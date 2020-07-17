from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import db, api
from webservices.resources.spending_by_others import (
    ECTotalsByCandidateView,
    IETotalsByCandidateView,
    CCTotalsByCandidateView,
)
from webservices.resources.aggregates import (
    CCAggregatesView,
    CommunicationCostByCandidateView,
    ElectioneeringByCandidateView,
    ECAggregatesView,
)


# test /electioneering/by_candidate/ under tag: electioneering
class TestElectionerringByCandidate(ApiBaseTest):

    def test_sort_by_candidate_name_descending(self):

        factories.CandidateHistoryFactory(
            candidate_id='S001',
            name='WARNER, MARK',
            two_year_period=2010,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S002',
            name='BALDWIN, ALISSA',
            two_year_period=2010,
            office='S',
            state='NY',
        )

        factories.CandidateElectionFactory(
            candidate_id='S001',
            cand_election_year=2010)
        factories.CandidateElectionFactory(
            candidate_id='S002',
            cand_election_year=2010)

        factories.ElectioneeringByCandidateFactory(
            total=50000,
            count=10,
            cycle=2010,
            candidate_id='S001',
        ),
        factories.ElectioneeringByCandidateFactory(
            total=10000,
            count=5,
            cycle=2010,
            candidate_id='S002',
        ),

        response = self._results(api.url_for(ElectioneeringByCandidateView, cycle=2010,
            office='senate', state='NY', sort='-candidate_name'))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['candidate_name'], 'WARNER, MARK')
        self.assertEqual(response[1]['candidate_name'], 'BALDWIN, ALISSA')

    def test_sort_by_candidate_id(self):

        factories.CandidateHistoryFactory(
            candidate_id='S001',
            name='Robert Ritchie',
            two_year_period=2012,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S002',
            name='FARLEY Ritchie',
            two_year_period=2012,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S003',
            name='Robert Ritchie',
            election_years=[2012],
            two_year_period=2012,
            office='S',
            state='NY',
        )

        factories.CandidateElectionFactory(
            candidate_id='S001',
            cand_election_year=2012)
        factories.CandidateElectionFactory(
            candidate_id='S002',
            cand_election_year=2012)
        factories.CandidateElectionFactory(
            candidate_id='S003',
            cand_election_year=2012)

        factories.ElectioneeringByCandidateFactory(
            cycle=2012,
            candidate_id='S001',
            total=700,
            count=5,
        ),
        factories.ElectioneeringByCandidateFactory(
            cycle=2012,
            candidate_id='S002',
            total=500,
            count=3,
        ),
        factories.ElectioneeringByCandidateFactory(
            cycle=2012,
            candidate_id='S003',
            total=100,
            count=1,
        ),
        response = self._results(
            api.url_for(ElectioneeringByCandidateView, sort='-candidate_id',
                office='senate', state='NY', cycle=2012))
        self.assertEqual(len(response), 3)
        self.assertEqual(response[0]['candidate_id'], 'S003')
        self.assertEqual(response[1]['candidate_id'], 'S002')
        self.assertEqual(response[2]['candidate_id'], 'S001')


class TestTotalElectioneering(ApiBaseTest):
    """
    test endpoint: /electioneering/totals/by_candidate/ under tag:electioneering
    """
    def test_fields(self):

        factories.CandidateHistoryFactory(
            candidate_id='S01', two_year_period=2018, candidate_election_year=2024
        ),
        factories.CandidateHistoryFactory(
            candidate_id='S01', two_year_period=2020, candidate_election_year=2024
        ),

        factories.ElectioneeringByCandidateFactory(
            candidate_id='S01', total=300, cycle=2018, committee_id='C01'
        ),
        factories.ElectioneeringByCandidateFactory(
            candidate_id='S01', total=200, cycle=2020, committee_id='C02'
        ),

        results = self._results(
            api.url_for(
                ECTotalsByCandidateView, candidate_id='S01', election_full=False
            )
        )
        assert len(results) == 2

        results = self._results(
            api.url_for(ECTotalsByCandidateView, candidate_id='S01', election_full=True)
        )
        assert len(results) == 1
        assert results[0]['total'] == 500


