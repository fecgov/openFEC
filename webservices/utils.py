import re
import functools
import json
import logging
import unicodedata
import requests
import six
import sqlalchemy as sa
import flask_restful as restful

from collections import defaultdict
from datetime import date
from sqlalchemy.orm import foreign
from sqlalchemy.ext.declarative import declared_attr
from sqlalchemy.dialects import postgresql
from elasticsearch import Elasticsearch, RequestsHttpConnection
import certifi
from requests_aws4auth import AWS4Auth
from marshmallow_pagination import paginators
from webargs import fields
from flask_apispec import use_kwargs as use_kwargs_original
from flask_apispec.views import MethodResourceMeta

from webservices.env import env
from webservices import docs
from webservices import sorting
from webservices import decoders
from webservices import exceptions

# import these 2 libraries to display the JSON formate with "datetime" data type
import datetime
from json import JSONEncoder


logger = logging.getLogger(__name__)

use_kwargs = functools.partial(use_kwargs_original, location="query")

DOCQUERY_URL = 'https://docquery.fec.gov'


class Resource(six.with_metaclass(MethodResourceMeta, restful.Resource)):
    pass


API_KEY_ARG = fields.Str(
     required=True, description=docs.API_KEY_DESCRIPTION,
)
if env.get_credential("PRODUCTION"):
    Resource = use_kwargs({"api_key": API_KEY_ARG})(Resource)

fec_url_map = {'9': DOCQUERY_URL + '/dcdev/posted/{0}.fec'}
fec_url_map = defaultdict(
    lambda: DOCQUERY_URL + '/paper/posted/{0}.fec', fec_url_map

)


def check_cap(kwargs, cap):
    if cap:
        if not kwargs.get("per_page") or kwargs["per_page"] > cap:
            raise exceptions.ApiError(
                "Parameter 'per_page' must be between 1 and {}".format(cap),
                status_code=422,
            )


def fetch_page(
    query,
    kwargs,
    model=None,
    aliases=None,
    join_columns=None,
    clear=False,
    count=None,
    cap=100,
    index_column=None,
    multi=False,
):
    check_cap(kwargs, cap)
    sort, hide_null, nulls_last = (
        kwargs.get("sort"),
        kwargs.get("sort_hide_null"),
        kwargs.get("sort_nulls_last"),
    )
    if sort and multi:
        query, _ = sorting.multi_sort(
            query,
            sort,
            model=model,
            aliases=aliases,
            join_columns=join_columns,
            clear=clear,
            hide_null=hide_null,
            index_column=index_column,
            nulls_last=nulls_last,
        )
    elif sort:
        query, _ = sorting.sort(
            query,
            sort,
            model=model,
            aliases=aliases,
            join_columns=join_columns,
            clear=clear,
            hide_null=hide_null,
            index_column=index_column,
            nulls_last=nulls_last,
        )
    paginator = paginators.OffsetPaginator(query, kwargs["per_page"], count=count)
    return paginator.get_page(kwargs["page"])


