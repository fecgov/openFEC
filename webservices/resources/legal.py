import re

from elasticsearch_dsl import Search, Q
from webargs import fields

from webservices import args
from webservices import utils
from webservices.utils import use_kwargs
from webservices.legal_docs import DOCS_SEARCH
es = utils.get_elasticsearch_connection()

class GetLegalDocument(utils.Resource):
    @property
    def args(self):
        return {"no": fields.Str(required=True, description='Document number to fetch.'),
                "doc_type": fields.Str(required=True, description='Document type to fetch.')}

    def get(self, doc_type, no, **kwargs):
        es_results = Search().using(es) \
            .query('bool', must=[Q('term', no=no), Q('term', _type=doc_type)]) \
            .source(exclude='text') \
            .extra(size=200) \
            .index(DOCS_SEARCH) \
            .execute()

        results = {"docs": [hit.to_dict() for hit in es_results]}
        return results


phrase_regex = re.compile('"(?P<phrase>[^"]*)"')
def parse_query_string(query):
    """Parse phrases from a query string for exact matches e.g. "independent agency"."""

    def _parse_query_string(query):
        """Recursively pull out terms and phrases from query. Each pass pulls
        out terms leading up to the phrase as well as the phrase itself. Then
        it processes the remaining string."""

        if not query:
            return ([], [])

        match = phrase_regex.search(query)
        if not match:
            return ([query], [])

        start, end = match.span()
        before_phrase = query[0:start]
        after_phrase = query[end:]

        term = before_phrase.strip()
        phrase = match.group('phrase').strip()
        remaining = after_phrase.strip()

        terms, phrases = _parse_query_string(remaining)

        if phrase:
            phrases.insert(0, phrase)

        if term:
            terms.insert(0, term)

        return (terms, phrases)

    terms, phrases = _parse_query_string(query)
    return dict(terms=terms, phrases=phrases)


class UniversalSearch(utils.Resource):
    @use_kwargs(args.query)
    def get(self, q='', from_hit=0, hits_returned=20, type='all',
            ao_no=None, ao_name=None, ao_min_date=None, ao_max_date=None, **kwargs):
        if type == 'all':
            types = ['statutes', 'regulations', 'advisory_opinions', 'murs']
        else:
            types = [type]

        parsed_query = parse_query_string(q)
        terms = parsed_query.get('terms')
        phrases = parsed_query.get('phrases')
        hits_returned = min([200, hits_returned])

        results = {}
        total_count = 0
        for type in types:
            must_query = [Q('term', _type=type)]
            text_highlight_query = Q()

            if len(terms):
                term_query = Q('match', _all=' '.join(terms))
                must_query.append(term_query)
                text_highlight_query = text_highlight_query & term_query

            if len(phrases):
                phrase_queries = [Q('match_phrase', _all=phrase) for phrase in phrases]
                must_query.extend(phrase_queries)
                text_highlight_query = text_highlight_query & Q('bool', must=phrase_queries)

            query = Search().using(es) \
                .query(Q('bool',
                         must=must_query,
                         should=[Q('match', no=q), Q('match_phrase', _all={"query": q, "slop": 50})])) \
                .highlight('description', 'name', 'no', 'summary', 'text') \
                .source(exclude='text') \
                .extra(size=hits_returned, from_=from_hit) \
                .index(DOCS_SEARCH)

            if type == 'advisory_opinions':
                query = query.query('match', category='Final Opinion')

                if ao_no:
                    query = query.query('terms', no=ao_no)

                if ao_name:
                    query = query.query("match", name=' '.join(ao_name))

                date_range = {}

                if ao_min_date:
                    date_range['gte'] = ao_min_date

                if ao_max_date:
                    date_range['lte'] = ao_max_date

                if date_range:
                    query = query.query("range", date=date_range)

            if type == 'murs':
                if kwargs.get('no'):
                    query = query.query('terms', no=kwargs.get('no'))
                if kwargs.get('election_cycles'):
                    query = query.query('term', election_cycles=kwargs.get('election_cycles'))
            if text_highlight_query:
                query = query.highlight_options(highlight_query=text_highlight_query.to_dict())

            es_results = query.execute()

            formatted_hits = []
            for hit in es_results:
                formatted_hit = hit.to_dict()
                formatted_hit['highlights'] = []
                formatted_hits.append(formatted_hit)

                if 'highlight' in hit.meta:
                    for key in hit.meta.highlight:
                        formatted_hit['highlights'].extend(hit.meta.highlight[key])

            count = es_results.hits.total
            total_count += count

            results[type] = formatted_hits
            results['total_%s' % type] = count

        results['total_all'] = total_count
        return results
