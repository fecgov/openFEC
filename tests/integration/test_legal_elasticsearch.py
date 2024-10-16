from webservices.legal_docs import create_index, CASE_INDEX, ARCH_MUR_INDEX, AO_INDEX
from webservices.utils import create_es_client
from tests.legal_test_data import all_test_murs
from webservices import rest
from datetime import datetime

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
        assert result['hits']['total']['value'] == len(all_test_murs)

    def test_mur_type_filter(self):
        mur_type = "current"
        url = "{}mur_type={}".format(self.base_search_url, mur_type)
        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 2
        assert response.json["total_murs"] == 2
        assert response.json["murs"][0]["mur_type"] == mur_type
        assert response.json["murs"][1]["mur_type"] == mur_type

        mur_type = "archived"
        url = "{}mur_type={}".format(self.base_search_url, mur_type)
        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 0
        assert response.json["total_murs"] == 0

        mur_type = "wrongType"
        url = "{}mur_type={}".format(self.base_search_url, mur_type)
        response = self.app.get(url)
        assert response.status_code == 422

    def test_election_cycles_filter(self):
        election_cycle = 2020
        url = "{}case_election_cycles={}".format(self.base_search_url, election_cycle)
        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 1
        assert response.json["total_murs"] == 1
        assert election_cycle in response.json["murs"][0]["election_cycles"]

        election_cycle = 1988
        url = "{}case_election_cycles={}".format(self.base_search_url, election_cycle)
        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 0
        assert response.json["total_murs"] == 0

    def test_mur_citation_filters(self):
        statutory_citation = "52 U.S.C. §30116"
        regulatory_citation = "11 CFR §104.3"

        url = "{}case_statutory_citation={}&case_regulatory_citation={}".format(self.base_search_url,
                                                                                statutory_citation, regulatory_citation)

        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 2
        assert response.json["total_murs"] == 2

        url = "{}case_statutory_citation={}&case_regulatory_citation={}&case_citation_require_all=true".format(
            self.base_search_url, statutory_citation, regulatory_citation)
        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 1
        assert response.json["total_murs"] == 1

        statutory_citation = "52 U.S.C. §308989"
        url = "{}case_statutory_citation={}".format(self.base_search_url, statutory_citation)

        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 0
        assert response.json["total_murs"] == 0

    def test_mur_date_filters(self):
        open_date = "2020-10-01"
        query_date = datetime.strptime(open_date, "%Y-%m-%d")
        url = "{}case_min_open_date={}".format(self.base_search_url, open_date)

        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 1
        assert response.json["total_murs"] == 1

        mur_date = datetime.strptime(response.json["murs"][0]["open_date"], "%Y-%m-%dT%H:%M:%S")

        assert mur_date >= query_date

        url = "{}case_max_open_date={}".format(self.base_search_url, open_date)

        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 1
        assert response.json["total_murs"] == 1

        mur_date = datetime.strptime(response.json["murs"][0]["open_date"], "%Y-%m-%dT%H:%M:%S")

        assert mur_date <= query_date

        close_date = "2022-11-29"
        query_date = datetime.strptime(close_date, "%Y-%m-%d")

        url = "{}case_min_close_date={}".format(self.base_search_url, close_date)

        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 2
        assert response.json["total_murs"] == 2

        mur_date_1 = datetime.strptime(response.json["murs"][0]["close_date"], "%Y-%m-%dT%H:%M:%S")
        mur_date_2 = datetime.strptime(response.json["murs"][1]["close_date"], "%Y-%m-%dT%H:%M:%S")

        assert mur_date_1 >= query_date and mur_date_2 >= query_date

        url = "{}case_max_close_date={}".format(self.base_search_url, close_date)

        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 1
        assert response.json["total_murs"] == 1

        mur_date = datetime.strptime(response.json["murs"][0]["close_date"], "%Y-%m-%dT%H:%M:%S")

        assert mur_date <= query_date

        wrong_date_format = "01/20/24"
        url = "{}case_min_close_date={}".format(self.base_search_url, wrong_date_format)

        response = self.app.get(url)
        assert response.status_code == 422

    def test_mur_disposition_filter(self):
        category_1 = "7"
        category_2 = "24"

        url = "{}mur_disposition_category_id={}&mur_disposition_category_id={}".format(self.base_search_url,
                                                                                       category_1, category_2)

        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 2
        assert response.json["total_murs"] == 2

        found = False
        for mur in response.json["murs"]:
            found = False
            for dispositions in mur["dispositions"]:
                dis_category = dispositions["mur_disposition_category_id"]
                if category_1 == dis_category or category_2 == dis_category:
                    found = True
            assert found

        category = "14"
        url = "{}mur_disposition_category_id={}".format(self.base_search_url, category)
        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_all"] == 1
        assert response.json["total_murs"] == 1

        for mur in response.json["murs"]:
            found = False
            for dispositions in mur["dispositions"]:
                dis_category = dispositions["mur_disposition_category_id"]
                if category == dis_category:
                    found = True
            assert found

        category = "49"
        url = "{}mur_disposition_category_id={}".format(self.base_search_url, category)

        response = self.app.get(url)
        assert response.status_code == 422

