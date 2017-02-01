import logging

from webservices.env import env
from webservices.legal_docs import DOCS_INDEX
from webservices.rest import db
from webservices.utils import get_elasticsearch_connection
from webservices.tasks.utils import get_bucket
from webservices.legal_docs.utils import STATUTE_REGEX, REGULATION_REGEX

from .utils import (
    get_subjects,
    get_election_cycles,
    get_participants, 
    get_sorted_respondents, 
    get_disposition, 
    get_documents,
    get_open_and_close_dates,
    get_commission_votes
)

logger = logging.getLogger(__name__)

ALL_MURS = """
    SELECT case_id, case_no, name
    FROM fecmur.case
    WHERE case_type = 'MUR'
"""

def load_current_murs():
    """
    Reads data for current MURs from a Postgres database, assembles a JSON document
    corresponding to the MUR and indexes this document in Elasticsearch in the index
    `docs_index` with a doc_type of `murs`. In addition, all documents attached to
    the MUR are uploaded to an S3 bucket under the _directory_ `legal/murs/current/`.
    """
    es = get_elasticsearch_connection()
    bucket = get_bucket()
    bucket_name = env.get_credential('bucket')
    with db.engine.connect() as conn:
        rs = conn.execute(ALL_MURS)
        for row in rs:
            case_id = row['case_id']
            mur = {
                'doc_id': 'mur_%s' % row['case_no'],
                'no': row['case_no'],
                'name': row['name'],
                'mur_type': 'current',
            }
            mur['subjects'] = get_subjects(case_id)
            mur['subject'] = {'text': mur['subjects']}
            mur['election_cycles'] = get_election_cycles(case_id)

            participants = get_participants(case_id)
            mur['participants'] = list(participants.values())
            mur['respondents'] = get_sorted_respondents(mur['participants'])
            mur['disposition'] = get_disposition(case_id)
            mur['commission_votes'] = get_commission_votes(case_id)
            mur['dispositions'] = mur['disposition']['data']
            mur['documents'] = get_documents(case_id, bucket, bucket_name)
            mur['open_date'], mur['close_date'] = get_open_and_close_dates(case_id)
            mur['url'] = '/legal/matter-under-review/%s/' % row['case_no']
            es.index(DOCS_INDEX, 'murs', mur, id=mur['doc_id'])