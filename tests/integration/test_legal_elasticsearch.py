from webservices.legal_docs import create_index, CASE_INDEX, ARCH_MUR_INDEX, AO_INDEX
from webservices.utils import create_es_client
from tests.legal_test_data import document_dictionary
from webservices.resources.legal import ALL_DOCUMENT_TYPES
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

# ---------------------- Test all case filters  ------------------------------------------------

    def test_all_doc_types(self):  # would catch hotfix
        response = self.app.get(self.base_search_url)

        total_all = 0
        total_all += sum(len(document_dictionary[doc_type]) for doc_type in document_dictionary)

        all_murs = len(document_dictionary["archived_murs"]) + len(document_dictionary["murs"])

        assert response.status_code == 200
        assert response.json["total_all"] == total_all
        assert response.json["total_murs"] == all_murs
        assert response.json["total_adrs"] == len(document_dictionary["adrs"])
        assert response.json["total_admin_fines"] == len(document_dictionary["admin_fines"])

    def test_type_filter(self):
        for type in ALL_DOCUMENT_TYPES:
            url = self.base_search_url + "type=" + type
            response = self.app.get(url)

            if type == "murs":
                total = len(document_dictionary["archived_murs"]) + len(document_dictionary["murs"])
            elif document_dictionary[type]:
                total = len(document_dictionary[type])
            else:
                total = 0

            assert response.status_code == 200
            assert response.json["total_all"] == total
            assert response.json["total_" + type] == total

    def test_election_cycles_filter(self):
        # for mur and adrs only
        election_cycle = 2020
        url = "{}case_election_cycles={}".format(self.base_search_url, election_cycle)
        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            (election_cycle in mur["election_cycles"] and mur["mur_type"] == "current")
            for mur in response.json["murs"]
        ) and all(
            election_cycle in adr["election_cycles"]
            for adr in response.json["adrs"]
        )

        election_cycle = "abc"
        url = "{}case_election_cycles={}".format(self.base_search_url, election_cycle)
        response = self.app.get(url)

        assert response.status_code == 422

    def test_case_date_filters(self):
        # for murs and adrs only
        open_date = "2020-10-01"
        query_date = datetime.strptime(open_date, "%Y-%m-%d")
        url = "{}case_min_open_date={}".format(self.base_search_url, open_date)

        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            datetime.strptime(mur["open_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for mur in response.json["murs"]
        ) and all(
            datetime.strptime(adr["open_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for adr in response.json["adrs"]
        )

        url = "{}case_max_open_date={}".format(self.base_search_url, open_date)

        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            datetime.strptime(mur["open_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for mur in response.json["murs"]
        )

        close_date = "2022-11-29"
        query_date = datetime.strptime(close_date, "%Y-%m-%d")

        url = "{}case_min_close_date={}".format(self.base_search_url, close_date)

        response = self.app.get(url)

        assert response.status_code == 200

        assert all(
            datetime.strptime(mur["close_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for mur in response.json["murs"]
        ) and all(
            datetime.strptime(adr["close_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for adr in response.json["adrs"]
        )

        url = "{}case_max_close_date={}".format(self.base_search_url, close_date)

        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            datetime.strptime(mur["close_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for mur in response.json["murs"]
        ) and all(
            datetime.strptime(adr["close_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for adr in response.json["adrs"]
        )

        wrong_date_format = "01/20/24"
        url = "{}case_min_close_date={}".format(self.base_search_url, wrong_date_format)

        response = self.app.get(url)
        assert response.status_code == 422

# ---------------------- Start MUR only filters ------------------------------------------------

    def test_mur_type_filter(self):
        mur_types = ["current", "archived"]

        for type in mur_types:
            url = "{}mur_type={}".format(self.base_search_url, type)
            response = self.app.get(url)

            assert response.status_code == 200
            assert all(mur["mur_type"] == type for mur in response.json["murs"])

        mur_type = "wrongType"
        url = "{}mur_type={}".format(self.base_search_url, mur_type)
        response = self.app.get(url)
        assert response.status_code == 422

    def test_mur_citation_filters(self):
        # filter for current murs only
        statutory_title = "52"
        statutory_text = "30116"
        regulatory_title = "11"
        regulatory_text = "104.3"

        url = "{}case_statutory_citation={} U.S.C. §{}&case_regulatory_citation={} CFR §{}".format(
            self.base_search_url, statutory_title, statutory_text, regulatory_title, regulatory_text)

        response = self.app.get(url)

        assert response.status_code == 200

        for mur in response.json["murs"]:
            assert mur["mur_type"] == "current"
            found = any(
                (citations["title"] == statutory_title and statutory_text in citations["text"]) or
                (citations["title"] == regulatory_title and regulatory_text in citations["text"])
                for dispositions in mur["dispositions"]
                for citations in dispositions["citations"]
            )
            assert found

        url = """{}case_statutory_citation={} U.S.C. §{}&case_regulatory_citation={} CFR §{}
        &case_citation_require_all=true""".format(
            self.base_search_url, statutory_title, statutory_text, regulatory_title, regulatory_text)

        response = self.app.get(url)

        assert response.status_code == 200

        for mur in response.json["murs"]:
            assert mur["mur_type"] == "current"
            found = any(
                (citations["title"] == statutory_title and statutory_text in citations["text"]) or
                (citations["title"] == regulatory_title and regulatory_text in citations["text"])
                for dispositions in mur["dispositions"]
                for citations in dispositions["citations"]
            )
            assert found

        statutory_citation = "52 U.S.C. §308989"
        url = "{}case_statutory_citation={}".format(self.base_search_url, statutory_citation)

        response = self.app.get(url)

        assert response.status_code == 200
        assert response.json["total_murs"] == 0

    def test_mur_disposition_filter(self):
        # filter for current murs only
        category_1 = "7"
        category_2 = "24"

        url = "{}mur_disposition_category_id={}&mur_disposition_category_id={}".format(self.base_search_url,
                                                                                       category_1, category_2)

        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            mur["mur_type"] == "current" and any(
                category_1 == dispositions["mur_disposition_category_id"] or
                category_2 == dispositions["mur_disposition_category_id"]
                for dispositions in mur["dispositions"]
            )
            for mur in response.json["murs"]
        )

        category = "14"
        url = "{}mur_disposition_category_id={}".format(self.base_search_url, category)
        response = self.app.get(url)

        assert response.status_code == 200

        assert all(
            mur["mur_type"] == "current" and any(
                category == dispositions["mur_disposition_category_id"]
                for dispositions in mur["dispositions"]
            )
            for mur in response.json["murs"]
        )

        category = "49"
        url = "{}mur_disposition_category_id={}".format(self.base_search_url, category)

        response = self.app.get(url)
        assert response.status_code == 422
# ---------------------- End MUR only filters ------------------------------------------------
# ---------------------- Start AF only filters ------------------------------------------------

    def test_af_filters(self):
        filters = {"af_name": "ICE PAC",
                   "af_committee_id": "C00833665",
                   "af_report_year": "2014"
                   }
        bad_value = "this is an incorrect value"

        for key, value in filters.items():
            url = "{}{}={}".format(self.base_search_url, key, value)

            response = self.app.get(url)
            assert response.status_code == 200
            assert all(af[key[3:]] == value for af in response.json["admin_fines"])

            url = "{}{}={}".format(self.base_search_url, key, bad_value)
            response = self.app.get(url)

            if key == "af_committee_id":
                assert response.status_code == 422
            else:
                assert response.status_code == 200
                assert response.json["total_admin_fines"] == 0
