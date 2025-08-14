# import datetime
import subprocess
# from unittest.mock import patch

import pytest
from tests.common import TEST_CONN, BaseTestCase

from webservices.common.models import db
from sqlalchemy import text
# from webservices.rulemaking_docs.rulemaking import get_rulemaking

EMPTY_SET = set()


# Test get_rulemaking(specific_rm_no) function in webservices.rulemaking_docs.rulemaking.py
@pytest.mark.usefixtures("migrate_db")
class TestGetRulemaking(BaseTestCase):
    def setUp(self):
        self.connection = db.engine.connect()
        subprocess.check_call(
            ["psql", TEST_CONN, "-f", "data/load_base_advisory_opinion_data.sql"]
        )

    def tearDown(self):
        self.clear_test_data()
        self.connection.close()
        db.session.remove()

    # def test_rulemaking_doc(self):
    #     expected_rm = {
    #         "id": 3177009,
    #         "rm_number": "REG 2021-01",
    #         "title": "REG 2021-01 Candidate Salaries",
    #         "description": "REG 2021-01 Candidate Salaries",
    #         "comment_close_date": "2023-03-29",
    #         "admin_close_date": None,
    #     }
    #     self.create_rm(3177009, expected_rm)
    #     actual_rm = next(get_rulemaking(None))

    #     assert actual_rm == expected_rm

    def create_rm(self, rm_id, rm):
        self.connection.execute(
            text(
                """INSERT INTO fosers.rulemaster (id, rm_number, title, description, comment_close_date,
                admin_close_date) VALUES (:rm, :rm_num, :title, :descr, :cc_date, :ac_date)"""),
            {
                "rm": rm_id,
                "rm_num": rm["rm_number"],
                "title": rm["title"],
                "descr": rm["description"],
                "cc_date": rm["comment_close_date"],
                "ac_date": rm["admin_close_date"]
            }
        )

    # @patch("webservices.legal.legal_docs.advisory_opinions.get_bucket")
    # @patch("webservices.legal.legal_docs.advisory_opinions.create_es_client")
    # @patch("webservices.legal.legal_docs.es_management.create_index")
    # def test_ao_with_entities(self, get_bucket, create_es_client, create_index):
    #     expected_requestor_names = [
    #         "The Manchurian Candidate",
    #         "Federation of Interstate Truckers",
    #     ]
    #     expected_requestor_types = [
    #         "Federal candidate/candidate committee/officeholder",
    #         "Labor Organization",
    #     ]
    #     expected_commenter_names = ["Tom Troll", "Harry Troll"]
    #     expected_representative_names = ["Dewey Cheetham and Howe LLC"]
    #     expected_ao = {
    #         "type": "advisory_opinions",
    #         "no": "2017-01",
    #         "doc_id": "advisory_opinions_2017-01",
    #         "name": "An AO name",
    #         "summary": "An AO summary",
    #         "request_date": datetime.date(2016, 6, 10),
    #         "issue_date": datetime.date(2016, 12, 15),
    #         "documents": [],
    #         "requestor_names": expected_requestor_names,
    #         "requestor_types": expected_requestor_types,
    #     }

    #     self.create_ao(1, expected_ao)
    #     for i, _ in enumerate(expected_requestor_names):
    #         self.create_requestor(
    #             1, i + 1, expected_requestor_names[i], expected_requestor_types[i]
    #         )
    #     offset = len(expected_requestor_names)
    #     for i, _ in enumerate(expected_commenter_names):
    #         self.create_commenter(1, i + offset + 1, expected_commenter_names[i])
    #     offset += len(expected_commenter_names)
    #     for i, _ in enumerate(expected_representative_names):
    #         self.create_representative(
    #             1, i + offset + 1, expected_representative_names[i]
    #         )

    #     actual_ao = next(get_rulemaking(None))

    #     assert set(actual_ao["requestor_names"]) == set(expected_requestor_names)
    #     assert set(actual_ao["requestor_types"]) == set(expected_requestor_types)
    #     assert set(actual_ao["commenter_names"]) == set(expected_commenter_names)
    #     assert set(actual_ao["representative_names"]) == set(
    #         expected_representative_names
    #     )

    # @patch("webservices.legal.legal_docs.advisory_opinions.get_bucket")
    # @patch("webservices.legal.legal_docs.advisory_opinions.create_es_client")
    # @patch("webservices.legal.legal_docs.es_management.create_index")
    # def test_ao_with_entity_individual(self, get_bucket, create_es_client, create_index):
    #     expected_entity = {
    #         "role": "Commenter",
    #         "name": "Mr Dan Becker MD",
    #         "type": "Individual",
    #     }
    #     expected_ao = {
    #         "type": "advisory_opinions",
    #         "no": "2017-01",
    #         "doc_id": "advisory_opinions_2017-01",
    #         "name": "An AO name",
    #         "summary": "An AO summary",
    #         "request_date": datetime.date(2016, 6, 10),
    #         "issue_date": datetime.date(2016, 12, 15),
    #         "documents": [],
    #         "requestor_names": [],
    #         "requestor_types": [],
    #         "entities": [expected_entity],
    #     }
    #     self.create_ao(1, expected_ao)
    #     self.create_entity_individual(1, 123, "", 15, 2, "Mr", "Dan", "Becker", "MD")

    #     actual_ao = next(get_rulemaking(None))
    #     assert actual_ao["entities"] == [
    #         {"role": "Commenter",
    #             "name": "Mr Dan Becker MD",
    #             "type": "Individual"}]

    # @patch("webservices.legal.legal_docs.advisory_opinions.get_bucket")
    # @patch("webservices.legal.legal_docs.advisory_opinions.create_es_client")
    # @patch("webservices.legal.legal_docs.es_management.create_index")
    # def test_completed_ao_with_docs(self, get_bucket, create_es_client, create_index):
    #     ao_no = "2017-01"
    #     filename = "Some File.pdf"
    #     expected_document = {
    #         "document_id": 1,
    #         "category": "Final Opinion",
    #         "text": "Some Text",
    #         "description": "Some Description",
    #         "date": datetime.datetime(2017, 2, 9, 0, 0),
    #         "url": "/files/legal/aos/{0}/{1}".format(ao_no, filename.replace(' ', '-')),
    #         "filename": filename[:-4]
    #     }
    #     expected_ao = {
    #         "no": ao_no,
    #         "name": "An AO name",
    #         "summary": "An AO summary",
    #         "request_date": datetime.date(2016, 6, 10),
    #         "issue_date": datetime.date(2016, 12, 15),
    #         "is_pending": True,
    #         "status": "Final",
    #         "documents": [expected_document],
    #     }
    #     self.create_ao(1, expected_ao)
    #     self.create_document(1, expected_document, filename)

    #     actual_ao = next(get_rulemaking(None))

    #     assert actual_ao["is_pending"] is False
    #     assert actual_ao["status"] == "Final"

    #     actual_document = actual_ao["documents"][0]
    #     for key in expected_document:
    #         assert actual_document[key] == expected_document[key]

    # @patch("webservices.legal.legal_docs.advisory_opinions.get_bucket")
    # @patch("webservices.legal.legal_docs.advisory_opinions.create_es_client")
    # @patch("webservices.legal.legal_docs.es_management.create_index")
    # def test_ao_citations(self, get_bucket, create_es_client, create_index):
    #     ao1_document = {
    #         "document_id": 1,
    #         "category": "Final Opinion",
    #         "text": "Not an AO reference 1776-01",
    #         "description": "Some Description",
    #         "date": datetime.datetime(2017, 2, 9, 0, 0),
    #     }
    #     ao1 = {
    #         "no": "2017-01",
    #         "doc_id": "advisory_opinions_2017-01",
    #         "name": "1st AO name",
    #         "summary": "1st AO summary",
    #         "status": "Final",
    #         "request_date": datetime.date(2016, 6, 10),
    #         "issue_date": datetime.date(2016, 12, 15),
    #         "documents": [ao1_document],
    #     }

    #     ao2_document = {
    #         "document_id": 2,
    #         "category": "Final Opinion",
    #         "text": "Reference to AO 2017-01",
    #         "description": "Some Description",
    #         "date": datetime.datetime(2017, 2, 9, 0, 0),
    #     }
    #     ao2 = {
    #         "no": "2017-02",
    #         "doc_id": "advisory_opinions_2017-02",
    #         "name": "2nd AO name",
    #         "summary": "2nd AO summary",
    #         "status": "Final",
    #         "request_date": datetime.date(2016, 6, 10),
    #         "issue_date": datetime.date(2016, 12, 15),
    #         "documents": [ao2_document],
    #     }

    #     self.create_ao(1, ao1)
    #     self.create_document(1, ao1_document)
    #     self.create_ao(2, ao2)
    #     self.create_document(2, ao2_document)

    #     actual_aos = [ao for ao in get_advisory_opinions(None)]
    #     assert len(actual_aos) == 2

    #     actual_ao1 = next(filter(lambda a: a["no"] == "2017-01", actual_aos))
    #     actual_ao2 = next(filter(lambda a: a["no"] == "2017-02", actual_aos))

    #     assert actual_ao1["ao_citations"] == []
    #     assert actual_ao1["aos_cited_by"] == [{"no": "2017-02", "name": "2nd AO name"}]

    #     assert actual_ao2["ao_citations"] == [{"no": "2017-01", "name": "1st AO name"}]
    #     assert actual_ao2["aos_cited_by"] == []

    # @patch("webservices.legal.legal_docs.advisory_opinions.get_bucket")
    # @patch("webservices.legal.legal_docs.advisory_opinions.create_es_client")
    # @patch("webservices.legal.legal_docs.es_management.create_index")
    # def test_ao_offsets(self, get_bucket, create_es_client, create_index):
    #     expected_ao1 = {
    #         "type": "advisory_opinions",
    #         "no": "2015-01",
    #         "ao_no": "2015-01",
    #         "ao_year": 2015,
    #         "ao_serial": 1,
    #         "doc_id": "advisory_opinions_2015-01",
    #         "name": "AO name1",
    #         "summary": "AO summary1",
    #         "request_date": datetime.date(2016, 6, 10),
    #         "issue_date": datetime.date(2016, 12, 15),
    #         "is_pending": True,
    #         "status": "Pending",
    #         "ao_citations": [],
    #         "statutory_citations": [],
    #         "regulatory_citations": [],
    #         "aos_cited_by": [],
    #         "documents": [],
    #         "requestor_names": [],
    #         "requestor_types": [],
    #         "commenter_names": [],
    #         "representative_names": [],
    #         "sort1": -2015,
    #         "sort2": -1,
    #         "entities": [],
    #     }
    #     expected_ao2 = {
    #         "type": "advisory_opinions",
    #         "no": "2015-02",
    #         "ao_no": "2015-02",
    #         "ao_year": 2015,
    #         "ao_serial": 2,
    #         "doc_id": "advisory_opinions_2015-02",
    #         "name": "An AO name2",
    #         "summary": "An AO summary2",
    #         "request_date": datetime.date(2016, 6, 10),
    #         "issue_date": datetime.date(2016, 12, 15),
    #         "is_pending": True,
    #         "status": "Pending",
    #         "ao_citations": [],
    #         "statutory_citations": [],
    #         "regulatory_citations": [],
    #         "aos_cited_by": [],
    #         "documents": [],
    #         "requestor_names": [],
    #         "requestor_types": [],
    #         "commenter_names": [],
    #         "representative_names": [],
    #         "sort1": -2015,
    #         "sort2": -2,
    #         "entities": [],
    #     }
    #     expected_ao3 = {
    #         "type": "advisory_opinions",
    #         "no": "2016-01",
    #         "ao_no": "2016-01",
    #         "ao_year": 2016,
    #         "ao_serial": 1,
    #         "doc_id": "advisory_opinions_2016-01",
    #         "name": "An AO name3",
    #         "summary": "An AO summary3",
    #         "request_date": datetime.date(2016, 6, 10),
    #         "issue_date": datetime.date(2016, 12, 15),
    #         "is_pending": True,
    #         "status": "Pending",
    #         "ao_citations": [],
    #         "statutory_citations": [],
    #         "regulatory_citations": [],
    #         "aos_cited_by": [],
    #         "documents": [],
    #         "requestor_names": [],
    #         "requestor_types": [],
    #         "commenter_names": [],
    #         "representative_names": [],
    #         "sort1": -2016,
    #         "sort2": -1,
    #         "entities": [],
    #     }
    #     self.create_ao(1, expected_ao1)
    #     self.create_ao(2, expected_ao2)
    #     self.create_ao(3, expected_ao3)

    #     gen = get_rulemaking(None)
    #     assert (next(gen)) == expected_ao3
    #     assert (next(gen)) == expected_ao2
    #     assert (next(gen)) == expected_ao1

    #     gen = get_rulemaking('2015-02')
    #     assert (next(gen)) == expected_ao3
    #     assert (next(gen)) == expected_ao2

    # def create_document(self, ao_id, document, filename='201801_C.pdf'):
    #     self.connection.execute(
    #         """
    #         INSERT INTO aouser.document
    #         (document_id, ao_id, category, ocrtext, fileimage, description, document_date, filename)
    #         VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""",
    #         document["document_id"],
    #         ao_id,
    #         document["category"],
    #         document["text"],
    #         document["text"],
    #         document["description"],
    #         document["date"],
    #         filename,
    #     )

    # def create_requestor(self, ao_id, entity_id, requestor_name, requestor_type):
    #     entity_type_id = self.connection.execute(
    #         "SELECT entity_type_id FROM aouser.entity_type " " WHERE description = %s ",
    #         requestor_type,
    #     ).scalar()

    #     self.create_entity(ao_id, entity_id, requestor_name, entity_type_id, 1)

    # def create_commenter(self, ao_id, entity_id, requestor_name):
    #     self.create_entity(ao_id, entity_id, requestor_name, 16, 2)

    # def create_representative(self, ao_id, entity_id, requestor_name):
    #     self.create_entity(ao_id, entity_id, requestor_name, 16, 3)

    # def create_entity(self, ao_id, entity_id, requestor_name, entity_type_id, role_id):
    #     self.connection.execute(
    #         """
    #         INSERT INTO aouser.entity
    #         (entity_id, name, type)
    #         VALUES (%s, %s, %s)""",
    #         entity_id,
    #         requestor_name,
    #         entity_type_id,
    #     )
    #     self.connection.execute(
    #         """
    #         INSERT INTO aouser.players
    #         (player_id, ao_id, entity_id, role_id)
    #         VALUES (%s, %s, %s, %s)""",
    #         entity_id,
    #         ao_id,
    #         entity_id,
    #         role_id,
    #     )

    # def create_entity_individual(self, ao_id, entity_id, requestor_name, entity_type_id,
    #                              role_id, prefix, first_name, last_name, suffix):
    #     self.connection.execute(
    #         """
    #         INSERT INTO aouser.entity
    #         (prefix, first_name, last_name, suffix, entity_id, name, type)
    #         VALUES (%s, %s, %s, %s, %s, %s, %s)""",
    #         prefix,
    #         first_name,
    #         last_name,
    #         suffix,
    #         entity_id,
    #         requestor_name,
    #         entity_type_id,
    #     )
    #     self.connection.execute(
    #         """
    #         INSERT INTO aouser.players
    #         (player_id, ao_id, entity_id, role_id)
    #         VALUES (%s, %s, %s, %s)""",
    #         entity_id,
    #         ao_id,
    #         entity_id,
    #         role_id,
    #     )

    def clear_test_data(self):
        # tables = ["calendar", "commissioners", "documentplayers", "documents",
        #           "participants", "rulemaster", "tiermapping", "votes", ]
        tables = ["rulemaster"]
        for table in tables:
            self.connection.execute(text("DELETE FROM fosers.{}".format(table)))
