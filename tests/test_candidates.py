import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest

from webservices import rest
from webservices import schemas
from webservices.rest import db
from webservices.rest import api
from webservices.resources.candidates import CandidateList
from webservices.resources.candidates import CandidateView
from webservices.resources.candidates import CandidateSearch
from webservices.resources.candidates import CandidateHistoryView


fields = dict(
    name='John Hoynes',
    address_street_1='1600 Pennsylvania Avenue',
    address_city='Washington',
    address_state='DC',
    address_zip='20500',
    party='DEM',
    party_full='Democratic Party',
    active_through=2014,
    candidate_inactive=True,
    candidate_status='C',
    incumbent_challenge='I',
    office='H',
    district='08',
    state='VA',
    office_full='House',
)


class CandidateFormatTest(ApiBaseTest):
    """Test/Document expected formats"""

    def test_candidate(self):
        """Compare results to expected fields."""
        candidate = factories.CandidateDetailFactory(**fields)
        response = self._response(
            api.url_for(CandidateView, candidate_id=candidate.candidate_id)
        )
        assert response['pagination'] == {
            'count': 1,
            'page': 1,
            'pages': 1,
            'per_page': 20,
            'is_count_exact': True,
        }
        # we are showing the full history rather than one result
        assert len(response['results']) == 1

        result = response['results'][0]
        assert result['candidate_id'] == candidate.candidate_id
        # # most recent record should be first
        assert result['name'] == candidate.name
        # #address
        assert result['address_city'] == candidate.address_city
        assert result['address_state'] == candidate.address_state
        assert result['address_street_1'] == candidate.address_street_1
        assert result['address_zip'] == candidate.address_zip
        # # office
        assert result['office'] == candidate.office
        assert result['district'] == candidate.district
        assert result['state'] == candidate.state
        assert result['office_full'] == candidate.office_full
        # # From party_mapping
        assert result['party'] == candidate.party
        assert result['party_full'] == candidate.party_full
        # From status_mapping
        assert result['active_through'] == candidate.active_through
        assert result['candidate_inactive'] == candidate.candidate_inactive
        assert result['candidate_status'] == candidate.candidate_status
        assert result['incumbent_challenge'] == candidate.incumbent_challenge

    def test_candidates_search(self):
        principal_committee = factories.CommitteeFactory(designation='P')
        joint_committee = factories.CommitteeFactory(designation='J')
        candidate = factories.CandidateFactory()
        db.session.flush()
        [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=candidate.candidate_id,
                committee_id=principal_committee.committee_id,
                committee_designation='P',
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=candidate.candidate_id,
                committee_id=joint_committee.committee_id,
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
        factories.CandidateFlagsFactory(candidate_id=candidate.candidate_id)
        response = self._results(
            api.url_for(CandidateView, candidate_id=candidate.candidate_id)
        )
        assert response[0].keys() == schemas.CandidateDetailSchema().fields.keys()

    def test_extra_fields(self):
        candidate = factories.CandidateDetailFactory(
            address_street_1='PO Box 8102', address_zip='60680',
        )
        response = self._results(
            api.url_for(CandidateView, candidate_id=candidate.candidate_id)
        )
        response = response[0]
        self.assertIn(candidate.address_street_1, response['address_street_1'])
        self.assertIn(candidate.address_zip, response['address_zip'])

    def test_fulltext_match(self):
        danielle = factories.CandidateFactory(name='Danielle')
        factories.CandidateSearchFactory(
            id=danielle.candidate_id, fulltxt=sa.func.to_tsvector('Danielle')
        )
        dana = factories.CandidateFactory(name='Dana')
        factories.CandidateSearchFactory(
            id=dana.candidate_id, fulltxt=sa.func.to_tsvector('Dana')
        )
        rest.db.session.flush()
        results = self._results(api.url_for(CandidateList, q='danielle'))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['candidate_id'], danielle.candidate_id)
        results = self._results(api.url_for(CandidateList, q='dan'))
        self.assertEqual(len(results), 2)
        self.assertEqual(
            set(each['candidate_id'] for each in results),
            {danielle.candidate_id, dana.candidate_id},
        )

    def test_cand_filters(self):
        [
            factories.CandidateFactory(office='H'),
            factories.CandidateFactory(district='00'),
            factories.CandidateFactory(district='02'),
            factories.CandidateFactory(state='CA'),
            factories.CandidateFactory(name='Obama'),
            factories.CandidateFactory(party='DEM'),
            factories.CandidateFactory(cycles=[2006]),
            factories.CandidateFactory(candidate_id='H00000011'),
            factories.CandidateFactory(candidate_id='H00000022'),
            factories.CandidateFactory(candidate_inactive=True),
            factories.CandidateFactory(inactive_election_years=[2012]),
        ]

        filter_fields = (
            ('office', 'H'),
            ('district', ['00', '02']),
            ('state', 'CA'),
            ('party', 'DEM'),
            ('cycle', '2006'),
            ('candidate_id', ['H00000011', 'H00000022']),
            ('is_active_candidate', False),
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

    def test_candidate_sort(self):
        candidates = [
            factories.CandidateFactory(candidate_status='P'),
            factories.CandidateFactory(candidate_status='C'),
        ]
        candidate_ids = [each.candidate_id for each in candidates]
        results = self._results(api.url_for(CandidateList, sort='candidate_status'))
        self.assertEqual(
            [each['candidate_id'] for each in results], candidate_ids[::-1]
        )
        results = self._results(api.url_for(CandidateSearch, sort='candidate_status'))
        self.assertEqual(
            [each['candidate_id'] for each in results], candidate_ids[::-1]
        )
        results = self._results(api.url_for(CandidateList, sort='-candidate_status'))
        self.assertEqual([each['candidate_id'] for each in results], candidate_ids)
        results = self._results(api.url_for(CandidateSearch, sort='-candidate_status'))
        self.assertEqual([each['candidate_id'] for each in results], candidate_ids)

    def test_candidate_sort_nulls_last(self):
        """
        Nulls will sort last by default when sorting ascending -
        sort_nulls_last forces nulls to the bottom for descending sort
        """
        candidates = [
            factories.CandidateFactory(candidate_id='1'),
            factories.CandidateFactory(candidate_id='2', candidate_status='P'),
            factories.CandidateFactory(candidate_id='3', candidate_status='C'),
        ]
        candidate_ids = [each.candidate_id for each in candidates]
        results = self._results(
            api.url_for(CandidateList, sort='candidate_status', sort_nulls_last=True)
        )
        self.assertEqual(
            [each['candidate_id'] for each in results], candidate_ids[::-1]
        )
        results = self._results(
            api.url_for(CandidateList, sort='-candidate_status', sort_nulls_last=True)
        )
        self.assertEqual([each['candidate_id'] for each in results], ['2', '3', '1'])

    def test_page_validation(self):
        response = self.app.get(
            api.url_for(CandidateList, page=0)
        )
        self.assertEqual(response.status_code, 422)


class TestCandidateHistory(ApiBaseTest):
    def setUp(self):
        super().setUp()
        self.committee = factories.CommitteeDetailFactory()
        self.candidates = [
            factories.CandidateDetailFactory(candidate_id='P00000001'),
            factories.CandidateDetailFactory(candidate_id='P00000002'),
        ]
        self.histories = [
            factories.CandidateHistoryFactory(
                candidate_id=self.candidates[0].candidate_id,
                two_year_period=2010,
                candidate_election_year=2012,
            ),
            factories.CandidateHistoryFactory(
                candidate_id=self.candidates[1].candidate_id,
                two_year_period=2012,
                candidate_election_year=2012,
            ),
        ]
        db.session.flush()
        self.links = [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidates[0].candidate_id,
                committee_id=self.committee.committee_id,
                election_yr_to_be_included=2012,
                fec_election_year=2010,
                committee_type='P',
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidates[1].candidate_id,
                committee_id=self.committee.committee_id,
                election_yr_to_be_included=2012,
                fec_election_year=2012,
                committee_type='P',
            ),
        ]

    def test_history(self):
        history_2012 = factories.CandidateHistoryFactory(two_year_period=2012)
        history_2008 = factories.CandidateHistoryFactory(
            two_year_period=2008, candidate_id=history_2012.candidate_id
        )
        results = self._results(
            api.url_for(CandidateHistoryView, candidate_id=history_2012.candidate_id)
        )

        assert results[0]['candidate_id'] == history_2012.candidate_id
        assert results[1]['candidate_id'] == history_2012.candidate_id
        assert results[0]['two_year_period'] == history_2012.two_year_period
        assert results[1]['two_year_period'] == history_2008.two_year_period

    def test_election_full(self):
        # When election_full=true, return all two_year_periods with that candidate_election_year
        candidate = factories.CandidateDetailFactory(candidate_id='H00000001')
        first_two_year_period = factories.CandidateHistoryFactory(
            candidate_id=candidate.candidate_id,
            two_year_period=2018,
            candidate_election_year=2020,
        )
        second_two_year_period = factories.CandidateHistoryFactory(
            candidate_id=candidate.candidate_id,
            two_year_period=2020,
            candidate_election_year=2020,
        )
        db.session.flush()
        # Link
        factories.CandidateCommitteeLinkFactory(
            candidate_id=candidate.candidate_id,
            fec_election_year=2018,
            committee_type='H',
            election_yr_to_be_included=2020,
        )

        # test election_full='false'
        results_false = self._results(
            api.url_for(
                CandidateHistoryView,
                candidate_id=candidate.candidate_id,
                cycle=2018,
                election_full='false',
            )
        )
        assert len(results_false) == 1
        assert results_false[0]['candidate_id'] == first_two_year_period.candidate_id
        assert (
            results_false[0]['two_year_period'] == first_two_year_period.two_year_period
        )
        assert (
            results_false[0]['candidate_election_year']
            == first_two_year_period.candidate_election_year
        )

        # test election_full='true'
        results_true = self._results(
            api.url_for(
                CandidateHistoryView,
                candidate_id=candidate.candidate_id,
                cycle=2020,
                election_full='true',
            )
        )
        assert len(results_true) == 2
        assert results_true[0]['candidate_id'] == second_two_year_period.candidate_id
        assert (
            results_true[0]['two_year_period'] == second_two_year_period.two_year_period
        )
        assert (
            results_true[0]['candidate_election_year']
            == second_two_year_period.candidate_election_year
        )
        # Default sort is two_year_period descending
        assert results_true[1]['candidate_id'] == first_two_year_period.candidate_id
        assert (
            results_true[1]['two_year_period'] == first_two_year_period.two_year_period
        )
        assert (
            results_true[1]['candidate_election_year']
            == first_two_year_period.candidate_election_year
        )

    def test_committee_cycle(self):
        results = self._results(
            api.url_for(
                CandidateHistoryView,
                committee_id=self.committee.committee_id,
                cycle=2012,
                election_full=False,
            )
        )
        assert len(results) == 1
        assert results[0]['two_year_period'] == 2012
        assert results[0]['candidate_id'] == self.candidates[1].candidate_id

    def test_case_insensitivity(self):
        results = self._results(
            api.url_for(
                CandidateHistoryView,
                committee_id=self.committee.committee_id.lower(),
                cycle=2012,
                election_full=False,
            )
        )
        assert len(results) == 1
        assert results[0]['candidate_id'] == self.candidates[1].candidate_id

        results = self._results(
            api.url_for(
                CandidateHistoryView,
                candidate_id=self.candidates[1].candidate_id.lower(),
                cycle=2012,
                election_full=False,
            )
        )
        assert len(results) == 1
        assert results[0]['candidate_id'] == self.candidates[1].candidate_id

    def test_parsed_candidate_name(self):
        candidate = factories.CandidateHistoryFactory(
            candidate_id='H8VA00035',
            name='John Hoynes',
            candidate_first_name='JOHN',
            candidate_last_name='HOYNES'
        )

        results = self._results(
            api.url_for(
                CandidateHistoryView,
                candidate_id=candidate.candidate_id,
            )
        )
        assert len(results) == 1
        assert results[0]['candidate_first_name'] == candidate.candidate_first_name
