import logging
import re
from webservices.rest import db
from webservices.utils import (
    extend,
    create_es_client,
    create_eregs_link,
    DateTimeEncoder,
)
from webservices.tasks.utils import get_bucket
from .es_management import (  # noqa
    CASE_ALIAS,
)
from .reclassify_statutory_citation import reclassify_statutory_citation_without_title
import json


logger = logging.getLogger(__name__)

# for debug, uncomment this line
# logger.setLevel(logging.DEBUG)

ALL_CASES = """
    SELECT
        case_id,
        case_no,
        case_serial,
        name,
        case_type,
        published_flg
    FROM fecmur.cases_with_parsed_case_serial_numbers_vw
    WHERE case_type = %s
    ORDER BY case_serial desc
"""

SINGLE_CASE = """
    SELECT DISTINCT
        case_id,
        case_no,
        case_serial,
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
        petition_court_decision_date,
        civil_penalty_due_date,
        civil_penalty_pymt_status_flg
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
        doc.document_id as document_id,
        mur.case_no as case_no,
        mur.case_type as case_type,
        doc.filename as filename,
        doo.category as category,
        doc.description as description,
        doc.ocrtext as ocrtext,
        doc.fileimage as fileimage,
        length(fileimage) AS length,
        doc.doc_order_id as doc_order_id,
        doc.document_date as document_date
    FROM fecmur.document doc
    INNER JOIN fecmur.cases_with_parsed_case_serial_numbers_vw mur
        ON mur.case_id = doc.case_id
    INNER JOIN fecmur.doc_order doo
        ON doo.doc_order_id= doc.doc_order_id
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

AF_DISPOSITION_DATA = """
   SELECT
        amount,
        dates,
        description
    FROM fecmur.af_case_disposition
    WHERE case_id = %s
    ORDER BY dates ASC;

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

MUR_COMMISSION_VOTES = """
    SELECT vote_date, action from fecmur.commission
    WHERE case_id = %s
    ORDER BY vote_date desc;
"""
ADR_COMMISSION_VOTES = """
    SELECT DISTINCT c."action", c.vote_date , e.name as commissioner_name,  v.vote_type
    FROM fecmur.COMMISSION c, fecmur.votes v, fecmur.entity e
    WHERE c.CASE_ID = %s
    AND c.commission_id = v.commission_id
    AND e.entity_id =  v.entity_id
    ORDER BY c.vote_date desc;
"""
ADR_COMPLAINANT = """
   SELECT name as complainant_name
   FROM fecmur.players
   JOIN fecmur.role USING (role_id)
   JOIN fecmur.entity USING (entity_id)
   WHERE  players.case_id = %s
   AND players.role_id IN (100095)
"""

ADR_NON_MONETARY_TERMS = """
    SELECT DISTINCT nt.term_description, nt.term_id
    FROM fecmur.case c, fecmur.SETTLEMENT s, fecmur.RELATEDOBJECTS r, fecmur.NON_MONETARY_TERM NT
    WHERE c.case_id = %s
    AND c.case_id = s.case_id
    AND UPPER (SETTLEMENT_TYPE) LIKE 'PENALTY'
    AND r.RELATION_ID = 8
    AND r.MASTER_KEY = s.settlement_id
    AND R.DETAIL_KEY = NT.TERM_ID
"""

ADR_NON_MONETARY_TERMS_RESPONDENTS = """
    SELECT detail_key AS entity_id, master_key AS settlement_id, fecmur.entity.name
    FROM fecmur.relatedobjects
    INNER JOIN fecmur.entity
        ON fecmur.entity.entity_id = fecmur.relatedobjects.detail_key
    INNER JOIN fecmur.settlement
        ON fecmur.relatedobjects.master_key = fecmur.settlement.settlement_id
    WHERE relation_id = 1
    AND fecmur.settlement.case_id = %s
"""

ADR_CITATIONS = """
    SELECT DISTINCT VIOLATIONS.statutory_citation, VIOLATIONS.regulatory_citation, entity.name, entity.entity_id
    FROM  fecmur.VIOLATIONS, fecmur.ENTITY
    WHERE VIOLATIONS.case_id = %s
    AND VIOLATIONS.ENTITY_ID = ENTITY.ENTITY_ID
    AND (case when trim(VIOLATIONS.STAGE) = ''
    or VIOLATIONS.STAGE is null then 'None'
    else upper(VIOLATIONS.STAGE)
    end)in(select case when trim(STAGE_ORDER.STAGE)=''
    or STAGE_ORDER.STAGE is null then 'None'
    else upper(STAGE_ORDER.STAGE)
    end
    from fecmur.STAGE_ORDER)
    ORDER BY entity.name
"""

