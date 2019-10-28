from tests import factories
from tests.common import ApiBaseTest

from webservices.utils import get_current_cycle

from webservices import schemas
from webservices.rest import db, api
from webservices.resources.aggregates_by_committeeID import (
    # ScheduleAByEmployerByCommitteeIDView,
    ScheduleBByPurposeByCommitteeIDView,
    ScheduleAByStateByCommitteeIDView,
    ScheduleBByRecipientByCommitteeIDView,
    ScheduleBByRecipientIDByCommitteeIDView,
    ScheduleEByCandidateByCommitteeIDView,
)

class TestCommitteeAggregates(ApiBaseTest):
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
        ]
        results = self._results(
            api.url_for(
                ScheduleAByStateByCommitteeIDView,
                committee_id='C0001',
                cycle=2012
            )
        )
        assert len(results) == 1

        results = self._results(
            api.url_for(
                ScheduleAByStateByCommitteeIDView,
                committee_id='C0002',
                state='NY',
            )
        )
        assert len(results) == 1

        results = self._results(
            api.url_for(
                ScheduleAByStateByCommitteeIDView,
                committee_id='C0003',
                cycle=2018,
                state='OT',
            )
        )
        assert len(results) == 1

    def test_disbursement_purpose(self):
        committee = factories.CommitteeHistoryFactory(cycle=2012)

        aggregate = factories.ScheduleBByPurposeFactory(
            committee_id=committee.committee_id,
            cycle=committee.cycle,
            purpose='ADMINISTRATIVE EXPENSES'
        )
        results = self._results(
            api.url_for(
                ScheduleBByPurposeByCommitteeIDView,
                committee_id=committee.committee_id,
                cycle=2012,
                purpose='Administrative'
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
            recipient_name='STARBOARD STRATEGIES, INC.'
        )
        results = self._results(
            api.url_for(
                ScheduleBByRecipientByCommitteeIDView,
                committee_id=committee.committee_id,
                cycle=2012,
                recipient_name='Starboard Strategies'
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
            memo_count=1
        )
        results = self._results(
            api.url_for(
                ScheduleBByRecipientIDByCommitteeIDView,
                committee_id=committee.committee_id,
                cycle=2012,
                recipient_id='C00507368'
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
            ScheduleEByCandidateByCommitteeIDView,
            schemas.ScheduleEByCandidateSchema,
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
                    election_full=False,
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
                    committee_id=self.committee.committee_id,
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
            candidate_id=self.candidate_zero.candidate_id,
            election_years=[2018],
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
