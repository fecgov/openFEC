import sqlalchemy as sa


import manage
from tests import common
from webservices.rest import db
from webservices.common import models


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


class TestViews(common.IntegrationTestCase):

    @classmethod
    def setUpClass(cls):
        super(TestViews, cls).setUpClass()
        manage.update_all(processes=1)

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
