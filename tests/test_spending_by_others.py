from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import db, api
from webservices.resources.spending_by_others import (
    ECTotalsByCandidateView,
)
from webservices.resources.aggregates import (
    ECAggregatesView,
)
from webservices.schemas import (
    ECAggregatesSchema,
)

# test endpoint: /electioneering/totals/by_candidate/ under tag:electioneering
class TestTotalElectioneering(ApiBaseTest):

    def test_fields(self):

        factories.CandidateHistoryFactory(
            candidate_id='S01',
            two_year_period=2018,
            candidate_election_year=2024
        ),
        factories.CandidateHistoryFactory(
            candidate_id='S01',
            two_year_period=2020,
            candidate_election_year=2024
        ),

        factories.ElectioneeringByCandidateFactory(
            candidate_id='S01',
            total=300,
            cycle=2018,
            committee_id='C01'
        ),
        factories.ElectioneeringByCandidateFactory(
            candidate_id='S01',
            total=200,
            cycle=2020,
            committee_id='C02'
        ),

        results = self._results(api.url_for(ECTotalsByCandidateView, candidate_id='S01', election_full=False))
        assert len(results) == 2

        results = self._results(api.url_for(ECTotalsByCandidateView, candidate_id='S01', election_full=True))
        assert len(results) == 1
        assert results[0]['total'] == 500


# test endpoint: /electioneering/aggregates/ under tag:electioneering
class TestElectioneeringAggregates(ApiBaseTest):
    def test_ECAggregatesView_base(self):
        factories.ElectioneeringByCandidateFactory(),
        results = self._results(api.url_for(ECAggregatesView,))
        assert len(results) == 1

    def test_filters_committee_candidate_id_cycle(self):
        factories.ElectioneeringByCandidateFactory(committee_id='P001', candidate_id='C001', cycle=2000)
        factories.ElectioneeringByCandidateFactory(committee_id='P001', candidate_id='C002', cycle=2000)
        factories.ElectioneeringByCandidateFactory(committee_id='P002', candidate_id='C001', cycle=2004)
        db.session.flush()
        results = self._results(api.url_for(ECAggregatesView, committee_id='P001'))
        self.assertEqual(len(results), 2)

        results = self._results(api.url_for(ECAggregatesView, candidate_id='C001'))
        self.assertEqual(len(results), 2)

        results = self._results(api.url_for(ECAggregatesView, cycle=2000))
        self.assertEqual(len(results), 2)
