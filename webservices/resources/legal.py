import re

from elasticsearch_dsl import Search, Q
from webargs import fields
from flask import abort
from flask_apispec import doc
from webservices import docs
from webservices import args
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

# for debug, uncomment this line:
# logger.setLevel(logging.DEBUG)

es_client = create_es_client()

INNER_HITS = {
    "_source": False,
    "highlight": {
        "require_field_match": False,
        "fields": {"documents.text": {}, "documents.description": {}},
    },
}

ALL_DOCUMENT_TYPES = [
    "statutes",
    "regulations",
    "advisory_opinions",
    "murs",
    "adrs",
    "admin_fines",
]


# endpoint path: /legal/docs/<doc_type>/<no>
# test url: http://127.0.0.1:5000/v1/legal/docs/murs/7212
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
        logger.debug("GetLegalDocument() results =" + json.dumps(results, indent=3, cls=DateTimeEncoder))

        if len(results["docs"]) > 0:
            return results
        else:
            return abort(404)


# endpoint path: /legal/search/
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
            "regulations": generic_query_builder,
            "advisory_opinions": ao_query_builder,
            "murs": case_query_builder,
            "adrs": case_query_builder,
            "admin_fines": case_query_builder,
        }

        if kwargs.get("type", "all") == "all":
            doc_types = ALL_DOCUMENT_TYPES
        else:
            doc_types = [kwargs.get("type")]

            # if doc_types is not in one of ALL_DOCUMENT_TYPES
            # then reset type = all (= ALL_DOCUMENT_TYPES)
            if doc_types[0] not in ALL_DOCUMENT_TYPES:
                doc_types = ALL_DOCUMENT_TYPES

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

    if q:
        must_query.append(Q("query_string", query=q))

    query = (
        Search()
        .using(es_client)
        .query(Q("bool", must=must_query))
        .highlight(
            "text", "name", "no", "summary", "documents.text", "documents.description"
        )
        .highlight_options(require_field_match=False)
        .source(exclude=["text", "documents.text", "sort1", "sort2"])
        .extra(size=hits_returned, from_=from_hit)
        .index(SEARCH_ALIAS)
        .sort("sort1", "sort2")
    )

    logger.debug("generic_query_builder =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return query


def case_query_builder(q, type_, from_hit, hits_returned, **kwargs):
    query = generic_query_builder(None, type_, from_hit, hits_returned, **kwargs)

    # sorting works in all three cases: ('murs','admin_fines','adrs').
    # so far only be able to sort by 'case_no', default sort is descending order.
    # descending order: 'sort=-case_no'; ascending order; sort=case_no
    # https://fec-dev-api.app.cloud.gov/v1/legal/search/?type=murs&sort=-case_no
    # https://fec-dev-api.app.cloud.gov/v1/legal/search/?type=murs&sort=case_no
    if kwargs.get("sort"):
        if kwargs.get("sort").upper() == "CASE_NO":
            query = query.sort({"case_serial": {"order": "asc"}})
        else:
            query = query.sort({"case_serial": {"order": "desc"}})

    should_query = [
        get_case_document_query(q, **kwargs),
        Q("query_string", query=q, fields=["no", "name"]),
    ]
    query = query.query("bool", should=should_query, minimum_should_match=1)

    must_clauses = []
    if kwargs.get("case_no"):
        must_clauses.append(Q("terms", no=kwargs.get("case_no")))

    if kwargs.get("case_document_category"):
        must_clauses = [
            Q("terms", documents__category=kwargs.get("case_document_category"))
        ]
    query = query.query("bool", must=must_clauses)

    logger.debug("case_query_builder =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

    if type_ == "admin_fines":
        return apply_af_specific_query_params(query, **kwargs)
    elif type_ == "murs":
        return apply_mur_specific_query_params(query, **kwargs)
    else:
        return apply_adr_specific_query_params(query, **kwargs)

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
    if kwargs.get("case_doc_category_id"):

        for doc_category_id in kwargs.get("case_doc_category_id"):
            category_queries.append(
                Q(
                    "match",
                    documents__doc_order_id=doc_category_id,
                ),
            )

    combined_query.append(Q("bool", should=category_queries, minimum_should_match=1))

    if q:
        combined_query.append(Q("query_string", query=q, fields=["documents.text"]))

    return Q(
        "nested",
        path="documents",
        inner_hits=INNER_HITS,
        query=Q("bool", must=combined_query),
    )


def apply_af_specific_query_params(query, **kwargs):
    must_clauses = []
    if kwargs.get("af_name"):
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
        must_clauses.append(Q("range", reason_to_believe_action_date=date_range))

    date_range = {}
    if kwargs.get("af_min_fd_date"):
        date_range["gte"] = kwargs.get("af_min_fd_date")
    if kwargs.get("af_max_fd_date"):
        date_range["lte"] = kwargs.get("af_max_fd_date")
    if date_range:
        must_clauses.append(Q("range", final_determination_date=date_range))

    if kwargs.get("af_rtb_fine_amount"):
        must_clauses.append(
            Q("term", reason_to_believe_fine_amount=kwargs.get("af_rtb_fine_amount"))
        )
    if kwargs.get("af_fd_fine_amount"):
        must_clauses.append(
            Q("term", final_determination_amount=kwargs.get("af_fd_fine_amount"))
        )

    query = query.query("bool", must=must_clauses)
    logger.debug("apply_af_specific_query_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

    return query


def apply_mur_specific_query_params(query, **kwargs):
    must_clauses = []

    if kwargs.get("mur_type"):
        must_clauses.append(Q("match", mur_type=kwargs.get("mur_type")))
    if kwargs.get("case_respondents"):
        must_clauses.append(Q("match", respondents=kwargs.get("case_respondents")))
    if kwargs.get("case_dispositions"):
        must_clauses.append(
            Q("term", disposition__data__disposition=kwargs.get("case_dispositions"))
        )

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
        must_clauses.append(Q("range", open_date=date_range))

    date_range = {}
    if kwargs.get("case_min_close_date"):
        date_range["gte"] = kwargs.get("case_min_close_date")
    if kwargs.get("case_max_close_date"):
        date_range["lte"] = kwargs.get("case_max_close_date")
    if date_range:
        must_clauses.append(Q("range", close_date=date_range))

    query = query.query("bool", must=must_clauses)
    logger.debug("apply_mur_adr_specific_query_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

    if kwargs.get("case_regulatory_citation") or kwargs.get("case_statutory_citation"):
        return case_apply_citation_params(
            query,
            kwargs.get("case_regulatory_citation"),
            kwargs.get("case_statutory_citation"),
            kwargs.get("case_citation_require_all"), **kwargs)
    else:
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
    logger.debug("apply_citation_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return query


def apply_adr_specific_query_params(query, **kwargs):
    must_clauses = []

    if kwargs.get("mur_type"):
        must_clauses.append(Q("match", mur_type=kwargs.get("mur_type")))
    if kwargs.get("case_respondents"):
        must_clauses.append(Q("match", respondents=kwargs.get("case_respondents")))
    if kwargs.get("case_dispositions"):
        must_clauses.append(
            Q("term", disposition__data__disposition=kwargs.get("case_dispositions"))
        )

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
        must_clauses.append(Q("range", open_date=date_range))

    date_range = {}
    if kwargs.get("case_min_close_date"):
        date_range["gte"] = kwargs.get("case_min_close_date")
    if kwargs.get("case_max_close_date"):
        date_range["lte"] = kwargs.get("case_max_close_date")
    if date_range:
        must_clauses.append(Q("range", close_date=date_range))

    query = query.query("bool", must=must_clauses)
    logger.debug("apply_mur_adr_specific_query_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

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
        Q("query_string", query=q, fields=["no", "name", "summary"]),
    ]
    query = query.query("bool", should=should_query, minimum_should_match=1)
    logger.debug("ao_query_builder =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return apply_ao_specific_query_params(query, **kwargs)


def get_ao_document_query(q, **kwargs):
    categories = {
        "F": "Final Opinion",
        "V": "Votes",
        "D": "Draft Documents",
        "R": "AO Request, Supplemental Material, and Extensions of Time",
        "W": "Withdrawal of Request",
        "C": "Comments and Ex parte Communications",
        "S": "Commissioner Statements",
    }

    if kwargs.get("ao_category"):
        ao_category = [categories[c] for c in kwargs.get("ao_category")]
        combined_query = [Q("terms", documents__category=ao_category)]
    else:
        combined_query = []

    if q:
        combined_query.append(Q("query_string", query=q, fields=["documents.text"]))

    return Q(
        "nested",
        path="documents",
        inner_hits=INNER_HITS,
        query=Q("bool", must=combined_query),
    )


def apply_ao_specific_query_params(query, **kwargs):
    must_clauses = []
    if kwargs.get("ao_no"):
        must_clauses.append(Q("terms", no=kwargs.get("ao_no")))

    if kwargs.get("ao_name"):
        must_clauses.append(Q("match", name=" ".join(kwargs.get("ao_name"))))

    if kwargs.get("ao_is_pending") is not None:
        must_clauses.append(Q("term", is_pending=kwargs.get("ao_is_pending")))

    if kwargs.get("ao_status"):
        must_clauses.append(Q("match", status=kwargs.get("ao_status")))

    if kwargs.get("ao_requestor"):
        must_clauses.append(Q("match", requestor_names=kwargs.get("ao_requestor")))

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

    if kwargs.get("ao_requestor_type"):
        requestor_types = {
            1: "Federal candidate/candidate committee/officeholder",
            2: "Publicly funded candidates/committees",
            3: "Party committee, national",
            4: "Party committee, state or local",
            5: "Nonconnected political committee",
            6: "Separate segregated fund",
            7: "Labor Organization",
            8: "Trade Association",
            9: "Membership Organization, Cooperative, Corporation W/O Capital Stock",
            10: "Corporation (including LLCs electing corporate status)",
            11: "Partnership (including LLCs electing partnership status)",
            12: "Governmental entity",
            13: "Research/Public Interest/Educational Institution",
            14: "Law Firm",
            15: "Individual",
            16: "Other",
        }
        must_clauses.append(
            Q(
                "terms",
                requestor_types=[
                    requestor_types[r] for r in kwargs.get("ao_requestor_type")
                ],
            )
        )

    date_range = {}
    if kwargs.get("ao_min_issue_date"):
        date_range["gte"] = kwargs.get("ao_min_issue_date")
    if kwargs.get("ao_max_issue_date"):
        date_range["lte"] = kwargs.get("ao_max_issue_date")
    if date_range:
        must_clauses.append(Q("range", issue_date=date_range))

    date_range = {}
    if kwargs.get("ao_min_request_date"):
        date_range["gte"] = kwargs.get("ao_min_request_date")
    if kwargs.get("ao_max_request_date"):
        date_range["lte"] = kwargs.get("ao_max_request_date")
    if date_range:
        must_clauses.append(Q("range", request_date=date_range))

    if kwargs.get("ao_entity_name"):
        must_clauses.append(
            Q(
                "bool",
                should=[
                    Q("match", commenter_names=" ".join(kwargs.get("ao_entity_name"))),
                    Q(
                        "match",
                        representative_names=" ".join(kwargs.get("ao_entity_name")),
                    ),
                ],
                minimum_should_match=1,
            )
        )

    query = query.query("bool", must=must_clauses)
    logger.debug("apply_ao_specific_query_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

    return query


def execute_query(query):
    es_results = query.execute()
    logger.debug("UniversalSearch() execute_query() es_results =" + json.dumps(
        es_results.to_dict(), indent=3, cls=DateTimeEncoder))

    formatted_hits = []
    for hit in es_results:
        formatted_hit = hit.to_dict()
        formatted_hit["highlights"] = []
        formatted_hit["document_highlights"] = {}
        formatted_hits.append(formatted_hit)

        # 1)When doc_type=[regulations, statutes], The 'highlight' section is in hit.meta
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
    logger.debug("formatted_hits =" + json.dumps(formatted_hits, indent=3, cls=DateTimeEncoder))

# Since ES7 the `total` becomes an object : "total": {"value": 1,"relation": "eq"}
# We can set rest_total_hits_as_int=true, default is false.
# but elasticsearch-dsl==7.3.0 has not supported this setting yet.
    count_dict = es_results.hits.total
    return formatted_hits, count_dict["value"]


# endpoint path: /legal/citation/<citation_type>/<citation>
class GetLegalCitation(Resource):
    @property
    def args(self):
        return {
            "citation_type": fields.Str(
                required=True, description="Citation type (regulation or statute)"
            ),
            "citation": fields.Str(
                required=True, description="Citation to search for."
            ),
        }

    def get(self, citation_type, citation, **kwargs):
        citation = "*%s*" % citation
        query = (
            Search()
            .using(es_client)
            .query(
                "bool",
                must=[
                    Q("term", type="citations"),
                    Q("match", citation_type=citation_type),
                ],
                should=[
                    Q("wildcard", citation_text=citation),
                    Q("wildcard", formerly=citation),
                ],
                minimum_should_match=1,
            )
            .extra(size=10)
            .index(SEARCH_ALIAS)
        )

        es_results = query.execute()

        results = {"citations": [hit.to_dict() for hit in es_results]}
        return results
