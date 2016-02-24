from tests import factories
from tests.common import ApiBaseTest, assert_dicts_subset

from webservices import schemas
from webservices.rest import db, api
from webservices.resources.aggregates import (
    ScheduleAByEmployerView,
    ScheduleEByCandidateView,
    CommunicationCostByCandidateView,
    ElectioneeringByCandidateView,
)
from webservices.resources.candidate_aggregates import (
    ScheduleABySizeCandidateView,
    ScheduleAByStateCandidateView,
    TotalsCandidateView,
)


class TestCommitteeAggregates(ApiBaseTest):

    def test_stable_sort(self):
        rows = [
            factories.ScheduleAByEmployerFactory(
                committee_id='C001',
                employer='omnicorp-{}'.format(idx),
                total=538,
            )
            for idx in range(100)
        ]
        employers = []
        for page in range(2):
            results = self._results(api.url_for(ScheduleAByEmployerView, sort='-total', per_page=50, page=page + 1))
            employers.extend(result['employer'] for result in results)
        assert len(set(employers)) == len(rows)


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
        factories.CandidateElectionFactory(
            candidate_id='P123',
            cand_election_year=2012,
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

    def test_candidate_aggregates_by_committee_full(self):
        """For each aggregate type, create a two-year aggregate in the target
        election year and a two-year aggregate in the previous two-year period.
        Assert that both aggregates are summed when the `election_full` flag is
        passed.
        """
        for factory, resource, schema in self.cases:
            aggregates = self.make_aggregates(factory)
            results = self._results(
                api.url_for(
                    resource,
                    candidate_id=self.candidate.candidate_id,
                    committee_id=self.committee.committee_id,
                    cycle=2012,
                    election_full='true',
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
        self.candidate = factories.CandidateHistoryFactory(
            candidate_id='S123',
            two_year_period=2012,
        )
        self.committees = [
            factories.CommitteeHistoryFactory(cycle=2012, designation='P'),
            factories.CommitteeHistoryFactory(cycle=2012, designation='A'),
        ]
        factories.CandidateHistoryLatestFactory(
            candidate_id=self.candidate.candidate_id,
            two_year_period=2012,
        )
        factories.CandidateDetailFactory(
            candidate_id=self.candidate.candidate_id,
            election_years=[2008, 2012],
        )
        [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate.candidate_id,
                cand_election_year=election_year
            )
            for election_year in [2008, 2012]
        ]
        [
            factories.CommitteeDetailFactory(committee_id=each.committee_id)
            for each in self.committees
        ]
        factories.CandidateTotalFactory(
            candidate_id=self.candidate.candidate_id,
            cycle=2012,
            is_election=True,
            receipts=100,
        )
        factories.CandidateTotalFactory(
            candidate_id=self.candidate.candidate_id,
            cycle=2012,
            is_election=False,
            receipts=75,
        )
        db.session.flush()
        # Create two-year totals for both the target period (2011-2012) and the
        # previous period (2009-2010) for testing the `election_full` flag
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committees[0].committee_id,
            committee_designation='P',
            committee_type='S',
            fec_election_year=2012,
        )
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committees[1].committee_id,
            committee_designation='A',
            committee_type='S',
            fec_election_year=2012,
        )
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committees[1].committee_id,
            committee_designation='A',
            committee_type='S',
            fec_election_year=2010,
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

    def test_totals(self):
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
            )
        )
        assert len(results) == 1
        assert_dicts_subset(results[0], {'cycle': 2012, 'receipts': 75})

    def test_totals_full(self):
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
                election_full='true',
            )
        )
        assert len(results) == 1
        assert_dicts_subset(results[0], {'cycle': 2012, 'receipts': 100})
