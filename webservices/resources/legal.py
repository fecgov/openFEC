import sqlalchemy as sa

from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices.utils import use_kwargs
from webargs import fields
from pyelasticsearch import ElasticSearch
from webservices.env import env


@doc(
    tags=['search'],
    description=docs.LEGAL_SEARCH
)

class UniversalSearch(utils.Resource):
    def __init__(self):
        es_conn = env.get_credential('ES_CONN')
        if not es_conn:
            es_conn = 'http://localhost:9200'
        self.es = ElasticSearch(es_conn)

    @use_kwargs(args.query)
    def get(self, **kwargs):
        query = kwargs['q']
        hits = self.es.search('_all: %s' % query, index='docs', size=10)['hits']['hits']
        return {'results': hits}