from webservices.rest import db, api
from webservices.resources.candidate_aggregates import (
    ScheduleABySizeCandidateView,
    ScheduleAByStateCandidateView,
)

from tests import factories
from tests.common import ApiBaseTest


class TestCandidateAggregates(ApiBaseTest):

    def setUp(self):
        super().setUp()
        self.candidate = factories.CandidateHistoryFactory(two_year_period=2012)
        self.committees = [
            factories.CommitteeHistoryFactory(cycle=2012, designation='P'),
            factories.CommitteeHistoryFactory(cycle=2012, designation='A'),
        ]
        factories.CandidateDetailFactory(candidate_key=self.candidate.candidate_key)
        [
            factories.CommitteeDetailFactory(committee_key=each.committee_key)
            for each in self.committees
        ]
        db.session.flush()
        factories.CandidateCommitteeLinkFactory(
            candidate_key=self.candidate.candidate_key,
            committee_key=self.committees[0].committee_key,
        )
        factories.CandidateCommitteeLinkFactory(
            candidate_key=self.candidate.candidate_key,
            committee_key=self.committees[1].committee_key,
        )

    def test_by_size(self):
        [
            factories.ScheduleABySizeFactory(
                committee_id=self.committees[0].committee_id,
                cycle=2012,
                total=50,
                size=200,
            ),
            factories.ScheduleABySizeFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2012,
                total=150,
                size=200,
            ),
        ]
        results = self._results(
            api.url_for(
                ScheduleABySizeCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
            )
        )
        self.assertEqual(len(results), 1)
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'cycle': 2012,
            'total': 200,
            'size': 200,
        }
        self.assertEqual(results[0], expected)

    def test_by_state(self):
        [
            factories.ScheduleAByStateFactory(
                committee_id=self.committees[0].committee_id,
                cycle=2012,
                total=50,
                state='NY',
                state_full='New York',
            ),
            factories.ScheduleAByStateFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2012,
                total=150,
                state='NY',
                state_full='New York',
            ),
        ]
        results = self._results(
            api.url_for(
                ScheduleAByStateCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
            )
        )
        self.assertEqual(len(results), 1)
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'cycle': 2012,
            'total': 200,
            'state': 'NY',
            'state_full': 'New York',
        }
        self.assertEqual(results[0], expected)
