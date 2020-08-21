# import these 3 libraries to display the JSON format of object "mur"
import json
import datetime
from json import JSONEncoder

from sqlalchemy.sql import text


from elasticsearch_dsl import Search, Q

import logging
import re
# from collections import defaultdict

# from webservices.env import env
from webservices.rest import db
# from webservices.utils import extend, create_eregs_link, get_elasticsearch_connection
# from webservices.tasks.utils import get_bucket
from webservices import utils
from .reclassify_statutory_citation import reclassify_statutory_citation

logger = logging.getLogger(__name__)

ALL_MURS = """
    SELECT DISTINCT
        mur_id,
        mur_number as mur_no
    FROM mur_arch.all_murs
    ORDER BY mur_id
"""

SINGLE_MUR = """
    SELECT DISTINCT
        mur_number as mur_no,
        mur_id,
        mur_name,
        open_date,
        close_date
    FROM mur_arch.all_murs
    WHERE mur_number = %s
"""

MUR_COMPLAINANT = """
    SELECT
        code,
        name
    FROM mur_arch.all_murs
    WHERE mur_id = %s AND code = 'C'
    ORDER BY name
"""

MUR_RESPONDENT = """
    SELECT
        code,
        name
    FROM mur_arch.all_murs
    WHERE mur_id = %s AND code = 'R'
    ORDER BY name
"""

MUR_CITES = """
    SELECT
        cite
    FROM mur_arch.all_murs
    WHERE mur_id = %s AND cite is not null
    ORDER BY cite
"""

MUR_SUBJECT_LV1 = """
    SELECT
        mur,
        level_1,
        subject
    FROM MUR_ARCH.SUBJCT_FROM_FILE
    WHERE level_2::integer = 0 AND level_3::integer = 0
    AND mur = %s
"""

MUR_SUBJECT_LV2 = """
    SELECT
        mur,
        level_2,
        subject
    FROM MUR_ARCH.SUBJCT_FROM_FILE
    WHERE level_2::integer > 0
    AND level_3::integer = 0
    AND mur = %s
    AND level_1 = %s
"""

MUR_SUBJECT_LV3 = """
    SELECT
        mur,
        level_3,
        subject
    FROM MUR_ARCH.SUBJCT_FROM_FILE
    WHERE level_3::integer > 0
    AND mur = %s
    AND level_1 = %s
    AND level_2 = %s
"""

MUR_DOCUMENTS = """
    SELECT
        document_id,
        mur_no,
        pdf_text,
        mur_id,
        length,
        url
    FROM MUR_ARCH.DOCUMENTS
    WHERE mur_id = %s
"""


# To display the open_date and close_date of JSON format inside object "mur"
class DateTimeEncoder(JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (datetime.date, datetime.datetime)):
            return obj.isoformat()


def load_archived_murs(mur_no=None):

    """
    Reads data for Archived MURs from a Postgres database (under schema:mur_arch),
    assembles a JSON document corresponding to the mur, and indexes this document
    in Elasticsearch in the index `archived_murs` with a doc_type of `archived_murs`.
    In addition, all documents attached to the case are uploaded to an
    S3 bucket under the _directory_ `legal/<doc_type>/<id>/`.
    """
    es = utils.get_elasticsearch_connection()
    logger.info("Loading archived mur {0}(s)".format(mur_no))
    mur_count = 0
    print("load_archived_murs().......")
    for mur in get_murs(mur_no):
        if mur is not None:
            logger.info("Loading archived murs: {0}".format(mur["no"]))
            print("Loading archived murs: {0}".format(mur["no"]))
            es.index("archived_murs", get_es_type(), mur, id=mur["doc_id"])
            mur_count += 1
            logger.info("{0} archived mur(s) loaded".format(mur_count))
            print("{0} archived mur(s) loaded".format(mur_count))
        else:
            logger.info("Found an unpublished case - deleting archived mur: {0} from ES".format(mur["no"]))
            es.delete_by_query(index="docs_index", body={"query": {"term": {"no": mur["no"]}}},
                doc_type=get_es_type())
            logger.info("Successfully deleted archived mur(s) {} from ES".format(mur["no"]))

        # display the JSON format of object "mur"
        print("mur_json_data =" + json.dumps(mur, indent=4, cls=DateTimeEncoder))


def get_murs(mur_no=None):
    """
    """
    print("get_murs().......")
    if mur_no is None:
        with db.engine.connect() as conn:
            rs = conn.execute(ALL_MURS)
            for row in rs:
                yield get_single_mur(row["mur_no"])
    else:
        yield get_single_mur(mur_no)


def get_single_mur(mur_no):

    with db.engine.connect() as conn:
        rs = conn.execute(SINGLE_MUR, mur_no)
        row = rs.first()
        if row is not None:
            mur_id = row["mur_id"]
            mur = {
                "doc_id": "mur_{0}".format(row["mur_no"]),
                "no": row["mur_no"],
                "url": "/legal/matter-under-review/{0}/".format(row["mur_no"]),
                "mur_type": "archived",
                "mur_name": row["mur_name"],
                "open_date": row["open_date"],
                "close_date": row["close_date"]
            }
            mur["complainants"] = get_complainants(mur_id)
            mur["respondents"] = get_respondents(mur_id)
            mur["citations"] = get_citations_arch_mur(mur_id)

            mur["subject"] = get_subjects(mur_id)
            mur["documents"] = get_documents(mur_id)
            return mur
        else:
            logger.info("Not a valid archived mur number.")
            return None


