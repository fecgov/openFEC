import datetime
from tests import factories
from tests.common import ApiBaseTest, assert_dicts_subset

from webservices.rest import db, api
from webservices.resources.elections import (
    ElectionsListView,
    ElectionView,
    ElectionSummary,
    StateElectionOfficeInfoView,
)


class TestElectionSearch(ApiBaseTest):
    def setUp(self):
        super().setUp()
        factories.ElectionsListFactory(
            office='P', state='US', district='00', incumbent_id='P12345'
        )
        factories.ElectionsListFactory(
            office='S', state='NJ', district='00', incumbent_id='SNJ123'
        )
        factories.ElectionsListFactory(
            office='H', state='NJ', district='09', incumbent_id='HNJ123'
        )
        factories.ElectionsListFactory(
            office='S', state='VA', district='00', incumbent_id='SVA123'
        )
        factories.ElectionsListFactory(
            office='H', state='VA', district='04', incumbent_id='HVA121'
        )
        factories.ElectionsListFactory(
            office='H', state='VA', district='05', incumbent_id='HVA123'
        )
        factories.ElectionsListFactory(
            office='H', state='VA', district='06', incumbent_id='HVA124'
        )
        factories.ElectionsListFactory(
            office='S', state='GA', district='00', incumbent_id='SGA123'
        )

    def test_search_district(self):
        results = self._results(
            api.url_for(ElectionsListView, state='NJ', district='09')
        )
        self.assertEqual(len(results), 3)
        assert_dicts_subset(
            results[0], {'cycle': 2012, 'office': 'P', 'state': 'US', 'district': '00'}
        )
        assert_dicts_subset(
            results[1], {'cycle': 2012, 'office': 'S', 'state': 'NJ', 'district': '00'}
        )
        assert_dicts_subset(
            results[2], {'cycle': 2012, 'office': 'H', 'state': 'NJ', 'district': '09'}
        )

    def test_search_district_padding(self):
        results_padded = self._results(api.url_for(ElectionsListView, district='09'))
        results_unpadded = self._results(api.url_for(ElectionsListView, district=9))
        self.assertEqual(len(results_padded), len(results_unpadded))
        self.assertEqual(len(results_unpadded), 5)

    def test_search_office(self):
        results = self._results(api.url_for(ElectionsListView, office='senate'))
        self.assertEqual(len(results), 3)
        self.assertTrue(all([each['office'] == 'S' for each in results]))

    def test_search_zip(self):
        factories.ZipsDistrictsFactory(
            district='05', zip_code='22902', state_abbrevation='VA'
        )

        results = self._results(api.url_for(ElectionsListView, zip='22902'))
        assert len(results) == 3
        assert_dicts_subset(
            results[0], {'cycle': 2012, 'office': 'P', 'state': 'US', 'district': '00'}
        )
        assert_dicts_subset(
            results[1], {'cycle': 2012, 'office': 'S', 'state': 'VA', 'district': '00'}
        )
        assert_dicts_subset(
            results[2], {'cycle': 2012, 'office': 'H', 'state': 'VA', 'district': '05'}
        )

    def test_counts(self):
        response = self._response(api.url_for(ElectionsListView))
        footer_count = response['pagination']['count']
        results_count = len(response['results'])
        self.assertEqual(footer_count, results_count)

    def test_search_sort_default(self):
        results = self._results(api.url_for(ElectionsListView, state='VA'))
        self.assertEqual(results[0]['office'], 'P')
        self.assertEqual(results[1]['office'], 'S')
        self.assertEqual(results[2]['district'], '04')
        self.assertEqual(results[3]['district'], '05')
        self.assertEqual(results[4]['district'], '06')

    def test_search_sort_state(self):
        results = self._results(api.url_for(ElectionsListView))
        self.assertTrue(
            [each['state'] for each in results],
            ['GA', 'NJ', 'NJ', 'US', 'VA', 'VA', 'VA', 'VA'],
        )


