from tests import factories
from tests.common import ApiBaseTest, assert_dicts_subset

from webservices.utils import get_current_cycle

from webservices import schemas
from webservices.rest import db, api
from webservices.resources.aggregates import (
    CommunicationCostByCandidateView,
    ElectioneeringByCandidateView,
    ScheduleAByEmployerView,
    ScheduleAByStateView,
    ScheduleBByPurposeView,
    ScheduleBByRecipientView,
    ScheduleEByCandidateView,
    ScheduleBByRecipientIDView,
)
from webservices.resources.candidate_aggregates import (
    ScheduleABySizeCandidateView,
    ScheduleAByStateCandidateView,
    ScheduleAByStateCandidateTotalsView,
    TotalsCandidateView,
    AggregateByOfficeView,
    AggregateByOfficeByPartyView,
    CandidateTotalAggregateView,
)


class TestCommitteeAggregates(ApiBaseTest):
    def test_stable_sort(self):
        rows = [
            factories.ScheduleAByEmployerFactory(
                committee_id='C001', employer='omnicorp-{}'.format(idx), total=538,
            )
            for idx in range(100)
        ]
        employers = []
        for page in range(2):
            results = self._results(
                api.url_for(
                    ScheduleAByEmployerView, sort='-total', per_page=50, page=page + 1
                )
            )
            employers.extend(result['employer'] for result in results)
        assert len(set(employers)) == len(rows)

    def test_by_state(self):
        [
            factories.ScheduleAByStateFactory(
                committee_id='C0001',
                cycle=2012,
                total=50,
                state='NY',
                state_full='New York',
                count=5,
            ),
            factories.ScheduleAByStateFactory(
                committee_id='C0002',
                cycle=2012,
                total=150,
                state='NY',
                state_full='New York',
                count=6,
            ),
            factories.ScheduleAByStateFactory(
                committee_id='C0003',
                cycle=2018,
                total=100,
                state='OT',
                state_full='Other',
            ),
            factories.ScheduleAByStateFactory(
                committee_id='C0001',
                cycle=2016,
                total=200,
                state='CT',
                state_full='Connecticut',
                count=2,
            ),
        ]
        results = self._results(
            api.url_for(ScheduleAByStateView, committee_id='C0001', cycle=2012)
        )
        assert len(results) == 1

        results = self._results(api.url_for(ScheduleAByStateView, state='NY',))
        assert len(results) == 2

        results = self._results(
            api.url_for(ScheduleAByStateView, cycle=2018, state='OT',)
        )
        assert len(results) == 1

        results = self._results(
            api.url_for(ScheduleAByStateView, committee_id='C0001',)
        )
        assert len(results) == 2

    def test_disbursement_purpose(self):
        committee = factories.CommitteeHistoryFactory(cycle=2012)

        aggregate = factories.ScheduleBByPurposeFactory(
            committee_id=committee.committee_id,
            cycle=committee.cycle,
            purpose='ADMINISTRATIVE EXPENSES',
        )
        results = self._results(
            api.url_for(
                ScheduleBByPurposeView,
                committee_id=committee.committee_id,
                cycle=2012,
                purpose='Administrative',
            )
        )
        self.assertEqual(len(results), 1)
        expected = {
            'committee_id': committee.committee_id,
            'purpose': 'ADMINISTRATIVE EXPENSES',
            'cycle': 2012,
            'total': aggregate.total,
            'count': aggregate.count,
            'memo_total': aggregate.memo_total,
            'memo_count': aggregate.memo_count,
        }
        self.assertEqual(results[0], expected)

    def test_disbursement_recipient(self):
        committee = factories.CommitteeHistoryFactory(cycle=2012)

        aggregate = factories.ScheduleBByRecipientFactory(
            committee_id=committee.committee_id,
            cycle=committee.cycle,
            recipient_name='STARBOARD STRATEGIES, INC.',
        )
        results = self._results(
            api.url_for(
                ScheduleBByRecipientView,
                committee_id=committee.committee_id,
                cycle=2012,
                recipient_name='Starboard Strategies',
            )
        )
        self.assertEqual(len(results), 1)
        expected = {
            'committee_id': committee.committee_id,
            'recipient_name': 'STARBOARD STRATEGIES, INC.',
            'cycle': 2012,
            'total': aggregate.total,
            'count': aggregate.count,
            'memo_total': aggregate.memo_total,
            'memo_count': aggregate.memo_count,
            'committee_total_disbursements': aggregate.committee_total_disbursements,
            'recipient_disbursement_percent': aggregate.recipient_disbursement_percent,
        }
        self.assertEqual(results[0], expected)

    def test_disbursement_recipient_id_total(self):
        committee = factories.CommitteeHistoryFactory(cycle=2012)

        aggregate = factories.ScheduleBByRecipientIDFactory(
            committee_id=committee.committee_id,
            cycle=committee.cycle,
            recipient_id='C00507368',
            total=4000,
            count=2,
            memo_total=10,
            memo_count=1,
        )
        results = self._results(
            api.url_for(
                ScheduleBByRecipientIDView,
                committee_id=committee.committee_id,
                cycle=2012,
                recipient_id='C00507368',
            )
        )
        self.assertEqual(len(results), 1)
        expected = {
            'committee_id': committee.committee_id,
            'recipient_id': 'C00507368',
            'cycle': 2012,
            'total': aggregate.total,
            'count': aggregate.count,
            'memo_total': aggregate.memo_total,
            'memo_count': aggregate.memo_count,
        }
        self.assertEqual(results[0], expected)


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
            name='Ritchie for America', cycle=2012,
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
            candidate_id='P123', cand_election_year=2012,
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
                    election_full=False,
                )
            )
            assert len(results) == 1
            serialized = schema().dump(aggregates[0]).data
            serialized.update(
                {
                    'committee_name': self.committee.name,
                    'candidate_name': self.candidate.name,
                }
            )
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
            serialized.update(
                {
                    'committee_name': self.committee.name,
                    'candidate_name': self.candidate.name,
                    'total': sum(each.total for each in aggregates),
                    'count': sum(each.count for each in aggregates),
                }
            )
            assert results[0] == serialized

    def test_candidate_aggregates_by_election(self):
        for factory, resource, _ in self.cases:
            [
                factory(
                    committee_id=self.committee.committee_id,
                    candidate_id=self.candidate.candidate_id,
                    cycle=self.committee.cycle,
                ),
                factory(cycle=self.committee.cycle,),
            ]
            results = self._results(
                api.url_for(resource, office='president', cycle=2012,)
            )
            assert len(results) == 1
            assert results[0]['candidate_id'] == self.candidate.candidate_id


