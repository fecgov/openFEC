from webservices import schemas
from webservices.rest import db, api
from webservices.resources.aggregates import (
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

    cases = [
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

    def setUp(self):
        super(TestAggregates, self).setUp()
        self.committee = factories.CommitteeHistoryFactory(
            name='Ritchie for America',
            cycle=2012,
        )
        self.candidate = factories.CandidateDetailFactory(
            candidate_id='P123',
            name='Robert Ritchie',
            election_years=[2012],
            office='P',
        )
        self.candidate_history = factories.CandidateHistoryFactory(
            candidate_id='P123',
            name='Robert Ritchie',
            election_years=[2012],
            two_year_period=2012,
            office='P',
        )

    def make_aggregates(self, factory):
        return [
            factory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committee.committee_id,
                cycle=self.committee.cycle,
                total=100,
                count=5,
            ),
            factory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committee.committee_id,
                cycle=self.committee.cycle - 2,
                total=100,
                count=5,
            ),
        ]

    def test_candidate_aggregates_by_committee(self):
        for factory, resource, schema in self.cases:
            aggregates = self.make_aggregates(factory)
            results = self._results(
                api.url_for(
                    resource,
                    committee_id=self.committee.committee_id,
                    cycle=2012,
                )
            )
            assert len(results) == 1
            serialized = schema().dump(aggregates[0]).data
            serialized.update({
                'committee_name': self.committee.name,
                'candidate_name': self.candidate.name,
            })
            assert results[0] == serialized

    def test_candidate_aggregates_by_committee_period(self):
        for factory, resource, schema in self.cases:
            aggregates = self.make_aggregates(factory)
            results = self._results(
                api.url_for(
                    resource,
                    candidate_id=self.candidate.candidate_id,
                    committee_id=self.committee.committee_id,
                    cycle=2012,
                    period='true',
                )
            )
            assert len(results) == 1
            serialized = schema().dump(aggregates[0]).data
            serialized.update({
                'committee_name': self.committee.name,
                'candidate_name': self.candidate.name,
                'total': sum(each.total for each in aggregates),
                'count': sum(each.count for each in aggregates),
            })
            assert results[0] == serialized

    def test_candidate_aggregates_by_election(self):
        for factory, resource, _ in self.cases:
            [
                factory(
                    committee_id=self.committee.committee_id,
                    candidate_id=self.candidate.candidate_id,
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
            assert len(results) == 1
            assert results[0]['candidate_id'] == self.candidate.candidate_id


class TestCandidateAggregates(ApiBaseTest):

    def setUp(self):
        super().setUp()
        self.candidate = factories.CandidateHistoryFactory(two_year_period=2012)
        self.committees = [
            factories.CommitteeHistoryFactory(cycle=2012, designation='P'),
            factories.CommitteeHistoryFactory(cycle=2012, designation='A'),
        ]
        factories.CandidateDetailFactory(
            candidate_id=self.candidate.candidate_id,
            election_years=[2008, 2012],
        )
        [
            factories.CommitteeDetailFactory(committee_id=each.committee_id)
            for each in self.committees
        ]
        db.session.flush()
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committees[0].committee_id,
            committee_designation='P',
            fec_election_year=2012,
        )
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committees[1].committee_id,
            committee_designation='A',
            fec_election_year=2012,
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
