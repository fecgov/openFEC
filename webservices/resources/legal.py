import re

from elasticsearch_dsl import Search, Q
from webargs import fields
from flask import abort
from flask_apispec import doc

from webservices import docs
from webservices import args
from webservices import utils
from webservices.utils import use_kwargs
from elasticsearch import RequestError
from webservices.exceptions import ApiError
import webservices.legal_docs.responses as responses
import logging


es = utils.get_elasticsearch_connection()
logger = logging.getLogger(__name__)

INNER_HITS = {
    "_source": False,
    "highlight": {
        "require_field_match": False,
        "fields": {
            "documents.text": {},
            "documents.description": {}
        }
    }
}

ALL_DOCUMENT_TYPES = [
    'statutes',
    'regulations',
    'advisory_opinions',
    'murs',
    'adrs',
    'admin_fines',
]


class GetLegalCitation(utils.Resource):
    @property
    def args(self):
        return {"citation_type": fields.Str(required=True, description="Citation type (regulation or statute)"),
        "citation": fields.Str(required=True, description='Citation to search for.')}

    def get(self, citation_type, citation, **kwargs):
        citation = '*%s*' % citation
        query = Search().using(es) \
            .query('bool', must=[Q("term", _type='citations'),
            Q('match', citation_type=citation_type)],
            should=[Q('wildcard', citation_text=citation),
            Q('wildcard', formerly=citation)],
            minimum_should_match=1) \
            .extra(size=10) \
            .index('docs_search')

        es_results = query.execute()

        results = {"citations": [hit.to_dict() for hit in es_results]}
        return results

class GetLegalDocument(utils.Resource):
    @property
    def args(self):
        return {"no": fields.Str(required=True, description='Document number to fetch.'),
                "doc_type": fields.Str(required=True, description='Document type to fetch.')}

    def get(self, doc_type, no, **kwargs):
        es_results = Search().using(es) \
            .query('bool', must=[Q('term', no=no), Q('term', _type=doc_type)]) \
            .source(exclude='documents.text') \
            .extra(size=200) \
            .index('docs_search') \
            .execute()

        results = {"docs": [hit.to_dict() for hit in es_results]}

        if len(results['docs']) > 0:
            return results
        else:
            return abort(404)

@doc(
    description=docs.LEGAL_SEARCH,
    tags=['legal'],
    responses=responses.LEGAL_SEARCH_RESPONSE
)
class UniversalSearch(utils.Resource):
    @use_kwargs(args.query)
    def get(self, q='', from_hit=0, hits_returned=20, **kwargs):
        query_builders = {
            "statutes": generic_query_builder,
            "regulations": generic_query_builder,
            "advisory_opinions": ao_query_builder,
            "murs": case_query_builder,
            "adrs": case_query_builder,
            "admin_fines": case_query_builder,
        }

        if kwargs.get('type', 'all') == 'all':
            doc_types = ALL_DOCUMENT_TYPES
        else:
            doc_types = [kwargs.get('type')]

            # if doc_types is not in one of ALL_DOCUMENT_TYPES
            # then reset type = all (= ALL_DOCUMENT_TYPES)
            if doc_types[0] not in ALL_DOCUMENT_TYPES:
                doc_types = ALL_DOCUMENT_TYPES

        hits_returned = min([200, hits_returned])

        results = {}
        total_count = 0

        for type_ in doc_types:
            try:
                query = query_builders.get(type_)(q, type_, from_hit, hits_returned, **kwargs)
                formatted_hits, count = execute_query(query)
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
            results['total_%s' % type_] = count
            total_count += count

        results['total_all'] = total_count
        return results

def generic_query_builder(q, type_, from_hit, hits_returned, **kwargs):
    must_query = [Q('term', _type=type_), Q('query_string', query=q)]

    query = Search().using(es) \
        .query(Q('bool', must=must_query)) \
        .highlight('text', 'name', 'no', 'summary', 'documents.text', 'documents.description') \
        .highlight_options(require_field_match=False) \
        .source(exclude=['text', 'documents.text', 'sort1', 'sort2']) \
        .extra(size=hits_returned, from_=from_hit) \
        .index('docs_search') \
        .sort("sort1", "sort2")

    return query

def case_query_builder(q, type_, from_hit, hits_returned, **kwargs):
    must_query = [Q('term', _type=type_)]

    if q:
        must_query.append(Q('query_string', query=q))

    query = Search().using(es) \
        .query(Q('bool', must=must_query)) \
        .highlight('text', 'name', 'no', 'summary', 'documents.text', 'documents.description') \
        .highlight_options(require_field_match=False) \
        .source(exclude=['text', 'documents.text', 'sort1', 'sort2']) \
        .extra(size=hits_returned, from_=from_hit) \
        .index('docs_search') \
        .sort("sort1", "sort2")

    must_clauses = []
    if kwargs.get('case_no'):
        must_clauses.append(Q('terms', no=kwargs.get('case_no')))
    if kwargs.get('case_document_category'):
        must_clauses = [Q('terms', documents__category=kwargs.get('case_document_category'))]

    query = query.query('bool', must=must_clauses)

    if type_ == 'admin_fines':
        return apply_af_specific_query_params(query, **kwargs)
    else:
        return apply_mur_adr_specific_query_params(query, **kwargs)


