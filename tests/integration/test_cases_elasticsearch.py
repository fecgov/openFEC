from datetime import datetime
from webservices.resources.legal import ALL_DOCUMENT_TYPES
from tests.common import ElasticSearchBaseTest, ALL_INDICES, document_dictionary
from webservices.rest import api
from webservices.resources.legal import UniversalSearch
# import logging


class TestCaseDocsElasticsearch(ElasticSearchBaseTest):
    wrong_date_format = "01/20/24"

    def check_filters(self, params, field_name, doc_type):
        response = self._results_case(api.url_for(UniversalSearch, **params))
        # logging.info(list(params.values())[0])
        # logging.info(response[doc_type])
        self.assertNotEqual(response["total_" + doc_type], 0)
        assert all(x[field_name] == list(params.values())[0] for x in response[doc_type])

    def check_incorrect_values(self, params, doc_type, raiseError):
        response = self.app.get(api.url_for(UniversalSearch, **params))
        # logging.info(response.json)

        if raiseError:
            assert response.status_code == 422
        else:
            assert response.status_code == 200
            assert response.json[doc_type] == 0

    def check_sort_asc(self, doc_dict):
        for i in range(len(doc_dict) - 1):
            assert doc_dict[i]["case_serial"] <= doc_dict[i + 1]["case_serial"]

    def check_sort_desc(self, doc_dict):
        for i in range(len(doc_dict) - 1):
            assert doc_dict[i]["case_serial"] >= doc_dict[i + 1]["case_serial"]
# ---------------------- Start tests  ------------------------------------------------

    def test_index_creation(self):
        for index in ALL_INDICES:
            exists = self.es_client.indices.get(index)
            assert exists, f"Error creating {index}"