class SeekCoalescePaginator(paginators.SeekPaginator):
    def __init__(self, cursor, per_page, hide_null, index_column, sort_column=None, count=None):
        self.max_column_map = {
            "date": date.max,
            "float": float("inf"),
            "int": float("inf"),
        }
        self.min_column_map = {
            "date": date.min,
            "float": float("inf"),
            "int": float("inf"),
        }
        self.hide_null = hide_null
        super(SeekCoalescePaginator, self).__init__(
            cursor, per_page, index_column, sort_column, count
        )

    def _fetch(self, last_index, sort_index=None, limit=None, eager=True):
        cursor = self.cursor
        direction = self.sort_column[1] if self.sort_column else sa.asc
        lhs, rhs = (), ()

        if sort_index is not None:
            left_index = self.sort_column[0]

            # Check if we're using a sort expression and if so, use the type
            # associated with it instead of deriving it from the column.
            if not self.sort_column[3]:
                comparator = self.max_column_map.get(
                    str(left_index.property.columns[0].type).lower()
                )
            else:
                comparator = self.max_column_map.get(self.sort_column[5])

            # Only add coalesce if nulls allowed in sort index
            if "coalesce" not in str(left_index) and not self.hide_null:
                left_index = sa.func.coalesce(left_index, comparator)

            lhs += (left_index,)
            rhs += (sort_index,)

        if last_index is not None:
            lhs += (self.index_column,)
            rhs += (last_index,)

        lhs = sa.tuple_(*lhs)
        rhs = sa.tuple_(*rhs)

        if rhs.clauses:
            filter = lhs > rhs if direction == sa.asc else lhs < rhs
            cursor = cursor.filter(filter)

        query = cursor.order_by(direction(self.index_column)).limit(limit)
        return query.all() if eager else query

    def _get_index_values(self, result):
        """Get index values from last result, to be used in seeking to the next
        page. Optionally include sort values, if any.
        """
        from webservices.common.models import db

        ret = {"last_index": str(paginators.convert_value(result, self.index_column))}

        if self.sort_column:
            key = "last_{0}".format(self.sort_column[2])

            # Check to see if we are dealing with a sort column or sort
            # expression.  If we're dealing with a sort expression, we need to
            # override the value serialization with the sort expression
            # information.
            if not self.sort_column[3]:
                ret[key] = paginators.convert_value(result, self.sort_column[0])
            else:
                # Create a new query based on the result returned and replace
                # the SELECT portion with just the sort expression criteria.
                # Also augment the WHERE clause with a match for the value of
                # the index column found in the result so we only retrieve the
                # single row matching the result.
                # NOTE:  This ensures we maintain existing clauses such as the
                # check constraint needed for partitioned tables.
                sort_column_query = self.cursor.with_entities(
                    self.sort_column[0]
                ).filter(
                    getattr(result.__class__, self.index_column.key)
                    == getattr(result, self.index_column.key)
                )

                # Execute the new query to retrieve the value of the sort
                # expression.
                expression_value = db.engine.execute(
                    sort_column_query.statement
                ).scalar()

                # Serialize the value using the mapped marshmallow field
                # defined with the sort expression.
                ret[key] = self.sort_column[4]()._serialize(
                    expression_value, None, None
                )

            if ret[key] is None:
                ret.pop(key)
                ret["sort_null_only"] = True

        return ret


def fetch_seek_page(
    query, kwargs, index_column, clear=False, count=None, cap=100, eager=True
):
    paginator = fetch_seek_paginator(
        query, kwargs, index_column, clear=clear, count=count, cap=cap
    )
    if paginator.sort_column is not None:
        sort_index = kwargs["last_{0}".format(paginator.sort_column[2])]
        null_sort_by = paginator.sort_column[0]

        # Check to see if we are sorting by an expression.  If we are, we need
        # to account for an alternative way to sort and page by null values.
        if paginator.sort_column[3]:
            null_sort_by = paginator.sort_column[6]
        if (
            not sort_index
            and kwargs["sort_null_only"]
            and paginator.sort_column[1] == sa.asc
        ):
            sort_index = None
            query = query.filter(null_sort_by == None)  # noqa
            paginator.cursor = query
    else:
        sort_index = None

    return paginator.get_page(
        last_index=kwargs["last_index"], sort_index=sort_index, eager=eager
    )


def fetch_seek_paginator(query, kwargs, index_column, clear=False, count=None, cap=100):
    check_cap(kwargs, cap)
    model = index_column.parent.class_
    sort, hide_null, nulls_last = (
        kwargs.get("sort"),
        kwargs.get("sort_hide_null"),
        kwargs.get("sort_nulls_last"),
    )
    if sort:
        query, sort_column = sorting.sort(
            query,
            sort,
            model=model,
            clear=clear,
            hide_null=hide_null,
            nulls_last=nulls_last,
        )
    else:
        sort_column = None

    return SeekCoalescePaginator(
        query, kwargs["per_page"], kwargs["sort_hide_null"], index_column, sort_column=sort_column, count=count
    )


def extend(*dicts):
    ret = {}
    for each in dicts:
        ret.update(each)
    return ret


