from opensearch_dsl import Search, Q
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
from webservices.legal.utils_opensearch import (
    create_opensearch_client,
    DateTimeEncoder,
    check_filter_exists,
)
from webservices.utils import use_kwargs, Resource
from opensearchpy import RequestError
from webservices.exceptions import ApiError
from webservices.legal.rulemaking_docs.responses import (
    RULEMAKING_SEARCH_RESPONSE
)
import logging
import json


logger = logging.getLogger(__name__)

# To debug, uncomment the line below:
# logger.setLevel(logging.DEBUG)

opensearch_client = create_opensearch_client()

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
            raise ApiError("Opensearch failed to execute query", 400)
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
        .using(opensearch_client)
        .query(Q("bool", must=must_query))
        .highlight_options(require_field_match=False)
        # Add text/ocrtext fields to exclude list to prevent showing in the results
        .source(excludes=["no_tier_documents.text", "documents.level_2_labels.level_2_docs.text",
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
        must_exclude_list = []
        must_exclude_list.append(
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

        must_exclude_list.append(
                Q(
                    "nested",
                    path="documents.level_2_labels.level_2_docs",
                    query=Q(
                        "simple_query_string",
                        query=kwargs.get("q_exclude"),
                        fields=["documents.level_2_labels.level_2_docs.text"]
                    )
                )
            )
        # Return rulemakings without the q_exclude value in their documents
        query = query.query("bool", must_not=must_exclude_list, minimum_should_match=1)

    # Sort regulations with deterministic fallback ordering
    sort_field = kwargs.get("sort")

    if sort_field:
        # Determine sort order and clean field name
        sort_order = "desc" if sort_field.startswith("-") else "asc"
        sort_field_clean = sort_field.lstrip("-")
        sort_field = sort_field_clean.lower()

        # Special case: when sorting "is_open_for_comment", secondary = desc
        if sort_field == "is_open_for_comment":
            secondary_order = "desc"
        else:
            secondary_order = sort_order

        # Apply primary sort field + fallback
        query = query.sort(
            {sort_field: {"order": sort_order}},
            {"rm_year": {"order": secondary_order}},
            {"rm_serial": {"order": secondary_order}},
        )
    else:
        # Default sort order: desc by rm_year → rm_serial
        query = query.sort(
            {"rm_year": {"order": "desc"}},
            {"rm_serial": {"order": "desc"}},
        )

    should_query = [
        get_document_query_params(q, **kwargs),
    ]
    query = query.query("bool", should=should_query, minimum_should_match=1)

    # logger.debug("build_search_query =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return get_all_query_params(query, **kwargs)


def get_document_query_params(q, **kwargs):
    must_clauses = []
    doc_category_ids = kwargs.get("doc_category_id", [])
    doc_category_ids = [int(i) for i in doc_category_ids if i]

    if doc_category_ids:
        combined_queries = []

        doc_category_inner_hits = {
            "_source": False,
            "size": 100,
            }

        doc_category_id_lvl2_inner_hits = doc_category_inner_hits.copy()

        doc_category_inner_hits["name"] = "documents_by_category"
        doc_category_id_lvl2_inner_hits["name"] = "documents_by_category_lvl2"

        # Search in documents.doc_category_id
        combined_queries.append(
            Q("nested",
              path="documents",
              query=Q("terms", **{"documents.doc_category_id": doc_category_ids}),
              inner_hits=doc_category_inner_hits
              )
        )

        # Search in documents.level_2_labels.level_2_docs.doc_category_id
        combined_queries.append(
            Q("nested",
              path="documents.level_2_labels.level_2_docs",
              query=Q("terms", **{"documents.level_2_labels.level_2_docs.doc_category_id": doc_category_ids}),
              inner_hits=doc_category_id_lvl2_inner_hits,
              )
        )
        doc_id_should_clauses = Q("bool", should=combined_queries, minimum_should_match=1)
        must_clauses.append(doc_id_should_clauses)

    # Add full-text query to documents
    if q:
        # Search in documents.text
        combined_queries = []
        combined_queries.append(
            Q("nested",
                path="documents",
                query=Q("simple_query_string", query=q, fields=["documents.text"]),
                inner_hits=INNER_HITS)
        )

        inner_hits_lvl_2 = {
            "_source": False,
            "highlight": {
                "require_field_match": False,
                "fields": {"documents.level_2_labels.level_2_docs.text": {}},
            },
            "size": 100,
        }
        # Search in documents.level_2_labels.level_2_docs.text
        combined_queries.append(
            Q("nested",
                path="documents.level_2_labels.level_2_docs",
                query=Q("simple_query_string", query=q, fields=["documents.level_2_labels.level_2_docs.text"]),
                inner_hits=inner_hits_lvl_2)
        )

        # Search in description
        combined_queries.append(Q("simple_query_string", query=q, fields=["description"]))

        q_should_clauses = Q("bool", should=combined_queries, minimum_should_match=1)
        must_clauses.append(q_should_clauses)

    # Handle proximity query
    if check_filter_exists(kwargs, "q_proximity") and kwargs.get("max_gaps") is not None:
        proximity_query = get_proximity_query("documents__text", **kwargs)
        combined_queries = []

        # Highlight config for documents.text
        proximity_inner_hits_documents = {
            "size": 100,
            "name": "documents_proximity",
            "highlight": {
                "require_field_match": False,
                "fields": {
                    "documents.text": {},
                    "documents.description": {}
                },
                "highlight_query": Q("simple_query_string", query=q, fields=["documents.text"]).to_dict()
            }
        }

        combined_queries.append(
            Q("nested",
                path="documents",
                query=proximity_query,
                inner_hits=proximity_inner_hits_documents)
        )

        # Highlight config for level_2_docs.text
        proximity_inner_hits_level2 = {
            "size": 100,
            "name": "documents_proximity_lvl2",
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
        proximity_lvl2_query = get_proximity_query("documents.level_2_labels.level_2_docs.text", **kwargs)

        combined_queries.append(
            Q("nested",
                path="documents.level_2_labels.level_2_docs",
                query=proximity_lvl2_query,
                inner_hits=proximity_inner_hits_level2)
        )

        proximity_should_clauses = Q("bool", should=combined_queries, minimum_should_match=1)
        must_clauses.append(proximity_should_clauses)

    return Q("bool", must=must_clauses)


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


def get_proximity_query(location, **kwargs):
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
            intervals_inner_query = Q('intervals', **{location: {
                'match':  {'query': q_proximity[0], 'max_gaps': max_gaps, "filter": filters, "ordered": True}
                }})
        else:
            intervals_inner_query = Q('intervals', **{location: {
                'match':  {'query': q_proximity[0], 'max_gaps': max_gaps, "ordered": True}
                }})
    else:
        for q in q_proximity:
            dict_item = {"match": {"query": q, "max_gaps": 0, "ordered": True}}
            intervals_list.append(dict_item)

        if contains_filter:
            intervals_inner_query = Q('intervals', **{location: {
                    'all_of':  {'max_gaps': max_gaps,
                                "ordered": ordered,
                                "intervals": intervals_list,
                                "filter": filters}
                    }})
        else:
            intervals_inner_query = Q('intervals', **{location: {
                    'all_of':  {'max_gaps': max_gaps, "ordered": ordered, "intervals": intervals_list}
                    }})
    # logger.debug("get_proximity_query =" + json.dumps(intervals_inner_query, indent=3, cls=DateTimeEncoder))
    return intervals_inner_query


# This function returns highlights at document nested level by default. Refactor this function to return
# highlights at documents, documents.level_2_labels, documents.level_2_labels.level_2_docs nested levels
def execute_search_query(query):
    es_results = query.execute()

    # logger.warning("Rulemaking execute_search_query() es_results =" + json.dumps(
    #    es_results.to_dict(), indent=3, cls=DateTimeEncoder))

    formatted_hits = []
    for hit in es_results:
        formatted_hit = hit.to_dict()
        formatted_hit["document_highlights"] = {}
        formatted_hits.append(formatted_hit)

        # The 'inner_hits' section is in hit.meta and 'highlight' & 'nested' are in inner_hit.meta
        if "inner_hits" in hit.meta:
            if "documents" in hit.meta.inner_hits:
                for inner_hit in hit.meta.inner_hits["documents"].hits:
                    if "highlight" in inner_hit.meta and "nested" in inner_hit.meta:
                        doc_offset = inner_hit.meta.nested.offset

                        highlights = [
                            hl
                            for hl_list in inner_hit.meta.highlight.to_dict().values()
                            for hl in hl_list
                        ]

                        # Attach highlight directly in the document object
                        formatted_hit["document_highlights"].setdefault(
                            doc_offset, {}
                        ).setdefault(-1, []).extend(highlights)

                        doc = formatted_hit["documents"][doc_offset]
                        doc.setdefault("highlights", []).extend(highlights)

            key = "documents.level_2_labels.level_2_docs"
            if key in hit.meta.inner_hits:
                for inner_hit in hit.meta.inner_hits[key].hits:
                    if "highlight" in inner_hit.meta and "nested" in inner_hit.meta:

                        nested = inner_hit.meta.nested
                        offsets = []
                        while nested:
                            offsets.append(nested["offset"])
                            nested = getattr(nested, "_nested", None)

                        doc_offset, label_offset, doc2_offset = offsets

                        highlights = [
                            hl
                            for hl_list in inner_hit.meta.highlight.to_dict().values()
                            for hl in hl_list
                        ]

                        formatted_hit["document_highlights"].setdefault(
                            doc_offset, {}
                        ).setdefault(
                            label_offset, {}
                        ).setdefault(
                            doc2_offset, []
                        ).extend(highlights)

                        doc = formatted_hit["documents"][doc_offset]
                        label = doc["level_2_labels"][label_offset]
                        doc2 = label["level_2_docs"][doc2_offset]
                        doc2.setdefault("highlights", []).extend(highlights)

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
