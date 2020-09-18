import logging
import re
from collections import defaultdict

from webservices.env import env
from webservices.rest import db
from webservices.utils import extend, create_eregs_link, get_elasticsearch_connection
from webservices.tasks.utils import get_bucket

from .reclassify_statutory_citation import reclassify_statutory_citation_without_title

logger = logging.getLogger(__name__)

ALL_CASES = """
    SELECT
        case_id,
        case_no,
        name,
        case_type,
        published_flg
    FROM fecmur.cases_with_parsed_case_serial_numbers_vw
    WHERE case_type = %s
    ORDER BY case_serial
"""

SINGLE_CASE = """
    SELECT DISTINCT
        case_id,
        case_no,
        name,
        case_type,
        published_flg
    FROM fecmur.cases_with_parsed_case_serial_numbers_vw
    WHERE case_type = %s
    AND case_no = %s
"""

AF_SPECIFIC_FIELDS = """
    SELECT DISTINCT
        committee_id,
        report_year,
        report_type,
        rtb_action_date,
        rtb_fine_amount,
        chal_receipt_date,
        CASE chal_outcome_code_desc
            WHEN 'Upheld' THEN 'RTB Finding and Fine Upheld'
            WHEN 'Corrected' THEN 'RTB Finding Upheld but Fine Reduced'
            WHEN 'Waived' THEN 'No Fine Assessed at Final Determination'
            WHEN 'TERMINATED' THEN 'No Fine Assessed at Final Determination'
            ELSE chal_outcome_code_desc END
        AS chal_outcome_code_desc,
        fd_date,
        fd_final_fine_amount,
        check_amount,
        treasury_date,
        treasury_amount,
        petition_court_filing_date,
        petition_court_decision_date
    FROM fecmur.af_case
    WHERE case_id = %s
"""

CASE_SUBJECTS = """
    SELECT
        subject.description AS subj,
        relatedsubject.description AS rel
    FROM fecmur.case_subject
    JOIN fecmur.subject USING (subject_id)
    LEFT OUTER JOIN fecmur.relatedsubject USING (subject_id, relatedsubject_id)
    WHERE case_id = %s
"""

CASE_ELECTION_CYCLES = """
    SELECT
        election_cycle::INT
    FROM fecmur.electioncycle
    WHERE case_id = %s
"""

CASE_PARTICIPANTS = """
    SELECT
        entity_id,
        name,
        role.description AS role
    FROM fecmur.players
    JOIN fecmur.role USING (role_id)
    JOIN fecmur.entity USING (entity_id)
    WHERE case_id = %s
"""

CASE_DOCUMENTS = """
    SELECT
        doc.document_id,
        mur.case_no,
        mur.case_type,
        doc.filename,
        doc.category,
        doc.description,
        doc.ocrtext,
        doc.fileimage,
        length(fileimage) AS length,
        doc.doc_order_id,
        doc.document_date
    FROM fecmur.document doc
    INNER JOIN fecmur.cases_with_parsed_case_serial_numbers_vw mur
        ON mur.case_id = doc.case_id
    WHERE doc.case_id = %s
    ORDER BY doc.doc_order_id, doc.document_date desc, doc.document_id DESC;
"""

CASE_VIOLATIONS = """
    SELECT entity_id, stage, statutory_citation, regulatory_citation
    FROM fecmur.violations
    WHERE case_id = %s;
"""

OPEN_AND_CLOSE_DATES = """
    SELECT min(event_date), max(event_date)
    FROM fecmur.calendar
    WHERE case_id = %s;
"""

DISPOSITION_DATA = """
    SELECT fecmur.event.event_name,
        fecmur.settlement.final_amount, fecmur.entity.name,
        violations.statutory_citation, violations.regulatory_citation
    FROM fecmur.calendar
    INNER JOIN fecmur.event USING (event_id)
    INNER JOIN fecmur.entity USING (entity_id)
    LEFT JOIN
        (SELECT detail_key AS entity_id, master_key AS settlement_id
        FROM fecmur.relatedobjects
        INNER JOIN fecmur.settlement
            ON fecmur.relatedobjects.master_key = fecmur.settlement.settlement_id
        WHERE relation_id = 1
        AND fecmur.settlement.case_id = {0}) AS relatedobjects
        ON relatedobjects.entity_id = fecmur.calendar.entity_id
    LEFT JOIN fecmur.settlement USING (settlement_id)
    LEFT JOIN
        (SELECT *
        FROM fecmur.violations
        WHERE stage = 'Closed'
            AND case_id = {0}) AS violations
        ON violations.entity_id = fecmur.calendar.entity_id
    WHERE fecmur.calendar.case_id = {0}
        AND event_name NOT IN ('Complaint/Referral', 'Disposition')
    ORDER BY fecmur.event.event_name ASC, fecmur.settlement.final_amount DESC NULLS LAST, event_date DESC;
"""

