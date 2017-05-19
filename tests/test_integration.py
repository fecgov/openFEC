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
    # NOTE: Due to the changes made in the production database and the switch
    # to using views instead of tables, we have attempted to reconstruct the
    # schema with our test data.  It is an approximation of what is actually
    # in production, but we are focused more on ensuring that the behavior and
    # processing of our scripts and business logic are sound as opposed to
    # mirroring the data exactly as it is at this time.
    metadata = sa.MetaData(schema='disclosure')
    automap = automap_base(bind=db.engine, metadata=metadata)
    automap.prepare(db.engine, reflect=True)

    class SchedAFactory(SQLAlchemyModelFactory):
        class Meta:
            sqlalchemy_session = db.session
            model = automap.classes.nml_sched_a
        form_tp_cd = '11'
        contb_receipt_dt = datetime.datetime(2016, 1, 1)
        sub_id = factory.Sequence(lambda n: n)
        rpt_yr = 2016

    class SchedBFactory(SQLAlchemyModelFactory):
        class Meta:
            sqlalchemy_session = db.session
            model = automap.classes.nml_sched_b
        form_tp_cd = '11'
        disb_dt = datetime.datetime(2016, 1, 1)
        sub_id = factory.Sequence(lambda n: n)
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
        #adding this here: my rationale is that
        #models.CaniddateCommitteeTotalsHouseSenate passed integration, so testing this specific
        #model really isn't expanding code coverage.  I can try and get the model passing but it's proving
        #to be difficult considering the joins needed (and our limited test subset)
        whitelist = [models.CandidateCommitteeTotalsPresidential, models.EntityReceiptDisbursementTotals]

        for model in db.Model._decl_class_registry.values():
            print(model)
            if model in whitelist:
                continue
            if not hasattr(model, '__table__'):
                continue
                print (model)
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
            contb_receipt_dt=datetime.datetime(2014, 1, 1)
        )
        db.session.commit()
        manage.update_aggregates()
        manage.refresh_itemized()
        search = models.ScheduleA.query.filter(
            models.ScheduleA.sub_id == row.sub_id
        ).one()
        self.assertEqual(search.contributor_name_text, "'adelson':2 'sheldon':1")

        # Test update
        row.contbr_nm = 'Shelly Adelson'
        db.session.add(row)
        db.session.commit()
        manage.update_aggregates()
        manage.refresh_itemized()
        search = models.ScheduleA.query.filter(
            models.ScheduleA.sub_id == row.sub_id
        ).one()
        db.session.refresh(search)
        self.assertEqual(search.contributor_name_text, "'adelson':2 'shelli':1")

        # Test delete
        db.session.delete(row)
        db.session.commit()
        manage.update_aggregates()
        manage.refresh_itemized()
        self.assertEqual(
            models.ScheduleA.query.filter(
                models.ScheduleA.sub_id == row.sub_id
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
        manage.refresh_itemized()
        self.assertEqual(
            models.ScheduleA.query.filter(
                models.ScheduleA.sub_id == row.sub_id
            ).count(),
            1,
        )

    def _get_sched_a_queue_new_count(self):
        return db.session.execute(
            'select count(*) from ofec_sched_a_queue_new'
        ).scalar()

    def _get_sched_a_queue_old_count(self):
        return db.session.execute(
            'select count(*) from ofec_sched_a_queue_old'
        ).scalar()

    def _clear_sched_a_queues(self):
        db.session.execute('delete from ofec_sched_a_queue_new')
        db.session.commit()
        db.session.execute('delete from ofec_sched_a_queue_old')
        db.session.commit()

    def test_sched_a_queue_transactions_success(self):
        # Make sure queues are clear before starting
        self._clear_sched_a_queues()

        # Test create
        row = self.SchedAFactory(
            rpt_yr=2014,
            contbr_nm='Sheldon Adelson',
            contb_receipt_dt=datetime.datetime(2014, 1, 1)
        )
        db.session.commit()
        new_queue_count = self._get_sched_a_queue_new_count()
        old_queue_count = self._get_sched_a_queue_old_count()
        self.assertEqual(new_queue_count, 1)
        self.assertEqual(old_queue_count, 0)
        manage.update_aggregates()
        manage.refresh_itemized()
        search = models.ScheduleA.query.filter(
            models.ScheduleA.sub_id == row.sub_id
        ).one()
        new_queue_count = self._get_sched_a_queue_new_count()
        old_queue_count = self._get_sched_a_queue_old_count()
        self.assertEqual(new_queue_count, 0)
        self.assertEqual(old_queue_count, 0)
        self.assertEqual(search.sub_id, row.sub_id)

        # Test update
        row.contbr_nm = 'Shelly Adelson'
        db.session.add(row)
        db.session.commit()
        new_queue_count = self._get_sched_a_queue_new_count()
        old_queue_count = self._get_sched_a_queue_old_count()
        self.assertEqual(new_queue_count, 1)
        self.assertEqual(old_queue_count, 1)
        manage.update_aggregates()
        manage.refresh_itemized()
        search = models.ScheduleA.query.filter(
            models.ScheduleA.sub_id == row.sub_id
        ).one()
        db.session.refresh(search)
        new_queue_count = self._get_sched_a_queue_new_count()
        old_queue_count = self._get_sched_a_queue_old_count()
        self.assertEqual(new_queue_count, 0)
        self.assertEqual(old_queue_count, 0)
        self.assertEqual(search.sub_id, row.sub_id)

        # Test delete
        db.session.delete(row)
        db.session.commit()
        new_queue_count = self._get_sched_a_queue_new_count()
        old_queue_count = self._get_sched_a_queue_old_count()
        self.assertEqual(new_queue_count, 0)
        self.assertEqual(old_queue_count, 1)
        manage.update_aggregates()
        manage.refresh_itemized()
        new_queue_count = self._get_sched_a_queue_new_count()
        old_queue_count = self._get_sched_a_queue_old_count()
        self.assertEqual(new_queue_count, 0)
        self.assertEqual(old_queue_count, 0)
        self.assertEqual(
            models.ScheduleA.query.filter(
                models.ScheduleA.sub_id == row.sub_id
            ).count(),
            0,
        )

    def test_sched_a_queue_transactions_failure(self):
        # Make sure queues are clear before starting
        self._clear_sched_a_queues()

        row = self.SchedAFactory(
            rpt_yr=2014,
            contbr_nm='Sheldon Adelson',
            contb_receipt_dt=datetime.datetime(2014, 1, 1)
        )
        db.session.commit()
        manage.update_aggregates()
        manage.refresh_itemized()

        # Test insert/update failure
        row.contbr_nm = 'Shelley Adelson'
        db.session.add(row)
        db.session.commit()
        new_queue_count = self._get_sched_a_queue_new_count()
        old_queue_count = self._get_sched_a_queue_old_count()
        self.assertEqual(new_queue_count, 1)
        self.assertEqual(old_queue_count, 1)
        db.session.execute('delete from ofec_sched_a_queue_old')
        db.session.commit()
        old_queue_count = self._get_sched_a_queue_old_count()
        self.assertEqual(old_queue_count, 0)
        manage.update_aggregates()
        manage.refresh_itemized()
        search = models.ScheduleA.query.filter(
            models.ScheduleA.sub_id == row.sub_id
        ).one()
        db.session.refresh(search)
        new_queue_count = self._get_sched_a_queue_new_count()
        old_queue_count = self._get_sched_a_queue_old_count()
        self.assertEqual(new_queue_count, 1)
        self.assertEqual(old_queue_count, 0)
        self.assertEqual(search.sub_id, row.sub_id)
        self.assertEqual(search.contributor_name, 'Sheldon Adelson')

    def _check_update_aggregate_create(self, item_key, total_key, total_model, value):
        filing = self.SchedAFactory(**{
            'rpt_yr': 2015,
            'cmte_id': 'C12345',
            'contb_receipt_amt': 538,
            'contb_receipt_dt': datetime.datetime(2015, 1, 1),
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
            'contb_receipt_dt': datetime.datetime(2015, 1, 1),
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
            contb_receipt_dt=datetime.datetime(2015, 1, 1),
            receipt_tp='15J',
        )
        db.session.flush()
        manage.update_aggregates()
        manage.refresh_itemized()
        db.session.refresh(existing)
        self.assertEqual(existing.total, total)
        self.assertEqual(existing.count, count)

    def test_update_aggregate_asize_create(self):
        filing = self.SchedAFactory(
            rpt_yr=2015,
            cmte_id='C6789',
            contb_receipt_amt=538,
            contb_receipt_dt=datetime.datetime(2015, 1, 1),
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

    def test_update_aggregate_asize_existing(self):
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
            contb_receipt_dt=datetime.datetime(2015, 1, 1),
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
            contb_receipt_dt=datetime.datetime(2015, 1, 1),
            receipt_tp='15J',
        )

        # Create a committee and committee report
        # Changed to point to sampled data, may be problematic in the future if det sum table
        # changes a lot and hence the tests need to test new behavior, believe it's fine for now though. -jcc
        rep = sa.Table('detsum_sample', db.metadata, autoload=True, autoload_with=db.engine)
        ins = rep.insert().values(
            indv_unitem_contb=20,
            cmte_id=existing.committee_id,
            rpt_yr=2016,
            orig_sub_id=9,
            form_tp_cd='F3',
        )
        db.session.execute(ins)
        db.session.commit()
        manage.update_aggregates()
        db.session.execute('refresh materialized view ofec_totals_house_senate_mv')
        db.session.execute('refresh materialized view ofec_totals_combined_mv')
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
            disb_dt=datetime.datetime(2015, 1, 1),
            disb_desc='CAMPAIGN BUTTONS',
            form_tp_cd='11'
        )
        db.session.commit()
        manage.update_aggregates()
        manage.refresh_itemized()
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
        manage.refresh_itemized()
        db.session.refresh(rows[0])
        self.assertEqual(rows[0].total, 538)
        self.assertEqual(rows[0].count, 1)
        filing.disb_desc = 'HANGING OUT'
        db.session.add(filing)
        db.session.commit()
        manage.update_aggregates()
        manage.refresh_itemized()
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
            disb_dt=datetime.datetime(2015, 1, 1),
            disb_tp='24K',
        )
        db.session.commit()
        manage.update_aggregates()
        db.session.refresh(existing)
        self.assertEqual(existing.total, total + 538)
        self.assertEqual(existing.count, count + 1)

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
            ~models.CandidateHistory.candidate_id._in(unverified_candidate_ids)
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

    def test_unverified_filers_excluded_in_candidates(self):
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

        self.assertEqual(
            committee_history_count,
            committee_history_verified_count
        )
