import re

from elasticsearch_dsl import Search, Q
from webargs import fields
from flask import abort
from flask_apispec import doc
from webservices import docs
from webservices import args
from webservices import filters
from webservices.utils import (
    create_es_client,
    Resource,
    DateTimeEncoder,
)
from webservices.legal_docs.es_management import (  # noqa
    SEARCH_ALIAS,
)
from webservices.utils import use_kwargs
from elasticsearch import RequestError
from webservices.exceptions import ApiError
import webservices.legal_docs.responses as responses
import logging
import json


logger = logging.getLogger(__name__)

# To debug, uncomment the line below:
# logger.setLevel(logging.DEBUG)

es_client = create_es_client()

INNER_HITS = {
    "_source": False,
    "highlight": {
        "require_field_match": False,
        "fields": {"documents.text": {}, "documents.description": {}},
    },
    "size": 100,
}

ALL_DOCUMENT_TYPES = [
    "statutes",
    "advisory_opinions",
    "murs",
    "adrs",
    "admin_fines",
]

ACCEPTED_DATE_FORMATS = "strict_date_optional_time_nanos||MM/dd/yyyy||M/d/yyyy||MM/d/yyyy||M/dd/yyyy"

REQUESTOR_TYPES = {
            "1": "Federal candidate/candidate committee/officeholder",
            "2": "Publicly funded candidates/committees",
            "3": "Party committee, national",
            "4": "Party committee, state or local",
            "5": "Nonconnected political committee",
            "6": "Separate segregated fund",
            "7": "Labor Organization",
            "8": "Trade Association",
            "9": "Membership Organization, Cooperative, Corporation W/O Capital Stock",
            "10": "Corporation (including LLCs electing corporate status)",
            "11": "Partnership (including LLCs electing partnership status)",
            "12": "Governmental entity",
            "13": "Research/Public Interest/Educational Institution",
            "14": "Law Firm",
            "15": "Individual",
            "16": "Other",
}

# endpoint path: /legal/docs/<doc_type>/<no>
# under tag: legal
# test urls:
# http://127.0.0.1:5000/v1/legal/docs/statutes/9001/
# http://127.0.0.1:5000/v1/legal/docs/advisory_opinions/2022-25/
# http://127.0.0.1:5000/v1/legal/docs/murs/8070/
# http://127.0.0.1:5000/v1/legal/docs/adrs/1091/
# http://127.0.0.1:5000/v1/legal/docs/admin_fines/4399/


# TODO: add this endpoint to swagger
@doc(
    tags=["legal"],
    description=docs.LEGAL_DOC_SEARCH,
)
class GetLegalDocument(Resource):
    @property
    def args(self):
        return {
            "no": fields.Str(required=True, description=docs.LEGAL_DOC_NO),
            "doc_type": fields.Str(required=True, description=docs.LEGAL_DOC_TYPE),
        }

    def get(self, doc_type, no, **kwargs):
        es_results = (
            Search()
            .using(es_client)
            .query("bool", must=[Q("term", no=no), Q("term", type=doc_type)])
            .source(exclude="documents.text")
            .extra(size=200)
            .index(SEARCH_ALIAS)
            .execute()
        )

        results = {"docs": [hit.to_dict() for hit in es_results]}
        # logger.debug("GetLegalDocument() results =" + json.dumps(results, indent=3, cls=DateTimeEncoder))

        if len(results["docs"]) > 0:
            return results
        else:
            return abort(404)


