from webservices.legal_docs import create_index, CASE_INDEX, ARCH_MUR_INDEX, AO_INDEX, display_index_alias
from webservices.utils import create_es_client
ALL_INDICES = [CASE_INDEX, AO_INDEX, ARCH_MUR_INDEX]


class TestElasticsearch:
    es_client = create_es_client()

    @classmethod
    def setup_class(self):
        # ensure environment is completely clean before starting
        self.delete_all_indices()
        for index in ALL_INDICES:
            create_index(index)

    @classmethod
    def delete_all_indices(self):
        self.es_client.indices.delete("*")

    @classmethod
    def teardown_class(self):
        self.delete_all_indices()

    @classmethod
    def wait_for_refresh(self, index_name):
        self.es_client.indices.refresh(index=index_name)

    def test_index_creation(self):
        display_index_alias()
        for index in ALL_INDICES:
            exists = self.es_client.indices.get(index)
            assert exists, f"Error creating {index}"
