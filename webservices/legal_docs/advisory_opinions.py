from collections import defaultdict
import logging
import re

from webservices.env import env
from webservices.legal_docs import DOCS_INDEX
from webservices.rest import db
from webservices.utils import get_elasticsearch_connection
from webservices.tasks.utils import get_bucket
from .reclassify_statutory_citation import reclassify_archived_mur_statutory_citation


logger = logging.getLogger(__name__)

ALL_AOS = """
    SELECT
        ao_parsed.ao_id,
        ao_parsed.ao_no,
        ao_parsed.name,
        ao_parsed.summary,
        ao_parsed.req_date,
        ao_parsed.issue_date,
        ao.stage
    FROM aouser.aos_with_parsed_numbers ao_parsed
    INNER JOIN aouser.ao ao
        ON ao_parsed.ao_id = ao.ao_id
    WHERE (
        (ao_parsed.ao_year = %s AND ao_parsed.ao_serial >= %s)
        OR
        (ao_parsed.ao_year > %s)
    )
    ORDER BY ao_parsed.ao_year, ao_parsed.ao_serial
"""

AO_ENTITIES = """
    SELECT
        e.name,
        et.description AS entity_type_description,
        r.description AS role_description
    FROM aouser.players p
    INNER JOIN aouser.entity e USING (entity_id)
    INNER JOIN aouser.entity_type et ON et.entity_type_id = e.type
    INNER JOIN aouser.role r USING (role_id)
    WHERE p.ao_id = %s
"""

AO_DOCUMENTS = """
    SELECT
        ao.ao_no,
        doc.document_id,
        doc.filename,
        doc.ocrtext,
        doc.fileimage,
        doc.description,
        doc.category,
        doc.document_date
    FROM aouser.document doc
    INNER JOIN aouser.ao ao
        ON ao.ao_id = doc.ao_id
    WHERE doc.ao_id = %s
"""

STATUTE_CITATION_REGEX = re.compile(
    r"(?P<title>\d+)\s+U\.?S\.?C\.?\s+§*\s*(?P<section>\d+).*\.?")

REGULATION_CITATION_REGEX = re.compile(
    r"(?P<title>\d+)\s+C\.?F\.?R\.?\s+§*\s*(?P<part>\d+)\.(?P<section>\d+)")

AO_CITATION_REGEX = re.compile(
    r"\b(?P<year>\d{4,4})-(?P<serial_no>\d+)\b")

AOS_WITH_CORRECTED_STAGE = {"2009-05": "Withdrawn"}


def load_advisory_opinions(from_ao_no=None):
    """
    Reads data for advisory opinions from a Postgres database,
    assembles a JSON document corresponding to the advisory opinion
    and indexes this document in Elasticsearch in the index `docs_index`
    with a doc_type of `advisory_opinions`.
    In addition, all documents attached to the advisory opinion
    are uploaded to an S3 bucket under the _directory_`legal/aos/`.
    """
    es = get_elasticsearch_connection()

    logger.info("Loading advisory opinions")
    ao_count = 0
    for ao in get_advisory_opinions(from_ao_no):
        logger.info("Loading AO: %s", ao['no'])
        es.index(DOCS_INDEX, 'advisory_opinions', ao, id=ao['no'])
        ao_count += 1
    logger.info("%d advisory opinions loaded", ao_count)


def ao_stage_to_pending(stage):

    return stage == 0


def ao_stage_to_status(ao_no, stage):

    if ao_no in AOS_WITH_CORRECTED_STAGE:
        return AOS_WITH_CORRECTED_STAGE[ao_no]
    if stage == 2:
        return "Withdrawn"
    elif stage == 1:
        return "Final"
    else:
        return "Pending"


def get_advisory_opinions(from_ao_no):
    bucket = get_bucket()

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
                "is_pending": ao_stage_to_pending(row["stage"]),
                "status": ao_stage_to_status(row["ao_no"], row["stage"]),
                "ao_citations": citations[row["ao_no"]]["ao"],
                "aos_cited_by": citations[row["ao_no"]]["aos_cited_by"],
                "statutory_citations": citations[row["ao_no"]]["statutes"],
                "regulatory_citations": citations[row["ao_no"]]["regulations"],
                "sort1": -year,
                "sort2": -serial,
            }
            ao["documents"] = get_documents(ao_id, bucket)
            (ao["requestor_names"], ao["requestor_types"], ao["commenter_names"],
                    ao["representative_names"], ao["entities"]) = get_entities(ao_id)

            yield ao


def get_entities(ao_id):
    requestor_names = []
    commenter_names = []
    representative_names = []
    requestor_types = set()
    entities = []
    with db.engine.connect() as conn:
        rs = conn.execute(AO_ENTITIES, ao_id)
        for row in rs:
            if row["role_description"] == "Requestor":
                requestor_names.append(row["name"])
                requestor_types.add(row["entity_type_description"])
            elif row["role_description"] == "Commenter":
                commenter_names.append(row["name"])
            elif row["role_description"] == "Counsel/Representative":
                representative_names.append(row["name"])
            entities.append({"role": row["role_description"],
                "name": row["name"],
                "type": row["entity_type_description"]})
    return requestor_names, list(requestor_types),\
            commenter_names, representative_names, entities


def get_documents(ao_id, bucket):
    documents = []
    with db.engine.connect() as conn:
        rs = conn.execute(AO_DOCUMENTS, ao_id)
        for row in rs:
            document = {
                "document_id": row["document_id"],
                "filename": row["filename"],
                "category": row["category"],
                "description": row["description"],
                "text": row["ocrtext"],
                "date": row["document_date"],
            }
            # TODO: Test this in dev - do spaces automatically get swapped with %?
            pdf_key = "legal/aos/{0}/{1}".format(row['ao_no'], row["filename"])
            logger.info("S3: Uploading {}".format(pdf_key))
            bucket.put_object(Key=pdf_key, Body=bytes(row["fileimage"]),
                    ContentType="application/pdf", ACL="public-read")
            document["url"] = '/files/' + pdf_key
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

    logger.debug("Getting citations...")

    rs = db.engine.execute("""SELECT ao_no, ocrtext FROM aouser.document
                                INNER JOIN aouser.ao USING (ao_id)
                              WHERE category = 'Final Opinion'""")

    all_regulatory_citations = set()
    all_statutory_citations = set()
    raw_citations = defaultdict(lambda: defaultdict(set))
    for row in rs:
        logger.debug("Getting citations for AO %s" % row["ao_no"])

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
            {"title": c[0], "section": c[1]}
            for c in raw_citations[ao]["statutes"]], key=lambda d: (d["title"], d["section"]))
        citations[ao]["regulations"] = sorted([
            {"title": c[0], "part": c[1], "section": c[2]}
            for c in raw_citations[ao]["regulations"]], key=lambda d: (d["title"], d["part"], d["section"]))

    es = get_elasticsearch_connection()

    for citation in all_regulatory_citations:
        entry = {'citation_text': '%d CFR §%d.%d'
                 % (citation[0], citation[1], citation[2]),'citation_type': 'regulation'}
        es.index(DOCS_INDEX, 'citations', entry, id=entry['citation_text'])

    for citation in all_statutory_citations:
        entry = {'citation_text': '%d U.S.C. §%d'
                 % (citation[0], citation[1]), 'citation_type': 'statute'}
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
                int(new_title),
                int(new_section)
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
