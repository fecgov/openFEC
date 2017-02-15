from collections import defaultdict
import logging
import re

from webservices.env import env
from webservices.legal_docs import DOCS_INDEX
from webservices.rest import db
from webservices.utils import get_elasticsearch_connection
from webservices.tasks.utils import get_bucket


logger = logging.getLogger(__name__)

ALL_AOS = """
    SELECT
        ao_id,
        ao_no,
        name,
        summary,
        issue_date,
        CASE WHEN finished IS NULL THEN TRUE ELSE FALSE END AS is_pending
    FROM aouser.ao
    LEFT JOIN (SELECT DISTINCT ao_id AS finished
               FROM aouser.document
               WHERE category IN ('Final Opinion', 'Withdrawal of Request')) AS finished
        ON ao.ao_id = finished.finished
"""

AO_REQUESTORS = """
    SELECT
        e.name,
        et.description
    FROM aouser.players p
    INNER JOIN aouser.entity e USING (entity_id)
    INNER JOIN aouser.entity_type et ON et.entity_type_id = e.type
    WHERE p.ao_id = %s AND role_id IN (0, 1)
"""

AO_DOCUMENTS = """
    SELECT
        document_id,
        ocrtext,
        fileimage,
        description,
        category,
        document_date
    FROM aouser.document
    WHERE ao_id = %s
"""

STATUTE_CITATION_REGEX = re.compile(r"(?P<title>\d+)\s+U.S.C.\s+§*(?P<section>\d+)")
REGULATION_CITATION_REGEX = re.compile(r"(?P<title>\d+)\s+CFR\s+§*(?P<part>\d+)\.(?P<section>\d+)")
AO_CITATION_REGEX = re.compile(r"\b\d{4,4}-\d+\b")


def load_advisory_opinions():
    """
    Reads data for advisory opinions from a Postgres database, assembles a JSON document
    corresponding to the advisory opinion and indexes this document in Elasticsearch in
    the index `docs_index` with a doc_type of `advisory_opinions`. In addition, all documents
    attached to the advisory opinion are uploaded to an S3 bucket under the _directory_
    `legal/aos/`.
    """
    es = get_elasticsearch_connection()

    for ao in get_advisory_opinions():
        es.index(DOCS_INDEX, 'advisory_opinions', ao, id=ao['no'])

def get_advisory_opinions():
    bucket = get_bucket()
    bucket_name = env.get_credential('bucket')

    citations = get_citations()

    with db.engine.connect() as conn:
        rs = conn.execute(ALL_AOS)
        for row in rs:
            ao_id = row["ao_id"]
            ao = {
                "no": row["ao_no"],
                "name": row["name"],
                "summary": row["summary"],
                "issue_date": row["issue_date"],
                "is_pending": row["is_pending"],
                "ao_citations": citations[row["ao_no"]]["ao"],
                "aos_cited_by": citations[row["ao_no"]]["aos_cited"],
                "statutory_citations": citations[row["ao_no"]]["statutes"],
                "regulatory_citations": citations[row["ao_no"]]["regulations"],
            }
            ao["documents"] = get_documents(ao_id, bucket, bucket_name)
            ao["requestor_names"], ao["requestor_types"] = get_requestors(ao_id)

            yield ao


def get_requestors(ao_id):
    requestor_names = []
    requestor_types = set()
    with db.engine.connect() as conn:
        rs = conn.execute(AO_REQUESTORS, ao_id)
        for row in rs:
            requestor_names.append(row["name"])
            requestor_types.add(row["description"])
    return requestor_names, list(requestor_types)

def get_documents(ao_id, bucket, bucket_name):
    documents = []
    with db.engine.connect() as conn:
        rs = conn.execute(AO_DOCUMENTS, ao_id)
        for row in rs:
            document = {
                "document_id": row["document_id"],
                "category": row["category"],
                "description": row["description"],
                "text": row["ocrtext"],
                "document_date": row["document_date"],
            }
            pdf_key = "legal/aos/%s.pdf" % row["document_id"]
            logger.info("S3: Uploading {}".format(pdf_key))
            bucket.put_object(Key=pdf_key, Body=bytes(row["fileimage"]),
                    ContentType="application/pdf", ACL="public-read")
            document["url"] = "https://%s.s3.amazonaws.com/%s" % (bucket_name, pdf_key)
            documents.append(document)
    return documents

def get_filtered_matches(text, regex, filter_set):
    matches = set()
    if text:
        for citation in regex.findall(text):
            if citation in filter_set:
                matches.add(citation)
    return matches

def get_citations():
    logger.info("Getting citations...")

    ao_names_results = db.engine.execute("""SELECT ao_no, name FROM aouser.ao""")
    ao_names = {}
    for row in ao_names_results:
        ao_names[row["ao_no"]] = row["name"]

    rs = db.engine.execute("""SELECT ao_no, ocrtext FROM aouser.document
                                INNER JOIN aouser.ao USING (ao_id)
                              WHERE category = 'Final Opinion'""")
    citations = defaultdict(lambda: defaultdict(set))
    aos_cited_by = defaultdict(set)
    for row in rs:
        logger.info("Getting citations for AO %s" % row["ao_no"])

        ao_citations_in_doc = get_filtered_matches(row["ocrtext"], AO_CITATION_REGEX, ao_names)
        ao_citations_in_doc.discard(row["ao_no"])  # Remove self

        citations[row["ao_no"]]["ao"].update(ao_citations_in_doc)

        for citation in ao_citations_in_doc:
            aos_cited_by[citation].add(row["ao_no"])

        citations[row["ao_no"]]["statutes"].update(parse_statutory_citations(row["ocrtext"]))
        citations[row["ao_no"]]["regulations"].update(parse_regulatory_citations(row["ocrtext"]))

    for ao in citations:
        citations[ao]["ao"] = sorted([
            {"no": c, "name": ao_names[c]}
            for c in citations[ao]["ao"]], key=lambda d: d["no"])

    for ao in aos_cited_by:
        citations[ao]["aos_cited"] = sorted([
            {"no": c, "name": ao_names[c]}
            for c in aos_cited_by[ao]], key=lambda d: d["no"])

    return citations

def parse_statutory_citations(text):
    matches = set()
    if text:
        for citation in STATUTE_CITATION_REGEX.finditer(text):
            matches.add((int(citation.group('title')), int(citation.group('section'))))
    return matches

def parse_regulatory_citations(text):
    matches = set()
    if text:
        for citation in REGULATION_CITATION_REGEX.finditer(text):
            matches.add((int(citation.group('title')), int(citation.group('part')), int(citation.group('section'))))
    return matches
