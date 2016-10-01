#!/usr/bin/env python

import re
from zipfile import ZipFile
from tempfile import NamedTemporaryFile
from xml.etree import ElementTree as ET
from datetime import datetime
from os.path import getsize
from random import shuffle
import csv
from multiprocessing import Pool
import logging
from urllib.parse import urlencode

import elasticsearch
from elasticsearch_dsl import Search, Q
from elasticsearch_dsl.result import Result
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
import slate
sys.path = sys.path[1:]

logger = logging.getLogger('manager')

def get_sections(reg):
    sections = {}
    for subpart in reg['children']:
        for node in subpart['children']:
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
    es.indices.delete('docs')
    es.indices.create('docs', {
        "mappings": {
            "_default_": {
                "properties": {
                    "no": {
                        "type": "string",
                        "index": "not_analyzed"
                    }
                }
            }
        }
    })


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

def process_mur_pdf(mur_no, pdf_key, bucket):
    response = requests.get('http://www.fec.gov/disclosure_data/mur/%s.pdf'
                            % mur_no, stream=True)

    with NamedTemporaryFile('wb+') as pdf:
        for chunk in response:
            pdf.write(chunk)

        pdf.seek(0)
        try:
            pdf_doc = slate.PDF(pdf)
        except:
            logger.error('Could not parse pdf: %s' % pdf_key)
            pdf_doc = []
        pdf_pages = len(pdf_doc)
        pdf_text = ' '.join(pdf_doc)
        pdf_size = getsize(pdf.name)

        pdf.seek(0)
        bucket.put_object(Key=pdf_key, Body=pdf,
                          ContentType='application/pdf', ACL='public-read')
        return pdf_text, pdf_size, pdf_pages

def get_subject_tree(html, tree=None):
    """This is a standard shift-reduce parser for extracting the tree of subject
    topics from the html. Using a html parser (eg., beautifulsoup4) would not have
    solved this problem, since the parse tree we want is _not_ represented in
    the hierarchy of html elements. Depending on the tag, the algorithm either shifts
    (adds the tag to a list) or reduces (collapses everything until the most recent ul
    into a child of the previous element). It stops when it encounters the empty tag."""

    if tree is None:
        tree = []
    # get next token
    root = re.match("([^<]+)(?:<br>)?(.*)", html, re.S)
    list_item = re.match("<li>(.*?)</li>(.*)", html, re.S)
    unordered_list = re.match("<ul\s+class='no-top-margin'>(.*)", html, re.S)
    end_list = re.match("</ul>(.*)", html, re.S)
    empty = re.match("\s*<br>\s*", html)

    if empty:
        pass
    elif end_list:
        # reduce
        sub_tree = []
        node = tree.pop()
        while node != 'ul_start':
            sub_tree.append(node)
            node = tree.pop()

        sub_tree.reverse()
        if tree[-1] != 'ul_start':
            tree[-1]['children'] = sub_tree
        else:
            tree.extend(sub_tree)
    elif unordered_list:
        # shift
        tree.append('ul_start')
    elif list_item or root:
        # shift
        subject = re.sub('\s+', ' ', (list_item or root).group(1))\
                    .strip().lower().capitalize()
        tree.append({'text': subject})
    else:
        print(html)
        raise Exception("Could not parse next token.")

    if not empty:
        tail = (root or list_item or unordered_list or end_list)
        if tail:
            html = tail.groups()[-1].strip()
            if html:
                get_subject_tree(html, tree)
    return tree

def get_citations(citation_texts):
    us_codes = []
    regulations = []

    for citation_text in citation_texts:
        us_code_match = re.match("(?P<title>[0-9]+) U\.S\.C\. (?P<section>[0-9a-z-]+)(?P<paragraphs>.*)", citation_text)
        regulation_match = re.match(
            "(?P<title>[0-9]+) C\.F\.R\. (?P<part>[0-9]+)(?:\.(?P<section>[0-9]+))?", citation_text)

        if us_code_match:
            title, section = map_pre2012_citation(us_code_match.group('title'), us_code_match.group('section'))
            citation_text = '%s U.S.C. %s%s' % (title, section, us_code_match.group('paragraphs'))
            url = 'http://api.fdsys.gov/link?' +\
                  urlencode([('collection', 'uscode'), ('title', title),
                    ('year', 'mostrecent'), ('section', section)])
            us_codes.append({"text": citation_text, "url": url})
        elif regulation_match:
            url = utils.create_eregs_link(regulation_match.group('part'), regulation_match.group('section'))
            regulations.append({"text": citation_text, "url": url})

        else:
            print(citation_text)
            raise Exception("Could not parse citation")
    return {"us_code": us_codes, "regulations": regulations}

def map_pre2012_citation(title, section, archived_mur_citation_map={}):
    """Archived MURs have citations referring to old USC Titles that were
    remapped in 2012. We link to the current laws based on the original
    citations."""

    def _load_citation_map(archived_mur_citation_map):
        # Cache the map
        if len(archived_mur_citation_map):
            return archived_mur_citation_map

        logger.info('Loading archived_mur_citation_map.csv')
        with open('data/archived_mur_citation_map.csv') as csvfile:
            for row in csv.reader(csvfile):
                title, section = row[1].split(':', 2)
                archived_mur_citation_map[row[0]] = (title, section)
        return archived_mur_citation_map

    citations_map = _load_citation_map(archived_mur_citation_map)

    # Fallback to title, section if no mapping exists
    citation = citations_map.get('%s:%s' % (title, section), (title, section))
    if (title, section) != citation:
        logger.info('Mapping archived MUR statute citation %s ->  %s' % ((title, section), citation))

    return citation