# endpoint path: /legal/search/
# under tag: legal
# test url: http://127.0.0.1:5000/v1/legal/search/?case_no=3744&type=murs
@doc(
    tags=["legal"],
    description=docs.LEGAL_SEARCH,
    responses=responses.LEGAL_SEARCH_RESPONSE,
)
class UniversalSearch(Resource):
    @use_kwargs(args.legal_universal_search)
    def get(self, q="", from_hit=0, hits_returned=20, **kwargs):
        query_builders = {
            "statutes": generic_query_builder,
            "advisory_opinions": ao_query_builder,
            "murs": case_query_builder,
            "adrs": case_query_builder,
            "admin_fines": case_query_builder,
        }
        # Get the type from kwargs, defaulting to '' if not present
        if kwargs.get("type", "") == "":
            doc_types = ALL_DOCUMENT_TYPES
        else:
            doc_types = [kwargs.get("type")]

        hits_returned = min([200, hits_returned])

        results = {}
        total_count = 0
        count_by_type = 0
        for type_ in doc_types:
            try:
                query = query_builders.get(type_)(
                    q, type_, from_hit, hits_returned, **kwargs
                )
                logger.debug("UniversalSearch() final query =" + json.dumps(
                    query.to_dict(), indent=3, cls=DateTimeEncoder))
                formatted_hits, count_by_type = execute_query(query)
            except TypeError as te:
                logger.error(te.args)
                raise ApiError("Not a valid search type", 400)
            except RequestError as e:
                logger.error(e.args)
                raise ApiError("Elasticsearch failed to execute query", 400)
            except Exception as e:
                logger.error(e.args)
                raise ApiError("Unexpected Server Error", 500)
            results[type_] = formatted_hits
            results["total_%s" % type_] = count_by_type
            total_count += count_by_type
            logger.debug("total count={0}".format(str(total_count)))
        results["total_all"] = total_count
        return results


def generic_query_builder(q, type_, from_hit, hits_returned, **kwargs):
    must_query = [Q("term", type=type_)]
    proximity_query = False

    if q:
        must_query.append(Q("simple_query_string", query=q))

    if check_filter_exists(kwargs, "q_proximity") and kwargs.get("max_gaps") is not None:
        proximity_query = True

    query = (
        Search()
        .using(es_client)
        .query(Q("bool", must=must_query))
        .highlight_options(require_field_match=False)
        .source(exclude=["text", "documents.text", "sort1", "sort2"])
        .extra(size=hits_returned, from_=from_hit)
        .index(SEARCH_ALIAS)
        .sort("sort1", "sort2")
    )

    if not proximity_query:
        if type_ == "advisory_opinions":
            query = query.highlight("summary", "documents.text", "documents.description")
        elif type_ == "statutes":
            query = query.highlight("name", "no")
        else:
            query = query.highlight("documents.text", "documents.description")

    if kwargs.get("q_exclude"):
        must_not = []
        must_not.append(
            Q(
                "nested",
                path="documents",
                query=Q(
                    "simple_query_string",
                    query=kwargs.get("q_exclude"),
                    fields=["documents.text"]
                )
            )
        )
        if type_ == "statutes":
            must_not.append(Q("simple_query_string",
                            query=kwargs.get("q_exclude"), fields=["name"]))
        query = query.query("bool", must_not=must_not)

    # logging.warning("generic_query_builder =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return query


