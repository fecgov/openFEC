import datetime

import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest

from webservices.partition import sched_a, sched_b, utils
from webservices.common.models import ScheduleA, ScheduleB
from webservices.rest import db


class TestPartitioning(ApiBaseTest):
    def test_load_table_util(self):
        parent = utils.load_table('ofec_sched_a_master')
        self.assertIsNotNone(parent)

    def test_schedule_a_master_create_and_rename(self):
        parent = utils.load_table('ofec_sched_a_master')
        sched_a.SchedAGroup.create_master(parent)

        temp_table = db.session.execute(
            'select tablename from pg_tables where tablename = \'ofec_sched_a_master_tmp\''
        )

        self.assertEqual(temp_table.scalar(), 'ofec_sched_a_master_tmp')

        sched_a.SchedAGroup.rename_master()

        temp_table = db.session.execute(
            'select tablename from pg_tables where tablename = \'ofec_sched_a_master_tmp\''
        )

        self.assertIsNone(temp_table.scalar())

    def test_schedule_b_master_create_and_rename(self):
        parent = utils.load_table('ofec_sched_b_master')
        sched_b.SchedBGroup.create_master(parent)

        temp_table = db.session.execute(
            'select tablename from pg_tables where tablename = \'ofec_sched_b_master_tmp\''
        )

        self.assertEqual(temp_table.scalar(), 'ofec_sched_b_master_tmp')

        sched_b.SchedBGroup.rename_master()

        temp_table = db.session.execute(
            'select tablename from pg_tables where tablename = \'ofec_sched_b_master_tmp\''
        )

        self.assertIsNone(temp_table.scalar())
