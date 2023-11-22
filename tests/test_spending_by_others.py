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


# Test '/electioneering/by_candidate/' (aggregates.ElectioneeringByCandidateView)under tag: electioneering
class TestElectioneeringByCandidateView(ApiBaseTest):

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

        response = self._results(api.url_for(
            ElectioneeringByCandidateView,
            cycle=2010,
            office='senate',
            state='NY',
            sort='-candidate_name'))
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
            api.url_for(
                ElectioneeringByCandidateView,
                sort='-candidate_id',
                office='senate',
                state='NY',
                cycle=2012))
        self.assertEqual(len(response), 3)
        self.assertEqual(response[0]['candidate_id'], 'S003')
        self.assertEqual(response[1]['candidate_id'], 'S002')
        self.assertEqual(response[2]['candidate_id'], 'S001')


# Test endpoint: '/electioneering/aggregates/' (aggregates.ECAggregatesView) under tag:electioneering
class TestECAggregatesView(ApiBaseTest):
    def test_ECAggregatesView_base(self):
        factories.ElectioneeringByCandidateFactory(),
        results = self._results(api.url_for(ECAggregatesView,))
        assert len(results) == 1

    def test_filters_committee_candidate_id_cycle(self):
        factories.ElectioneeringByCandidateFactory(
            committee_id='C00000001', candidate_id='P00000001', cycle=2000
        )
        factories.ElectioneeringByCandidateFactory(
            committee_id='C00000001', candidate_id='P00000002', cycle=2000
        )
        factories.ElectioneeringByCandidateFactory(
            committee_id='C00000002', candidate_id='P00000001', cycle=2004
        )
        db.session.flush()
        results = self._results(api.url_for(ECAggregatesView, committee_id='C00000001'))
        self.assertEqual(len(results), 2)

        results = self._results(api.url_for(ECAggregatesView, candidate_id='P00000001'))
        self.assertEqual(len(results), 2)

        results = self._results(api.url_for(ECAggregatesView, cycle=2000))
        self.assertEqual(len(results), 2)


# Test '/electioneering/totals/by_candidate/' (spending_by_others.ECTotalsByCandidateView)under tag: electioneering
class TestECTotalsByCandidateView(ApiBaseTest):

    def test_fields(self):

        factories.CandidateHistoryFactory(
            candidate_id='S00000001', two_year_period=2018, candidate_election_year=2024
        ),
        factories.CandidateHistoryFactory(
            candidate_id='S00000001', two_year_period=2020, candidate_election_year=2024
        ),

        factories.ElectioneeringByCandidateFactory(
            candidate_id='S00000001', total=300, cycle=2018, committee_id='C00000001'
        ),
        factories.ElectioneeringByCandidateFactory(
            candidate_id='S00000001', total=200, cycle=2020, committee_id='C00000002'
        ),

        results = self._results(
            api.url_for(
                ECTotalsByCandidateView, candidate_id='S00000001', election_full=False
            )
        )
        assert len(results) == 2

        results = self._results(
            api.url_for(ECTotalsByCandidateView, candidate_id='S00000001', election_full=True)
        )
        assert len(results) == 1
        assert results[0]['total'] == 500

    def test_sort_validation(self):
        # sort_option = ['cycle','candidate_id','total'], sort value must be one of sort_option.
        factories.CandidateHistoryFactory(
            candidate_id='S00000001', two_year_period=2018, candidate_election_year=2024
        ),
        factories.CandidateHistoryFactory(
            candidate_id='S00000001', two_year_period=2020, candidate_election_year=2024
        ),

        factories.ElectioneeringByCandidateFactory(
            committee_id='C00000001', candidate_id='P00000001', cycle=2000
        )
        factories.ElectioneeringByCandidateFactory(
            committee_id='C00000001', candidate_id='P00000002', cycle=2000
        )
        factories.ElectioneeringByCandidateFactory(
            committee_id='C00000002', candidate_id='P00000001', cycle=2004
        )
        db.session.flush()
        results = self._results(api.url_for(ECAggregatesView, committee_id='C00000001'))
        self.assertEqual(len(results), 2)

        results = self._results(api.url_for(ECAggregatesView, candidate_id='P00000001'))
        self.assertEqual(len(results), 2)

        results = self._results(api.url_for(ECAggregatesView, cycle=2000))
        self.assertEqual(len(results), 2)