MUR_ADR_COMMISSION_VOTES = """
    SELECT vote_date, action from fecmur.commission
    WHERE case_id = %s
    ORDER BY vote_date desc;
"""

AF_COMMISSION_VOTES = """
    SELECT action_date as vote_date, action from fecmur.af_case
    WHERE case_id = %s
    ORDER BY action_date desc;
"""

STATUTE_REGEX = re.compile(r'(?<!\(|\d)(?P<section>\d+([a-z](-1)?)?)')
REGULATION_REGEX = re.compile(r'(?<!\()(?P<part>\d+)(\.(?P<section>\d+))?')
CASE_NO_REGEX = re.compile(r'(?P<serial>\d+)')


def load_current_murs(specific_mur_no=None):
    load_cases('MUR', specific_mur_no)


def load_adrs(specific_adr_no=None):
    load_cases('ADR', specific_adr_no)


def load_admin_fines(specific_af_no=None):
    load_cases('AF', specific_af_no)


def get_es_type(case_type):
    case_type = case_type.upper()
    if case_type == 'AF':
        return 'admin_fines'
    elif case_type == 'ADR':
        return 'adrs'
    else:
        return 'murs'


def get_full_name(case_type):
    case_type = case_type.upper()
    if case_type == 'AF':
        return 'administrative-fine'
    elif case_type == 'ADR':
        return 'alternative-dispute-resolution'
    else:
        return 'matter-under-review'


def load_cases(case_type, case_no=None):
    """
    Reads data for current MURs, AFs, and ADRs from a Postgres database,
    assembles a JSON document corresponding to the case, and indexes this document
    in Elasticsearch in the index `docs_index` with a doc_type of `murs`, `adrs`, or `admin_fines`.
    In addition, all documents attached to the case are uploaded to an
    S3 bucket under the _directory_ `legal/<doc_type>/<id>/`.
    """
    if case_type in ('MUR', 'ADR', 'AF'):
        es = get_elasticsearch_connection()
        logger.info("TEST MESSAGE 4: current_cases es")
        logger.info("Loading {0}(s)".format(case_type))
        case_count = 0
        for case in get_cases(case_type, case_no):
            logger.info("TEST MESSAGE 5: case found in get_cases")
            if case is not None:
                logger.info("TEST 6: case.get('published_flg') {0}".format(case.get('published_flg')))
                if case.get('published_flg'):
                    logger.info("Loading {0}: {1}".format(case_type, case['no']))
                    es.index('docs_index', get_es_type(case_type), case, id=case['doc_id'])
                    case_count += 1
                    logger.info("{0} {1}(s) loaded".format(case_count, case_type))
                else:
                    logger.info("Found an unpublished case - deleting {0}: {1} from ES".format(case_type, case['no']))
                    es.delete_by_query(index='docs_index', body={'query': {"term": {"no": case['no']}}},
                        doc_type=get_es_type(case_type))
                    logger.info('Successfully deleted {} {} from ES'.format(case_type, case['no']))
    else:
        logger.error("Invalid case_type: must be 'MUR', 'ADR', or 'AF'.")


def get_cases(case_type, case_no=None):
    """
    Takes a specific case to load.
    If none are specified, all cases are reloaded
    Unlike AOs, cases are not published in sequential order.
    """
    if case_no is None:
        logger.info("TEST MESSAGE 7: get_cases (case is None) {0}: {1}".format(case_type, case_no))
        with db.engine.connect() as conn:
            rs = conn.execute(ALL_CASES, case_type)
            for row in rs:
                yield get_single_case(case_type, row['case_no'])
    else:
        logger.info("TEST MESSAGE 8: get_cases (case is not None) {0}: {1}".format(case_type, case_no))
        yield get_single_case(case_type, case_no)


