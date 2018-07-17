from tests import factories
from tests.common import ApiBaseTest, assert_dicts_subset

from webservices.utils import get_current_cycle

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
                    office='president',
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
                    office='president',
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

    current_cycle = get_current_cycle()
    next_cycle = current_cycle + 2

    def setUp(self):
        super().setUp()
        self.candidate = factories.CandidateHistoryFutureFactory(
            candidate_id='S123',
            two_year_period=2012,
            candidate_election_year=2012,
        )
        self.committees = [
            factories.CommitteeHistoryFactory(cycle=2012, designation='P'),
            factories.CommitteeHistoryFactory(cycle=2012, designation='A'),
        ]
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
        factories.CandidateFlagsFactory(
            candidate_id=self.candidate.candidate_id
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
        # Create a candidate_zero without a committee and $0 in CandidateTotal
        self.candidate_zero = factories.CandidateHistoryFutureFactory(
            candidate_id='H321',
            two_year_period=2018,
            candidate_election_year=2018,
        )
        factories.CandidateDetailFactory(
            candidate_id=self.candidate_zero.candidate_id,
            election_years=[2018],
        )
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_zero.candidate_id,
            cycle=2018,
            is_election=False,
            receipts=0,
        )
        # Create data for a candidate who ran in 2017 and 2018

        self.candidate_17_18 = factories.CandidateHistoryFutureFactory(
            candidate_id='S456',
            two_year_period=2018,
            candidate_election_year=2018,
        )
        self.committees_17_18 = [
            factories.CommitteeHistoryFactory(cycle=2018, designation='P'),
        ]
        factories.CandidateDetailFactory(
            candidate_id=self.candidate_17_18.candidate_id,
            election_years=[2018],
        )
        [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate_17_18.candidate_id,
                cand_election_year=election_year
            )
            for election_year in [2017, 2018]
        ]
        [
            factories.CommitteeDetailFactory(committee_id=each.committee_id)
            for each in self.committees_17_18
        ]
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_17_18.candidate_id,
            cycle=2018,
            is_election=True,
            receipts=100,
        )
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_17_18.candidate_id,
            cycle=2018,
            is_election=False,
            receipts=100,
        )
        factories.CandidateFlagsFactory(
            candidate_id=self.candidate_17_18.candidate_id
        )
        db.session.flush()

        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate_17_18.candidate_id,
            committee_id=self.committees_17_18[0].committee_id,
            committee_designation='P',
            committee_type='S',
            cand_election_year=2017,
            fec_election_year=2018,
        )
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate_17_18.candidate_id,
            committee_id=self.committees_17_18[0].committee_id,
            committee_designation='P',
            committee_type='S',
            cand_election_year=2018,
            fec_election_year=2018,
        )
        # Create data for a candidate who ran just in 2017
        self.candidate_17_only = factories.CandidateHistoryFutureFactory(
            candidate_id='H456',
            two_year_period=2018,
            candidate_election_year=2017,
        )
        self.committees_17_only = [
            factories.CommitteeHistoryFactory(cycle=2018, designation='P'),
        ]
        factories.CandidateDetailFactory(
            candidate_id=self.candidate_17_only.candidate_id,
            election_years=[2017],
        )
        [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate_17_only.candidate_id,
                cand_election_year=election_year
            )
            for election_year in [2017]
        ]
        [
            factories.CommitteeDetailFactory(committee_id=each.committee_id)
            for each in self.committees_17_only
        ]
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_17_only.candidate_id,
            cycle=2018,
            is_election=True,
            receipts=150,
        )
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_17_only.candidate_id,
            cycle=2018,
            is_election=False,
            receipts=150,
        )
        factories.CandidateFlagsFactory(
            candidate_id=self.candidate_17_only.candidate_id
        )
        db.session.flush()

        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate_17_only.candidate_id,
            committee_id=self.committees_17_only[0].committee_id,
            committee_designation='P',
            committee_type='S',
            cand_election_year=2017,
            fec_election_year=2018,
        )

        # Create data for future presidential - next_cycle. Use formula for future

        # Test full next_cycle and current_cycle 2-year totals

        self.candidate_20 = factories.CandidateHistoryFutureFactory(
            candidate_id='P456',
            two_year_period=self.current_cycle,
            candidate_election_year=self.next_cycle,
        )
        self.candidate_20 = factories.CandidateHistoryFutureFactory(
            candidate_id='P456',
            two_year_period=self.next_cycle,
            candidate_election_year=self.next_cycle,
        )
        #Candidate history won't have next_cycle yet
        self.committees_20 = [
            factories.CommitteeHistoryFactory(cycle=self.current_cycle, designation='P'),
        ]
        factories.CandidateDetailFactory(
            candidate_id=self.candidate_20.candidate_id,
            election_years=[self.next_cycle],
        )
        [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate_20.candidate_id,
                cand_election_year=election_year
            )
            for election_year in [self.next_cycle - 4, self.next_cycle]
        ]
        [
            factories.CommitteeDetailFactory(committee_id=each.committee_id)
            for each in self.committees_20
        ]
        #Full next_cycle
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_20.candidate_id,
            cycle=self.next_cycle,
            is_election=True,
            receipts=55000,
        )
        #current_cycle 2-year
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_20.candidate_id,
            cycle=self.current_cycle,
            is_election=False,
            receipts=25000,
        )
        factories.CandidateFlagsFactory(
            candidate_id=self.candidate_20.candidate_id
        )
        db.session.flush()

        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate_20.candidate_id,
            committee_id=self.committees_20[0].committee_id,
            committee_designation='P',
            committee_type='P',
            cand_election_year=self.next_cycle,
            fec_election_year=self.current_cycle,
        )

        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate_20.candidate_id,
            committee_id=self.committees_20[0].committee_id,
            committee_designation='P',
            committee_type='P',
            cand_election_year=self.next_cycle,
            fec_election_year=self.next_cycle,
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

        # candidate_zero
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate_zero.candidate_id,
                cycle=2018,
            )
        )
        assert len(results) == 1
        assert_dicts_subset(results[0], {'cycle': 2018, 'receipts': 0})

        # candidate_17_18
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate_17_18.candidate_id,
                cycle=2018,
            )
        )
        assert len(results) == 1
        assert_dicts_subset(results[0], {'cycle': 2018, 'receipts': 100})

        # candidate_17_only
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate_17_only.candidate_id,
                cycle=2018,
            )
        )
        assert len(results) == 1
        assert_dicts_subset(results[0], {'cycle': 2018, 'receipts': 150})

        # candidate_20
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate_20.candidate_id,
                cycle=self.current_cycle,
            )
        )
        assert len(results) == 1
        assert_dicts_subset(results[0], {'cycle': self.current_cycle, 'receipts': 25000})

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

        # candidate_20
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate_20.candidate_id,
                cycle=self.next_cycle,
                election_full='true',
            )
        )
        assert len(results) == 1
        assert_dicts_subset(results[0], {'cycle': self.next_cycle, 'receipts': 55000})