def case_query_builder(q, type_, from_hit, hits_returned, **kwargs):
    query = generic_query_builder(None, type_, from_hit, hits_returned, **kwargs)

    # sorting works in all three cases: ('murs','admin_fines','adrs').
    # so far only be able to sort by 'case_no', default sort is descending order.
    # descending order: 'sort=-case_no'; ascending order; sort=case_no
    # https://fec-dev-api.app.cloud.gov/v1/legal/search/?type=murs&sort=-case_no
    # https://fec-dev-api.app.cloud.gov/v1/legal/search/?type=murs&sort=case_no

    if kwargs.get("sort") and kwargs.get("sort").upper() == "CASE_NO":
        query = query.sort({"case_serial": {"order": "asc"}, "mur_type": {"order": "desc"}})
    else:
        query = query.sort({"case_serial": {"order": "desc"}, "mur_type": {"order": "desc"}})

    should_query = [
        get_case_document_query(q, **kwargs),
    ]
    query = query.query("bool", should=should_query, minimum_should_match=1)

    # add mur_dispositions_category_id filter
    if kwargs.get("mur_disposition_category_id") and type_ == "murs":
        should_query_mur_disposition = [
            get_mur_disposition_query(q, **kwargs),
        ]
        query = query.query("bool", should=should_query_mur_disposition, minimum_should_match=1)

    must_clauses = []
    if check_filter_exists(kwargs, "case_no"):
        must_clauses.append(Q("terms", no=kwargs.get("case_no")))

    # Get 'primary_subject_id' from kwargs
    primary_subject_id = kwargs.get("primary_subject_id", [])
    primary_subject_id_valid_values = ['1', '2', '3', '4', '5', '6', '7', '8', '9',
                                       '10', '11', '12', '13', '14', '15', '16',
                                       '17', '18', '19', '20']

    # Validate 'primary_subject_id filter'
    valid_primary_subject_id = filters.validate_multiselect_filter(
        primary_subject_id, primary_subject_id_valid_values)

    if valid_primary_subject_id:
        must_clauses.append(Q("nested", path="subjects",
                            query=Q("terms", subjects__primary_subject_id=valid_primary_subject_id)))

    # Get 'secondary_subject_id' from kwargs
    secondary_subject_id = kwargs.get("secondary_subject_id", [])
    secondary_subject_id_valid_values = ['1', '2', '3', '4', '5', '6', '7', '8', '9',
                                         '10', '11', '12', '13', '14', '15', '16',
                                         '17', '18']

    # Validate 'secondary_subject_id filter'
    valid_secondary_subject_id = filters.validate_multiselect_filter(
        secondary_subject_id, secondary_subject_id_valid_values)

    if valid_secondary_subject_id:
        must_clauses.append(Q("nested", path="subjects",
                            query=Q("terms", subjects__secondary_subject_id=valid_secondary_subject_id)))

    if kwargs.get("case_respondents"):
        must_clauses.append(Q("simple_query_string",
                            query=kwargs.get("case_respondents"), fields=["respondents"]))

    if kwargs.get("case_regulatory_citation") or kwargs.get("case_statutory_citation"):
        return case_apply_citation_params(
            query,
            kwargs.get("case_regulatory_citation"),
            kwargs.get("case_statutory_citation"),
            kwargs.get("case_citation_require_all"), **kwargs)

    penalty_range = {}
    if kwargs.get("case_min_penalty_amount") and kwargs.get("case_min_penalty_amount") != '':
        penalty_range["gte"] = kwargs.get("case_min_penalty_amount")

    if kwargs.get("case_max_penalty_amount") and kwargs.get("case_max_penalty_amount") != '':
        penalty_range["lte"] = kwargs.get("case_max_penalty_amount")

    if penalty_range:
        must_clauses.append(Q("nested", path="dispositions",
                            query=Q("range", dispositions__penalty=penalty_range)))
    query = query.query("bool", must=must_clauses)

    # logger.debug("case_query_builder =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

    if type_ == "admin_fines":
        return apply_af_specific_query_params(query, **kwargs)
    elif type_ == "murs":
        return apply_mur_specific_query_params(query, **kwargs)
    else:
        return apply_adr_specific_query_params(query, **kwargs)


def get_proximity_query(**kwargs):
    q_proximity = kwargs.get("q_proximity")
    max_gaps = kwargs.get("max_gaps")
    intervals_list = []
    contains_filter = False

    if kwargs.get("proximity_filter") and kwargs.get("proximity_filter_term"):
        contains_filter = True
        filter = "before" if kwargs.get("proximity_filter") == "after" else "after"
        filters = {filter: {'match': {'query': kwargs.get("proximity_filter_term"), "max_gaps": 0, "ordered": True}}}

    if len(q_proximity) == 1:
        if contains_filter:
            intervals_inner_query = Q('intervals', documents__text={
                'match':  {'query': q_proximity[0], 'max_gaps': max_gaps, "filter": filters, "ordered": True}
                })
        else:
            intervals_inner_query = Q('intervals', documents__text={
                'match':  {'query': q_proximity[0], 'max_gaps': max_gaps, "ordered": True}
                })
    else:
        for q in q_proximity:
            dict_item = {"match": {"query": q, "max_gaps": 0, "ordered": True}}
            intervals_list.append(dict_item)

        if contains_filter:
            intervals_inner_query = Q('intervals', documents__text={
                    'all_of':  {'max_gaps': max_gaps, "intervals": intervals_list, "filter": filters}
                    })
        else:
            intervals_inner_query = Q('intervals', documents__text={
                    'all_of':  {'max_gaps': max_gaps, "intervals": intervals_list}
                    })
    return intervals_inner_query

