from collections import defaultdict
import logging
import re

from webservices.env import env
from webservices.legal_docs import DOCS_INDEX
from webservices.legal_docs.load_legal_docs import generate_aws_s3_url
from webservices.rest import db
from webservices.utils import get_elasticsearch_connection
from webservices.tasks.utils import get_bucket
from .reclassify_statutory_citation import reclassify_archived_mur_statutory_citation


logger = logging.getLogger(__name__)

ALL_AOS = """
    SELECT
        ao_id,
        ao_no,
        name,
        summary,
        req_date,
        issue_date,
        CASE WHEN finished IS NULL THEN TRUE ELSE FALSE END AS is_pending
    FROM aouser.aos_with_parsed_numbers ao
    LEFT JOIN (SELECT DISTINCT ao_id AS finished
               FROM aouser.document
               WHERE category IN ('Final Opinion', 'Withdrawal of Request')) AS finished
        ON ao.ao_id = finished.finished
    WHERE (
        (ao_year = %s AND ao_serial >= %s)
        OR
        (ao_year > %s)
    )
    ORDER BY ao_year, ao_serial
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

STATUTE_CITATION_REGEX = re.compile(r"(?P<title>\d+)\s+U.S.C.\s+§*(?P<section>\d+).*\.?")
REGULATION_CITATION_REGEX = re.compile(r"(?P<title>\d+)\s+CFR\s+§*(?P<part>\d+)\.(?P<section>\d+)")
AO_CITATION_REGEX = re.compile(r"\b(?P<year>\d{4,4})-(?P<serial_no>\d+)\b")


def load_advisory_opinions(from_ao_no=None):
    """
    Reads data for advisory opinions from a Postgres database, assembles a JSON document
    corresponding to the advisory opinion and indexes this document in Elasticsearch in
    the index `docs_index` with a doc_type of `advisory_opinions`. In addition, all documents
    attached to the advisory opinion are uploaded to an S3 bucket under the _directory_
    `legal/aos/`.
    """
    es = get_elasticsearch_connection()

    for ao in get_advisory_opinions(from_ao_no):
        logger.info("Loading AO: %s", ao['no'])
        es.index(DOCS_INDEX, 'advisory_opinions', ao, id=ao['no'])

def get_advisory_opinions(from_ao_no):
    bucket = get_bucket()
    bucket_name = env.get_credential('bucket')

    ao_names = get_ao_names()
    ao_no_to_component_map = {a: tuple(map(int, a.split('-'))) for a in ao_names}

    citations = get_citations(ao_names)

    if from_ao_no is None:
        start_ao_year, start_ao_serial = 0, 0
    else:
        start_ao_year, start_ao_serial = tuple(map(int, from_ao_no.split('-')))

    with db.engine.connect() as conn:
        rs = conn.execute(ALL_AOS, (start_ao_year, start_ao_serial, start_ao_year))
        for row in rs:
            ao_id = row["ao_id"]
            year, serial = ao_no_to_component_map[row["ao_no"]]
            ao = {
                "no": row["ao_no"],
                "name": row["name"],
                "summary": row["summary"],
                "request_date": row["req_date"],
                "issue_date": row["issue_date"],
                "is_pending": row["is_pending"],
                "ao_citations": citations[row["ao_no"]]["ao"],
                "aos_cited_by": citations[row["ao_no"]]["aos_cited_by"],
                "statutory_citations": citations[row["ao_no"]]["statutes"],
                "regulatory_citations": citations[row["ao_no"]]["regulations"],
                "sort1": -year,
                "sort2": -serial,
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
                "date": row["document_date"],
            }
            pdf_key = "legal/aos/%s.pdf" % row["document_id"]
            logger.info("S3: Uploading {}".format(pdf_key))
            bucket.put_object(Key=pdf_key, Body=bytes(row["fileimage"]),
                    ContentType="application/pdf", ACL="public-read")
            document["url"] = generate_aws_s3_url(bucket_name, pdf_key)
            documents.append(document)
    return documents

def get_ao_names():
    ao_names_results = db.engine.execute("""SELECT ao_no, name FROM aouser.ao""")
    ao_names = {}
    for row in ao_names_results:
        ao_names[row["ao_no"]] = row["name"]

    return ao_names


def get_citations(ao_names):
    ao_component_to_name_map = {tuple(map(int, a.split('-'))): a for a in ao_names}

    logger.info("Getting citations...")

    rs = db.engine.execute("""SELECT ao_no, ocrtext FROM aouser.document
                                INNER JOIN aouser.ao USING (ao_id)
                              WHERE category = 'Final Opinion'""")

    all_regulatory_citations = set()
    all_statutory_citations = set()
    raw_citations = defaultdict(lambda: defaultdict(set))
    for row in rs:
        logger.info("Getting citations for AO %s" % row["ao_no"])

        ao_citations_in_doc = parse_ao_citations(row["ocrtext"], ao_component_to_name_map)
        ao_citations_in_doc.discard(row["ao_no"])  # Remove self

        raw_citations[row["ao_no"]]["ao"].update(ao_citations_in_doc)

        for citation in ao_citations_in_doc:
            raw_citations[citation]["aos_cited_by"].add(row["ao_no"])

        statutory_citations = parse_statutory_citations(row["ocrtext"])
        regulatory_citations = parse_regulatory_citations(row["ocrtext"])
        all_statutory_citations.update(statutory_citations)
        all_regulatory_citations.update(regulatory_citations)
        raw_citations[row["ao_no"]]["statutes"].update(statutory_citations)
        raw_citations[row["ao_no"]]["regulations"].update(regulatory_citations)

    citations = defaultdict(lambda: defaultdict(list))
    for ao in raw_citations:
        citations[ao]["ao"] = sorted([
            {"no": c, "name": ao_names[c]}
            for c in raw_citations[ao]["ao"]], key=lambda d: d["no"])
        citations[ao]["aos_cited_by"] = sorted([
            {"no": c, "name": ao_names[c]}
            for c in raw_citations[ao]["aos_cited_by"]], key=lambda d: d["no"])
        citations[ao]["statutes"] = sorted([
            {"text": c[0], "title": c[1], "section": c[2], "former_title": c[3], "former_section": c[4]}
            for c in raw_citations[ao]["statutes"]], key=lambda d: (d["title"], d["section"]))
        citations[ao]["regulations"] = sorted([
            {"title": c[0], "part": c[1], "section": c[2]}
            for c in raw_citations[ao]["regulations"]], key=lambda d: (d["title"], d["part"], d["section"]))

    es = get_elasticsearch_connection()

    for citation in all_regulatory_citations:
        entry = {'citation_text': '%d CFR §%d.%d' % (citation[0], citation[1], citation[2]), 'citation_type': 'regulation'}
        es.index(DOCS_INDEX, 'citations', entry, id=entry['citation_text'])

    for citation in all_statutory_citations:
        if citation[3] != citation[1]:
            entry = {'citation_text': '%s U.S.C. §%s' % (citation[1], citation[2]),
                'formerly': '%d U.S.C. §%d' % (citation[3], citation[4]),
                'citation_type': 'statute'}
        else:
            entry = {'citation_text': '%d U.S.C. §%d' % (citation[1], citation[2]), 'citation_type': 'statute'}
        es.index(DOCS_INDEX, 'citations', entry, id=entry['citation_text'])
    return citations

def parse_ao_citations(text, ao_component_to_name_map):
    matches = set()

    if text:
        for citation in AO_CITATION_REGEX.finditer(text):
            year, serial_no = int(citation.group('year')), int(citation.group('serial_no'))
            if (year, serial_no) in ao_component_to_name_map:
                matches.add(ao_component_to_name_map[(year, serial_no)])
    return matches

def parse_statutory_citations(text):
    matches = set()
    if text:
        for citation in STATUTE_CITATION_REGEX.finditer(text):
            new_title, new_section = reclassify_archived_mur_statutory_citation(
                citation.group('title'), citation.group('section'))
            matches.add((
                citation.group(0),
                int(new_title),
                int(new_section),
                int(citation.group('title')),
                int(citation.group('section'))
            ))
    return matches

def parse_regulatory_citations(text):
    matches = set()
    if text:
        for citation in REGULATION_CITATION_REGEX.finditer(text):
            matches.add((
                int(citation.group('title')),
                int(citation.group('part')),
                int(citation.group('section'))
            ))
    return matches
