import logging
from webservices.common.models import db
from webservices.utils import (
    create_es_client,
)
# from webservices.tasks.utils import get_bucket
import webservices.constants as constants

logger = logging.getLogger(__name__)

# for debug, uncomment this line
# logger.setLevel(logging.DEBUG)


ALL_RMS = """
SELECT
rm_number,
rm_id
FROM fosers.rulemaking_vw
ORDER BY rm_year desc, rm_serial desc
"""

SINGLE_RM = """
SELECT
admin_close_date,
calculated_comment_close_date,
comment_close_date,
description,
is_open_for_comment,
last_updated,
rm_id,
rm_name,
rm_no,
rm_number,
rm_serial,
rm_year,
sync_status,
title
FROM fosers.rulemaking_vw
WHERE rm_number = %s
"""

LEVEL_1_DOCS = """
SELECT
doc_category_id,
doc_description,
doc_date,
doc_id,
doc_type_id,
filename,
is_key_document,
level_1,
level_2,
ocrtext,
sort_order
FROM fosers.documents_vw
WHERE rm_id = %s
AND level_1 in (SELECT
DISTINCT level_1
FROM fosers.documents_vw
WHERE rm_id = %s)
AND level_2 = 0
order by doc_date desc
"""

LEVEL_2_ID_LIST = """
SELECT
DISTINCT level_2
FROM fosers.documents_vw
WHERE rm_id = %s
AND level_1 = %s
AND level_2 > 0
"""

LEVEL_2_DOCS = """
SELECT
doc_category_id,
doc_description,
doc_date,
doc_id,
doc_type_id,
filename,
is_key_document,
level_1,
level_2,
ocrtext,
sort_order
FROM fosers.documents_vw
WHERE rm_id = %s
AND level_1 = %s
AND level_2 = %s
order by doc_date
"""

KEY_DOCUMENTS = """
SELECT
doc_description,
doc_date,
doc_id,
filename,
level_1,
level_2
FROM fosers.documents_vw
WHERE rm_id = %s
AND is_key_document = true
order by doc_date
"""

RM_ENTITIES = """
SELECT
name,
role
FROM fosers.participants
WHERE rm_id = %s
ORDER BY name
"""

RM_DOCUMENT_ENTITIES = """
SELECT
p.name as name,
p.role as role
FROM fosers.documentplayers dp, fosers.participants p
WHERE dp.participant_id = p.id
AND dp.rm_id = %s
AND dp.document_id = %s
ORDER BY name
"""

RM_VOTE_DATE = """
SELECT event_name,
eventdt as vote_date
FROM FOSERS.CALENDAR
WHERE event_key IN (107229,107232,107422,107425,106646,106649,106775,106777,112443,112444,107111,107116,
108837,108838,107327,107329,108672,108710,108730,108750,112446,108868,108843,108690,106944,106946,106948,
106950,108905,108906,112414,106643,106653,108731,112384,112418,112475,112474,112480,112478,112479,112477,
112476,112503,112502,112508,112506,112507,112505,112504,108806,108807,108808,108809,108813,108814,112397,
112460,112459,112465,112463,112464,112462,112461,107107,107121,108869,112406,106903,106906,106909,106912,
108768,108769,112392,108836,108839,108844,112402,107227,107235,108673,112371,107324,107333,108691,112375,
107420,107428,108711,112380,106772,106778,108751,112388,112426,112425,112431,112429,112430,112428,112427,
107006,107009,107011,107013,108788,108789,112393,112442,112448,112447,112445,106695,112489,106693,112488,
112410,112494,108887,112492,108888,112493,106700,112491,106697,112490)
AND rm_id = %s
ORDER BY vote_date DESC
"""

RM_FR_PUBLICATION_DATE = """
SELECT event_name,
eventdt as fr_publication_date
FROM FOSERS.CALENDAR
WHERE event_key IN (107029,107091,112449,107138,107208,108817,110919,108693,112598,107358,108847,107034,
108713,106993,106874,106881,107093,112451,107212,108818,108908,112419,112481,112509,108851,112588,112432,
112434,107358,112599,112495,112466)
AND rm_id = %s
ORDER BY fr_publication_date DESC
"""

RM_HEARING_DATE = """
SELECT event_name,
eventdt as hearing_date
FROM FOSERS.CALENDAR
WHERE event_key in (112420,112608,107143)
AND rm_id = %s
ORDER BY hearing_date DESC
"""


