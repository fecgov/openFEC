import datetime

import pytest

import sqlalchemy as sa
from tests import common, factories
from webservices.common import models
from webservices.common.models import ScheduleA, db
from webservices.config import SQL_CONFIG

REPORTS_MODELS = [
    models.CommitteeReportsPacParty,
    models.CommitteeReportsPresidential,
    models.CommitteeReportsHouseSenate,
]

TOTALS_MODELS = [
    models.CommitteeTotalsPacParty,
    models.CommitteeTotalsPerCycle,
    models.CommitteeTotalsHouseSenate,
]


@pytest.mark.usefixtures("migrate_db")
class IntegrationTestCase(common.BaseTestCase):
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
        query = sa.select(model).filter(model.cycle < SQL_CONFIG['START_YEAR'])

        count = db.session.scalar(sa.select(sa.func.count()).select_from(query.subquery()))

        self.assertEqual(count, 0)

    def _check_entity_model(self, model, key):
        subquery = sa.select(
            getattr(model, key), sa.func.unnest(model.cycles).label('cycle'),
        ).subquery()

        query = (
            sa.select(getattr(subquery.columns, key))
            .group_by(getattr(subquery.columns, key))
            .having(
                sa.func.max(subquery.columns.cycle) < SQL_CONFIG['START_YEAR']
            )
        )
        count = db.session.scalar(sa.select(sa.func.count()).select_from(query.subquery()))

        self.assertEqual(count, 0)

    def test_committee_counts(self):
        query = sa.select(models.CommitteeHistory).distinct(models.CommitteeHistory.committee_id)
        counts = [
            db.session.scalar(sa.select(sa.func.count()).select_from(models.Committee)),
            db.session.scalar(sa.select(sa.func.count()).select_from(models.CommitteeDetail)),
            db.session.scalar(sa.select(sa.func.count()).select_from(query.subquery())),
            db.session.scalar(sa.select(sa.func.count()).select_from(models.CommitteeSearch)),
        ]
        assert len(set(counts)) == 1

    def test_candidate_counts(self):
        query = sa.select(models.CandidateHistory).distinct(models.CandidateHistory.candidate_id)
        counts = [
            db.session.scalar(sa.select(sa.func.count()).select_from(models.Candidate)),
            db.session.scalar(sa.select(sa.func.count()).select_from(models.CandidateDetail)),
            db.session.scalar(sa.select(sa.func.count()).select_from(query.subquery())),
            db.session.scalar(sa.select(sa.func.count()).select_from(models.CandidateSearch)),
        ]
        assert len(set(counts)) == 1

    def test_unverified_filers_excluded_in_candidates(self):
        candidate_history_count = db.session.scalar(sa.select(sa.func.count()).select_from(models.CandidateHistory))

        query = sa.select(models.UnverifiedFiler).filter(
            sa.or_(
                models.UnverifiedFiler.candidate_committee_id.like('H%'),
                models.UnverifiedFiler.candidate_committee_id.like('S%'),
                models.UnverifiedFiler.candidate_committee_id.like('P%'),
            )
        )
        unverified_candidates = db.session.execute(query).scalars().all()
        unverified_candidate_ids = [
            c.candidate_committee_id for c in unverified_candidates
        ]

        query = sa.select(models.CandidateHistory).filter(
            ~models.CandidateHistory.candidate_id.in_(unverified_candidate_ids)
        )
        candidate_history_verified_count = db.session.scalar(sa.select(sa.func.count()).select_from(query.subquery()))

        self.assertEqual(candidate_history_count, candidate_history_verified_count)

    def test_unverified_filers_excluded_in_committees(self):
        committee_history_count = db.session.scalar(sa.select(sa.func.count()).select_from(models.CommitteeHistory))

        query = sa.select(models.UnverifiedFiler).filter(
            models.UnverifiedFiler.candidate_committee_id.like('C%')
        )

        unverified_committees = db.session.execute(query).scalars().all()
        unverified_committees_ids = [
            c.candidate_committee_id for c in unverified_committees
        ]

        query = sa.select(models.CommitteeHistory).filter(
            ~models.CommitteeHistory.committee_id.in_(unverified_committees_ids)
        )
        committee_history_verified_count = db.session.scalar(sa.select(sa.func.count()).select_from(query.subquery()))
        self.assertEqual(committee_history_count, committee_history_verified_count)

    def test_last_day_of_month(self):
        connection = db.engine.connect()
        fixtures = [
            (
                datetime.datetime(1999, 3, 21, 10, 20, 30),
                datetime.datetime(1999, 3, 31, 0, 0, 0),
            ),
            (
                datetime.datetime(2007, 4, 21, 10, 20, 30),
                datetime.datetime(2007, 4, 30, 0, 0, 0),
            ),
            (
                datetime.datetime(2017, 2, 21, 10, 20, 30),
                datetime.datetime(2017, 2, 28, 0, 0, 0),
            ),
        ]
        for fixture in fixtures:
            test_value, expected = fixture
            returned_date = connection.execute(
                sa.text("SELECT last_day_of_month(:test)"), {"test": test_value}
            ).scalar()

            assert returned_date == expected

    def test_filter_individual_sched_a(self):
        individuals = [
            factories.ScheduleAFactory(receipt_type='15J', filing_form='F3X'),
            factories.ScheduleAFactory(
                line_number='12', contribution_receipt_amount=150, filing_form='F3X'
            ),
        ]
        earmarks = [
            factories.ScheduleAFactory(filing_form='F3X'),
            factories.ScheduleAFactory(
                line_number='12',
                contribution_receipt_amount=150,
                memo_text='earmark',
                memo_code='X',
                filing_form='F3X',
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
        query = sa.select(ScheduleA)
        rows = db.session.execute(query).scalars().all()
        self.assertEqual(rows, individuals + earmarks)

        query = query.filter(is_individual)

        rows = db.session.execute(query).scalars().all()
        self.assertEqual(rows, individuals)
