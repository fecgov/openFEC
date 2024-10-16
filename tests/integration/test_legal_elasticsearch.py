from webservices.legal_docs import create_index, CASE_INDEX, ARCH_MUR_INDEX, AO_INDEX
from webservices.utils import create_es_client
from tests.legal_test_data import all_test_murs
from webservices import rest


ALL_INDICES = [CASE_INDEX, AO_INDEX, ARCH_MUR_INDEX]


class TestLegalSearch():
    es_client = create_es_client()
    base_search_url = "/v1/legal/search/?"

    @classmethod
    def setup_class(self):
        self.app = rest.app.test_client()
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

    def test_mur_insert(self):
        # Insert a document
        for mur in all_test_murs:
            self.es_client.index(index=CASE_INDEX, body=mur)

        self.wait_for_refresh(CASE_INDEX)

        # Query the document
        query = {"query": {"term": {"type": "murs"}}}
        result = self.es_client.search(index=CASE_INDEX, body=query)
        assert result['hits']['total']['value'] == 2

    def test_mur_type_filter(self):
        mur_type = "current"
        response = self.app.get(
            self.base_search_url + "mur_type=" + mur_type
        )
        assert response.status_code == 200
        assert response.json["total_all"] == 2
        assert response.json["total_murs"] == 2
        assert response.json["murs"][0]["mur_type"] == mur_type
        assert response.json["murs"][1]["mur_type"] == mur_type

        mur_type = "archived"
        response = self.app.get(
            self.base_search_url + "mur_type=" + mur_type
        )
        assert response.status_code == 200
        assert response.json["total_all"] == 0
        assert response.json["total_murs"] == 0

    def test_election_cycles_filter(self):
        election_cycle = 2020
        response = self.app.get(
            self.base_search_url + "case_election_cycles=" + str(election_cycle)
        )

        assert response.status_code == 200
        assert response.json["total_all"] == 1
        assert response.json["total_murs"] == 1
        assert election_cycle in response.json["murs"][0]["election_cycles"]

    def test_mur_citation_filters(self):
        statutory_citation = "52 U.S.C. §30116"
        regulatory_citation = "11 CFR §104.3"

        response = self.app.get(
            self.base_search_url + "case_statutory_citation=" +
            statutory_citation + "&case_regulatory_citation=" + regulatory_citation
        )

        assert response.status_code == 200
        assert response.json["total_all"] == 2
        assert response.json["total_murs"] == 2

        response = self.app.get(
            self.base_search_url + "case_statutory_citation=" +
            statutory_citation + "&case_regulatory_citation=" + regulatory_citation +
            "&case_citation_require_all=true"
        )

        assert response.status_code == 200
        assert response.json["total_all"] == 1
        assert response.json["total_murs"] == 1

        statutory_citation = "52 U.S.C. §308989"

        response = self.app.get(
            self.base_search_url + "case_statutory_citation=" + statutory_citation
        )
        assert response.status_code == 200
        assert response.json["total_all"] == 0
        assert response.json["total_murs"] == 0

    # def test_mur_date_filters(self):