# ---------------------- Start all case filters  ------------------------------------------------
    def test_all_doc_types(self):
        response = self._results_case(api.url_for(UniversalSearch))
        # logging.info(response)

        total_all = 0
        total_all += sum(len(document_dictionary[doc_type]) for doc_type in document_dictionary)

        all_murs = len(document_dictionary["archived_murs"]) + len(document_dictionary["murs"])

        self.assertEqual(response["total_all"], total_all)
        self.assertEqual(response["total_murs"], all_murs)
        self.assertEqual(response["total_adrs"], len(document_dictionary["adrs"]))
        self.assertEqual(response["total_admin_fines"], len(document_dictionary["admin_fines"]))

    def test_type_filter(self):
        for type in ALL_DOCUMENT_TYPES:
            response = self._response(api.url_for(UniversalSearch, type=type))
            # logging.info(response)

            if type == "murs":
                total = len(document_dictionary["archived_murs"]) + len(document_dictionary["murs"])
            elif document_dictionary[type]:
                total = len(document_dictionary[type])
            else:
                total = 0

            self.assertEqual(response["total_all"], total)
            self.assertEqual(response["total_" + type], total)

        self.check_incorrect_values({"type": "Wrong Type"}, None, True)

    def test_case_no(self):
        # archived and current murs, adrs, and afs
        case_numbers = ["108", "101", "104", "106"]

        response = self._results_case(api.url_for(UniversalSearch, case_no=case_numbers))
        # logging.info(response)

        assert all(
            mur["no"] in case_numbers
            for mur in response["murs"]
        ) and all(
            af["no"] in case_numbers
            for af in response["admin_fines"]
        ) and all(
            adr["no"] in case_numbers
            for adr in response["adrs"]
        )

        response = self._results_case(api.url_for(UniversalSearch, case_no="105"))
        # logging.info(response)

        self.assertEqual(response["adrs"][0]["no"], document_dictionary["adrs"][0]["no"])

    def test_penalty_filter(self):
        # for current murs, adrs, and afs
        penalty = -1

        response = self._results_case(api.url_for(UniversalSearch, case_max_penalty_amount=penalty))
        # logging.info(response)

        assert all(
            any(doc["penalty"] is None
                for doc in mur["dispositions"])
            for mur in response["murs"]
        ) and all(
            any(doc["penalty"] is None
                for doc in adr["dispositions"])
            for adr in response["adrs"]
        ) and all(
            any(doc["penalty"] is None
                for doc in af["dispositions"])
            for af in response["admin_fines"])

        min_penalty = 1250.50
        max_penalty = 5500

        response = self._results_case(api.url_for(UniversalSearch,
                                                  case_min_penalty_amount=min_penalty,
                                                  case_max_penalty_amount=max_penalty))
        # logging.info(response)

        assert all(
            any(doc["penalty"] >= min_penalty and doc["penalty"] <= max_penalty
                for doc in mur["dispositions"])
            for mur in response["murs"]
        ) and all(
            any(doc["penalty"] >= min_penalty and doc["penalty"] <= max_penalty
                for doc in adr["dispositions"])
            for adr in response["adrs"]
        ) and all(
            any(doc["penalty"] >= min_penalty and doc["penalty"] <= max_penalty
                for doc in af["dispositions"])
            for af in response["admin_fines"])

        params = {
            "case_min_penalty_amount": 999999
        }

        self.check_incorrect_values(params, "total_murs", False)
        self.check_incorrect_values(params, "total_admin_fines", False)
        self.check_incorrect_values(params, "total_adrs", False)

    def test_case_doc_cat_id_filter(self):
        # for archived and current murs, adrs, and afs
        case_doc_category_ids = [2, 1, 2001]
        response = self._results_case(api.url_for(UniversalSearch, case_doc_category_id=case_doc_category_ids))
        # logging.info(response)

        assert all(
            any(doc["doc_order_id"] in case_doc_category_ids
                for doc in mur["documents"])
            for mur in response["murs"]
        ) and all(
            any(doc["doc_order_id"] in case_doc_category_ids
                for doc in adr["documents"])
            for adr in response["adrs"]
        ) and all(
            any(doc["doc_order_id"] in case_doc_category_ids
                for doc in af["documents"])
            for af in response["admin_fines"])

        self.check_incorrect_values({"case_doc_category_id": 5555}, None, True)

    def test_case_doc_date(self):
        # for current murs, adrs, and afs
        document_date = "2022-12-01"
        query_date = datetime.strptime(document_date, "%Y-%m-%d")

        response = self._results_case(api.url_for(UniversalSearch, case_min_document_date=document_date))
        # logging.info(response)

        assert all(any(
                datetime.strptime(doc["document_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
                for doc in mur["documents"])
            for mur in response["murs"]
        ) and all(any(
                datetime.strptime(doc["document_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
                for doc in adr["documents"])
            for adr in response["adrs"]
        ) and all(any(
                datetime.strptime(doc["document_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
                for doc in af["documents"])
            for af in response["admin_fines"]
        )

        response = self._results_case(api.url_for(UniversalSearch, case_max_document_date=document_date))
        # logging.info(response)

        assert all(any(
                datetime.strptime(doc["document_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
                for doc in mur["documents"])
            for mur in response["murs"]
        ) and all(any(
                datetime.strptime(doc["document_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
                for doc in adr["documents"])
            for adr in response["adrs"]
        ) and all(any(
                datetime.strptime(doc["document_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
                for doc in af["documents"])
            for af in response["admin_fines"]
        )

        filters = ["case_min_document_date", "case_max_document_date",]

        for filter in filters:
            self.check_incorrect_values({filter: self.wrong_date_format}, None, True)

    def test_q_filters(self):
        # for archived and current murs, advisory_opinions, adrs, and afs

        search_phrase = "sample"
        response = self._results_case(api.url_for(UniversalSearch, q=search_phrase))
        # logging.info(response)

        self.assertEqual(response["total_all"], 8)
        assert all(
            all(search_phrase in highlight
                for highlight in mur["highlights"])
            for mur in response["murs"]
        ) and all(
            all(search_phrase in highlight
                for highlight in adr["highlights"])
            for adr in response["adrs"]
        ) and all(
            all(search_phrase in highlight
                for highlight in af["highlights"])
            for af in response["admin_fines"]
        ) and all(
            all(search_phrase in highlight
                for highlight in ao["highlights"])
            for ao in response["advisory_opinions"])

        exclude_phrase = "admin_fine"
        response = self._results_case(api.url_for(UniversalSearch, q_exclude=exclude_phrase))
        # logging.info(response)

        self.assertEqual(response["total_admin_fines"], 0)
        self.assertEqual(response["total_all"], 8)

    def test_sort(self):
        sort_value = "case_no"
        ignore_type = ["advisory_opinions", "statutes"]
        response = self._results_case(api.url_for(UniversalSearch, sort=sort_value))
        # logging.info(response)

        for doc_type in ALL_DOCUMENT_TYPES:
            if doc_type not in ignore_type:
                self.check_sort_asc(response[doc_type])

        response = self._results_case(api.url_for(UniversalSearch, sort="-" + sort_value))
        # logging.info(response)

        for doc_type in ALL_DOCUMENT_TYPES:
            if doc_type not in ignore_type:
                self.check_sort_desc(response[doc_type])

# ---------------------- End all case filters  ------------------------------------------------
# ---------------------- Start MUR and ADR filters ------------------------------------------------
    def test_election_cycles_filter(self):
        # for current murs and adrs
        election_cycle = 2020
        response = self._results_adr_mur(api.url_for(UniversalSearch, case_election_cycles=election_cycle))
        # logging.info(response)

        assert all(
            election_cycle in mur["election_cycles"] and mur["mur_type"] == "current"
            for mur in response["murs"]
        ) and all(
            election_cycle in adr["election_cycles"]
            for adr in response["adrs"]
        )

        self.check_incorrect_values({"case_election_cycles": "abc"}, None, True)

    def test_case_date_filters(self):
        # for archived murs, current murs, and adrs
        open_date = "2020-10-01"
        query_date = datetime.strptime(open_date, "%Y-%m-%d")

        response = self._results_adr_mur(api.url_for(UniversalSearch, case_min_open_date=open_date))
        # logging.info(response)

        assert all(
            datetime.strptime(mur["open_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for mur in response["murs"]
        ) and all(
            datetime.strptime(adr["open_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for adr in response["adrs"]
        )

        response = self._results_adr_mur(api.url_for(UniversalSearch, case_max_open_date=open_date))
        # logging.info(response)

        assert all(
            datetime.strptime(mur["open_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for mur in response["murs"]
        ) and all(
            datetime.strptime(adr["open_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for adr in response["adrs"]
        )

        close_date = "2022-11-29"
        query_date = datetime.strptime(close_date, "%Y-%m-%d")

        response = self._results_adr_mur(api.url_for(UniversalSearch, case_min_close_date=close_date))
        # logging.info(response)

        assert all(
            datetime.strptime(mur["close_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for mur in response["murs"]
        ) and all(
            datetime.strptime(adr["close_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for adr in response["adrs"]
        )

        response = self._results_adr_mur(api.url_for(UniversalSearch, case_max_close_date=close_date))
        # logging.info(response)

        assert all(
            datetime.strptime(mur["close_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for mur in response["murs"]
        ) and all(
            datetime.strptime(adr["close_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for adr in response["adrs"]
        )

        filters = ["case_min_close_date", "case_max_close_date", "case_min_open_date", "case_max_open_date"]

        for filter in filters:
            self.check_incorrect_values({filter: self.wrong_date_format}, None, True)

    def test_subject_id(self):
        # for current murs and adrs
        primary = ["3", "16", "19"]
        secondary = ["13", "15"]

        response = self._results_adr_mur(api.url_for(UniversalSearch, primary_subject_id=primary))
        # logging.info(response)

        assert all(
            mur["mur_type"] == "current" and any(
                subject["primary_subject_id"] in primary
                for subject in mur["subjects"]
            )
            for mur in response["murs"]
        ) and (any(
            subject["primary_subject_id"] in primary
            for subject in adr["subjects"]
        )
            for adr in response["adrs"]
        )

        response = self._results_adr_mur(api.url_for(UniversalSearch, secondary_subject_id=secondary))
        # logging.info(response)

        assert all(
            mur["mur_type"] == "current" and any(
                subject["secondary_subject_id"] in secondary
                for subject in mur["subjects"]
            )
            for mur in response["murs"]
        ) and all(any(
            subject["secondary_subject_id"] in secondary
            for subject in adr["subjects"]
        )
            for adr in response["adrs"]
        )

        filters = ["primary_subject_id", "secondary_subject_id"]

        for filter in filters:
            self.check_incorrect_values({filter: "555"}, None, True)

    def test_case_respondents(self):
        #  archived and current murs, and adrs
        respondents = ["John", "Jayme", "Naolitano"]

        for respondent in respondents:
            response = self._results_adr_mur(api.url_for(UniversalSearch, case_respondents=respondent))
            # logging.info(response)
            assert all(any(respondent in rsp
                           for rsp in mur["respondents"])
                       for mur in response["murs"]
                       ) and all(any(respondent in rsp
                                     for rsp in adr["respondents"]
                                     ) for adr in response["adrs"])

        self.check_incorrect_values({"case_respondents": "Bad value"}, "total_murs", False)
        self.check_incorrect_values({"case_respondents": "Bad value"}, "total_adrs", False)

    def test_citation_filters(self):
        # filter for current murs and adrs
        statutory_title = "52"
        statutory_text = "30116"
        regulatory_title = "11"
        regulatory_text = "104.3"
        stat_citation = "{} U.S.C. §{}".format(statutory_title, statutory_text)
        reg_citation = "{} CFR §{}".format(regulatory_title, regulatory_text)

        response = self._results_adr_mur(api.url_for(UniversalSearch,
                                                     case_statutory_citation=stat_citation,
                                                     case_regulatory_citation=reg_citation))
        # logging.info(response)

        for source in [response["murs"], response["adrs"]]:
            for item in source:
                found = any(
                    (citations["title"] == statutory_title and statutory_text in citations["text"]) or
                    (citations["title"] == regulatory_title and regulatory_text in citations["text"])
                    for dispositions in item["dispositions"]
                    for citations in dispositions["citations"]
                )
                assert found

        response = self._results_adr_mur(api.url_for(UniversalSearch,
                                                     case_statutory_citation=stat_citation,
                                                     case_regulatory_citation=reg_citation,
                                                     case_citation_require_all="true"))
        # logging.info(response)

        for source in [response["murs"], response["adrs"]]:
            for item in source:

                statutory_found = any(
                    citations["title"] == statutory_title and statutory_text in citations["text"]
                    for dispositions in item["dispositions"]
                    for citations in dispositions["citations"]
                )

                regulatory_found = any(
                    citations["title"] == regulatory_title and regulatory_text in citations["text"]
                    for dispositions in item["dispositions"]
                    for citations in dispositions["citations"]
                )

                assert statutory_found and regulatory_found

        filters = [
            ["case_statutory_citation", "524 U.S.C. §30106444"],
            ["case_regulatory_citation", "1111 CFR §112.4111"]
        ]
        for filter in filters:
            self.check_incorrect_values({filter[0]: filter[1]}, "total_murs", False)
            self.check_incorrect_values({filter[0]: filter[1]}, "total_adrs", False)

# ---------------------- End MUR and ADR filters ------------------------------------------------
# ---------------------- Start MUR  filters ------------------------------------------------
    def test_mur_type_filter(self):
        filters = [
            [{"mur_type": "current"}, "mur_type", True],
            [{"mur_type": "archived"}, "mur_type", True]
        ]

        for filter in filters:
            self.check_filters(filter[0], filter[1], "murs")
            self.check_incorrect_values({"mur_type": "wrongType"}, "total_murs", filter[2])

    def test_mur_disposition_filter(self):
        # filter for current murs
        categories = ["7", "24"]
        response = self._results_mur(api.url_for(UniversalSearch, mur_disposition_category_id=categories))
        # logging.info(response)

        assert all(
            mur["mur_type"] == "current" and any(
                dispositions["mur_disposition_category_id"] in categories
                for dispositions in mur["dispositions"]
            )
            for mur in response["murs"]
        )

        category = "14"
        response = self._results_mur(api.url_for(UniversalSearch, mur_disposition_category_id=category))
        # logging.info(response)

        assert all(
            mur["mur_type"] == "current" and any(
                category == dispositions["mur_disposition_category_id"]
                for dispositions in mur["dispositions"]
            )
            for mur in response["murs"]
        )
        self.check_incorrect_values({"mur_disposition_category_id": "49"}, "total_murs", True)

# ---------------------- End MUR  filters ------------------------------------------------
# ---------------------- Start AF  filters ------------------------------------------------
    def test_af_name_multiple_filter(self):
        names_list = ["ICE PAC", "SOCIAL PROGRESS IN UNION WITH ECONOMIC GROWTH"]
        response = self._results_af(api.url_for(UniversalSearch, af_name=names_list))
        # logging.info(response)

        assert all(
            af["name"] in names_list
            for af in response["admin_fines"]
        )

    def test_af_filters(self):
        filters = [
            [{"af_name": "ICE PAC"}, "name", False],
            [{"af_committee_id": "C00833665"}, "committee_id", True],
            [{"af_report_year": "2014"}, "report_year", False],
            [{"af_rtb_fine_amount": 3300}, "reason_to_believe_fine_amount", True],
            [{"af_fd_fine_amount": 3300}, "final_determination_amount", True]
        ]

        for filter in filters:
            self.check_filters(filter[0], filter[1], "admin_fines")
            self.check_incorrect_values({list(filter[0].keys())[0]: "Incorrect"}, "total_admin_fines", filter[2])

    def test_af_date_filters(self):
        rtb = "2017-10-01"
        query_date = datetime.strptime(rtb, "%Y-%m-%d")

        response = self._results_af(api.url_for(UniversalSearch, af_min_rtb_date=rtb))
        # logging.info(response)

        assert all(
            datetime.strptime(af["reason_to_believe_action_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for af in response["admin_fines"]
        )

        response = self._results_af(api.url_for(UniversalSearch, af_max_rtb_date=rtb))
        # logging.info(response)

        assert all(
            datetime.strptime(af["reason_to_believe_action_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for af in response["admin_fines"]
        )

        fd_date = "2024-08-13"
        query_date = datetime.strptime(fd_date, "%Y-%m-%d")

        response = self._results_af(api.url_for(UniversalSearch, af_min_fd_date=fd_date))
        # logging.info(response)

        assert all(
            datetime.strptime(af["final_determination_date"], "%Y-%m-%dT%H:%M:%S") >= query_date
            for af in response["admin_fines"]
        )

        response = self._results_af(api.url_for(UniversalSearch, af_max_fd_date=fd_date))
        # logging.info(response)

        assert all(
            datetime.strptime(af["final_determination_date"], "%Y-%m-%dT%H:%M:%S") <= query_date
            for af in response["admin_fines"]
        )
        filters = ["af_min_rtb_date", "af_max_rtb_date", "af_min_fd_date", "af_max_fd_date"]

        for filter in filters:
            self.check_incorrect_values({filter: self.wrong_date_format}, None, True)
# ---------------------- End AF filters ------------------------------------------------