def ao_query_builder(q, type_, from_hit, hits_returned, **kwargs):
    must_query = [Q('term', _type=type_)]
    should_query = [get_ao_document_query(q, **kwargs),
                Q('query_string', query=q, fields=['no', 'name', 'summary'])]

    query = Search().using(es) \
        .query(Q('bool', must=must_query, should=should_query, minimum_should_match=1)) \
        .highlight('text', 'name', 'no', 'summary', 'documents.text', 'documents.description') \
        .highlight_options(require_field_match=False) \
        .source(exclude=['text', 'documents.text', 'sort1', 'sort2']) \
        .extra(size=hits_returned, from_=from_hit) \
        .index('docs_search') \
        .sort("sort1", "sort2")

    return apply_ao_specific_query_params(query, **kwargs)

def apply_mur_adr_specific_query_params(query, **kwargs):
    must_clauses = []

    if kwargs.get('case_respondents'):
        must_clauses.append(Q('match', respondents=kwargs.get('case_respondents')))
    if kwargs.get('case_dispositions'):
        must_clauses.append(Q('term', disposition__data__disposition=kwargs.get('case_dispositions')))

    if kwargs.get('case_election_cycles'):
        must_clauses.append(Q('term', election_cycles=kwargs.get('case_election_cycles')))

    # gte/lte: greater than or equal to/less than or equal to
    date_range = {}
    if kwargs.get('case_min_open_date'):
        date_range['gte'] = kwargs.get('case_min_open_date')
    if kwargs.get('case_max_open_date'):
        date_range['lte'] = kwargs.get('case_max_open_date')
    if date_range:
        must_clauses.append(Q("range", open_date=date_range))

    date_range = {}
    if kwargs.get('case_min_close_date'):
        date_range['gte'] = kwargs.get('case_min_close_date')
    if kwargs.get('case_max_close_date'):
        date_range['lte'] = kwargs.get('case_max_close_date')
    if date_range:
        must_clauses.append(Q("range", close_date=date_range))

    query = query.query('bool', must=must_clauses)

    return query


def apply_af_specific_query_params(query, **kwargs):
    must_clauses = []
    if kwargs.get('af_name'):
        must_clauses.append(Q('match', name=' '.join(kwargs.get('af_name'))))
    if kwargs.get('af_committee_id'):
        must_clauses.append(Q('match', committee_id=kwargs.get('af_committee_id')))
    if kwargs.get('af_report_year'):
        must_clauses.append(Q('match', report_year=kwargs.get('af_report_year')))

    date_range = {}
    if kwargs.get('af_min_rtb_date'):
        date_range['gte'] = kwargs.get('af_min_rtb_date')
    if kwargs.get('af_max_rtb_date'):
        date_range['lte'] = kwargs.get('af_max_rtb_date')
    if date_range:
        must_clauses.append(Q("range", reason_to_believe_action_date=date_range))

    date_range = {}
    if kwargs.get('af_min_fd_date'):
        date_range['gte'] = kwargs.get('af_min_fd_date')
    if kwargs.get('af_max_fd_date'):
        date_range['lte'] = kwargs.get('af_max_fd_date')
    if date_range:
        must_clauses.append(Q("range", final_determination_date=date_range))

    if kwargs.get('af_rtb_fine_amount'):
        must_clauses.append(Q('term', reason_to_believe_fine_amount=kwargs.get('af_rtb_fine_amount')))
    if kwargs.get('af_fd_fine_amount'):
        must_clauses.append(Q('term', final_determination_amount=kwargs.get('af_fd_fine_amount')))

    query = query.query('bool', must=must_clauses)

    return query


def get_ao_document_query(q, **kwargs):
    categories = {'F': 'Final Opinion',
                  'V': 'Votes',
                  'D': 'Draft Documents',
                  'R': 'AO Request, Supplemental Material, and Extensions of Time',
                  'W': 'Withdrawal of Request',
                  'C': 'Comments and Ex parte Communications',
                  'S': 'Commissioner Statements'}

    if kwargs.get('ao_category'):
        ao_category = [categories[c] for c in kwargs.get('ao_category')]
        combined_query = [Q('terms', documents__category=ao_category)]
    else:
        combined_query = []

    if q:
        combined_query.append(Q('query_string', query=q, fields=['documents.text']))

    return Q("nested", path="documents", inner_hits=INNER_HITS, query=Q('bool', must=combined_query))

