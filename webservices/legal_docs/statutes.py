#!/usr/bin/env python
import re
from zipfile import ZipFile
from tempfile import NamedTemporaryFile
from defusedxml import ElementTree as Et
import logging
import requests
from webservices.utils import create_es_client
from .es_management import (  # noqa
    AO_ALIAS,
)

logger = logging.getLogger(__name__)


def get_xml_tree_from_url(url):
    r = requests.get(url, stream=True)

    with NamedTemporaryFile("wb+") as f:
        for chunk in r:
            f.write(chunk)
        f.seek(0)
        zip_file = ZipFile(f.name)

        with zip_file.open(zip_file.namelist()[0]) as title, NamedTemporaryFile(
            "wb+"
        ) as title_xml:
            title_xml.write(title.read())
            title_xml.seek(0)
            return Et.parse(title_xml.name)


def get_title_52_statutes():
    es_client = create_es_client()
    title_parsed = get_xml_tree_from_url(
        "https://uscode.house.gov/download/"
        "releasepoints/us/pl/114/219/xml_usc52@114-219.zip"
    )
    tag_name = "{{http://xml.house.gov/schemas/uslm/1.0}}{0}"
    section_count = 0
    for subtitle in title_parsed.iter(tag_name.format("subtitle")):
        if subtitle.attrib["identifier"] == "/us/usc/t52/stIII":
            for subchapter in subtitle.iter(tag_name.format("subchapter")):
                match = re.match(
                    "/us/usc/t52/stIII/ch([0-9]+)/sch([IVX]+)",
                    subchapter.attrib["identifier"],
                )
                chapter = match.group(1)
                subchapter_no = match.group(2)
                for section in subchapter.iter(tag_name.format("section")):
                    text = ""
                    for child in section.iter():
                        if child.text:
                            text += " %s " % child.text.strip()
                    heading = section.find(tag_name.format("heading")).text.strip()
                    section_no = re.match(
                        "/us/usc/t52/s([0-9]+)", section.attrib["identifier"]
                    ).group(1)
                    pdf_url = "https://www.govinfo.gov/link/uscode/52/%s" % section_no
                    doc = {
                        "type": "statutes",
                        "doc_id": section.attrib["identifier"],
                        "text": text,
                        "name": heading,
                        "no": section_no,
                        "title": "52",
                        "chapter": chapter,
                        "subchapter": subchapter_no,
                        "url": pdf_url,
                        "sort1": 52,
                        "sort2": int(section_no),
                    }
                    es_client.index(AO_ALIAS, doc, id=doc["doc_id"])
                    section_count += 1
    return section_count


def get_title_26_statutes():
    es_client = create_es_client()
    title_parsed = get_xml_tree_from_url(
        "https://uscode.house.gov/download/"
        "releasepoints/us/pl/114/219/xml_usc26@114-219.zip"
    )
    tag_name = "{{http://xml.house.gov/schemas/uslm/1.0}}{0}"
    section_count = 0
    for subtitle in title_parsed.iter(tag_name.format("subtitle")):
        if subtitle.attrib["identifier"] == "/us/usc/t26/stH":
            for chapter in subtitle.iter(tag_name.format("chapter")):
                match = re.match(
                    "/us/usc/t26/stH/ch([0-9]+)", chapter.attrib["identifier"]
                )
                chapter_no = match.group(1)
                for section in chapter.iter(tag_name.format("section")):
                    text = ""
                    for child in section.iter():
                        if child.text:
                            text += " %s " % child.text.strip()
                    heading = section.find(tag_name.format("heading")).text.strip()
                    section_no = re.match(
                        "/us/usc/t26/s([0-9]+)", section.attrib["identifier"]
                    ).group(1)
                    pdf_url = "https://www.govinfo.gov/link/uscode/26/%s" % section_no
                    doc = {
                        "type": "statutes",
                        "doc_id": section.attrib["identifier"],
                        "text": text,
                        "name": heading,
                        "no": section_no,
                        "title": "26",
                        "chapter": chapter_no,
                        "url": pdf_url,
                        "sort1": 26,
                        "sort2": int(section_no),
                    }
                    es_client.index(AO_ALIAS, doc, id=doc["doc_id"])
                    section_count += 1
    return section_count


# example endpoint url: http://127.0.0.1:5000/v1/legal/search/?type=statutes&hits_returned=60
def load_statutes():
    """
        Load statutes with titles 26 and 52 in Elasticsearch.
        The statutes are downloaded from http://uscode.house.gov.
    """
    es_client = create_es_client()
    # check if AO_ALIAS exist before uploading.
    if es_client.indices.exists(index=AO_ALIAS):
        logger.info(" Uploading statutes...")
        title_26_section_count = get_title_26_statutes()
        title_52_section_count = get_title_52_statutes()
        logger.info(" %d statute sections uploaded", title_26_section_count + title_52_section_count)
    else:
        logger.error(" The index alias '{0}' is not found, cannot load statutes.".format(AO_ALIAS))
