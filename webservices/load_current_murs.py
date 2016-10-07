import logging
import re
from collections import defaultdict
from urllib.parse import urlencode

from webservices.env import env
from webservices.rest import db
from webservices.utils import create_eregs_link, get_elasticsearch_connection
from webservices.tasks.utils import get_bucket

logger = logging.getLogger(__name__)

ALL_MURS = """
    SELECT case_id, case_no, name
    FROM fecmur.case
    WHERE case_type = 'MUR'
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

OPEN_AND_CLOSE_DATES = """
    SELECT min(event_date), max(event_date)
    FROM fecmur.calendar
    WHERE case_id = %s;
"""

DISPOSITION_DATA = """
    SELECT fecmur.event.event_name,
    fecmur.settlement.final_amount, fecmur.entity.name, violations.statutory_citation,
    violations.regulatory_citation
    from fecmur.calendar
    inner join fecmur.event on fecmur.calendar.event_id = fecmur.event.event_id
    inner join fecmur.entity on fecmur.entity.entity_id = fecmur.calendar.entity_id
    left join (select * from fecmur.relatedobjects where relation_id=1) AS relatedobjects
    on relatedobjects.detail_key = fecmur.calendar.entity_id
    left join fecmur.settlement on fecmur.settlement.settlement_id = relatedobjects.master_key
    left join (select * from fecmur.violations where stage='Closed' and case_id={0})
    as violations on violations.entity_id = fecmur.calendar.entity_id
    where fecmur.calendar.case_id={0} and event_name not in ('Complaint/Referral', 'Disposition')
    ORDER BY fecmur.event.event_name ASC, fecmur.settlement.final_amount DESC NULLS LAST, event_date DESC;
"""

DISPOSITION_TEXT = """
SELECT vote_date, action from fecmur.commission
WHERE case_id = %s
ORDER BY vote_date desc;
"""

STATUTE_REGEX = re.compile(r'(?<!\()(?P<section>\d+([a-z](-1)?)?)')
REGULATION_REGEX = re.compile(r'(?<!\()(?P<part>\d+)(\.(?P<section>\d+))*')

def load_current_murs():
    es = get_elasticsearch_connection()
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
            mur['subject'] = {"text": get_subjects(case_id)}

            participants = get_participants(case_id)
            mur['participants'] = list(participants.values())
            mur['disposition'] = get_disposition(case_id)
            mur['text'], mur['documents'] = get_documents(case_id, bucket, bucket_name)
            mur['open_date'], mur['close_date'] = get_open_and_close_dates(case_id)
            mur['url'] = '/legal/matter-under-review/%s/' % row['case_no']
            es.index('docs', 'murs', mur, id=mur['doc_id'])

def get_open_and_close_dates(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(OPEN_AND_CLOSE_DATES, case_id)
        open_date, close_date = rs.fetchone()
    return open_date, close_date

def get_disposition(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(DISPOSITION_DATA.format(case_id))
        disposition_data = []
        for row in rs:
            citations = parse_statutory_citations(row['statutory_citation'], case_id, row['name'])
            citations.extend(parse_regulatory_citations(row['regulatory_citation'], case_id, row['name']))
            disposition_data.append({'disposition': row['event_name'], 'penalty': row['final_amount'],
                'respondent': row['name'], 'citations': citations})

        rs = conn.execute(DISPOSITION_TEXT, case_id)
        disposition_text = []
        for row in rs:
            disposition_text.append({'vote_date': row['vote_date'], 'text': row['action']})
        return {'text': disposition_text, 'data': disposition_data}

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
            entity_id = row['entity_id']
            if entity_id not in participants:
                logger.warn("Entity %s from violations not found in participants for case %s", entity_id, case_id)
                continue
            participants[entity_id]['citations'][row['stage']].extend(
                parse_statutory_citations(row['statutory_citation'], case_id, entity_id))
            participants[entity_id]['citations'][row['stage']].extend(
                parse_regulatory_citations(row['regulatory_citation'], case_id, entity_id))

def parse_statutory_citations(statutory_citation, case_id, entity_id):
    citations = []
    if statutory_citation:
        for match in STATUTE_REGEX.finditer(statutory_citation):
            title, section = reclassify_statutory_citation(match.group('section'))
            url = 'https://api.fdsys.gov/link?' +\
                urlencode([
                    ('collection', 'uscode'),
                    ('year', 'mostrecent'),
                    ('link-type', 'html'),
                    ('title', title),
                    ('section', section)
                ])
            text = '%s U.S.C. %s' % (title, section)
            citations.append({'text': text, 'url': url})
        if not citations:
            logger.warn("Cannot parse statutory citation %s for Entity %s in case %s",
                    statutory_citation, entity_id, case_id)
    return citations

def parse_regulatory_citations(regulatory_citation, case_id, entity_id):
    citations = []
    if regulatory_citation:
        for match in REGULATION_REGEX.finditer(regulatory_citation):
            url = create_eregs_link(match.group('part'), match.group('section'))
            text = '11 C.F.R. %s' % match.group('part')
            if match.group('section'):
                text += '.%s' % match.group('section')
            citations.append({'text': text, 'url': url})
        if not citations:
            logger.warn("Cannot parse regulatory citation %s for Entity %s in case %s",
                    regulatory_citation, entity_id, case_id)
    return citations

def reclassify_statutory_citation(section):
    """
    Source: http://uscode.house.gov/editorialreclassification/t52/Reclassifications_Title_52.html
    """
    reclassifications = {
        '431': '30101',
        '432': '30102',
        '433': '30103',
        '434': '30104',
        '437': '30105',
        '437c': '30106',
        '437d': '30107',
        '437f': '30108',
        '437g': '30109',
        '437h': '30110',
        '438': '30111',
        '438a': '30112',
        '439': '30113',
        '439a': '30114',
        '439c': '30115',
        '441a': '30116',
        '441a-1': '30117',
        '441b': '30118',
        '441c': '30119',
        '441d': '30120',
        '441e': '30121',
        '441f': '30122',
        '441g': '30123',
        '441h': '30124',
        '441i': '30125',
        '441k': '30126',
        '451': '30141',
        '452': '30142',
        '453': '30143',
        '454': '30144',
        '455': '30145',
        '457': '30146',
    }

    return 52, reclassifications.get(section, section)

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
            document_text += row['ocrtext'] + ' '
            pdf_key = 'legal/murs/current/%s.pdf' % row['document_id']
            logger.info("S3: Uploading {}".format(pdf_key))
            bucket.put_object(Key=pdf_key, Body=bytes(row['fileimage']),
                    ContentType='application/pdf', ACL='public-read')
            document['url'] = "https://%s.s3.amazonaws.com/%s" % (bucket_name, pdf_key)
            documents.append(document)
    return document_text, documents