# Select one or more case_doc_category_id to filter by corresponding case_document_category
# - 1 - Conciliation and Settlement Agreements
# - 2 - Complaint, Responses, Designation of Counsel and Extensions of Time
# - 3 - General Counsel Reports, Briefs, Notifications and Responses
# - 4 - Certifications
# - 5 - Civil Penalties, Disgorgements, Other Payments and Letters of Compliance
# - 6 - Statement of Reasons
# ADR document categories
# - 1001 - ADR Settlement Agreements
# - 1002 - Complaint, Responses, Designation of Counsel and Extensions of Time
# - 1003 - ADR Memoranda, Notifications and Responses
# - 1004 - Certifications
# - 1005 - Civil Penalties, Disgorgements, Other Payments and Letters of Compliance
# - 1006 - Statement of Reasons
# AF document category
# - 2001 - Administrative Fine Case


def get_case_document_query(q, **kwargs):
    combined_query = []
    category_queries = []
    if kwargs.get("case_doc_category_id") and (len(kwargs.get("case_doc_category_id")) > 0):
        for doc_category_id in kwargs.get("case_doc_category_id"):
            if len(doc_category_id) > 0:
                category_queries.append(
                    Q(
                        "match",
                        documents__doc_order_id=doc_category_id,
                    ),
                )

        combined_query.append(Q("bool", should=category_queries, minimum_should_match=1))

    case_document_date_range = {}
    if kwargs.get("case_min_document_date"):
        case_document_date_range["gte"] = kwargs.get("case_min_document_date")
    if kwargs.get("case_max_document_date"):
        case_document_date_range["lte"] = kwargs.get("case_max_document_date")
    if case_document_date_range:
        case_document_date_range["format"] = ACCEPTED_DATE_FORMATS
        combined_query.append(Q("range", documents__document_date=case_document_date_range))
    if q:
        q_query = Q("simple_query_string", query=q, fields=["documents.text"])
        combined_query.append(q_query)

    if check_filter_exists(kwargs, "q_proximity") and kwargs.get("max_gaps") is not None:
        combined_query.append(get_proximity_query(**kwargs))
        proximity_inner_hits = {"_source": {"excludes": ["documents.text"]}, "size": 100}

        if q:
            proximity_inner_hits["highlight"] = {
                "require_field_match": False,
                "fields": {"documents.text": {}, "documents.description": {}, },
                "highlight_query": q_query.to_dict()
                }

        return Q(
            "nested",
            path="documents",
            inner_hits=proximity_inner_hits,
            query=Q("bool", must=combined_query),
        )

    return Q(
        "nested",
        path="documents",
        inner_hits=INNER_HITS,
        query=Q("bool", must=combined_query),
    )


def get_mur_disposition_query(q, **kwargs):
    combined_query = []
    category_queries = []
    if kwargs.get("mur_disposition_category_id") and (len(kwargs.get("mur_disposition_category_id")) > 0):

        for mur_disposition_category_id in kwargs.get("mur_disposition_category_id"):
            if len(mur_disposition_category_id) > 0:
                category_queries.append(
                    Q(
                        "match",
                        dispositions__mur_disposition_category_id=mur_disposition_category_id,
                    ),
                )
        combined_query.append(Q("bool", should=category_queries, minimum_should_match=1))

    return Q(
        "nested",
        path="dispositions",
        inner_hits=INNER_HITS,
        query=Q("bool", must=combined_query),
    )


