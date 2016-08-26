#!/usr/bin/env python

import re
from zipfile import ZipFile
from tempfile import NamedTemporaryFile, TemporaryFile
from xml.etree import ElementTree as ET
from datetime import datetime

import requests

from webservices.rest import db
from webservices.env import env
from webservices import utils
from webservices.tasks.utils import get_bucket

# sigh. This is a mess because slate uses a library also called utils.
import importlib
importlib.invalidate_caches()
import sys
from distutils.sysconfig import get_python_lib
sys.path = [get_python_lib() + '/slate'] + sys.path
print(sys.path)
import slate
sys.path = sys.path[1:]

def get_sections(reg):
    sections = {}
    for node in reg['children'][0]['children']:
        sections[tuple(node['label'])] = {'text': get_text(node),
                                          'title': node['title']}
    return sections


def get_text(node):
    text = ''
    if "text" in node:
        text = node["text"]
    for child in node["children"]:
        text += ' ' + get_text(child)
    return text


def remove_legal_docs():
    es = utils.get_elasticsearch_connection()
    es.delete_index('docs')
    es.create_index('docs', {"mappings": {
                             "_default_": {
                                "properties": {
                                        "no": {
                                            "type": "string",
                                            "index": "not_analyzed"
                                        }
                                    }
                                }}})


def index_regulations():
    eregs_api = env.get_credential('FEC_EREGS_API', '')

    if(eregs_api):
        reg_versions = requests.get(eregs_api + 'regulation').json()['versions']
        es = utils.get_elasticsearch_connection()
        reg_count = 0
        for reg in reg_versions:
            url = '%sregulation/%s/%s' % (eregs_api, reg['regulation'],
                                          reg['version'])
            regulation = requests.get(url).json()
            sections = get_sections(regulation)

            print("Loading part %s" % reg['regulation'])
            for section_label in sections:
                doc_id = '%s_%s' % (section_label[0], section_label[1])
                section_formatted = '%s-%s' % (section_label[0], section_label[1])
                reg_url = '/regulations/{0}/{1}#{0}'.format(section_formatted,
                                                            reg['version'])
                no = '%s.%s' % (section_label[0], section_label[1])
                name = sections[section_label]['title'].split(no)[1].strip()
                doc = {"doc_id": doc_id, "name": name,
                       "text": sections[section_label]['text'], 'url': reg_url,
                       "no": no}

                es.index('docs', 'regulations', doc, id=doc['doc_id'])
            reg_count += 1
        print("%d regulation parts indexed." % reg_count)
    else:
        print("Regs could not be indexed, environment variable not set.")

def legal_loaded():
    legal_loaded = db.engine.execute("""SELECT EXISTS (
                               SELECT 1
                               FROM   information_schema.tables
                               WHERE  table_name = 'ao'
                            );""").fetchone()[0]
    if not legal_loaded:
        print('Advisory opinion tables not found.')

    return legal_loaded


def index_advisory_opinions():
    print('Indexing advisory opinions...')

    if legal_loaded():
        count = db.engine.execute('select count(*) from AO').fetchone()[0]
        print('AO count: %d' % count)
        count = db.engine.execute('select count(*) from DOCUMENT').fetchone()[0]
        print('DOC count: %d' % count)

        es = utils.get_elasticsearch_connection()

        result = db.engine.execute("""select DOCUMENT_ID, OCRTEXT, DESCRIPTION,
                                CATEGORY, DOCUMENT.AO_ID, NAME, SUMMARY,
                                TAGS, AO_NO, DOCUMENT_DATE FROM DOCUMENT INNER JOIN
                                AO on AO.AO_ID = DOCUMENT.AO_ID""")

        loading_doc = 0

        if loading_doc % 500 == 0:
            print("%d docs loaded" % loading_doc)

        bucket_name = env.get_credential('bucket')
        for row in result:
            key = "legal/aos/%s.pdf" % row[0]
            pdf_url = "https://%s.s3.amazonaws.com/%s" % (bucket_name, key)
            doc = {"doc_id": row[0],
                   "text": row[1],
                   "description": row[2],
                   "category": row[3],
                   "id": row[4],
                   "name": row[5],
                   "summary": row[6],
                   "tags": row[7],
                   "no": row[8],
                   "date": row[9],
                   "url": pdf_url}

            es.index('docs', 'advisory_opinions', doc, id=doc['doc_id'])
            loading_doc += 1
        print("%d docs loaded" % loading_doc)

