#!/usr/bin/env python
import logging
import requests
from webservices.env import env
# from webservices import utils
from webservices.utils import create_es_client

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
def load_regulations():
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
