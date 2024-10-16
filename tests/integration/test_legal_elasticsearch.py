from webservices.legal_docs import create_index, CASE_INDEX, ARCH_MUR_INDEX, AO_INDEX

from webservices.utils import create_es_client
from tests.legal_test_data import first_test_mur


ALL_INDICES = [CASE_INDEX, AO_INDEX, ARCH_MUR_INDEX]


class TestElasticsearch:
    es_client = create_es_client()

    @classmethod
    def setup_class(self):
        for index in ALL_INDICES:
            create_index(index)

    @classmethod
    def teardown_class(self):
        for index in ALL_INDICES:
            self.es_client.indices.delete(index)

    @classmethod
    def wait_for_refresh(self, index_name):
        self.es_client.indices.refresh(index=index_name)

    def test_index_creation(self):
        for index in ALL_INDICES:
            exists = self.es_client.indices.get(index)
            assert exists, f"Error creating {index}"

    def test_insert_and_query(self):
        # Insert a document
        doc = first_test_mur
        self.es_client.index(index=CASE_INDEX, body=doc)
        self.wait_for_refresh(CASE_INDEX)  # Ensure the document is indexed

        # Query the document
        query = {"query": {"term": {"type": "murs"}}}
        result = self.es_client.search(index=CASE_INDEX, body=query)
        assert result['hits']['total']['value'] == 1
