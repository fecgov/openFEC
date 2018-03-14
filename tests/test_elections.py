import datetime
import functools

from tests import factories
from tests.common import ApiBaseTest, assert_dicts_subset

from webservices.rest import db, api
from webservices.resources.elections import ElectionsListView, ElectionView, ElectionSummary, StateElectionOfficeInfoView
from webservices.common.models.elections import StateElectionOfficeInfo
from webservices.schemas import StateElectionOfficeInfoSchema
# class TestElectionSearch(ApiBaseTest):

#     def setUp(self):
#         super().setUp()
#         factories.ElectionsListFactory(office='P', state='US', district='00', incumbent_id='P12345')
#         factories.ElectionsListFactory(office='S', state='NJ', district='00', incumbent_id='SNJ123')
#         factories.ElectionsListFactory(office='H', state='NJ', district='09', incumbent_id='HNJ123')
#         factories.ElectionsListFactory(office='S', state='VA', district='00', incumbent_id='SVA123')
#         factories.ElectionsListFactory(office='H', state='VA', district='04', incumbent_id='HVA121')
#         factories.ElectionsListFactory(office='H', state='VA', district='05', incumbent_id='HVA123')
#         factories.ElectionsListFactory(office='H', state='VA', district='06', incumbent_id='HVA124')
#         factories.ElectionsListFactory(office='S', state='GA', district='00', incumbent_id='SGA123')

#     def test_search_district(self):
#         results = self._results(api.url_for(ElectionsListView, state='NJ', district='09'))
#         self.assertEqual(len(results), 3)
#         assert_dicts_subset(results[0], {'cycle': 2012, 'office': 'P', 'state': 'US', 'district': '00'})
#         assert_dicts_subset(results[1], {'cycle': 2012, 'office': 'S', 'state': 'NJ', 'district': '00'})
#         assert_dicts_subset(results[2], {'cycle': 2012, 'office': 'H', 'state': 'NJ', 'district': '09'})

#     def test_search_district_padding(self):
#         results_padded = self._results(api.url_for(ElectionsListView, district='09'))
#         results_unpadded = self._results(api.url_for(ElectionsListView, district=9))
#         self.assertEqual(len(results_padded), len(results_unpadded))
#         self.assertEqual(len(results_unpadded), 5)

#     def test_search_office(self):
#         results = self._results(api.url_for(ElectionsListView, office='senate'))
#         self.assertEqual(len(results), 3)
#         self.assertTrue(all([each['office'] == 'S' for each in results]))

#     def test_search_zip(self):
#         factories.ZipsDistrictsFactory(district='05', zip_code='22902', state_abbrevation='VA')

#         results = self._results(api.url_for(ElectionsListView, zip='22902'))
#         assert len(results) == 3
#         assert_dicts_subset(results[0], {'cycle': 2012, 'office': 'P', 'state': 'US', 'district': '00'})
#         assert_dicts_subset(results[1], {'cycle': 2012, 'office': 'S', 'state': 'VA', 'district': '00'})
#         assert_dicts_subset(results[2], {'cycle': 2012, 'office': 'H', 'state': 'VA', 'district': '05'})

#     def test_counts(self):
#         response = self._response(api.url_for(ElectionsListView))
#         footer_count = response['pagination']['count']
#         results_count = len(response['results'])
#         self.assertEqual(footer_count, results_count)

#     def test_search_sort_default(self):
#         results = self._results(api.url_for(ElectionsListView, state='VA'))
#         self.assertEqual(results[0]['office'], 'P')
#         self.assertEqual(results[1]['office'], 'S')
#         self.assertEqual(results[2]['district'], '04')
#         self.assertEqual(results[3]['district'], '05')
#         self.assertEqual(results[4]['district'], '06')

#     def test_search_sort_state(self):
#         results = self._results(api.url_for(ElectionsListView))
#         self.assertTrue(
#             [each['state'] for each in results],
#             ['GA', 'NJ', 'NJ', 'US', 'VA', 'VA', 'VA', 'VA']
#         )