# Test endpoint: '/schedules/schedule_e/totals/by_candidate/' (spending_by_others.IETotalsByCandidateView)
# under tag:independent expenditures
class TestIETotalsByCandidateView(ApiBaseTest):
    def test_fields(self):

        factories.CandidateHistoryFactory(
            candidate_id='P00000001', two_year_period=2014, candidate_election_year=2016
        ),
        factories.CandidateHistoryFactory(
            candidate_id='P00000001', two_year_period=2016, candidate_election_year=2016
        ),

        factories.ScheduleEByCandidateFactory(
            candidate_id='P00000001',
            total=100,
            cycle=2012,
            committee_id='C00000001',
            support_oppose_indicator='S',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P00000001',
            total=200,
            cycle=2014,
            committee_id='C00000002',
            support_oppose_indicator='S',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P00000001',
            total=300,
            cycle=2014,
            committee_id='C00000002',
            support_oppose_indicator='O',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P00000001',
            total=400,
            cycle=2016,
            committee_id='C00000003',
            support_oppose_indicator='S',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P00000001',
            total=500,
            cycle=2016,
            committee_id='C00000003',
            support_oppose_indicator='O',
        ),

        results = self._results(
            api.url_for(
                IETotalsByCandidateView, candidate_id='P00000001', election_full=False
            )
        )
        assert len(results) == 4

        results = self._results(
            api.url_for(IETotalsByCandidateView, candidate_id='P00000001', election_full=True)
        )
        assert len(results) == 2
        assert results[0]['total'] == 800
        assert results[1]['total'] == 600

    def test_sort_validation(self):
        # sort_option = ['cycle','candidate_id','total','support_oppose_indicator'],
        # sort value must be one of sort_option.
        factories.CandidateHistoryFactory(
            candidate_id='P00000001', two_year_period=2014, candidate_election_year=2016
        ),
        factories.CandidateHistoryFactory(
            candidate_id='P00000001', two_year_period=2016, candidate_election_year=2016
        ),

        factories.ScheduleEByCandidateFactory(
            candidate_id='P00000001',
            total=100,
            cycle=2012,
            committee_id='C00000001',
            support_oppose_indicator='S',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P00000001',
            total=200,
            cycle=2014,
            committee_id='C00000002',
            support_oppose_indicator='S',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P00000001',
            total=300,
            cycle=2014,
            committee_id='C00000002',
            support_oppose_indicator='O',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P00000001',
            total=400,
            cycle=2016,
            committee_id='C00000003',
            support_oppose_indicator='S',
        ),
        factories.ScheduleEByCandidateFactory(
            candidate_id='P00000001',
            total=500,
            cycle=2016,
            committee_id='C00000003',
            support_oppose_indicator='O',
        ),

        results = self.app.get(
            api.url_for(
                IETotalsByCandidateView,
                sort='bad_value',
            )
        )
        self.assertEqual(results.status_code, 422)

        results = self._results(
            api.url_for(
                IETotalsByCandidateView,
                candidate_id='P00000001',
                sort='cycle',
            )
        )
        assert len(results) == 2
        expected = {
            'candidate_id': 'P00000001',
            'cycle': 2016,
            'total': 800,
            'support_oppose_indicator': 'O'
        }
        assert results[0] == expected


