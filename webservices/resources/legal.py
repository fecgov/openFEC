import re

from elasticsearch_dsl import Search, Q
from webargs import fields

from webservices import args
from webservices import utils
from webservices.utils import use_kwargs

es = utils.get_elasticsearch_connection()

class AdvisoryOpinion(utils.Resource):
    @property
    def args(self):
        return {"ao_no": fields.Str(required=True, description='Advisory opinion number to fetch.')}

    def get(self, ao_no, **kwargs):
        es_results = Search().using(es) \
          .query('bool', must=[Q('term', no=ao_no), Q('term', _type='advisory_opinions')]) \
          .source(exclude='text') \
          .extra(size=200) \
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
    def get(self, q, from_hit=0, hits_returned=20, type='all', **kwargs):
        if type == 'all':
            types = ['advisory_opinions', 'regulations', 'statutes']
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
            text_highlight_query = None

            if len(terms):
                must_query.append(Q('match', _all=' '.join(terms)))

            if len(phrases):
                phrase_queries = [Q('match_phrase', text=phrase) for phrase in phrases]
                must_query.extend(phrase_queries)
                text_highlight_query = Q('bool', must=phrase_queries)

            query = Search().using(es) \
                .query(Q('bool',
                         must=must_query,
                         should=[Q('match', no=q), Q('match_phrase', _all={"query": q, "slop": 50})])) \
                .highlight('name', 'number') \
                .source(exclude='text') \
                .extra(size=hits_returned, from_=from_hit) \
                .index('docs')

            if text_highlight_query:
                query = query.highlight('text', highlight_query=text_highlight_query.to_dict())
            else:
                query = query.highlight('text')

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
