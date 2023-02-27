from sqlalchemy.sql import text
from elasticsearch_dsl import Search
import logging
import re
from webservices.rest import db
from webservices.utils import (
    create_es_client,
    create_eregs_link,
    DateTimeEncoder,
)
from .reclassify_statutory_citation import reclassify_statutory_citation
import json
from .es_management import (  # noqa
    ARCH_MUR_ALIAS,
)

logger = logging.getLogger(__name__)

# for debug, uncomment this line
# logger.setLevel(logging.DEBUG)

ALL_ARCHIVED_MURS = """
    SELECT DISTINCT
        mur_id,
        mur_number as mur_no,
        mur_id as case_serial
    FROM MUR_ARCH.ARCHIVED_MURS
    ORDER BY mur_id desc
"""

SINGLE_MUR = """
    SELECT DISTINCT
        mur_number as mur_no,
        mur_id,
        mur_id as case_serial,
        mur_name,
        open_date,
        close_date
    FROM MUR_ARCH.ARCHIVED_MURS
    WHERE mur_number = %s
"""

MUR_COMPLAINANT = """
    SELECT
        complainant_respondent_code as code,
        complainant_respondent_name as name
    FROM MUR_ARCH.ARCHIVED_MURS
    WHERE mur_id = %s AND complainant_respondent_code = 'C'
    ORDER BY complainant_respondent_name
"""

MUR_RESPONDENT = """
    SELECT
        complainant_respondent_code as code,
        complainant_respondent_name as name
    FROM MUR_ARCH.ARCHIVED_MURS
    WHERE mur_id = %s AND complainant_respondent_code = 'R'
    ORDER BY complainant_respondent_name
"""

MUR_CITES = """
    SELECT
        citation as cite
    FROM MUR_ARCH.ARCHIVED_MURS
    WHERE mur_id = %s AND citation is not null
    ORDER BY citation
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
    ORDER BY document_id
"""

INSERT_DOCUMENT = """
    INSERT INTO MUR_ARCH.DOCUMENTS(
        document_id,
        mur_no,
        pdf_text,
        mur_id,
        length,
        url
    ) VALUES (:document_id, :mur_no, :pdf_text, :mur_id, :length, :url)
"""


def load_archived_murs(mur_no=None):
    """
    Reads data for Archived MURs from a Postgres database (under schema:mur_arch),
    assembles a JSON document corresponding to the mur, and indexes this document
    in Elasticsearch in the alias ARCH_MUR_ALIAS of ARCH_MUR_INDEX with a type=`murs` and mur_type=`archived`.
    """
    # TO DO: check if ARCH_MUR_ALIAS exist before uploading.
    es_client = create_es_client()
    mur_count = 0
    for mur in get_murs(mur_no):
        if mur is not None:
            try:
                logger.info("Loading archived MUR No: {0}".format(mur["no"]))
                es_client.index(ARCH_MUR_ALIAS, mur, id=mur["doc_id"])
                mur_count += 1
                logger.info("{0} Archived Mur(s) loaded".format(mur_count))
            except Exception as err:
                logger.error(
                    "An error occurred while uploading archived mur:\nmur no={0} \nerr={1}".format(
                        mur["no"], err))

        # ==for dubug use: remove the big "documents" section to display the object "mur" data
        mur_debug_data = mur
        # del mur_debug_data["documents"]
        logger.debug("mur_data count=" + str(mur_count))
        logger.debug("mur_debug_data =" + json.dumps(mur_debug_data, indent=3, cls=DateTimeEncoder))


def get_murs(mur_no=None):
    if mur_no is None:
        with db.engine.connect() as conn:
            rs = conn.execute(ALL_ARCHIVED_MURS)
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
                "type": get_es_type(),
                "doc_id": "mur_{0}".format(row["mur_no"]),
                "no": row["mur_no"],
                "case_serial": row["mur_id"],
                "url": "/legal/matter-under-review/{0}/".format(row["mur_no"]),
                "mur_type": "archived",
                "mur_name": row["mur_name"],
                "open_date": row["open_date"],
                "close_date": row["close_date"],
            }
            mur["complainants"] = get_complainants(mur_id)
            mur["respondents"] = get_respondents(mur_id)
            mur["citations"] = get_citations_arch_mur(mur_id)
            mur["subject"] = get_subjects(mur_id)
            mur["documents"] = get_documents(mur_id)
            return mur
        else:
            logger.error("Not a valid archived mur number.")
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


# citation sample data:
# 1) us_code :
#   ex1: original us_code: 2 U.S.C. 441a(a)(5)
#        mapped us_code: 52 U.S.C. 30116(a)(5)
#        url: https://www.govinfo.gov/link/uscode/52/30116

#   ex2: 26 U.S.C. 9002(2)(A)
#        url: https://www.govinfo.gov/link/uscode/26/9002

# 2) regulation: 11 C.F.R. 9002.11(b)(3)
#    url: /regulations/9002-11/CURRENT

