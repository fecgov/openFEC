# import datetime
import subprocess
# from unittest.mock import patch

import pytest
from tests.common import TEST_CONN, BaseTestCase
import datetime
from webservices.common.models import db
from sqlalchemy import text
from webservices.legal.rulemaking_docs.rulemaking import sort_documents_tier_one
from webservices.legal.rulemaking_docs.rulemaking import get_rulemaking

EMPTY_SET = set()


# Test get_rulemaking(specific_rm_no) function in webservices.rulemaking_docs.rulemaking.py
@pytest.mark.usefixtures("migrate_db")
class TestGetRulemaking(BaseTestCase):
    def setUp(self):
        self.connection = db.engine.connect()
        subprocess.check_call(
            ["psql", TEST_CONN, "-f", "data/load_base_rulemaking_data.sql"]
        )

    def tearDown(self):
        self.clear_test_data()
        self.connection.close()
        db.session.remove()

    def test_simple_rm(self):
        expected_rm = {
            "admin_close_date": datetime.datetime(1999, 9, 24, 23, 59, 59),
            "calculated_comment_close_date": datetime.datetime(1999, 9, 24, 23, 59, 59),
            "comment_close_date": datetime.datetime(1999, 9, 24, 23, 59, 59),
            "commenter_names": [],
            "counsel_names": [],
            "description": "rm description",
            "documents": [],
            "fr_publication_dates": [],
            "hearing_dates": [],
            "is_open_for_comment": False,
            "key_documents": [],
            "last_updated": None,
            "no_tier_documents": [],
            "petitioner_names": [],
            "published_flg": True,
            "representative_names": [],
            "rm_entities": [],
            "rm_id": 11,
            "rm_name": "rm name",
            "rm_no": "2000-01",
            "rm_number": "REG 2000-01",
            "rm_serial": 1,
            "rm_year": 2000,
            "sort1": -2000,
            "sort2": -1,
            "sync_status": "UPTODATE",
            "testify_flg": False,
            "title": "REG 2000-01 rm name",
            "type": "rulemakings",
            "vote_dates": [],
            "witness_names": []
        }

        self.create_rm(expected_rm)
        actual_rm = next(get_rulemaking(None))
        assert actual_rm == expected_rm

    def create_rm(self, rm):
        self.connection.execute(
            text(
                """INSERT INTO fosers.rulemaster (id, rm_number, title, description,
                comment_close_date, admin_close_date, sync_status, published_flg, testify_flg)
                VALUES (:id, :rm_number, :title, :description, :comment_close_date,
                :admin_close_date, :sync_status, :published_flg, :testify_flg)"""),
            {
                "id": rm["rm_id"],
                "rm_number": rm["rm_number"],
                "title": rm["title"],
                "description": rm["description"],
                "comment_close_date": rm["comment_close_date"],
                "admin_close_date": rm["admin_close_date"],
                "sync_status": rm["sync_status"],
                "published_flg": rm["published_flg"],
                "testify_flg": rm["testify_flg"]
            }
        )
        self.connection.commit()

    def test_rm_sort(self):
        documents = [
            {
                "doc_date": datetime.date(2026, 3, 17),
                "level_1": 10,
                "doc_id": 7
            },
            {
                "doc_date": None,
                "level_1": 3,
                "doc_id": 8,
                "level_2_labels": [
                    {
                        "level_2_docs": [
                            {"doc_date": datetime.date(2024, 12, 19)},
                            {"doc_date": datetime.date(2026, 3, 17)},
                            {"doc_date": None}
                        ]
                    }
                ]
            },
            {
                "doc_date": None,
                "level_1": 15,
                "doc_id": 9,
                "level_2_labels": [
                    {
                        "level_2_docs": [
                            {"doc_date": None},
                            {"doc_date": None}
                        ]
                    }
                ]
            }
        ]
        sort_documents_tier_one(documents)
        self.assertEqual(documents[0]["doc_id"], 9)
        self.assertEqual(documents[1]["doc_id"], 8)
        self.assertEqual(documents[2]["doc_id"], 7)

    # @patch("webservices.legal.legal_docs.advisory_opinions.get_bucket")
    # def test_rm_documents(self, get_bucket):
    # def test_rm_documents(self):

    #     expected_documents = [
    #     {
    #         "doc_admin_close_date": None,
    #         "doc_calc_comment_close_date": None,
    #         "doc_category_id": 4,
    #         "doc_category_label": "Federal Register Document",
    #         "doc_comment_close_date": None,
    #         "doc_date": datetime.date(2024, 11, 26),
    #         "doc_description": "NOA.pdf",
    #         "doc_entities": [],
    #         "doc_id": 425629,
    #         "doc_type_id": 66,
    #         "doc_type_label": "Notice of Availability",
    #         "filename": "NOA",
    #         "is_comment_eligible": False,
    #         "is_key_document": False,
    #         "level_1": 14,
    #         "level_1_label": "Notice of Availability",
    #         "level_2": 0,
    #         "level_2_label": "Notice of Availability",
    #         "level_2_labels": [
    #             {
    #                 "level_2": 1,
    #                 "level_2_docs": [
    #                     {
    #                         "doc_admin_close_date": None,
    #                         "doc_calc_comment_close_date": None,
    #                         "doc_category_id": 7,
    #                         "doc_category_label": "Votes",
    #                         "doc_comment_close_date": None,
    #                         "doc_date": "2024-11-13",
    #                         "doc_description": "REG 2024-08 (Untraceable Electronic Payment Methods).pdf",
    #                         "doc_entities": [],
    #                         "doc_id": 425609,
    #                         "doc_type_id": 44,
    #                         "doc_type_label": "Vote to approve",
    #                         "filename": "REG 2024-08 (Untraceable Electronic Payment Methods)",
    #                         "is_comment_eligible": False,
    #                         "is_key_document": False,
    #                         "level_1": 14,
    #                         "level_1_label": "Notice of Availability",
    #                         "level_2": 1,
    #                         "level_2_label": "Open Meeting Documents",
    #                         "sort_order": 0,
    #                         "url": "/files/legal/rulemakings/2024-08/425609/
    #                           REG-2024-08-(Untraceable-Electronic-Payment-Methods).pdf"
    #                     },
    #                     {
    #                         "doc_admin_close_date": None,
    #                         "doc_calc_comment_close_date": None,
    #                         "doc_category_id": 3,
    #                         "doc_category_label": "Agenda Document",
    #                         "doc_comment_close_date": None,
    #                         "doc_date": "2024-11-14",
    #                         "doc_description": "REG 2024-08 (Untraceable Electronic Payment Methods) Draft NOA.pdf",
    #                         "doc_entities": [],
    #                         "doc_id": 425595,
    #                         "doc_type_id": 27,
    #                         "doc_type_label": "Draft Notice of Availability",
    #                         "filename": "REG 2024-08 (Untraceable Electronic Payment Methods) Draft NOA",
    #                         "is_comment_eligible": False,
    #                         "is_key_document": False,
    #                         "level_1": 14,
    #                         "level_1_label": "Notice of Availability",
    #                         "level_2": 1,
    #                         "level_2_label": "Open Meeting Documents",
    #                         "sort_order": 0,
    #                         "url": "/files/legal/rulemakings/2024-08/425595/
    #                           REG-2024-08-(Untraceable-Electronic-Payment-Methods)-Draft-NOA.pdf"
    #                     }
    #                 ]
    #             },
    #             {
    #                 "level_2": 2,
    #                 "level_2_docs": [
    #                     {
    #                         "doc_admin_close_date": None,
    #                         "doc_calc_comment_close_date": None,
    #                         "doc_category_id": 5,
    #                         "doc_category_label": "Comments and Ex Parte Communications",
    #                         "doc_comment_close_date": None,
    #                         "doc_date": "2024-11-26",
    #                         "doc_description": "REG_2024_08_Jones_Tracey_11_26_2024_22_12_27_CommentText.pdf",
    #                         "doc_entities": [
    #                             {
    #                                 "name": "Jones, Tracey",
    #                                 "role": "Commenter"
    #                             }
    #                         ],
    #                         "doc_id": 425741,
    #                         "doc_type_id": 74,
    #                         "doc_type_label": "Comments",
    #                         "filename": "REG_2024_08_Jones_Tracey_11_26_2024_22_12_27_CommentText",
    #                         "is_comment_eligible": False,
    #                         "is_key_document": False,
    #                         "level_1": 14,
    #                         "level_1_label": "Notice of Availability",
    #                         "level_2": 2,
    #                         "level_2_label": "Comments",
    #                         "sort_order": 0,
    #                         "url": "/files/legal/rulemakings/2024-08/425741/
    #                           REG_2024_08_Jones_Tracey_11_26_2024_22_12_27_CommentText.pdf"
    #                     },
    #                 ]
    #             }
    #         ],
    #         "sort_order": 0,
    #         "url": "/files/legal/rulemakings/2024-08/425629/NOA.pdf"
    #     },
    #     {
    #         "doc_admin_close_date": None,
    #         "doc_calc_comment_close_date": None,
    #         "doc_category_id": 6,
    #         "doc_category_label": "Commencing Document",
    #         "doc_comment_close_date": None,
    #         "doc_date": "2024-10-22",
    #         "doc_description": "Rulemaking Petition",
    #         "doc_entities": [],
    #         "doc_id": 425690,
    #         "doc_type_id": 73,
    #         "doc_type_label": "Commencing Document",
    #         "filename": "OCR Rulemaking petition_Paxton (10.22.24)",
    #         "is_comment_eligible": False,
    #         "is_key_document": True,
    #         "level_1": 7,
    #         "level_1_label": "Commencing Document",
    #         "level_2": 0,
    #         "level_2_label": "Commencing Document",
    #         "level_2_labels": [],
    #         "sort_order": 0,
    #         "url": "/files/legal/rulemakings/2024-08/425690/OCR-Rulemaking-petition_Paxton-(10.22.24).pdf"
    #     }
    # ]

    #     self.create_ao(1, expected_ao)
    #     self.create_document(1, expected_document, filename)

    #     actual_ao = next(get_rulemaking(None))

    #     assert actual_ao["is_pending"] is False
    #     assert actual_ao["status"] == "Final"

    #     actual_document = actual_ao["documents"][0]
    #     for key in expected_document:
    #         assert actual_document[key] == expected_document[key]

    # @patch("webservices.legal.legal_docs.advisory_opinions.get_bucket")
    # @patch("webservices.legal.legal_docs.advisory_opinions.create_opensearch_client")
    # @patch("webservices.legal.legal_docs.opensearch_management.create_index")
    # def test_ao_citations(self, get_bucket, create_opensearch_client, create_index):
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

    def create_document(self, documents):
        self.connection.execute(
            text("""IINSERT INTO fosers.documents
            (id, rm_id, filename, category, description, contents, date1, is_key_document,
            type_id, sync_status, sort_order, comment_close_date, admin_close_date)
            VALUES (:id, :rm_id, :filename, :category, :description, :contents,
            :date1, :is_key_document, :type_id, :sync_status, :sort_order,
            :comment_close_date, :admin_close_date)"""),
            {
                "id": documents["rm_id"],
                "rm_id": documents["rm_number"],
                "title": documents["title"],
                "description": documents["description"],
                "comment_close_date": documents["comment_close_date"],
                "admin_close_date": documents["admin_close_date"],
                "sync_status": documents["sync_status"],
                "published_flg": documents["published_flg"],
                "testify_flg": documents["testify_flg"]
            }
        )
        self.connection.commit()

    def create_documents_ocrtext(self, documents_ocrtext):
        self.connection.execute(
            text("""
            INSERT INTO fosers.documents_ocrtext(id, ocrtext)VALUES (:id, :ocrtext)"""),
            {
                "id": documents_ocrtext["rm_id"],
                "ocrtext": documents_ocrtext["ocrtext"],
            }
        )
        self.connection.commit()

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

        tables = ["calendar", "commissioners", "documentplayers", "documents",
                  "participants", "rulemaster", "tiermapping", "votes", ]
        for table in tables:
            self.connection.execute(text("DELETE FROM fosers.{}".format(table)))
