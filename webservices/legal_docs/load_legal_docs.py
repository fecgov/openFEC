#!/usr/bin/env python
import re
from zipfile import ZipFile
from tempfile import NamedTemporaryFile
from xml.etree import ElementTree as ET
import logging
import requests
from webservices.rest import db
from webservices.env import env
# from webservices import utils
from webservices.utils import create_es_client
from webservices.tasks.utils import get_bucket

logger = logging.getLogger('manager')


def get_sections(reg):
    sections = {}
    for subpart in reg['children']:
        for node in subpart['children']:
            sections[tuple(node['label'])] = {
                'text': get_text(node),
                'title': node['title'],
            }
    return sections


def get_text(node):
    text = ''
    if "text" in node:
        text = node["text"]
    for child in node["children"]:
        text += ' ' + get_text(child)
    return text


# curl command examples:
# 1)curl -X GET "localhost:9200/docs/_search?pretty" -H 'Content-Type: application/json' 
# -d'{"query": {"terms": {"_id": [ "9039_3", "100_110"] }}}'
#
# 2)curl -d '{"query": {"term": {"type": "regulations"}}}' -H "Content-Type: application/json" 
# -X POST "localhost:9200/docs/_count?pretty"
#
# 3)curl -d '{"from" : 0, "size" : 600, "query": {"term": {"type": "regulations"}}}' -H "Content-Type: application/json" 
# -X POST "localhost:9200/docs/_search?pretty" -o regulation_out.json
def index_regulations():
    """
    Indexes the regulations relevant to the FEC in Elasticsearch.
    The regulations are accessed from FEC_EREGS_API.
    """
    eregs_api = env.get_credential('FEC_EREGS_API', '')
    if not eregs_api:
        logger.error(
            "Regs could not be indexed, environment variable FEC_EREGS_API not set."
        )
        return

    logger.info("Indexing regulations")
    reg_versions = requests.get(eregs_api + 'regulation').json()['versions']
    es_client = create_es_client()
    reg_count = 0
    for reg in reg_versions:
        url = '%sregulation/%s/%s' % (eregs_api, reg['regulation'], reg['version'])
        regulation = requests.get(url).json()
        sections = get_sections(regulation)

        logger.debug("Loading part %s" % reg['regulation'])
        for section_label in sections:
            doc_id = '%s_%s' % (section_label[0], section_label[1])
            section_formatted = '%s-%s' % (section_label[0], section_label[1])
            reg_url = '/regulations/{0}/{1}#{0}'.format(
                section_formatted, reg['version']
            )
            no = '%s.%s' % (section_label[0], section_label[1])
            name = sections[section_label]['title'].split(no)[1].strip()
            doc = {
                "type": "regulations",
                "doc_id": doc_id,
                "name": name,
                "text": sections[section_label]['text'],
                "url": reg_url,
                "no": no,
                "sort1": int(section_label[0]),
                "sort2": int(section_label[1]),
            }

            es_client.index('docs_index', doc, id=doc['doc_id'])
        reg_count += 1
        logger.info("%d regulation parts indexed.", reg_count)


def get_ao_citations():
    logger.info("getting citations...")
    ao_names_results = db.engine.execute(
        """SELECT ao_no, name FROM aouser.document
                                  INNER JOIN aouser.ao ON ao.ao_id = document.ao_id"""
    )
    ao_names = {}
    for row in ao_names_results:
        ao_names[row['ao_no']] = row['name']

    text = db.engine.execute(
        """SELECT ao_no, category, ocrtext FROM aouser.document
                                INNER JOIN aouser.ao ON ao.ao_id = document.ao_id"""
    )
    citations = {}
    cited_by = {}
    for row in text:
        logger.info("Getting citations for %s" % row['ao_no'])
        citations_in_doc = set()
        text = row['ocrtext'] or ''
        for citation in re.findall('[12][789012][0-9][0-9]-[0-9][0-9]?[0-9]?', text):
            year, no = tuple(citation.split('-'))
            citation_txt = "{0}-{1:02d}".format(year, int(no))
            if citation_txt != row['ao_no'] and citation_txt in ao_names:
                citations_in_doc.add(citation_txt)

        citations[(row['ao_no'], row['category'])] = sorted(
            [
                {'no': citation, 'name': ao_names[citation]}
                for citation in citations_in_doc
            ],
            key=lambda d: d['no'],
        )

        if row['category'] == 'Final Opinion':
            for citation in citations_in_doc:
                if citation not in cited_by:
                    cited_by[citation] = set([row['ao_no']])
                else:
                    cited_by[citation].add(row['ao_no'])

    for citation, cited_by_set in cited_by.items():
        cited_by_with_name = sorted(
            [{'no': c, 'name': ao_names[c]} for c in cited_by_set],
            key=lambda d: d['no'],
        )
        cited_by[citation] = cited_by_with_name

    return citations, cited_by


