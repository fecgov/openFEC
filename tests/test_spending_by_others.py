from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.resources.spending_by_others import ECTotalsByCandidateView


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
