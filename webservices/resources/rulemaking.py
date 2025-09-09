from elasticsearch_dsl import Search, Q
from flask_apispec import doc
from webservices import docs
from webservices import args
from webservices import filters
from webservices.legal.constants import (
    RM_SEARCH_ALIAS,
    ENTITY_ROLE_TYPES,
    ENTITY_ROLE_TYPE_VALID_VALUES,
    RULEMAKING_TYPE
)
from webservices.legal.utils_es import (
    create_es_client,
    DateTimeEncoder,
    check_filter_exists,
)
from webservices.utils import use_kwargs, Resource
from elasticsearch import RequestError
from webservices.exceptions import ApiError
from webservices.legal.rulemaking_docs.responses import (
    RULEMAKING_SEARCH_RESPONSE
)
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
        "fields": {"documents.text": {}},
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
    responses=RULEMAKING_SEARCH_RESPONSE,
)
class RulemakingSearch(Resource):
    @use_kwargs(args.rulemaking_search)
    #  Set 'hit_returned' to 30 by default to implement pagination for rulemaking on datatables.
    def get(self, q="", from_hit=0, hits_returned=30, **kwargs):
        type_ = RULEMAKING_TYPE
        hits_returned = min([200, hits_returned])
        results = {}
        try:
            query = build_search_query(q, type_, from_hit, hits_returned, **kwargs)
            logger.debug(
                "Rulemaking search final query = " +
                json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder)
            )
            formatted_hits, rm_count = execute_search_query(query)
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

        logger.debug("total count={0}".format(str(rm_count)))
        return results


def build_search_query(q, type_, from_hit, hits_returned, **kwargs):
    # Only pass query string to document list below
    proximity_query = False
    must_query = [Q("term", type=type_)]
    query = (
        Search()
        .using(es_client)
        .query(Q("bool", must=must_query))
        .highlight_options(require_field_match=False)
        .source(exclude=["sort1", "sort2"])
        # Add text/ocrtext fields to exclude list to prevent showing in the results
        .source(exclude=["no_tier_documents.text", "documents.level_2_labels.level_2_docs.text",
                         "documents.text", "sort1", "sort2"])
        .extra(size=hits_returned, from_=from_hit)
        .index(RM_SEARCH_ALIAS)
        .sort("sort1", "sort2")
    )

    if check_filter_exists(kwargs, "q_proximity") and kwargs.get("max_gaps") is not None:
        proximity_query = True

    if not proximity_query:
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

    # Sort regulations by 'rm_no'. Default sort order is desc.
    sort_field = kwargs.get("sort")
    if sort_field:
        if sort_field.startswith("-"):
            sort_order = "desc"
            sort_field = sort_field[1:]
        else:
            sort_order = "asc"

        if sort_field.upper() == "RM_NO":
            query = query.sort({"rm_year": {"order": sort_order}}, {"rm_serial": {"order": sort_order}})

    should_query = [
        get_document_query_params(q, **kwargs),
        Q("simple_query_string", query=q, fields=["description"]),
    ]
    query = query.query("bool", should=should_query, minimum_should_match=1)

    # logger.debug("build_search_query =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return get_all_query_params(query, **kwargs)


