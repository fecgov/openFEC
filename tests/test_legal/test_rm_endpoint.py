from tests.common import ElasticSearchBaseTest, rm_document_dictionary
from webservices.resources.rulemaking import RulemakingSearch
from webservices.api_setup import api
from datetime import datetime
from webservices.legal.constants import TEST_RM_SEARCH_ALIAS

import unittest.mock as mock
# import logging


@mock.patch("webservices.resources.rulemaking.RM_SEARCH_ALIAS", TEST_RM_SEARCH_ALIAS)
class TestRuleMakingDocsElasticsearch(ElasticSearchBaseTest):
    wrong_date_format = "01/20/24"

    def check_filters(self, params, field_name, multiple):
        response = self._results_rm(api.url_for(RulemakingSearch, **params))
        filter_value = list(params.values())[0]
        # logging.info(response)
        # logging.info(params)

        # Normalize the filter value to a list so we can check integers
        if isinstance(filter_value, (list, tuple)):
            expected_values = filter_value
        else:
            expected_values = [filter_value]

        if multiple:
            assert all(x[field_name] in expected_values for x in response)
        else:
            assert all(x[field_name] == expected_values[0] for x in response)

    def check_incorrect_values(self, params, raiseError):
        response = self.app.get(api.url_for(RulemakingSearch, **params))
        # logging.info(response.json)

        if raiseError:
            assert response.status_code == 422
        else:
            assert response.status_code == 200
            assert response.json["total_rulemakings"] == 0

    def test_docs(self):
        response = self._results_rm(api.url_for(RulemakingSearch))
        # logging.info(response)

        self.assertEqual(len(response), len(rm_document_dictionary["rulemakings"]))

    def test_rulemaking_filters(self):
        filters = [
            [{"rm_no": "2024-10"}, "rm_no", False, False],
            [{"rm_no": ["2024-10", "2024-08",]}, "rm_no", True, False],
            [{"rm_name": "Form 3Z"}, "rm_name", False, False],
            # [{"rm_name":
            #  ["\"Amendments of Rules Regarding Contributions from Untraceable Electronic Payment Methods\"",
            #   "Form 3Z"]}, "rm_name", True, False],
            [{"is_open_for_comment": True}, "is_open_for_comment", False, True],
            [{"rm_year": 2022}, "rm_year", True, True],
        ]

        for filter in filters:
            self.check_filters(filter[0], filter[1], filter[2])
            self.check_incorrect_values({list(filter[0].keys())[0]: "Incorrect"}, filter[3])

    def test_sort(self):
        sort = "rm_no"
        response = self._results_rm(api.url_for(RulemakingSearch, sort=sort))

        self.assertEqual(response[0]["rm_no"], "2022-06")
        self.assertEqual(response[1]["rm_no"], "2024-04")
        self.assertEqual(response[2]["rm_no"], "2024-08")
        self.assertEqual(response[3]["rm_no"], "2024-10")

        sort = "-rm_no"
        response = self._results_rm(api.url_for(RulemakingSearch, sort=sort))

        self.assertEqual(response[0]["rm_no"], "2024-10")
        self.assertEqual(response[1]["rm_no"], "2024-08")
        self.assertEqual(response[2]["rm_no"], "2024-04")
        self.assertEqual(response[3]["rm_no"], "2022-06")

    def test_is_key_document_filter(self):
        is_key_document = True
        response = self._results_rm(api.url_for(RulemakingSearch, is_key_document=is_key_document))
        assert all(rulemaking["key_documents"] for rulemaking in response)

        self.check_incorrect_values({"is_key_document": "IncorrectValue"}, True)

    def test_filename_filter(self):
        level_one_filename = "NOA"
        response = self._results_rm(api.url_for(RulemakingSearch, filename=level_one_filename))

        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]["rm_no"], "2024-08")

        level_two_filename = "REG 2024-04"
        response = self._results_rm(api.url_for(RulemakingSearch, filename=level_two_filename))

        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]["rm_no"], "2024-04")

        self.check_incorrect_values({"filename": "IncorrectValue"}, False)

    def test_entity_filters(self):
        entity_role_type = 4
        entity_role_type_list = [4, 5]
        response = self._results_rm(api.url_for(RulemakingSearch, entity_role_type=entity_role_type))

        self.assertEqual(len(response), 2)
        assert all(
            any(entity.get("role") == "Officer/Representative" for entity in rulemaking.get("rm_entities", []))
            for rulemaking in response
        )

        response = self._results_rm(api.url_for(RulemakingSearch, entity_role_type=entity_role_type_list))

        self.assertEqual(len(response), 3)
        assert all(
            any(
                entity.get("role") in
                ("Commenter", "Officer/Representative") for entity in rulemaking.get("rm_entities", []))
            for rulemaking in response
        )

        self.check_incorrect_values({"entity_role_type": "IncorrectValue"}, True)

        entity_name = "Junkin"

        response = self._results_rm(api.url_for(RulemakingSearch, entity_name=entity_name))

        self.assertEqual(len(response), 1)
        assert all(
            any(entity_name.lower() in entity.get("name", "").lower() for entity in rulemaking.get("rm_entities", []))
            for rulemaking in response
        )

        self.check_incorrect_values({"entity_name": "IncorrectValue"}, False)

    def check_date(self, rulemaking_column, query_date, response, is_min):
        if is_min:
            assert all(
                any(
                    datetime.strptime(date_str, "%Y-%m-%d") >= query_date
                    for date_str in rulemaking.get(rulemaking_column, [])
                )
                for rulemaking in response
            )
        else:
            assert all(
                any(
                    datetime.strptime(date_str, "%Y-%m-%d") <= query_date
                    for date_str in rulemaking.get(rulemaking_column, [])
                )
                for rulemaking in response
            )

    def test_fed_registry_date_filter(self):
        federal_registry_publish_date = "2023-02-22"
        query_date = datetime.strptime(federal_registry_publish_date, "%Y-%m-%d")

        response = self._results_rm(
            api.url_for(RulemakingSearch, min_federal_registry_publish_date=federal_registry_publish_date))
        # logging.info(response)

        self.assertEqual(len(response), 3)
        self.check_date("fr_publication_dates", query_date, response, True)

        response = self._results_rm(
            api.url_for(RulemakingSearch, max_federal_registry_publish_date=federal_registry_publish_date))
        # logging.info(response)

        self.assertEqual(len(response), 1)
        self.check_date("fr_publication_dates", query_date, response, False)

        filters = ["min_federal_registry_publish_date", "max_federal_registry_publish_date"]

        for filter in filters:
            self.check_incorrect_values({filter: self.wrong_date_format}, True)

    def test_hearing_date_filter(self):
        hearing_date = "2024-11-15"
        query_date = datetime.strptime(hearing_date, "%Y-%m-%d")

        response = self._results_rm(
            api.url_for(RulemakingSearch, min_hearing_date=hearing_date))
        # logging.info(response)

        self.assertEqual(len(response), 1)
        self.check_date("hearing_dates", query_date, response, True)

        response = self._results_rm(
            api.url_for(RulemakingSearch, max_hearing_date=hearing_date))
        # logging.info(response)

        self.assertEqual(len(response), 2)
        self.check_date("hearing_dates", query_date, response, False)

        filters = ["min_hearing_date", "max_hearing_date"]

        for filter in filters:
            self.check_incorrect_values({filter: self.wrong_date_format}, True)

    def test_vote_date_filter(self):
        vote_date = "2022-12-20"
        query_date = datetime.strptime(vote_date, "%Y-%m-%d")

        response = self._results_rm(
            api.url_for(RulemakingSearch, min_vote_date=vote_date))
        # logging.info(response)

        self.assertEqual(len(response), 3)
        self.check_date("vote_dates", query_date, response, True)

        response = self._results_rm(
            api.url_for(RulemakingSearch, max_vote_date=vote_date))
        # logging.info(response)

        self.assertEqual(len(response), 1)
        self.check_date("vote_dates", query_date, response, False)

        filters = ["min_vote_date", "max_vote_date"]

        for filter in filters:
            self.check_incorrect_values({filter: self.wrong_date_format}, True)

    def test_doc_category_id_filter(self):
        category_lvl_one = 6
        response = self._results_rm(api.url_for(RulemakingSearch, doc_category_id=category_lvl_one))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]["rm_no"], "2024-08")
        self.assertEqual(response[1]["rm_no"], "2022-06")

        category_lvl_one_list = [4, 6]
        response = self._results_rm(api.url_for(RulemakingSearch, doc_category_id=category_lvl_one_list))
        self.assertEqual(len(response), 4)

        category_lvl_two = 5
        response = self._results_rm(api.url_for(RulemakingSearch, doc_category_id=category_lvl_two))
        self.assertEqual(len(response), 3)
        self.assertEqual(response[0]["rm_no"], "2024-08")
        self.assertEqual(response[1]["rm_no"], "2024-04")
        self.assertEqual(response[2]["rm_no"], "2022-06")

        category_lvl_two_list = [5, 7]
        response = self._results_rm(api.url_for(RulemakingSearch, doc_category_id=category_lvl_two_list))
        self.assertEqual(len(response), 4)

        self.check_incorrect_values({"doc_category_id": "IncorrectValue"}, True)

    def test_q_filter(self):
        q_lvl_one = "level1test"
        response = self._results_rm(api.url_for(RulemakingSearch, q=q_lvl_one))
        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]["rm_no"], "2024-10")

        q_lvl_two = "\"sixth lvl 2\""
        response = self._results_rm(api.url_for(RulemakingSearch, q=q_lvl_two))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]["rm_no"], "2024-08")
        self.assertEqual(response[1]["rm_no"], "2022-06")

        q_description = "\"Form 3Z\""
        response = self._results_rm(api.url_for(RulemakingSearch, q=q_description))
        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]["rm_no"], "2024-04")

        self.check_incorrect_values({"q": "IncorrectValue"}, False)

    def test_q_prox_filter(self):
        q_prox_lvl_one = ["Fourth RM", "lvl1"]
        max_gaps = 2

        response = self._results_rm(api.url_for(RulemakingSearch,
                                                q_proximity=q_prox_lvl_one,
                                                proximity_preserve_order=True,
                                                max_gaps=max_gaps))
        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]["rm_no"], "2022-06")

        q_prox_lvl_two = ["fourth lvl 2", "Second RM"]
        max_gaps = 3

        response = self._results_rm(api.url_for(RulemakingSearch,
                                                q_proximity=q_prox_lvl_two,
                                                proximity_preserve_order=False,
                                                max_gaps=max_gaps))
        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]["rm_no"], "2024-08")

        q_prox_description = "RM lvl 2"
        proximity_filter = "before"
        proximity_filter_term = "First"
        max_gaps = 3

        response = self._results_rm(api.url_for(RulemakingSearch,
                                                q_proximity=q_prox_description,
                                                proximity_filter=proximity_filter,
                                                proximity_filter_term=proximity_filter_term,
                                                max_gaps=max_gaps))
        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]["rm_no"], "2024-10")

        self.check_incorrect_values({"q_proximity": "Incorrect value", "max_gaps": 1}, False)

    def test_all_nested_filters_together(self):
        q = "\"REG 2024-10 Civil Monetary\""
        q_proximity = ["First RM", "first lvl 2"]
        max_gaps = 3
        doc_category_id = 7
        is_key_document = False
        entity_name = "Fake"
        entity_role = 2

        response = self._results_rm(api.url_for(RulemakingSearch,
                                                q=q,
                                                q_proximity=q_proximity,
                                                max_gaps=max_gaps,
                                                doc_category_id=doc_category_id,
                                                is_key_document=is_key_document,
                                                entity_name=entity_name,
                                                entity_role_type=entity_role))

        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]["rm_no"], "2024-10")
