from webservices.env import env
from flask import request
from webservices import utils
import os

es = utils.get_elasticsearch_connection()

if env.get_credential('WRITE_AUTHORIZED_TOKENS'):
    write_cred = env.get_credential('WRITE_AUTHORIZED_TOKENS') 
else:
    if 'WRITE_AUTHORIZED_TOKENS' in os.environ:
        write_cred = os.environ['WRITE_AUTHORIZED_TOKENS']
    else:
        write_cred = ''

write_authorized_tokens = [token.strip() for token in write_cred.split(',')]

class Legal(utils.Resource):
    def post(self, **kwargs):
        data = request.get_json()
        if data['api_key'] in write_authorized_tokens:
            es.bulk((es.index_op(doc, id=doc['doc_id']) for doc in data['docs']),
              index='docs',
              doc_type=data['doc_type'])

            es.refresh(index='docs')
            return {'success': True}
        else:
            msg = {'success': False, 'message': 
                "Your API token has not been authorized to write data to this application."}
            return msg, 401
