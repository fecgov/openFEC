import codecs
import pytest
import json

import manage

from tests import common
from webservices import rest, __API_VERSION__
from webservices.rest import db
from webservices.resources.candidates import CandidateList
from webservices.resources.candidate_aggregates import TotalsCandidateView

@pytest.mark.usefixtures("migrate_db")
class CandidatesTestCase(common.BaseTestCase):

    def setUp(self):
        super().setUp()
        self.longMessage = True
        self.maxDiff = None
        self.request_context = rest.app.test_request_context()
        self.request_context.push()
        self.connection = db.engine.connect()

    def _response(self, qry):
        response = self.app.get(qry)
        self.assertEquals(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertEqual(result['api_version'], __API_VERSION__)
        return result

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_candidate_counts_house(self):
        cand_valid_fec_yr_data = [
            {
                'cand_valid_yr_id': 1,
                'cand_id': '1',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cand_status': 'A',
                'cand_office': 'H',
                'date_entered': 'now()'
            },
            {
                'cand_valid_yr_id': 2,
                'cand_id': '2',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cand_status': 'A',
                'cand_office': 'H',
                'date_entered': 'now()'
            },
            {
                'cand_valid_yr_id': 3,
                'cand_id': '3',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cand_status': 'A',
                'cand_office': 'H',
                'date_entered': 'now()'
            },
        ]
        election_year = 2020
        self.create_cand_valid(cand_valid_fec_yr_data)

        cand_cmte_linkage_data = [
            {
                'linkage_id': 2,
                'cand_id': 'H1',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cmte_id': '2',
                'cmte_count_cand_yr': 1,
                'cmte_tp': 'H',
                'cmte_dsgn': 'P',
                'linkage_type': 'P',
                'date_entered': 'now()'
            },
            {
                'linkage_id': 4,
                'cand_id': 'H2',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cmte_id': '3',
                'cmte_count_cand_yr': 1,
                'cmte_tp': 'H',
                'cmte_dsgn': 'P',
                'linkage_type': 'P',
                'date_entered': 'now()'
            },
            {
                'linkage_id': 6,
                'cand_id': 'H3',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cmte_id': '3',
                'cmte_count_cand_yr': 1,
                'cmte_tp': 'H',
                'cmte_dsgn': 'P',
                'linkage_type': 'P',
                'date_entered': 'now()'
            }

        ]
        self.create_cand_cmte_linkage(cand_cmte_linkage_data)

        manage.refresh_materialized(concurrent=False)
        sql_extract = "SELECT * from disclosure.cand_valid_fec_yr " + \
            "WHERE cand_election_yr in ({}, {})".format(election_year - 1, election_year)
        results_tab = self.connection.execute(sql_extract).fetchall()
        candidates_result_api = self._results(rest.api.url_for(CandidateList, election_year=election_year))
        # TODO: Do we expect results for election_full=False?
        # Results for house currently don't match for election_full=true and election_full=False
        candidates_totals_results_api = self._results(rest.api.url_for(TotalsCandidateView, election_year=election_year, election_full=True))
        assert len(results_tab) == len(candidates_result_api) == len(candidates_totals_results_api)

    def create_cand_valid(self, candidate_data):
        sql_insert = "INSERT INTO disclosure.cand_valid_fec_yr " + \
            "(cand_valid_yr_id, cand_id, fec_election_yr, cand_election_yr, " + \
            "cand_status, cand_office, date_entered) VALUES (%(cand_valid_yr_id)s, %(cand_id)s, " + \
            "%(fec_election_yr)s, %(cand_election_yr)s, %(cand_status)s, %(cand_office)s, %(date_entered)s)"
        self.connection.execute(sql_insert, candidate_data)

    def create_cand_cmte_linkage(self, linkage_data):
        sql_insert = "INSERT INTO disclosure.cand_cmte_linkage " + \
            "(linkage_id, cand_id, fec_election_yr, cand_election_yr, " + \
            "cmte_id, cmte_count_cand_yr, cmte_tp, cmte_dsgn, linkage_type, date_entered) " + \
            "VALUES (%(linkage_id)s, %(cand_id)s, " + \
            "%(fec_election_yr)s, %(cand_election_yr)s, %(cmte_id)s, %(cmte_count_cand_yr)s, " + \
            "%(cmte_tp)s, %(cmte_dsgn)s, %(linkage_type)s, %(date_entered)s)"
        self.connection.execute(sql_insert, linkage_data)
