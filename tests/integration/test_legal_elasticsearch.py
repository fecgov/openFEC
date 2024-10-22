from webservices.legal_docs import create_index, CASE_INDEX, ARCH_MUR_INDEX, AO_INDEX
from webservices.utils import create_es_client
from tests.legal_test_data import document_dictionary
from webservices.resources.legal import ALL_DOCUMENT_TYPES
from webservices import rest
from datetime import datetime
from urllib.parse import urlencode

ALL_INDICES = [CASE_INDEX, AO_INDEX, ARCH_MUR_INDEX]


class TestLegalSearch():
    es_client = create_es_client()
    base_search_url = "/v1/legal/search/?"

    @classmethod
    def setup_class(self):
        self.app = rest.app.test_client()
        for index in ALL_INDICES:
            create_index(index, testing=True)

    @classmethod
    def delete_indices(self):
        for index in ALL_INDICES:
            self.es_client.indices.delete(index)

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

    @classmethod
    def check_all_doc_types(self, filter_name, field_name, expected_return):
        for doc_type in ALL_DOCUMENT_TYPES:
            self.check_filters(filter_name, field_name, expected_return, doc_type)

    @classmethod
    def check_filters(self, filter_name, field_name, expected_return, doc_type):
        url = f"{self.base_search_url}{filter_name}={expected_return}"
        response = self.app.get(url)

        assert response.status_code == 200
        assert all(x[field_name] == expected_return for x in response.json[doc_type])

    @classmethod
    def check_bad_values(self, filter_name, bad_value, doc_type, raiseError):
        url = f"{self.base_search_url}{filter_name}={bad_value}"
        response = self.app.get(url)

        if raiseError:
            assert response.status_code == 422
        else:
            assert response.status_code == 200
            assert response.json[doc_type] == 0

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

    def test_all_doc_types(self):
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

    def test_case_no(self):
        case_numbers = [108, 101, 104]

        params = {
            "case_no": case_numbers
        }
        url = self.base_search_url + urlencode(params, doseq=True)
        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            ("case_no" not in mur or mur["case_no"] in case_numbers)
            for mur in response.json["murs"]
        ) and all(
            ("case_no" not in adr or adr["case_no"] in case_numbers)
            for adr in response.json["advisory_opinions"]
        ) and all(
            ("case_no" not in af or af["case_no"] in case_numbers)
            for af in response.json["admin_fines"]
        )

    def test_election_cycles_filter(self):
        # for current mur and adrs only
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
        self.check_bad_values("case_election_cycles", election_cycle, "", True)

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
        ) and all(
            datetime.strptime(adr["open_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for adr in response.json["adrs"]
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
        filters = ["case_min_close_date", "case_max_close_date", "case_min_open_date", "case_max_open_date"]

        for filter in filters:
            self.check_bad_values(filter, wrong_date_format, "", True)

    def test_subject_id(self):
        # for current mur and adrs only
        primary = ["3", "16"]
        secondary = ["13", "15"]

        params = {
            "primary_subject_id": primary
        }

        url = self.base_search_url + urlencode(params, doseq=True)
        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            mur["mur_type"] == "current" and any(
                subject["primary_subject_id"] in primary
                for subject in mur["subjects"]
            )
            for mur in response.json["murs"]
        ) and (any(
            subject["primary_subject_id"] in primary
            for subject in adr["subjects"]
        )
            for adr in response.json["advisory_opinions"]
        )

        params = {
            "secondary_subject_id": secondary
        }

        url = self.base_search_url + urlencode(params, doseq=True)
        response = self.app.get(url)
        assert response.status_code == 200
        assert all(
            mur["mur_type"] == "current" and any(
                subject["secondary_subject_id"] in secondary
                for subject in mur["subjects"]
            )
            for mur in response.json["murs"]
        ) and (any(
            subject["secondary_subject_id"] in secondary
            for subject in adr["subjects"]
        )
            for adr in response.json["advisory_opinions"]
        )

        category = "555"
        filters = ["primary_subject_id", "secondary_subject_id"]

        for filter in filters:
            self.check_bad_values(filter, category, "", True)

    def test_case_respondents(self):
        # for archived murs, current murs, and adr only
        respondents = ["Hometown Values PAC",]
        #["Smith, John",]
##"Naolitano, Grace Flores for Congress Committee", "Hometown Values PAC"
        for respondent in respondents:
            url = "{}case_respondents={}".format(self.base_search_url, respondent)
            response = self.app.get(url)

            assert response.status_code == 200
            print(response.json)
            assert all(
               ("respondents" not in mur or respondent in mur["respondents"])
               for mur in response.json["murs"]
            ) and (
               ("respondents" not in adr or respondent in adr["respondents"])
               for adr in response.json["advisory_opinions"]
            )

        bad_value = "This is a bad value"
        self.check_bad_values("case_respondents", bad_value, "murs", False)
        self.check_bad_values("case_respondents", bad_value, "adrs", False)

# ---------------------- Start MUR only filters ------------------------------------------------

    def test_mur_type_filter(self):
        filters = [
            ["mur_type", "mur_type", "current", True],
            ["mur_type", "mur_type", "archived", True]

        ]
        bad_value = "wrongType"

        for filter in filters:
            self.check_filters(filter[0], filter[1], filter[2], "murs")
            self.check_bad_values(filter[0], bad_value, "total_murs", filter[3])

    def test_mur_citation_filters(self):
        # filter for current murs only
        statutory_title = "52"
        statutory_text = "30116"
        regulatory_title = "11"
        regulatory_text = "104.3"

        params = {
            "case_statutory_citation": "{} U.S.C. §{}".format(statutory_title, statutory_text),
            "case_regulatory_citation": "{} CFR §{}".format(regulatory_title, regulatory_text)
        }

        url = self.base_search_url + urlencode(params)

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

        params = {
            "case_statutory_citation": "{} U.S.C. §{}".format(statutory_title, statutory_text),
            "case_regulatory_citation": "{} CFR §{}".format(regulatory_title, regulatory_text),
            "case_citation_require_all": "true"
        }

        url = self.base_search_url + urlencode(params)

        response = self.app.get(url)

        assert response.status_code == 200

        for mur in response.json["murs"]:
            assert mur["mur_type"] == "current"

            statutory_found = any(
                citations["title"] == statutory_title and statutory_text in citations["text"]
                for dispositions in mur["dispositions"]
                for citations in dispositions["citations"]
            )

            regulatory_found = any(
                citations["title"] == regulatory_title and regulatory_text in citations["text"]
                for dispositions in mur["dispositions"]
                for citations in dispositions["citations"]
            )
        assert statutory_found and regulatory_found

        filters = [
            ["case_statutory_citation", "524 U.S.C. §30106444"],
            ["case_regulatory_citation", "1111 CFR §112.4111"]
        ]
        for filter in filters:
            self.check_bad_values(filter[0], filter[1], "total_murs", False)

    def test_mur_disposition_filter(self):
        # filter for current murs only
        categories = ["7", "24"]
        params = {
            "mur_disposition_category_id": categories
        }
        url = self.base_search_url + urlencode(params, doseq=True)
        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            mur["mur_type"] == "current" and any(
                dispositions["mur_disposition_category_id"] in categories
                for dispositions in mur["dispositions"]
            )
            for mur in response.json["murs"]
        )

        category = "14"
        params = {
            "mur_disposition_category_id": category
        }
        url = self.base_search_url + urlencode(params)
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
        self.check_bad_values("mur_disposition_category_id", category, "total_murs", True)

# ---------------------- End MUR only filters ------------------------------------------------
# ---------------------- Start AF only filters ------------------------------------------------
    def test_af_name_multiple_filter(self):
        names_list = ["ICE PAC", "SOCIAL PROGRESS IN UNION WITH ECONOMIC GROWTH"]
        params = {
            "af_name": names_list
        }
        url = self.base_search_url + urlencode(params, doseq=True)
        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            af["name"] in names_list
            for af in response.json["admin_fines"]
        )

    def test_af_filters(self):
        filters = [
            ["af_name", "name", "ICE PAC", False],
            ["af_committee_id", "committee_id", "C00833665", True],
            ["af_report_year", "report_year", "2014", False],
            ["af_rtb_fine_amount", "reason_to_believe_fine_amount", 3300, True],
            ["af_fd_fine_amount", "final_determination_amount", 3300, True]
        ]
        bad_value = "this is an incorrect value"

        for filter in filters:
            self.check_filters(filter[0], filter[1], filter[2], "admin_fines")
            self.check_bad_values(filter[0], bad_value, "total_admin_fines", filter[3])

    def test_af_date_filters(self):
        rtb = "2017-10-01"
        query_date = datetime.strptime(rtb, "%Y-%m-%d")
        url = "{}af_min_rtb_date={}".format(self.base_search_url, rtb)

        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            datetime.strptime(af["reason_to_believe_action_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for af in response.json["admin_fines"]
        )

        url = "{}af_max_rtb_date={}".format(self.base_search_url, rtb)

        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            datetime.strptime(af["reason_to_believe_action_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for af in response.json["admin_fines"]
        )

        fd_date = "2024-08-13"
        query_date = datetime.strptime(fd_date, "%Y-%m-%d")

        url = "{}af_min_fd_date={}".format(self.base_search_url, fd_date)

        response = self.app.get(url)

        assert response.status_code == 200

        assert all(
            datetime.strptime(af["final_determination_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for af in response.json["admin_fines"]
        )

        url = "{}af_max_fd_date={}".format(self.base_search_url, fd_date)

        response = self.app.get(url)

        assert response.status_code == 200
        assert all(
            datetime.strptime(af["final_determination_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for af in response.json["admin_fines"]
        )
        wrong_date_format = "01/20/24"
        filters = ["af_min_rtb_date", "af_max_rtb_date", "af_min_fd_date", "af_max_fd_date"]

        for filter in filters:
            self.check_bad_values(filter, wrong_date_format, "", True)