# Load specific one rm_no command: `python cli.py load_rulemaking 2021-01`
# Load all rulemakings command: `python cli.py load_rulemaking`
def load_rulemaking(specific_rm_no=None):
    es_client = create_es_client()
    rm_count = 0
    if es_client.indices.exists(index=constants.RM_ALIAS):
        logger.info(" Index alias '{0}' exists, start loading rulemaking...".format(constants.RM_ALIAS))
        for rm in get_rulemaking(specific_rm_no):
            if rm is not None:
                logger.info(" Loading rm_no: {0}, rm_id: {1} ".format(rm["rm_no"], rm["rm_id"]))
                es_client.index(constants.RM_ALIAS, rm, id=rm["rm_id"])
                rm_count += 1

        logger.info(" Total %d rulemaking loaded.", rm_count)
    else:
        logger.error(" The index alias '{0}' is not found, cannot load rulemaking".format(constants.RM_ALIAS))


def get_rulemaking(specific_rm_no):
    # bucket = get_bucket() (don't need upload xxxx.pdf to s3 bucket)
    if specific_rm_no is None:
        # load all rulemakings
        with db.engine.connect() as conn:
            rs = conn.execute(ALL_RMS)
            for row in rs:
                yield get_single_rulemaking(row["rm_number"])
    else:
        # load specific one rulemaking
        rm_number = "REG " + specific_rm_no
        yield get_single_rulemaking(rm_number)


def get_single_rulemaking(rm_number):
    with db.engine.connect() as conn:
        rs = conn.execute(SINGLE_RM, rm_number)
        row = rs.first()
        rm_id = row["rm_id"]
        rm = {
            "admin_close_date": row["admin_close_date"],
            "calculated_comment_close_date": row["calculated_comment_close_date"],
            "comment_close_date": row["comment_close_date"],
            "description": row["description"],
            "is_open_for_comment": row["is_open_for_comment"],
            "last_updated": row["last_updated"],
            "key_documents": get_key_documents(rm_id),
            "rm_id": rm_id,
            "rm_name": row["rm_name"],
            "rm_no": row["rm_no"],
            "rm_number": rm_number,
            "rm_serial": row["rm_serial"],
            "rm_year": row["rm_year"],
            "sort1": -row["rm_year"],
            "sort2": -row["rm_serial"],
            "sync_status": row["sync_status"],
            "title": row["title"],
            "type": constants.RULEMAKING_TYPE,
        }
        rm["documents"] = get_documents(rm_id)
        rm["fr_publication_dates"] = get_fr_publication_dates(rm_id)
        rm["hearing_dates"] = get_hearing_dates(rm_id)
        rm["vote_dates"] = get_vote_dates(rm_id)

        (
            rm["commenter_names"],
            rm["counsel_names"],
            rm["petitioner_names"],
            rm["representative_names"],
            rm["witness_names"],
            rm["rm_entities"],
        ) = get_rm_entities(rm_id)
    return rm


def get_documents(rm_id):
    documents = []
    with db.engine.connect() as conn:
        rs = conn.execute(LEVEL_1_DOCS, rm_id, rm_id)
        for row in rs:
            document = {
                "doc_category_id": row["doc_category_id"],
                "doc_category_label": constants.DOC_CATEGORY_MAP.get(row["doc_category_id"]),
                "doc_description": row["doc_description"],
                "doc_date": row["doc_date"],
                "doc_id": row["doc_id"],
                "doc_entities": get_doc_entities(rm_id, row["doc_id"]),
                "doc_type_id": row["doc_type_id"],
                "doc_type_label": constants.DOC_TYPE_MAP.get(row["doc_type_id"]),
                "filename": row["filename"],
                "is_key_document": row["is_key_document"],
                "level_1": row["level_1"],
                "level_2": row["level_2"],
                "level_1_label": constants.LEVEL_1_MAP.get(row["level_1"]),
                "level_2_label": (constants.LEVEL_1_2_MAP.get(row["level_1"]).get(row["level_2"])),
                "sort_order": row["sort_order"],
                "text": row["ocrtext"],
                "url": "https://www.fec.gov/rulemaking/{}/{}".format(row["doc_id"], row["filename"]),
                "level_2_labels": get_level_2_labels(rm_id, row["level_1"]),
            }
            documents.append(document)
        return documents


