import logging
import re
from collections import defaultdict

import furl
from webservices import utils
from webservices.env import env
from webservices.rest import db
from webservices.tasks.utils import get_bucket

logger = logging.getLogger(__name__)

ALL_MURS = """
    SELECT case_id, case_no, name
    FROM fecmur.case
    WHERE case_type = 'MUR'
    LIMIT 2
"""

MUR_SUBJECTS = """
    SELECT subject.description AS subj, relatedsubject.description AS rel
    FROM fecmur.case_subject
    JOIN fecmur.subject USING (subject_id)
    LEFT OUTER JOIN fecmur.relatedsubject USING (subject_id, relatedsubject_id)
    WHERE case_id = %s
"""

MUR_PARTICIPANTS = """
    SELECT entity_id, name, role.description AS role
    FROM fecmur.players
    JOIN fecmur.role USING (role_id)
    JOIN fecmur.entity USING (entity_id)
    WHERE case_id = %s
"""

MUR_DOCUMENTS = """
    SELECT document_id, category, description, ocrtext,
        fileimage, length(fileimage) AS length,
        doc_order_id, document_date
    FROM fecmur.document
    WHERE case_id = %s
    ORDER BY doc_order_id, document_date desc, document_id DESC;
"""
# TODO: Check if document order matters

MUR_VIOLATIONS = """
    SELECT entity_id, stage, statutory_citation, regulatory_citation
    FROM fecmur.violations
    WHERE case_id = %s
    ;
"""

STATUTE_REGEX = re.compile(r'(?<!\()(?P<section>\d+[a-z]+)')
REGULATION_REGEX = re.compile(r'(?<!\()(?P<part>\d+)(\.(?P<section>\d+))*')

def load_current_murs():
    es = utils.get_elasticsearch_connection()
    bucket = get_bucket()
    bucket_name = env.get_credential('bucket')
    with db.engine.connect() as conn:
        rs = conn.execute(ALL_MURS)
        for row in rs:
            case_id = row['case_id']
            mur = {
                'doc_id': 'mur_%s' % row['case_no'],
                'no': row['case_no'],
                'name': row['name'],
                'mur_type': 'current',
            }
            mur['subject'] = ",".join(get_subjects(case_id))

            participants = get_participants(case_id)
            mur['participants'] = list(participants.values())
            assign_citations(participants, case_id)

            mur['text'], mur['documents'] = get_documents(case_id, bucket, bucket_name)
            # TODO pdf_pages, open_date, close_date, url
            es.index('docs', 'murs', mur, id=mur['doc_id'])

def get_participants(case_id):
    participants = {}
    with db.engine.connect() as conn:
        rs = conn.execute(MUR_PARTICIPANTS, case_id)
        for row in rs:
            participants[row['entity_id']] = {
                'name': row['name'],
                'role': row['role'],
                'citations': defaultdict(list)
            }
    return participants

def get_subjects(case_id):
    subjects = []
    with db.engine.connect() as conn:
        rs = conn.execute(MUR_SUBJECTS, case_id)
        for row in rs:
            if row['rel']:
                subject_str = row['subj'] + "-" + row['rel']
            else:
                subject_str = row['subj']
            subjects.append(subject_str)
    return subjects

def assign_citations(participants, case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(MUR_VIOLATIONS, case_id)
        for row in rs:
            if row['entity_id'] not in participants:
                logger.warn("Entity %s from violations not found in particpants for case %s", row['entity_id'], case_id)
                continue
            participants[row['entity_id']]['citations'][row['stage']].append(
                parse_citations(row['statutory_citation'], row['regulatory_citation']))

def parse_citations(statutory_citation, regulatory_citation):
    citations = []
    if statutory_citation:
        for match in STATUTE_REGEX.finditer(statutory_citation):
            url = furl.furl('https://api.fdsys.gov/link')
            url.args.update({
                'collection': 'uscode',
                'year': 'mostrecent',
                'link-type': 'html',
                'title': '2',
                'section': match.group('section')
            })
        citations.append(url.tostr())
    if regulatory_citation:
        for match in REGULATION_REGEX.finditer(regulatory_citation):
            url = furl.furl('https://api.fdsys.gov/link')
            url.args.update({
                'collection': 'cfr',
                'year': 'mostrecent',
                'titlenum': '11',
                'partnum': match.group('part')
            })
            if match.group('section'):
                url.args['sectionnum'] = match.group('section')
            citations.append(url.tostr())
    return citations

def get_documents(case_id, bucket, bucket_name):
    documents = []
    document_text = ""
    with db.engine.connect() as conn:
        rs = conn.execute(MUR_DOCUMENTS, case_id)
        for row in rs:
            document = {
                'document_id': row['document_id'],
                'category': row['category'],
                'description': row['description'],
                'length': row['length'],
                'document_date': row['document_date'],
            }
            document_text += ' ' + row['ocrtext']
            pdf_key = 'legal/murs/current/%s.pdf' % row['document_id']
            logger.info("S3: Uploading {}".format(pdf_key))
            bucket.put_object(Key=pdf_key, Body=bytes(row['fileimage']),
                              ContentType='application/pdf', ACL='public-read')
            document['url'] = "https://%s.s3.amazonaws.com/%s" % (bucket_name, pdf_key)
            documents.append(document)
    return document_text, documents

def as_citation_list(citation_dict):
    return [{'text': citation_text, 'url': citation_url}
            for citation_text, citation_url in citation_dict.items()]
