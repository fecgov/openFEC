import datetime
import unittest
import functools

from marshmallow.utils import isoformat

from tests import factories
from tests.common import ApiBaseTest

from webservices import schemas
from webservices.rest import db
from webservices.rest import api
from webservices.resources.candidates import CandidateList
from webservices.resources.candidates import CandidateView
from webservices.resources.candidates import CandidateSearch
from webservices.resources.candidates import CandidateHistoryView


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
        response = self._response(
            api.url_for(CandidateView, candidate_id=candidate.candidate_id)
        )
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
        self.assertEqual(result['load_date'], isoformat(candidate.load_date))
        self.assertNotEqual(result['load_date'], isoformat(candidate_old.load_date))
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

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_candidates_search(self):
        principal_committee = factories.CommitteeFactory(designation='P')
        joint_committee = factories.CommitteeFactory(designation='J')
        candidate = factories.CandidateFactory()
        db.session.flush()
        [
            factories.CandidateCommitteeLinkFactory(
                candidate_key=candidate.candidate_key,
                committee_key=principal_committee.committee_key,
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_key=candidate.candidate_key,
                committee_key=joint_committee.committee_key,
            ),
        ]
        results = self._results(api.url_for(CandidateSearch))
        self.assertEqual(len(results), 1)
        self.assertIn('principal_committees', results[0])
        self.assertEqual(len(results[0]['principal_committees']), 1)
        self.assertEqual(
            results[0]['principal_committees'][0]['committee_id'],
            principal_committee.committee_id,
        )

    def test_fields(self):
        candidate = factories.CandidateDetailFactory()
        response = self._results(
            api.url_for(CandidateView, candidate_id=candidate.candidate_id)
        )
        assert response[0].keys() == schemas.CandidateDetailSchema().fields.keys()
        response = response[0]

    def test_extra_fields(self):
        candidate = factories.CandidateDetailFactory(
            address_street_1='PO Box 8102',
            address_zip='60680',
        )
        response = self._results(
            api.url_for(CandidateView, candidate_id=candidate.candidate_id)
        )
        response = response[0]
        self.assertIn(candidate.address_street_1, response['address_street_1'])
        self.assertIn(candidate.address_zip, response['address_zip'])

    def test_cand_filters(self):
        [
            factories.CandidateFactory(office='H'),
            factories.CandidateFactory(district='00'),
            factories.CandidateFactory(district='02'),
            factories.CandidateFactory(state='CA'),
            factories.CandidateFactory(name='Obama'),
            factories.CandidateFactory(party='DEM'),
            factories.CandidateFactory(cycles=[2006]),
            factories.CandidateFactory(candidate_id='barlet'),
            factories.CandidateFactory(candidate_id='ritchie'),
        ]

        filter_fields = (
            ('office', 'H'),
            ('district', ['00', '02']),
            ('state', 'CA'),
            ('name', 'Obama'),
            ('party', 'DEM'),
            ('cycle', '2006'),
            ('candidate_id', ['bartlet', 'ritchie'])
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(CandidateList))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(CandidateList, **{field: example})
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
        results = self._results(
            api.url_for(
                CandidateHistoryView,
                candidate_id=id,
                cycle=histories[1].two_year_period,
            )
        )
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
        results = self._results(
            api.url_for(CandidateHistoryView, candidate_id=id)
        )

        self.assertEqual(results[0]['candidate_id'], id)
        self.assertEqual(results[1]['candidate_id'], id)
        self.assertEqual(results[0]['two_year_period'], histories[0].two_year_period)
        self.assertEqual(results[1]['two_year_period'], histories[1].two_year_period)

    def test_candidate_sort(self):
        candidates = [
            factories.CandidateFactory(candidate_status='P'),
            factories.CandidateFactory(candidate_status='C'),
        ]
        candidate_ids = [each.candidate_id for each in candidates]
        results = self._results(api.url_for(CandidateList, sort='candidate_status'))
        self.assertEqual([each['candidate_id'] for each in results], candidate_ids[::-1])
        results = self._results(api.url_for(CandidateSearch, sort='candidate_status'))
        self.assertEqual([each['candidate_id'] for each in results], candidate_ids[::-1])
        results = self._results(api.url_for(CandidateList, sort='-candidate_status'))
        self.assertEqual([each['candidate_id'] for each in results], candidate_ids)
        results = self._results(api.url_for(CandidateSearch, sort='-candidate_status'))
        self.assertEqual([each['candidate_id'] for each in results], candidate_ids)

    def test_candidate_multi_sort(self):
        candidates = [
            factories.CandidateFactory(candidate_status='C', party='DFL'),
            factories.CandidateFactory(candidate_status='P', party='FLP'),
            factories.CandidateFactory(candidate_status='P', party='REF'),
        ]
        candidate_ids = [each.candidate_id for each in candidates]
        results = self._results(api.url_for(CandidateList, sort=['candidate_status', 'party']))
        self.assertEqual([each['candidate_id'] for each in results], candidate_ids)
        results = self._results(api.url_for(CandidateList, sort=['candidate_status', '-party']))
        self.assertEqual(
            [each['candidate_id'] for each in results],
            [candidate_ids[0], candidate_ids[2], candidate_ids[1]],
        )