class TestCandidateAggregates(ApiBaseTest):
    current_cycle = get_current_cycle()
    next_cycle = current_cycle + 2

    def setUp(self):
        super().setUp()
        self.candidate = factories.CandidateHistoryFutureFactory(
            candidate_id='S123', two_year_period=2012, candidate_election_year=2012,
        )
        self.committees = [
            factories.CommitteeHistoryFactory(cycle=2012, designation='P'),
            factories.CommitteeHistoryFactory(cycle=2012, designation='A'),
        ]
        factories.CandidateDetailFactory(
            candidate_id=self.candidate.candidate_id, election_years=[2008, 2012],
        )
        [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate.candidate_id,
                cand_election_year=election_year,
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
        factories.CandidateFlagsFactory(candidate_id=self.candidate.candidate_id)
        db.session.flush()
        # Create two-year totals for both the target period (2011-2012) and the
        # previous period (2009-2010) for testing the `election_full` flag
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committees[0].committee_id,
            committee_designation='P',
            committee_type='S',
            fec_election_year=2012,
            election_yr_to_be_included=2012,
        )
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committees[1].committee_id,
            committee_designation='A',
            committee_type='S',
            fec_election_year=2012,
            election_yr_to_be_included=2012,
        )
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committees[1].committee_id,
            committee_designation='A',
            committee_type='S',
            fec_election_year=2010,
            election_yr_to_be_included=2012,
        )
        # Create a candidate_zero without a committee and $0 in CandidateTotal
        self.candidate_zero = factories.CandidateHistoryFutureFactory(
            candidate_id='H321',
            two_year_period=2018,
            candidate_election_year=2018,
            candidate_inactive=True,
        )
        factories.CandidateDetailFactory(
            candidate_id=self.candidate_zero.candidate_id, election_years=[2018],
        )
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_zero.candidate_id,
            cycle=2018,
            is_election=False,
            receipts=0,
        )
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_zero.candidate_id,
            cycle=2018,
            is_election=True,
            receipts=0,
        )
        # Create data for a candidate who ran in 2017 and 2018

        self.candidate_17_18 = factories.CandidateHistoryFutureFactory(
            candidate_id='S456',
            two_year_period=2018,
            candidate_election_year=2018,
            candidate_inactive=False,
        )
        self.committees_17_18 = [
            factories.CommitteeHistoryFactory(cycle=2018, designation='P'),
        ]
        factories.CandidateDetailFactory(
            candidate_id=self.candidate_17_18.candidate_id, election_years=[2018],
        )
        [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate_17_18.candidate_id,
                cand_election_year=election_year,
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
        factories.CandidateFlagsFactory(candidate_id=self.candidate_17_18.candidate_id)
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
            candidate_id='H456', two_year_period=2018, candidate_election_year=2017,
        )
        self.committees_17_only = [
            factories.CommitteeHistoryFactory(cycle=2018, designation='P'),
        ]
        factories.CandidateDetailFactory(
            candidate_id=self.candidate_17_only.candidate_id, election_years=[2017],
        )
        [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate_17_only.candidate_id,
                cand_election_year=election_year,
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
        # Candidate history won't have next_cycle yet
        self.committees_20 = [
            factories.CommitteeHistoryFactory(
                cycle=self.current_cycle, designation='P'
            ),
        ]
        factories.CandidateDetailFactory(
            candidate_id=self.candidate_20.candidate_id,
            election_years=[self.next_cycle],
        )
        [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate_20.candidate_id,
                cand_election_year=election_year,
            )
            for election_year in [self.next_cycle - 4, self.next_cycle]
        ]
        [
            factories.CommitteeDetailFactory(committee_id=each.committee_id)
            for each in self.committees_20
        ]
        # Full next_cycle
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_20.candidate_id,
            cycle=self.next_cycle,
            is_election=True,
            receipts=55000,
        )
        # current_cycle 2-year
        factories.CandidateTotalFactory(
            candidate_id=self.candidate_20.candidate_id,
            cycle=self.current_cycle,
            is_election=False,
            receipts=25000,
        )
        factories.CandidateFlagsFactory(candidate_id=self.candidate_20.candidate_id)
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
                count=20,
            ),
            factories.ScheduleABySizeFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2012,
                total=150,
                size=200,
                count=20,
            ),
            factories.ScheduleABySizeFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2010,
                total=3,
                size=200,
                count=3,
            ),
        ]
        results = self._results(
            api.url_for(
                ScheduleABySizeCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
            )
        )
        assert len(results) == 1
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'cycle': 2012,
            'total': 203,
            'size': 200,
            'count': 43,
        }
        assert results[0] == expected

        results = self._results(
            api.url_for(
                ScheduleABySizeCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
                election_full=False,
            )
        )
        assert len(results) == 1
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'cycle': 2012,
            'total': 200,
            'size': 200,
            'count': 40,
        }
        assert results[0] == expected

    def test_by_state(self):
        [
            factories.ScheduleAByStateFactory(
                committee_id=self.committees[0].committee_id,
                cycle=2012,
                total=50,
                state='NY',
                state_full='New York',
                count=30,
            ),
            factories.ScheduleAByStateFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2012,
                total=150,
                state='NY',
                state_full='New York',
                count=30,
            ),
            factories.ScheduleAByStateFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2010,
                total=10.01,
                state='NY',
                state_full='New York',
                count=3,
            ),
        ]
        results = self._results(
            api.url_for(
                ScheduleAByStateCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
            )
        )
        assert len(results) == 1
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'cycle': 2012,
            'total': 210.01,
            'state': 'NY',
            'state_full': 'New York',
            'count': 63,
        }
        assert results[0] == expected

        results = self._results(
            api.url_for(
                ScheduleAByStateCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
                election_full=False,
            )
        )
        assert len(results) == 1
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'cycle': 2012,
            'total': 200,
            'state': 'NY',
            'state_full': 'New York',
            'count': 60,
        }
        assert results[0] == expected

    def test_by_state_candidate_totals(self):
        [
            factories.ScheduleAByStateFactory(
                committee_id=self.committees[0].committee_id,
                cycle=2012,
                total=50.3,
                state='NY',
                state_full='New York',
                count=30,
            ),
            factories.ScheduleAByStateFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2012,
                total=150.11,
                state='CT',
                state_full='New York',
                count=10,
            ),
            factories.ScheduleAByStateFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2012,
                total=150.10,
                state='NJ',
                state_full='New Jersey',
                count=60,
            ),
        ]
        results = self._results(
            api.url_for(
                ScheduleAByStateCandidateTotalsView,
                candidate_id=self.candidate.candidate_id.lower(),
                cycle=2012,
            )
        )
        assert len(results) == 1
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'cycle': 2012,
            'total': 350.51,
            'count': 100,
        }
        assert results[0] == expected

    def test_totals(self):
        # 2-year totals
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
                election_full=False,
            )
        )
        assert len(results) == 1
        assert_dicts_subset(results[0], {'cycle': 2012, 'receipts': 75})

        # Full-cycle totals (default is true)
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
            )
        )
        assert len(results) == 1
        assert_dicts_subset(results[0], {'cycle': 2012, 'receipts': 100})

        # candidate_zero
        # by default, load all candidates, current candidate should return
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate_zero.candidate_id,
                cycle=2018,
            )
        )
        assert len(results) == 1
        assert_dicts_subset(results[0], {'cycle': 2018, 'receipts': 0})

        # active candidate test: loading active candidates result nothing
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate_zero.candidate_id,
                cycle=2018,
                is_active_candidate=True,
            )
        )
        assert len(results) == 0

        # active candidate test: loading inactive candidates result current one
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate_zero.candidate_id,
                cycle=2018,
                is_active_candidate=False,
                election_full=False,
            )
        )
        assert len(results) == 1

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

        # active candidats tst2: load inactive candidates result nothing
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate_17_18.candidate_id,
                cycle=2018,
                is_active_candidate=False,
            )
        )
        assert len(results) == 0

        # active candidats tst3: load active candidates only
        results = self._results(
            api.url_for(
                TotalsCandidateView,
                candidate_id=self.candidate_17_18.candidate_id,
                cycle=2018,
                is_active_candidate=True,
            )
        )
        assert len(results) == 1

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
                election_full=False,
            )
        )
        assert len(results) == 1
        assert_dicts_subset(
            results[0], {'cycle': self.current_cycle, 'receipts': 25000}
        )

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


