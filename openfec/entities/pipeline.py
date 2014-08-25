"""
Pipeline for merging FEC entity data and importing to Elasticsearch.
"""

# System dependencies
import os
from os.path import join, dirname
import logging
import sys

# Third Party Dependencies
import luigi
import scrapelib
import leveldb
import requests
import simplejson as json
from elasticsearch import Elasticsearch

# Local
from openfec.entities import annotate

###
# Settings settings settings
###
# Run Directory
RUN_DIR = dirname(dirname(os.path.abspath(__file__)))
# Data Type
DATA_TYPE = 'entities'
# Where to download data to
DATA_DIR = './data/'
# Where to cache to
CACHE_DIR = './cache/'

SOURCE_URL = 'https://s3.amazonaws.com/openfec/test'

CANDIDATE_SOURCE_FILES = {
    "DIMCAND": "DIMCAND.json",
    "DIMCANDOFFICE": "DIMCANDOFFICE.json",
    "DIMCANDPROPERTIES": "DIMCANDPROPERTIES.json",
    "DIMCANDSTATUSICI": "DIMCANDSTATUSICI.json"
}

COMMITTEE_SOURCE_FILES = {
    "DIMCMTE": "DIMCMTE.json",
    "DIMCMTEPROPERTIES": "DIMCMTEPROPERTIES.json",
    "DIMCMTETPDSGN": "DIMCMTETPDSGN.json",
}

META_SOURCE_FILES = {
    "DIMOFFICE": "dimoffice.json",
    "DIMPARTY": "dimparty.json"
}

class DownloadDataset(luigi.Task):
    def output(self):
        return luigi.LocalTarget(join(DATA_DIR, 'entities/raw'))

    def run(self):
        # We first will ensure the cache and data directories exist
        if not os.path.exists(CACHE_DIR):
            os.makedirs(CACHE_DIR)
        if not os.path.exists(DATA_DIR):
            os.makedirs(DATA_DIR)

        # We use scrapelib as we are unsure of the integrity of the server we will be pulling from
        s = scrapelib.Scraper(retry_wait_seconds=5, retry_attempts=10)

        # Enable caching so we don't repeat downloads
        s.cache_storage = scrapelib.FileCache(CACHE_DIR)
        s.cache_write_only = False

        # Simple download function
        def download_entity(s, filename):
            """ Download an asset """
            logging.info('Downloading %s from %s' % (filename, join(SOURCE_URL, filename)))
            s.urlretrieve(
                '%s/%s' % (SOURCE_URL, filename),
                '%s/%s' % (self.output().path, filename)
                )

        # Download the data!
        os.system('mkdir -p "%s"' % self.output().path)
        for filename in CANDIDATE_SOURCE_FILES.values():
            download_entity(s, filename)
        
        for filename in COMMITTEE_SOURCE_FILES.values():
            download_entity(s, filename)

        for filename in META_SOURCE_FILES.values():
            download_entity(s, filename)


