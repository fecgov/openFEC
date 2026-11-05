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
from marshmallow_pagination import paginators
from webargs import fields
from flask_apispec import use_kwargs as use_kwargs_original
from flask_apispec.views import MethodResourceMeta

from webservices.env import env
from webservices import docs
from webservices import sorting
from webservices import decoders
from webservices import exceptions


logger = logging.getLogger(__name__)

use_kwargs = functools.partial(use_kwargs_original, location="query")

DOCQUERY_URL = 'https://docquery.fec.gov'


class Resource(six.with_metaclass(MethodResourceMeta, restful.Resource)):
    pass


VALID_TRUE_VALUES = ("true", True, "True", 'TRUE')


API_KEY_ARG = fields.Str(
     load_default="DEMO_KEY", metadata={'description': docs.API_KEY_DESCRIPTION},
)
if env.get_credential("PRODUCTION") or env.get_credential("STAGE"):
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
    session,
    is_count_exact=None,
    model=None,
    aliases=None,
    join_columns=None,
    clear=False,
    count=None,
    cap=100,
    index_column=None,
    multi=False,
    **options
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
    paginator = paginators.OffsetPaginator(query, kwargs["per_page"],
                                           session, is_count_exact=is_count_exact, count=count, **options)
    return paginator.get_page(kwargs["page"], **options)


