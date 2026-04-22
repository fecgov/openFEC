import subprocess
from unittest.mock import patch
import psycopg2
import pytest
from tests.common import TEST_CONN, BaseTestCase
import datetime
from webservices.common.models import db
from sqlalchemy import text
from webservices.legal.rulemaking_docs.rulemaking import sort_documents_tier_one
from webservices.legal.rulemaking_docs.rulemaking import get_rulemaking, get_documents

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
            "admin_close_date": None,
            "calculated_comment_close_date": datetime.datetime(2025, 1, 27, 23, 59, 59),
            "comment_close_date": datetime.datetime(2025, 1, 27, 23, 59, 59),
            "commenter_names": [],
            "counsel_names": [],
            "description": "REG 2024-08 Amendments of Rules",
            "documents": [],
            "fr_publication_dates": [datetime.date(2025, 1, 27)],
            "hearing_dates": [],
            "is_open_for_comment": False,
            "key_documents": [],
            "last_updated": None,
            "no_tier_documents": [],
            "petitioner_names": [],
            "published_flg": True,
            "representative_names": [],
            "rm_entities": [],
            "rm_id": 3472947,
            "rm_name": "Amendments of Rules",
            "rm_no": "2024-08",
            "rm_number": "REG 2024-08",
            "rm_serial": 8,
            "rm_year": 2024,
            "sort1": -2024,
            "sort2": -8,
            "sync_status": "UPTODATE",
            "testify_flg": None,
            "title": "REG 2024-08 Amendments of Rules",
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

    @patch("webservices.legal.rulemaking_docs.rulemaking.get_bucket")
    def test_rm_documents(self, get_bucket):
        # 1)Test the get_documents(rm_no, rm_id, bucket) function
        # in webservices/legal/rulemaking_docs/rulemaking.py.
        # 2)For the filename field:
        # In the table, filenames are stored as xxxxx.pdf.
        # In the output, they should appear as xxxxx (without the file extension).
        # in rulemaking.py (line 551) to remove the extension:filename = row["filename"][:-4]
        # 3)For the content field:
        # It should be uploaded to S3 only and not in the expected output object.
        expected_level_2_docs_1 = [
            {
                "doc_admin_close_date": None,
                "doc_calc_comment_close_date": None,
                "doc_category_id": 7,
                "doc_category_label": "Votes",
                "doc_comment_close_date": None,
                "doc_date": datetime.date(2024, 11, 13),
                "doc_description": "REG 2024-08 (Electronic).pdf",
                "doc_entities": [],
                "doc_id": 425609,
                "doc_type_id": 44,
                "doc_type_label": "Vote to approve",
                "filename": "REG 2024-08 (Electronic)",
                "is_comment_eligible": False,
                "is_key_document": False,
                "level_1": 14,
                "level_1_label": "Notice of Availability",
                "level_2": 1,
                "level_2_label": "Open Meeting Documents",
                "sort_order": 0,
                'text': 'level 2 document1',
                "url": "/files/legal/rulemakings/2024-08/425609/REG-2024-08-(Electronic).pdf",
            },
            {
                "doc_admin_close_date": None,
                "doc_calc_comment_close_date": None,
                "doc_category_id": 3,
                "doc_category_label": "Agenda Document",
                "doc_comment_close_date": None,
                "doc_date": datetime.date(2024, 11, 14),
                "doc_description": "REG 2024-08 (Untraceable Electronic).pdf",
                "doc_entities": [],
                "doc_id": 425595,
                "doc_type_id": 27,
                "doc_type_label": "Draft Notice of Availability",
                "filename": "REG 2024-08 (Untraceable Electronic)",
                "is_comment_eligible": False,
                "is_key_document": False,
                "level_1": 14,
                "level_1_label": "Notice of Availability",
                "level_2": 1,
                "level_2_label": "Open Meeting Documents",
                "sort_order": 0,
                'text': 'level 2 document2',
                "url": "/files/legal/rulemakings/2024-08/425595/REG-2024-08-(Untraceable-Electronic).pdf",
            },
        ]

        expected_level_2_labels_1 = [
            {
                "level_2": 1,
                "level_2_label": "Open Meeting Documents",
                "level_2_docs": expected_level_2_docs_1,
            },
        ]

        expected_documents = [
            {
                "doc_admin_close_date": None,
                "doc_calc_comment_close_date": None,
                "doc_category_id": 4,
                "doc_category_label": "Federal Register Document",
                "doc_comment_close_date": None,
                "doc_date": datetime.date(2024, 11, 26),
                "doc_description": "NOA.pdf",
                "doc_entities": [],
                "doc_id": 425629,
                "doc_type_id": 66,
                "doc_type_label": "Notice of Availability",
                "filename": "NOA",
                "is_comment_eligible": False,
                "is_key_document": False,
                "level_1": 14,
                "level_1_label": "Notice of Availability",
                "level_2": 0,
                "level_2_label": "Notice of Availability",
                "level_2_labels": expected_level_2_labels_1,
                "sort_order": 0,
                'text': 'level 1 document',
                "url": "/files/legal/rulemakings/2024-08/425629/NOA.pdf",
            },
        ]

        level1_doc = {
            "id": 425629,
            "rm_id": 3472947,
            "filename": "NOA.pdf",
            "category": 4,
            "description": "NOA.pdf",
            "contents": "content11".encode("utf-8"),
            "date1": datetime.date(2024, 11, 26),
            "is_key_document": 0,
            "type_id": 66,
            "sync_status": None,
            "sort_order": 0,
            "comment_close_date": None,
            "admin_close_date": None,
        }
        self.create_documents(level1_doc)

        level2_doc1 = {
            "id": 425609,
            "rm_id": 3472947,
            "filename": "REG 2024-08 (Electronic).pdf",
            "category": 7,
            "description": "REG 2024-08 (Electronic).pdf",
            "contents": "content21".encode("utf-8"),
            "date1": datetime.date(2024, 11, 13),
            "is_key_document": 0,
            "type_id": 44,
            "sync_status": None,
            "sort_order": 0,
            "comment_close_date": None,
            "admin_close_date": None,
        }
        self.create_documents(level2_doc1)

        level2_doc2 = {
            "id": 425595,
            "rm_id": 3472947,
            "filename": "REG 2024-08 (Untraceable Electronic).pdf",
            "category": 3,
            "description": "REG 2024-08 (Untraceable Electronic).pdf",
            "contents": "content22".encode("utf-8"),
            "date1": datetime.date(2024, 11, 14),
            "is_key_document": 0,
            "type_id": 27,
            "sync_status": None,
            "sort_order": 0,
            "comment_close_date": None,
            "admin_close_date": None,
        }
        self.create_documents(level2_doc2)

        self.create_documents_ocrtext(425629, "level 1 document")
        self.create_documents_ocrtext(425609, "level 2 document1")
        self.create_documents_ocrtext(425595, "level 2 document2")

        calendar = {
            "id": 35834,
            "rm_id": 3472947,
            "event_name": "Policy - Notice of Availability (NOA)",
            "event_key": 106881,
            "eventdt": datetime.date(2025, 1, 27),
        }
        self.create_calendar(calendar)

        tiermapping1 = {
            "level1": 14,
            "level2": 0,
            "type_id": 66,
            "description": "Notice of Availabilty"
        }
        tiermapping2 = {
            "level1": 14,
            "level2": 1,
            "type_id": 27,
            "description": "Draft Notice of Availability"
        }
        tiermapping3 = {
            "level1": 14,
            "level2": 1,
            "type_id": 44,
            "description": "Vote to approve"
        }
        self.create_tiermapping(tiermapping1)
        self.create_tiermapping(tiermapping2)
        self.create_tiermapping(tiermapping3)

        actual_documents2 = get_documents("2024-08", 3472947, get_bucket)
        assert actual_documents2 == expected_documents

        self.connection.execute(
            text("""DELETE FROM fosers.documents""")
        )
        self.connection.commit()

    def create_documents(self, document):
        self.connection.execute(
            text("""INSERT INTO fosers.documents
            (id, rm_id, filename, category, description, contents, date1, is_key_document,
            type_id, sync_status, sort_order, comment_close_date, admin_close_date)
            VALUES (:id, :rm_id, :filename, :category, :description, :contents,
            :date1, :is_key_document, :type_id, :sync_status, :sort_order,
            :comment_close_date, :admin_close_date)"""),
            {
                "id": document["id"],
                "rm_id": document["rm_id"],
                "filename": document["filename"],
                "category": document["category"],
                "description": document["description"],
                "contents": psycopg2.Binary(document["contents"]),
                "date1": document["date1"],
                "is_key_document": document["is_key_document"],
                "type_id": document["type_id"],
                "sync_status": document["sync_status"],
                "sort_order": document["sort_order"],
                "comment_close_date": document["comment_close_date"],
                "admin_close_date": document["admin_close_date"],
            }
        )
        self.connection.commit()

    def create_documents_ocrtext(self, id, ocrtext):
        self.connection.execute(
            text("""
            INSERT INTO fosers.documents_ocrtext(id, ocrtext)VALUES (:id, :ocrtext)"""),
            {
                "id": id,
                "ocrtext": ocrtext,
            }
        )
        self.connection.commit()

    def create_calendar(self, calendar):
        self.connection.execute(
            text("""
            INSERT INTO fosers.calendar(id, rm_id, event_key, event_name, eventdt)
                 VALUES (:id, :rm_id, :event_key, :event_name, :eventdt)"""),
            {
                "id": calendar["id"],
                "rm_id": calendar["rm_id"],
                "event_key": calendar["event_key"],
                "event_name": calendar["event_name"],
                "eventdt": calendar["eventdt"],
            }
        )
        self.connection.commit()
        # --106881, 107212, 112434, 108851, 107093, 106993, 107034, 112451, 108818

    def create_tiermapping(self, tm):
        self.connection.execute(
            text("""
            INSERT INTO fosers.tiermapping(level1, level2, type_id, description)
                 VALUES (:level1, :level2, :type_id, :description)"""),
            {
                "level1": tm["level1"],
                "level2": tm["level2"],
                "type_id": tm["type_id"],
                "description": tm["description"],
            }
        )
        self.connection.commit()

    def clear_test_data(self):
        tables = ["calendar", "commissioners", "documentplayers", "documents",
                  "participants", "rulemaster", "tiermapping", "votes", ]
        for table in tables:
            self.connection.execute(text("DELETE FROM fosers.{}".format(table)))
