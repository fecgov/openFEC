
from tests import factories
from tests.common import ApiBaseTest
from webservices.api_setup import api
from webservices.schemas import ScheduleEByCandidateSchema
from webservices.resources.aggregates import ScheduleEByCandidateView


# test /schedules/schedule_e/by_candidate/ under tag: independent expenditures
class TestScheduleEByCandidateView(ApiBaseTest):
    def test_fields(self):
        candidate_id = 'S00000001'
        support_oppose_indicator = 'S'
        factories.ScheduleEByCandidateFactory(
            candidate_id=candidate_id,
            support_oppose_indicator=support_oppose_indicator,
            cycle=2018)
        factories.CandidateElectionFactory(candidate_id=candidate_id,
                                           cand_election_year=2018)
        results = self._results(api.url_for(ScheduleEByCandidateView,
                                            candidate_id='S00000001'))
        assert len(results) == 1
        assert results[0].keys() == ScheduleEByCandidateSchema().fields.keys()

    def test_sched_e_filter_match(self):
        factories.CandidateElectionFactory(candidate_id='S00000002',
                                           cand_election_year=2014)
        factories.ScheduleEByCandidateFactory(
            total=50000,
            count=10,
            cycle=2008,
            candidate_id='S00000001',
            support_oppose_indicator='O',
        ),
        factories.ScheduleEByCandidateFactory(
            total=10000,
            count=5,
            cycle=2010,
            candidate_id='S00000002',
            support_oppose_indicator='S',
        ),

        results = self._results(
            api.url_for(ScheduleEByCandidateView, candidate_id='S00000002',
                        cycle=2014, support_oppose='S')
        )
        self.assertEqual(len(results), 1)

    def test_sort_bad_column(self):
        response = self.app.get(api.url_for(ScheduleEByCandidateView,
                                            sort='candidate'))
        self.assertEqual(response.status_code, 422)
        self.assertIn(b'Cannot sort on value', response.data)

    def test_sort_by_candidate_id(self):

        factories.CandidateHistoryFactory(
            candidate_id='S00000001',
            name='Robert Ritchie',
            two_year_period=2012,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S00000002',
            name='FARLEY Ritchie',
            two_year_period=2012,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S00000003',
            name='Robert Ritchie',
            election_years=[2012],
            two_year_period=2012,
            office='S',
            state='NY',
        )

        factories.CandidateElectionFactory(
            candidate_id='S00000001',
            cand_election_year=2012)
        factories.CandidateElectionFactory(
            candidate_id='S00000002',
            cand_election_year=2012)
        factories.CandidateElectionFactory(
            candidate_id='S00000003',
            cand_election_year=2012)

        factories.ScheduleEByCandidateFactory(
            cycle=2012,
            candidate_id='S00000001',
            support_oppose_indicator='O',
            total=700,
            count=5,
        ),
        factories.ScheduleEByCandidateFactory(
            cycle=2012,
            candidate_id='S00000002',
            support_oppose_indicator='O',
            total=500,
            count=3,
        ),
        factories.ScheduleEByCandidateFactory(
            cycle=2012,
            candidate_id='S00000003',
            support_oppose_indicator='S',
            total=100,
            count=1,
        ),
        response = self._results(
            api.url_for(ScheduleEByCandidateView, sort='-candidate_id',
                        office='senate', state='NY', cycle=2012))
        self.assertEqual(len(response), 3)
        self.assertEqual(response[0]['candidate_id'], 'S00000003')
        self.assertEqual(response[0]['support_oppose_indicator'], 'S')
        self.assertEqual(response[1]['candidate_id'], 'S00000002')
        self.assertEqual(response[1]['support_oppose_indicator'], 'O')
        self.assertEqual(response[2]['candidate_id'], 'S00000001')
        self.assertEqual(response[2]['support_oppose_indicator'], 'O')

    def test_sort_by_candidate_name_descending(self):

        factories.CandidateHistoryFactory(
            candidate_id='S00000005',
            name='WARNER, MARK',
            two_year_period=2010,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S00000006',
            name='BALDWIN, ALISSA',
            two_year_period=2010,
            office='S',
            state='NY',
        )

        factories.CandidateElectionFactory(
            candidate_id='S00000005',
            cand_election_year=2010)
        factories.CandidateElectionFactory(
            candidate_id='S00000006',
            cand_election_year=2010)

        factories.ScheduleEByCandidateFactory(
            total=50000,
            count=10,
            cycle=2010,
            candidate_id='S00000005',
            support_oppose_indicator='S',
        ),
        factories.ScheduleEByCandidateFactory(
            total=10000,
            count=5,
            cycle=2010,
            candidate_id='S00000006',
            support_oppose_indicator='S',
        ),

        response = self._results(api.url_for(ScheduleEByCandidateView,
                                             cycle=2010,
                                             office='senate',
                                             state='NY',
                                             sort='-candidate_name'))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['candidate_name'], 'WARNER, MARK')
        self.assertEqual(response[1]['candidate_name'], 'BALDWIN, ALISSA')

    def test_sort_by_committee_id(self):

        factories.CommitteeHistoryFactory(
            name='Warner for America', cycle=2010,
            committee_id='C00000005'
        )
        factories.CommitteeHistoryFactory(
            name='Ritche for America', cycle=2010,
            committee_id='C00000006'
        )

        factories.CandidateHistoryFactory(
            candidate_id='S00000005',
            name='WARNER, MARK',
            election_years=[2010],
            two_year_period=2010,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S00000006',
            name='BALDWIN, ALISSA',
            election_years=[2010],
            two_year_period=2010,
            office='S',
            state='NY',
        )

        factories.CandidateElectionFactory(
            candidate_id='S00000005',
            cand_election_year=2010)
        factories.CandidateElectionFactory(
            candidate_id='S00000006',
            cand_election_year=2010)

        factories.ScheduleEByCandidateFactory(
            total=50000,
            count=10,
            cycle=2010,
            candidate_id='S00000005',
            support_oppose_indicator='S',
            committee_id='C00000005',
        ),
        factories.ScheduleEByCandidateFactory(
            total=10000,
            count=5,
            cycle=2010,
            candidate_id='S00000005',
            support_oppose_indicator='S',
            committee_id='C00000006',
        ),

        response = self._results(api.url_for(ScheduleEByCandidateView,
                                             sort='-committee_id',
                                             office='senate',
                                             cycle=2010,
                                             state='NY'))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['committee_id'], 'C00000006')
        self.assertEqual(response[1]['committee_id'], 'C00000005')

    def test_sort_by_committee_name(self):

        factories.CommitteeHistoryFactory(
            name='Warner for America', cycle=2010,
            committee_id='C00000005'
        )
        factories.CommitteeHistoryFactory(
            name='Ritche for America', cycle=2010,
            committee_id='C00000006'
        )

        factories.CandidateHistoryFactory(
            candidate_id='S00000005',
            name='WARNER, MARK',
            election_years=[2010],
            two_year_period=2010,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S00000006',
            name='BALDWIN, ALISSA',
            election_years=[2010],
            two_year_period=2010,
            office='S',
            state='NY',
        )

        factories.CandidateElectionFactory(
            candidate_id='S00000005',
            cand_election_year=2010)
        factories.CandidateElectionFactory(
            candidate_id='S00000006',
            cand_election_year=2010)

        factories.ScheduleEByCandidateFactory(
            total=50000,
            count=10,
            cycle=2010,
            candidate_id='S00000005',
            support_oppose_indicator='S',
            committee_id='C00000005',
        ),
        factories.ScheduleEByCandidateFactory(
            total=10000,
            count=5,
            cycle=2010,
            candidate_id='S00000005',
            support_oppose_indicator='S',
            committee_id='C00000006',
        ),

        response = self._results(api.url_for(ScheduleEByCandidateView,
                                             sort='-committee_name',
                                             office='senate',
                                             cycle=2010,
                                             state='NY'))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['committee_name'], 'Warner for America')
        self.assertEqual(response[1]['committee_name'], 'Ritche for America')