# Test '/communication_costs/totals/by_candidate/' (spending_by_others.CCTotalsByCandidateView)
# under tag: communication cost
class TestCCTotalsByCandidateView(ApiBaseTest):
    def test_fields(self):

        factories.CandidateHistoryFactory(
            candidate_id='P00000001', two_year_period=2014, candidate_election_year=2016
        ),
        factories.CandidateHistoryFactory(
            candidate_id='P00000001', two_year_period=2016, candidate_election_year=2016
        ),

        factories.CommunicationCostByCandidateFactory(
            candidate_id='P00000001',
            total=100,
            cycle=2012,
            committee_id='C00000001',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P00000001',
            total=200,
            cycle=2014,
            committee_id='C00000002',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P00000001',
            total=300,
            cycle=2014,
            committee_id='C00000002',
            support_oppose_indicator='O',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P00000001',
            total=400,
            cycle=2016,
            committee_id='C00000003',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P00000001',
            total=500,
            cycle=2016,
            committee_id='C00000003',
            support_oppose_indicator='O',
        ),

        results = self._results(
            api.url_for(
                CCTotalsByCandidateView,
                cycle='2016',
                candidate_id='P00000001',
                election_full=False,
            )
        )
        assert len(results) == 2

        results = self._results(
            api.url_for(
                CCTotalsByCandidateView,
                cycle='2016',
                candidate_id='P00000001',
                election_full=True,
            )
        )
        assert len(results) == 2
        assert results[0]['total'] == 800
        assert results[1]['total'] == 600

    def test_sort_validation(self):

        factories.CandidateHistoryFactory(
            candidate_id='P00000001', two_year_period=2014, candidate_election_year=2016
        ),
        factories.CandidateHistoryFactory(
            candidate_id='P00000001', two_year_period=2016, candidate_election_year=2016
        ),

        factories.CommunicationCostByCandidateFactory(
            candidate_id='P00000001',
            total=100,
            cycle=2012,
            committee_id='C00000001',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P00000001',
            total=200,
            cycle=2014,
            committee_id='C00000002',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P00000001',
            total=300,
            cycle=2014,
            committee_id='C00000002',
            support_oppose_indicator='O',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P00000001',
            total=400,
            cycle=2016,
            committee_id='C00000003',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            candidate_id='P00000001',
            total=500,
            cycle=2016,
            committee_id='C00000003',
            support_oppose_indicator='O',
        ),

        results = self.app.get(
            api.url_for(
                CCTotalsByCandidateView,
                sort='bad_value',
            )
        )
        self.assertEqual(results.status_code, 422)

        results = self._results(
            api.url_for(
                CCTotalsByCandidateView,
                cycle='2016',
                candidate_id='P00000001',
                election_full=True,
            )
        )
        assert len(results) == 2
        expected = {
            'candidate_id': 'P00000001',
            'cycle': 2016,
            'total': 800,
            'support_oppose_indicator': 'O'
        }
        assert results[0] == expected


# Test '/communication_costs/by_candidate/' (aggregates.CommunicationCostByCandidateView)
# under tag: communication cost
class TestCommunicationCostByCandidateView(ApiBaseTest):

    def test_sort_by_candidate_name_descending(self):

        factories.CandidateHistoryFactory(
            candidate_id='S00000001',
            name='WARNER, MARK',
            two_year_period=2010,
            office='S',
            state='NY',
        )
        factories.CandidateHistoryFactory(
            candidate_id='S00000002',
            name='BALDWIN, ALISSA',
            two_year_period=2010,
            office='S',
            state='NY',
        )

        factories.CandidateElectionFactory(
            candidate_id='S00000001',
            cand_election_year=2010)
        factories.CandidateElectionFactory(
            candidate_id='S00000002',
            cand_election_year=2010)

        factories.CommunicationCostByCandidateFactory(
            total=50000,
            count=10,
            cycle=2010,
            candidate_id='S00000001',
            support_oppose_indicator='S',
        ),
        factories.CommunicationCostByCandidateFactory(
            total=10000,
            count=5,
            cycle=2010,
            candidate_id='S00000002',
            support_oppose_indicator='S',
        ),

        response = self._results(api.url_for(
            CommunicationCostByCandidateView,
            cycle=2010,
            office='senate',
            state='NY',
            sort='-candidate_name'))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['candidate_name'], 'WARNER, MARK')
        self.assertEqual(response[1]['candidate_name'], 'BALDWIN, ALISSA')

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

        factories.CommunicationCostByCandidateFactory(
            cycle=2012,
            candidate_id='S00000001',
            support_oppose_indicator='O',
            total=700,
            count=5,
        ),
        factories.CommunicationCostByCandidateFactory(
            cycle=2012,
            candidate_id='S00000002',
            support_oppose_indicator='O',
            total=500,
            count=3,
        ),
        factories.CommunicationCostByCandidateFactory(
            cycle=2012,
            candidate_id='S00000003',
            support_oppose_indicator='S',
            total=100,
            count=1,
        ),
        response = self._results(
            api.url_for(
                CommunicationCostByCandidateView,
                sort='-candidate_id',
                office='senate',
                state='NY',
                cycle=2012))
        self.assertEqual(len(response), 3)
        self.assertEqual(response[0]['candidate_id'], 'S00000003')
        self.assertEqual(response[0]['support_oppose_indicator'], 'S')
        self.assertEqual(response[1]['candidate_id'], 'S00000002')
        self.assertEqual(response[1]['support_oppose_indicator'], 'O')
        self.assertEqual(response[2]['candidate_id'], 'S00000001')
        self.assertEqual(response[2]['support_oppose_indicator'], 'O')


