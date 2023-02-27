from collections import defaultdict
import logging
import re
from webservices.rest import db
from webservices.utils import (
    create_es_client,
    DateTimeEncoder,
)
from webservices.tasks.utils import get_bucket
from .reclassify_statutory_citation import reclassify_statutory_citation
from .es_management import (  # noqa
   AO_ALIAS,
)
import json

logger = logging.getLogger(__name__)

# for debug, uncomment this line
# logger.setLevel(logging.DEBUG)


ALL_AOS = """
    SELECT
        ao_parsed.ao_id as ao_id,
        ao_parsed.ao_no as ao_no,
        ao_parsed.ao_year as ao_year,
        ao_parsed.ao_serial as ao_serial,
        ao_parsed.name as name,
        ao_parsed.summary as summary,
        ao_parsed.req_date as req_date,
        ao_parsed.issue_date as issue_date,
        ao.stage as stage
    FROM aouser.aos_with_parsed_numbers ao_parsed
    INNER JOIN aouser.ao ao
        ON ao_parsed.ao_id = ao.ao_id
    WHERE (
        (ao_parsed.ao_year = %s AND ao_parsed.ao_serial >= %s)
        OR
        (ao_parsed.ao_year > %s)
    )
    ORDER BY ao_parsed.ao_year desc, ao_parsed.ao_serial desc
"""

