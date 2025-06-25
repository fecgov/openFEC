from elasticsearch_dsl import Search, Q
# from flask import abort
from flask_apispec import doc
from webservices import docs
from webservices import args
from webservices import filters
from webservices.constants import (
    RM_SEARCH_ALIAS,
    ENTITY_ROLE_TYPES,
    ENTITY_ROLE_TYPE_VALID_VALUES,
    RULEMAKING_TYPE
)
from webservices.utils import (
    create_es_client,
    Resource,
    DateTimeEncoder,
)
from webservices.utils import use_kwargs
from elasticsearch import RequestError
from webservices.exceptions import ApiError
from webservices.rulemaking_docs.responses import (
    RULEMAKING_SEARCH_RESPONSE_1
)
import logging
import json


logger = logging.getLogger(__name__)

# To debug, uncomment the line below:
logger.setLevel(logging.DEBUG)

es_client = create_es_client()

INNER_HITS = {
    "_source": False,
    "highlight": {
        "require_field_match": False,
        "fields": {"documents.text": {}, "documents.description": {}},
    },
    "size": 100,
}

ACCEPTED_DATE_FORMATS = "strict_date_optional_time_nanos||MM/dd/yyyy||M/d/yyyy||MM/d/yyyy||M/dd/yyyy"

# endpoint path: /rulemaking/search/
# under tag: legal
# test url: http://127.0.0.1:5000/v1/rulemaking/search/?rm_no=2025-05


@doc(
    tags=["legal"],
    description=docs.RM_SEARCH,
    responses=RULEMAKING_SEARCH_RESPONSE_1,
)
class RulemakingSearch(Resource):
    @use_kwargs(args.rulemaking_search)
    def get(self, q="", from_hit=0, hits_returned=20, **kwargs):
        query_builder = rm_query_builder
        type_ = RULEMAKING_TYPE
        print("@@@@@@@@@@@@@@@@@@@@@@@ TYPE:::::", type_)
        hits_returned = min([200, hits_returned])
        results = {}
        total_count = 0
        try:
            query = query_builder(q, type_, from_hit, hits_returned, **kwargs)
            logger.debug(
                "Rulemaking search final query = " +
                json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder)
            )
            formatted_hits, rm_count = execute_query(query)
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
        results["total_%s" % type_] = rm_count
        total_count += rm_count
        results["total"] = total_count

        logger.debug("total count={0}".format(str(total_count)))
        return results


def generic_query_builder(q, type_, from_hit, hits_returned, **kwargs):
    must_query = [Q("term", type=type_)]
    # proximity_query = False

    if q:
        must_query.append(Q("simple_query_string", query=q))

    # if check_filter_exists(kwargs, "q_proximity") and kwargs.get("max_gaps") is not None:
    #     proximity_query = True

    query = (
        Search()
        .using(es_client)
        .query(Q("bool", must=must_query))
        .highlight_options(require_field_match=False)
        .source(exclude=["sort1", "sort2"])
        .extra(size=hits_returned, from_=from_hit)
        .index(RM_SEARCH_ALIAS)
        .sort("sort1", "sort2")
    )

    # if not proximity_query:
    #     if type_ == "advisory_opinions":
    #         query = query.highlight("summary", "documents.text", "documents.description")
    #     elif type_ == "statutes":
    #         query = query.highlight("name", "no")
    #     else:
    #         query = query.highlight("documents.text", "documents.description")

    # if kwargs.get("q_exclude"):
    #     must_not = []
    #     must_not.append(
    #         Q(
    #             "nested",
    #             path="documents",
    #             query=Q(
    #                 "simple_query_string",
    #                 query=kwargs.get("q_exclude"),
    #                 fields=["documents.text"]
    #             )
    #         )
    #     )
    # logging.warning("generic_query_builder =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return query