# class TestElections(ApiBaseTest):

#     def setUp(self):
#         super().setUp()
#         self.candidate = factories.CandidateDetailFactory()
#         self.candidates = [
#             factories.CandidateHistoryFactory(
#                 candidate_id=self.candidate.candidate_id,
#                 state='NY',
#                 two_year_period=2012,
#                 election_years=[2010, 2012],
#                 cycles=[2010, 2012],
#                 office='S',
#                 candidate_election_year=2012,
#             ),
#             factories.CandidateHistoryFactory(
#                 candidate_id=self.candidate.candidate_id,
#                 state='NY',
#                 two_year_period=2010,
#                 election_years=[2010, 2012],
#                 cycles=[2010, 2012],
#                 office='S',
#                 candidate_election_year=2012,
#             ),
#         ]
#         self.committees = [
#             factories.CommitteeHistoryFactory(cycle=2012, designation='P'),
#             factories.CommitteeHistoryFactory(cycle=2012, designation='A'),
#         ]
#         [
#             factories.CandidateElectionFactory(candidate_id=self.candidate.candidate_id, cand_election_year=year)
#             for year in [2010, 2012]
#         ]
#         [
#             factories.CommitteeDetailFactory(committee_id=each.committee_id)
#             for each in self.committees
#         ]
#         db.session.flush()
#         factories.CandidateCommitteeLinkFactory(
#             candidate_id=self.candidate.candidate_id,
#             committee_id=self.committees[0].committee_id,
#             committee_designation='A',
#             fec_election_year=2012,
#         )
#         factories.CandidateCommitteeLinkFactory(
#             candidate_id=self.candidate.candidate_id,
#             committee_id=self.committees[1].committee_id,
#             committee_designation='P',
#             fec_election_year=2012,
#         )
#         factories.CandidateCommitteeLinkFactory(
#             candidate_id=self.candidate.candidate_id,
#             committee_id=self.committees[1].committee_id,
#             committee_designation='P',
#             fec_election_year=2010,
#         )
#         self.totals = [
#             factories.TotalsHouseSenateFactory(
#                 receipts=50,
#                 disbursements=75,
#                 committee_id=self.committees[0].committee_id,
#                 coverage_end_date=datetime.datetime(2012, 9, 30),
#                 last_cash_on_hand_end_period=1979,
#                 cycle=2012,
#             ),
#             factories.TotalsHouseSenateFactory(
#                 receipts=50,
#                 disbursements=75,
#                 committee_id=self.committees[1].committee_id,
#                 coverage_end_date=datetime.datetime(2012, 12, 31),
#                 last_cash_on_hand_end_period=1979,
#                 cycle=2012,
#             ),
#             factories.TotalsHouseSenateFactory(
#                 receipts=50,
#                 disbursements=75,
#                 committee_id=self.committees[1].committee_id,
#                 coverage_end_date=datetime.datetime(2012, 12, 31),
#                 last_cash_on_hand_end_period=1979,
#                 cycle=2010,
#             ),
#         ]

#     def test_missing_params(self):
#         response = self.app.get(api.url_for(ElectionView))
#         self.assertEquals(response.status_code, 422)

#     def test_conditional_missing_params(self):
#         response = self.app.get(api.url_for(ElectionView, office='president', cycle=2012))
#         self.assertEquals(response.status_code, 200)
#         response = self.app.get(api.url_for(ElectionView, office='senate', cycle=2012))
#         self.assertEquals(response.status_code, 422)
#         response = self.app.get(api.url_for(ElectionView, office='senate', cycle=2012, state='NY'))
#         self.assertEquals(response.status_code, 200)
#         response = self.app.get(api.url_for(ElectionView, office='house', cycle=2012, state='NY'))
#         self.assertEquals(response.status_code, 422)
#         response = self.app.get(api.url_for(ElectionView, office='house', cycle=2012, state='NY', district='01'))
#         self.assertEquals(response.status_code, 200)

