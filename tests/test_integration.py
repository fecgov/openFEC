import datetime
import unittest

import sqlalchemy as sa

from smore import exceptions
from smore.apispec import utils

import manage
from tests import common
from webservices.rest import db
from webservices.spec import spec
from webservices.common import models
from webservices.config import SQL_CONFIG


CANDIDATE_MODELS = [
    models.Candidate,
    models.CandidateDetail,
    models.CandidateHistory,
]
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


class TestSwagger(unittest.TestCase):

    def test_swagger_valid(self):
        try:
            utils.validate_swagger(spec)
        except exceptions.SwaggerError as error:
            self.fail(str(error))


class TestViews(common.IntegrationTestCase):

    @classmethod
    def setUpClass(cls):
        super(TestViews, cls).setUpClass()
        manage.update_schemas(processes=1)
        manage.update_schedule_a()
        manage.update_schedule_b()

    def test_update_schemas(self):
        for model in db.Model._decl_class_registry.values():
            if not hasattr(model, '__table__'):
                continue
            self.assertGreater(model.query.count(), 0)

    def test_committee_year_filter(self):
        self._check_entity_model(models.Committee, 'committee_key')
        self._check_entity_model(models.CommitteeDetail, 'committee_key')

    def test_candidate_year_filter(self):
        self._check_entity_model(models.Candidate, 'candidate_key')
        self._check_entity_model(models.CandidateDetail, 'candidate_key')

    def test_reports_year_filter(self):
        for model in REPORTS_MODELS:
            self._check_financial_model(model)

    def test_totals_year_filter(self):
        for model in TOTALS_MODELS:
            self._check_financial_model(model)

    def test_keeps_only_non_expired_reports(self):
        for model in REPORTS_MODELS:
            with self.subTest(report_model=model):
                self.assertFalse(model.query.filter(model.expire_date != None).count())

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

    def test_exclude_z_only_filers(self):
        dcp = sa.Table('dimcandproperties', db.metadata, autoload=True, autoload_with=db.engine)
        s = sa.select([dcp.c.cand_sk]).where(dcp.c.form_tp != 'F2Z').distinct()
        expected = [int(each.cand_sk) for each in db.engine.execute(s).fetchall()]
        for model in CANDIDATE_MODELS:
            observed = [each.candidate_key for each in model.query.all()]
            self.assertFalse(set(observed).difference(expected))

    def test_sched_a_fulltext(self):
        self.assertEqual(
            models.ScheduleA.query.filter(
                models.ScheduleA.report_year >= SQL_CONFIG['START_YEAR_ITEMIZED']
            ).count(),
            models.ScheduleASearch.query.count(),
        )

    def test_sched_a_fulltext_trigger(self):
        filing = models.ScheduleA(
            sched_a_sk=42,
            report_year=2014,
            contributor_name='Sheldon Adelson',
            load_date=datetime.datetime.now(),
            sub_id=7,
        )
        db.session.add(filing)
        db.session.commit()
        search = models.ScheduleASearch.query.filter(
            models.ScheduleASearch.sched_a_sk == 42
        ).one()
        self.assertEqual(search.contributor_name_text, "'adelson':2 'sheldon':1")
        filing.contributor_name = 'Shelly Adelson'
        db.session.commit()
        search = models.ScheduleASearch.query.filter(
            models.ScheduleASearch.sched_a_sk == 42
        ).one()
        self.assertEqual(search.contributor_name_text, "'adelson':2 'shelli':1")
        db.session.delete(filing)
        db.session.commit()
        self.assertEqual(
            models.ScheduleASearch.query.filter(
                models.ScheduleASearch.sched_a_sk == 42
            ).count(),
            0,
        )
