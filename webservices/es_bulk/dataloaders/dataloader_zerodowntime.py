import logging
from elasticsearch import Elasticsearch
from elasticsearch import NotFoundError

from utils.decorators import timing
from .dataloader import DataLoader

LOGGER = logging.getLogger(__name__)


class DataLoaderZeroDownTime(DataLoader):

    def __init__(self, es_ip):
        super(DataLoader, self).__init__()
        self.es_ip = es_ip
        self.es = Elasticsearch([es_ip])
        self.doc_type = 'data'
        self._index = None
        self._data = None
        self._key = None
        self.mappings = None

    @property
    def first_index(self):
        return self.index + '_v1'

    @property
    def second_index(self):
        return self.index + '_v2'

    def add_alias(self, idx):
        LOGGER.warning("The alias {} will point to {}.".format(self.index, idx))
        self.es.indices.put_alias(idx, self.index)

    def delete_alias(self, idx):
        LOGGER.warning("The alias {} will be removed from {}.".format(self.index, idx))
        self.es.indices.delete_alias(idx, self.index)

    def get_current_index(self):
        first, second = self.first_index, self.second_index
        if not self.es.indices.exists(first) and not self.es.indices.exists(second):
            LOGGER.warning("Both versions for {} do not exist.".format(self.index))
            LOGGER.info("{} will be created.".format(first))
            return first
        if not self.es.indices.exists(first):
            return first
        if not self.es.indices.exists(second):
            return second

        # Both indexes exist
        # Fixing issue 33 https://github.com/loc-rdc/transfer_rep/issues/33
        # Always index the one without alias 'self.index'
        if not self.es.indices.exists_alias(first, self.index) \
                and not self.es.indices.exists_alias(second, self.index):
            LOGGER.warning("No alias found from both indecies. strange.")
            return first

        if self.es.indices.exists_alias(first, self.index):
            return second
        return first

    @timing
    def run_data_loading_pipeline(self):
        current_index = self.get_current_index()
        LOGGER.warning('The index that will be used is {}, and all previous data will be deleted.'.format(current_index))
        unused_index = self.second_index
        LOGGER.info('The index {} will NOT be used this time.'.format(unused_index))

        if current_index == self.second_index:
            unused_index = self.first_index
        self.prepare_index(current_index)

        current_data = self.prepare_data(current_index)
        self.index_data(current_data)

        LOGGER.info("The alias will start to switch.")
        try:
            self.delete_alias(unused_index)
        except NotFoundError:
            LOGGER.warning("{} does not exist yet.".format(unused_index))
        try:
            LOGGER.info("Adding alias for current index {}".format(current_index))
            self.add_alias(current_index)
        except NotFoundError:
            LOGGER.warning("{} does not exist yet.".format(current_index))
        LOGGER.info("The alias has been switched.")
