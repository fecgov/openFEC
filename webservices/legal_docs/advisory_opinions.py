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
    SELECT ao_id, ao_no, name, summary,
        CASE WHEN finished IS NULL THEN TRUE ELSE FALSE END AS is_pending
    FROM aouser.ao
    LEFT JOIN (SELECT DISTINCT ao_id AS finished
               FROM aouser.document
               WHERE category IN ('Final Opinion', 'Withdrawal of Request')) AS finished
    ON ao.ao_id = finished.finished
    LIMIT 1
"""

AO_REQUESTORS = """
    SELECT e.name, et.description
    FROM aouser.players p
    INNER JOIN aouser.entity e USING (entity_id)
    INNER JOIN aouser.entity_type et ON et.entity_type_id = e.type
    WHERE p.ao_id = %s AND role_id IN (0, 1)
"""

AO_DOCUMENTS = """
    SELECT document_id, ocrtext, fileimage, description, category, document_date
    FROM aouser.document
    WHERE ao_id = %s
"""


STATUTE_REGEX = re.compile(r'(?<!\(|\d)(?P<section>\d+([a-z](-1)?)?)')
REGULATION_REGEX = re.compile(r'(?<!\()(?P<part>\d+)(\.(?P<section>\d+))?')

def load_advisory_opinions():
    """
    TODO
    """
    es = get_elasticsearch_connection()
    bucket = get_bucket()
    bucket_name = env.get_credential('bucket')

    citations, cited_by = get_ao_citations()
    with db.engine.connect() as conn:
        rs = conn.execute(ALL_AOS)
        for row in rs:
            ao_id = row['ao_id']
            ao = {
                "no": row['ao_no'],
                "name": row['name'],
                "summary": row['summary'],
                "is_pending": row['is_pending'],
                "citations": citations[row['ao_no']],
                "cited_by": cited_by[row['ao_no']] if row['ao_no'] in cited_by else []
            }
            ao['documents'] = get_documents(ao_id, bucket, bucket_name)
            requestor_names, requestor_types = get_requestors(ao_id)
            ao['requestor_names'] = requestor_names
            ao['requestor_types'] = requestor_types
            es.index(DOCS_INDEX, 'advisory_opinions', ao, id=ao['no'])

def get_requestors(ao_id):
    requestor_names = []
    requestor_types = set()
    with db.engine.connect() as conn:
        rs = conn.execute(AO_REQUESTORS, ao_id)
        for row in rs:
            requestor_names.append(row['name'])
            requestor_types.add(row['description'])
    return requestor_names, list(requestor_types)

def get_documents(ao_id, bucket, bucket_name):
    documents = []
    with db.engine.connect() as conn:
        rs = conn.execute(AO_DOCUMENTS, ao_id)
        for row in rs:
            document = {
                'document_id': row['document_id'],
                'category': row['category'],
                'description': row['description'],
                'text': row['ocrtext'],
                'document_date': row['document_date'],
            }
            pdf_key = 'legal/aos/%s.pdf' % row['document_id']
            logger.info("S3: Uploading {}".format(pdf_key))
            bucket.put_object(Key=pdf_key, Body=bytes(row['fileimage']),
                    ContentType='application/pdf', ACL='public-read')
            document['url'] = "https://%s.s3.amazonaws.com/%s" % (bucket_name, pdf_key)
            documents.append(document)
    return documents

def get_ao_citations():
    AO_CITATION_REGEX = re.compile(r'\b\d{4,4}-\d+\b')

    logger.info("Getting AO citations...")

    ao_names_results = db.engine.execute("""SELECT ao_no, name FROM aouser.ao""")
    ao_names = {}
    for row in ao_names_results:
        ao_names[row['ao_no']] = row['name']

    rs = db.engine.execute("""SELECT ao_no, ocrtext FROM aouser.document
                                INNER JOIN aouser.ao USING (ao_id)
                              WHERE category = 'Final Opinion'""")
    citations = defaultdict(set)
    cited_by = defaultdict(set)
    for row in rs:
        logger.info("Getting citations for %s" % row['ao_no'])
        text = row['ocrtext'] or ''

        citations_in_doc = set()
        for citation in AO_CITATION_REGEX.findall(text):
            if citation != row['ao_no'] and citation in ao_names:
                citations_in_doc.add(citation)

        citations[(row['ao_no'])].update(citations_in_doc)

        for citation in citations_in_doc:
            cited_by[citation].add(row['ao_no'])

    citations_with_names = {}
    for ao, citations_in_ao in citations.items():
        citations_with_names[ao] = sorted([
            {'no': c, 'name': ao_names[c]}
            for c in citations_in_ao], key=lambda d: d['no'])

    cited_by_with_names = {}
    for citation, cited_by_set in cited_by.items():
        cited_by_with_names[citation] = sorted([
            {'no': c, 'name': ao_names[c]}
            for c in cited_by_set], key=lambda d: d['no'])

    return citations_with_names, cited_by_with_names
