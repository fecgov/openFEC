import codecs
import pytest
import json

import manage

from tests import common
from webservices import rest, __API_VERSION__
from webservices.rest import db
from webservices.resources.candidates import CandidateList
from webservices.resources.candidate_aggregates import TotalsCandidateView
from webservices.resources.elections import ElectionView


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
        self.assertEqual(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertEqual(result['api_version'], __API_VERSION__)
        return result

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_candidate_counts_house(self):
        """
        Given base table candidate data, the list of candidates should be the same
        For /candidates/, /candidates/totals/, and /elections/
        """
        cand_valid_fec_yr_data = [
            {
                'cand_valid_yr_id': 1,
                'cand_id': 'H00000001',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cand_status': 'A',
                'cand_office': 'H',
                'cand_office_st': 'MD',
                'cand_office_district': '01',
                'date_entered': 'now()',
            },
            {
                'cand_valid_yr_id': 2,
                'cand_id': 'H00000002',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cand_status': 'A',
                'cand_office': 'H',
                'cand_office_st': 'MD',
                'cand_office_district': '01',
                'date_entered': 'now()',
            },
            {
                'cand_valid_yr_id': 3,
                'cand_id': 'H00000003',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cand_status': 'A',
                'cand_office': 'H',
                'cand_office_st': 'MD',
                'cand_office_district': '01',
                'date_entered': 'now()',
            },
        ]
        election_year = 2020
        self.create_cand_valid(cand_valid_fec_yr_data)

        cand_cmte_linkage_data = [
            {
                'linkage_id': 2,
                'cand_id': 'H00000001',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cmte_id': '2',
                'cmte_count_cand_yr': 1,
                'cmte_tp': 'H',
                'cmte_dsgn': 'P',
                'linkage_type': 'P',
                'date_entered': 'now()',
            },
            {
                'linkage_id': 4,
                'cand_id': 'H00000002',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cmte_id': '3',
                'cmte_count_cand_yr': 1,
                'cmte_tp': 'H',
                'cmte_dsgn': 'P',
                'linkage_type': 'P',
                'date_entered': 'now()',
            },
            {
                'linkage_id': 6,
                'cand_id': 'H00000003',
                'fec_election_yr': 2020,
                'cand_election_yr': 2020,
                'cmte_id': '3',
                'cmte_count_cand_yr': 1,
                'cmte_tp': 'H',
                'cmte_dsgn': 'P',
                'linkage_type': 'P',
                'date_entered': 'now()',
            },
        ]
        self.create_cand_cmte_linkage(cand_cmte_linkage_data)

        manage.refresh_materialized(concurrent=False)
        sql_extract = (
            "SELECT * from disclosure.cand_valid_fec_yr "
            + "WHERE cand_election_yr in ({}, {})".format(
                election_year - 1, election_year
            )
        )
        results_tab = self.connection.execute(sql_extract).fetchall()
        candidate_params = {
            'election_year': election_year,
            'cycle': election_year,
            'district': '01',
            'state': 'MD',
        }

        election_params = {
            'cycle': election_year,
            'election_full': True,
            'district': '01',
            'state': 'MD',
        }

        total_params = {
            'cycle': election_year,
            'election_full': True,
            'district': '01',
            'state': 'MD',
            'election_year': election_year,
        }
        candidates_api = self._results(rest.api.url_for(CandidateList, **candidate_params))
        candidates_totals_api = self._results(
            rest.api.url_for(TotalsCandidateView, **total_params)
        )
        elections_api = self._results(
            rest.api.url_for(ElectionView, office='house', **election_params)
        )
        assert (
            len(results_tab)
            == len(candidates_api)
            == len(candidates_totals_api)
            == len(elections_api)
        )

    def create_cand_valid(self, candidate_data):
        sql_insert = (
            "INSERT INTO disclosure.cand_valid_fec_yr \
            (cand_valid_yr_id, cand_id, fec_election_yr, cand_election_yr, \
            cand_status, cand_office, cand_office_st, cand_office_district, date_entered) \
            VALUES (%(cand_valid_yr_id)s, %(cand_id)s, \
            %(fec_election_yr)s, %(cand_election_yr)s, %(cand_status)s, %(cand_office)s, \
            %(cand_office_st)s, %(cand_office_district)s, %(date_entered)s)"
        )
        self.connection.execute(sql_insert, candidate_data)

    def create_cand_cmte_linkage(self, linkage_data):
        sql_insert = (
            "INSERT INTO disclosure.cand_cmte_linkage \
            (linkage_id, cand_id, fec_election_yr, cand_election_yr, \
            cmte_id, cmte_count_cand_yr, cmte_tp, cmte_dsgn, linkage_type, date_entered) \
            VALUES (%(linkage_id)s, %(cand_id)s, \
            %(fec_election_yr)s, %(cand_election_yr)s, %(cmte_id)s, %(cmte_count_cand_yr)s, \
            %(cmte_tp)s, %(cmte_dsgn)s, %(linkage_type)s, %(date_entered)s)"
        )
        self.connection.execute(sql_insert, linkage_data)