def parse_fulltext(text):
    '''
    The main purpose of parse_fulltext is to decompose user input into a safe form
    for searching that is tightly coupled with the way filed data is decomposed into
    TSVECTOR fields in the database.

    The general procedure is to split on and remove any nonword characters for converion
    to a form recogonized in the TSVECTOR search.  The 'text' argument is first unidecoded
    to remove accents, since both accented and non-accented versions exist in the searched
    tsvector column. This will lead to unaccented versions being returned when filed data
    does not contain accents.

    See Unicodedata documentation for additional details:
    https://docs.python.org/2/library/unicodedata.html

    "normalize" converts text to normal form (NFKD) and encodes it to ascii as a
    bytestring. For further parsing in re.sub below, the string is first decoded into
    ascii (the encode and decode are chained).
    '''
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode("ascii")
    return " & ".join([part + ":*" for part in re.sub(r"\W", " ", text).split()])


office_args_required = ["office", "cycle"]
office_args_map = {
    "house": ["state", "district"],
    "senate": ["state"],
}


def check_election_arguments(kwargs):
    for arg in office_args_required:
        if kwargs.get(arg) is None:
            raise exceptions.ApiError(
                "Required parameter '{0}' not found.".format(arg), status_code=422,
            )
    conditional_args = office_args_map.get(kwargs["office"], [])
    for arg in conditional_args:
        if kwargs.get(arg) is None:
            raise exceptions.ApiError(
                "Must include argument '{0}' with office type '{1}'".format(
                    arg, kwargs["office"],
                ),
                status_code=422,
            )


def get_model(name):
    from webservices.common.models import db

    return db.Model._decl_class_registry.get(name)


def related(
    related_model,
    id_label,
    related_id_label=None,
    cycle_label=None,
    related_cycle_label=None,
    use_modulus=True,
):
    from webservices.common.models import db

    related_model = get_model(related_model)
    related_id_label = related_id_label or id_label
    related_cycle_label = related_cycle_label or cycle_label

    @declared_attr
    def related(cls):
        id_column = getattr(cls, id_label)
        related_id_column = getattr(related_model, related_id_label)
        filters = [foreign(id_column) == related_id_column]
        if cycle_label:
            cycle_column = getattr(cls, cycle_label)
            if use_modulus:
                cycle_column = cycle_column + cycle_column % 2
            related_cycle_column = getattr(related_model, related_cycle_label)
            filters.append(cycle_column == related_cycle_column)
        return db.relationship(related_model, primaryjoin=sa.and_(*filters),)

    return related


related_committee = functools.partial(related, "CommitteeDetail", "committee_id")
related_candidate = functools.partial(related, "CandidateDetail", "candidate_id")

related_committee_history = functools.partial(
    related, "CommitteeHistory", "committee_id", related_cycle_label="cycle",
)
related_candidate_history = functools.partial(
    related, "CandidateHistory", "candidate_id", related_cycle_label="two_year_period",
)
related_efile_summary = functools.partial(
    related, "EFilings", "file_number", related_id_label="file_number",
)


def document_description(
    report_year, report_type=None, document_type=None, form_type=None
):
    if report_type:
        clean = re.sub(r"\{[^)]*\}", "", report_type)
    elif document_type:
        clean = document_type
    elif form_type and form_type in decoders.form_types:
        clean = decoders.form_types[form_type]
    else:
        clean = "Document"

    if form_type and (form_type == "RFAI" or form_type == "FRQ"):
        clean = "RFAI: " + clean
    return "{0} {1}".format(clean.strip(), report_year)


def make_report_pdf_url(image_number):
    if image_number:
        return DOCQUERY_URL + '/pdf/{0}/{1}/{1}.pdf'.format(
            str(image_number)[-3:], image_number,
        )
    else:
        return None


def make_schedule_pdf_url(image_number):
    if image_number:
        return DOCQUERY_URL + '/cgi-bin/fecimg/?' + image_number


def make_csv_url(file_num):
    file_number = str(file_num)
    if file_num > -1 and file_num < 100:
        return DOCQUERY_URL + '/csv/000/{0}.csv'.format(file_number)
    elif file_num >= 100:
        return DOCQUERY_URL + '/csv/{0}/{1}.csv'.format(
            file_number[-3:], file_number
        )


def make_fec_url(image_number, file_num):
    image_number = str(image_number)
    if file_num < 0 or file_num is None:
        return
    file_num = str(file_num)
    indicator = -1
    if len(image_number) == 18:
        indicator = image_number[8]
    elif len(image_number) == 11:
        indicator = image_number[2]
    return fec_url_map[indicator].format(file_num)


