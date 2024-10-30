from tests.common import ElasticSearchBaseTest
from webservices.resources.legal import UniversalSearch, requestor_types, categories
from webservices.rest import api
from datetime import datetime
# import logging


class TestAODocsElasticsearch(ElasticSearchBaseTest):
    wrong_date_format = "01/20/24"

    def check_filters(self, params, field_name, multiple):
        response = self._results_ao(api.url_for(UniversalSearch, **params))
        # logging.info(response)

        if multiple:
            assert all(x[field_name] in list(params.values())[0] for x in response)
        else:
            assert all(x[field_name] == list(params.values())[0] for x in response)

    def check_incorrect_values(self, params, raiseError):
        response = self.app.get(api.url_for(UniversalSearch, **params))
        # logging.info(response.json)

        if raiseError:
            assert response.status_code == 422
        else:
            assert response.status_code == 200
            assert response.json["total_advisory_opinions"] == 0

    def check_doc_filters(self, params, field_name, compare_values):
        response = self._results_ao(api.url_for(UniversalSearch, **params))
        # logging.info(response)

        assert all(any(
            doc[field_name] in compare_values
            for doc in ao["documents"])
            for ao in response)

    def test_ao_filters(self):
        filters = [
            [{"ao_no": "2014-19"}, "no", False, False],
            [{"ao_no": ["2014-22", "2024-12"]}, "no", True, False],
            [{"ao_name": "McCutcheon"}, "name", False, False],
            [{"ao_name": ["Fake Name", "ActBlue"]}, "name", True, False],
            [{"ao_is_pending": True}, "is_pending", False, True],
            [{"ao_status": "Final"}, "status", False, False],
        ]

        for filter in filters:
            self.check_filters(filter[0], filter[1], filter[2])
            self.check_incorrect_values({list(filter[0].keys())[0]: "Incorrect"}, filter[3])

    def test_ao_requestor_filter(self):
        requestor = "Jane Doe"
        response = self._results_ao(api.url_for(UniversalSearch, ao_requestor=requestor))
        # logging.info(response)

        assert all(requestor in doc["requestor_names"] for doc in response)
        self.check_incorrect_values({"ao_requestor": "Incorrect"}, False)

        types = [5, 15]
        requstor_type_full = [requestor_types[5], requestor_types[15]]
        response = self._results_ao(api.url_for(UniversalSearch, ao_requestor_type=types))
        # logging.info(response)

        assert all(any(requestor in requstor_type_full
                       for requestor in doc["requestor_types"])
                   for doc in response)

        type = 15
        response = self._results_ao(api.url_for(UniversalSearch, ao_requestor_type=type))
        # logging.info(response)

        assert all(requestor_types[type] in doc["requestor_types"] for doc in response)
        self.check_incorrect_values({"ao_requestor_type": 22}, True)

    def test_ao_entity_name_filter(self):
        entity_name = "Francis Beaver"
        response = self._results_ao(api.url_for(UniversalSearch, ao_entity_name=entity_name))
        # logging.info(response)

        assert all(entity_name in doc["commenter_names"] or entity_name in doc["representative_names"]
                   for doc in response)

        entity_names = ["Jake Brown", "Francis Beaver"]
        response = self._results_ao(api.url_for(UniversalSearch, ao_entity_name=entity_names))
        # logging.info(response)

        assert all(set(entity_names).intersection(doc["commenter_names"]) or set(entity_names).intersection(
            doc["representative_names"])
                   for doc in response)

        self.check_incorrect_values({"ao_entity_name": "Bad Value"}, False)

    def test_doc_cat_id_filter(self):
        ao_doc_cat_id = "C"
        self.check_doc_filters({"ao_doc_category_id": ao_doc_cat_id}, "ao_doc_category_id", ao_doc_cat_id)

        ao_doc_cat_ids = ["C", "V"]
        self.check_doc_filters({"ao_doc_category_id": ao_doc_cat_ids}, "ao_doc_category_id", ao_doc_cat_ids)

        self.check_incorrect_values({"ao_doc_category_id": "P"}, True)

    def test_ao_category_filter(self):
        ao_category = "W"
        self.check_doc_filters({"ao_category": ao_category}, "category", categories[ao_category])

        ao_categories = ["V", "D"]
        ao_categories_full = [categories["V"], categories["D"]]
        self.check_doc_filters({"ao_category": ao_categories}, "category", ao_categories_full)

        self.check_incorrect_values({"ao_category": "P"}, True)

    def test_ao_sort(self):
        sort = "-ao_no"
        response = self._results_ao(api.url_for(UniversalSearch, sort=sort))
        # logging.info(response)
        self.assertEqual(response[0]["ao_no"], "2024-12")

        sort = "ao_no"
        response = self._results_ao(api.url_for(UniversalSearch, sort=sort))
        # logging.info(response)
        self.assertEqual(response[0]["ao_no"], "2014-19")

    def test_q_filters(self):
        q = "fourth"
        response = self._results_ao(api.url_for(UniversalSearch, q=q))
        # logging.info(response)

        assert all(
            all(q in highlight
                for highlight in ao["highlights"])
            for ao in response
        )
        q_exclude = "Random"
        response = self._results_ao(api.url_for(UniversalSearch, q_exclude=q_exclude))
        # logging.info(response)

        self.assertEqual(len(response), 1)
        self.assertEqual(response[0]["ao_no"], "2014-19")

    def test_citation_filters(self):
        statutory_title = 52
        statutory_section = "30101"
        regulatory_title = 11
        regulatory_section = 3
        regulatory_part = 101
        stat_citation = "{} U.S.C. §{}".format(statutory_title, statutory_section)
        reg_citation = "{} CFR §{}.{}".format(regulatory_title, regulatory_part, regulatory_section)

        response = self._results_ao(api.url_for(UniversalSearch, ao_statutory_citation=stat_citation,
                                                ao_regulatory_citation=reg_citation))
        # logging.info(response)

        for ao in response:
            found = any(
                (citation["title"] == regulatory_title and citation["part"] == regulatory_part and
                 citation["section"] == regulatory_section)
                for citation in ao["regulatory_citations"]
            ) or any(
                (citation["title"] == statutory_title and citation["section"] == statutory_section)
                for citation in ao["statutory_citations"]
            )
            assert found

        response = self._results_ao(api.url_for(UniversalSearch, ao_statutory_citation=stat_citation,
                                                ao_regulatory_citation=reg_citation,
                                                ao_citation_require_all="true"))
        # logging.info(response)

        for ao in response:

            statutory_found = any(
                (citation["title"] == statutory_title and citation["section"] == statutory_section)
                for citation in ao["statutory_citations"]
            )

            regulatory_found = any(
                (citation["title"] == regulatory_title and citation["part"] == regulatory_part and
                 citation["section"] == regulatory_section)
                for citation in ao["regulatory_citations"]
            )
        assert statutory_found and regulatory_found

        filters = [
            ["ao_statutory_citation", "524 U.S.C. §30106444"],
            ["ao_regulatory_citation", "1111 CFR §112.4111"]
        ]
        for filter in filters:
            self.check_incorrect_values({filter[0]: filter[1]}, False)

    def check_date(self, ao_column, query_date, response, is_min):

        if is_min:
            assert all(
                datetime.strptime(ao[ao_column], "%Y-%m-%d") >= query_date
                for ao in response
            )
        else:
            assert all(
                datetime.strptime(ao[ao_column], "%Y-%m-%d") <= query_date
                for ao in response
            )

    def test_issue_date_filter(self):
        issue_date = "2020-01-01"
        query_date = datetime.strptime(issue_date, "%Y-%m-%d")

        response = self._results_ao(api.url_for(UniversalSearch, ao_min_issue_date=issue_date))
        # logging.info(response)
        self.check_date("issue_date", query_date, response, True)

        response = self._results_ao(api.url_for(UniversalSearch, ao_max_issue_date=issue_date))
        # logging.info(response)
        self.check_date("issue_date", query_date, response, False)

        filters = ["ao_min_issue_date", "ao_max_issue_date"]

        for filter in filters:
            self.check_incorrect_values({filter: self.wrong_date_format}, True)

    def test_request_date_filter(self):
        request_date = "2020-01-01"
        query_date = datetime.strptime(request_date, "%Y-%m-%d")

        response = self._results_ao(api.url_for(UniversalSearch, ao_min_request_date=request_date))
        # logging.info(response)
        self.check_date("request_date", query_date, response, True)

        response = self._results_ao(api.url_for(UniversalSearch, ao_max_request_date=request_date))
        # logging.info(response)
        self.check_date("request_date", query_date, response, False)

        filters = ["ao_min_request_date", "ao_max_request_date"]

        for filter in filters:
            self.check_incorrect_values({filter: self.wrong_date_format}, True)

    def test_doc_date_filter(self):
        document_date = "2022-12-01"
        query_date = datetime.strptime(document_date, "%Y-%m-%d")

        response = self._results_ao(api.url_for(UniversalSearch, ao_min_document_date=document_date))
        # logging.info(response)

        assert all(any(
                datetime.strptime(doc["date"], "%Y-%m-%dT%H:%M:%S") >= query_date
                for doc in ao["documents"])
            for ao in response
        )

        response = self._results_ao(api.url_for(UniversalSearch, ao_max_document_date=document_date))
        # logging.info(response)

        assert all(any(
                datetime.strptime(doc["date"], "%Y-%m-%dT%H:%M:%S") <= query_date
                for doc in ao["documents"])
            for ao in response
        )

        filters = ["ao_min_document_date", "ao_max_document_date",]

        for filter in filters:
            self.check_incorrect_values({filter: self.wrong_date_format}, True)
