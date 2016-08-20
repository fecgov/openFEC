from mock import patch
from data.load_legal_docs import *

class ElasticSearchMock:
    def search():
        pass

def get_es():
    return ElasticSearchMock()

class StatuteTest(unittest.TestCase):
    @patch('webservices.utils.get_elasticsearch_connection', side_effect=get_es)
    def test_title_26(self):
        get_title_26_statutes()
