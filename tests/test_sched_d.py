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
            factories.ScheduleDViewFactory(load_date=datetime.date(2012, 1, 1)),
            factories.ScheduleDViewFactory(load_date=datetime.date(2013, 1, 1)),
            factories.ScheduleDViewFactory(load_date=datetime.date(2014, 1, 1)),
            factories.ScheduleDViewFactory(load_date=datetime.date(2015, 1, 1)),
        ]
        min_date = datetime.date(2013, 1, 1)
        results = self._results(api.url_for(ScheduleDView, min_load_date=min_date))
        self.assertTrue(
            all(each for each in results if each['load_date'] >= min_date.isoformat())
        )
        max_date = datetime.date(2014, 1, 1)
        results = self._results(api.url_for(ScheduleDView, max_load_date=max_date))
        self.assertTrue(
            all(each for each in results if each['load_date'] <= max_date.isoformat())
        )
        results = self._results(
            api.url_for(ScheduleDView, min_load_date=min_date, max_load_date=max_date)
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_date.isoformat() <= each['load_date'] <= max_date.isoformat()
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
