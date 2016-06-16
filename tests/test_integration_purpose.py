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

class TestViews(common.IntegrationTestCase):

    @classmethod
    def setUpClass(cls):
        super(TestViews, cls).setUpClass()
        cls.SchedAFactory, cls.SchedBFactory = make_factory()
        manage.update_all(processes=1)


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