def get_index_column(model):
    column = model.__mapper__.primary_key[0]
    return getattr(model, column.key)


def cycle_param(**kwargs):
    ret = {
        "name": "cycle",
        "type": "integer",
        "in": "path",
    }
    ret.update(kwargs)
    return ret


def get_election_duration(column):
    return sa.case([(column == "S", 6), (column == "P", 4), ], else_=2,)


def get_current_cycle():
    year = date.today().year
    return year + year % 2


ES_SERVICE_INSTANCE_NAME = "fec-api-elasticsearch"
AWS_ES_SERVICE = "es"
REGION = "us-gov-west-1"
PORT = 443


def get_service_instance(service_instance_name):
    return env.get_service(name=service_instance_name)


def get_service_instance_credentials(service_instance):
    return service_instance.credentials


def create_es_client():
    try:
        es_service = get_service_instance(ES_SERVICE_INSTANCE_NAME)
        if es_service:
            credentials = es_service.credentials
            #  create "http_auth".
            host = credentials["host"]
            access_key = credentials["access_key"]
            secret_key = credentials["secret_key"]
            aws_auth = AWS4Auth(access_key, secret_key, REGION, AWS_ES_SERVICE)

            #  create elasticsearch client through "http_auth"
            es_client = Elasticsearch(
                hosts=[{"host": host, "port": PORT}],
                http_auth=aws_auth,
                use_ssl=True,
                verify_certs=True,
                ca_certs=certifi.where(),
                connection_class=RequestsHttpConnection,
                timeout=40,
                max_retries=10,
                retry_on_timeout=True,
            )
        else:
            # create local elasticsearch client
            url = "http://localhost:9200"
            es_client = Elasticsearch(
                url,
                timeout=30,
                max_retries=10,
                retry_on_timeout=True,
            )
        return es_client
    except Exception as err:
        logger.error("An error occurred trying to create Elasticsearch client.{0}".format(err))


def print_literal_query_string(query):
    print(
        str(
            query.statement.compile(
                dialect=postgresql.dialect(), compile_kwargs={"literal_binds": True}
            )
        )
    )


def create_eregs_link(part, section):
    url_part_section = part
    if section:
        url_part_section += "-" + section
    return "/regulations/{}/CURRENT".format(url_part_section)


def post_to_slack(message, channel):
    response = requests.post(
        env.get_credential("SLACK_HOOK"),
        data=json.dumps(
            {
                "text": message,
                "channel": channel,
                "link_names": 1,
                "username": "Ms. Robot",
                "icon_emoji": ":robot_face:",
            }
        ),
        headers={"Content-Type": "application/json"},
    )
    if response.status_code != 200:
        logger.error("SLACK ERROR- Message failed to send:{0}".format(message))


def split_env_var(env_var):
    """ Remove whitespace and split to a list based of comma delimiter"""
    return env_var.replace(" ", "").split(",")


# To display the open_date and close_date of JSON format inside object "mur"
class DateTimeEncoder(JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (datetime.date, datetime.datetime)):
            return obj.isoformat()


def get_percentage(numerators, denominators):
    """Calculate the percentage numerators (top) are of denominators (bottom), 2 decimals

    If unable to calculate, return None
    """

    # Values must be in a list
    if not isinstance(numerators, list) and isinstance(denominators, list):
        raise TypeError("Numerator and denominators must be type 'list'")

    # Unable to calculate unless ALL values are present
    if None in numerators or None in denominators:
        return None

    try:
        numerator = sum(value for value in numerators)
        denominator = sum(value for value in denominators)
        percentage = round((numerator / denominator) * 100, 2)
        return percentage

    # None for divide by zero errors
    except ZeroDivisionError:
        return None

    # Output unexpected exceptions in debug mode
    except Exception as exception:
        logger.debug(exception, False)
        return None


def report_type_full(report_type, form_type, report_type_full_original):
    if form_type in ('F5', 'F24') and report_type in ('24', '48'):
        return report_type + "-HOUR REPORT OF INDEPENDENT EXPENDITURES"
    elif form_type == 'F6':
        return "48-HOUR NOTICE OF CONTRIBUTIONS OR LOANS RECEIVED"
    else:
        return report_type_full_original
