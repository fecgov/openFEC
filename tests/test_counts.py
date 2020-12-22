import datetime

from unittest import mock

from tests import factories
from tests.common import ApiBaseTest

from webservices.resources import sched_a, sched_e
from webservices.rest import db
from webservices.common import models, counts


@mock.patch.object(counts, 'get_query_plan')
class TestCounts(ApiBaseTest):
    def test_schedule_e_efile_uses_exact_count(self, get_query_plan_mock):
        schedule_e_efile = [factories.ScheduleEEfileFactory() for i in range(5)]  # noqa
        factories.EFilingsFactory(file_number=123)
        db.session.flush()

        query = db.session.query(models.ScheduleEEfile)
        # Estimated rows = 6000000
        get_query_plan_mock.return_value = [
            (
                'Seq Scan on real_efile_se_f57_vw  \
            (cost=0.00..10.60 rows=6000000 width=1289)',
            )
        ]
        resource = sched_e.ScheduleEEfileView()
        count, estimate = counts.get_count(
            resource, query
        )
        # Always use exact count for Schedule E efile
        self.assertEqual(count, 5)
        self.assertEqual(estimate, False)

    def test_use_actual_counts_under_threshold(self, get_query_plan_mock):
        receipts = [  # noqa
            factories.ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016,
            ),
            factories.ScheduleAFactory(
                report_year=2015,
                contribution_receipt_date=datetime.date(2015, 1, 1),
                two_year_transaction_period=2016,
            ),
        ]
        query = db.session.query(models.ScheduleA)
        # Estimated rows == 200
        get_query_plan_mock.return_value = [
            ('Seq Scan on fec_fitem_sched_a  (cost=0.00..10.60 rows=200 width=1289)',)
        ]
        resource = sched_a.ScheduleAView()
        count, estimate = counts.get_count(resource, query)
        self.assertEqual(count, 2)
        self.assertEqual(estimate, False)

    def test_use_estimated_counts_over_threshold(self, get_query_plan_mock):
        query = db.session.query(models.ScheduleA)
        # Estimated rows == 2000000
        get_query_plan_mock.return_value = [
            (
                'Seq Scan on fec_fitem_sched_a  \
            (cost=0.00..10.60 rows=2000000 width=1289)',
            )
        ]
        resource = sched_a.ScheduleAView()
        count, estimate = counts.get_count(resource, query)
        self.assertEqual(count, 2000000)
        self.assertEqual(estimate, True)

    # test boundary conditions (n-1)
    def test_threshold_boundary_minus_1(self, get_query_plan_mock):
        query = db.session.query(models.ScheduleA)
        resource = sched_a.ScheduleAView()
        get_query_plan_mock.return_value = [
            (
                'Seq Scan on fec_fitem_sched_a  \
            (cost=0.00..10.60 rows={} width=1289)'.format(resource.estimated_count_threshold - 1),
            )
        ]
        count, estimate = counts.get_count(resource, query)
        self.assertEqual(estimate, False)

    # test boundary conditions (n)
    def test_threshold_boundary(self, get_query_plan_mock):
        query = db.session.query(models.ScheduleA)
        resource = sched_a.ScheduleAView()
        get_query_plan_mock.return_value = [
            (
                'Seq Scan on fec_fitem_sched_a  \
            (cost=0.00..10.60 rows={} width=1289)'.format(resource.estimated_count_threshold),
            )
        ]
        count, estimate = counts.get_count(resource, query)
        self.assertEqual(estimate, False)

    # test boundary conditions (n+1)
    def test_threshold_boundary_plus_1(self, get_query_plan_mock):
        query = db.session.query(models.ScheduleA)
        resource = sched_a.ScheduleAView()
        get_query_plan_mock.return_value = [
            (
                'Seq Scan on fec_fitem_sched_a  \
            (cost=0.00..10.60 rows={} width=1289)'.format(resource.estimated_count_threshold + 1),
            )
        ]
        count, estimate = counts.get_count(resource, query)
        self.assertEqual(estimate, True)