def get_xml_tree_from_url(url):
    r = requests.get(url, stream=True)

    with NamedTemporaryFile('wb+') as f:
        for chunk in r:
            f.write(chunk)
        f.seek(0)
        zip_file = ZipFile(f.name)

        with zip_file.open(zip_file.namelist()[0]) as title,\
         NamedTemporaryFile('wb+') as title_xml:
            title_xml.write(title.read())
            title_xml.seek(0)
            return ET.parse(title_xml.name)

def get_title_52_statutes():
    es = utils.get_elasticsearch_connection()

    title_parsed = get_xml_tree_from_url('http://uscode.house.gov/download/' +
                    'releasepoints/us/pl/114/219/xml_usc52@114-219.zip')
    tag_name = '{{http://xml.house.gov/schemas/uslm/1.0}}{0}'
    for subtitle in title_parsed.iter(tag_name.format('subtitle')):
        if subtitle.attrib['identifier'] == '/us/usc/t52/stIII':
            for subchapter in subtitle.iter(tag_name.format('subchapter')):
                match = re.match("/us/usc/t52/stIII/ch([0-9]+)/sch([IVX]+)",
                                    subchapter.attrib['identifier'])
                chapter = match.group(1)
                subchapter_no = match.group(2)
                for section in subchapter.iter(tag_name.format('section')):
                    text = ''
                    for child in section.iter():
                        if child.text:
                            text += ' %s ' % child.text.strip()
                    heading = section.find(tag_name.format('heading')).text.strip()
                    section_no = re.match('/us/usc/t52/s([0-9]+)',
                             section.attrib['identifier']).group(1)
                    pdf_url = 'http://api.fdsys.gov/link?collection=uscode&' +\
                              'title=52&year=mostrecent&section=%s'\
                              % section_no
                    doc = {"doc_id": section.attrib['identifier'],
                           "text": text,
                           "name": heading,
                           "no": section_no,
                           "title": "52",
                           "chapter": chapter,
                           "subchapter": subchapter_no,
                           "url": pdf_url}
                    es.index('docs', 'statutes', doc, id=doc['doc_id'])

def get_title_26_statutes():
    es = utils.get_elasticsearch_connection()

    title_parsed = get_xml_tree_from_url('http://uscode.house.gov/download/' +
                    'releasepoints/us/pl/114/219/xml_usc26@114-219.zip')
    tag_name = '{{http://xml.house.gov/schemas/uslm/1.0}}{0}'
    for subtitle in title_parsed.iter(tag_name.format('subtitle')):
        if subtitle.attrib['identifier'] == '/us/usc/t26/stH':
            for chapter in subtitle.iter(tag_name.format('chapter')):
                match = re.match("/us/usc/t26/stH/ch([0-9]+)",
                                    chapter.attrib['identifier'])
                chapter_no = match.group(1)
                for section in chapter.iter(tag_name.format('section')):
                    text = ''
                    for child in section.iter():
                        if child.text:
                            text += ' %s ' % child.text.strip()
                    heading = section.find(tag_name.format('heading')).text.strip()
                    section_no = re.match('/us/usc/t26/s([0-9]+)',
                             section.attrib['identifier']).group(1)
                    pdf_url = 'http://api.fdsys.gov/link?collection=uscode&' +\
                              'title=26&year=mostrecent&section=%s'\
                              % section_no
                    doc = {"doc_id": section.attrib['identifier'],
                           "text": text,
                           "name": heading,
                           "no": section_no,
                           "title": "26",
                           "chapter": chapter_no,
                           "url": pdf_url}
                    es.index('docs', 'statutes', doc, id=doc['doc_id'])