def get_document_query_params(q, **kwargs):
    should_clauses = []
    doc_category_ids = kwargs.get("doc_category_id", [])
    doc_category_ids = [int(i) for i in doc_category_ids if i]

    if doc_category_ids:
        # Search in documents.doc_category_id
        should_clauses.append(
            Q("nested",
              path="documents",
              query=Q("terms", **{"documents.doc_category_id": doc_category_ids}),
              inner_hits=INNER_HITS)
        )
        # Search in documents.level_2_labels.level_2_docs.doc_category_id
        should_clauses.append(
            Q("nested",
              path="documents.level_2_labels.level_2_docs",
              query=Q("terms", **{"documents.level_2_labels.level_2_docs.doc_category_id": doc_category_ids}),
              inner_hits=INNER_HITS)
        )

    # Add full-text query to documents
    if q:
        # Search in documents.text
        should_clauses.append(
            Q("nested",
                path="documents",
                query=Q("simple_query_string", query=q, fields=["documents.text"]),
                inner_hits=INNER_HITS)
        )

        # Search in documents.level_2_labels.level_2_docs.text
        should_clauses.append(
            Q("nested",
                path="documents.level_2_labels.level_2_docs",
                query=Q("simple_query_string", query=q, fields=["documents.level_2_labels.level_2_docs.text"]),
                inner_hits=INNER_HITS)
        )

    # Handle proximity query
    if check_filter_exists(kwargs, "q_proximity") and kwargs.get("max_gaps") is not None:
        proximity_query = get_proximity_query(**kwargs)

        # Highlight config for documents.text
        proximity_inner_hits_documents = {
            "size": 100,
            "highlight": {
                "require_field_match": False,
                "fields": {
                    "documents.text": {},
                    "documents.description": {}
                },
                "highlight_query": Q("simple_query_string", query=q, fields=["documents.text"]).to_dict()
            }
        }

        should_clauses.append(
            Q("nested",
                path="documents",
                query=proximity_query,
                inner_hits=proximity_inner_hits_documents)
        )

        # Highlight config for level_2_docs.text
        proximity_inner_hits_level2 = {
            "size": 100,
            "highlight": {
                "require_field_match": False,
                "fields": {
                    "documents.level_2_labels.level_2_docs.text": {},
                },
                "highlight_query": Q(
                    "simple_query_string",
                    query=q,
                    fields=["documents.level_2_labels.level_2_docs.text"]
                ).to_dict()
            }
        }

        should_clauses.append(
            Q("nested",
                path="documents.level_2_labels.level_2_docs",
                query=proximity_query,
                inner_hits=proximity_inner_hits_level2)
        )

    return Q("bool", should=should_clauses, minimum_should_match=1)


def get_all_query_params(query, **kwargs):
    must_clauses = []

    if check_filter_exists(kwargs, "rm_no"):
        must_clauses.append(Q("terms", rm_no=kwargs.get("rm_no")))

    if check_filter_exists(kwargs, "rm_name"):
        must_clauses.append(Q({
            "simple_query_string": {
                "query": " ".join(kwargs.get("rm_name")),
                "fields": ["rm_name"]
            }
        }))

    if kwargs.get("rm_year") is not None:
        must_clauses.append(Q("term", rm_year=kwargs.get("rm_year")))

    if kwargs.get("is_key_document") is not None:
        must_clauses.append(
            Q("nested", path="documents",
                query=Q("term", documents__is_key_document=kwargs.get("is_key_document"))))

    if kwargs.get("is_open_for_comment") is not None:
        must_clauses.append(Q("term", is_open_for_comment=kwargs.get("is_open_for_comment")))

    # entity_name and entity_role filter
    nested_entity_query = build_entity_nested_query(kwargs)
    if nested_entity_query:
        must_clauses.append(nested_entity_query)

    fr_publish_dates_range = {}
    if kwargs.get("min_federal_registry_publish_date"):
        fr_publish_dates_range["gte"] = kwargs.get("min_federal_registry_publish_date")
    if kwargs.get("max_federal_registry_publish_date"):
        fr_publish_dates_range["lte"] = kwargs.get("max_federal_registry_publish_date")
    if fr_publish_dates_range:
        fr_publish_dates_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", fr_publication_dates=fr_publish_dates_range))

    hearing_dates_range = {}
    if kwargs.get("min_hearing_date"):
        hearing_dates_range["gte"] = kwargs.get("min_hearing_date")
    if kwargs.get("max_hearing_date"):
        hearing_dates_range["lte"] = kwargs.get("max_hearing_date")
    if hearing_dates_range:
        hearing_dates_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", hearing_dates=hearing_dates_range))

    vote_dates_range = {}
    if kwargs.get("min_vote_date"):
        vote_dates_range["gte"] = kwargs.get("min_vote_date")
    if kwargs.get("max_vote_date"):
        vote_dates_range["lte"] = kwargs.get("max_vote_date")
    if vote_dates_range:
        vote_dates_range["format"] = ACCEPTED_DATE_FORMATS
        must_clauses.append(Q("range", vote_dates=vote_dates_range))

    # Use the .keyword subfield for wildcard matching exact full filename strings.
    # Use wildcard query with *{filename}* so partial matches are possible.
    filename = kwargs.get("filename")
    if filename:
        # Query for documents.filename.keyword
        doc_filename_query = Q(
            "nested",
            path="documents",
            query=Q("wildcard", **{"documents.filename.keyword": f"*{filename}*"}),
            inner_hits={}
        )

        # Query for documents.level_2_labels.level_2_docs.filename.keyword
        level_2_docs_filename_query = Q(
            "nested",
            path="documents.level_2_labels.level_2_docs",
            query=Q("wildcard", **{"documents.level_2_labels.level_2_docs.filename.keyword": f"*{filename}*"}),
            inner_hits={}
        )

        must_clauses.append(
            Q(
                "bool",
                should=[doc_filename_query, level_2_docs_filename_query],
                minimum_should_match=1
            )
        )

    query = query.query("bool", must=must_clauses)
    # logger.debug("get_all_query_params =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))

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
    # logger.debug("get_proximity_query =" + json.dumps(intervals_inner_query, indent=3, cls=DateTimeEncoder))
    return intervals_inner_query


