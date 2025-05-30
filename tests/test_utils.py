import pytest
import sqlalchemy as sa

from unittest import TestCase
from flask import request
from webargs import flaskparser

from tests import factories
from tests.common import ApiBaseTest

from webservices import args
from flask import current_app
from webservices import sorting
from webservices.resources import candidate_aggregates
from webservices.resources import elections
from webservices.common.models import db
from webservices import utils
from webservices.common import models


class TestSort(ApiBaseTest):
    def test_single_column(self):
        candidates = [
            factories.CandidateFactory(district='01'),
            factories.CandidateFactory(district='02'),
        ]
        query, columns = sorting.sort(
            sa.select(models.Candidate), 'district', model=models.Candidate
        )
        self.assertEqual(db.session.execute(query).unique().scalars().all(), candidates)

    def test_single_column_reverse(self):
        candidates = [
            factories.CandidateFactory(district='01'),
            factories.CandidateFactory(district='02'),
        ]
        query, columns = sorting.sort(
            sa.select(models.Candidate), '-district', model=models.Candidate
        )
        self.assertEqual(db.session.execute(query).unique().scalars().all(), candidates[::-1])

    def test_multi_column(self):
        audit = [
            factories.AuditCaseFactory(
                cycle=2012,
                committee_name='Boy',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2012,
                committee_name='Girl',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2012,
                committee_name='Ted',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2012,
                committee_name='Zoo',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2014,
                committee_name='Abc',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2014,
                committee_name='John',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2014,
                committee_name='Ted',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
        ]
        query, columns = sorting.multi_sort(
            sa.select(models.AuditCase), ['cycle', 'committee_name', ], model=models.AuditCase
        )
        self.assertEqual(db.session.execute(query).unique().scalars().all(), audit)

    def test_multi_column_reverse_first_column(self):
        audit = [
            factories.AuditCaseFactory(
                cycle=2012,
                committee_name='Zoo',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2012,
                committee_name='Ted',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2012,
                committee_name='Girl',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2012,
                committee_name='Abc',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2014,
                committee_name='Ted',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2014,
                committee_name='John',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
            factories.AuditCaseFactory(
                cycle=2014,
                committee_name='Abc',
                primary_category_id=-1,
                sub_category_id=-2,
                audit_case_id=1000,
            ),
        ]
        query, columns = sorting.multi_sort(
            sa.select(models.AuditCase),
            ['-cycle', 'committee_name', ],
            model=models.AuditCase,
        )
        self.assertEqual(db.session.execute(query).unique().scalars().all(), audit[::-1])

    def test_hide_null(self):
        candidates = [
            factories.CandidateFactory(district='01'),
            factories.CandidateFactory(district='02'),
            factories.CandidateFactory(),
        ]
        query, columns = sorting.sort(
            sa.select(models.Candidate), 'district', model=models.Candidate
        )
        self.assertEqual(db.session.execute(query).unique().scalars().all(), candidates)
        query, columns = sorting.sort(
            sa.select(models.Candidate), 'district', model=models.Candidate, hide_null=True
        )
        self.assertEqual(db.session.execute(query).unique().scalars().all(), candidates[:2])

    def test_hide_null_candidate_totals(self):
        candidates = [
            factories.CandidateFactory(candidate_id='C1234'),
            factories.CandidateFactory(candidate_id='C5678'),
        ]
        candidateHistory = [  # noqa
            factories.CandidateHistoryFutureFactory(
                candidate_id='C1234',
                two_year_period=2016,
                election_years=[2016],
                cycles=[2016],
                candidate_election_year=2016,
            ),
            factories.CandidateHistoryFutureFactory(
                candidate_id='C5678',
                two_year_period=2016,
                election_years=[2016],
                cycles=[2016],
                candidate_election_year=2016,
            ),
        ]
        candidateTotals = [  # noqa
            factories.CandidateTotalFactory(
                candidate_id='C1234', is_election=False, cycle=2016
            ),
            factories.CandidateTotalFactory(
                candidate_id='C5678',
                disbursements='9999.99',
                is_election=False,
                cycle=2016,
            ),
        ]
        candidateFlags = [  # noqa
            factories.CandidateFlagsFactory(candidate_id='C1234'),
            factories.CandidateFlagsFactory(candidate_id='C5678'),
        ]

        tcv = candidate_aggregates.TotalsCandidateView()
        query, columns = sorting.sort(
            tcv.build_query(election_full=False), 'disbursements', model=None
        )
        results = db.session.execute(query).all()
        self.assertEqual(len(results), len(candidates))
        query, columns = sorting.sort(
            tcv.build_query(election_full=False),
            'disbursements',
            model=None,
            hide_null=True,
        )
        results = db.session.execute(query).all()

        self.assertEqual(len(results), len(candidates) - 1)
        self.assertTrue(candidates[1].candidate_id in results[0])

    def test_hide_null_election(self):
        candidates = [
            factories.CandidateFactory(candidate_id='C1234'),
            factories.CandidateFactory(candidate_id='C5678'),
        ]
        cmteFacorty = [  # noqa
            factories.CommitteeDetailFactory(committee_id='H1234'),
            factories.CommitteeDetailFactory(committee_id='H5678'),
        ]
        db.session.flush()
        candidateHistory = [  # noqa
            factories.CandidateHistoryFactory(
                candidate_id='C1234',
                two_year_period=2016,
                state='MO',
                candidate_election_year=2016,
                candidate_inactive=False,
                district='01',
                office='S',
                election_years=[2016],
                cycles=[2016],
            ),
            factories.CandidateHistoryFactory(
                candidate_id='C5678',
                candidate_election_year=2016,
                two_year_period=2016,
                state='MO',
                election_years=[2016],
                cycles=[2016],
                candidate_inactive=False,
                district='02',
                office='S',
            ),
        ]
        candidateCmteLinks = [  # noqa
            factories.CandidateCommitteeLinkFactory(
                committee_id='H1234',
                candidate_id='C1234',
                fec_election_year=2016,
                committee_designation='P',
                election_yr_to_be_included=2016,
            ),
            factories.CandidateCommitteeLinkFactory(
                committee_id='H5678',
                candidate_id='C5678',
                fec_election_year=2016,
                committee_designation='P',
                election_yr_to_be_included=2016,
            ),
        ]
        cmteTotalsFactory = [  # noqa
            factories.CommitteeTotalsHouseSenateFactory(
                committee_id='H1234', cycle=2016
            ),
            factories.CommitteeTotalsHouseSenateFactory(
                committee_id='H1234', cycle=2016, disbursements='9999.99'
            ),
            factories.CommitteeTotalsHouseSenateFactory(
                committee_id='H5678', cycle=2016
            ),
        ]
        db.session.flush()

        electionView = elections.ElectionView()
        query, columns = sorting.sort(
            electionView.build_query(office='senate', cycle=2016, state='MO'),
            'total_disbursements',
            model=None,
        )
        results = db.session.execute(query).all()
        self.assertEqual(len(results), len(candidates))
        query, columns = sorting.sort(
            electionView.build_query(office='senate', cycle=2016, state='MO'),
            'total_disbursements',
            model=None,
            hide_null=True,
        )
        results = db.session.execute(query).all()
        # Taking this assert statement out because I believe, at least how the FEC interprets null (i.e. none) primary
        # committees for a candidate is that they have in fact raised/spent 0.0 dollars, this can be shown as true
        # using the Alabama special election as an example
        # self.assertEqual(len(query.all()), len(candidates) - 1)
        self.assertTrue(candidates[1].candidate_id in results[0])
        self.assertEqual(results[0].total_disbursements, 0.0)


class TestArgs(TestCase):
    def test_currency(self):
        if current_app.config['TESTING']:
            with current_app.test_request_context('?dollars=$24.50'):
                parsed = flaskparser.parser.parse({'dollars': args.Currency()}, request, location='query')
                self.assertEqual(parsed, {'dollars': 24.50})


class TestEnvVarSplit(TestCase):
    def test_env_var_split(self):
        test_cases = [
            "1.2.3.4, 5.6.7.8",
            "1.2.3.4,  5.6.7.8",
            "1.2.3.4,5.6.7.8",
            " 1.2.3.4,  5.6.7.8 ",
        ]
        expected = ["1.2.3.4", "5.6.7.8"]
        for test_case in test_cases:
            result = utils.split_env_var(test_case)
            self.assertEqual(result, expected)


class TestPercentages(TestCase):
    def test_get_percentage(self):
        test_cases = [
            ([3], [9], 33.33),
            ([2, 3], [10], 50.0),
            ([1, 2, 3], [10], 60.0),
            ([2], [5, 5], 20.0),
            ([0], [10], 0),
            ([0, 0, 0], [10], 0),
            # Unusual but should still calculate
            ([10], [5], 200.0),  # Over 100%
            ([-5], [10], -50.0),  # Negative numerator
            ([5], [-10], -50.0),  # Negative denominator
            ([-5], [-10], 50.0),  # Both negative
            ([1], [10000], .01),  # Under 1%
            # None == Unable to calculate
            # Divide by zero
            ([1, 2, 3], [0], None),
            # Null values
            ([None], [None], None),
            ([0], [None], None),
            ([None], [100], None),
            ([], [], None),
            ([1, None, 3], [10], None),
        ]
        for test_case in test_cases:
            numerators, denominators, expected = test_case
            result = utils.get_percentage(numerators, denominators)
            self.assertEqual(result, expected)

        # Developer forgets to put values in list
        with pytest.raises(TypeError):
            utils.get_percentage(5, 10)