def apply_af_specific_query_params(query, **kwargs):
    must_clauses = []
    if check_filter_exists(kwargs, "af_name"):
        must_clauses.append(Q("match", name=" ".join(kwargs.get("af_name"))))
    if kwargs.get("af_committee_id"):
        must_clauses.append(Q("match", committee_id=kwargs.get("af_committee_id")))
    if kwargs.get("af_report_year"):
        must_clauses.append(Q("match", report_year=kwargs.get("af_report_year")))

    date_range = {}
    if kwargs.get("af_min_rtb_date"):
        date_range["gte"] = kwargs.get("af_min_rtb_date")
    if kwargs.get("af_max_rtb_date"):
        date_range["lte"] = kwargs.get("af_max_rtb_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", reason_to_believe_action_date=date_range))

    date_range = {}
    if kwargs.get("af_min_fd_date"):
        date_range["gte"] = kwargs.get("af_min_fd_date")
    if kwargs.get("af_max_fd_date"):
        date_range["lte"] = kwargs.get("af_max_fd_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", final_determination_date=date_range))

    if kwargs.get("af_rtb_fine_amount") is not None:
        must_clauses.append(
            Q("term", reason_to_believe_fine_amount=kwargs.get("af_rtb_fine_amount"))
        )
    if kwargs.get("af_fd_fine_amount") is not None:
        must_clauses.append(
            Q("term", final_determination_amount=kwargs.get("af_fd_fine_amount"))
        )

    query = query.query("bool", must=must_clauses)
    # logger.debug("apply_af_specific_query_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

    return query


def apply_mur_specific_query_params(query, **kwargs):
    must_clauses = []

    if check_filter_exists(kwargs, "mur_type"):
        must_clauses.append(Q("match", mur_type=kwargs.get("mur_type")))

    if kwargs.get("case_election_cycles"):
        must_clauses.append(
            Q("term", election_cycles=kwargs.get("case_election_cycles"))
        )

    # gte/lte: greater than or equal to/less than or equal to
    date_range = {}
    if kwargs.get("case_min_open_date"):
        date_range["gte"] = kwargs.get("case_min_open_date")
    if kwargs.get("case_max_open_date"):
        date_range["lte"] = kwargs.get("case_max_open_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", open_date=date_range))

    date_range = {}
    if kwargs.get("case_min_close_date"):
        date_range["gte"] = kwargs.get("case_min_close_date")
    if kwargs.get("case_max_close_date"):
        date_range["lte"] = kwargs.get("case_max_close_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", close_date=date_range))

    query = query.query("bool", must=must_clauses)
    # logger.debug("apply_mur_adr_specific_query_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return query


def case_apply_citation_params(query, regulatory_citation, statutory_citation, citation_require_all, **kwargs):
    #  regulatory citation example: 11 CFR §112.4
    #  statutory citation example: 52 U.S.C. §30106
    must_clauses = []
    citation_queries = []
    if regulatory_citation:

        for citation in regulatory_citation:
            exact_match = re.match(
                r"(?P<title>\d+)\s+C\.?F\.?R\.?\s+§*\s*(?P<text>\d+\.\d+)",
                citation,
            )
            if exact_match:
                citation_queries.append(
                    Q(
                        "nested",
                        path="dispositions",
                        query=Q(
                            "nested",
                            path="dispositions.citations",
                            query=Q(
                                "bool",
                                must=[
                                    Q(
                                        "match",
                                        dispositions__citations__title=exact_match.group("title"),
                                    ),
                                    Q(
                                        "match",
                                        dispositions__citations__text=exact_match.group("text"),
                                    ),
                                    Q(
                                        "match",
                                        dispositions__citations__type="regulation",
                                    ),
                                ],
                            ),
                        )
                    )
                )

    if statutory_citation:
        for citation in statutory_citation:
            exact_match = re.match(
                r"(?P<title>\d+)\s+U\.?S\.?C\.?\s+§*\s*(?P<text>\d+).*\.?", citation
            )
            if exact_match:
                citation_queries.append(
                    Q(
                        "nested",
                        path="dispositions",
                        query=Q(
                            "nested",
                            path="dispositions.citations",
                            query=Q(
                                "bool",
                                must=[
                                    Q(
                                        "match",
                                        dispositions__citations__title=exact_match.group("title"),
                                    ),
                                    Q(
                                        "match",
                                        dispositions__citations__text=exact_match.group("text"),
                                    ),
                                    Q(
                                        "match",
                                        dispositions__citations__type="statute",
                                    ),
                                ],
                            ),
                        )
                    )
                )

    if citation_require_all:
        # if citation_require_all= True, return all matched citations("and" relation)
        must_clauses.append(Q("bool", must=citation_queries))
    else:
        # Default citation_require_all=False, return any matched citations("or" relation)
        must_clauses.append(Q("bool", should=citation_queries, minimum_should_match=1))

    query = query.query("bool", must=must_clauses)
    # logger.debug("apply_citation_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return query