# test endpoint: /electioneering/aggregates/ under tag:electioneering
class TestElectioneeringAggregates(ApiBaseTest):
    def test_ECAggregatesView_base(self):
        factories.ElectioneeringByCandidateFactory(),
        results = self._results(api.url_for(ECAggregatesView,))
        assert len(results) == 1

    def test_filters_committee_candidate_id_cycle(self):
        factories.ElectioneeringByCandidateFactory(
            committee_id='P001', candidate_id='C001', cycle=2000
        )
        factories.ElectioneeringByCandidateFactory(
            committee_id='P001', candidate_id='C002', cycle=2000
        )
        factories.ElectioneeringByCandidateFactory(
            committee_id='P002', candidate_id='C001', cycle=2004
        )
        db.session.flush()
        results = self._results(api.url_for(ECAggregatesView, committee_id='P001'))
        self.assertEqual(len(results), 2)

        results = self._results(api.url_for(ECAggregatesView, candidate_id='C001'))
        self.assertEqual(len(results), 2)

        results = self._results(api.url_for(ECAggregatesView, cycle=2000))
        self.assertEqual(len(results), 2)


# test endpoint: /schedules/schedule_e/totals/by_candidate/ under tag:independent expenditures
class TestTotalIndependentExpenditure(ApiBaseTest):
    def test_fields(self):

        factories.CandidateHistoryFactory(
            candidate_id='P01', two_year_period=2014, candidate_election_year=2016
        ),
        factories.CandidateHistoryFactory(
            candidate_id='P01', two_year_period=2016, candidate_election_year=2016
        ),

        factories.ScheduleEByCandidateFactory(
            candidate_id='P01',
            total=100,
            cycle=2012,
            committee_id='C01',
            support_oppose_indicator='S',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P01',
            total=200,
            cycle=2014,
            committee_id='C02',
            support_oppose_indicator='S',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P01',
            total=300,
            cycle=2014,
            committee_id='C02',
            support_oppose_indicator='O',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P01',
            total=400,
            cycle=2016,
            committee_id='C03',
            support_oppose_indicator='S',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P01',
            total=500,
            cycle=2016,
            committee_id='C03',
            support_oppose_indicator='O',
        ),

        results = self._results(
            api.url_for(
                IETotalsByCandidateView, candidate_id='P01', election_full=False
            )
        )
        assert len(results) == 4

        results = self._results(
            api.url_for(IETotalsByCandidateView, candidate_id='P01', election_full=True)
        )
        assert len(results) == 2
        assert results[0]['total'] == 800
        assert results[1]['total'] == 600


# test /communication_costs/by_candidate/total/ under tag: communication cost
class TestTotalCommunicationsCosts(ApiBaseTest):
    def test_fields(self):

        factories.CandidateHistoryFactory(
            candidate_id='P01', two_year_period=2014, candidate_election_year=2016
        ),
        factories.CandidateHistoryFactory(
            candidate_id='P01', two_year_period=2016, candidate_election_year=2016
        ),

        factories.CommunicationCostByCandidateFactory(
            candidate_id='P01',
            total=100,
            cycle=2012,
            committee_id='C01',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P01',
            total=200,
            cycle=2014,
            committee_id='C02',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P01',
            total=300,
            cycle=2014,
            committee_id='C02',
            support_oppose_indicator='O',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P01',
            total=400,
            cycle=2016,
            committee_id='C03',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P01',
            total=500,
            cycle=2016,
            committee_id='C03',
            support_oppose_indicator='O',
        ),

        results = self._results(
            api.url_for(
                CCTotalsByCandidateView,
                cycle='2016',
                candidate_id='P01',
                election_full=False,
            )
        )
        assert len(results) == 2

        results = self._results(
            api.url_for(
                CCTotalsByCandidateView,
                cycle='2016',
                candidate_id='P01',
                election_full=True,
            )
        )
        assert len(results) == 2
        assert results[0]['total'] == 800
        assert results[1]['total'] == 600


