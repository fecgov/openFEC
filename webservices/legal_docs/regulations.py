#!/usr/bin/env python
import logging
import requests
from webservices.env import env
from webservices.utils import (
    create_es_client,
    DateTimeEncoder,
)
from .es_management import (  # noqa
    CASE_ALIAS,
)
import json

logger = logging.getLogger(__name__)

# for debug, uncomment this line
# logger.setLevel(logging.DEBUG)


def get_sections(reg):
    sections = {}
    for subpart in reg["children"]:
        for node in subpart["children"]:
            sections[tuple(node["label"])] = {
                "text": get_text(node),
                "title": node["title"],
            }
    return sections


def get_text(node):
    text = ""
    if "text" in node:
        text = node["text"]
    for child in node["children"]:
        text += " " + get_text(child)
    return text


# example endpoint url: http://127.0.0.1:5000/v1/legal/search/?type=regulations&hits_returned=50
def load_regulations():
    """
    Load the regulations relevant to the FEC in Elasticsearch.
    The regulations are accessed from FEC_EREGS_API.
    """

    # set env variable:
    # export FEC_EREGS_API=https://fec-dev-eregs.app.cloud.gov/regulations/api/
    eregs_api = env.get_credential("FEC_EREGS_API", "")
    if not eregs_api:
        logger.error(
            "Regs could not be loaded, environment variable FEC_EREGS_API not set."
        )
        return

    logger.info("Uploading regulations...")
    reg_versions = requests.get(eregs_api + "regulation").json()["versions"]
    logger.debug("reg_versions =" + json.dumps(reg_versions, indent=3, cls=DateTimeEncoder))

    # TO DO: check if CASE_ALIAS exist before uploading.
    es_client = create_es_client()
    regulation_part_count = 0
    document_count = 0
    for reg in reg_versions:
        url = "%sregulation/%s/%s" % (eregs_api, reg["regulation"], reg["version"])
        logger.debug("url=" + url)
        regulation = requests.get(url).json()
        sections = get_sections(regulation)

        each_part_document_count = 0
        logger.debug("Loading part %s" % reg["regulation"])
        for section_label in sections:
            doc_id = "%s_%s" % (section_label[0], section_label[1])
            logger.debug("(%d) doc_id= %s" % (each_part_document_count + 1, doc_id))
            section_formatted = "%s-%s" % (section_label[0], section_label[1])
            reg_url = "/regulations/{0}/{1}#{0}".format(
                section_formatted, reg["version"]
            )
            no = "%s.%s" % (section_label[0], section_label[1])
            name = sections[section_label]["title"].split(no)[1].strip()
            doc = {
                "type": "regulations",
                "doc_id": doc_id,
                "name": name,
                "text": sections[section_label]["text"],
                "url": reg_url,
                "no": no,
                "sort1": int(section_label[0]),
                "sort2": int(section_label[1]),
            }
            each_part_document_count += 1
            document_count += 1

            es_client.index(CASE_ALIAS, doc, id=doc["doc_id"])
        logger.debug("Part %s: %d document(s) are loaded." % (reg["regulation"], each_part_document_count))
        regulation_part_count += 1
        logger.info("%d regulation parts with %d documents are loaded.", regulation_part_count, document_count)