#     def test_empty_query(self):
#         results = self._results(api.url_for(ElectionView, office='senate', cycle=2012, state='ZZ', per_page=0))
#         self.assertEqual(len(results), 0)

#     def test_elections(self):
#         results = self._results(api.url_for(ElectionView, office='senate', cycle=2012, state='NY'))
#         self.assertEqual(len(results), 1)
#         totals = [each for each in self.totals if each.cycle == 2012]
#         expected = {
#             'candidate_id': self.candidate.candidate_id,
#             'candidate_name': self.candidate.name,
#             'incumbent_challenge_full': self.candidate.incumbent_challenge_full,
#             'party_full': self.candidate.party_full,
#             'total_receipts': sum(each.receipts for each in totals),
#             'total_disbursements': sum(each.disbursements for each in totals),
#             'cash_on_hand_end_period': sum(each.last_cash_on_hand_end_period for each in totals),
#             'won': False,
#         }
#         assert_dicts_subset(results[0], expected)
#         assert set(each.committee_id for each in self.committees) == set(results[0]['committee_ids'])

#     def test_elections_full(self):
#         results = self._results(
#             api.url_for(
#                 ElectionView,
#                 office='senate', cycle=2012, state='NY', election_full='true',
#             )
#         )
#         totals = self.totals
#         last_totals = self.totals[:2]
#         expected = {
#             'candidate_id': self.candidate.candidate_id,
#             'candidate_name': self.candidate.name,
#             'incumbent_challenge_full': self.candidate.incumbent_challenge_full,
#             'party_full': self.candidate.party_full,
#             'total_receipts': sum(each.receipts for each in totals),
#             'total_disbursements': sum(each.disbursements for each in totals),
#             'cash_on_hand_end_period': sum(each.last_cash_on_hand_end_period for each in last_totals),
#             'won': False,
#         }
#         assert len(results) == 1
#         assert_dicts_subset(results[0], expected)
#         assert set(results[0]['committee_ids']) == set(each.committee_id for each in self.committees)

#     def test_elections_winner(self):
#         [
#             factories.ElectionResultFactory(
#                 cand_office='S',
#                 election_yr=2012,
#                 cand_office_st='NY',
#                 cand_id=self.candidate.candidate_id,
#                 cand_name=self.candidate.name,
#             )
#         ]
#         results = self._results(api.url_for(ElectionView, office='senate', cycle=2012, state='NY'))
#         self.assertEqual(len(results), 1)
#         expected = {
#             'candidate_id': self.candidate.candidate_id,
#             'candidate_name': self.candidate.name,
#             'won': True,
#         }
#         assert_dicts_subset(results[0], expected)

#     def test_election_summary(self):
#         results = self._response(api.url_for(ElectionSummary, office='senate', cycle=2012, state='NY'))
#         totals = [each for each in self.totals if each.cycle == 2012]
#         self.assertEqual(results['count'], 1)
#         self.assertEqual(results['receipts'], sum(each.receipts for each in totals))
#         self.assertEqual(results['disbursements'], sum(each.disbursements for each in totals))

class TestStateElectionOffices(ApiBaseTest):

    def test_fields(self):
        factories.StateElectionOfficesFactory()
        results = self._results(api.url_for(StateElectionOfficeInfoView))
        import pdb
        pdb.set_trace()
        assert len(results) == 1
        assert results[0].keys() == StateElectionOfficeInfoSchema().fields.keys()

    # def test_filters(self):
    #     filters = [
    #         ('state', StateElectionOfficeInfo.state, ['VA']),
    #         ('office_type', StateElectionOfficeInfo.office_type, ['STATE BALLOT ACCESS']),
    #         ('office_type', StateElectionOfficeInfo.office_type, ['STATE CAMPAIGN FINANCE']),
    #     ]
    #     for label, column, values in filters:
    #         [
    #             factories.StateElectionOfficesFactory(**{column.key: value})
    #             for value in values
    #         ]
    #         results = self._results(api.url_for(StateElectionOfficeInfoView, **{label: values[0]}))
    #         assert len(results) == 1
    #         assert results[0][column.key] == values[0]