# Test endpoint: '/communication_costs/aggregates/' (aggregates.CCAggregatesView)under tag:communication costs
class TestCCAggregatesView(ApiBaseTest):
    def test_CCAggregatesView_base(self):
        factories.CommunicationCostByCandidateFactory(),
        results = self._results(api.url_for(CCAggregatesView,))
        assert len(results) == 1

    def test_filters_committee_candidate_id_cycle(self):
        factories.CandidateHistoryFactory(
            candidate_id='P00000001', two_year_period=2000, candidate_election_year=2000, name='Apple Smith'
        ),
        factories.CandidateHistoryFactory(
            candidate_id='P00000002', two_year_period=2000, candidate_election_year=2000, name='Snapple Smith'
        ),
        factories.CandidateHistoryFactory(
            candidate_id='P00000002', two_year_period=2004, candidate_election_year=2004, name='Zapple Smith'
        ),

        factories.CommitteeHistoryFactory(
            committee_id='C00000001', cycle=2000, name='Acme Co'
        ),
        factories.CommitteeHistoryFactory(
            committee_id='C00000002', cycle=2000, name='Tetris Corp'
        ),
        factories.CommitteeHistoryFactory(
            committee_id='C00000002', cycle=2004, name='Winner PAC'
        ),

        factories.CommunicationCostByCandidateFactory(
            committee_id='C00000001', candidate_id='P00000001', cycle=2000
        )
        factories.CommunicationCostByCandidateFactory(
            committee_id='C00000001', candidate_id='P00000002', cycle=2000
        )
        factories.CommunicationCostByCandidateFactory(
            committee_id='C00000002', candidate_id='P00000001', cycle=2004
        )
        db.session.flush()

        # assert results filtered by committee_id sorted by candidate name in descending order
        results = self._results(api.url_for(CCAggregatesView, committee_id='C00000001', sort='-candidate_name'))
        self.assertEqual(len(results), 2)
        self.assertEqual(results[0]['candidate_name'], 'Snapple Smith')
        self.assertEqual(results[1]['candidate_name'], 'Apple Smith')

        # assert results filtered by committee_id sorted by candidate name in ascending order
        results = self._results(api.url_for(CCAggregatesView, committee_id='C00000001', sort='candidate_name'))
        self.assertEqual(len(results), 2)
        self.assertEqual(results[0]['candidate_name'], 'Apple Smith')
        self.assertEqual(results[1]['candidate_name'], 'Snapple Smith')

        # assert results filtered by candidate_id sorted by committee name in descending order
        results = self._results(api.url_for(CCAggregatesView, candidate_id='P00000001', sort='-committee_name'))
        self.assertEqual(len(results), 2)
        self.assertEqual(results[0]['committee_name'], 'Winner PAC')
        self.assertEqual(results[1]['committee_name'], 'Acme Co')

        # assert results filtered by candidate_id sorted by committee name in ascending order
        results = self._results(api.url_for(CCAggregatesView, candidate_id='P00000001', sort='committee_name'))
        self.assertEqual(len(results), 2)
        self.assertEqual(results[0]['committee_name'], 'Acme Co')
        self.assertEqual(results[1]['committee_name'], 'Winner PAC')

        # assert results filtered by cycle sorted by committee name in ascending order
        results = self._results(api.url_for(CCAggregatesView, cycle=2000, sort='committee_name'))
        self.assertEqual(len(results), 2)
        self.assertEqual(results[0]['committee_name'], 'Acme Co')
        self.assertEqual(results[1]['committee_name'], 'Acme Co')
