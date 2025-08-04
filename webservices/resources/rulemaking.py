from elasticsearch_dsl import Search, Q
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
    RULEMAKING_SEARCH_RESPONSE
)
import logging
import json


logger = logging.getLogger(__name__)

# To debug, uncomment the line below:
logger.setLevel(logging.DEBUG)

es_client = create_es_client()

# INNER_HITS = {
#     "_source": False,
#     "highlight": {
#         "require_field_match": False,
#         "fields": {"documents.text": {}},
#     },
#     "size": 100,
# }

INNER_HITS = {
    "_source": False,
    "highlight": {
        "require_field_match": False,
        "fields": {"documents.text": {}},
    },
    "size": 100,
}

INNER_HITS_LEVEL_2_LABELS = {
    "_source": False,
    "highlight": {
        "require_field_match": False,
        "fields": {"documents.level_2_labels.level_2_label": {}},
    },
    "size": 100,
}

INNER_HITS_LEVEL_2_DOCS = {
    "_source": False,
    "highlight": {
        "require_field_match": False,
        "fields": {"documents.level_2_labels.level_2_docs.text": {}},
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
    def get(self, q="", from_hit=0, hits_returned=20, **kwargs):
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
    # proximity_query = False
    must_query = [Q("term", type=type_)]

    # if q:
    #     must_query.append(Q("simple_query_string", query=q))

    query = (
        Search()
        .using(es_client)
        .query(Q("bool", must=must_query))
        .highlight_options(require_field_match=False)
        .source(exclude=["sort1", "sort2"])
        # text/ocrtext will not show in the resultset/output when text/ocrtext fields are added to the exclud list
        .source(exclude=["no_tier_documents.text", "documents.level_2_labels.level_2_docs.text",
                         "documents.text", "sort1", "sort2"])
        .extra(size=hits_returned, from_=from_hit)
        .index(RM_SEARCH_ALIAS)
        .sort("sort1", "sort2")
    )

    # if filters.check_filter_exists(kwargs, "q_proximity") and kwargs.get("max_gaps") is not None:
    #     proximity_query = True

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
        # get_document_query_params(q, **kwargs),
        # get_level_1_document_query(q, **kwargs),
        get_level_2_document_query(q, **kwargs),
        # Q("simple_query_string", query=q, fields=["description"]),
    ]
    query = query.query("bool", should=should_query, minimum_should_match=1)

    # logger.debug("build_search_query =" + json.dumps(query.to_dict(), indent=3, cls=DateTimeEncoder))
    return get_all_query_params(query, **kwargs)


def get_level_1_document_query(q, **kwargs):
    return Q(
        "nested",
        path="documents",
        inner_hits={
            "name": "inner_hits_documents",
            "highlight": {
                "fields": {
                    "documents.text": {
                        "number_of_fragments": 0,  # Return full match
                        "fragment_size": 100,
                        "type": "unified"  # Required for offsets
                    }
                }
            }
        },
        query=Q("simple_query_string", query=q, fields=["documents.text"]),
    )


def get_level_2_document_query(q, **kwargs):
    return Q(
        "nested",
        path="documents",
        inner_hits={
            "name": "inner_hits_documents",
            "highlight": {
                "fields": {
                    "documents.text": {
                        "number_of_fragments": 0,  # Return full match
                        "fragment_size": 100,
                        "type": "unified"  # Required for offsets
                    }
                }
            }
        },
        query=Q(
            "nested",
            path="documents.level_2_labels",
            inner_hits={
                "name": "inner_hits_level_2_labels",
                "highlight": {
                    "fields": {
                        "documents.level_2_labels.level_2_label": {
                            "number_of_fragments": 0,  # Return full match
                            "fragment_size": 100,
                            "type": "unified"  # Required for offsets
                        }
                    }
                }
            },
            query=Q(
                "nested",
                path="documents.level_2_labels.level_2_docs",
                inner_hits={
                    "name": "inner_hits_level_2_docs",
                    "highlight": {
                        "fields": {
                            "documents.level_2_labels.level_2_docs.text": {
                                "number_of_fragments": 0,  # Return full match
                                "fragment_size": 100,
                                "type": "unified"  # Required for offsets
                            }
                        }
                    }
                },
                query=Q("simple_query_string", query=q, fields=["documents.level_2_labels.level_2_docs.text"]),
            )
        )
    )


def get_document_query_params(q, **kwargs):
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

    if filters.check_filter_exists(kwargs, "q_proximity") and kwargs.get("max_gaps") is not None:
        combined_query.append(get_proximity_query(**kwargs))
        proximity_inner_hits = {"_source": {"excludes": ["documents.text"]}, "size": 100}
        if q:
            proximity_inner_hits["highlight"] = {
                "require_field_match": False,
                "fields": {"documents.text": {}, "documents.description": {}},
                "highlight_query": q_query.to_dict()
                }

        return Q(
            "nested",
            path="documents",
            inner_hits=proximity_inner_hits,
            query=Q("bool", must=combined_query),
        )

    # combined_query.append(Q("bool", should=document_query, minimum_should_match=1))
    return combined_query

    # return Q(
    #     "nested",
    #     path="documents.level_2_labels.level_2_docs",
    #     # path="documents",
    #     inner_hits=INNER_HITS,
    #     query=Q("bool", must=combined_query),
    # )
    # .query(
    #     "nested",
    #     path="comments",
    #     query=Q("match", comments__author="Alice"),
    #     inner_hits={
    #         "name": "comments_hits", # Name for the inner hits
    #         "nested": {
    #             "path": "comments.replies",
    #             "query": Q("match", comments__replies__user="Bob"),
    #             "inner_hits": {
    #                 "name": "replies_hits" # Name for the nested inner hits
    #             }
    #         }
    #     }
    # )


def get_all_query_params(query, **kwargs):
    must_clauses = []

    if filters.check_filter_exists(kwargs, "rm_no"):
        must_clauses.append(Q("terms", rm_no=kwargs.get("rm_no")))

    if filters.check_filter_exists(kwargs, "rm_name"):
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
# highlights at documents, document.level_2_labels, document.level_2_labels.level_2_docs nested levels
def execute_search_query(query):
    es_results = query.execute()
    # logger.debug("Rulemaking execute_search_query() es_results =" + json.dumps(
    #     es_results.to_dict(), indent=3, cls=DateTimeEncoder))
    # for hit in response:
    #     activities_hits = hit.meta.inner_hits.activities_hits
    #     for act_hit in activities_hits:
    #         details_hits = act_hit.meta.inner_hits.details_hits
    #         for detail_hit in details_hits:
    #             highlights = detail_hit.meta.highlight.get("user.activities.details.text", [])
    #             for fragment in highlights:
    #                 print("Highlight:", fragment)
    formatted_hits = []
    for hit in es_results:
        formatted_hit = hit.to_dict()
        formatted_hit["document_highlights"] = {}
        formatted_hit["source"] = []
        formatted_hits.append(formatted_hit)

    for hit in es_results:
        inner_hits_documents = hit.meta.inner_hits.inner_hits_documents
        # print ("$$$$$$$$$$$$$$$$ top 1")
        # print (inner_hits_documents.to_dict())
        # if "highlight" in inner_hits_documents.meta and "nested" in inner_hits_documents.meta:
        #     inner_hits_offset = inner_hits_documents.meta["nested"]["offset"]
        #     print("Jun inner_hits_offset//////")
        #     print("inner_hits_offset:", inner_hits_offset)
        for top_hit in inner_hits_documents:
            # print ("$$$$$$$$$$$$$$$$ top 1")
            inner_hits_level_2_labels = top_hit.meta.inner_hits.inner_hits_level_2_labels
            for label2_hit in inner_hits_level_2_labels:
                # label2_highlights = label2_hit.meta.highlight["documents.level_2_labels.level_2_label"]
                # if "label2_highlights" in label2_hit.meta and "nested" in label2_hit.meta:
                #     print ("$$$$$$$$$$$$$$$$ top 3")
                inner_hits_level_2_docs = label2_hit.meta.inner_hits.inner_hits_level_2_docs
                # print ("$$$$$$$$$$$$$$$$ top 4")
                for label2_doc_hit in inner_hits_level_2_docs:
                    # print ("$$$$$$$$$$$$$$$$ top 5")
                    # highlights = label2_doc_hit.meta.highlight["documents.level_2_labels.level_2_docs.text"]
                    # print ("$$$$$$$$$$$$$$$$ highlights")
                    if "highlight" in label2_doc_hit.meta and "nested" in label2_doc_hit.meta:
                        highlights = label2_doc_hit.meta.highlight["documents.level_2_labels.level_2_docs.text"]
                        offset_label2_doc = label2_doc_hit.meta["nested"]["offset"]
                        print("Jun li########")
                        print("offset_label2_doc:", offset_label2_doc)

                        formatted_hit["document_highlights"][offset_label2_doc] = [
                            hl for hl_list in highlights for hl in hl_list
                        ]
                        #   for fragment in highlights:
                        #   print("$$$$$$")
                        #   print("Highlight:", fragment)
    # formatted_hits = []
    # for hit in es_results:
    #     formatted_hit = hit.to_dict()
    #     formatted_hit["document_highlights"] = {}
    #     formatted_hit["source"] = []
    #     formatted_hits.append(formatted_hit)
    # logger.debug("Rulemaking hit meta =" + json.dumps(
    # hit.meta.to_dict(), indent=3, cls=DateTimeEncoder))

        # The 'inner_hits' section is in hit.meta and 'highlight' & 'nested' are in inner_hit.meta
        # if "inner_hits" in hit.meta:
        #     for inner_hit in hit.meta.inner_hits["documents"].hits:
        #         if "highlight" in inner_hit.meta and "nested" in inner_hit.meta:
        #             # set "document_highlights" in return hit
        #             offset = inner_hit.meta["nested"]["offset"]
        #             highlights = inner_hit.meta.highlight.to_dict().values()
        #             formatted_hit["document_highlights"][offset] = [
        #                 hl for hl_list in highlights for hl in hl_list
        #             ]

        #         if len(inner_hit.to_dict()) > 0:
        #             source = inner_hit.to_dict()
        #             formatted_hit["source"].append(source)

# INNER_HITS_LEVEL_2_LABELS
        # # if "inner_hits" in hit.meta:
        # #     for inner_hit in hit.meta.inner_hits["documents.level_2_labels.level_2_docs"].hits:
        # #         if "highlight" in inner_hit.meta and "nested" in inner_hit.meta:
        # #             # set "document_highlights" in return hit
        # #             offset = inner_hit.meta["nested"]["offset"]
        # #             highlights = inner_hit.meta.highlight.to_dict().values()
        # #             formatted_hit["document_highlights"][offset] = [
        # #                 hl for hl_list in highlights for hl in hl_list
        # #             ]

        #         if len(inner_hit.to_dict()) > 0:
        #             source = inner_hit.to_dict()
        #             formatted_hit["source"].append(source)

    # logger.debug("formatted_hits =" + json.dumps(formatted_hits, indent=3, cls=DateTimeEncoder))
    # Since ES7 the `total` becomes an object : "total": {"value": 1,"relation": "eq"}
    # We can set rest_total_hits_as_int=true, default is false.
    # but elasticsearch-dsl==7.3.0 has not supported this setting yet.
    count_dict = es_results.hits.total
    return formatted_hits, count_dict["value"]
