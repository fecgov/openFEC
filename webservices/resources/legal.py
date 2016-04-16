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
    def get(self, q, from_hit=0, hits_returned=10, **kwargs):
        query = {
          "query": { 
            "bool": { 
              "must": { 
                "match": { "_all": q}
              },    
              "should": [
                   {"match": {
                      "AO_No": q  
                   }},
                   {"match_phrase": { 
                      "_all": {
                        "query": q,
                        "slop":  50
                      }
                    }
            }]}}}

        count = es.count(query)
        
        query["highlight"] = {"fields": {"text": {}}}
        query["_source"] = {"exclude": "text"}
        hits_returned = min([10, hits_returned])
        hits = es.search(query, index='docs', size=hits_returned, es_from=from_hit)['hits']['hits']
        return {'results': hits, 'count': count['count']}
