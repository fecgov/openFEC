import datetime
import unittest

import sqlalchemy as sa

from smore import exceptions
from smore.apispec import utils

import manage
from tests import common
from tests import factories
from webservices import updates
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
        manage.update_all(processes=1)

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
        # Test create
        filing = models.ScheduleA(
            sched_a_sk=42,
            report_year=2014,
            contributor_name='Sheldon Adelson',
            load_date=datetime.datetime.now(),
            sub_id=7,
        )
        db.session.add(filing)
        db.session.commit()
        db.session.execute('select update_aggregates()')
        search = models.ScheduleASearch.query.filter(
            models.ScheduleASearch.sched_a_sk == 42
        ).one()
        self.assertEqual(search.contributor_name_text, "'adelson':2 'sheldon':1")

        # Test update
        filing.contributor_name = 'Shelly Adelson'
        db.session.commit()
        db.session.execute('select update_aggregates()')
        search = models.ScheduleASearch.query.filter(
            models.ScheduleASearch.sched_a_sk == 42
        ).one()
        self.assertEqual(search.contributor_name_text, "'adelson':2 'shelli':1")

        # Test delete
        db.session.delete(filing)
        db.session.commit()
        db.session.execute('select update_aggregates()')
        self.assertEqual(
            models.ScheduleASearch.query.filter(
                models.ScheduleASearch.sched_a_sk == 42
            ).count(),
            0,
        )

    def _check_update_aggregate_create(self, item_key, total_key, total_model, value):
        filing = factories.ScheduleAFactory(**{
            'report_year': 2015,
            'committee_id': 'C12345',
            'contributor_receipt_amount': 538,
            item_key: value,
        })
        db.session.flush()
        updates.update_all(conn=db.session.connection())
        db.session.execute('select update_aggregates()')
        rows = total_model.query.filter_by(**{
            'cycle': 2016,
            'committee_id': 'C12345',
            total_key: value,
        }).all()
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0].total, 538)
        self.assertEqual(rows[0].count, 1)
        filing.contributor_receipt_amount = 53
        db.session.add(filing)
        db.session.flush()
        updates.update_all(conn=db.session.connection())
        db.session.execute('select update_aggregates()')
        db.session.refresh(rows[0])
        self.assertEqual(rows[0].total, 53)
        self.assertEqual(rows[0].count, 1)

    def _check_update_aggregate_existing(self, item_key, total_key, total_model):
        existing = total_model.query.filter(
            total_model.cycle == 2016,
            getattr(total_model, total_key) != None,
        ).first()
        total = existing.total
        count = existing.count
        factories.ScheduleAFactory(**{
            'report_year': 2015,
            'committee_id': existing.committee_id,
            'contributor_receipt_amount': 538,
            item_key: getattr(existing, total_key),
        })
        db.session.flush()
        updates.update_all(conn=db.session.connection())
        db.session.execute('select update_aggregates()')
        db.session.refresh(existing)
        self.assertEqual(existing.total, total + 538)
        self.assertEqual(existing.count, count + 1)

    def test_update_aggregate_create(self):
        self._check_update_aggregate_create('contributor_zip', 'zip', models.ScheduleAByZip, '19041')
        self._check_update_aggregate_create('contributor_state', 'state', models.ScheduleAByState, 'PA')
        self._check_update_aggregate_create('contributor_employer', 'employer', models.ScheduleAByEmployer, 'PET CHOW')
        self._check_update_aggregate_create('contributor_occupation', 'occupation', models.ScheduleAByOccupation, 'FURRIER')

    def test_update_aggregate_existing(self):
        self._check_update_aggregate_existing('contributor_zip', 'zip', models.ScheduleAByZip)
        self._check_update_aggregate_existing('contributor_state', 'state', models.ScheduleAByState)
        self._check_update_aggregate_existing('contributor_employer', 'employer', models.ScheduleAByEmployer)
        self._check_update_aggregate_existing('contributor_occupation', 'occupation', models.ScheduleAByOccupation)

    def test_update_aggregate_state_existing_null_amount(self):
        existing = models.ScheduleAByState.query.filter_by(
            cycle=2016,
        ).first()
        total = existing.total
        count = existing.count
        factories.ScheduleAFactory(
            report_year=2015,
            committee_id=existing.committee_id,
            contributor_state=existing.state,
            contributor_receipt_amount=None,
        )
        db.session.flush()
        db.session.execute('select update_aggregates()')
        db.session.refresh(existing)
        self.assertEqual(existing.total, total)
        self.assertEqual(existing.count, count)

    def test_update_aggregate_size_create(self):
        filing = factories.ScheduleAFactory(
            report_year=2015,
            committee_id='C12345',
            contributor_receipt_amount=538,
        )
        db.session.flush()
        updates.update_all(conn=db.session.connection())
        db.session.execute('select update_aggregates()')
        db.session.execute('refresh materialized view ofec_sched_a_aggregate_size_merged_mv')
        rows = models.ScheduleABySize.query.filter_by(
            cycle=2016,
            committee_id='C12345',
            size=500,
        ).all()
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0].total, 538)
        self.assertEqual(rows[0].count, 1)
        filing.contributor_receipt_amount = 53
        db.session.add(filing)
        db.session.flush()
        updates.update_all(conn=db.session.connection())
        db.session.execute('select update_aggregates()')
        db.session.execute('refresh materialized view ofec_sched_a_aggregate_size_merged_mv')
        db.session.refresh(rows[0])
        self.assertEqual(rows[0].total, 0)
        self.assertEqual(rows[0].count, 0)

    def test_update_aggregate_size_existing(self):
        existing = models.ScheduleABySize.query.filter_by(
            size=500,
            cycle=2016,
        ).first()
        total = existing.total
        count = existing.count
        factories.ScheduleAFactory(
            report_year=2015,
            committee_id=existing.committee_id,
            contributor_receipt_amount=538,
        )
        db.session.flush()
        updates.update_all(conn=db.session.connection())
        db.session.execute('select update_aggregates()')
        db.session.execute('refresh materialized view ofec_sched_a_aggregate_size_merged_mv')
        db.session.refresh(existing)
        self.assertEqual(existing.total, total + 538)
        self.assertEqual(existing.count, count + 1)

    def test_update_aggregate_size_existing_merged(self):
        existing = models.ScheduleABySize.query.filter_by(
            size=0,
            cycle=2016,
        ).first()
        total = existing.total
        factories.ScheduleAFactory(
            report_year=2015,
            committee_id=existing.committee_id,
            contributor_receipt_amount=75,
        )
        # Create a committee and committee report
        dc = sa.Table('dimcmte', db.metadata, autoload=True, autoload_with=db.engine)
        ins = dc.insert().values(
            cmte_sk=7,
            cmte_id=existing.committee_id,
            load_date=datetime.datetime.now(),
        )
        db.session.execute(ins)
        rep = sa.Table('facthousesenate_f3', db.metadata, autoload=True, autoload_with=db.engine)
        ins = rep.insert().values(
            cmte_sk=7,
            indv_unitem_contb_per=20,
            facthousesenate_f3_sk=3,
            two_yr_period_sk=2016,
            load_date=datetime.datetime.now(),
        )
        db.session.execute(ins)
        db.session.flush()
        updates.update_all(conn=db.session.connection())
        db.session.execute('select update_aggregates()')
        db.session.execute('refresh materialized view ofec_totals_house_senate_mv')
        db.session.execute('refresh materialized view ofec_sched_a_aggregate_size_merged_mv')
        db.session.refresh(existing)
        # Updated total includes new Schedule A filing and new report
        self.assertEqual(existing.total, total + 75 + 20)
        self.assertEqual(existing.count, None)
