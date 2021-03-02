import datetime

from tests import factories
from tests.common import ApiBaseTest
from webservices.rest import api
from webservices.common.models import ScheduleD
from webservices.schemas import ScheduleDSchema
from webservices.resources.sched_d import ScheduleDView, ScheduleDViewBySubId


class TestScheduleDView(ApiBaseTest):
    def test_fields(self):
        [
            factories.ScheduleDViewFactory(),
        ]
        results = self._results(api.url_for(ScheduleDView))
        assert len(results) == 1
        assert results[0].keys() == ScheduleDSchema().fields.keys()

    def test_filters(self):
        filters = [
            ('image_number', ScheduleD.image_number, ['123', '456']),
            ('committee_id', ScheduleD.committee_id, ['C01', 'C02']),
            ('candidate_id', ScheduleD.candidate_id, ['S01', 'S02']),
        ]
        for label, column, values in filters:
            [factories.ScheduleDViewFactory(**{column.key: value}) for value in values]
            results = self._results(api.url_for(ScheduleDView, **{label: values[0]}))
            assert len(results) == 1
            assert results[0][column.key] == values[0]

    def test_filter_fulltext_field(self):
        names = ['OFFICE MAX', 'MAX AND ERMAS', 'OFFICE MAX CONSUMER CREDIT CARD']
        [factories.ScheduleDViewFactory(creditor_debtor_name=name) for name in names]
        results = self._results(
            api.url_for(ScheduleDView, creditor_debtor_name='OFFICE')
        )
        self.assertEqual(len(results), 2)
        self.assertEqual(results[0]['creditor_debtor_name'], 'OFFICE MAX')

    def test_filter_match_field(self):
        names = ['DUES', 'PRINTING', 'ENTERTAIMENT']
        [factories.ScheduleDViewFactory(nature_of_debt=name) for name in names]
        results = self._results(
            api.url_for(ScheduleDView, nature_of_debt='ENTERTAIMENT')
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['nature_of_debt'], 'ENTERTAIMENT')

    def test_filter_range(self):
        [
            factories.ScheduleDViewFactory(
                load_date=datetime.date(2012, 1, 1),
                amount_incurred_period=1,
                outstanding_balance_beginning_of_period=1,
                outstanding_balance_close_of_period=1
            ),
            factories.ScheduleDViewFactory(
                load_date=datetime.date(2013, 1, 1),
                amount_incurred_period=2,
                outstanding_balance_beginning_of_period=2,
                outstanding_balance_close_of_period=2
            ),
            factories.ScheduleDViewFactory(
                load_date=datetime.date(2014, 1, 1),
                amount_incurred_period=3,
                outstanding_balance_beginning_of_period=3,
                outstanding_balance_close_of_period=3
            ),
            factories.ScheduleDViewFactory(
                load_date=datetime.date(2015, 1, 1),
                amount_incurred_period=4,
                outstanding_balance_beginning_of_period=3,
                outstanding_balance_close_of_period=4
            ),
        ]
        # load_date min, max
        min_date = datetime.date(2013, 1, 1)
        results = self._results(api.url_for(ScheduleDView, min_date=min_date))
        self.assertTrue(
            all(
                each['load_date'] >= min_date.isoformat()
                for each in results
            )
        )
        max_date = datetime.date(2014, 1, 1)
        results = self._results(api.url_for(ScheduleDView, max_date=max_date))
        self.assertTrue(
            all(each['load_date'] <= max_date.isoformat() for each in results)
        )
        results = self._results(
            api.url_for(ScheduleDView, min_date=min_date, max_date=max_date)
        )
        self.assertTrue(
            all(
                min_date.isoformat() <= each['load_date'] <= max_date.isoformat()
                for each in results
            )
        )
        min_amount = 2
        max_amount = 3
        filters = [
            (
                "amount_incurred_period",
                "min_amount_incurred",
                "max_amount_incurred"
            ),
            (
                "outstanding_balance_beginning_of_period",
                "min_amount_outstanding_beginning",
                "max_amount_outstanding_beginning"),
            (
                "outstanding_balance_close_of_period",
                "min_amount_outstanding_close",
                "max_amount_outstanding_close"
            ),
        ]
        for output_field, min_filter, max_filter in filters:
            results = self._results(api.url_for(ScheduleDView, **{min_filter: min_amount}))
            self.assertTrue(
                all(each[output_field] >= min_amount for each in results)
            )
            results = self._results(api.url_for(ScheduleDView, **{max_filter: max_amount}))
            self.assertTrue(
                all(each[output_field] <= max_amount for each in results)
            )
            results = self._results(
                api.url_for(ScheduleDView, **{min_filter: min_amount, max_filter: max_amount})
            )
            self.assertTrue(
                all(
                    min_amount <= each[output_field] <= max_amount
                    for each in results
                )
            )

    def test_sort_ascending(self):
        [
            factories.ScheduleDViewFactory(sub_id=1, load_date='2017-01-02'),
            factories.ScheduleDViewFactory(sub_id=2, load_date='2017-01-01'),
        ]
        results = self._results(api.url_for(ScheduleDView, sort=['load_date']))
        self.assertEqual(results[0]['load_date'], '2017-01-01')
        self.assertEqual(results[1]['load_date'], '2017-01-02')

    def test_sort_descending(self):
        [
            factories.ScheduleDViewFactory(sub_id=1, load_date='2017-01-02'),
            factories.ScheduleDViewFactory(sub_id=2, load_date='2017-01-01'),
        ]
        results = self._results(api.url_for(ScheduleDView, sort=['-sub_id']))
        self.assertEqual(results[0]['sub_id'], '2')
        self.assertEqual(results[1]['sub_id'], '1')


class TestScheduleDViewBySubId(ApiBaseTest):
    def test_sub_id_field(self):
        [
            factories.ScheduleDViewBySubIdFactory(sub_id='101'),
            factories.ScheduleDViewBySubIdFactory(sub_id='102'),
        ]
        results = self._results(api.url_for(ScheduleDViewBySubId, sub_id='101'))
        assert len(results) == 1
        assert results[0].keys() == ScheduleDSchema().fields.keys()
