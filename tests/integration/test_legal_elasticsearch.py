from webservices.legal_docs import create_index, CASE_INDEX, ARCH_MUR_INDEX, AO_INDEX
from webservices.utils import create_es_client
from tests.legal_test_data import document_dictionary
from webservices import rest
ALL_INDICES = [CASE_INDEX, AO_INDEX, ARCH_MUR_INDEX]


class TestElasticsearch:
    es_client = create_es_client()
    base_search_url = "/v1/legal/search/?"

    @classmethod
    def setup_class(self):
        self.app = rest.app.test_client()
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

    @classmethod
    def insert_documents(self, doc_type, index):
        for doc in document_dictionary[doc_type]:
            self.es_client.index(index=index, body=doc)

        self.wait_for_refresh(index)

        if doc_type == "archived_murs":
            query = {"query": {"term": {"type": "murs"}}}
        else:
            query = {"query": {"term": {"type": doc_type}}}

        result = self.es_client.search(index=index, body=query)
        assert result['hits']['total']['value'] == len(document_dictionary[doc_type])

# ---------------------- Start tests  ------------------------------------------------

    def test_index_creation(self):
        for index in ALL_INDICES:
            exists = self.es_client.indices.get(index)
            assert exists, f"Error creating {index}"

# ---------------------- Test document inserts  ------------------------------------------------

    def test_mur_insert(self):
        self.insert_documents("murs", CASE_INDEX)

    def test_arch_mur_insert(self):
        self.insert_documents("archived_murs", ARCH_MUR_INDEX)

    def test_adr_insert(self):
        self.insert_documents("adrs", CASE_INDEX)

    def test_af_insert(self):
        self.insert_documents("admin_fines", CASE_INDEX)