def delete_murs_from_s3():
    bucket = get_bucket()
    for obj in bucket.objects.filter(Prefix="legal/murs"):
        obj.delete()

def delete_murs_from_es():
    es = utils.get_elasticsearch_connection()
    es.transport.perform_request('DELETE', '/docs/murs')

def get_mur_names(mur_names={}):
    # Cache the mur names
    if len(mur_names):
        return mur_names

    with open('data/archived_mur_names.csv') as csvfile:
        for row in csv.reader(csvfile):
            if row[0] == 'MUR':
                mur_names[row[1]] = row[2]
    return mur_names

def process_mur(mur):
    print("processing mur %d of %d" % (mur[0], mur[1]))
    es = utils.get_elasticsearch_connection()
    bucket = get_bucket()
    bucket_name = env.get_credential('bucket')
    mur_names = get_mur_names()
    (mur_no_td, open_date_td, close_date_td, parties_td, subject_td, citations_td)\
        = re.findall("<td[^>]*>(.*?)</td>", mur[2], re.S)
    mur_no = re.search("/disclosure_data/mur/([0-9_A-Z]+)\.pdf", mur_no_td).group(1)
    print("processing mur %s" % mur_no)
    pdf_key = 'legal/murs/%s.pdf' % mur_no
    if [k for k in bucket.objects.filter(Prefix=pdf_key)]:
        print('already processed %s' % pdf_key)
        return
    text, pdf_size, pdf_pages = process_mur_pdf(mur_no, pdf_key, bucket)
    pdf_url = "https://%s.s3.amazonaws.com/%s" % (bucket_name, pdf_key)
    open_date, close_date = (None, None)
    if open_date_td:
        open_date = datetime.strptime(open_date_td, '%m/%d/%Y').isoformat()
    if close_date_td:
        close_date = datetime.strptime(close_date_td, '%m/%d/%Y').isoformat()
    parties = re.findall("(.*?)<br>", parties_td)
    complainants = []
    respondents = []
    for party in parties:
        match = re.match("\(([RC])\) - (.*)", party)
        name = match.group(2).strip().title()
        if match.group(1) == 'C':
            complainants.append(name)
        if match.group(1) == 'R':
            respondents.append(name)

    subject = get_subject_tree(subject_td)
    citations = get_citations(re.findall("(.*?)<br>", citations_td))

    mur_digits = re.match("([0-9]+)", mur_no).group(1)
    name = mur_names[mur_digits] if mur_digits in mur_names else ''
    doc = {
        'doc_id': 'mur_%s' % mur_no,
        'no': mur_no,
        'name': name,
        'text': text,
        'mur_type': 'archived',
        'pdf_size': pdf_size,
        'pdf_pages': pdf_pages,
        'open_date': open_date,
        'close_date': close_date,
        'complainants': complainants,
        'respondents': respondents,
        'subject': subject,
        'citations': citations,
        'url': pdf_url
    }
    es.index('docs', 'murs', doc, id=doc['doc_id'])

def load_archived_murs():
    table_text = requests.get('http://www.fec.gov/MUR/MURData.do').text
    rows = re.findall("<tr [^>]*>(.*?)</tr>", table_text, re.S)[1:]
    bucket = get_bucket()
    murs_completed = set([re.match("legal/murs/([0-9_A-Z]+).pdf", o.key).group(1)
                        for o in bucket.objects.filter(Prefix="legal/murs")
                        if re.match("legal/murs/([0-9_A-Z]+).pdf", o.key)])
    rows = [r for r in rows
            if re.search('/disclosure_data/mur/([0-9_A-Z]+)\.pdf', r, re.M).group(1)
            not in murs_completed]
    shuffle(rows)
    murs = zip(range(len(rows)), [len(rows)] * len(rows), rows)
    with Pool(processes=1, maxtasksperchild=1) as pool:
        pool.map(process_mur, murs, chunksize=1)

def remap_archived_murs_citations():
    """Re-map citations for archived MURs. To extract the MUR
    information from the archived PDFs, use load_archived_murs"""

    es = utils.get_elasticsearch_connection()

    # Fetch archived murs from ES
    query = Search() \
            .query(Q('term', mur_type='archived') &  Q('term', _type='murs')) \
            .source(include='citations')
    archived_murs = elasticsearch.helpers.scan(es, query.to_dict(), scroll='1m', index='docs', doc_type='murs', size=500)

    # Re-map the citations
    update_murs = (dict(_op_type='update', _id=mur.meta.id, doc=mur.to_dict()) for mur in remap_citations(archived_murs))

    # Save MURs to ES
    count, _ = elasticsearch.helpers.bulk(es, update_murs, index='docs', doc_type='murs', chunk_size=100, request_timeout=30)
    logger.info("Re-mapped %d archived MURs" % count)


def remap_citations(archived_murs):
    for mur in archived_murs:
        mur = Result(mur)

        # Include regulations and us_code citations in the re-map
        mur.citations = get_citations(map(lambda c: c['text'], list(mur.citations['regulations']) + list(mur.citations['us_code'])))
        yield mur
