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
    ECAggregatesView,
)


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
