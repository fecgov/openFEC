import datetime

import sqlalchemy as sa
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm.session import make_transient

from faker import Faker
import factory
from factory.alchemy import SQLAlchemyModelFactory

import manage
from manage import execute_sql_file
from tests import common
from webservices.rest import db
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

    class NmlSchedAFactory(SQLAlchemyModelFactory):
        class Meta:
            sqlalchemy_session = db.session
            model = automap.classes.nml_sched_a
        form_tp_cd = '11'
        contb_receipt_dt = datetime.datetime(2016, 1, 1)
        sub_id = factory.Sequence(lambda n: n)
        rpt_yr = 2016
        amndt_ind = 'A'

    class NmlSchedBFactory(SQLAlchemyModelFactory):
        class Meta:
            sqlalchemy_session = db.session
            model = automap.classes.nml_sched_b
        form_tp_cd = '11'
        disb_dt = datetime.datetime(2016, 1, 1)
        sub_id = factory.Sequence(lambda n: n)
        rpt_yr = 2016
        amndt_ind = 'A'

    class FItemReceiptOrExp(SQLAlchemyModelFactory):
        class Meta:
            sqlalchemy_session = db.session
            model = automap.classes.f_item_receipt_or_exp
        v_sum_link_id = factory.Sequence(lambda n: n)
        form_tp_cd = 'F3X'

    return NmlSchedAFactory, NmlSchedBFactory, FItemReceiptOrExp