def get_es_type():
    return "murs"


def get_complainants(mur_id):
    complainants = []
    with db.engine.connect() as conn:
        rs = conn.execute(MUR_COMPLAINANT, mur_id)
        for row in rs:
            complainants.append(row["name"])
    return complainants


def get_respondents(mur_id):
    respondents = []
    with db.engine.connect() as conn:
        rs = conn.execute(MUR_RESPONDENT, mur_id)
        for row in rs:
            respondents.append(row["name"])
    return respondents


def get_subjects(mur_id):
    subject_lv1 = []
    subject_lv2 = []
    subject_lv3 = []
    with db.engine.connect() as conn:
        rs1 = conn.execute(MUR_SUBJECT_LV1, mur_id)
        for row1 in rs1:
            if row1["subject"]:
                rs2 = conn.execute(MUR_SUBJECT_LV2, mur_id, row1["level_1"])
                subject_lv2 = []
                for row2 in rs2:
                    if row2["subject"]:
                        rs3 = conn.execute(MUR_SUBJECT_LV3, mur_id, row1["level_1"], row2["level_2"])
                        subject_lv3 = []
                        for row3 in rs3:
                            if row3["subject"]:
                                subject_lv3.append({"text": row3["subject"]})

                        if subject_lv3:
                            subject_lv2.append({"text": row2["subject"], "children": subject_lv3})
                        else:
                            subject_lv2.append({"text": row2["subject"]})
                if subject_lv2:
                    subject_lv1.append({"text": row1["subject"], "children": subject_lv2})
                else:
                    subject_lv1.append({"text": row1["subject"]})
    return subject_lv1


# us_codes examples: 2 U.S.C. 431(1)(B) or 26 U.S.C. 9008(d)(1)
# url:www.govinfo.gov/link/uscode/52/30101
def get_citations_arch_mur(mur_id):
    us_codes = []
    regulations = []

    with db.engine.connect() as conn:
        rs = conn.execute(MUR_CITES, mur_id)
        for row in rs:
            if row["cite"]:
                us_code_match = re.match(
                    "(?P<title>[0-9]+) U\.S\.C\. (?P<section>[0-9a-z-]+)(?P<paragraphs>.*)", row["cite"])

                regulation_match = re.match(
                    "(?P<title>[0-9]+) C\.F\.R\. (?P<part>[0-9]+)(?:\.(?P<section>[0-9]+))?", row["cite"])

                if us_code_match:
                    us_code_title, us_code_section = reclassify_statutory_citation(
                        us_code_match.group("title"), us_code_match.group("section"))
                    citation_text = "%s U.S.C. %s%s" % (
                        us_code_title, us_code_section, us_code_match.group("paragraphs"))
                    url = "https://www.govinfo.gov/link/uscode/{0}/{1}".format(us_code_title, us_code_section)

                    us_codes.append({"text": citation_text, "url": url})

                elif regulation_match:
                    url = utils.create_eregs_link(regulation_match.group("part"), regulation_match.group("section"))
                    regulations.append({"text": row["cite"], "url": url})
                else:
                    raise Exception("Could not parse archived mur's citation.")
        return {"us_code": us_codes, "regulations": regulations}


def get_documents(mur_id):
    documents = []
    with db.engine.connect() as conn:
        rs = conn.execute(MUR_DOCUMENTS, mur_id)
        for row in rs:
            documents.append({
                "document_id": int(row["document_id"] or 1),
                "length": int(row["length"] or 0),
                "text": (row["pdf_text"].replace('"', '""')),
                "url": (row["url"] or "/files/legal/murs/{0}.pdf".format(mur_id))
            })
    return documents


def extract_pdf_text(mur_no=None):
    es = utils.get_elasticsearch_connection()

    print ("extract_pdf_text()...")
    es_results = (
        Search()
        .using(es)
        .source(includes=["no", "documents.document_id", "documents.length", "documents.url", "documents.text"])
        .extra(size=20)
        .index("archived_murs")
        .doc_type("murs")
        .execute()
    )
    results = {"all_mur_docs": [hit.to_dict() for hit in es_results]}
    print("results =" + json.dumps(results, indent=4, cls=DateTimeEncoder))

    print("results.length=" + str(len(results['all_mur_docs'])))

    INSERT_DOCUMENT = """
        INSERT INTO MUR_ARCH.DOCUMENTS_TMP(
            document_id,
            mur_no,
            pdf_text,
            mur_id,
            length,
            url
        ) VALUES (:document_id, :mur_no, :pdf_text, :mur_id, :length, :url)
    """

    insert_data_docs = []
    if results and results.get("all_mur_docs"):
        with db.engine.connect() as conn:
            for mur in results["all_mur_docs"]:
                mur_no = mur["no"]
                if mur.get("documents"):
                    for mur_doc in mur["documents"]:
                        if mur_doc:
                            insert_data_doc = ({
                                "document_id": int(mur_doc["document_id"]),
                                "mur_no": mur_no,
                                "pdf_text": mur_doc["text"],
                                "mur_id": int(mur_no),
                                "length": int(mur_doc["length"] or 0),
                                "url": mur_doc["url"],
                            })

                            conn.execute(text(INSERT_DOCUMENT), **insert_data_doc)

                            insert_data_docs.append(insert_data_doc)

                # elif mur["text"]: TO DO List
            print("insert_data_docs =" + json.dumps(insert_data_docs, indent=4, cls=DateTimeEncoder))