def apply_ao_specific_query_params(query, **kwargs):
    must_clauses = []
    if kwargs.get('ao_no'):
        must_clauses.append(Q('terms', no=kwargs.get('ao_no')))

    if kwargs.get('ao_name'):
        must_clauses.append(Q('match', name=' '.join(kwargs.get('ao_name'))))

    if kwargs.get('ao_is_pending') is not None:
        must_clauses.append(Q('term', is_pending=kwargs.get('ao_is_pending')))

    if kwargs.get('ao_status'):
        must_clauses.append(Q('match', status=kwargs.get('ao_status')))

    if kwargs.get('ao_requestor'):
        must_clauses.append(Q('match', requestor_names=kwargs.get('ao_requestor')))

    citation_queries = []
    if kwargs.get('ao_regulatory_citation'):
        for citation in kwargs.get('ao_regulatory_citation'):
            exact_match = re.match(r"(?P<title>\d+)\s+C\.?F\.?R\.?\s+§*\s*(?P<part>\d+)\.(?P<section>\d+)", citation)
            if(exact_match):
                citation_queries.append(Q("nested", path="regulatory_citations", query=Q("bool",
                    must=[Q("term", regulatory_citations__title=int(exact_match.group('title'))),
                        Q("term", regulatory_citations__part=int(exact_match.group('part'))),
                        Q("term", regulatory_citations__section=int(exact_match.group('section')))])))

    if kwargs.get('ao_statutory_citation'):
        for citation in kwargs.get('ao_statutory_citation'):
            exact_match = re.match(r"(?P<title>\d+)\s+U\.?S\.?C\.?\s+§*\s*(?P<section>\d+).*\.?", citation)
            if(exact_match):
                citation_queries.append(Q("nested", path="statutory_citations", query=Q("bool",
                    must=[Q("term", statutory_citations__title=int(exact_match.group('title'))),
                    Q("term", statutory_citations__section=int(exact_match.group('section')))])))

    if kwargs.get('ao_citation_require_all'):
        must_clauses.append(Q('bool', must=citation_queries))
    else:
        must_clauses.append(Q('bool', should=citation_queries, minimum_should_match=1))

    if kwargs.get('ao_requestor_type'):
        requestor_types = {1: 'Federal candidate/candidate committee/officeholder',
                      2: 'Publicly funded candidates/committees',
                      3: 'Party committee, national',
                      4: 'Party committee, state or local',
                      5: 'Nonconnected political committee',
                      6: 'Separate segregated fund',
                      7: 'Labor Organization',
                      8: 'Trade Association',
                      9: 'Membership Organization, Cooperative, Corporation W/O Capital Stock',
                     10: 'Corporation (including LLCs electing corporate status)',
                     11: 'Partnership (including LLCs electing partnership status)',
                     12: 'Governmental entity',
                     13: 'Research/Public Interest/Educational Institution',
                     14: 'Law Firm',
                     15: 'Individual',
                     16: 'Other'}
        must_clauses.append(Q("terms", requestor_types=[requestor_types[r] for r in kwargs.get('ao_requestor_type')]))

    date_range = {}
    if kwargs.get('ao_min_issue_date'):
        date_range['gte'] = kwargs.get('ao_min_issue_date')
    if kwargs.get('ao_max_issue_date'):
        date_range['lte'] = kwargs.get('ao_max_issue_date')
    if date_range:
        must_clauses.append(Q("range", issue_date=date_range))

    date_range = {}
    if kwargs.get('ao_min_request_date'):
        date_range['gte'] = kwargs.get('ao_min_request_date')
    if kwargs.get('ao_max_request_date'):
        date_range['lte'] = kwargs.get('ao_max_request_date')
    if date_range:
        must_clauses.append(Q("range", request_date=date_range))

    if kwargs.get('ao_entity_name'):
        must_clauses.append(Q('bool', should=[Q('match', commenter_names=' '.join(kwargs.get('ao_entity_name'))),
          Q('match', representative_names=' '.join(kwargs.get('ao_entity_name')))],
            minimum_should_match=1))

    query = query.query('bool', must=must_clauses)

    return query

def execute_query(query):
    es_results = query.execute()
    formatted_hits = []
    for hit in es_results:
        formatted_hit = hit.to_dict()
        formatted_hit['highlights'] = []
        formatted_hit['document_highlights'] = {}
        formatted_hits.append(formatted_hit)

        if 'highlight' in hit.meta:
            for key in hit.meta.highlight:
                formatted_hit['highlights'].extend(hit.meta.highlight[key])

        if 'inner_hits' in hit.meta:
            for inner_hit in hit.meta.inner_hits['documents'].hits:
                if 'highlight' in inner_hit.meta and 'nested' in inner_hit.meta:
                    offset = inner_hit.meta['nested']['offset']
                    highlights = inner_hit.meta.highlight.to_dict().values()
                    formatted_hit['document_highlights'][offset] = [
                        hl for hl_list in highlights for hl in hl_list]

    return formatted_hits, es_results.hits.total
