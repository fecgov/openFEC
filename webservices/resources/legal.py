import sqlalchemy as sa

from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices.utils import use_kwargs
from webargs import fields
from pyelasticsearch import ElasticSearch
from webservices.env import env
import json
from flask import request


es_conn = env.get_service(label='elasticsearch-swarm-1.7.1')
if es_conn:
    es = ElasticSearch(es_conn.get_url(url='uri'))
else:
    es = ElasticSearch('http://localhost:9200')

class Search(utils.Resource):
    @use_kwargs(args.query)
    def get(self, **kwargs):
        query = kwargs['q']
        hits = es.search('_all: %s' % query, index='docs', size=10)['hits']['hits']
        return {'results': hits}

class Load(utils.Resource):
    def post(self, **kwargs):
        data = request.get_json()
        es.bulk((es.index_op(doc, id=doc['doc_id']) for doc in data['docs']),
          index='docs',
          doc_type=data['doc_type'])

        es.refresh(index='docs')

        return {'success': True}