def apply_adr_specific_query_params(query, **kwargs):
    must_clauses = []

    if kwargs.get("mur_type"):
        must_clauses.append(Q("match", mur_type=kwargs.get("mur_type")))

    if kwargs.get("case_election_cycles"):
        must_clauses.append(
            Q("term", election_cycles=kwargs.get("case_election_cycles"))
        )

    # gte/lte: greater than or equal to/less than or equal to
    date_range = {}
    if kwargs.get("case_min_open_date"):
        date_range["gte"] = kwargs.get("case_min_open_date")
    if kwargs.get("case_max_open_date"):
        date_range["lte"] = kwargs.get("case_max_open_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", open_date=date_range))

    date_range = {}
    if kwargs.get("case_min_close_date"):
        date_range["gte"] = kwargs.get("case_min_close_date")
    if kwargs.get("case_max_close_date"):
        date_range["lte"] = kwargs.get("case_max_close_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", close_date=date_range))

    query = query.query("bool", must=must_clauses)
    # logger.debug("apply_mur_adr_specific_query_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

    return query


def ao_query_builder(q, type_, from_hit, hits_returned, **kwargs):
    # Only pass query string to document list below
    query = generic_query_builder(None, type_, from_hit, hits_returned, **kwargs)

    # so far only be able to sort by 'ao_no', default sort is descending order.
    # descending order: 'sort=-ao_no'; ascending order; sort=ao_no
    # https://fec-dev-api.app.cloud.gov/v1/legal/search/?type=advisory_opinions&sort=-ao_no
    # https://fec-dev-api.app.cloud.gov/v1/legal/search/?type=advisory_opinions&sort=ao_no

    if kwargs.get("sort"):
        if kwargs.get("sort").upper() == "AO_NO":
            query = query.sort({"ao_no": {"order": "asc"}})
        else:
            query = query.sort({"ao_no": {"order": "desc"}})

    should_query = [
        get_ao_document_query(q, **kwargs),
        Q("simple_query_string", query=q, fields=["summary"]),
    ]
    query = query.query("bool", should=should_query, minimum_should_match=1)
    # logger.debug("ao_query_builder =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return apply_ao_specific_query_params(query, **kwargs)


def get_ao_document_query(q, **kwargs):
    category_query = []
    combined_query = []
    if kwargs.get("ao_doc_category_id") and (len(kwargs.get("ao_doc_category_id")) > 0):
        for ao_doc_category_id in kwargs.get("ao_doc_category_id"):
            if len(ao_doc_category_id) > 0:
                category_query.append(Q("term", documents__ao_doc_category_id=ao_doc_category_id))
        combined_query.append(Q("bool", should=category_query, minimum_should_match=1))

    ao_document_date_range = {}
    if kwargs.get("ao_min_document_date"):
        ao_document_date_range["gte"] = kwargs.get("ao_min_document_date")
    if kwargs.get("ao_max_document_date"):
        ao_document_date_range["lte"] = kwargs.get("ao_max_document_date")
    if ao_document_date_range:
        ao_document_date_range["format"] = ACCEPTED_DATE_FORMATS
        combined_query.append(Q("range", documents__date=ao_document_date_range))

    if q:
        q_query = Q("simple_query_string", query=q, fields=["documents.text"])
        combined_query.append(q_query)

    if check_filter_exists(kwargs, "q_proximity") and kwargs.get("max_gaps") is not None:
        combined_query.append(get_proximity_query(**kwargs))
        proximity_inner_hits = {"_source": {"excludes": ["documents.text"]}, "size": 100}

        if q:
            proximity_inner_hits["highlight"] = {
                "require_field_match": False,
                "fields": {"documents.text": {}, "documents.description": {}, },
                "highlight_query": q_query.to_dict()
                }

        return Q(
            "nested",
            path="documents",
            inner_hits=proximity_inner_hits,
            query=Q("bool", must=combined_query),
        )

    return Q(
        "nested",
        path="documents",
        inner_hits=INNER_HITS,
        query=Q("bool", must=combined_query),
    )