def get_level_2_labels(rm_id, level_1):
    level_2_labels = []
    with db.engine.connect() as conn:
        rs = conn.execute(LEVEL_2_ID_LIST, rm_id, level_1)
        for row in rs:
            document = {
                "level_2": row["level_2"],
                "level_2_label": (constants.LEVEL_1_2_MAP.get(level_1).get(row["level_2"])),
                "level_2_docs": get_level_2_docs(rm_id, level_1, row["level_2"]),
            }
            level_2_labels.append(document)
        return level_2_labels


def get_level_2_docs(rm_id, level_1, level_2):
    level_2_documents = []
    with db.engine.connect() as conn:
        rs = conn.execute(LEVEL_2_DOCS, rm_id, level_1, level_2)
        for row in rs:
            document = {
                "doc_category_id": row["doc_category_id"],
                "doc_category_label": constants.DOC_CATEGORY_MAP.get(row["doc_category_id"]),
                "doc_description": row["doc_description"],
                "doc_date": row["doc_date"],
                "doc_id": row["doc_id"],
                "doc_entities": get_doc_entities(rm_id, row["doc_id"]),
                "doc_type_id": row["doc_type_id"],
                "doc_type_label": constants.DOC_TYPE_MAP.get(row["doc_type_id"]),
                "filename": row["filename"],
                "is_key_document": row["is_key_document"],
                "level_1": level_1,
                "level_2": level_2,
                "level_1_label": constants.LEVEL_1_MAP.get(level_1),
                "level_2_label": (constants.LEVEL_1_2_MAP.get(level_1).get(level_2)),
                "sort_order": row["sort_order"],
                "text": row["ocrtext"],
                "url": "https://www.fec.gov/rulemaking/{}/{}".format(row["doc_id"], row["filename"]),
            }
            level_2_documents.append(document)
        return level_2_documents


def get_key_documents(rm_id):
    key_documents = []
    with db.engine.connect() as conn:
        rs = conn.execute(KEY_DOCUMENTS, rm_id)
        for row in rs:
            document = {
                "doc_description": row["doc_description"],
                "doc_date": row["doc_date"],
                "doc_id": row["doc_id"],
                "filename": row["filename"],
                "level_1": row["level_1"],
                "level_1_label": constants.LEVEL_1_MAP.get(row["level_1"]),
                "level_2": row["level_2"],
                "url": "https://www.fec.gov/rulemaking/{}/{}".format(row["doc_id"], row["filename"]),
            }
            key_documents.append(document)
        return key_documents


def get_doc_entities(rm_id, document_id):
    doc_entities = []
    with db.engine.connect() as conn:
        rs = conn.execute(RM_DOCUMENT_ENTITIES, rm_id, document_id)
        for row in rs:
            doc_entities.append(
                {
                    "name": row["name"],
                    "role": row["role"],
                 }
            )
    return doc_entities


def get_fr_publication_dates(rm_id):
    fr_publication_dates = []
    with db.engine.connect() as conn:
        rs = conn.execute(RM_FR_PUBLICATION_DATE, rm_id)
        for row in rs:
            fr_publication_dates.append(row["fr_publication_date"])
    return fr_publication_dates


def get_hearing_dates(rm_id):
    hearing_dates = []
    with db.engine.connect() as conn:
        rs = conn.execute(RM_HEARING_DATE, rm_id)
        for row in rs:
            hearing_dates.append(row["hearing_date"])
    return hearing_dates


def get_vote_dates(rm_id):
    vote_dates = []
    with db.engine.connect() as conn:
        rs = conn.execute(RM_VOTE_DATE, rm_id)
        for row in rs:
            vote_dates.append(row["vote_date"])
    return vote_dates


def get_rm_entities(rm_id):
    commenter_names = []
    representative_names = []
    counsel_names = []
    witness_names = []
    petitioner_names = []
    rm_entities = []
    with db.engine.connect() as conn:
        rs = conn.execute(RM_ENTITIES, rm_id)
        for row in rs:
            rm_entities.append(
                {
                    "name": row["name"],
                    "role": row["role"],
                }
            )
            if (row["role"]).lower() == "commenter":
                commenter_names.append(row["name"])
            elif row["role"].lower() == "counsel":
                counsel_names.append(row["name"])
            elif row["role"].lower() == "officer/representative":
                representative_names.append(row["name"])
            elif row["role"].lower() == "petitioner":
                petitioner_names.append(row["name"])
            elif row["role"].lower() == "witness":
                witness_names.append(row["name"])
    return (
        commenter_names,
        counsel_names,
        petitioner_names,
        representative_names,
        witness_names,
        rm_entities,
    )
