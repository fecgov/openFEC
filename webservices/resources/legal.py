from webservices import args
from webservices import utils
from webservices.utils import use_kwargs

es = utils.get_elasticsearch_connection()

class Search(utils.Resource):
    @use_kwargs(args.query)
    def get(self, q, from_hit=0, hits_returned=20, type='all', **kwargs):
        if type == 'all':
            types = ['advisory_opinions', 'regulations']
        else:
            types = [type]

        results = {}
        total_count = 0
        for type in types:
            query = {"query": {"bool": {
                     "must": [{"match": {"_all": q}}, {"term": {"_type": type}}],
                               "should": [{"match": {"no": q}},
                                               {"match_phrase": {"_all": {"query": q,
                                                                          "slop": 50}
                                                                 }
                                                }]
                     }},
                "highlight": {"fields": [{"text": {}},
                    {"name": {}}, {"number": {}}]},
                "_source": {"exclude": "text"}}

            hits_returned = min([200, hits_returned])
            es_results = es.search(query, index='docs', size=hits_returned,
                             es_from=from_hit)
            hits = es_results['hits']['hits']
            for hit in hits:
                highlights = []
                if 'highlight' in hit:
                    for key in hit['highlight']:
                        highlights.extend(hit['highlight'][key])
                hit['_source']['highlights'] = highlights
            count = es_results['hits']['total']
            total_count += count
            formatted_hits = [h['_source'] for h in hits]

            results[type] = formatted_hits
            results['total_%s' % type] = count

        results['total_all'] = total_count
        return results