def apply_ao_specific_query_params(query, **kwargs):
    must_clauses = []

    if check_filter_exists(kwargs, "ao_no"):
        must_clauses.append(Q("terms", no=kwargs.get("ao_no")))

    if check_filter_exists(kwargs, "ao_name"):
        must_clauses.append(Q("match", name=" ".join(kwargs.get("ao_name"))))

    if kwargs.get("ao_is_pending") is not None:
        must_clauses.append(Q("term", is_pending=kwargs.get("ao_is_pending")))

    if kwargs.get("ao_status"):
        must_clauses.append(Q("match", status=kwargs.get("ao_status")))

    if kwargs.get("ao_requestor"):
        must_clauses.append(Q("match", requestor_names=kwargs.get("ao_requestor")))

    if kwargs.get("ao_commenter"):
        must_clauses.append(Q("match", commenter_names=kwargs.get("ao_commenter")))

    if kwargs.get("ao_representative"):
        must_clauses.append(Q("match", representative_names=kwargs.get("ao_representative")))

    citation_queries = []
    if kwargs.get("ao_regulatory_citation"):
        for citation in kwargs.get("ao_regulatory_citation"):
            exact_match = re.match(
                r"(?P<title>\d+)\s+C\.?F\.?R\.?\s+§*\s*(?P<part>\d+)\.(?P<section>\d+)",
                citation,
            )
            if exact_match:
                citation_queries.append(
                    Q(
                        "nested",
                        path="regulatory_citations",
                        query=Q(
                            "bool",
                            must=[
                                Q(
                                    "term",
                                    regulatory_citations__title=int(
                                        exact_match.group("title")
                                    ),
                                ),
                                Q(
                                    "term",
                                    regulatory_citations__part=int(
                                        exact_match.group("part")
                                    ),
                                ),
                                Q(
                                    "term",
                                    regulatory_citations__section=int(
                                        exact_match.group("section")
                                    ),
                                ),
                            ],
                        ),
                    )
                )

    if kwargs.get("ao_statutory_citation"):
        for citation in kwargs.get("ao_statutory_citation"):
            exact_match = re.match(
                r"(?P<title>\d+)\s+U\.?S\.?C\.?\s+§*\s*(?P<section>\d+).*\.?", citation
            )
            if exact_match:
                citation_queries.append(
                    Q(
                        "nested",
                        path="statutory_citations",
                        query=Q(
                            "bool",
                            must=[
                                Q(
                                    "term",
                                    statutory_citations__title=int(
                                        exact_match.group("title")
                                    ),
                                ),
                                Q(
                                    "term",
                                    statutory_citations__section=int(
                                        exact_match.group("section")
                                    ),
                                ),
                            ],
                        ),
                    )
                )

    if kwargs.get("ao_citation_require_all"):
        must_clauses.append(Q("bool", must=citation_queries))
    else:
        must_clauses.append(Q("bool", should=citation_queries, minimum_should_match=1))

    # Get 'ao_requestor_type' from kwargs
    ao_requestor_type = kwargs.get("ao_requestor_type", [])
    ao_requestor_type_valid_values = ['1', '2', '3', '4', '5', '6', '7', '8', '9',
                                      '10', '11', '12', '13', '14', '15', '16']

    # Validate 'ao_requestor_type filter'
    valid_requestor_types = filters.validate_multiselect_filter(
        ao_requestor_type, ao_requestor_type_valid_values)

    # Always include valid values in the query construction
    if valid_requestor_types:
        must_clauses.append(
            Q(
                "terms",
                requestor_types=[
                    REQUESTOR_TYPES[r] for r in valid_requestor_types
                ],
            )
        )

    date_range = {}
    if kwargs.get("ao_min_issue_date"):
        date_range["gte"] = kwargs.get("ao_min_issue_date")
    if kwargs.get("ao_max_issue_date"):
        date_range["lte"] = kwargs.get("ao_max_issue_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", issue_date=date_range))

    date_range = {}
    if kwargs.get("ao_min_request_date"):
        date_range["gte"] = kwargs.get("ao_min_request_date")
    if kwargs.get("ao_max_request_date"):
        date_range["lte"] = kwargs.get("ao_max_request_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", request_date=date_range))

    query = query.query("bool", must=must_clauses)
    # logger.debug("apply_ao_specific_query_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

    return query