def get_proximity_query(**kwargs):
    q_proximity = kwargs.get("q_proximity")
    max_gaps = kwargs.get("max_gaps")
    ordered = kwargs.get("proximity_preserve_order", False)
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
                    'all_of':  {'max_gaps': max_gaps,
                                "ordered": ordered,
                                "intervals": intervals_list,
                                "filter": filters}
                    })
        else:
            intervals_inner_query = Q('intervals', documents__text={
                    'all_of':  {'max_gaps': max_gaps, "ordered": ordered, "intervals": intervals_list}
                    })
    return intervals_inner_query


def rm_query_builder(q, type_, from_hit, hits_returned, **kwargs):
    # Only pass query string to document list below
    query = generic_query_builder(None, type_, from_hit, hits_returned, **kwargs)

    # Sort regulations by 'rm_no'. Default sort order is desc.
    # example desc order: 'sort=-rm_no'; asc order; sort=rm_no
    # https://fec-dev-api.app.cloud.gov/v1/rulemaking/search/?type=rulemaking&sort=-rm_no
    # https://fec-dev-api.app.cloud.gov/v1/rulemaking/search/?type=rulemaking&sort=rm_no
    sort_field = kwargs.get("sort")
    if sort_field:
        if sort_field.startswith("-"):
            sort_order = "desc"
            sort_field = sort_field[1:]
        else:
            sort_order = "asc"

        if sort_field.upper() == "RM_NO":
            query = query.sort({"rm_year": {"order": sort_order}}, {"rm_serial": {"order": sort_order}})

    # should_query = [
    #     get_rm_document_query(q, **kwargs),
    #     Q("simple_query_string", query=q, fields=["description"]),
    # ]
    # query = query.query("bool", should=should_query, minimum_should_match=1)

    logger.debug("rm_query_builder =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return apply_rm_specific_query_params(query, **kwargs)


def get_rm_document_query(q, **kwargs):
    category_query = []
    combined_query = []
    if kwargs.get("rm_doc_category_id") and (len(kwargs.get("rm_doc_category_id")) > 0):
        for rm_doc_category_id in kwargs.get("rm_doc_category_id"):
            if len(rm_doc_category_id) > 0:
                category_query.append(Q("term", documents__doc_category_id=rm_doc_category_id))
        combined_query.append(Q("bool", should=category_query, minimum_should_match=1))

    if q:
        q_query = Q("simple_query_string", query=q, fields=["documents.level_2_labels.level_2_docs.text"])
        combined_query.append(q_query)

    # if check_filter_exists(kwargs, "q_proximity") and kwargs.get("max_gaps") is not None:
    #     combined_query.append(get_proximity_query(**kwargs))
    #     proximity_inner_hits = {"_source": {"excludes": ["documents.text"]}, "size": 100}

    #     if q:
    #         proximity_inner_hits["highlight"] = {
    #             "require_field_match": False,
    #             "fields": {"documents.text": {}, "documents.description": {}, },
    #             "highlight_query": q_query.to_dict()
    #             }

    #     return Q(
    #         "nested",
    #         path="documents",
    #         inner_hits=proximity_inner_hits,
    #         query=Q("bool", must=combined_query),
    #     )

    return Q(
        "nested",
        path="documents",
        inner_hits=INNER_HITS,
        query=Q("bool", must=combined_query),
    )


def apply_rm_specific_query_params(query, **kwargs):
    must_clauses = []

    if check_filter_exists(kwargs, "rm_no"):
        must_clauses.append(Q("terms", rm_no=kwargs.get("rm_no")))

    if check_filter_exists(kwargs, "rm_name"):
        must_clauses.append(Q("match", rm_name=" ".join(kwargs.get("rm_name"))))

    if kwargs.get("rm_year") is not None:
        must_clauses.append(Q("term", rm_year=kwargs.get("rm_year")))

    if kwargs.get("is_key_document") is not None:
        must_clauses.append(
            Q("nested", path="documents",
                query=Q("term", documents__is_key_document=kwargs.get("is_key_document"))))

    if kwargs.get("is_open_for_comment") is not None:
        must_clauses.append(Q("term", is_open_for_comment=kwargs.get("is_open_for_comment")))

    if kwargs.get("entity_name"):
        must_clauses.append(Q("nested", path="rm_entities",
                            query=Q("match", rm_entities__name=kwargs.get("entity_name"))))

    # Get 'entity_role_type' from kwargs
    entity_role_type = kwargs.get("entity_role_type", [])

    # Validate 'entity_role_type filter'
    valid_entity_role_types = filters.validate_multiselect_filter(
        entity_role_type, ENTITY_ROLE_TYPE_VALID_VALUES)

    # Always include valid values in the query construction
    if valid_entity_role_types:
        must_clauses.append(Q("nested", path="rm_entities",
                            query=Q("terms",
                                    rm_entities__role=[ENTITY_ROLE_TYPES[r] for r in valid_entity_role_types])))

    date_range = {}
    if kwargs.get("min_federal_registry_publish_date"):
        date_range["gte"] = kwargs.get("min_federal_registry_publish_date")
    if kwargs.get("max_federal_registry_publish_date"):
        date_range["lte"] = kwargs.get("max_federal_registry_publish_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", fr_publication_dates=date_range))

    if kwargs.get("min_hearing_date"):
        date_range["gte"] = kwargs.get("min_hearing_date")
    if kwargs.get("max_hearing_date"):
        date_range["lte"] = kwargs.get("max_hearing_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", hearing_dates=date_range))

    if kwargs.get("min_vote_date"):
        date_range["gte"] = kwargs.get("min_vote_date")
    if kwargs.get("max_vote_date"):
        date_range["lte"] = kwargs.get("max_vote_date")
    if date_range:
        date_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", vote_dates=date_range))

    if kwargs.get("filename"):
        must_clauses = []
        must_clauses.append(Q("nested", path="documents",
                            query=Q("match", documents__filename=kwargs.get("filename"))))
        query = query.query("bool", must=must_clauses)

    query = query.query("bool", must=must_clauses)
    logger.debug("apply_rm_specific_query_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

    return query


def execute_query(query):
    es_results = query.execute()
    # logger.debug("Rulemaking search() execute_query() es_results =" + json.dumps(
    #     es_results.to_dict(), indent=3, cls=DateTimeEncoder))

    formatted_hits = []
    for hit in es_results:
        formatted_hit = hit.to_dict()
        # formatted_hit["highlights"] = []
        # formatted_hit["document_highlights"] = {}
        formatted_hit["source"] = []
        formatted_hits.append(formatted_hit)

        # 1)When doc_type=[statutes], The 'highlight' section is in hit.meta
        # hit.meta={'index': 'docs', 'id': '100_29', 'score': None, 'highlight'...}
        # if "highlight" in hit.meta:
        #     for key in hit.meta.highlight:
        #         formatted_hit["highlights"].extend(hit.meta.highlight[key])

        # 2)When doc_type= [advisory_opinions, murs, adrs, admin_fines],
        # The 'inner_hits' section is in hit.meta and 'highlight' & 'nested' are in inner_hit.meta
        # hit.meta={'index': 'docs', 'id': 'mur_7212', 'score': None, 'sort': [...}
        # if "inner_hits" in hit.meta:
        #     for inner_hit in hit.meta.inner_hits["documents"].hits:
        #         if "highlight" in inner_hit.meta and "nested" in inner_hit.meta:
        #             # set "document_highlights" in return hit
        #             offset = inner_hit.meta["nested"]["offset"]
        #             highlights = inner_hit.meta.highlight.to_dict().values()
        #             formatted_hit["document_highlights"][offset] = [
        #                 hl for hl_list in highlights for hl in hl_list
        #             ]

        #             # put "highlights" in return hit
        #             for key in inner_hit.meta.highlight:
        #                 formatted_hit["highlights"].extend(inner_hit.meta.highlight[key])

        #         if len(inner_hit.to_dict()) > 0:
        #             source = inner_hit.to_dict()
        #             formatted_hit["source"].append(source)

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