def get_single_case(case_type, case_no):
    bucket = get_bucket()
    bucket_name = env.get_credential('bucket')
    logger.info("TEST MESSAGE 9: get_single_case")
    with db.engine.connect() as conn:
        rs = conn.execute(SINGLE_CASE, case_type, case_no)
        row = rs.first()
        if row is not None:
            logger.info("TEST MESSAGE 10: get_single_case, row is not None")
            case_id = row['case_id']
            sort1, sort2 = get_sort_fields(row['case_no'])
            case = {
                'doc_id': '{0}_{1}'.format(case_type.lower(), row['case_no']),
                'no': row['case_no'],
                'name': row['name'],
                'published_flg': row['published_flg'],
                'sort1': sort1,
                'sort2': sort2,
            }
            case['commission_votes'] = get_commission_votes(case_type, case_id)
            case['documents'] = get_documents(case_id, bucket, bucket_name)
            case['url'] = '/legal/{0}/{1}/'.format(get_full_name(case_type), row['case_no'])
            if case_type == 'AF':
                case = extend(case, get_af_specific_fields(case_id))
                return case
            if case_type == 'MUR':
                case['mur_type'] = 'current'
            case['subjects'] = get_subjects(case_id)
            case['election_cycles'] = get_election_cycles(case_id)
            participants = get_participants(case_id)
            case['participants'] = list(participants.values())
            case['respondents'] = get_sorted_respondents(case['participants'])

            case['dispositions'] = get_dispositions(case_id)

            case['open_date'], case['close_date'] = get_open_and_close_dates(case_id)
            return case
        else:
            logger.info("TEST MESSAGE 11: row is None")
            logger.error("Not a valid {0} number.".format(case_type))
            return None


def get_af_specific_fields(case_id):
    case = {}
    with db.engine.connect() as conn:
        rs = conn.execute(AF_SPECIFIC_FIELDS, case_id)
        row = rs.first()
        if row is not None:
            case["committee_id"] = row["committee_id"]
            case["report_year"] = row["report_year"]
            case["report_type"] = row["report_type"]
            case["reason_to_believe_action_date"] = row["rtb_action_date"]
            case["reason_to_believe_fine_amount"] = row["rtb_fine_amount"]
            case["challenge_receipt_date"] = row["chal_receipt_date"]
            case["challenge_outcome"] = row["chal_outcome_code_desc"]
            case["final_determination_date"] = row["fd_date"]
            case["final_determination_amount"] = row["fd_final_fine_amount"]
            case["check_amount"] = row["check_amount"]
            case["treasury_referral_date"] = row["treasury_date"]
            case["treasury_referral_amount"] = row["treasury_amount"]
            case["petition_court_filing_date"] = row["petition_court_filing_date"]
            case["petition_court_decision_date"] = row["petition_court_decision_date"]
    return case


def get_election_cycles(case_id):
    election_cycles = []
    with db.engine.connect() as conn:
        rs = conn.execute(CASE_ELECTION_CYCLES, case_id)
        for row in rs:
            election_cycles.append(row['election_cycle'])
    return election_cycles


