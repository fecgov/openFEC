from webservices import args
from webservices import utils
from webservices.utils import use_kwargs

es = utils.get_elasticsearch_connection()

class Search(utils.Resource):
    @use_kwargs(args.query)
    def get(self, **kwargs):
        query = kwargs['q']
        hits = es.search('_all: %s' % query, index='docs', size=10)['hits']['hits']
        return {'results': hits}