AF_COMMISSION_VOTES = """
    SELECT action_date as vote_date, action from fecmur.af_case
    WHERE case_id = %s
    ORDER BY action_date desc;
"""

""" For ADR's populate case_status based on event_name"""
adr_case_status_map = {
    "Dismissed": "Case Dismissed",
    "Settlement Agreement - Complaint Unsubstantiated": "Negotiated Settlement Approved",
    "Dismissed - Agreement Rejected": "Negotiated Settlement Rejected by Commission",
    "Dismissed - Failed to Approve": "Case Dismissed"
}

STATUTE_REGEX = re.compile(r"(?<!\(|\d)(?P<section>\d+([a-z](-1)?)?)")
REGULATION_REGEX = re.compile(r"(?<!\()(?P<part>\d+)(\.(?P<section>\d+))?")
CASE_NO_REGEX = re.compile(r"(?P<serial>\d+)")


def load_current_murs(specific_mur_no=None):
    """
    Reads data for current MURs from a Postgres database,
    assembles a JSON document corresponding to the case, and indexes this document
    in Elasticsearch in the CASE_ALIAS of CASE_INDEX with a type=`murs`.
    In addition, all documents attached to the case are uploaded to an
    S3 bucket under the _directory_ `legal/<doc_type>/<id>/`.
    """
    load_cases("MUR", specific_mur_no)


def load_adrs(specific_adr_no=None):
    """
    Reads data for ADRs from a Postgres database,
    assembles a JSON document corresponding to the case, and indexes this document
    in Elasticsearch the CASE_ALIAS of CASE_INDEX with a type=`adrs`.
    In addition, all documents attached to the case are uploaded to an
    S3 bucket under the _directory_ `legal/<doc_type>/<id>/`.
    """
    load_cases("ADR", specific_adr_no)


def load_admin_fines(specific_af_no=None):
    """
    Reads data for AFs from a Postgres database,
    assembles a JSON document corresponding to the case, and indexes this document
    in Elasticsearch the CASE_ALIAS of CASE_INDEX with a type=`admin_fines`.
    In addition, all documents attached to the case are uploaded to an
    S3 bucket under the _directory_ `legal/<doc_type>/<id>/`.
    """
    load_cases("AF", specific_af_no)


def get_es_type(case_type):
    case_type = case_type.upper()
    if case_type == "AF":
        return "admin_fines"
    elif case_type == "ADR":
        return "adrs"
    else:
        return "murs"


def get_full_name(case_type):
    case_type = case_type.upper()
    if case_type == "AF":
        return "administrative-fine"
    elif case_type == "ADR":
        return "alternative-dispute-resolution"
    else:
        return "matter-under-review"


def load_cases(case_type, case_no=None):
    # TO DO: check if CASE_ALIAS exist before uploading.
    if case_type in ("MUR", "ADR", "AF"):
        es_client = create_es_client()
        logger.info("Loading {0}(s)".format(case_type))
        case_count = 0
        for case in get_cases(case_type, case_no):
            if case is not None:
                if case.get("published_flg"):
                    logger.info("Loading {0}: {1}".format(case_type, case["no"]))
                    es_client.index(CASE_ALIAS, case, id=case["doc_id"])
                    case_count += 1
                    logger.info("{0} {1}(s) loaded".format(case_count, case_type))
                else:
                    try:
                        logger.info("Found an unpublished case - deleting {0}: {1} from ES".format(
                            case_type, case["no"]))
                        es_client.delete(index=CASE_ALIAS, id=case["doc_id"])
                        logger.info("Successfully deleted {} {} from ES".format(case_type, case["no"]))
                    except Exception as err:
                        logger.error("An error occurred while deteting an unpublished case.{0} {1} {2}".format(
                            case_type, case["no"], err))

            # ==for local dubug use: remove the big "documents" section to display the object "case_type" data
            debug_case_data = case
            del debug_case_data["documents"]
            logger.debug("case_data count=" + str(case_count))
            logger.debug("debug_case_data =" + json.dumps(debug_case_data, indent=3, cls=DateTimeEncoder))

    else:
        logger.error("Invalid case_type: must be 'MUR', 'ADR', or 'AF'.")


