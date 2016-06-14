import datetime
import unittest

import sqlalchemy as sa
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm.session import make_transient

import factory
from factory.alchemy import SQLAlchemyModelFactory

from apispec import utils, exceptions

import manage
from tests import common
from webservices.rest import db
from webservices.spec import spec
from webservices.common import models


def make_factory():
    automap = automap_base()
    automap.prepare(db.engine, reflect=True)

    class SchedAFactory(SQLAlchemyModelFactory):
        class Meta:
            sqlalchemy_session = db.session
            model = automap.classes.sched_a
        load_date = datetime.datetime.utcnow()
        sched_a_sk = factory.Sequence(lambda n: n)
        sub_id = factory.Sequence(lambda n: n)
        rpt_yr = 2016

    class SchedBFactory(SQLAlchemyModelFactory):
        class Meta:
            sqlalchemy_session = db.session
            model = automap.classes.sched_b
        sched_b_sk = factory.Sequence(lambda n: n)
        load_date = datetime.datetime.utcnow()
        rpt_yr = 2016

    return SchedAFactory, SchedBFactory


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
        cls.SchedAFactory, cls.SchedBFactory = make_factory()
        manage.update_all(processes=1)

    def test_update_schemas(self):
        for model in db.Model._decl_class_registry.values():
            #Added this stupid print statement to see which models are empty
            print(model)
            if not hasattr(model, '__table__'):
                continue
            self.assertGreater(model.query.count(), 0)
    def test_refresh_materialized(self):
        db.session.execute('select refresh_materialized()')

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

    def test_sched_a_fulltext_trigger(self):
        # Test create
        row = self.SchedAFactory(
            rpt_yr=2014,
            contbr_nm='Sheldon Adelson',
            load_date=datetime.datetime.now(),
            sub_id=7,
        )
        db.session.commit()
        manage.update_aggregates()
        search = models.ScheduleA.query.filter(
            models.ScheduleA.sched_a_sk == row.sched_a_sk
        ).one()
        self.assertEqual(search.contributor_name_text, "'adelson':2 'sheldon':1")

        # Test update
        row.contbr_nm = 'Shelly Adelson'
        db.session.add(row)
        db.session.commit()
        manage.update_aggregates()
        search = models.ScheduleA.query.filter(
            models.ScheduleA.sched_a_sk == row.sched_a_sk
        ).one()
        db.session.refresh(search)
        self.assertEqual(search.contributor_name_text, "'adelson':2 'shelli':1")

        # Test delete
        db.session.delete(row)
        db.session.commit()
        manage.update_aggregates()
        self.assertEqual(
            models.ScheduleA.query.filter(
                models.ScheduleA.sched_a_sk == row.sched_a_sk
            ).count(),
            0,
        )

        # Test sequential writes
        make_transient(row)
        db.session.add(row)
        db.session.commit()

        db.session.delete(row)
        db.session.commit()

        make_transient(row)
        db.session.add(row)
        db.session.commit()
        manage.update_aggregates()
        self.assertEqual(
            models.ScheduleA.query.filter(
                models.ScheduleA.sched_a_sk == row.sched_a_sk
            ).count(),
            1,
        )

    def _check_update_aggregate_create(self, item_key, total_key, total_model, value):
        filing = self.SchedAFactory(**{
            'rpt_yr': 2015,
            'cmte_id': 'C12345',
            'contb_receipt_amt': 538,
            'receipt_tp': '15J',
            item_key: value,
        })
        db.session.commit()
        manage.update_aggregates()
        rows = total_model.query.filter_by(**{
            'cycle': 2016,
            'committee_id': 'C12345',
            total_key: value,
        }).all()
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0].total, 538)
        self.assertEqual(rows[0].count, 1)
        filing.contb_receipt_amt = 53
        db.session.add(filing)
        db.session.commit()
        manage.update_aggregates()
        db.session.refresh(rows[0])
        self.assertEqual(rows[0].total, 53)
        self.assertEqual(rows[0].count, 1)

    def _check_update_aggregate_existing(self, item_key, total_key, total_model):
        existing = total_model.query.filter(
            total_model.cycle == 2016,
            getattr(total_model, total_key) != None,  # noqa
        ).first()
        total = existing.total
        count = existing.count
        self.SchedAFactory(**{
            'rpt_yr': 2015,
            'cmte_id': existing.committee_id,
            'contb_receipt_amt': 538,
            'receipt_tp': '15J',
            item_key: getattr(existing, total_key),
        })
        db.session.commit()
        manage.update_aggregates()
        db.session.refresh(existing)
        self.assertEqual(existing.total, total + 538)
        self.assertEqual(existing.count, count + 1)

    def test_update_aggregate_create(self):
        self._check_update_aggregate_create('contbr_zip', 'zip', models.ScheduleAByZip, '19041')
        self._check_update_aggregate_create('contbr_st', 'state', models.ScheduleAByState, 'PA')
        self._check_update_aggregate_create('contbr_employer', 'employer', models.ScheduleAByEmployer, 'PET CHOW')
        self._check_update_aggregate_create('contbr_occupation', 'occupation', models.ScheduleAByOccupation, 'FURRIER')

    def test_update_aggregate_existing(self):
        self._check_update_aggregate_existing('contbr_zip', 'zip', models.ScheduleAByZip)
        self._check_update_aggregate_existing('contbr_st', 'state', models.ScheduleAByState)
        self._check_update_aggregate_existing('contbr_employer', 'employer', models.ScheduleAByEmployer)
        self._check_update_aggregate_existing('contbr_occupation', 'occupation', models.ScheduleAByOccupation)

    def test_update_aggregate_state_existing_null_amount(self):
        existing = models.ScheduleAByState.query.filter_by(
            cycle=2016,
        ).first()
        total = existing.total
        count = existing.count
        self.SchedAFactory(
            rpt_yr=2015,
            cmte_id=existing.committee_id,
            contbr_st=existing.state,
            contb_receipt_amt=None,
            receipt_tp='15J',
        )
        db.session.flush()
        manage.update_aggregates()
        db.session.refresh(existing)
        self.assertEqual(existing.total, total)
        self.assertEqual(existing.count, count)

    def test_update_aggregate_size_create(self):
        filing = self.SchedAFactory(
            rpt_yr=2015,
            cmte_id='C6789',
            contb_receipt_amt=538,
            receipt_tp='15J',
        )
        db.session.commit()
        manage.update_aggregates()
        db.session.execute('refresh materialized view ofec_sched_a_aggregate_size_merged_mv')
        rows = models.ScheduleABySize.query.filter_by(
            cycle=2016,
            committee_id='C6789',
            size=500,
        ).all()
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0].total, 538)
        self.assertEqual(rows[0].count, 1)
        filing.contb_receipt_amt = 53
        db.session.add(filing)
        db.session.commit()
        manage.update_aggregates()
        db.session.execute('refresh materialized view ofec_sched_a_aggregate_size_merged_mv')
        db.session.refresh(rows[0])
        self.assertEqual(rows[0].total, 0)
        self.assertEqual(rows[0].count, 0)

    def test_update_aggregate_size_existing(self):
        def get_existing():
            return models.ScheduleABySize.query.filter_by(
                size=500,
                cycle=2016,
            ).order_by(
                models.ScheduleABySize.committee_id,
            ).first()
        existing = get_existing()
        total = existing.total
        count = existing.count
        self.SchedAFactory(
            rpt_yr=2015,
            cmte_id=existing.committee_id,
            contb_receipt_amt=538,
            receipt_tp='15J',
        )
        db.session.commit()
        manage.update_aggregates()
        db.session.execute('refresh materialized view ofec_sched_a_aggregate_size_merged_mv')
        existing = get_existing()
        self.assertEqual(existing.total, total + 538)
        self.assertEqual(existing.count, count + 1)

    def test_update_aggregate_size_existing_merged(self):
        existing = models.ScheduleABySize.query.filter_by(
            size=0,
            cycle=2016,
        ).first()
        print(existing.committee_id)
        total = existing.total
        self.SchedAFactory(
            rpt_yr=2015,
            cmte_id=existing.committee_id,
            contb_receipt_amt=75,
            receipt_tp='15J',
        )

        # Create a committee and committee report
        rep = sa.Table('fec_vsum_f3', db.metadata, autoload=True, autoload_with=db.engine)
        ins = rep.insert().values(
            indv_unitem_contb_per=20,
            cmte_id=existing.committee_id,
            election_cycle=2016,
            sub_id=9,
            most_recent_filing_flag='Y'
        )
        db.session.execute(ins)
        db.session.commit()
        manage.update_aggregates()
        db.session.execute('refresh materialized view ofec_totals_house_senate_mv')
        db.session.execute('refresh materialized view ofec_sched_a_aggregate_size_merged_mv')
        db.session.refresh(existing)
        # Updated total includes new Schedule A filing and new report
        self.assertAlmostEqual(existing.total, total + 75 + 20)
        self.assertEqual(existing.count, None)

    def test_update_aggregate_purpose_create(self):
        filing = self.SchedBFactory(
            rpt_yr=2015,
            cmte_id='C12345',
            disb_amt=538,
            disb_desc='CAMPAIGN BUTTONS',
        )
        db.session.commit()
        manage.update_aggregates()
        rows = models.ScheduleBByPurpose.query.filter_by(
            cycle=2016,
            committee_id='C12345',
            purpose='MATERIALS',
        ).all()
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0].total, 538)
        self.assertEqual(rows[0].count, 1)
        filing.disbursement_description = 'BUMPER STICKERS'
        db.session.add(filing)
        db.session.commit()
        manage.update_aggregates()
        db.session.refresh(rows[0])
        self.assertEqual(rows[0].total, 538)
        self.assertEqual(rows[0].count, 1)
        filing.disb_desc = 'HANGING OUT'
        db.session.add(filing)
        db.session.commit()
        manage.update_aggregates()
        db.session.refresh(rows[0])
        self.assertEqual(rows[0].total, 0)
        self.assertEqual(rows[0].count, 0)

    def test_update_aggregate_purpose_existing(self):
        existing = models.ScheduleBByPurpose.query.filter_by(
            purpose='CONTRIBUTIONS',
            cycle=2016,
        ).first()
        total = existing.total
        count = existing.count
        self.SchedBFactory(
            rpt_yr=2015,
            cmte_id=existing.committee_id,
            disb_amt=538,
            disb_tp='24K',
        )
        db.session.commit()
        manage.update_aggregates()
        db.session.refresh(existing)
        self.assertEqual(existing.total, total + 538)
        self.assertEqual(existing.count, count + 1)