class TestViews(common.IntegrationTestCase):

    @classmethod
    def setUpClass(cls):
        super(TestViews, cls).setUpClass()
        cls.NmlSchedAFactory, cls.NmlSchedBFactory, cls.FItemReceiptOrExp = make_factory()
        manage.update_all(processes=1)
        #manage.refresh_materialized()

    def test_sched_a_fulltext_trigger(self):
        # Test create
        nml_row = self.NmlSchedAFactory(
            rpt_yr=2014,
            contbr_nm='Sheldon Adelson',
            contb_receipt_dt=datetime.datetime(2014, 1, 1)
        )
        self.FItemReceiptOrExp(
            sub_id=nml_row.sub_id,
            rpt_yr=2014,
        )
        db.session.commit()
        search = models.ScheduleA.query.filter(
            models.ScheduleA.sub_id == nml_row.sub_id
        ).one()
        self.assertEqual(search.contributor_name_text, "'adelson':2 'sheldon':1")

        # Test update
        nml_row.contbr_nm = 'Shelly Adelson'
        db.session.add(nml_row)
        db.session.commit()
        search = models.ScheduleA.query.filter(
            models.ScheduleA.sub_id == nml_row.sub_id
        ).one()
        db.session.refresh(search)
        self.assertEqual(search.contributor_name_text, "'adelson':2 'shelli':1")

        # Test delete
        db.session.delete(nml_row)
        db.session.commit()
        self.assertEqual(
            models.ScheduleA.query.filter(
                models.ScheduleA.sub_id == nml_row.sub_id
            ).count(),
            0,
        )

        # Test sequential writes
        make_transient(nml_row)
        db.session.add(nml_row)
        db.session.commit()

        db.session.delete(nml_row)
        db.session.commit()

        make_transient(nml_row)
        db.session.add(nml_row)
        db.session.commit()
        self.assertEqual(
            models.ScheduleA.query.filter(
                models.ScheduleA.sub_id == nml_row.sub_id
            ).count(),
            1,
        )

    def _check_update_aggregate_create(self, item_key, total_key, total_model, value):
        filing = self.NmlSchedAFactory(**{
            'rpt_yr': 2015,
            'cmte_id': 'C12345',
            'contb_receipt_amt': 538,
            'contb_receipt_dt': datetime.datetime(2015, 1, 1),
            'receipt_tp': '15J',
            item_key: value,
        })
        self.FItemReceiptOrExp(
            sub_id=filing.sub_id,
            rpt_yr=2015,
        )
        db.session.commit()
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
        db.session.refresh(rows[0])
        self.assertEqual(rows[0].total, 53)
        self.assertEqual(rows[0].count, 1)

    def _check_update_aggregate_existing(self, item_key, total_key, total_model, item_key_value):
        filing = self.NmlSchedAFactory(**{
            'rpt_yr': 2015,
            'cmte_id': 'X1234',
            'contb_receipt_amt': 504,
            'contb_receipt_dt': datetime.datetime(2015, 1, 1),
            'receipt_tp': '15J',
            item_key: item_key_value
        })
        self.FItemReceiptOrExp(
            sub_id=filing.sub_id,
            rpt_yr=2015,
        )
        db.session.commit()
        existing = total_model.query.filter(
            total_model.cycle == 2016,
            getattr(total_model, total_key) == item_key_value,  # noqa
        ).first()
        total = existing.total
        count = existing.count
        filing = self.NmlSchedAFactory(**{
            'rpt_yr': 2015,
            'cmte_id': existing.committee_id,
            'contb_receipt_amt': 538,
            'contb_receipt_dt': datetime.datetime(2015, 1, 1),
            'receipt_tp': '15J',
            item_key: item_key_value
        })
        self.FItemReceiptOrExp(
            sub_id=filing.sub_id,
            rpt_yr=2015,
        )
        db.session.commit()
        db.session.refresh(existing)
        self.assertEqual(existing.total, total + 538)
        self.assertEqual(existing.count, count + 1)

    def test_update_aggregate_create(self):
        self._check_update_aggregate_create('contbr_zip', 'zip', models.ScheduleAByZip, '19041')
        self._check_update_aggregate_create('contbr_st', 'state', models.ScheduleAByState, 'PA')
        self._check_update_aggregate_create('contbr_employer', 'employer', models.ScheduleAByEmployer, 'PET CHOW')
        self._check_update_aggregate_create('contbr_occupation', 'occupation', models.ScheduleAByOccupation, 'FURRIER')

    def test_update_aggregate_existing(self):
        faker = Faker()
        self._check_update_aggregate_existing('contbr_zip', 'zip', models.ScheduleAByZip, faker.zipcode())
        self._check_update_aggregate_existing('contbr_st', 'state', models.ScheduleAByState, faker.state_abbr())
        self._check_update_aggregate_existing(
            'contbr_employer', 'employer', models.ScheduleAByEmployer, faker.company()[:38])
        self._check_update_aggregate_existing(
            'contbr_occupation', 'occupation', models.ScheduleAByOccupation, faker.job()[:38])

    def test_update_aggregate_state_existing_null_amount(self):
        existing = models.ScheduleAByState.query.filter_by(
            cycle=2016,
        ).first()
        total = existing.total
        count = existing.count
        self.NmlSchedAFactory(
            rpt_yr=2015,
            cmte_id=existing.committee_id,
            contbr_st=existing.state,
            contb_receipt_amt=None,
            contb_receipt_dt=datetime.datetime(2015, 1, 1),
            receipt_tp='15J',
        )
        db.session.flush()
        db.session.refresh(existing)
        self.assertEqual(existing.total, total)
        self.assertEqual(existing.count, count)

    def test_update_aggregate_asize_create(self):
        filing = self.NmlSchedAFactory(
            rpt_yr=2015,
            cmte_id='C6789',
            contb_receipt_amt=538,
            contb_receipt_dt=datetime.datetime(2015, 1, 1),
            receipt_tp='15J',
        )
        self.FItemReceiptOrExp(
            sub_id=filing.sub_id,
            rpt_yr=2015,
        )
        db.session.commit()
        _rebuild_sched_a_by_size_merged()
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
        _rebuild_sched_a_by_size_merged()
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
        EXISTING_RECEIPT_AMOUNT = 504
        filing = self.NmlSchedAFactory(
            rpt_yr=2015,
            cmte_id='X1234',
            contb_receipt_amt=EXISTING_RECEIPT_AMOUNT,
            contb_receipt_dt=datetime.datetime(2015, 1, 1),
            receipt_tp='15J',
        )
        self.FItemReceiptOrExp(
            sub_id=filing.sub_id,
            rpt_yr=2015,
        )
        db.session.commit()
        _rebuild_sched_a_by_size_merged()
        existing = get_existing()
        total = existing.total
        count = existing.count
        NEW_RECEIPT_AMOUNT = 538
        filing = self.NmlSchedAFactory(
            rpt_yr=2015,
            cmte_id=existing.committee_id,
            contb_receipt_amt=NEW_RECEIPT_AMOUNT,
            contb_receipt_dt=datetime.datetime(2015, 1, 1),
            receipt_tp='15J',
        )
        self.FItemReceiptOrExp(
            sub_id=filing.sub_id,
            rpt_yr=2015,
        )
        db.session.commit()
        _rebuild_sched_a_by_size_merged()
        existing = get_existing()
        self.assertEqual(existing.total, total + NEW_RECEIPT_AMOUNT)
        self.assertEqual(existing.count, count + 1)

    def test_update_aggregate_size_existing_merged(self):
        existing = models.ScheduleABySize.query.filter_by(
            size=0,
            cycle=2016,
        ).first()
        total = existing.total
        committee_id = existing.committee_id
        filing = self.NmlSchedAFactory(
            rpt_yr=2015,
            cmte_id=committee_id,
            contb_receipt_amt=75,
            contb_receipt_dt=datetime.datetime(2015, 1, 1),
            receipt_tp='15J',
        )
        self.FItemReceiptOrExp(
            sub_id=filing.sub_id,
            rpt_yr=2015,
        )

        # Create a committee and committee report
        # Changed to point to sampled data, may be problematic in the future if det sum table
        # changes a lot and hence the tests need to test new behavior, believe it's fine for now though. -jcc
        rep = sa.Table('detsum_sample', db.metadata, autoload=True, autoload_with=db.engine)
        ins = rep.insert().values(
            indv_unitem_contb=20,
            cmte_id=committee_id,
            rpt_yr=2016,
            orig_sub_id=9,
            form_tp_cd='F3',
        )
        db.session.execute(ins)
        db.session.commit()
        db.session.execute('refresh materialized view ofec_totals_house_senate_mv')
        db.session.execute('refresh materialized view ofec_totals_combined_mv')
        db.session.commit()
        _rebuild_sched_a_by_size_merged()
        refreshed = models.ScheduleABySize.query.filter_by(
            size=0,
            cycle=2016,
            committee_id=committee_id,
        ).first()
        # Updated total includes new Schedule A filing and new report
        self.assertAlmostEqual(refreshed.total, total + 75 + 20)
        self.assertEqual(refreshed.count, None)

    def test_update_aggregate_purpose_create(self):
        db.session.execute('delete from disclosure.f_item_receipt_or_exp')
        filing = self.NmlSchedBFactory(
            rpt_yr=2015,
            cmte_id='C12345',
            disb_amt=538,
            disb_dt=datetime.datetime(2015, 1, 1),
            disb_desc='CAMPAIGN BUTTONS',
            form_tp_cd='11'
        )
        self.FItemReceiptOrExp(
            sub_id=filing.sub_id,
            rpt_yr=2015,
        )
        db.session.commit()
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
        db.session.refresh(rows[0])
        self.assertEqual(rows[0].total, 538)
        self.assertEqual(rows[0].count, 1)
        filing.disb_desc = 'HANGING OUT'
        db.session.add(filing)
        db.session.commit()
        db.session.refresh(rows[0])
        self.assertEqual(rows[0].total, 0)
        self.assertEqual(rows[0].count, 0)

    def test_update_aggregate_purpose_existing(self):
        db.session.execute('delete from disclosure.f_item_receipt_or_exp')
        filing = self.NmlSchedBFactory(
            rpt_yr=2015,
            cmte_id='C12345',
            disb_amt=538,
            disb_dt=datetime.datetime(2015, 1, 1),
            disb_tp='24K',
        )
        self.FItemReceiptOrExp(
            sub_id=filing.sub_id,
            rpt_yr=2015,
        )
        db.session.commit()
        existing = models.ScheduleBByPurpose.query.filter_by(
            purpose='CONTRIBUTIONS',
            cycle=2016,
        ).first()
        total = existing.total
        count = existing.count
        filing = self.NmlSchedBFactory(
            rpt_yr=2015,
            cmte_id=existing.committee_id,
            disb_amt=538,
            disb_dt=datetime.datetime(2015, 1, 1),
            disb_tp='24K',
        )
        self.FItemReceiptOrExp(
            sub_id=filing.sub_id,
            rpt_yr=2015,
        )
        db.session.commit()
        db.session.refresh(existing)
        self.assertEqual(existing.total, total + 538)
        self.assertEqual(existing.count, count + 1)

    def test_add_itemized_partition_cycle(self):
        manage.add_itemized_partition_cycle(3002, 2)
        expected_tables = {
            "ofec_sched_a_3001_3002",
            "ofec_sched_b_3003_3004",
            "ofec_sched_a_3001_3002",
            "ofec_sched_b_3003_3004",
        }
        inspector = sa.inspect(db.engine)
        actual_tables = set(inspector.get_table_names())
        assert expected_tables.issubset(actual_tables)
        assert "ofec_sched_a_3005_3006" not in actual_tables

def _rebuild_sched_a_by_size_merged():
    execute_sql_file('./data/converted_mvs/sched_a_by_size_merged.sql')
