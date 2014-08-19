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

        def add_metadata():
            """ This function will take in two items of metadata, DIMOFFICE and DIMPARTY, and make them accessible in our local store """
            DIMOFFICE = open_json('dimoffice.json')
            DIMPARTY = open_json('dimparty.json')

            for office in DIMOFFICE:
                db.Put('OFFICE!%s' % office['OFFICE_SK'], json.dumps(office))

            for party in DIMPARTY:
                db.Put('PARTY!%s' % party['PARTY_SK'], json.dumps(party))

        # And we'll just run that metadata add function while we're here
        add_metadata()

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

        _combine_candidates()

class CleanData(luigi.Task):
    def requires(self):
        return CombineData()

    def output(self):
        return luigi.LocalTarget(join(DATA_DIR, 'entities/cleaned'))

    def run(self):
        combined_data = leveldb.LevelDB(self.input().path)
        cleaned_data = leveldb.LevelDB(self.output().path)

        """ Iterate through each candidate and clean it up! """
        for key, candidate in combined_data.RangeIter(key_from="CAND!!", key_to="CAND!~"):
            candidate = json.loads(candidate)
            cleaned_candidate = {}
            
            # We'll first iterate through all the elections a candidate has participated in
            elections = []
            try:
                # We iterate through each item in DIMCANDOFFICE, which represent offices the candidate has run for.
                # TODO (seanherron): check for duplicate entries here. They shouldn't occur but we need to verify.
                for item in candidate['DIMCANDOFFICE']:
                    election = {}

                    # Transfer over the election year of the candidate
                    election['ELECTION_YEAR'] = item['CAND_ELECTION_YR']

                    # We can now try and see if we can connect this election to the Incumbent/Challenger Indicator
                    try:
                        for ici in candidate['DIMCANDSTATUSICI']:
                            if ici['ELECTION_YR'] == election['ELECTION_YEAR']:
                                # First We set the candidate status
                                if ici['CAND_STATUS'] == "C":
                                    election['STATUS'] = "Statutory Candidate"
                                elif ici['CAND_STATUS'] == "F":
                                    election['STATUS'] = "Statutory Candidate for Future Election"
                                elif ici['CAND_STATUS'] == "N":
                                    election['STATUS'] = "Not Yet a Statutory Candidate"
                                elif ici['CAND_STATUS'] == "P":
                                    election['STATUS'] = "Statutory Candidate in Prior Cycle"

                                # Now set the Incumbent Challenger Status
                                if ici['ICI_CODE'] == "C":
                                    election['INCUMBENT_CHALLENGER_STATUS'] = "Challenger"
                                elif ici['ICI_CODE'] == "I":
                                    election['INCUMBENT_CHALLENGER_STATUS'] = "Incumbent"
                                elif ici['ICI_CODE'] == "O":
                                    election['INCUMBENT_CHALLENGER_STATUS'] = "Open Seat"
                    except KeyError:
                        print("Key Error!")

                    # Grab the actual office information (rather than just the key) from our combined_data db and insert that data directly
                    office = json.loads(combined_data.Get('OFFICE!%s' % item['OFFICE_SK']))
                    election['OFFICE'] = office['OFFICE_TP_DESC']

                    # This is annoying - if the candidate is running for President, the state is listed as "US". We don't need to include that that.
                    if election['OFFICE'] is not "President":
                        election['STATE'] = office['OFFICE_STATE']

                    # We'll also include the district if the candidate is running for the House of Representatives
                    if election['OFFICE'] is "House":
                        election['DISTRICT'] = office['OFFICE_DISTRICT']

                    # Finally, append the new dictionary to our elections list
                    elections.append(election)

            # Sometimes we get a Key Error because the candidate doesn't have any related campaigns. Not sure why that would happen.   
            except KeyError:
                print("Key Error!")
            
            # Add our elections list to our cleaned_candidate entry
            print elections
            cleaned_candidate['ELECTIONS'] = elections
            






if __name__ == '__main__':
    logging.basicConfig(
        stream=sys.stderr,
        format='%(created)f %(filename)s:%(lineno)s [%(funcName)s] %(message)s',
        level=logging.DEBUG)
        
    luigi.run()
        