def get_open_and_close_dates(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(OPEN_AND_CLOSE_DATES, case_id)
        open_date, close_date = rs.fetchone()
    return open_date, close_date


def get_dispositions(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(DISPOSITION_DATA.format(case_id))
        disposition_data = []
        for row in rs:
            citations = parse_statutory_citations(row['statutory_citation'], case_id, row['name'])
            citations.extend(parse_regulatory_citations(row['regulatory_citation'], case_id, row['name']))
            disposition_data.append({'disposition': row['event_name'], 'penalty': row['final_amount'],
                'respondent': row['name'], 'citations': citations})

        return disposition_data


def get_commission_votes(case_type, case_id):
    with db.engine.connect() as conn:
        if case_type == 'AF':
            rs = conn.execute(AF_COMMISSION_VOTES, case_id)
        else:
            rs = conn.execute(MUR_ADR_COMMISSION_VOTES, case_id)
        commission_votes = []
        for row in rs:
            commission_votes.append({'vote_date': row['vote_date'], 'action': row['action']})
        return commission_votes


def get_participants(case_id):
    participants = {}
    with db.engine.connect() as conn:
        rs = conn.execute(CASE_PARTICIPANTS, case_id)
        for row in rs:
            participants[row['entity_id']] = {
                'name': row['name'],
                'role': row['role'],
                'citations': defaultdict(list)
            }
    return participants


def get_sorted_respondents(participants):
    """
    Returns the respondents in a MUR sorted in the order of most important to least important
    """
    SORTED_RESPONDENT_ROLES = ['Primary Respondent', 'Respondent', 'Previous Respondent']
    respondents = []
    for role in SORTED_RESPONDENT_ROLES:
        respondents.extend(sorted([p['name'] for p in participants if p['role'] == role]))
    return respondents


def get_subjects(case_id):
    subjects = []
    with db.engine.connect() as conn:
        rs = conn.execute(CASE_SUBJECTS, case_id)
        for row in rs:
            if row['rel']:
                subject_str = row['subj'] + "-" + row['rel']
            else:
                subject_str = row['subj']
            subjects.append(subject_str)
    return subjects


def assign_citations(participants, case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(CASE_VIOLATIONS, case_id)
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
        statutory_citation = remove_reclassification_notes(statutory_citation)
        matches = list(STATUTE_REGEX.finditer(statutory_citation))
        for index, match in enumerate(matches):
            section = match.group('section')
            orig_title, new_title, new_section = reclassify_statutory_citation_without_title(section)
            url = 'https://www.govinfo.gov/link/uscode/{0}/{1}'.format(new_title, new_section)
            if index == len(matches) - 1:
                match_text = statutory_citation[match.start():]
            else:
                match_text = statutory_citation[match.start():matches[index + 1].start()]
            text = match_text.rstrip(' ,;')
            citations.append({'text': text, 'type': 'statute', 'title': orig_title, 'url': url})
        if not citations:
            logger.warn("Cannot parse statutory citation %s for Entity %s in case %s",
                    statutory_citation, entity_id, case_id)
    return citations


def parse_regulatory_citations(regulatory_citation, case_id, entity_id):
    citations = []
    if regulatory_citation:
        matches = list(REGULATION_REGEX.finditer(regulatory_citation))
        for index, match in enumerate(matches):
            part = match.group('part')
            section = match.group('section')
            url = create_eregs_link(part, section)
            if index == len(matches) - 1:
                match_text = regulatory_citation[match.start():]
            else:
                match_text = regulatory_citation[match.start():matches[index + 1].start()]
            text = match_text.rstrip(' ,;')
            citations.append({'text': text, 'type': 'regulation', 'title': '11', 'url': url})
        if not citations:
            logger.warn("Cannot parse regulatory citation %s for Entity %s in case %s",
                    regulatory_citation, entity_id, case_id)
    return citations


def get_documents(case_id, bucket, bucket_name):
    documents = []
    with db.engine.connect() as conn:
        rs = conn.execute(CASE_DOCUMENTS, case_id)
        for row in rs:
            document = {
                'document_id': row['document_id'],
                'category': row['category'],
                'description': row['description'],
                'length': row['length'],
                'text': row['ocrtext'],
                'document_date': row['document_date'],
            }
            if not row['fileimage']:
                logger.error(
                    'Error uploading document ID {0} for {1} %{2}: No file image'.
                    format(row['document_id'], row['case_type'], row['case_no']))
            else:
                pdf_key = 'legal/{0}/{1}/{2}'.format(get_es_type(row['case_type']), row['case_no'],
                    row['filename'].replace(' ', '-'))
                document['url'] = '/files/' + pdf_key
                logger.debug("S3: Uploading {}".format(pdf_key))
                bucket.put_object(Key=pdf_key, Body=bytes(row['fileimage']),
                        ContentType='application/pdf', ACL='public-read')
                documents.append(document)

    return documents


def remove_reclassification_notes(statutory_citation):
    """ Statutory citations include notes on reclassification of the form
    "30120 (formerly 441d)" and "30120 (formerly 432(e)(1))". These need to be
    removed as we explicitly perform the necessary reclassifications.
    """
    UNPARENTHESIZED_FORMERLY_REGEX = re.compile(r' formerly \S*')
    PARENTHESIZED_FORMERLY_REGEX = re.compile(r'\(formerly ')

    def remove_to_matching_parens(citation):
        """ In the case of reclassification notes of the form "(formerly ...",
        remove all characters up to the matching closing ')' allowing for nested
        parentheses pairs.
        """
        match = PARENTHESIZED_FORMERLY_REGEX.search(citation)
        pos = match.end()
        paren_count = 0
        while pos < len(citation):
            if citation[pos] == ')':
                if paren_count == 0:
                    return citation[:match.start()] + citation[pos + 1:]
                else:
                    paren_count -= 1
            elif citation[pos] == '(':
                paren_count += 1
            pos += 1
        return citation[:match.start()]  # Degenerate case - no matching ')'

    cleaned_citation = UNPARENTHESIZED_FORMERLY_REGEX.sub(' ', statutory_citation)
    while PARENTHESIZED_FORMERLY_REGEX.search(cleaned_citation):
        cleaned_citation = remove_to_matching_parens(cleaned_citation)
    return cleaned_citation


def get_sort_fields(case_no):
    match = CASE_NO_REGEX.match(case_no)
    return -int(match.group("serial")), None