def get_xml_tree_from_url(url):
    r = requests.get(url, stream=True)

    with NamedTemporaryFile('wb+') as f:
        for chunk in r:
            f.write(chunk)
        f.seek(0)
        zip_file = ZipFile(f.name)

        with zip_file.open(zip_file.namelist()[0]) as title, NamedTemporaryFile(
            'wb+'
        ) as title_xml:
            title_xml.write(title.read())
            title_xml.seek(0)
            return ET.parse(title_xml.name)


def get_title_52_statutes():
    es_client = create_es_client()

    title_parsed = get_xml_tree_from_url(
        'http://uscode.house.gov/download/'
        'releasepoints/us/pl/114/219/xml_usc52@114-219.zip'
    )
    tag_name = '{{http://xml.house.gov/schemas/uslm/1.0}}{0}'
    section_count = 0
    for subtitle in title_parsed.iter(tag_name.format('subtitle')):
        if subtitle.attrib['identifier'] == '/us/usc/t52/stIII':
            for subchapter in subtitle.iter(tag_name.format('subchapter')):
                match = re.match(
                    "/us/usc/t52/stIII/ch([0-9]+)/sch([IVX]+)",
                    subchapter.attrib['identifier'],
                )
                chapter = match.group(1)
                subchapter_no = match.group(2)
                for section in subchapter.iter(tag_name.format('section')):
                    text = ''
                    for child in section.iter():
                        if child.text:
                            text += ' %s ' % child.text.strip()
                    heading = section.find(tag_name.format('heading')).text.strip()
                    section_no = re.match(
                        '/us/usc/t52/s([0-9]+)', section.attrib['identifier']
                    ).group(1)
                    pdf_url = 'https://www.govinfo.gov/link/uscode/52/%s' % section_no
                    doc = {
                        "type": "statutes",
                        "doc_id": section.attrib['identifier'],
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
                    es_client.index('docs_index', doc, id=doc['doc_id'])
                    section_count += 1
    return section_count


def get_title_26_statutes():
    es_client = create_es_client()

    title_parsed = get_xml_tree_from_url(
        'http://uscode.house.gov/download/'
        'releasepoints/us/pl/114/219/xml_usc26@114-219.zip'
    )
    tag_name = '{{http://xml.house.gov/schemas/uslm/1.0}}{0}'
    section_count = 0
    for subtitle in title_parsed.iter(tag_name.format('subtitle')):
        if subtitle.attrib['identifier'] == '/us/usc/t26/stH':
            for chapter in subtitle.iter(tag_name.format('chapter')):
                match = re.match(
                    "/us/usc/t26/stH/ch([0-9]+)", chapter.attrib['identifier']
                )
                chapter_no = match.group(1)
                for section in chapter.iter(tag_name.format('section')):
                    text = ''
                    for child in section.iter():
                        if child.text:
                            text += ' %s ' % child.text.strip()
                    heading = section.find(tag_name.format('heading')).text.strip()
                    section_no = re.match(
                        '/us/usc/t26/s([0-9]+)', section.attrib['identifier']
                    ).group(1)
                    pdf_url = 'https://www.govinfo.gov/link/uscode/26/%s' % section_no
                    doc = {
                        "type": "statutes",
                        "doc_id": section.attrib['identifier'],
                        "text": text,
                        "name": heading,
                        "no": section_no,
                        "title": "26",
                        "chapter": chapter_no,
                        "url": pdf_url,
                        "sort1": 26,
                        "sort2": int(section_no),
                    }
                    es_client.index('docs_index', doc, id=doc['doc_id'])
                    section_count += 1
    return section_count


# curl command examples:
# 1)curl -X GET "localhost:9200/docs/_search?pretty" -H 'Content-Type: application/json' -d'
# {"query": {"terms": {"_id": ["/us/usc/t26/s9009, "/us/usc/t52/s30110"] }}}'
#
# 2)curl -d '{"query": {"term": {"type": "statutes"}}}' -H "Content-Type: application/json" 
# -X POST "localhost:9200/docs/_count?pretty"
def index_statutes():
    """
        Indexes statutes with titles 26 and 52 in Elasticsearch.
        The statutes are downloaded from http://uscode.house.gov.
    """
    logger.info("Indexing statutes")
    title_26_section_count = get_title_26_statutes()
    title_52_section_count = get_title_52_statutes()
    logger.info(
        "%d statute sections indexed", title_26_section_count + title_52_section_count
    )


def delete_murs_from_s3():
    """
    Deletes all MUR documents from S3
    """
    bucket = get_bucket()
    for obj in bucket.objects.filter(Prefix="legal/murs"):
        obj.delete()


def delete_current_murs_from_es():
    """
    Deletes all current MURs from Elasticsearch
    """
    delete_from_es('docs_index', 'murs')


def delete_advisory_opinions_from_es():
    """
    Deletes all advisory opinions from Elasticsearch
    """
    delete_from_es('docs_index', 'advisory_opinions')


def delete_from_es(index, doc_type):
    """
    Deletes all documents with the given `doc_type` from Elasticsearch
    """
    es_client = create_es_client()
    es_client.delete_by_query(
        index=index, body={'query': {'match_all': {}}}, doc_type=doc_type
    )