# This function returns highlights at document nested level by default. Refactor this function to return
# highlights at documents, documents.level_2_labels, documents.level_2_labels.level_2_docs nested levels
def execute_search_query(query):
    es_results = query.execute()
    # logger.debug("Rulemaking execute_search_query() es_results =" + json.dumps(
    #     es_results.to_dict(), indent=3, cls=DateTimeEncoder))

    formatted_hits = []
    for hit in es_results:
        formatted_hit = hit.to_dict()
        formatted_hit["document_highlights"] = {}
        formatted_hits.append(formatted_hit)

        # The 'inner_hits' section is in hit.meta and 'highlight' & 'nested' are in inner_hit.meta
        if "inner_hits" in hit.meta:
            for inner_hit in hit.meta.inner_hits["documents"].hits:
                if "highlight" in inner_hit.meta and "nested" in inner_hit.meta:
                    # set "document_highlights" in return hit
                    offset = inner_hit.meta["nested"]["offset"]
                    highlights = inner_hit.meta.highlight.to_dict().values()
                    formatted_hit["document_highlights"][offset] = [
                        hl for hl_list in highlights for hl in hl_list
                    ]

    # logger.debug("formatted_hits =" + json.dumps(formatted_hits, indent=3, cls=DateTimeEncoder))

    count_dict = es_results.hits.total
    return formatted_hits, count_dict["value"]


def build_entity_nested_query(kwargs):
    nested_must = []

    # Get and validate 'entity_role_type' filter
    entity_role_type = kwargs.get("entity_role_type", [])
    valid_entity_role_types = filters.validate_multiselect_filter(
        entity_role_type, ENTITY_ROLE_TYPE_VALID_VALUES
    )

    # Add simple_query_string for entity_name
    entity_name = kwargs.get("entity_name")
    if entity_name:
        nested_must.append(Q({
            "simple_query_string": {
                "query": entity_name,
                "fields": ["rm_entities.name"]
            }
        }))

    # Add terms query for entity_role_type
    if valid_entity_role_types:
        nested_must.append(Q("terms", rm_entities__role=[
            ENTITY_ROLE_TYPES[r] for r in valid_entity_role_types
        ]))

    # If any nested filters are present, return a nested query
    if nested_must:
        return Q("nested", path="rm_entities", query=Q("bool", must=nested_must))

    return None