def index_statutes():
    get_title_26_statutes()
    get_title_52_statutes()


def delete_advisory_opinions_from_s3():
    for obj in get_bucket().objects.filter(Prefix="legal/aos"):
        obj.delete()


def load_advisory_opinions_into_s3():
    if legal_loaded():
        docs_in_db = set([str(r[0]) for r in db.engine.execute(
                         "select document_id from document").fetchall()])

        bucket = get_bucket()
        docs_in_s3 = set([re.match("legal/aos/([0-9]+)\.pdf", obj.key).group(1)
                          for obj in bucket.objects.filter(Prefix="legal/aos")])

        new_docs = docs_in_db.difference(docs_in_s3)

        if new_docs:
            query = "select document_id, fileimage from document \
                    where document_id in (%s)" % ','.join(new_docs)

            result = db.engine.connect().execution_options(stream_results=True)\
                    .execute(query)

            bucket_name = env.get_credential('bucket')
            for i, (document_id, fileimage) in enumerate(result):
                key = "legal/aos/%s.pdf" % document_id
                bucket.put_object(Key=key, Body=bytes(fileimage),
                                  ContentType='application/pdf', ACL='public-read')
                url = "https://%s.s3.amazonaws.com/%s" % (bucket_name, key)
                print("pdf written to %s" % url)
                print("%d of %d advisory opinions written to s3" % (i + 1, len(new_docs)))
        else:
            print("No new advisory opinions found.")

def process_mur_pdf(mur_no, bucket):
    response = requests.get('http://www.fec.gov/disclosure_data/mur/%s.pdf'
                            % mur_no, stream=True)

    with TemporaryFile('wb+') as pdf:
        for chunk in response:
            pdf.write(chunk)

        pdf.seek(0)
        key = 'legal/murs/%s.pdf' % mur_no
        bucket.put_object(Key=key, Body=pdf,
                          ContentType='application/pdf', ACL='public-read')

        pdf.seek(0)
        pdf_text = ' '.join(slate.PDF(pdf))
        return pdf_text, key

def load_archived_murs():
    es = utils.get_elasticsearch_connection()
    table_text = requests.get('http://www.fec.gov/MUR/MURData.do').text
    rows = re.findall("<tr [^>]*>(.*?)</tr>", table_text, re.S)
    bucket = get_bucket()
    bucket_name = env.get_credential('bucket')
    for row in rows[1:]:
        data = re.findall("<td[^>]*>(.*?)</td>", row, re.S)
        mur_no = re.search("/disclosure_data/mur/([0-9_A-Z]+)\.pdf", data[0]).group(1)
        text, pdf_key = process_mur_pdf(mur_no, bucket)
        pdf_url = "https://%s.s3.amazonaws.com/%s" % (bucket_name, pdf_key)
        if data[1]:
            open_date = datetime.strptime(data[1], '%m/%d/%Y').isoformat()
        if data[2]:
            close_date = datetime.strptime(data[2], '%m/%d/%Y').isoformat()
        parties = re.findall("(.*?)<br>", data[3])
        complainants = []
        respondents = []
        for party in parties:
            match = re.match("\(([RC])\) - (.*)", party)
            if match.group(1) == 'C':
                complainants.append(match.group(2))
            if match.group(1) == 'R':
                respondents.append(match.group(2))

        subject = data[4]
        citations = re.findall("(.*?)<br>", data[5])
        doc = {
            'doc_id': mur_no,
            'no': mur_no,
            'text': text,
            'mur_type': 'archived',
            'open_date': open_date,
            'close_date': close_date,
            'complainants': complainants,
            'respondents': respondents,
            'subject': subject,
            'citations': citations,
            'url': pdf_url
        }
        print(pdf_url)
        es.index('docs', 'murs', doc, id=doc['doc_id'])