class CombineData(luigi.Task):
    def requires(self):
        return DownloadDataset()

    def output(self):
        return luigi.LocalTarget(join(DATA_DIR, 'entities/parsed'))

    def run(self):
        db = leveldb.LevelDB(self.output().path)

        def open_json(filename):
            """ Opens up a given JSON file and returns the data in a Python dict """

            with open(join(self.input().path, filename)) as file:
                read_data = file.read().replace('\r','').replace('\n', '')
                json_data = json.loads(read_data)
            return json_data

        def combine_json(key, source_data, append_data):
            """ Combines Everything from two given dictionaries """
            if key in source_data:
                source_data[key].append(append_data)
            else:
                source_data[key] = []
                source_data[key].append(append_data)
            return source_data
        
        def add_entity_to_db(namespace, key_name, source_data, source_data_name):
            for entry in source_data:
                entity = json.loads(db.Get('%s!%s' % (namespace, entry[key_name])))
                combined_entry = combine_json(source_data_name, entity, entry)
                db.Put('%s!%s' % (namespace, entity[key_name]), json.dumps(combined_entry))

        def _add_metadata():
            """ This function will take in two items of metadata, DIMOFFICE and DIMPARTY, and make them accessible in our local store """
            DIMOFFICE = open_json('dimoffice.json')
            DIMPARTY = open_json('dimparty.json')

            for office in DIMOFFICE:
                db.Put('OFFICE!%s' % office['OFFICE_SK'], json.dumps(office))

            for party in DIMPARTY:
                db.Put('PARTY!%s' % party['PARTY_SK'], json.dumps(party))


        def _combine_candidates():
            """Iterate through all candidates, create a unique entity for them in our local store, and add in additional metadata.
            """
            DIMCAND = open_json('DIMCAND.json')
            DIMCANDOFFICE = open_json('DIMCANDOFFICE.json')
            DIMCANDPROPERTIES = open_json('DIMCANDPROPERTIES.json')
            DIMCANDSTATUSICI = open_json('DIMCANDSTATUSICI.json')
            DIMOFFICE = open_json('dimoffice.json')
            DIMPARTY = open_json('dimparty.json')

            # Iterate through DIMCAND and create entities for everyone
            for candidate in DIMCAND:
                # We use CAND!{CAND_SK} for our key. Note that CAND_SK is different than CAND_ID and doesn't need to be exposed to the end-user.
                db.Put('%s!%s' % ('CAND', candidate["CAND_SK"]), json.dumps(candidate))

            # Next, let's add in information about the office they have run for!
            add_entity_to_db('CAND', 'CAND_SK', DIMCANDOFFICE, 'DIMCANDOFFICE')
            add_entity_to_db('CAND', 'CAND_SK', DIMCANDPROPERTIES, 'DIMCANDPROPERTIES')
            add_entity_to_db('CAND', 'CAND_SK', DIMCANDSTATUSICI, 'DIMCANDSTATUSICI')


        def _combine_committees():
            """Iterate through all committees, creates a unique entity for them in our local store, and add in additional metadata.
            """
            DIMCMTE = open_json('DIMCMTE.json')
            DIMCMTEPROPERTIES = open_json('DIMCMTEPROPERTIES.json')
            DIMCMTETPDSGN = open_json('DIMCMTETPDSGN.json')

            # Iterate through DIMCMTE and create entities for each committee
            for committee in DIMCMTE:
                # We use CMTE!{CMTE_SK} for our key. Note that CMTE_SK is different than CMTE_ID and doesn't need to be exposed to the end-user.
                db.Put('%s!%s' % ('CMTE', committee["CMTE_SK"]), json.dumps(committee))

            add_entity_to_db('CMTE', 'CMTE_SK', DIMCMTEPROPERTIES, 'DIMCMTEPROPERTIES')
            add_entity_to_db('CMTE', 'CMTE_SK', DIMCMTETPDSGN, 'DIMCMTETPDSGN')

        # Run the three database store creation functions
        _add_metadata()
        _combine_candidates()
        _combine_committees()

class CleanData(luigi.Task):
    def requires(self):
        return CombineData()

    def output(self):
        return luigi.LocalTarget(join(DATA_DIR, 'entities/cleaned'))

    def run(self):
        combined_db = leveldb.LevelDB(self.input().path)
        cleaned_db = leveldb.LevelDB(self.output().path)

        """ Iterate through each candidate and clean it up! """
        for key, value in combined_db.RangeIter(key_from="CAND!!", key_to="CAND!~"):
            candidate = json.loads(value)
            cleaned_candidate = {}
            # Add the Candidate ID to the main top-level entry
            cleaned_candidate['id'] = candidate['CAND_ID']
            
            # Add our elections list to our cleaned_candidate entry
            cleaned_candidate['elections'] = annotate.create_elections_entry(candidate, combined_db)

            property_fields_to_keep = {
                'CAND_ST1':'street',
                'CAND_ST2':'street_2',
                'CAND_ZIP':'zipcode',
                'CAND_CITY':'city',
                'CAND_ST':'state',
                'CAND_NM':'name',
                'CAND_STATUS_DESC':'status_description',
                'CAND_STATUS_CD':'status_code',
                'LOAD_DATE': 'date'
            }

            cleaned_candidate['properties'], cleaned_candidate['historical_properties'] = annotate.create_revision_history(property_fields_to_keep, candidate, 'DIMCANDPROPERTIES', 'CANDPROPERTIES_SK')
            
            cleaned_db.Put("CAND!%s" % cleaned_candidate['id'], json.dumps(cleaned_candidate))

        """ Iterate through each committee and clean it up! """
        for key, value in combined_db.RangeIter(key_from="CMTE!!", key_to="CMTE!~"):
            committee = json.loads(value)
            cleaned_committee = {}

            # Add the Committee ID to the main top-level entry
            cleaned_committee['id'] = committee['CMTE_ID']

            properties_fields_to_keep = {
                "CMTE_NM": "name",
                "CMTE_ST1": "street",
                "CMTE_ST2": "street_2",
                "CMTE_CITY": "city"
            }
            cleaned_committee['properties'], cleaned_committee['historical_properties'] = annotate.create_revision_history(properties_fields_to_keep, committee, 'DIMCMTEPROPERTIES', 'CMTE_SK')

            print json.dumps(cleaned_committee)

if __name__ == '__main__':
    logging.basicConfig(
        stream=sys.stderr,
        format='%(created)f %(filename)s:%(lineno)s [%(funcName)s] %(message)s',
        level=logging.DEBUG)
        
    luigi.run()
        