def get_cases(case_type, case_no=None):
    """
    Takes a specific case to load.
    If none are specified, all cases are reloaded
    Unlike AOs, cases are not published in sequential order.
    """
    bucket = get_bucket()

    if case_no is None:
        with db.engine.connect() as conn:
            rs = conn.execute(ALL_CASES, case_type)
            for row in rs:
                yield get_single_case(case_type, row["case_no"], bucket)
    else:
        yield get_single_case(case_type, case_no, bucket)


def get_single_case(case_type, case_no, bucket):
    # bucket = get_bucket()

    with db.engine.connect() as conn:
        rs = conn.execute(SINGLE_CASE, case_type, case_no)
        row = rs.first()
        if row is not None:
            case_id = row["case_id"]
            sort1, sort2 = get_sort_fields(row["case_no"])
            case = {
                "type": get_es_type(case_type),
                "doc_id": "{0}_{1}".format(case_type.lower(), row["case_no"]),
                "no": row["case_no"],
                "case_serial": row["case_serial"],
                "name": row["name"],
                "published_flg": row["published_flg"],
                "sort1": sort1,
                "sort2": sort2,
            }
            if case_type == "ADR":
                case["commission_votes"] = get_adr_commission_votes(case_id)
                case["complainant"] = get_adr_complainant(case_id)
                case["non_monetary_terms"] = get_adr_non_monetary_terms(case_id)
                case["non_monetary_terms_respondents"] = get_adr_non_monetary_terms_respondents(case_id)
                case["citations"] = get_adr_citations(case_id)
                case["adr_dispositions"] = get_adr_dispositions(case_id)
                case["case_status"] = get_adr_case_status(case_id)
            else:
                case["commission_votes"] = get_commission_votes(case_type, case_id)
            case["documents"] = get_documents(case_id, bucket)
            case["url"] = "/legal/{0}/{1}/".format(get_full_name(case_type), row["case_no"])
            if case_type == "AF":
                case = extend(case, get_af_specific_fields(case_id))
                return case
            if case_type == "MUR":
                case["mur_type"] = "current"
                case["dispositions"] = get_dispositions(case_id)
            case["subjects"] = get_subjects(case_id)
            case["election_cycles"] = get_election_cycles(case_id)
            participants = get_participants(case_id)
            case["participants"] = list(participants.values())
            case["respondents"] = get_sorted_respondents(case["participants"])
            case["open_date"], case["close_date"] = get_open_and_close_dates(case_id)
            return case
        else:
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
            case["payment_amount"] = row["check_amount"]
            case["treasury_referral_date"] = row["treasury_date"]
            case["treasury_referral_amount"] = row["treasury_amount"]
            case["petition_court_filing_date"] = row["petition_court_filing_date"]
            case["petition_court_decision_date"] = row["petition_court_decision_date"]
            case["civil_penalty_due_date"] = row["civil_penalty_due_date"]
            case["civil_penalty_payment_status"] = row["civil_penalty_pymt_status_flg"]
            case["af_dispositions"] = get_af_dispositions(case_id)
    return case


def get_election_cycles(case_id):
    election_cycles = []
    with db.engine.connect() as conn:
        rs = conn.execute(CASE_ELECTION_CYCLES, case_id)
        for row in rs:
            election_cycles.append(row["election_cycle"])
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
            citations = parse_statutory_citations(row["statutory_citation"], case_id, row["name"])
            citations.extend(parse_regulatory_citations(row["regulatory_citation"], case_id, row["name"]))
            disposition_data.append(
                {"disposition": row["event_name"], "penalty": row["final_amount"],
                 "respondent": row["name"], "citations": citations}
            )
        return disposition_data


