import elasticsearch
from webservices.env import env
from flask import request
from webservices import utils

es = utils.get_elasticsearch_connection()

write_cred = env.get_credential('WRITE_AUTHORIZED_TOKENS', '')
write_authorized_tokens = [token.strip() for token in write_cred.split(',')]

class Legal(utils.Resource):
    def post(self, **kwargs):
        data = request.get_json()
        if data['api_key'] in write_authorized_tokens:
            elasticsearch.helpers.bulk(es, (dict(_op_type='index', _source=doc, id=doc['doc_id']) for doc in data['docs']),
              index='docs',
              doc_type=data['doc_type'])

            return {'success': True}
        else:
            msg = {'success': False, 'message':
                "Your API token has not been authorized to write data to this application."}
            return msg, 401
