import datetime

import pytest

import sqlalchemy as sa
from sqlalchemy.ext.automap import automap_base

import factory
from factory.alchemy import SQLAlchemyModelFactory

import manage
from tests import common, factories
from webservices.rest import db
from webservices.common import models
from webservices.common.models import ScheduleA


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
        cls.NmlSchedAFactory, cls.NmlSchedBFactory, cls.FItemReceiptOrExp = make_factory()
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

    # def test_sched_a_fulltext_trigger(self):
    #     # Test create
    #     nml_row = self.NmlSchedAFactory(
    #         rpt_yr=2014,
    #         contbr_nm='Sheldon Adelson',
    #         contb_receipt_dt=datetime.datetime(2014, 1, 1)
    #     )
    #     self.FItemReceiptOrExp(
    #         sub_id=nml_row.sub_id,
    #         rpt_yr=2014,
    #     )
    #     db.session.commit()
    #     manage.refresh_itemized()
    #     search = models.ScheduleA.query.filter(
    #         models.ScheduleA.sub_id == nml_row.sub_id
    #     ).one()
    #     self.assertEqual(search.contributor_name_text, "'adelson':2 'sheldon':1")

    #     # Test update
    #     nml_row.contbr_nm = 'Shelly Adelson'
    #     db.session.add(nml_row)
    #     db.session.commit()
    #     manage.refresh_itemized()
    #     search = models.ScheduleA.query.filter(
    #         models.ScheduleA.sub_id == nml_row.sub_id
    #     ).one()
    #     db.session.refresh(search)
    #     self.assertEqual(search.contributor_name_text, "'adelson':2 'shelli':1")

    #     # Test delete
    #     db.session.delete(nml_row)
    #     db.session.commit()
    #     manage.refresh_itemized()
    #     self.assertEqual(
    #         models.ScheduleA.query.filter(
    #             models.ScheduleA.sub_id == nml_row.sub_id
    #         ).count(),
    #         0,
    #     )

    #     # Test sequential writes
    #     make_transient(nml_row)
    #     db.session.add(nml_row)
    #     db.session.commit()

    #     db.session.delete(nml_row)
    #     db.session.commit()

    #     make_transient(nml_row)
    #     db.session.add(nml_row)
    #     db.session.commit()
    #     manage.refresh_itemized()
    #     self.assertEqual(
    #         models.ScheduleA.query.filter(
    #             models.ScheduleA.sub_id == nml_row.sub_id
    #         ).count(),
    #         1,
    #     )

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

    # def test_sched_a_queue_transactions_success(self):
    #     # Make sure queues are clear before starting
    #     self._clear_sched_a_queues()

    #     # Test create
    #     nml_row = self.NmlSchedAFactory(
    #         rpt_yr=2014,
    #         contbr_nm='Sheldon Adelson',
    #         contb_receipt_dt=datetime.datetime(2014, 1, 1)
    #     )
    #     self.FItemReceiptOrExp(
    #         sub_id=nml_row.sub_id,
    #         rpt_yr=2014,
    #     )
    #     db.session.commit()
    #     new_queue_count = self._get_sched_a_queue_new_count()
    #     old_queue_count = self._get_sched_a_queue_old_count()
    #     self.assertEqual(new_queue_count, 1)
    #     self.assertEqual(old_queue_count, 0)
    #     manage.refresh_itemized()
    #     search = models.ScheduleA.query.filter(
    #         models.ScheduleA.sub_id == nml_row.sub_id
    #     ).one()
    #     new_queue_count = self._get_sched_a_queue_new_count()
    #     old_queue_count = self._get_sched_a_queue_old_count()
    #     self.assertEqual(new_queue_count, 0)
    #     self.assertEqual(old_queue_count, 0)
    #     self.assertEqual(search.sub_id, nml_row.sub_id)

    #     # Test update
    #     nml_row.contbr_nm = 'Shelly Adelson'
    #     db.session.add(nml_row)
    #     db.session.commit()
    #     new_queue_count = self._get_sched_a_queue_new_count()
    #     old_queue_count = self._get_sched_a_queue_old_count()
    #     self.assertEqual(new_queue_count, 1)
    #     self.assertEqual(old_queue_count, 1)
    #     manage.refresh_itemized()
    #     search = models.ScheduleA.query.filter(
    #         models.ScheduleA.sub_id == nml_row.sub_id
    #     ).one()
    #     db.session.refresh(search)
    #     new_queue_count = self._get_sched_a_queue_new_count()
    #     old_queue_count = self._get_sched_a_queue_old_count()
    #     self.assertEqual(new_queue_count, 0)
    #     self.assertEqual(old_queue_count, 0)
    #     self.assertEqual(search.sub_id, nml_row.sub_id)

    #     # Test delete
    #     db.session.delete(nml_row)
    #     db.session.commit()
    #     new_queue_count = self._get_sched_a_queue_new_count()
    #     old_queue_count = self._get_sched_a_queue_old_count()
    #     self.assertEqual(new_queue_count, 0)
    #     self.assertEqual(old_queue_count, 1)
    #     manage.refresh_itemized()
    #     new_queue_count = self._get_sched_a_queue_new_count()
    #     old_queue_count = self._get_sched_a_queue_old_count()
    #     self.assertEqual(new_queue_count, 0)
    #     self.assertEqual(old_queue_count, 0)
    #     self.assertEqual(
    #         models.ScheduleA.query.filter(
    #             models.ScheduleA.sub_id == nml_row.sub_id
    #         ).count(),
    #         0,
    #     )

    # def test_sched_a_queue_transactions_failure(self):
    #     # Make sure queues are clear before starting
    #     self._clear_sched_a_queues()

    #     nml_row = self.NmlSchedAFactory(
    #         rpt_yr=2014,
    #         contbr_nm='Sheldon Adelson',
    #         contb_receipt_dt=datetime.datetime(2014, 1, 1)
    #     )
    #     self.FItemReceiptOrExp(
    #         sub_id=nml_row.sub_id,
    #         rpt_yr=2014,
    #     )
    #     db.session.commit()
    #     manage.refresh_itemized()

    #     # Test insert/update failure
    #     nml_row.contbr_nm = 'Shelley Adelson'
    #     db.session.add(nml_row)
    #     db.session.commit()
    #     new_queue_count = self._get_sched_a_queue_new_count()
    #     old_queue_count = self._get_sched_a_queue_old_count()
    #     self.assertEqual(new_queue_count, 1)
    #     self.assertEqual(old_queue_count, 1)
    #     db.session.execute('delete from ofec_sched_a_queue_old')
    #     db.session.commit()
    #     old_queue_count = self._get_sched_a_queue_old_count()
    #     self.assertEqual(old_queue_count, 0)
    #     manage.refresh_itemized()
    #     search = models.ScheduleA.query.filter(
    #         models.ScheduleA.sub_id == nml_row.sub_id
    #     ).one()
    #     db.session.refresh(search)
    #     new_queue_count = self._get_sched_a_queue_new_count()
    #     old_queue_count = self._get_sched_a_queue_old_count()
    #     self.assertEqual(new_queue_count, 1)
    #     self.assertEqual(old_queue_count, 0)
    #     self.assertEqual(search.sub_id, nml_row.sub_id)
    #     self.assertEqual(search.contributor_name, 'Sheldon Adelson')

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
        self._clear_sched_a_queues()
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

        # Create a committee and committee report
        # Changed to point to sampled data, may be problematic in the future if det sum table
        # changes a lot and hence the tests need to test new behavior, believe it's fine for now though. -jcc
        rep = sa.Table('v_sum_and_det_sum_report', db.metadata, schema='disclosure',
                autoload=True, autoload_with=db.engine)
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
        db.session.execute('refresh materialized view ofec_totals_combined_mv')
        db.session.execute('refresh materialized view ofec_sched_a_aggregate_size_merged_mv')
        refreshed = models.ScheduleABySize.query.filter_by(
            size=0,
            cycle=2016,
            committee_id=existing.committee_id,
        ).first()
        # Updated total includes new Schedule A filing and new report
        self.assertAlmostEqual(refreshed.total, total + 75 + 20)
        self.assertEqual(refreshed.count, None)

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
