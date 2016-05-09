from webservices import args
from webservices import utils
from webservices.utils import use_kwargs

es = utils.get_elasticsearch_connection()

class Search(utils.Resource):
    @use_kwargs(args.query)
    def get(self, q, from_hit=0, hits_returned=20, **kwargs):
        query = {"query": {"bool": {
                            "must": {"match": {"_all": q}},
                            "should": [{"match": {"AO_No": q}},
                                           {"match_phrase": {"_all": {"query": q,
                                                                      "slop":  50
                                                                      }
                                                             }
                                            }]
                                    }
                            },
                    "highlight": {"fields": {"text": {}}},
                    "_source": {"exclude": "text"}
                 }

        hits_returned = min([200, hits_returned])
        results = es.search(query, index='docs', size=hits_returned,
                         es_from=from_hit)
        hits = results['hits']['hits']

        for hit in hits:
            hit["pdf_url"] = 'http://saos.fec.gov/aodocs/%s.pdf' % hit['_source']['AO_No']

        return {'results': hits, 'count': results['hits']['total']}

