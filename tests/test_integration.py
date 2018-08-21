import datetime
import subprocess

import pytest

import sqlalchemy as sa

from jdbc_utils import to_jdbc_url
import manage
from tests import common, factories
from webservices import rest
from webservices.rest import db
from webservices.common import models
from webservices.common.models import ScheduleA

REPORTS_MODELS = [
    models.CommitteeReportsPacParty,
    models.CommitteeReportsPresidential,
    models.CommitteeReportsHouseSenate,
]

TOTALS_MODELS = [
    models.CommitteeTotalsPacParty,
    models.CommitteeTotalsPresidential,
    models.CommitteeTotalsHouseSenate,
]

class IntegrationTestCase(common.BaseTestCase):
    """Base test case for tests that depend on the test data subset.
    """

    @classmethod
    def setUpClass(cls):
        super(IntegrationTestCase, cls).setUpClass()
        reset_schema()
        run_migrations()
        manage.refresh_materialized(concurrent=False)

    def test_committee_year_filter(self):
        self._check_entity_model(models.Committee, 'committee_id')
        self._check_entity_model(models.CommitteeDetail, 'committee_id')

    def test_candidate_year_filter(self):
        self._check_entity_model(models.Candidate, 'candidate_id')
        self._check_entity_model(models.CandidateDetail, 'candidate_id')

    def test_reports_year_filter(self):
        for model in REPORTS_MODELS:
            self._check_financial_model(model)

    def test_totals_year_filter(self):
        for model in TOTALS_MODELS:
            self._check_financial_model(model)

    def _check_financial_model(self, model):
        count = model.query.filter(
            model.cycle < manage.SQL_CONFIG['START_YEAR']
        ).count()
        self.assertEqual(count, 0)

    def _check_entity_model(self, model, key):
        subquery = model.query.with_entities(
            getattr(model, key),
            sa.func.unnest(model.cycles).label('cycle'),
        ).subquery()
        count = db.session.query(
            getattr(subquery.columns, key)
        ).group_by(
            getattr(subquery.columns, key)
        ).having(
            sa.func.max(subquery.columns.cycle) < manage.SQL_CONFIG['START_YEAR']
        ).count()
        self.assertEqual(count, 0)

    def test_committee_counts(self):
        counts = [
            models.Committee.query.count(),
            models.CommitteeDetail.query.count(),
            models.CommitteeHistory.query.distinct(models.CommitteeHistory.committee_id).count(),
            models.CommitteeSearch.query.count(),
        ]
        assert len(set(counts)) == 1

    def test_candidate_counts(self):
        counts = [
            models.Candidate.query.count(),
            models.CandidateDetail.query.count(),
            models.CandidateHistory.query.distinct(models.CandidateHistory.candidate_id).count(),
            models.CandidateSearch.query.count(),
        ]
        assert len(set(counts)) == 1

    def test_unverified_filers_excluded_in_candidates(self):
        candidate_history_count = models.CandidateHistory.query.count()

        unverified_candidates = models.UnverifiedFiler.query.filter(sa.or_(
            models.UnverifiedFiler.candidate_committee_id.like('H%'),
            models.UnverifiedFiler.candidate_committee_id.like('S%'),
            models.UnverifiedFiler.candidate_committee_id.like('P%')
        )).all()

        unverified_candidate_ids = [
            c.candidate_committee_id for c in unverified_candidates
        ]

        candidate_history_verified_count = models.CandidateHistory.query.filter(
            ~models.CandidateHistory.candidate_id.in_(unverified_candidate_ids)
        ).count()

        self.assertEqual(
            candidate_history_count,
            candidate_history_verified_count
        )

    def test_unverified_filers_excluded_in_committees(self):
        committee_history_count = models.CommitteeHistory.query.count()

        unverified_committees = models.UnverifiedFiler.query.filter(
            models.UnverifiedFiler.candidate_committee_id.like('C%')
        ).all()

        unverified_committees_ids = [
            c.candidate_committee_id for c in unverified_committees
        ]

        committee_history_verified_count = models.CommitteeHistory.query.filter(
            ~models.CommitteeHistory.committee_id.in_(unverified_committees_ids)
        ).count()

        self.assertEqual(committee_history_count, committee_history_verified_count)

    @pytest.mark.filterwarnings("ignore:Skipped unsupported reflection")
    def test_last_day_of_month(self):
        connection = db.engine.connect()
        fixtures = [
            (datetime.datetime(1999, 3, 21, 10, 20, 30), datetime.datetime(1999, 3, 31, 0, 0, 0)),
            (datetime.datetime(2007, 4, 21, 10, 20, 30), datetime.datetime(2007, 4, 30, 0, 0, 0)),
            (datetime.datetime(2017, 2, 21, 10, 20, 30), datetime.datetime(2017, 2, 28, 0, 0, 0)),
        ]
        for fixture in fixtures:
            test_value, expected = fixture
            returned_date = connection.execute("SELECT last_day_of_month(%s)", test_value).scalar()

            assert returned_date == expected

    def test_filter_individual_sched_a(self):
        individuals = [
            factories.ScheduleAFactory(receipt_type='15J', filing_form='F3X'),
            factories.ScheduleAFactory(line_number='12', contribution_receipt_amount=150, filing_form='F3X'),
        ]
        earmarks = [
            factories.ScheduleAFactory(filing_form='F3X'),
            factories.ScheduleAFactory(
                line_number='12',
                contribution_receipt_amount=150,
                memo_text='earmark',
                memo_code='X',
                filing_form='F3X'
            ),
        ]

        is_individual = sa.func.is_individual(
            ScheduleA.contribution_receipt_amount,
            ScheduleA.receipt_type,
            ScheduleA.line_number,
            ScheduleA.memo_code,
            ScheduleA.memo_text,
            ScheduleA.contributor_id,
            ScheduleA.committee_id,
        )

        rows = ScheduleA.query.all()
        self.assertEqual(rows, individuals + earmarks)

        rows = ScheduleA.query.filter(is_individual).all()
        self.assertEqual(rows, individuals)

def run_migrations():
    subprocess.check_call(
        ['flyway', 'migrate', '-n', '-url=%s' % get_test_jdbc_url(), '-locations=filesystem:data/migrations'],)

def reset_schema():
    for schema in [
        "aouser",
        "auditsearch",
        "disclosure",
        "fecapp",
        "fecmur",
        "public",
        "rad_pri_user",
        "real_efile",
        "real_pfile",
        "rohan",
        "staging",
    ]:
        rest.db.engine.execute('drop schema if exists %s cascade;' % schema)
    rest.db.engine.execute('create schema public;')

def get_test_jdbc_url():
    """
    Return the JDBC URL for TEST_CONN. If TEST_CONN cannot be successfully converted,
    it is probably the default Postgres instance with trust authentication
    """
    jdbc_url = to_jdbc_url(common.TEST_CONN)
    if jdbc_url is None:
        jdbc_url = "jdbc:" + common.TEST_CONN
    return jdbc_url