class TestElections(ApiBaseTest):
    def setUp(self):
        super().setUp()
        self.candidate = factories.CandidateDetailFactory()
        self.candidates = [
            factories.CandidateHistoryFactory(
                candidate_id=self.candidate.candidate_id,
                state='NY',
                two_year_period=2012,
                election_years=[2010, 2012],
                cycles=[2010, 2012],
                office='S',
                candidate_election_year=2012,
            ),
            factories.CandidateHistoryFactory(
                candidate_id=self.candidate.candidate_id,
                state='NY',
                two_year_period=2010,
                election_years=[2010, 2012],
                cycles=[2010, 2012],
                office='S',
                candidate_election_year=2012,
            ),
        ]
        self.committees = [
            factories.CommitteeHistoryFactory(cycle=2012, designation='P'),
            factories.CommitteeHistoryFactory(cycle=2012, designation='A'),
        ]
        [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate.candidate_id, cand_election_year=year
            )
            for year in [2010, 2012]
        ]
        [
            factories.CommitteeDetailFactory(committee_id=each.committee_id)
            for each in self.committees
        ]
        db.session.flush()
        self.candidate_committee_links = [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[0].committee_id,
                committee_designation='A',
                fec_election_year=2012,
                election_yr_to_be_included=2012,
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[1].committee_id,
                committee_designation='P',
                fec_election_year=2012,
                election_yr_to_be_included=2012,
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[1].committee_id,
                committee_designation='P',
                fec_election_year=2010,
                election_yr_to_be_included=2012,
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[1].committee_id,
                committee_designation='P',
                fec_election_year=2010,
            ),
        ]
        self.totals = [
            factories.TotalsHouseSenateFactory(
                receipts=50,
                disbursements=75,
                committee_id=self.committees[0].committee_id,
                coverage_end_date=datetime.datetime(2012, 9, 30),
                last_cash_on_hand_end_period=100,
                cycle=2012,
            ),
            factories.TotalsHouseSenateFactory(
                receipts=50,
                disbursements=75,
                committee_id=self.committees[1].committee_id,
                coverage_end_date=datetime.datetime(2012, 12, 31),
                last_cash_on_hand_end_period=100,
                cycle=2012,
            ),
            factories.TotalsHouseSenateFactory(
                receipts=50,
                disbursements=75,
                committee_id=self.committees[1].committee_id,
                coverage_end_date=datetime.datetime(2012, 12, 31),
                last_cash_on_hand_end_period=300,
                cycle=2010,
            ),
        ]

        self.president_candidate = factories.CandidateDetailFactory()
        self.president_candidates = [
            factories.CandidateHistoryFactory(
                candidate_id=self.president_candidate.candidate_id,
                state='NY',
                two_year_period=2020,
                office='P',
                candidate_inactive=False,
                candidate_election_year=2020,
            ),
            factories.CandidateHistoryFactory(
                candidate_id=self.president_candidate.candidate_id,
                state='NY',
                two_year_period=2018,
                office='P',
                candidate_inactive=False,
                candidate_election_year=2020,
            ),
        ]
        self.president_committees = [
            factories.CommitteeHistoryFactory(cycle=2020, designation='P'),
            factories.CommitteeHistoryFactory(cycle=2020, designation='J'),
        ]
        [
            factories.CandidateElectionFactory(
                candidate_id=self.president_candidate.candidate_id,
                cand_election_year=year,
            )
            for year in [2016, 2020]
        ]
        [
            factories.CommitteeDetailFactory(committee_id=each.committee_id)
            for each in self.president_committees
        ]
        db.session.flush()
        self.president_candidate_committee_links = [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.president_candidate.candidate_id,
                committee_id=self.president_committees[0].committee_id,
                committee_designation='P',
                fec_election_year=2020,
                cand_election_year=2020,
                election_yr_to_be_included=2020,
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.president_candidate.candidate_id,
                committee_id=self.president_committees[0].committee_id,
                committee_designation='P',
                fec_election_year=2018,
                cand_election_year=2020,
                election_yr_to_be_included=2020,
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.president_candidate.candidate_id,
                committee_id=self.president_committees[1].committee_id,
                committee_designation='P',
                fec_election_year=2018,
                cand_election_year=2020,
                election_yr_to_be_included=2020,
            ),
        ]

        self.presidential_totals = [
            factories.TotalsCombinedFactory(
                receipts=50,
                disbursements=75,
                committee_id=self.president_committees[0].committee_id,
                coverage_end_date=datetime.datetime(2019, 9, 30),
                last_cash_on_hand_end_period=0,
                cycle=2020,
            ),
            factories.TotalsCombinedFactory(
                receipts=1,
                disbursements=1,
                committee_id=self.president_committees[1].committee_id,
                coverage_end_date=datetime.datetime(2017, 12, 31),
                last_cash_on_hand_end_period=100,
                cycle=2018,
            ),
            factories.TotalsCombinedFactory(
                receipts=25,
                disbursements=10,
                committee_id=self.president_committees[0].committee_id,
                coverage_end_date=datetime.datetime(2017, 12, 31),
                last_cash_on_hand_end_period=300,
                cycle=2018,
            ),
        ]

    def test_missing_params(self):
        response = self.app.get(api.url_for(ElectionView))
        self.assertEqual(response.status_code, 422)

    def test_conditional_missing_params(self):
        response = self.app.get(
            api.url_for(ElectionView, office='president', cycle=2012)
        )
        self.assertEqual(response.status_code, 200)
        response = self.app.get(api.url_for(ElectionView, office='senate', cycle=2012))
        self.assertEqual(response.status_code, 422)
        response = self.app.get(
            api.url_for(ElectionView, office='senate', cycle=2012, state='NY')
        )
        self.assertEqual(response.status_code, 200)
        response = self.app.get(
            api.url_for(ElectionView, office='house', cycle=2012, state='NY')
        )
        self.assertEqual(response.status_code, 422)
        response = self.app.get(
            api.url_for(
                ElectionView, office='house', cycle=2012, state='NY', district='01'
            )
        )
        self.assertEqual(response.status_code, 200)

    def test_empty_query(self):
        results = self._results(
            api.url_for(ElectionView, office='senate', cycle=2012, state='ZZ')
        )
        assert len(results) == 0

    def test_elections(self):
        results = self._results(
            api.url_for(
                ElectionView,
                office='senate',
                cycle=2012,
                state='NY',
                election_full=False,
            )
        )
        self.assertEqual(len(results), 1)
        totals = [each for each in self.totals if each.cycle == 2012]
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'candidate_name': self.candidate.name,
            'incumbent_challenge_full': self.candidate.incumbent_challenge_full,
            'party_full': self.candidate.party_full,
            'total_receipts': sum(each.receipts for each in totals),
            'total_disbursements': sum(each.disbursements for each in totals),
            'cash_on_hand_end_period': sum(
                each.last_cash_on_hand_end_period for each in totals
            ),
        }
        assert_dicts_subset(results[0], expected)
        assert set(each.committee_id for each in self.committees) == set(
            results[0]['committee_ids']
        )

    def test_elections_full(self):
        results = self._results(
            api.url_for(
                ElectionView,
                office='senate',
                cycle=2012,
                state='NY',
                election_full='true',
            )
        )
        totals = self.totals
        cash_on_hand_totals = self.totals[:2]
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'candidate_name': self.candidate.name,
            'incumbent_challenge_full': self.candidate.incumbent_challenge_full,
            'party_full': self.candidate.party_full,
            'total_receipts': sum(each.receipts for each in totals),
            'total_disbursements': sum(each.disbursements for each in totals),
            'cash_on_hand_end_period': sum(
                each.last_cash_on_hand_end_period for each in cash_on_hand_totals
            ),
        }
        assert len(results) == 1
        assert_dicts_subset(results[0], expected)
        assert set(results[0]['committee_ids']) == set(
            each.committee_id for each in self.committees if each.designation != 'J'
        )

    def test_elections_year_null(self):
        results = self._results(
            api.url_for(
                ElectionView,
                office='senate',
                cycle=2010,
                state='NY',
                election_full='true',
            )
        )
        totals = self.totals  # noqa
        cash_on_hand_totals = self.totals[:2]  # noqa
        assert len(results) == 0

    def test_president_elections_full(self):
        results = self._results(
            api.url_for(
                ElectionView, office='president', cycle=2020, election_full='true',
            )
        )
        totals = self.presidential_totals
        cash_on_hand_totals = self.presidential_totals[:2]
        expected = {
            'candidate_id': self.president_candidate.candidate_id,
            'candidate_name': self.president_candidate.name,
            'incumbent_challenge_full': self.president_candidate.incumbent_challenge_full,
            'party_full': self.president_candidate.party_full,
            'total_receipts': sum(each.receipts for each in totals),
            'total_disbursements': sum(each.disbursements for each in totals),
            'cash_on_hand_end_period': sum(
                each.last_cash_on_hand_end_period for each in cash_on_hand_totals
            ),
        }
        assert len(results) == 1
        assert_dicts_subset(results[0], expected)

    def test_electionview_excludes_jfc(self):
        self.candidate_committee_links[0].committee_designation = 'J'
        self.committees[0].designation = 'J'

        results = self._results(
            api.url_for(
                ElectionView,
                office='senate',
                cycle=2012,
                state='NY',
                election_full='true',
            )
        )
        # Joint Fundraising Committees raise money for multiple
        # candidate committees and transfer that money to those committees.
        # By limiting the committee designations to A and P
        # you eliminate J (joint) and thus do not inflate
        # the candidate's money by including it twice and
        # by including money that was raised and transferred
        # to the other committees in the joint fundraiser.
        totals_without_jfc = self.totals[1:]
        cash_on_hand_without_jfc = self.totals[1:2]
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'candidate_name': self.candidate.name,
            'incumbent_challenge_full': self.candidate.incumbent_challenge_full,
            'party_full': self.candidate.party_full,
            'total_receipts': sum(each.receipts for each in totals_without_jfc),
            'total_disbursements': sum(
                each.disbursements for each in totals_without_jfc
            ),
            'cash_on_hand_end_period': sum(
                each.last_cash_on_hand_end_period for each in cash_on_hand_without_jfc
            ),
        }
        assert len(results) == 1
        assert_dicts_subset(results[0], expected)
        assert set(results[0]['committee_ids']) == set(
            each.committee_id for each in self.committees if each.designation != 'J'
        )

    def test_election_summary(self):
        results = self._response(
            api.url_for(
                ElectionSummary,
                office='senate',
                cycle=2012,
                state='NY',
                election_full=False,
            )
        )
        totals = [each for each in self.totals if each.cycle == 2012]
        self.assertEqual(results['count'], 1)
        self.assertEqual(results['receipts'], sum(each.receipts for each in totals))
        self.assertEqual(
            results['disbursements'], sum(each.disbursements for each in totals)
        )