def get_adr_dispositions(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(DISPOSITION_DATA.format(case_id))
        adr_dispositions = []
        for row in rs:
            adr_dispositions.append({"disposition": row["event_name"], "penalty": row["final_amount"],
                                     "respondent": row["name"]})

        return adr_dispositions


def get_adr_case_status(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(DISPOSITION_DATA.format(case_id))
        case_status = []
        for row in rs:
            disposition_description = row["event_name"]
            if adr_case_status_map.get(disposition_description) is not None:
                case_status = adr_case_status_map.get(disposition_description)
            else:
                case_status = "No status found"
        return case_status


def get_af_dispositions(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(AF_DISPOSITION_DATA, case_id)
        disposition_data = []
        for row in rs:
            disposition_data.append({"disposition_description": row["description"],
                                     "disposition_date": row["dates"], "amount": row["amount"]})

        return disposition_data


def get_commission_votes(case_type, case_id):
    with db.engine.connect() as conn:
        if case_type == "AF":
            rs = conn.execute(AF_COMMISSION_VOTES, case_id)
        elif case_type == "MUR":
            rs = conn.execute(MUR_COMMISSION_VOTES, case_id)
        commission_votes = []
        for row in rs:
            commission_votes.append({"vote_date": row["vote_date"], "action": row["action"]})
        return commission_votes


def get_adr_commission_votes(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(ADR_COMMISSION_VOTES, case_id)
        commission_votes = []
        for row in rs:
            commission_votes.append({"vote_date": row["vote_date"], "action": row["action"],
                                     "commissioner_name": row["commissioner_name"], "vote_type": row["vote_type"]})
        return commission_votes


def get_adr_non_monetary_terms(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(ADR_NON_MONETARY_TERMS, case_id)
        non_monetary_terms = []
        for row in rs:
            non_monetary_terms.append(row["term_description"])
        return non_monetary_terms


def get_adr_non_monetary_terms_respondents(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(ADR_NON_MONETARY_TERMS_RESPONDENTS, case_id)
        non_monetary_terms_repondents = []
        for row in rs:
            non_monetary_terms_repondents.append(row["name"])
        return non_monetary_terms_repondents


def get_adr_citations(case_id):
    citations = []
    with db.engine.connect() as conn:
        rs = conn.execute(ADR_CITATIONS, case_id)
        for row in rs:
            citations = parse_statutory_citations(row["statutory_citation"], case_id, row["name"])
            citations.extend(parse_regulatory_citations(row["regulatory_citation"], case_id, row["name"]))
        return citations


def get_adr_complainant(case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(ADR_COMPLAINANT, case_id)
        complainant = []
        for row in rs:
            complainant.append(row["complainant_name"])
        return complainant


def get_participants(case_id):
    participants = {}
    with db.engine.connect() as conn:
        rs = conn.execute(CASE_PARTICIPANTS, case_id)
        for row in rs:
            participants[row["entity_id"]] = {
                "name": row["name"],
                "role": row["role"]
            }
    return participants


def get_sorted_respondents(participants):
    """
    Returns the respondents in a MUR sorted in the order of most important to least important
    """
    SORTED_RESPONDENT_ROLES = ["Primary Respondent", "Respondent", "Previous Respondent"]
    respondents = []
    for role in SORTED_RESPONDENT_ROLES:
        respondents.extend(sorted([p["name"] for p in participants if p["role"] == role]))
    return respondents


def get_subjects(case_id):
    subjects = []
    with db.engine.connect() as conn:
        rs = conn.execute(CASE_SUBJECTS, case_id)
        for row in rs:
            if row["rel"]:
                subject_str = row["subj"] + "-" + row["rel"]
            else:
                subject_str = row["subj"]
            subjects.append(subject_str)
    return subjects


def assign_citations(participants, case_id):
    with db.engine.connect() as conn:
        rs = conn.execute(CASE_VIOLATIONS, case_id)
        for row in rs:
            entity_id = row["entity_id"]
            if entity_id not in participants:
                logger.warn("Entity %s from violations not found in participants for case %s", entity_id, case_id)
                continue
            participants[entity_id]["citations"][row["stage"]].extend(
                parse_statutory_citations(row["statutory_citation"], case_id, entity_id))
            participants[entity_id]["citations"][row["stage"]].extend(
                parse_regulatory_citations(row["regulatory_citation"], case_id, entity_id))


def parse_statutory_citations(statutory_citation, case_id, entity_id):
    citations = []
    if statutory_citation:
        statutory_citation = remove_reclassification_notes(statutory_citation)
        matches = list(STATUTE_REGEX.finditer(statutory_citation))
        for index, match in enumerate(matches):
            section = match.group("section")
            orig_title, new_title, new_section = reclassify_statutory_citation_without_title(section)
            url = "https://www.govinfo.gov/link/uscode/{0}/{1}".format(new_title, new_section)
            if index == len(matches) - 1:
                match_text = statutory_citation[match.start():]
            else:
                match_text = statutory_citation[match.start():matches[index + 1].start()]
            text = match_text.rstrip(" ,;")
            citations.append({"text": text, "type": "statute", "title": orig_title, "url": url})
        if not citations:
            logger.warn("Cannot parse statutory citation %s for Entity %s in case %s",
                        statutory_citation, entity_id, case_id)
    return citations


def parse_regulatory_citations(regulatory_citation, case_id, entity_id):
    citations = []
    if regulatory_citation:
        matches = list(REGULATION_REGEX.finditer(regulatory_citation))
        for index, match in enumerate(matches):
            part = match.group("part")
            section = match.group("section")
            url = create_eregs_link(part, section)
            if index == len(matches) - 1:
                match_text = regulatory_citation[match.start():]
            else:
                match_text = regulatory_citation[match.start():matches[index + 1].start()]
            text = match_text.rstrip(" ,;")
            citations.append({"text": text, "type": "regulation", "title": "11", "url": url})
        if not citations:
            logger.warn("Cannot parse regulatory citation %s for Entity %s in case %s",
                        regulatory_citation, entity_id, case_id)
    return citations


def get_documents(case_id, bucket):
    documents = []
    with db.engine.connect() as conn:
        rs = conn.execute(CASE_DOCUMENTS, case_id)
        for row in rs:
            document = {
                "document_id": row["document_id"],
                "category": row["category"],
                "description": row["description"],
                "length": row["length"],
                "text": row["ocrtext"],
                "document_date": row["document_date"],
                "doc_order_id": row["doc_order_id"],
            }
            if not row["fileimage"]:
                logger.error(
                    "Error uploading document ID {0} for {1} %{2}: No file image".
                    format(row["document_id"], row["case_type"], row["case_no"]))
            else:
                pdf_key = "legal/{0}/{1}/{2}".format(
                    get_es_type(row["case_type"]), row["case_no"], row["filename"].replace(" ", "-")
                )
                document["url"] = "/files/" + pdf_key
                documents.append(document)

                # bucket is None on local, don't need upload pdf to s3
                try:
                    if bucket:
                        logger.debug("S3: Uploading {}".format(pdf_key))
                        bucket.put_object(
                            Key=pdf_key,
                            Body=bytes(row["fileimage"]),
                            ContentType="application/pdf",
                            ACL="public-read",
                        )
                except Exception:
                    pass
    return documents


def remove_reclassification_notes(statutory_citation):
    """ Statutory citations include notes on reclassification of the form
    "30120 (formerly 441d)" and "30120 (formerly 432(e)(1))". These need to be
    removed as we explicitly perform the necessary reclassifications.
    """
    UNPARENTHESIZED_FORMERLY_REGEX = re.compile(r" formerly \S*")
    PARENTHESIZED_FORMERLY_REGEX = re.compile(r"\(formerly ")

    def remove_to_matching_parens(citation):
        """ In the case of reclassification notes of the form "(formerly ...",
        remove all characters up to the matching closing ")" allowing for nested
        parentheses pairs.
        """
        match = PARENTHESIZED_FORMERLY_REGEX.search(citation)
        pos = match.end()
        paren_count = 0
        while pos < len(citation):
            if citation[pos] == ")":
                if paren_count == 0:
                    return citation[:match.start()] + citation[pos + 1:]
                else:
                    paren_count -= 1
            elif citation[pos] == "(":
                paren_count += 1
            pos += 1
        return citation[:match.start()]  # Degenerate case - no matching ")"

    cleaned_citation = UNPARENTHESIZED_FORMERLY_REGEX.sub(" ", statutory_citation)
    while PARENTHESIZED_FORMERLY_REGEX.search(cleaned_citation):
        cleaned_citation = remove_to_matching_parens(cleaned_citation)
    return cleaned_citation


def get_sort_fields(case_no):
    match = CASE_NO_REGEX.match(case_no)
    return -int(match.group("serial")), None
