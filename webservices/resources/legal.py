import sqlalchemy as sa

from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices.utils import use_kwargs
from webargs import fields
from pyelasticsearch import ElasticSearch
from webservices.env import env


es_conn = env.get_service(label='elasticsearch-swarm-1.7.1')
if es_conn:
    es = ElasticSearch(es_conn.get_url(url='uri'))
else:
    es = ElasticSearch('http://localhost:9200')

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

