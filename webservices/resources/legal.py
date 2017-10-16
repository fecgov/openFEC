import re

from elasticsearch_dsl import Search, Q
from webargs import fields
from flask import abort

from webservices import args
from webservices import utils
from webservices.utils import use_kwargs
from webservices.legal_docs import DOCS_SEARCH
from elasticsearch import RequestError
from webservices.exceptions import ApiError
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
            .index(DOCS_SEARCH)

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
            .index(DOCS_SEARCH) \
            .execute()

        results = {"docs": [hit.to_dict() for hit in es_results]}

        if len(results['docs']) > 0:
            return results
        else:
            return abort(404)

class UniversalSearch(utils.Resource):
    @use_kwargs(args.query)
    def get(self, q='', from_hit=0, hits_returned=20, **kwargs):
        query_builders = {
            "statutes": generic_query_builder,
            "regulations": generic_query_builder,
            "advisory_opinions": ao_query_builder,
            "murs": mur_query_builder
        }

        if kwargs.get('type', 'all') == 'all':
            doc_types = ['statutes', 'regulations', 'advisory_opinions', 'murs']
        else:
            doc_types = [kwargs.get('type')]

        hits_returned = min([200, hits_returned])

        results = {}
        total_count = 0

        for type_ in doc_types:
            query = query_builders.get(type_)(q, type_, from_hit, hits_returned, **kwargs)
            try:
                formatted_hits, count = execute_query(query)
            except RequestError as e:
                logger.info(e.args)
                raise ApiError("Could not parse query", 400)
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
        .index(DOCS_SEARCH) \
        .sort("sort1", "sort2")

    return query

def mur_query_builder(q, type_, from_hit, hits_returned, **kwargs):
    must_query = [Q('term', _type=type_)]

    if q:
        must_query.append(Q('query_string', query=q))

    query = Search().using(es) \
        .query(Q('bool', must=must_query)) \
        .highlight('text', 'name', 'no', 'summary', 'documents.text', 'documents.description') \
        .highlight_options(require_field_match=False) \
        .source(exclude=['text', 'documents.text', 'sort1', 'sort2']) \
        .extra(size=hits_returned, from_=from_hit) \
        .index(DOCS_SEARCH) \
        .sort("sort1", "sort2")

    return apply_mur_specific_query_params(query, **kwargs)

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
        .index(DOCS_SEARCH) \
        .sort("sort1", "sort2")

    return apply_ao_specific_query_params(query, **kwargs)

def apply_mur_specific_query_params(query, **kwargs):
    must_clauses = []
    if kwargs.get('mur_no'):
        must_clauses.append(Q('terms', no=kwargs.get('mur_no')))
    if kwargs.get('mur_respondents'):
        must_clauses.append(Q('match', respondents=kwargs.get('mur_respondents')))
    if kwargs.get('mur_dispositions'):
        must_clauses.append(Q('term', disposition__data__disposition=kwargs.get('mur_dispositions')))
    if kwargs.get('mur_election_cycles'):
        must_clauses.append(Q('term', election_cycles=kwargs.get('mur_election_cycles')))

    if kwargs.get('mur_document_category'):
        must_clauses = [Q('terms', documents__category=kwargs.get('mur_document_category'))]

    #if the query contains min or max open date, add as a range clause ("Q(range)")
    #to the set of must_clauses

    #gte = greater than or equal to and lte = less than or equal to (see elasticsearch docs)
    date_range = {}
    if kwargs.get('mur_min_open_date'):
        date_range['gte'] = kwargs.get('mur_min_open_date')
    if kwargs.get('mur_max_open_date'):
        date_range['lte'] = kwargs.get('mur_max_open_date')
    if date_range:
        must_clauses.append(Q("range", open_date=date_range))

    date_range = {}
    if kwargs.get('mur_min_close_date'):
        date_range['gte'] = kwargs.get('mur_min_close_date')
    if kwargs.get('mur_max_close_date'):
        date_range['lte'] = kwargs.get('mur_max_close_date')
    if date_range:
        must_clauses.append(Q("range", close_date=date_range))

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

    if kwargs.get('ao_requestor'):
        must_clauses.append(Q('match', requestor_names=kwargs.get('ao_requestor')))

    citation_queries = []
    if kwargs.get('ao_regulatory_citation'):
        for citation in kwargs.get('ao_regulatory_citation'):
            exact_match = re.match(r"(?P<title>\d+)\s+CFR\s+§*(?P<part>\d+)\.(?P<section>\d+)", citation)
            if(exact_match):
                citation_queries.append(Q("nested", path="regulatory_citations", query=Q("bool",
                    must=[Q("term", regulatory_citations__title=int(exact_match.group('title'))),
                        Q("term", regulatory_citations__part=int(exact_match.group('part'))),
                        Q("term", regulatory_citations__section=int(exact_match.group('section')))])))

    if kwargs.get('ao_statutory_citation'):
        for citation in kwargs.get('ao_statutory_citation'):
            exact_match = re.match(r"(?P<title>\d+)\s+U.S.C.\s+§*(?P<section>\d+).*\.?", citation)
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