class TestPRElections(ApiBaseTest):
    def setUp(self):
        super().setUp()
        self.candidate = factories.CandidateDetailFactory()
        self.candidates = [
            factories.CandidateHistoryFactory(
                candidate_id=self.candidate.candidate_id,
                state='PR',
                district='00',
                two_year_period=2018,
                election_years=[2020],
                cycles=[2018, 2020],
                office='H',
                candidate_election_year=2020,
            ),
            factories.CandidateHistoryFactory(
                candidate_id=self.candidate.candidate_id,
                state='PR',
                district='00',
                two_year_period=2020,
                election_years=[2020],
                cycles=[2018, 2020],
                office='H',
                candidate_election_year=2020,
            ),
        ]
        self.committees = [
            factories.CommitteeHistoryFactory(cycle=2020, designation='P'),
            factories.CommitteeHistoryFactory(cycle=2020, designation='A'),
        ]
        [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate.candidate_id, cand_election_year=year
            )
            for year in [2016, 2020]
        ]
        [
            factories.CommitteeDetailFactory(committee_id=each.committee_id)
            for each in self.committees
        ]
        db.session.flush()
        self.candidate_committee_links = [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[0].committee_id,
                committee_designation='P',
                fec_election_year=2018,
                election_yr_to_be_included=2020,
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[1].committee_id,
                committee_designation='A',
                fec_election_year=2018,
                election_yr_to_be_included=2020,
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[0].committee_id,
                committee_designation='P',
                fec_election_year=2020,
                election_yr_to_be_included=2020,
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[1].committee_id,
                committee_designation='A',
                fec_election_year=2020,
                election_yr_to_be_included=2020,
            ),
        ]
        self.totals = [
            factories.TotalsHouseSenateFactory(
                receipts=50,
                disbursements=75,
                committee_id=self.committees[1].committee_id,
                coverage_end_date=datetime.datetime(2018, 12, 31),
                last_cash_on_hand_end_period=100,
                cycle=2018,
            ),
            factories.TotalsHouseSenateFactory(
                receipts=50,
                disbursements=75,
                committee_id=self.committees[1].committee_id,
                coverage_end_date=datetime.datetime(2020, 12, 31),
                last_cash_on_hand_end_period=300,
                cycle=2020,
            ),
        ]
        db.session.flush()

    def test_elections_2_year(self):
        results = self._results(
            api.url_for(
                ElectionView,
                office='house',
                district='00',
                cycle=2020,
                state='PR',
                election_full=False,
            )
        )
        self.assertEqual(len(results), 1)
        totals = [each for each in self.totals if each.cycle == 2020]
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'candidate_name': self.candidate.name,
            'incumbent_challenge_full': self.candidate.incumbent_challenge_full,
            'party_full': self.candidate.party_full,
            'total_receipts': sum(each.receipts for each in totals),
            'total_disbursements': sum(each.disbursements for each in totals),
            'cash_on_hand_end_period': sum(
                each.last_cash_on_hand_end_period for each in totals
            ),
        }
        assert_dicts_subset(results[0], expected)
        assert set(each.committee_id for each in self.committees) == set(
            results[0]['committee_ids']
        )

    def test_elections_full(self):
        results = self._results(
            api.url_for(
                ElectionView,
                office='house',
                district='00',
                cycle=2020,
                state='PR',
                election_full='true',
            )
        )
        totals = self.totals
        cash_on_hand_totals = self.totals[:2]
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'candidate_name': self.candidate.name,
            'incumbent_challenge_full': self.candidate.incumbent_challenge_full,
            'party_full': self.candidate.party_full,
            'total_receipts': sum(each.receipts for each in totals),
            'total_disbursements': sum(each.disbursements for each in totals),
            'cash_on_hand_end_period': max(
                each.last_cash_on_hand_end_period for each in cash_on_hand_totals
            ),
        }
        assert len(results) == 1
        assert_dicts_subset(results[0], expected)


class TestStateElectionOffices(ApiBaseTest):
    def test_filter_match(self):
        # Filter for a single string value
        [
            factories.StateElectionOfficesFactory(
                state='TX', office_type='STATE CAMPAIGN FINANCE'
            ),
            factories.StateElectionOfficesFactory(
                state='AK', office_type='STATE CAMPAIGN FINANCE'
            ),
            factories.StateElectionOfficesFactory(
                state='WA', office_type='STATE CAMPAIGN FINANCE'
            ),
        ]
        results = self._results(api.url_for(StateElectionOfficeInfoView, state='TX'))

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['state'], 'TX')
