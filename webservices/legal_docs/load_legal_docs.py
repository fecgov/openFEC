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

import requests

from webservices.rest import db
from webservices.env import env
from webservices import utils
from webservices.tasks.utils import get_bucket
from webservices.legal_docs import DOCS_INDEX

from . import reclassify_statutory_citation

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


def index_regulations():
    """
        Indexes the regulations relevant to the FEC in Elasticsearch.
        The regulations are accessed from FEC_EREGS_API.
    """
    eregs_api = env.get_credential('FEC_EREGS_API', '')
    if not eregs_api:
        logger.info("Regs could not be indexed, environment variable FEC_EREGS_API not set.")
        return

    reg_versions = requests.get(eregs_api + 'regulation').json()['versions']
    es = utils.get_elasticsearch_connection()
    reg_count = 0
    for reg in reg_versions:
        url = '%sregulation/%s/%s' % (eregs_api, reg['regulation'],
                                        reg['version'])
        regulation = requests.get(url).json()
        sections = get_sections(regulation)

        logger.info("Loading part %s" % reg['regulation'])
        for section_label in sections:
            doc_id = '%s_%s' % (section_label[0], section_label[1])
            section_formatted = '%s-%s' % (section_label[0], section_label[1])
            reg_url = '/regulations/{0}/{1}#{0}'.format(section_formatted,
                                                        reg['version'])
            no = '%s.%s' % (section_label[0], section_label[1])
            name = sections[section_label]['title'].split(no)[1].strip()
            doc = {
                "doc_id": doc_id,
                "name": name,
                "text": sections[section_label]['text'],
                "url": reg_url,
                "no": no,
                "sort1": int(section_label[0]),
                "sort2": int(section_label[1])
            }

            es.index(DOCS_INDEX, 'regulations', doc, id=doc['doc_id'])
        reg_count += 1
    logger.info("%d regulation parts indexed." % reg_count)

def get_ao_citations():
    logger.info("getting citations...")
    ao_names_results = db.engine.execute("""SELECT ao_no, name FROM aouser.document
                                  INNER JOIN aouser.ao ON ao.ao_id = document.ao_id""")
    ao_names = {}
    for row in ao_names_results:
        ao_names[row['ao_no']] = row['name']

    text = db.engine.execute("""SELECT ao_no, category, ocrtext FROM aouser.document
                                INNER JOIN aouser.ao ON ao.ao_id = document.ao_id""")
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

        citations[(row['ao_no'], row['category'])] = sorted([{'no': citation, 'name': ao_names[citation]}
         for citation in citations_in_doc], key=lambda d: d['no'])

        if row['category'] == 'Final Opinion':
            for citation in citations_in_doc:
                if citation not in cited_by:
                    cited_by[citation] = set([row['ao_no']])
                else:
                    cited_by[citation].add(row['ao_no'])

    for citation, cited_by_set in cited_by.items():
        cited_by_with_name = sorted([{'no': c, 'name': ao_names[c]}
            for c in cited_by_set], key=lambda d: d['no'])
        cited_by[citation] = cited_by_with_name

    return citations, cited_by

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
                    doc = {
                        "doc_id": section.attrib['identifier'],
                        "text": text,
                        "name": heading,
                        "no": section_no,
                        "title": "52",
                        "chapter": chapter,
                        "subchapter": subchapter_no,
                        "url": pdf_url,
                        "sort1": 52,
                        "sort2": int(section_no)
                    }
                    es.index(DOCS_INDEX, 'statutes', doc, id=doc['doc_id'])

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
                    doc = {
                        "doc_id": section.attrib['identifier'],
                        "text": text,
                        "name": heading,
                        "no": section_no,
                        "title": "26",
                        "chapter": chapter_no,
                        "url": pdf_url,
                        "sort1": 26,
                        "sort2": int(section_no)
                    }
                    es.index(DOCS_INDEX, 'statutes', doc, id=doc['doc_id'])


def index_statutes():
    """
        Indexes statutes with titles 26 and 52 in Elasticsearch.
        The statutes are downloaded from http://uscode.house.gov.
    """
    get_title_26_statutes()
    get_title_52_statutes()


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
            title, section = reclassify_statutory_citation.reclassify_archived_mur_statutory_citation(
                us_code_match.group('title'), us_code_match.group('section'))
            citation_text = '%s U.S.C. %s%s' % (title, section, us_code_match.group('paragraphs'))
            url = 'http://api.fdsys.gov/link?' +\
                  urlencode([('collection', 'uscode'), ('link-type', 'html'), ('title', title),
                    ('year', 'mostrecent'), ('section', section)])
            us_codes.append({"text": citation_text, "url": url})
        elif regulation_match:
            url = utils.create_eregs_link(regulation_match.group('part'), regulation_match.group('section'))
            regulations.append({"text": citation_text, "url": url})

        else:
            print(citation_text)
            raise Exception("Could not parse citation")
    return {"us_code": us_codes, "regulations": regulations}

def delete_murs_from_s3():
    """
    Deletes all MUR documents from S3
    """
    bucket = get_bucket()
    for obj in bucket.objects.filter(Prefix="legal/murs"):
        obj.delete()

def delete_murs_from_es():
    """
    Deletes all MURs from Elasticsearch
    """
    delete_from_es(DOCS_INDEX, 'murs')

def delete_advisory_opinions_from_es():
    """
    Deletes all advisory opinions from Elasticsearch
    """
    delete_from_es(DOCS_INDEX, 'advisory_opinions')

def delete_from_es(index, doc_type):
    """
    Deletes all documents with the given `doc_type` from Elasticsearch
    """
    es = utils.get_elasticsearch_connection()
    es.delete_by_query(index=index, body={'query': {'match_all': {}}}, doc_type=doc_type)

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
    logger.info("processing mur %d of %d" % (mur[0], mur[1]))
    es = utils.get_elasticsearch_connection()
    bucket = get_bucket()
    bucket_name = env.get_credential('bucket')
    mur_names = get_mur_names()
    (mur_no_td, open_date_td, close_date_td, parties_td, subject_td, citations_td)\
        = re.findall("<td[^>]*>(.*?)</td>", mur[2], re.S)
    mur_no = re.search("/disclosure_data/mur/([0-9_A-Z]+)\.pdf", mur_no_td).group(1)
    logger.info("processing mur %s" % mur_no)
    pdf_key = 'legal/murs/%s.pdf' % mur_no
    if [k for k in bucket.objects.filter(Prefix=pdf_key)]:
        logger.info('already processed %s' % pdf_key)
        return
    text, pdf_size, pdf_pages = process_mur_pdf(mur_no, pdf_key, bucket)
    pdf_url = generate_aws_s3_url(bucket_name, pdf_key)
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
    es.index(DOCS_INDEX, 'murs', doc, id=doc['doc_id'])

def load_archived_murs():
    """
    Reads data for archived MURs from http://www.fec.gov/MUR, assembles a JSON
    document corresponding to the MUR and indexes this document in Elasticsearch
    in the index `docs_index` with a doc_type of `murs`. In addition, the MUR
    document is uploaded to an S3 bucket under the _directory_ `legal/murs/`.
    """
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

def generate_aws_s3_url(bucket_name, pdf_key):
    return "https://%s.s3.amazonaws.com/%s" % (bucket_name, pdf_key)