# Test /candidates/totals/by_office/ (candidate_aggregates.AggregateByOfficeView
class TestCandidateTotalsByOffice(ApiBaseTest):

    def setUp(self):
        super().setUp()
        factories.CandidateTotalFactory(
            candidate_id="S11",
            is_election=True,  # candidate election year
            receipts=100,
            disbursements=100,
            election_year=2016,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=100,
            transfers_from_other_authorized_committee=100,
            other_political_committee_contributions=100,
        )
        factories.CandidateTotalFactory(
            candidate_id="S11",
            is_election=False,  # data for two-year period (not candidate election year)
            cycle=2012,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            receipts=200,
            disbursements=200,
            election_year=2016,
            office="S",
            candidate_inactive=True,  # is_active_candidate=False
            individual_itemized_contributions=200,
            transfers_from_other_authorized_committee=200,
            other_political_committee_contributions=200,
        )
        factories.CandidateTotalFactory(
            candidate_id="S11",
            is_election=False,  # data for two-year period (not candidate election year)
            cycle=2014,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            receipts=400,
            disbursements=400,
            election_year=2016,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=400,
            transfers_from_other_authorized_committee=400,
            other_political_committee_contributions=400,
        )
        factories.CandidateTotalFactory(
            candidate_id="S11",
            is_election=False,  # data for two-year period (not candidate election year)
            cycle=2016,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            receipts=600,
            disbursements=600,
            election_year=2016,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=600,
            transfers_from_other_authorized_committee=600,
            other_political_committee_contributions=600,
        )
        factories.CandidateTotalFactory(
            candidate_id="S22",
            is_election=True,  # candidate election year
            receipts=700,
            disbursements=700,
            election_year=2010,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=700,
            transfers_from_other_authorized_committee=700,
            other_political_committee_contributions=700,
        )

        factories.CandidateTotalFactory(
            candidate_id="S33",
            is_election=True,  # candidate election year
            receipts=800,
            disbursements=800,
            election_year=2016,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=800,
            transfers_from_other_authorized_committee=800,
            other_political_committee_contributions=800,
        )

        factories.CandidateTotalFactory(
            candidate_id="S44",
            is_election=True,  # candidate election year
            receipts=90,
            disbursements=90,
            election_year=2022,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=90,
            transfers_from_other_authorized_committee=90,
            other_political_committee_contributions=90,
        )

        factories.CandidateTotalFactory(
            candidate_id="H11",
            is_election=False,
            receipts=1000,
            disbursements=1000,
            election_year=2016,
            cycle=2016,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            office="H",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=1000,
            transfers_from_other_authorized_committee=1000,
            other_political_committee_contributions=1000,
        )
        factories.CandidateTotalFactory(
            candidate_id="H11",
            is_election=True,
            receipts=1000,
            disbursements=1000,
            election_year=2016,
            cycle=2016,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            office="H",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=1000,
            transfers_from_other_authorized_committee=1000,
            other_political_committee_contributions=1000,
        )
        factories.CandidateTotalFactory(
            candidate_id="H22",
            is_election=True,
            receipts=2000,
            disbursements=2000,
            election_year=2016,
            office="H",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=2000,
            transfers_from_other_authorized_committee=2000,
            other_political_committee_contributions=2000,
        )
        factories.CandidateTotalFactory(
            candidate_id="H22",
            is_election=True,
            receipts=5000,
            disbursements=5000,
            election_year=2018,
            office="H",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=5000,
            transfers_from_other_authorized_committee=5000,
            other_political_committee_contributions=5000,
        )

    def test_base(self):
        # without any paramenter, return six rows:
        # 1)2016/S, 2)2010/S, 3)2022/S, 4)2016/H, 5)2018/H
        results = self._results(api.url_for(AggregateByOfficeView,))
        assert len(results) == 5

    def test_filter_by_office(self):
        # office=S, election_full default=true
        # return three rows:
        # 1) election_year=2016
        # 2) election_year=2010
        # 3) election_year=2022
        results = self._results(api.url_for(AggregateByOfficeView, office="S"))
        assert len(results) == 3

        # office=H, election_full default=true
        # return two rows:
        # 1) election_year=2016
        # 2) election_year=2018
        results = self._results(api.url_for(AggregateByOfficeView, office="H"))
        assert len(results) == 2

    def test_filter_by_election_year(self):
        # office=S, election_full=true, election_year=2016
        # return one rows:
        # 1)election_year=2016, election_full=true, is_active_candidate=true,
        # total_receiptes=100+800=900
        results = self._results(
            api.url_for(
                AggregateByOfficeView,
                office="S",
                is_active_candidate=True,
                election_year=2016)
        )
        assert len(results) == 1
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "total_receipts": 900,
                "total_disbursements": 900,
                "total_individual_itemized_contributions": 900,
                "total_transfers_from_other_authorized_committee": 900,
                "total_other_political_committee_contributions": 900,
            },
        )

    def test_filter_by_is_active_candidate(self):
        # office=S, election_full=true, is_active_candidate=true
        # return three rows:
        # 1)election_year=2022, election_full=true, is_active_candidate=true
        # return: total_receipts=90
        # 2)election_year=2016, election_full=true, is_active_candidate=true
        # return: total_receipts=100+800
        # 3)election_year=2010, election_full=true, is_active_candidate=true
        # return: total_receipts=700
        #
        results = self._results(
            api.url_for(
                AggregateByOfficeView,
                office="S",
                is_active_candidate=True,
            )
        )
        assert len(results) == 3
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2022,
                "total_receipts": 90,
                "total_disbursements": 90,
                "total_individual_itemized_contributions": 90,
                "total_transfers_from_other_authorized_committee": 90,
                "total_other_political_committee_contributions": 90,
            },
        )
        assert_dicts_subset(
            results[1],
            {
                "election_year": 2016,
                "total_receipts": 900,
                "total_disbursements": 900,
                "total_individual_itemized_contributions": 900,
                "total_transfers_from_other_authorized_committee": 900,
                "total_other_political_committee_contributions": 900,
            },
        )
        assert_dicts_subset(
            results[2],
            {
                "election_year": 2010,
                "total_receipts": 700,
                "total_disbursements": 700,
                "total_individual_itemized_contributions": 700,
                "total_transfers_from_other_authorized_committee": 700,
                "total_other_political_committee_contributions": 700,
            },
        )

        # office=S, election_full=false, is_active_candidate=false
        # return one rows:
        # 1)election_year=2016, election_full=false, is_active_candidate=false, total_receipts=200
        results = self._results(
            api.url_for(
                AggregateByOfficeView,
                office="S",
                is_active_candidate=False,
                election_full=False,  # =is_eleciton
            )
        )
        assert len(results) == 1
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "total_receipts": 200,
                "total_disbursements": 200,
                "total_individual_itemized_contributions": 200,
                "total_transfers_from_other_authorized_committee": 200,
                "total_other_political_committee_contributions": 200,
            },
        )

        # office=S, election_full=true, is_active_candidate=false
        # return 0 row:
        results = self._results(
            api.url_for(
                AggregateByOfficeView,
                office="S",
                is_active_candidate=False,
                election_full=True,  # =is_eleciton
            )
        )
        assert len(results) == 0

    def test_sort_by_election_year(self):
        # office=H, election_full=true, is_active_candidate=true
        # return two rows:
        # 1)election_year=2018, election_full=true, is_active_candidate=true,
        # return: total_receipts=5000
        # 2)election_year=2016, election_full=true, is_active_candidate=true
        # return: total_receipts=1000+2000=3000
        #
        results = self._results(
            api.url_for(AggregateByOfficeView, office="H", is_active_candidate=True,)
        )
        assert len(results) == 2
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2018,
                "total_receipts": 5000,
                "total_disbursements": 5000,
                "total_individual_itemized_contributions": 5000,
                "total_transfers_from_other_authorized_committee": 5000,
                "total_other_political_committee_contributions": 5000,
            },
        )
        assert_dicts_subset(
            results[1],
            {
                "election_year": 2016,
                "total_receipts": 3000,
                "total_disbursements": 3000,
                "total_individual_itemized_contributions": 3000,
                "total_transfers_from_other_authorized_committee": 3000,
                "total_other_political_committee_contributions": 3000,
            },
        )

    def test_filter_by_min_max_election_cycle(self):
        # case1: office=S, election_full=true, is_active_candidate=true,min_election_cycle=2016
        # return two rows:
        # 1)election_year=2022, 2)election_year=2016
        results = self._results(
            api.url_for(
                AggregateByOfficeView,
                office="S",
                is_active_candidate=True,
                min_election_cycle=2016
            )
        )
        assert len(results) == 2

        # case2: office=S, election_full=true, is_active_candidate=true,max_election_cycle=2016
        # return two rows:
        # 1)election_year=2010, 2)election_year=2016
        results = self._results(
            api.url_for(
                AggregateByOfficeView,
                office="S",
                is_active_candidate=True,
                max_election_cycle=2016
            )
        )
        assert len(results) == 2

        # case3: office=S, election_full=true, is_active_candidate=true,min_election_cycle=2016,max_election_cycle=2022
        # return two rows:
        # 1)election_year=2022, 2)election_year=2016
        results = self._results(
            api.url_for(
                AggregateByOfficeView,
                office="S",
                is_active_candidate=True,
                min_election_cycle=2016,
                max_election_cycle=2022
            )
        )
        assert len(results) == 2