# test /communication_costs/by_candidate/ under tag: communication cost
class TestCommunicationsCostsByCandidate(ApiBaseTest):

    def test_sort_by_candidate_name_descending(self):

        factories.CandidateHistoryFactory(
            candidate_id='S001',
            name='WARNER, MARK',
            two_year_period=2010,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S002',
            name='BALDWIN, ALISSA',
            two_year_period=2010,
            office='S',
            state='NY',
        )

        factories.CandidateElectionFactory(
            candidate_id='S001',
            cand_election_year=2010)
        factories.CandidateElectionFactory(
            candidate_id='S002',
            cand_election_year=2010)

        factories.CommunicationCostByCandidateFactory(
            total=50000,
            count=10,
            cycle=2010,
            candidate_id='S001',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            total=10000,
            count=5,
            cycle=2010,
            candidate_id='S002',
            support_oppose_indicator='S',
        ),

        response = self._results(api.url_for(CommunicationCostByCandidateView, cycle=2010,
            office='senate', state='NY', sort='-candidate_name'))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['candidate_name'], 'WARNER, MARK')
        self.assertEqual(response[1]['candidate_name'], 'BALDWIN, ALISSA')

    def test_sort_by_candidate_id(self):

        factories.CandidateHistoryFactory(
            candidate_id='S001',
            name='Robert Ritchie',
            two_year_period=2012,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S002',
            name='FARLEY Ritchie',
            two_year_period=2012,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S003',
            name='Robert Ritchie',
            election_years=[2012],
            two_year_period=2012,
            office='S',
            state='NY',
        )

        factories.CandidateElectionFactory(
            candidate_id='S001',
            cand_election_year=2012)
        factories.CandidateElectionFactory(
            candidate_id='S002',
            cand_election_year=2012)
        factories.CandidateElectionFactory(
            candidate_id='S003',
            cand_election_year=2012)

        factories.CommunicationCostByCandidateFactory(
            cycle=2012,
            candidate_id='S001',
            support_oppose_indicator='O',
            total=700,
            count=5,
        ),
        factories.CommunicationCostByCandidateFactory(
            cycle=2012,
            candidate_id='S002',
            support_oppose_indicator='O',
            total=500,
            count=3,
        ),
        factories.CommunicationCostByCandidateFactory(
            cycle=2012,
            candidate_id='S003',
            support_oppose_indicator='S',
            total=100,
            count=1,
        ),
        response = self._results(
            api.url_for(CommunicationCostByCandidateView, sort='-candidate_id',
                office='senate', state='NY', cycle=2012))
        self.assertEqual(len(response), 3)
        self.assertEqual(response[0]['candidate_id'], 'S003')
        self.assertEqual(response[0]['support_oppose_indicator'], 'S')
        self.assertEqual(response[1]['candidate_id'], 'S002')
        self.assertEqual(response[1]['support_oppose_indicator'], 'O')
        self.assertEqual(response[2]['candidate_id'], 'S001')
        self.assertEqual(response[2]['support_oppose_indicator'], 'O')


# test endpoint: /communication_costs/aggregates/ under tag:communication costs
class TestCommunicationCostAggregates(ApiBaseTest):
    def test_CCAggregatesView_base(self):
        factories.CommunicationCostByCandidateFactory(),
        results = self._results(api.url_for(CCAggregatesView,))
        assert len(results) == 1

    def test_filters_committee_candidate_id_cycle(self):
        factories.CommunicationCostByCandidateFactory(
            committee_id='P001', candidate_id='C001', cycle=2000
        )
        factories.CommunicationCostByCandidateFactory(
            committee_id='P001', candidate_id='C002', cycle=2000
        )
        factories.CommunicationCostByCandidateFactory(
            committee_id='P002', candidate_id='C001', cycle=2004
        )
        db.session.flush()
        results = self._results(api.url_for(CCAggregatesView, committee_id='P001'))
        self.assertEqual(len(results), 2)

        results = self._results(api.url_for(CCAggregatesView, candidate_id='C001'))
        self.assertEqual(len(results), 2)

        results = self._results(api.url_for(CCAggregatesView, cycle=2000))
        self.assertEqual(len(results), 2)
