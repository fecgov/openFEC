from webservices import schemas
from webservices.rest import db, api
from webservices.resources.aggregates import (
    ScheduleBByPurposeView,
    ScheduleEByCandidateView,
    CommunicationCostByCandidateView,
    ElectioneeringByCandidateView,
)
from webservices.resources.candidate_aggregates import (
    ScheduleABySizeCandidateView,
    ScheduleAByStateCandidateView,
)

from tests import factories
from tests.common import ApiBaseTest


class TestAggregates(ApiBaseTest):

    def setUp(self):
        super(TestAggregates, self).setUp()
        self.committee = factories.CommitteeHistoryFactory(cycle=2012)

    def test_aggregates_by_committee(self):
        params = [
            (
                factories.ScheduleBByPurposeFactory,
                ScheduleBByPurposeView,
                schemas.ScheduleBByPurposeSchema,
            ),
            (
                factories.ScheduleEByCandidateFactory,
                ScheduleEByCandidateView,
                schemas.ScheduleEByCandidateSchema,
            ),
            (
                factories.CommunicationCostByCandidateFactory,
                CommunicationCostByCandidateView,
                schemas.CommunicationCostByCandidateSchema,
            ),
            (
                factories.ElectioneeringByCandidateFactory,
                ElectioneeringByCandidateView,
                schemas.ElectioneeringByCandidateSchema,
            ),
        ]
        for factory, resource, schema in params:
            aggregate = factory(
                committee_id=self.committee.committee_id,
                cycle=self.committee.cycle,
            )
            results = self._results(
                api.url_for(
                    resource,
                    committee_id=self.committee.committee_id,
                    cycle=2012,
                )
            )
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0], schema().dump(aggregate).data)

    def test_aggregates_by_election(self):
        params = [
            (factories.CommunicationCostByCandidateFactory, CommunicationCostByCandidateView),
            (factories.ElectioneeringByCandidateFactory, ElectioneeringByCandidateView),
        ]
        candidate = factories.CandidateFactory(
            election_years=[2012],
            office='P',
        )
        factories.CandidateHistoryFactory(
            candidate_id=candidate.candidate_id,
            two_year_period=2012,
            election_years=[2012],
            office='P',
        )
        for factory, resource in params:
            [
                factory(
                    committee_id=self.committee.committee_id,
                    candidate_id=candidate.candidate_id,
                    cycle=self.committee.cycle,
                ),
                factory(
                    cycle=self.committee.cycle,
                ),
            ]
            results = self._results(
                api.url_for(
                    resource,
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
        factories.CandidateDetailFactory(candidate_id=self.candidate.candidate_id)
        [
            factories.CommitteeDetailFactory(committee_id=each.committee_id)
            for each in self.committees
        ]
        db.session.flush()
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committees[0].committee_id,
            cand_election_year=2012,
        )
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committees[1].committee_id,
            cand_election_year=2012,
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
