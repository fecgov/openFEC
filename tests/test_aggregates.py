from webservices.rest import db, api
from webservices.resources.aggregates import (
    ScheduleBByPurposeView,
    ScheduleEByCandidateView,
    CommunicationCostByCandidateView,
)
from webservices.resources.candidate_aggregates import (
    ScheduleABySizeCandidateView,
    ScheduleAByStateCandidateView,
    ScheduleAByContributorTypeCandidateView,
)

from tests import factories
from tests.common import ApiBaseTest


class TestAggregates(ApiBaseTest):

    def setUp(self):
        super(TestAggregates, self).setUp()
        self.committee = factories.CommitteeHistoryFactory(cycle=2012)

    def test_disbursement_purpose(self):
        aggregate = factories.ScheduleBByPurposeFactory(
            committee_id=self.committee.committee_id,
            cycle=self.committee.cycle,
        )
        results = self._results(
            api.url_for(
                ScheduleBByPurposeView,
                committee_id=self.committee.committee_id,
                cycle=2012,
            )
        )
        self.assertEqual(len(results), 1)
        expected = {
            'committee_id': self.committee.committee_id,
            'purpose': 'ADMINISTRATIVE',
            'cycle': 2012,
            'total': aggregate.total,
            'count': aggregate.count,
        }
        self.assertEqual(results[0], expected)

    def test_independent_expenditure_candidate(self):
        aggregate = factories.ScheduleEByCandidateFactory(
            committee_id=self.committee.committee_id,
            cycle=self.committee.cycle,
        )
        results = self._results(
            api.url_for(
                ScheduleEByCandidateView,
                committee_id=self.committee.committee_id,
                cycle=2012,
            )
        )
        self.assertEqual(len(results), 1)
        expected = {
            'committee_id': self.committee.committee_id,
            'candidate_id': aggregate.candidate_id,
            'support_oppose_indicator': aggregate.support_oppose_indicator,
            'cycle': aggregate.cycle,
            'total': aggregate.total,
            'count': aggregate.count,
        }
        for key, value in expected.items():
            self.assertEqual(results[0][key], value)

    def test_communication_cost(self):
        aggregate = factories.CommunicationCostByCandidateFactory(
            committee_id=self.committee.committee_id,
            cycle=self.committee.cycle,
        )
        results = self._results(
            api.url_for(
                CommunicationCostByCandidateView,
                committee_id=self.committee.committee_id,
                cycle=2012,
            )
        )
        self.assertEqual(len(results), 1)
        expected = {
            'committee_id': self.committee.committee_id,
            'candidate_id': aggregate.candidate_id,
            'support_oppose_indicator': aggregate.support_oppose_indicator,
            'cycle': aggregate.cycle,
            'total': aggregate.total,
            'count': aggregate.count,
        }
        for key, value in expected.items():
            self.assertEqual(results[0][key], value)

    def test_communication_cost_by_election(self):
        candidate = factories.CandidateHistoryFactory(
            two_year_period=2012,
            election_years=[2012],
            office='P',
        )
        [
            factories.CommunicationCostByCandidateFactory(
                committee_id=self.committee.committee_id,
                candidate_id=candidate.candidate_id,
                cycle=self.committee.cycle,
            ),
            factories.CommunicationCostByCandidateFactory(
                cycle=self.committee.cycle,
            ),
        ]
        results = self._results(
            api.url_for(
                CommunicationCostByCandidateView,
                office='president',
                cycle=2012,
            )
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['candidate']['candidate_id'], candidate.candidate_id)


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

    def test_by_contributor_type(self):
        [
            factories.ScheduleAByContributorTypeFactory(
                committee_id=self.committees[0].committee_id,
                cycle=2012,
                total=50,
                individual=True,
            ),
            factories.ScheduleAByContributorTypeFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2012,
                total=150,
                individual=True,
            ),
            factories.ScheduleAByContributorTypeFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2012,
                total=150,
                individual=False,
            ),
        ]
        results = self._results(
            api.url_for(
                ScheduleAByContributorTypeCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
            )
        )
        self.assertEqual(len(results), 2)
        individual = {
            'candidate_id': self.candidate.candidate_id,
            'cycle': 2012,
            'total': 200,
            'individual': True,
        }
        committee = {
            'candidate_id': self.candidate.candidate_id,
            'cycle': 2012,
            'total': 150,
            'individual': False,
        }
        self.assertIn(individual, results)
        self.assertIn(committee, results)