class SeekCoalescePaginator(paginators.SeekPaginator):
    def __init__(self, cursor, per_page, hide_null, index_column, session,
                 is_count_exact=None, sort_column=None, count=None):
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
        self.session = session
        super(SeekCoalescePaginator, self).__init__(
            cursor, per_page, index_column, session, is_count_exact, sort_column, count
        )

    def _fetch(self, last_index, sort_index=None, limit=None):
        if self.count == 0:
            self.is_count_exact = True
            return []
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
        return self.session.execute(query).unique().scalars().all()

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
                sort_column_query = sa.select(self.sort_column[0]).filter(
                    getattr(result.__class__, self.index_column.key)
                    == getattr(result, self.index_column.key)
                )

                # Execute the new query to retrieve the value of the sort
                # expression.
                expression_value = db.session.execute(
                    sort_column_query
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


class SeekNullsPaginator(paginators.SeekPaginator):
    """Keyset paginator that places null sort values first.
        ascending:
            1. NULL rows ordered by index_column ASC
            2. non-NULL rows ordered by sort_column ASC, index_column ASC
        descending:
            1. NULL rows ordered by index_column ASC
            2. non-NULL rows ordered by sort_column DESC, index_column DESC
    """

    def __init__(
        self,
        cursor,
        per_page,
        hide_null,
        index_column,
        session,
        is_count_exact=None,
        sort_column=None,
        count=None,
    ):
        self.hide_null = bool(hide_null)
        self.session = session

        super(SeekNullsPaginator, self).__init__(
            cursor,
            per_page,
            index_column,
            session,
            is_count_exact,
            sort_column,
            count,
        )

    def _get_direction(self):
        if self.sort_column is None:
            return sa.asc, True

        direction = self.sort_column[1]

        if direction is sa.asc or direction == sa.asc:
            return sa.asc, True

        if direction is sa.desc or direction == sa.desc:
            return sa.desc, False

        raise ValueError(
            "Unsupported sort direction. Expected sqlalchemy.asc or "
            "sqlalchemy.desc."
        )

    @staticmethod
    def _apply_seek_filter(query, lhs, rhs, ascending):
        """Apply the appropriate keyset comparison."""
        if ascending:
            return query.filter(lhs > rhs)

        return query.filter(lhs < rhs)

    def _execute(self, query):
        """
        The incoming query must not multiply ORM entities through joins.
        SQL LIMIT is applied before Result.unique().
        """
        return self.session.execute(query).unique().scalars().all()

    def _fetch_null_rows(self, cursor, sort_col, last_index, limit):
        query = cursor.filter(sort_col.is_(None))

        if last_index is not None:
            query = query.filter(self.index_column > last_index)

        query = (
            query.order_by(None)
            .order_by(sa.asc(self.index_column))
            .limit(limit)
        )

        return self._execute(query)

    def _fetch_non_null_rows(
        self,
        cursor,
        sort_col,
        direction,
        ascending,
        limit,
        sort_index=None,
        last_index=None,
    ):
        """Fetch rows from the non-NULL block."""
        query = cursor.filter(sort_col.is_not(None))

        if sort_index is not None:
            if last_index is not None:
                lhs = sa.tuple_(sort_col, self.index_column)
                rhs = sa.tuple_(sort_index, last_index)
            else:
                lhs = sort_col
                rhs = sort_index

            query = self._apply_seek_filter(
                query,
                lhs,
                rhs,
                ascending,
            )

        query = (
            query.order_by(None)
            .order_by(
                direction(sort_col),
                direction(self.index_column),
            )
            .limit(limit)
        )

        return self._execute(query)

    def _fetch_single_query(
        self,
        cursor,
        direction,
        ascending,
        last_index,
        sort_index,
        limit,
    ):
        """Fetch a page when no split NULL query is necessary."""
        query = cursor.order_by(None)

        if self.sort_column is None:
            if last_index is not None:
                query = query.filter(self.index_column > last_index)

            query = query.order_by(sa.asc(self.index_column))
        else:
            sort_col = self.sort_column[0]

            if sort_index is not None and last_index is not None:
                lhs = sa.tuple_(sort_col, self.index_column)
                rhs = sa.tuple_(sort_index, last_index)

                query = self._apply_seek_filter(
                    query,
                    lhs,
                    rhs,
                    ascending,
                )
            elif sort_index is not None:
                query = self._apply_seek_filter(
                    query,
                    sort_col,
                    sort_index,
                    ascending,
                )
            elif last_index is not None:
                # This state is valid for an index-only cursor. It should not
                # normally occur for a non-null sorted continuation cursor.
                query = query.filter(self.index_column > last_index)

            query = query.order_by(
                direction(sort_col),
                direction(self.index_column),
            )

        query = query.limit(limit)
        return self._execute(query)

    def _fetch(self, last_index, sort_index=None, limit=None):
        if self.count == 0:
            self.is_count_exact = True
            return []

        if limit is None or limit <= 0:
            raise ValueError("limit must be a positive integer")

        cursor = self.cursor
        direction, ascending = self._get_direction()

        # No explicit sort expression or NULL rows have already been removed
        # by sorting.sort(..., hide_null=True).
        if self.sort_column is None or self.hide_null:
            return self._fetch_single_query(
                cursor=cursor,
                direction=direction,
                ascending=ascending,
                last_index=last_index,
                sort_index=sort_index,
                limit=limit,
            )

        sort_col = self.sort_column[0]

        # A missing sort value means either:
        #   * this is the first page, when last_index is also None; or
        #   * the previous page ended on a NULL row.
        if sort_index is None:
            null_results = self._fetch_null_rows(
                cursor=cursor,
                sort_col=sort_col,
                last_index=last_index,
                limit=limit,
            )

            if len(null_results) == limit:
                return null_results

            remaining = limit - len(null_results)

            non_null_results = self._fetch_non_null_rows(
                cursor=cursor,
                sort_col=sort_col,
                direction=direction,
                ascending=ascending,
                limit=remaining,
            )

            return null_results + non_null_results

        # The previous page ended in the non-NULL block.
        return self._fetch_non_null_rows(
            cursor=cursor,
            sort_col=sort_col,
            direction=direction,
            ascending=ascending,
            limit=limit,
            sort_index=sort_index,
            last_index=last_index,
        )

    def _get_index_values(self, result):
        last_index = paginators.convert_value(
            result,
            self.index_column,
        )

        if last_index is None:
            raise ValueError(
                "index_column returned NULL. Seek pagination requires a "
                "non-null index column."
            )

        ret = {
            "last_index": str(last_index),
        }

        if self.sort_column is not None:
            sort_key = "last_{0}".format(self.sort_column[2])
            sort_value = paginators.convert_value(
                result,
                self.sort_column[0],
            )

            if sort_value is None:
                ret["sort_null_only"] = True
            else:
                ret[sort_key] = sort_value

        return ret


def fetch_seek_page_nulls(
    query,
    kwargs,
    index_column,
    session,
    is_count_exact=None,
    clear=False,
    count=None,
    cap=100,
):
    paginator = fetch_seek_paginator_nulls(
        query=query,
        kwargs=kwargs,
        index_column=index_column,
        session=session,
        is_count_exact=is_count_exact,
        clear=clear,
        count=count,
        cap=cap,
    )

    last_index = kwargs.get("last_index")

    if last_index == "":
        raise ValueError("last_index cannot be an empty string")

    sort_index = None

    if paginator.sort_column is not None:
        sort_key = "last_{0}".format(paginator.sort_column[2])
        sort_null_only = bool(kwargs.get("sort_null_only", False))
        supplied_sort_index = kwargs.get(sort_key)

        if sort_null_only and supplied_sort_index is not None:
            raise ValueError(
                "Cursor cannot contain both sort_null_only=True and "
                "a non-null sort cursor."
            )

        if (
            last_index is not None
            and not sort_null_only
            and supplied_sort_index is None
        ):
            raise ValueError(
                "A sorted continuation cursor must contain either "
                "sort_null_only=True or a non-null sort cursor."
            )

        if not sort_null_only:
            sort_index = supplied_sort_index

    return paginator.get_page(
        last_index=last_index,
        sort_index=sort_index,
    )


def fetch_seek_paginator_nulls(
    query,
    kwargs,
    index_column,
    session,
    is_count_exact=None,
    clear=False,
    count=None,
    cap=100,
):
    check_cap(kwargs, cap)

    model = index_column.parent.class_

    sort = kwargs.get("sort")
    hide_null = bool(kwargs.get("sort_hide_null", False))
    nulls_last = bool(kwargs.get("sort_nulls_last", False))

    if nulls_last and not hide_null:
        raise ValueError(
            "SeekNullsPaginator does not support sort_nulls_last=True"
        )

    if sort:
        query, sort_column = sorting.sort(
            query,
            sort,
            model=model,
            clear=clear,
            hide_null=hide_null,
            nulls_last=False,
        )
    else:
        sort_column = None

    return SeekNullsPaginator(
        cursor=query,
        per_page=kwargs["per_page"],
        hide_null=hide_null,
        index_column=index_column,
        session=session,
        is_count_exact=is_count_exact,
        sort_column=sort_column,
        count=count,
    )


def fetch_seek_page(
    query, kwargs, index_column, session, is_count_exact=None, clear=False, count=None, cap=100
):

    paginator = fetch_seek_paginator(
        query, kwargs, index_column, session, is_count_exact=is_count_exact, clear=clear, count=count, cap=cap
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
        last_index=kwargs["last_index"], sort_index=sort_index
    )


def fetch_seek_paginator(query, kwargs, index_column, session, is_count_exact=None, clear=False, count=None, cap=100):
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
        query,
        kwargs["per_page"],
        kwargs["sort_hide_null"],
        index_column,
        session,
        is_count_exact=is_count_exact,
        sort_column=sort_column,
        count=count
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


def check_committee_id(committee_id):
    # A valid committee_id begins with a 'C' followed by 8 digits
    committee_id = committee_id.lstrip('-')
    if len(committee_id) != 9 or not committee_id.startswith('C'):
        raise exceptions.ApiError(
            exceptions.COMMITTEE_ID_ERROR,
            status_code=422)

    try:
        committee_id = int(committee_id[1:])
    except (TypeError, ValueError):
        raise exceptions.ApiError(
            exceptions.COMMITTEE_ID_ERROR,
            status_code=422)


def check_candidate_id(candidate_id):
    # A valid candidate_id begins with a 'P' or 'H' or 'S' followed by 8 letters or numbers
    if len(candidate_id.lstrip('-')) != 9 or candidate_id.lstrip('-')[0] not in ('P', 'S', 'H'):
        raise exceptions.ApiError(
            exceptions.CANDIDATE_ID_ERROR,
            status_code=422)


def get_model(name):
    from webservices.common.models import db
    return db.Model.registry._class_registry.get(name)


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
    report_year, report_type=None, document_type_full=None, form_type=None
):

    if report_type:
        clean = re.sub(r"\{[^)]*\}", "", report_type)
    elif document_type_full:
        clean = document_type_full
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
    return sa.case((column == "S", 6), (column == "P", 4), else_=2,)


def get_current_cycle():
    year = date.today().year
    return year + year % 2


def print_literal_query_string(query):
    print(
        str(
            query.statement.compile(
                dialect=postgresql.dialect(), compile_kwargs={"literal_binds": True}
            )
        )
    )


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


def check_form_line_number(kwargs):
    if 'form_line_number' in kwargs:
        for each in kwargs['form_line_number']:
            if each.startswith('-'):
                each = each[1:]
            if len(each.split('-')) != 2 or not each.startswith('F'):
                raise exceptions.ApiError(
                    exceptions.FORM_LINE_NUMBER_ERROR, status_code=400
                )


def validate_and_filter_zip_codes(query, kwargs, zip_field, filters, filter_fields):
    if kwargs.get(zip_field):
        zip_list = []
        for value in kwargs[zip_field]:
            if re.search('[^a-zA-Z0-9-\s]', value): # noqa
                raise exceptions.ApiError(
                    exceptions.INVALID_ZIP,
                    status_code=422,
                )
            else:
                zip_list.append(value[:5])
        contributor_zip_list = {zip_field: zip_list}
        query = filters.filter_multi_start_with(
            query, contributor_zip_list, filter_fields
        )
    return query