def execute_query(query):
    es_results = query.execute()
    # logger.debug("UniversalSearch() execute_query() es_results =" + json.dumps(
    #     es_results.to_dict(), indent=3, cls=DateTimeEncoder))

    formatted_hits = []
    for hit in es_results:
        formatted_hit = hit.to_dict()
        formatted_hit["highlights"] = []
        formatted_hit["document_highlights"] = {}
        formatted_hit["source"] = []
        formatted_hits.append(formatted_hit)

        # 1)When doc_type=[statutes], The 'highlight' section is in hit.meta
        # hit.meta={'index': 'docs', 'id': '100_29', 'score': None, 'highlight'...}
        if "highlight" in hit.meta:
            for key in hit.meta.highlight:
                formatted_hit["highlights"].extend(hit.meta.highlight[key])

        # 2)When doc_type= [advisory_opinions, murs, adrs, admin_fines],
        # The 'inner_hits' section is in hit.meta and 'highlight' & 'nested' are in inner_hit.meta
        # hit.meta={'index': 'docs', 'id': 'mur_7212', 'score': None, 'sort': [...}
        if "inner_hits" in hit.meta:
            for inner_hit in hit.meta.inner_hits["documents"].hits:
                if "highlight" in inner_hit.meta and "nested" in inner_hit.meta:
                    # set "document_highlights" in return hit
                    offset = inner_hit.meta["nested"]["offset"]
                    highlights = inner_hit.meta.highlight.to_dict().values()
                    formatted_hit["document_highlights"][offset] = [
                        hl for hl_list in highlights for hl in hl_list
                    ]

                    # put "highlights" in return hit
                    for key in inner_hit.meta.highlight:
                        formatted_hit["highlights"].extend(inner_hit.meta.highlight[key])

                if len(inner_hit.to_dict()) > 0:
                    source = inner_hit.to_dict()
                    formatted_hit["source"].append(source)

    # logger.debug("formatted_hits =" + json.dumps(formatted_hits, indent=3, cls=DateTimeEncoder))

# Since ES7 the `total` becomes an object : "total": {"value": 1,"relation": "eq"}
# We can set rest_total_hits_as_int=true, default is false.
# but elasticsearch-dsl==7.3.0 has not supported this setting yet.
    count_dict = es_results.hits.total
    return formatted_hits, count_dict["value"]


def check_filter_exists(kwargs, filter):
    if kwargs.get(filter):
        for val in kwargs.get(filter):
            if len(val) > 0:
                return True
        return False
    else:
        return False


# endpoint path: /legal/citation/<citation_type>/<citation>
class GetLegalCitation(Resource):

    @use_kwargs(args.citation)
    def get(self, citation_type=None, citation=None, **kwargs):
        citation = "*%s*" % citation

        must_clauses = [
                    Q("term", type="citations"),
                    Q("match", citation_type=citation_type),
                ]

        if kwargs.get("doc_type"):
            doc_type_clause = Q("match", doc_type=kwargs.get("doc_type"))
            must_clauses.append(doc_type_clause)

        query = (
            Search()
            .using(es_client)
            .query(
                "bool",
                must=must_clauses,
                should=[
                    Q("wildcard", citation_text=citation),
                    Q("wildcard", formerly=citation),
                ],
                minimum_should_match=1,
            )
            .extra(size=10)
            .index(SEARCH_ALIAS)
        )

        # logger.debug("Citation final query =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

        es_results = query.execute()
        results = {"citations": [hit.to_dict() for hit in es_results]}
        return results
