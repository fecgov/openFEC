import datetime
import unittest
import functools

import sqlalchemy as sa

from .common import ApiBaseTest
from webservices import rest
from tests import factories


fields = dict(
    name='John Hoynes',
    form_type='F2',
    address_street_1='1600 Pennsylvania Avenue',
    address_city='Washington',
    address_state='DC',
    address_zip='20500',
    party='DEM',
    party_full='Democratic Party',
    active_through=2014,
    candidate_inactive='Y',
    candidate_status='C',
    incumbent_challenge='I',
    candidate_status_full='Candidate',
    office='H',
    district='08',
    state='VA',
    office_full='House',
)


class CandidateFormatTest(ApiBaseTest):
    """Test/Document expected formats"""
    def test_candidate(self):
        """Compare results to expected fields."""
        candidate_old = factories.CandidateDetailFactory(
            load_date=datetime.datetime(2014, 1, 2),
            **fields
        )
        candidate = factories.CandidateDetailFactory(
            load_date=datetime.datetime(2014, 1, 3),
            **fields
        )
        response = self._response('/candidate/{0}'.format(candidate.candidate_id))
        self.assertResultsEqual(
            response['pagination'],
            {'count': 1, 'page': 1, 'pages': 1, 'per_page': 20})
        # we are showing the full history rather than one result
        self.assertEqual(len(response['results']), 1)

        result = response['results'][0]
        self.assertEqual(result['candidate_id'], candidate.candidate_id)
        self.assertEqual(result['form_type'], 'F2')
        # @todo - check for a value for expire_data
        self.assertEqual(result['expire_date'], None)
        # # most recent record should be first
        self.assertEqual(result['load_date'], str(candidate.load_date))
        self.assertNotEqual(result['load_date'], str(candidate_old.load_date))
        self.assertResultsEqual(result['name'], candidate.name)
        # #address
        self.assertEqual(result['address_city'], candidate.address_city)
        self.assertEqual(result['address_state'], candidate.address_state)
        self.assertEqual(result['address_street_1'], candidate.address_street_1)
        self.assertEqual(result['address_zip'], candidate.address_zip)
        # # office
        self.assertResultsEqual(result['office'], candidate.office)
        self.assertResultsEqual(result['district'], candidate.district)
        self.assertResultsEqual(result['state'], candidate.state)
        self.assertResultsEqual(result['office_full'], candidate.office_full)
        # # From party_mapping
        self.assertResultsEqual(result['party'], candidate.party)
        self.assertResultsEqual(result['party_full'], candidate.party_full)
        # From status_mapping
        self.assertResultsEqual(result['active_through'], candidate.active_through)
        self.assertResultsEqual(result['candidate_inactive'], candidate.candidate_inactive)
        self.assertResultsEqual(result['candidate_status'], candidate.candidate_status)
        self.assertResultsEqual(result['incumbent_challenge'], candidate.incumbent_challenge)
        self.assertResultsEqual(result['candidate_status_full'], candidate.candidate_status_full)

    @unittest.skip("Fix later once we've figured out how to fix committee cardinality")
    def test_candidate_committees(self):
        """Compare results to expected fields."""
        # @todo - use a factory rather than the test data
        response = self._response('/candidate/H0VA08040/committees')
        committees = response['results'][0]['committees']
        self.prettyPrint(committees)
        self.assertResultsEqual(committees,
            [{
                # From cand_committee_format_mapping
                'committee_designation': 'P',
                'committee_designation_full': 'Principal campaign committee',
                'committee_id': 'C00241349',
                'committee_name': 'MORAN FOR CONGRESS',
                'committee_type': 'H',
                'committee_type_full': 'House',
                'election_year': 2014,
                'expire_date': None,
                'link_date': '2007-10-12 13:38:33',

            }])

        # The above candidate is missing a few fields
        response = self._response('/candidate/P20003984')
        committee = response['results'][0]['committees'][1]

        self.assertResultsEqual(committee['committee_type'], 'I')
        self.assertResultsEqual(committee['committee_type_full'], 'Independent Expenditor (Person or Group)')

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_fields(self):
        candidate = factories.CandidateDetailFactory()
        response = self._results('/candidate/{0}'.format(candidate.candidate_id))
        response = response[0]

        fields = ('party', 'party_full', 'state', 'district', 'incumbent_challenge_full', 'incumbent_challenge', 'candidate_status', 'candidate_status_full', 'office', 'active_through')

        for field in fields:
            self.assertIn(field, response)

    def test_extra_fields(self):
        candidate = factories.CandidateDetailFactory(
            address_street_1='PO Box 8102',
            address_zip='60680',
        )
        response = self._results('/candidate/{0}'.format(candidate.candidate_id))
        response = response[0]
        self.assertIn('committees', response)
        self.assertIn(candidate.address_street_1, response['address_street_1'])
        self.assertIn(candidate.address_zip, response['address_zip'])

    @unittest.skip("This functionality to be removed soon.")
    def test_candidate_committes(self):
        response = self._results('/candidate/P80003338?year=*')

        fields = ('committee_id', 'committee_designation', 'committee_designation_full', 'committee_type', 'committee_type_full', 'committee_name')

        election = response[0]['committees'][0]
        print(election)
        for field in fields:
            print(field)
            self.assertEquals(field in election, True)

    def test_cand_filters(self):
        [
            factories.CandidateFactory(office='H'),
            factories.CandidateFactory(district='00'),
            factories.CandidateFactory(district='02'),
            factories.CandidateFactory(state='CA'),
            factories.CandidateFactory(name='Obama'),
            factories.CandidateFactory(party='DEM'),
            factories.CandidateFactory(election_years=[2006]),
            factories.CandidateFactory(candidate_id='barlet'),
            factories.CandidateFactory(candidate_id='ritchie'),
        ]

        filter_fields = (
            ('office', 'H'),
            ('district', '00,02'),
            ('state', 'CA'),
            ('name', 'Obama'),
            ('party', 'DEM'),
            ('year', '2006'),
            ('candidate_id', 'bartlet,ritchie')
        )

        # checking one example from each field
        orig_response = self._response('/candidates')
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = "/candidates?%s=%s" % (field, example)
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])

    def test_candidate_history_by_year(self):
        key = 0
        id = 'id0'
        partial = functools.partial(
            factories.CandidateHistoryFactory,
            candidate_id=id, candidate_key=key,
        )
        histories = [
            partial(two_year_period=2012),
            partial(two_year_period=2008),
        ]
        results = self._results('/candidate/{0}/history/{1}'.format(id, histories[1].two_year_period))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['candidate_id'], id)
        self.assertEqual(results[0]['two_year_period'], histories[1].two_year_period)

    def test_candidate_history(self):
        key = 0
        id = 'id0'
        partial = functools.partial(
            factories.CandidateHistoryFactory,
            candidate_id=id, candidate_key=key,
        )
        histories = [
            partial(two_year_period=2012),
            partial(two_year_period=2008),
        ]
        results = self._results('/candidate/{0}/history'.format(id))
        recent_results = self._results('/candidate/{0}/history/recent'.format(id))

        # history/recent
        self.assertEqual(recent_results[0]['candidate_id'], histories[0].candidate_id)
        self.assertEqual(len(recent_results), 1)
        # /history
        self.assertEqual(results[0]['candidate_id'], id)
        self.assertEqual(results[1]['candidate_id'], id)
        self.assertEqual(results[0]['two_year_period'], histories[0].two_year_period)
        self.assertEqual(results[1]['two_year_period'], histories[1].two_year_period)