AO_ENTITIES = """
    SELECT
        COALESCE(e.prefix,'') AS prefix,
        COALESCE(e.first_name,'') AS firstname,
        COALESCE(e.last_name,'') AS lastname,
        COALESCE(e.suffix,'') AS suffix,
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

TO_END_OF_SENTENCE = r"(?P<possible_sections>\d+[a-z]?(-1)?[^.;]*)[.;]"

# Statute REGEX

STATUTE_TITLE = r"(?P<title>\d+)\s+U\.?S\.?C\.?\s+§*\s*"
STATUTE_SECTION = r"(?P<section>\d+[a-z]?(-1)?)(?:\S*)"

SINGLE_STATUTE_CITATION_REGEX = re.compile(STATUTE_TITLE + STATUTE_SECTION + r".*\.?")

MULTIPLE_STATUTE_CITATION_REGEX = re.compile(STATUTE_TITLE + TO_END_OF_SENTENCE)

STATUTE_SECTION_ONLY_REGEX = re.compile(STATUTE_SECTION)

# Regulation REGEX

MAX_MULTIPLE_REGULATION_CITATION_LENGTH = r"(?P<possible_parts_and_sections>.{,70})"

REGULATION_TITLE = r"(?P<title>\d+)\s+C\.?F\.?R\.?\s+§*\s*"
REGULATION_SECTION = r"(?P<part>\d+)\.(?P<section>\d+)+"

SINGLE_REGULATION_CITATION_REGEX = re.compile(REGULATION_TITLE + REGULATION_SECTION)

MULTIPLE_REGULATION_CITATION_REGEX = re.compile(
    REGULATION_TITLE + MAX_MULTIPLE_REGULATION_CITATION_LENGTH
)

REGULATION_SECTION_ONLY_REGEX = re.compile(REGULATION_SECTION)

# AO REGEX

AO_CITATION_REGEX = re.compile(r"\b(?P<year>\d{4,4})-(?P<serial_no>\d+)\b")

AOS_WITH_CORRECTED_STAGE = {"2009-05": "Withdrawn"}
AO_DOC_TYPE = "advisory_opinions"


def load_advisory_opinions(from_ao_no=None):
    """
    Reads data for advisory opinions from a Postgres database,
    assembles a JSON document corresponding to the advisory opinion
    and indexes this document in Elasticsearch in the AO_ALIAS of AO_INDEX
    with a type=`advisory_opinions`.
    In addition, all documents attached to the advisory opinion
    are uploaded to an S3 bucket under the _directory_`legal/aos/`.
    """
    es_client = create_es_client()

    # TO DO: check if AO_ALIAS exist before uploading.
    logger.info("Loading advisory opinions")
    ao_count = 0
    for ao in get_advisory_opinions(from_ao_no):
        logger.info("Loading AO: %s", ao["no"])
        es_client.index(AO_ALIAS, ao, id=ao["no"])
        ao_count += 1

        # ==for local dubug use: remove the big "documents" section to display the object "ao" data.
        debug_ao_data = ao
        del debug_ao_data["documents"]
        logger.debug("ao_data count=" + str(ao_count))
        logger.debug("debug_ao_data =" + json.dumps(debug_ao_data, indent=3, cls=DateTimeEncoder))

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
    ao_no_to_component_map = {a: tuple(map(int, a.split("-"))) for a in ao_names}

    citations = get_citations(ao_names)

    if from_ao_no is None:
        start_ao_year, start_ao_serial = 0, 0
    else:
        start_ao_year, start_ao_serial = tuple(map(int, from_ao_no.split("-")))

    with db.engine.connect() as conn:
        rs = conn.execute(ALL_AOS, (start_ao_year, start_ao_serial, start_ao_year))
        for row in rs:
            ao_id = row["ao_id"]
            year, serial = ao_no_to_component_map[row["ao_no"]]
            ao = {
                "type": AO_DOC_TYPE,
                "no": row["ao_no"],
                "ao_no": row["ao_no"],
                "ao_year": row["ao_year"],
                "ao_serial": row["ao_serial"],
                "doc_id": "{0}_{1}".format(AO_DOC_TYPE, row["ao_no"]),
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
            (
                ao["requestor_names"],
                ao["requestor_types"],
                ao["commenter_names"],
                ao["representative_names"],
                ao["entities"],
            ) = get_entities(ao_id)

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
            # For entity type "individual" populate the name column by combining
            # prefix, firstname, lastname and suffix.
            if row["entity_type_description"] == "Individual":
                entities.append(
                    {
                        "role": row["role_description"],
                        "name": row["prefix"] + " " + row["firstname"] + " " + row["lastname"] + " " + row["suffix"],
                        "type": row["entity_type_description"],
                    }
                )
            else:
                entities.append(
                    {
                        "role": row["role_description"],
                        "name": row["name"],
                        "type": row["entity_type_description"],
                    }
                )
    return (
        requestor_names,
        list(requestor_types),
        commenter_names,
        representative_names,
        entities,
    )


def get_documents(ao_id, bucket):
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
            if not row["fileimage"]:
                logger.error(
                    "Error uploading document ID {0} for AO no {1}: No file image".format(
                        row["document_id"], row["ao_no"]
                    )
                )
            else:
                pdf_key = "legal/aos/{0}/{1}".format(
                    row["ao_no"], row["filename"].replace(" ", "-")
                )
                document["url"] = "/files/" + pdf_key
                logger.debug("S3: Uploading {}".format(pdf_key))
                documents.append(document)

                try:
                    # bucket is None on local, don't need upload pdf to s3
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


def get_ao_names():
    ao_names_results = db.engine.execute("""SELECT ao_no, name FROM aouser.ao""")
    ao_names = {}
    for row in ao_names_results:
        ao_names[row["ao_no"]] = row["name"]

    return ao_names


def fix_citations(ao_no, citation_type, citations):
    """
    Exclude false positives and include missed citations due to
    parsing errors. Citation types are "ao", "statute", and "regulation"

    Example lookup:
    {"2017-03":
        {"ao": ["2011-12", "2018-11"]},
        {"statute": [(52, "30101"), (52, "30116")]},
        {"regulation": [(11, 110, 3), (11, 100, 5)]},
    }

    """

    CITATION_EXCLUDE_LOOKUP = {
        "2017-03": {"ao": ["2010-11", "2011-12", "2015-16"]},
        "2019-11": {"statute": [(52, "301")]},
    }

    CITATION_INCLUDE_LOOKUP = {
        "1999-40": {"regulation": [(11, 110, 3)]},
        "2019-14": {"regulation": [(11, 102, 1), (11, 102, 6), (11, 104, 1), (11, 300, 10)]},
        "2019-11": {"regulation": [(11, 110, 11)]},
        "2018-15": {"regulation": [(11, 112, 1), (11, 112, 5), (11, 113, 1), (11, 113, 2)]},
    }

    exclude_list = CITATION_EXCLUDE_LOOKUP.get(ao_no, {}).get(citation_type)
    if exclude_list:
        for false_citation in exclude_list:
            logger.debug("Removing citation {}".format(false_citation))
            citations.discard(false_citation)

    include_list = CITATION_INCLUDE_LOOKUP.get(ao_no, {}).get(citation_type)
    if include_list:
        for missed_citation in include_list:
            logger.debug("Adding citation {}".format(missed_citation))
            citations.add(missed_citation)

    return citations


def get_citations(ao_names):
    ao_component_to_name_map = {tuple(map(int, a.split("-"))): a for a in ao_names}

    logger.info("Getting citations...")

    rs = db.engine.execute(
        """SELECT ao_no, ocrtext FROM aouser.document
            INNER JOIN aouser.ao USING (ao_id)
            WHERE category = 'Final Opinion'
        """
    )

    all_regulatory_citations = set()
    all_statutory_citations = set()
    raw_citations = defaultdict(lambda: defaultdict(set))
    for row in rs:
        logger.debug("Getting citations for AO %s" % row["ao_no"])

        if not row["ocrtext"]:
            logger.error(
                "Missing OCR text for AO no {0}: unable to get citations".format(
                    row["ao_no"]
                )
            )
        ao_citations_in_doc = parse_ao_citations(
            row["ocrtext"], ao_component_to_name_map
        )
        # Remove self
        ao_citations_in_doc.discard(row["ao_no"])
        statutory_citations = parse_statutory_citations(row["ocrtext"])
        regulatory_citations = parse_regulatory_citations(row["ocrtext"])
        # Manually fix parsing mistakes
        ao_citations_in_doc = fix_citations(row["ao_no"], "ao", ao_citations_in_doc)
        statutory_citations = fix_citations(
            row["ao_no"], "statute", statutory_citations
        )
        regulatory_citations = fix_citations(
            row["ao_no"], "regulation", regulatory_citations
        )

        for citation in ao_citations_in_doc:
            raw_citations[citation]["aos_cited_by"].add(row["ao_no"])

        logger.debug("AO citations: {}".format(ao_citations_in_doc))
        raw_citations[row["ao_no"]]["ao"].update(ao_citations_in_doc)
        logger.debug("Statutory citations: {}".format(statutory_citations))
        all_statutory_citations.update(statutory_citations)
        logger.debug("Regulatory citations: {}".format(regulatory_citations))
        all_regulatory_citations.update(regulatory_citations)

        raw_citations[row["ao_no"]]["statutes"].update(statutory_citations)
        raw_citations[row["ao_no"]]["regulations"].update(regulatory_citations)

    citations = defaultdict(lambda: defaultdict(list))
    for ao in raw_citations:
        citations[ao]["ao"] = sorted(
            [{"no": c, "name": ao_names[c]} for c in raw_citations[ao]["ao"]],
            key=lambda d: d["no"],
        )
        citations[ao]["aos_cited_by"] = sorted(
            [{"no": c, "name": ao_names[c]} for c in raw_citations[ao]["aos_cited_by"]],
            key=lambda d: d["no"],
        )
        citations[ao]["statutes"] = sorted(
            [{"title": c[0], "section": c[1]} for c in raw_citations[ao]["statutes"]],
            key=lambda d: (d["title"], d["section"]),
        )
        citations[ao]["regulations"] = sorted(
            [
                {"title": c[0], "part": c[1], "section": c[2]}
                for c in raw_citations[ao]["regulations"]
            ],
            key=lambda d: (d["title"], d["part"], d["section"]),
        )

    es_client = create_es_client()

    for citation in all_regulatory_citations:
        entry = {
            "type": "citations",
            "citation_text": "%d CFR §%d.%d" % (citation[0], citation[1], citation[2]),
            "citation_type": "regulation",
        }
        es_client.index(AO_ALIAS, entry, id=entry["citation_text"])

    for citation in all_statutory_citations:
        entry = {
            "type": "citations",
            "citation_text": "%d U.S.C. §%s" % (citation[0], citation[1]),
            "citation_type": "statute",
        }
        es_client.index(AO_ALIAS, entry, id=entry["citation_text"])

    logger.info("Citations loaded.")

    return citations


def parse_ao_citations(text, ao_component_to_name_map):
    matches = set()

    if text:
        for citation in AO_CITATION_REGEX.finditer(text):
            year, serial_no = (
                int(citation.group("year")),
                int(citation.group("serial_no")),
            )
            if (year, serial_no) in ao_component_to_name_map:
                matches.add(ao_component_to_name_map[(year, serial_no)])
    return matches


def validate_statute_citation(title, section):
    """
    Check to see if the statute (USC) citation is in the expected range.

    Convert the first 3 digits to an integer - the smallest number is 3 digits.
    - Title 2 between 431a and 457b
    - Title 18 between 590 and 619, and  1001
    - Title 26 between 9001 and 9042, 501 (IRS)
    - Title 52 between 30101 and 30146

    If title isn't in this list, fall back to True and add unknown citations
    """
    try:
        section_lookup = int(section[:3])
    except Exception:
        return False

    if title == "2":
        return 431 <= section_lookup <= 457
    elif title == "18":
        return 590 <= section_lookup <= 619 or section_lookup == 100
    elif title == "26":
        return 900 <= section_lookup <= 904 or section_lookup in (501, 527)
    elif title == "52":
        return section_lookup == 301

    return True


def parse_statutory_citations(text):
    matches = set()
    if text:
        for citation in SINGLE_STATUTE_CITATION_REGEX.finditer(text):
            new_title, new_section = reclassify_statutory_citation(
                citation.group("title"), citation.group("section")
            )
            matches.add((int(new_title), str(new_section)))
        for possible_multiple_citation in MULTIPLE_STATUTE_CITATION_REGEX.finditer(
            text
        ):
            citations_title = possible_multiple_citation.group("title")
            possible_sections = possible_multiple_citation.group("possible_sections")

            for section in STATUTE_SECTION_ONLY_REGEX.finditer(possible_sections):
                new_title, new_section = reclassify_statutory_citation(
                    citations_title, section.group("section")
                )

                if validate_statute_citation(new_title, new_section):
                    matches.add((int(new_title), str(new_section)))
                else:
                    logger.debug(
                        "Citation out of range - excluding {} USC {} from multiples.".format(
                            new_title, new_section
                        )
                    )
    return matches


def validate_regulation_citation(title, part):
    """
    Check to see if the regulation (CFR) is in the expected range. Add padding for future regs.

    Source: https://www.gpo.gov/fdsys/pkg/CFR-2018-title11-vol1/pdf/CFR-2018-title11-vol1-chapI.pdf

    11 CFR: 1-8, 100-120, 200-205, 300-305, 400 (historical), 9001-9099

    Other CFR's can appear, so fall back to True
    12 CFR 544 (1984-55)

    """
    try:
        part = int(part)
    except Exception:
        return False

    if title == "11":
        return (
            1 <= part <= 8
            or 100 <= part <= 120
            or 200 <= part <= 205
            or 300 <= part <= 305
            or part == 400
            or 9001 <= part <= 9099
        )

    return True


def parse_regulatory_citations(text):
    matches = set()
    if text:
        for citation in SINGLE_REGULATION_CITATION_REGEX.finditer(text):
            matches.add(
                (
                    int(citation.group("title")),
                    int(citation.group("part")),
                    int(citation.group("section")),
                )
            )

        for possible_multiple_citation in MULTIPLE_REGULATION_CITATION_REGEX.finditer(
            text
        ):
            citations_title = possible_multiple_citation.group("title")
            possible_parts_and_sections = possible_multiple_citation.group(
                "possible_parts_and_sections"
            )

            for part_and_section in REGULATION_SECTION_ONLY_REGEX.finditer(
                possible_parts_and_sections
            ):

                if validate_regulation_citation(
                    citations_title, part_and_section.group("part")
                ):
                    matches.add(
                        (
                            int(citations_title),
                            int(part_and_section.group("part")),
                            int(part_and_section.group("section")),
                        )
                    )
                else:
                    logger.debug(
                        "Citation out of range - excluding {} CFR {}.{} from multiples.".format(
                            citations_title,
                            part_and_section.group("part"),
                            int(part_and_section.group("section")),
                        )
                    )
    return matches