# Test /candidates/totals/by_office/by_party/ (candidate_aggregates.AggregateByOfficeByPartyView)
class TestCandidateTotalsByOfficeByParty(ApiBaseTest):
    def setUp(self):
        super().setUp()
        factories.CandidateTotalFactory(
            candidate_id='S11111',
            is_election=True,
            receipts=100,
            disbursements=100,
            election_year=2016,
            office='S',
            party='DEM',
            candidate_inactive=True,
        )
        factories.CandidateTotalFactory(
            candidate_id='S2222',
            is_election=False,
            receipts=1000,
            disbursements=1000,
            election_year=2016,
            office='S',
            party='DEM',
            candidate_inactive=False,
        )
        factories.CandidateTotalFactory(
            candidate_id='S3333',
            is_election=True,
            receipts=10000,
            disbursements=10000,
            election_year=2016,
            office='S',
            party='REP',
            candidate_inactive=False,
        )
        factories.CandidateTotalFactory(
            candidate_id='P11111',
            is_election=True,
            receipts=100000,
            disbursements=100000,
            election_year=2016,
            office='P',
            party='DEM',
            candidate_inactive=False,
        )
        factories.CandidateTotalFactory(
            candidate_id='P2222',
            is_election=True,
            receipts=1000000,
            disbursements=1000000,
            election_year=2016,
            office='P',
            party='REP',
            candidate_inactive=True,
        )
        factories.CandidateTotalFactory(
            candidate_id='H1111',
            is_election=True,
            receipts=200,
            disbursements=200,
            election_year=2016,
            office='H',
            party='REP',
            candidate_inactive=False,
        )
        factories.CandidateTotalFactory(
            candidate_id='H2222',
            is_election=True,
            receipts=300,
            disbursements=300,
            election_year=2016,
            office='H',
            party='GRE',
            candidate_inactive=False,
        )

    def test_candidate_totals_by_office_by_party(self):
        results = self._results(api.url_for(AggregateByOfficeByPartyView,))
        assert len(results) == 6

        results = self._results(api.url_for(AggregateByOfficeByPartyView, office='S'))
        assert len(results) == 2
        assert_dicts_subset(
            results[0],
            {
                'election_year': 2016,
                'party': 'DEM',
                'total_receipts': 100,
                'total_disbursements': 100,
            },
        )
        assert_dicts_subset(
            results[1],
            {
                'election_year': 2016,
                'party': 'REP',
                'total_receipts': 10000,
                'total_disbursements': 10000,
            },
        )

        results = self._results(
            api.url_for(
                AggregateByOfficeByPartyView, office='H', is_active_candidate=True,
            )
        )
        assert len(results) == 2
        assert_dicts_subset(
            results[0],
            {
                'election_year': 2016,
                'party': 'Other',
                'total_receipts': 300,
                'total_disbursements': 300,
            },
        )
        assert_dicts_subset(
            results[1],
            {
                'election_year': 2016,
                'party': 'REP',
                'total_receipts': 200,
                'total_disbursements': 200,
            },
        )