def get_citations_arch_mur(mur_id):
    us_codes = []
    regulations = []
    with db.engine.connect() as conn:
        rs = conn.execute(MUR_CITES, mur_id)
        for row in rs:
            if row["cite"]:
                us_code_match = re.match(
                    r"(?P<title>[0-9]+) U\.S\.C\. (?P<section>[0-9a-z-]+)(?P<paragraphs>.*)", row["cite"])

                regulation_match = re.match(
                    r"(?P<title>[0-9]+) C\.F\.R\. (?P<part>[0-9]+)(?:\.(?P<section>[0-9]+))?", row["cite"])

                if us_code_match:
                    us_code_title, us_code_section = reclassify_statutory_citation(
                        us_code_match.group("title"), us_code_match.group("section"))
                    citation_text = "%s U.S.C. %s%s" % (
                        us_code_title, us_code_section, us_code_match.group("paragraphs"))
                    url = "https://www.govinfo.gov/link/uscode/{0}/{1}".format(us_code_title, us_code_section)

                    us_codes.append({"text": citation_text, "url": url})

                elif regulation_match:
                    url = create_eregs_link(regulation_match.group("part"), regulation_match.group("section"))
                    regulations.append({"text": row["cite"], "url": url})
                else:
                    raise Exception("Could not parse archived mur's citation.")
        return {"us_code": us_codes, "regulations": regulations}


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


def get_documents(mur_id):
    documents = []
    with db.engine.connect() as conn:
        rs = conn.execute(MUR_DOCUMENTS, mur_id)
        for row in rs:
            documents.append({
                "document_id": int(row["document_id"] or 1),
                "length": int(row["length"] or 0),
                "text": row["pdf_text"],
                "url": (row["url"] or "/files/legal/murs/{0}.pdf".format(mur_id))
            })
    return documents


def extract_pdf_text(mur_no=None):
    """
    1)Reads "text" and "documents" object data for Archived MURs from Elasticsearch,
    under index: ARCH_MUR_INDEX and type of `murs`
    2)Assembles a JSON document corresponding to the archived murs,
    3)Insert the JSON document into Postgres database table: mur_arch.documents
    4)Run this command carefully, backup mur_arch.documents table first
    and empty it. the data will be inserted into table: mur_arch.documents
    """
    es_client = create_es_client()
    each_fetch_size = 1000
    max_size = 5000
    all_results = []

    # get "text" and "documents" object data from Elasticsearch
    for from_no in range(0, max_size, each_fetch_size):
        es_results = (
            Search()
            .using(es_client)
            .source(includes=[
                "no",
                "text",
                "documents.document_id",
                "documents.length",
                "documents.url",
                "documents.text"
            ])
            .extra(size=each_fetch_size, from_=from_no)
            .index(ARCH_MUR_ALIAS)
            .doc_type("murs")
            .sort("no")
            .execute()
        )

        for rs in [hit.to_dict() for hit in es_results]:
            all_results.append(rs)
        logger.debug("all_results = " + json.dumps(all_results, indent=3, cls=DateTimeEncoder))

    results = {"all_mur_docs": all_results}
    logger.debug("all_mur_docs = " + json.dumps(results, indent=3, cls=DateTimeEncoder))

    logger.info("Get {0} archived mur(s) from elasticserch index: \"ARCH_MUR_INDEX\"".format(
        str(len(results["all_mur_docs"]))))

    if results and results.get("all_mur_docs"):
        with db.engine.connect() as conn:
            for mur in results["all_mur_docs"]:
                mur_no = mur["no"]
                if mur.get("documents"):
                    logger.info("Archived Mur{0} has documents.".format(mur_no))
                    for mur_doc in mur["documents"]:
                        if mur_doc:
                            insert_data_doc = ({
                                "document_id": int(mur_doc["document_id"]),
                                "mur_no": mur_no,
                                "pdf_text": mur_doc.get("text"),
                                "mur_id": int(mur_no),
                                "length": (int(mur_doc["length"]) or len(mur_doc["text"]) or None),
                                "url": (mur_doc["url"] or "/files/legal/murs/{0}.pdf".format(mur_no)),
                            })
                            conn.execute(text(INSERT_DOCUMENT), **insert_data_doc)
                            logger.info("Archived Mur{0} has been inserted into table successfully".format(mur_no))
                elif mur.get("text"):
                    logger.info("Archived Mur{0} has no documents, but has text.".format(mur_no))
                    insert_data_doc = ({
                        "document_id": 1,
                        "mur_no": mur_no,
                        "pdf_text": mur["text"],
                        "mur_id": int(mur_no),
                        "length": (len(mur["text"]) or None),
                        "url": "/files/legal/murs/{0}.pdf".format(mur_no),
                    })
                    conn.execute(text(INSERT_DOCUMENT), **insert_data_doc)
                    logger.info("Archived Mur{0} has been inserted into table successfully".format(mur_no))
                else:
                    logger.info("Archived Mur{0} has no documents.".format(mur_no))
                    insert_data_doc = ({
                        "document_id": None,
                        "mur_no": mur_no,
                        "pdf_text": None,
                        "mur_id": int(mur_no),
                        "length": None,
                        "url": "/files/legal/murs/{0}.pdf".format(mur_no),
                    })
                    conn.execute(text(INSERT_DOCUMENT), **insert_data_doc)
                    logger.info("Archived Mur{0} has been inserted into table successfully".format(mur_no))
