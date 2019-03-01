import unittest
from elasticsearch import Elasticsearch

import random
import string
import tests.settings as settings

import os, sys
path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, path)


from dataloaders.dataloader_zerodowntime import DataLoaderZeroDownTime
from reporting import Reporting



class TestZeroDown(unittest.TestCase):

    def __init__(self, *args, **kwargs):
        super(TestZeroDown, self).__init__(*args, **kwargs)
        self.es_host = settings.TEST_ES_HOST
        self.index_alias = None

    def setUp(self):
        self.index_alias = TestZeroDown.generate_random_index_name()
        #self.test_get_current_index()

    #need everything thing in lower case
    @staticmethod
    def generate_random_index_name():
        return ''.join(random.SystemRandom().choice(string.ascii_lowercase + string.digits) for _ in range(5))

    def test_get_current_index(self):

        data_loader = DataLoaderZeroDownTime(es_ip=self.es_host)

        reporting = Reporting(data_loader=data_loader)

        #bag_item = BagItemDocuments(cts_data_provider)
        test_doc = [{'k1':'v1'}]

        #first time index it, create v1
        reporting.index(index=self.index_alias, mappings=None, documents=test_doc,
                        key_field=None)

        es = Elasticsearch([self.es_host])

        assert es.indices.exists(self.index_alias+'_v1')
        assert es.indices.exists_alias(self.index_alias+'_v1', self.index_alias)
        assert not es.indices.exists(self.index_alias+'_v2')

        #second time index it, create v2, switch alias
        reporting.index(index=self.index_alias, mappings=None, documents=test_doc,
                        key_field=None)
        assert es.indices.exists(self.index_alias+'_v1')
        assert es.indices.exists(self.index_alias+'_v2')
        assert es.indices.exists_alias(self.index_alias+'_v2', self.index_alias)
        assert not es.indices.exists_alias(self.index_alias+'_v1', self.index_alias)

        #third time index it, switch back to v1
        reporting.index(index=self.index_alias, mappings=None, documents=test_doc,
                        key_field=None)
        assert es.indices.exists(self.index_alias+'_v2')
        assert es.indices.exists(self.index_alias+'_v1')
        assert es.indices.exists_alias(self.index_alias+'_v1', self.index_alias)
        assert not es.indices.exists_alias(self.index_alias+'_v2', self.index_alias)

        #now delete v2 and receate an empty v2 to assimulate a non-valid v2
        es.indices.delete(index=self.index_alias+'_v2')
        es.indices.create(index=self.index_alias+'_v2', ignore=400)
        v2_creation_time = es.indices.get(self.index_alias+'_v2')[self.index_alias+'_v2']['settings']['index']['creation_date']
        v1_creation_time = es.indices.get(self.index_alias+'_v1')[self.index_alias+'_v1']['settings']['index']['creation_date']

        #if based on creation time, we'll get v1 bak for re-indexing, which is a defect. because v2 is empty and invalid
        assert v2_creation_time > v1_creation_time
        data_loader.index = self.index_alias
        #the alias-based solution should return v2 instead
        assert data_loader.get_current_index() == self.index_alias+'_v2'




    def tearDown(self):
        es = Elasticsearch([self.es_host])
        es.indices.delete(index=self.index_alias+'v1', ignore=[400, 404])
        es.indices.delete(index=self.index_alias+'v2', ignore=[400, 404])


if __name__ == '__main__':
     unittest.main()
