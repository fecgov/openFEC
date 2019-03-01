import logging

from elasticsearch import Elasticsearch
from elasticsearch import helpers
from utils.decorators import timing
from utils.common import print_json


LOGGER = logging.getLogger(__name__)


class DataLoader(object):
    def __init__(self, es_ip):
        self.es_ip = es_ip
        self.es = Elasticsearch([es_ip])
        self.doc_type = "data"
        self._index = None
        self._data = None
        self._key = None
        self._mapping_file = None
        self.document_count = -1

    @property
    def mappings(self):
        return self._mapping_file

    @mappings.setter
    def mappings(self, value):
        self._mapping_file = value

    @property
    def data(self):
        return self._data

    @data.setter
    def data(self, value):
        self._data = value

    @property
    def key(self):
        return self._key

    @key.setter
    def key(self, value):
        if value:
            LOGGER.info("The key {} is settled".format(value))
        else:
            LOGGER.warning("There is no valid key or id for Elasticsearch, and will use the default.")
        self._key = value

    @property
    def index(self):
        return self._index

    @index.setter
    def index(self, value):
        LOGGER.info("The index {} is settled.".format(value))
        self._index = value

    @timing
    def prepare_data(self, idx):
        for i, each_json in enumerate(self.data):
            if i == 0:
                LOGGER.info("Will print the first JSON file below for validation.")
                LOGGER.info(print_json(each_json))
                LOGGER.info("***************Indexing {} now*****************************".format(self.index))
            if self.key:
                current_id = each_json[self.key]
            else:
                current_id = i
            self.document_count = i + 1
            yield {
                "_index": idx,
                "_type": self.doc_type,
                "_id": current_id,
                "_source": each_json
            }
        LOGGER.info("There are {} JSONs that were indexed.".format(self.document_count))

    @timing
    def prepare_index(self, idx):
        if self.es.indices.exists(idx):
            LOGGER.warning('The index {} will be deleted.'.format(idx))
            self.es.indices.delete(index=idx)
        else:
            LOGGER.info('No index {} exists and will create one'.format(idx))
        if self.mappings:
            LOGGER.info("The mapping will be based the mapping file.")
            self.es.indices.create(index=idx, ignore=400, body=self.mappings)
        else:
            LOGGER.info("There is no mapping file specified, and the indexing will continue with default.")
            self.es.indices.create(index=idx, ignore=400)

    @timing
    def index_data(self, data):
        for resp in helpers.parallel_bulk(self.es, data):
            pass

    @timing
    def run_data_loading_pipeline(self):
        current_data = self.prepare_data(self.index)
        self.index_data(current_data)
        LOGGER.info("The index is done.")