# Test /candidates/totals/aggregates/ (candidate_aggregates.CandidateTotalAggregateView
class TestCandidatesTotalsAggregates(ApiBaseTest):
    def setUp(self):
        super().setUp()
        factories.ElectionsListFactory(
            cycle=2016, state='CA', office='H', district='01'
        )
        factories.ElectionsListFactory(
            cycle=2016, state='CA', office='H', district='02'
        )
        factories.ElectionsListFactory(
            cycle=2016, state='NY', office='H', district='01'
        )
        factories.ElectionsListFactory(
            cycle=2016, state='CA', office='S', district='00'
        )
        factories.ElectionsListFactory(
            cycle=2022, state='CA', office='S', district='00'
        )
        factories.ElectionsListFactory(
            cycle=2010, state='NY', office='S', district='00'
        )
        factories.ElectionsListFactory(
            cycle=2016, state='NY', office='S', district='00'
        )

        factories.CandidateTotalFactory(
            candidate_id="HCA01",
            is_election=True,
            receipts=1000,
            disbursements=1000,
            election_year=2016,
            cycle=2016,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            office="H",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=1000,
            transfers_from_other_authorized_committee=1000,
            other_political_committee_contributions=1000,
            cash_on_hand_end_period=1000,
            debts_owed_by_committee=1000,
            state="CA",
            district="01",
            party="DEM",
            state_full='California'
        )
        factories.CandidateTotalFactory(
            candidate_id="HCA01",
            is_election=False,
            receipts=1000,
            disbursements=1000,
            election_year=2016,
            cycle=2016,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            office="H",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=1000,
            transfers_from_other_authorized_committee=1000,
            other_political_committee_contributions=1000,
            cash_on_hand_end_period=1000,
            debts_owed_by_committee=1000,
            state="CA",
            district="01",
            party="DEM",
            state_full='California'
        )
        factories.CandidateTotalFactory(
            candidate_id="HCA02",
            is_election=True,
            receipts=2000,
            disbursements=2000,
            election_year=2016,
            cycle=2016,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            office="H",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=2000,
            transfers_from_other_authorized_committee=2000,
            other_political_committee_contributions=2000,
            cash_on_hand_end_period=2000,
            debts_owed_by_committee=2000,
            state="CA",
            district="02",
            party="DEM",
            state_full='California'
        )
        factories.CandidateTotalFactory(
            candidate_id="HNY01",
            is_election=True,
            receipts=3300,
            disbursements=3300,
            election_year=2016,
            office="H",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=3300,
            transfers_from_other_authorized_committee=3300,
            other_political_committee_contributions=3300,
            cash_on_hand_end_period=3300,
            debts_owed_by_committee=3300,
            state="NY",
            district="01",
            party="REP",
            state_full='New York'
        )
        factories.CandidateTotalFactory(
            candidate_id="HNY13",
            is_election=True,
            receipts=4000,
            disbursements=4000,
            election_year=2016,
            office="H",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=4000,
            transfers_from_other_authorized_committee=4000,
            other_political_committee_contributions=4000,
            cash_on_hand_end_period=4000,
            debts_owed_by_committee=4000,
            state="NY",
            district="13",
            party="REP",
            state_full='New York'
        )

        factories.CandidateTotalFactory(
            candidate_id="SCA01",
            is_election=True,  # candidate election year
            receipts=100,
            disbursements=100,
            election_year=2016,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=100,
            transfers_from_other_authorized_committee=100,
            other_political_committee_contributions=100,
            cash_on_hand_end_period=100,
            debts_owed_by_committee=100,
            state="CA",
            district="00",
            party="DEM",
            state_full='California'
        )
        factories.CandidateTotalFactory(
            candidate_id="SCA01",
            is_election=False,  # data for two-year period (not candidate election year)
            cycle=2012,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            receipts=200,
            disbursements=200,
            election_year=2016,
            office="S",
            candidate_inactive=True,  # is_active_candidate=False
            individual_itemized_contributions=200,
            transfers_from_other_authorized_committee=200,
            other_political_committee_contributions=200,
            cash_on_hand_end_period=200,
            debts_owed_by_committee=200,
            state="CA",
            district="00",
            party="DEM",
            state_full='California'
        )
        factories.CandidateTotalFactory(
            candidate_id="SNY01",
            is_election=False,  # data for two-year period (not candidate election year)
            cycle=2014,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            receipts=400,
            disbursements=400,
            election_year=2016,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=400,
            transfers_from_other_authorized_committee=400,
            other_political_committee_contributions=400,
            cash_on_hand_end_period=400,
            debts_owed_by_committee=400,
            state="NY",
            district="00",
            party="DEM",
            state_full='New York'
        )
        factories.CandidateTotalFactory(
            candidate_id="SNY01",
            is_election=False,  # data for two-year period (not candidate election year)
            cycle=2016,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            receipts=600,
            disbursements=600,
            election_year=2016,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=600,
            transfers_from_other_authorized_committee=600,
            other_political_committee_contributions=600,
            cash_on_hand_end_period=600,
            debts_owed_by_committee=600,
            state="NY",
            district="00",
            party="DEM",
            state_full='New York'
        )
        factories.CandidateTotalFactory(
            candidate_id="SNY01",
            is_election=True,  # data for two-year period (not candidate election year)
            cycle=2016,  # UNIQUE INDEX=elction_year,candidate_id,cycle,is_election
            receipts=1000,
            disbursements=1000,
            election_year=2016,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=1000,
            transfers_from_other_authorized_committee=1000,
            other_political_committee_contributions=1000,
            cash_on_hand_end_period=1000,
            debts_owed_by_committee=1000,
            state="NY",
            district="00",
            party="DEM",
            state_full='New York'
        )
        factories.CandidateTotalFactory(
            candidate_id="SVA02",  # not exist in election list
            is_election=True,  # candidate election year
            cycle=2010,
            receipts=700,
            disbursements=700,
            election_year=2010,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=700,
            transfers_from_other_authorized_committee=700,
            other_political_committee_contributions=700,
            cash_on_hand_end_period=700,
            debts_owed_by_committee=700,
            state="VA",
            district="00",
            party="REP",
            state_full='Virginia'
        )

        factories.CandidateTotalFactory(
            candidate_id="SCA03",
            is_election=True,  # candidate election year
            cycle=2016,
            receipts=800,
            disbursements=800,
            election_year=2018,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=800,
            transfers_from_other_authorized_committee=800,
            other_political_committee_contributions=800,
            cash_on_hand_end_period=800,
            debts_owed_by_committee=800,
            state="CA",
            district="00",
            party="REP",
            state_full='California'
        )

        factories.CandidateTotalFactory(
            candidate_id="SCA04",
            is_election=True,  # candidate election year
            cycle=2022,
            receipts=90,
            disbursements=90,
            election_year=2022,
            office="S",
            candidate_inactive=False,  # is_active_candidate=True
            individual_itemized_contributions=90,
            transfers_from_other_authorized_committee=90,
            other_political_committee_contributions=90,
            cash_on_hand_end_period=90,
            debts_owed_by_committee=90,
            state="CA",
            district="00",
            party="REP",
            state_full='California'
        )

    def test_base(self):
        # without any paramenter, group by election_year only
        # return  rows (election_year:  2016, 2022)
        results = self._results(api.url_for(
            CandidateTotalAggregateView, sort='-election_year')
        )
        assert len(results) == 2
        self.assertEqual(results[0]['election_year'], 2022)

    def test_aggregate_by_office(self):
        # aggregate_by=office, election_full default=true
        # group by election_year, office.
        # return  rows (2016/H, 2022/S, 2016/S)
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office",)
        )
        assert len(results) == 3

    def test_aggregate_by_office_state(self):
        # aggregate_by=office-state, is_active_candidate=True, election_year=2016, election_full default=true
        # group by election_year, office, state.
        # return  rows (2016/H/CA, 2016/H/NY, 2016/S/CA, 2016/S/NY)
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office-state",
            is_active_candidate=True,
            election_year=2016,)
        )
        assert len(results) == 4

    def test_aggregate_by_office_state_district(self):
        # aggregate_by=office-state-district, is_active_candidate=True, election_year=2016, election_full default=true
        # group by election_year, office, state, district.
        # return  rows (2016/H/CA/01, 2016/H/CA/02, 2016/H/NY/01, 2016/S/CA/00, 2016/S/NY/00)
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office-state-district",
            is_active_candidate=True,
            election_year=2016,)
        )
        assert len(results) == 5

    def test_aggregate_by_office_party(self):
        # aggregate_by=office-party, is_active_candidate=True, election_year=2016, election_full default=true
        # group by election_year, office, party.
        # return  rows (2016/H/DEM, 2016/H/REP, 2016/S/DEM,)
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office-party",
            is_active_candidate=True,
            election_year=2016,)
        )
        assert len(results) == 3

    def test_filter_by_office(self):
        # aggregate_by=office, office=H, is_active_candidate=True, election_full default=true
        # return rows: (2016/H,)
        # row: 2016/H/total=1000+2000+3300=6300.
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office",
            is_active_candidate=True,
            office="H",)
        )
        assert len(results) == 1
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "office": "H",
                "total_receipts": 6300,
                "total_disbursements": 6300,
                "total_individual_itemized_contributions": 6300,
                "total_transfers_from_other_authorized_committee": 6300,
                "total_other_political_committee_contributions": 6300,
                "total_cash_on_hand_end_period": 6300,
                "total_debts_owed_by_committee": 6300,
            },
        )

        # aggregate_by="office-state", office=S, is_active_candidate=True, election_full default=true
        # return rows: (2022/S/CA, 2016/S/CA, 2016/S/NY)
        # row 1: 2022/total=90
        # row 2: 2016/total=100
        # row 3: 2016/total=1000
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office-state",
            office="S",
            is_active_candidate=True,)
        )
        assert len(results) == 3
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2022,
                "office": "S",
                "state": "CA",
                "state_full": "California",
                "total_receipts": 90,
                "total_disbursements": 90,
                "total_individual_itemized_contributions": 90,
                "total_transfers_from_other_authorized_committee": 90,
                "total_other_political_committee_contributions": 90,
                "total_cash_on_hand_end_period": 90,
                "total_debts_owed_by_committee": 90,
            },
        )
        assert_dicts_subset(
            results[1],
            {
                "election_year": 2016,
                "office": "S",
                "state": "CA",
                "total_receipts": 100,
                "state_full": "California",
                "total_disbursements": 100,
                "total_individual_itemized_contributions": 100,
                "total_transfers_from_other_authorized_committee": 100,
                "total_other_political_committee_contributions": 100,
                "total_cash_on_hand_end_period": 100,
                "total_debts_owed_by_committee": 100,
            },
        )
        assert_dicts_subset(
            results[2],
            {
                "election_year": 2016,
                "office": "S",
                "state": "NY",
                "state_full": "New York",
                "total_receipts": 1000,
                "total_disbursements": 1000,
                "total_individual_itemized_contributions": 1000,
                "total_transfers_from_other_authorized_committee": 1000,
                "total_other_political_committee_contributions": 1000,
                "total_cash_on_hand_end_period": 1000,
                "total_debts_owed_by_committee": 1000,
            },
        )

        # aggregate_by="office-party", election_full default=true, office=H,
        # is_active_candidate=True, election_year=2016
        # return two rows:
        # row 1: 2016/H/DEM/1000+2000=3000
        # row 2: 2016/H/REP/total=3300
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office-party",
            office='H',
            is_active_candidate=True,
            election_year=2016,
            sort='party')
        )
        assert len(results) == 2
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "total_receipts": 3000,
                "total_disbursements": 3000,
                "total_individual_itemized_contributions": 3000,
                "total_transfers_from_other_authorized_committee": 3000,
                "total_other_political_committee_contributions": 3000,
                "total_cash_on_hand_end_period": 3000,
                "total_debts_owed_by_committee": 3000,
                "party": "DEM",
                "office": "H",
            },
        )
        assert_dicts_subset(
            results[1],
            {
                "election_year": 2016,
                "total_receipts": 3300,
                "total_disbursements": 3300,
                "total_individual_itemized_contributions": 3300,
                "total_transfers_from_other_authorized_committee": 3300,
                "total_other_political_committee_contributions": 3300,
                "total_cash_on_hand_end_period": 3300,
                "total_debts_owed_by_committee": 3300,
                "party": "REP",
                "office": "H",
            },
        )

    def test_filter_by_election_year(self):
        # aggregate_by=office, office=S, election_full default=true, election_year=2016
        # return one rows:
        # row 1: 2016/CA+NY/total=100+1000=1100
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office",
            office="S",
            is_active_candidate=True,
            election_year=2016,)
        )
        assert len(results) == 1
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "office": "S",
                "total_receipts": 1100,
                "total_disbursements": 1100,
                "total_individual_itemized_contributions": 1100,
                "total_transfers_from_other_authorized_committee": 1100,
                "total_other_political_committee_contributions": 1100,
                "total_cash_on_hand_end_period": 1100,
                "total_debts_owed_by_committee": 1100,
            },
        )

    def test_filter_by_is_active_candidate(self):
        # aggregate_by=office, office=S, election_full=true, is_active_candidate=false
        # return 0 rows:
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office",
            office="S",
            is_active_candidate=False,
            election_full=True,)
        )
        assert len(results) == 0

        # aggregate_by=office, office=S, election_full=false, is_active_candidate=false
        # return one row: 2016/total=200
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office",
            office="S",
            election_full=False,  # =is_eleciton
            is_active_candidate=False,)
        )
        assert len(results) == 1
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "total_receipts": 200,
                "total_disbursements": 200,
                "total_individual_itemized_contributions": 200,
                "total_transfers_from_other_authorized_committee": 200,
                "total_other_political_committee_contributions": 200,
                "total_cash_on_hand_end_period": 200,
                "total_debts_owed_by_committee": 200,
            },
        )

    def test_sort_by_election_year(self):
        # aggregate_by=office, office=H, election_full=true, is_active_candidate=true
        # return rows:
        # row 1: 2016/total=6300
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office",
            office="H",
            election_full=True,  # =is_eleciton
            is_active_candidate=True,)
        )
        assert len(results) == 1
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "total_receipts": 6300,
                "total_disbursements": 6300,
                "total_individual_itemized_contributions": 6300,
                "total_transfers_from_other_authorized_committee": 6300,
                "total_other_political_committee_contributions": 6300,
                "total_cash_on_hand_end_period": 6300,
                "total_debts_owed_by_committee": 6300,
            },
        )

    def test_sort_by_state_full(self):
        # aggregate_by="office-state", office=S, is_active_candidate=True, election_full default=true
        # return rows: (2016/S/NY, 2016/S/CA, 2022/S/CA)
        # row 1: 2016/total=1000
        # row 2: 2016/total=100
        # row 3: 2022/total=90

        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office-state",
            office="S",
            is_active_candidate=True,
            sort="-state_full")
        )
        assert len(results) == 3
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "office": "S",
                "state": "NY",
                "state_full": "New York",
                "total_receipts": 1000,
                "total_disbursements": 1000,
                "total_individual_itemized_contributions": 1000,
                "total_transfers_from_other_authorized_committee": 1000,
                "total_other_political_committee_contributions": 1000,
                "total_cash_on_hand_end_period": 1000,
                "total_debts_owed_by_committee": 1000,

            },
        )
        assert_dicts_subset(
            results[1],
            {
                "election_year": 2016,
                "office": "S",
                "state": "CA",
                "state_full": "California",
                "total_receipts": 100,
                "total_disbursements": 100,
                "total_individual_itemized_contributions": 100,
                "total_transfers_from_other_authorized_committee": 100,
                "total_other_political_committee_contributions": 100,
                "total_cash_on_hand_end_period": 100,
                "total_debts_owed_by_committee": 100,
            },
        )
        assert_dicts_subset(
            results[2],
            {
                "election_year": 2022,
                "office": "S",
                "state": "CA",
                "state_full": "California",
                "total_receipts": 90,
                "total_disbursements": 90,
                "total_individual_itemized_contributions": 90,
                "total_transfers_from_other_authorized_committee": 90,
                "total_other_political_committee_contributions": 90,
                "total_cash_on_hand_end_period": 90,
                "total_debts_owed_by_committee": 90,

            },
        )

    def test_filter_by_min_max_election_cycle(self):
        # case1: aggregate_by=office, office=S, election_full default=true,
        # is_active_candidate=true, min_election_cycle=2016
        # return two rows:
        # row 1: 2022
        # row 2: 2016
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office",
            office="S",
            is_active_candidate=True,
            min_election_cycle=2016,)
        )
        assert len(results) == 2

        # case2: aggregate_by=office, office=S, election_full default =true,
        # is_active_candidate=true,max_election_cycle=2016
        # return rows:
        # row 1: 2016

        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office",
            office="S",
            is_active_candidate=True,
            max_election_cycle=2016,)
        )
        assert len(results) == 1
        # case3: aggregate_by=office ,office=S, election_full default=true,
        # is_active_candidate=true,min_election_cycle=2010,max_election_cycle=2022
        # return two rows:
        # row 1: 2022
        # row 2: 2016

        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office",
            office="S",
            is_active_candidate=True,
            min_election_cycle=2010,
            max_election_cycle=2022,)
        )
        assert len(results) == 2

    def test_filter_by_state(self):
        # aggregate_by=office-state, office=H, state=CA
        # election_full default=true, election_year=2016, is_active_candidate=True
        # return one row:
        # row 1: 2016/H/CA/1000+2000=3000
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office-state",
            office="H",
            is_active_candidate=True,
            election_year=2016,
            state="CA",)
        )
        assert len(results) == 1
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "office": "H",
                "total_receipts": 3000,
                "total_disbursements": 3000,
                "total_individual_itemized_contributions": 3000,
                "total_transfers_from_other_authorized_committee": 3000,
                "total_other_political_committee_contributions": 3000,
                "total_cash_on_hand_end_period": 3000,
                "total_debts_owed_by_committee": 3000,
                "state": "CA",
                "state_full": "California"
            },
        )

    def test_filter_by_district(self):
        # aggregate_by="office-state-district", office=H, state=CA,
        # election_full default=true, election_year=2016, is_active_candidate=True
        # return one rows:
        # row 1: 2016/H/CA/01
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office-state-district",
            office="H",
            is_active_candidate=True,
            election_year=2016,
            state="CA",
            district="01",)
        )
        assert len(results) == 1
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "total_receipts": 1000,
                "total_disbursements": 1000,
                "total_individual_itemized_contributions": 1000,
                "total_transfers_from_other_authorized_committee": 1000,
                "total_other_political_committee_contributions": 1000,
                "total_cash_on_hand_end_period": 1000,
                "total_debts_owed_by_committee": 1000,
                "state": "CA",
                "district": "01",
                "state_full": "California",
            },
        )

    def test_filter_by_party(self):
        # aggregate_by="office-party", office=H, party=DEM,
        # election_full default=true, election_year=2016, is_active_candidate=True
        # return one rows:
        # row 1: 2016/H/DEM/total=1000+2000=3000
        results = self._results(api.url_for(
            CandidateTotalAggregateView,
            aggregate_by="office-party",
            office="H",
            is_active_candidate=True,
            election_year=2016,
            party="DEM",)
        )
        assert len(results) == 1
        assert_dicts_subset(
            results[0],
            {
                "election_year": 2016,
                "total_receipts": 3000,
                "total_disbursements": 3000,
                "total_individual_itemized_contributions": 3000,
                "total_transfers_from_other_authorized_committee": 3000,
                "total_other_political_committee_contributions": 3000,
                "total_cash_on_hand_end_period": 3000,
                "total_debts_owed_by_committee": 3000,
                "party": "DEM",
                "office": "H",
            },
        )
