"""Test endpoints for Schedule C which are used in loans page."""
import datetime

from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.schemas import ScheduleCSchema
from webservices.resources.sched_c import ScheduleCView, ScheduleCViewBySubId


class TestScheduleCView(ApiBaseTest):
    def test_fields(self):
        [
            factories.ScheduleCFactory(),
        ]
        results = self._results(api.url_for(ScheduleCView))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0].keys(), ScheduleCSchema().fields.keys())

    def test_sort_incurred_date(self):
        [
            factories.ScheduleCFactory(
                incurred_date=datetime.date(2019, 1, 1), payment_to_date=10.55,
            ),
            factories.ScheduleCFactory(
                incurred_date=datetime.date(2019, 12, 2), payment_to_date=20.55,
            ),
        ]
        response1 = self._response(api.url_for(ScheduleCView, sort='-incurred_date',))
        self.assertEqual(
            [each['payment_to_date'] for each in response1['results']], [20.55, 10.55]
        )

        response2 = self._response(api.url_for(ScheduleCView, sort='incurred_date',))
        self.assertEqual(
            [each['payment_to_date'] for each in response2['results']], [10.55, 20.55]
        )

    def test_sort_payment_to_date(self):
        [
            factories.ScheduleCFactory(payment_to_date=10.55,),
            factories.ScheduleCFactory(payment_to_date=20.55,),
        ]
        response1 = self._response(api.url_for(ScheduleCView, sort='-payment_to_date',))
        self.assertEqual(
            [each['payment_to_date'] for each in response1['results']], [20.55, 10.55]
        )

        response2 = self._response(api.url_for(ScheduleCView, sort='payment_to_date',))
        self.assertEqual(
            [each['payment_to_date'] for each in response2['results']], [10.55, 20.55]
        )

    def test_sort_original_loan_amount(self):
        [
            factories.ScheduleCFactory(original_loan_amount=10.55,),
            factories.ScheduleCFactory(original_loan_amount=20.55,),
        ]
        response1 = self._response(
            api.url_for(ScheduleCView, sort='-original_loan_amount',)
        )
        self.assertEqual(
            [each['original_loan_amount'] for each in response1['results']],
            [20.55, 10.55],
        )

        response2 = self._response(
            api.url_for(ScheduleCView, sort='original_loan_amount',)
        )
        self.assertEqual(
            [each['original_loan_amount'] for each in response2['results']],
            [10.55, 20.55],
        )

    def test_sort_bad_column(self):
        response = self.app.get(api.url_for(ScheduleCView, sort='bad_column'))
        self.assertEqual(response.status_code, 422)
        self.assertIn(b'Cannot sort on value', response.data)

    def test_filter_fulltext_loaner_name(self):
        loaner_names = ['bb cc', 'aa cc']
        [
            factories.ScheduleCFactory(loan_source_name=loaner_name)
            for loaner_name in loaner_names
        ]
        results = self._results(api.url_for(ScheduleCView, loan_source_name='aa '))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['loan_source_name'], 'aa cc')

    def test_filter_fulltext_candidate_name(self):
        candidate_names = ['bb cc', 'aa cc']
        [
            factories.ScheduleCFactory(candidate_name=candidate_name)
            for candidate_name in candidate_names
        ]
        results = self._results(api.url_for(ScheduleCView, candidate_name='aa '))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['candidate_name'], 'aa cc')

# test invlid keyword search
        response = self.app.get(
            api.url_for(ScheduleCView, candidate_name='aa'))
        self.assertEqual(response.status_code, 422)

    def test_filter_payment_to_date(self):
        [
            factories.ScheduleCFactory(payment_to_date=50),
            factories.ScheduleCFactory(payment_to_date=100),
            factories.ScheduleCFactory(payment_to_date=150),
            factories.ScheduleCFactory(payment_to_date=200),
        ]
        results = self._results(api.url_for(ScheduleCView, min_payment_to_date=100))
        self.assertTrue(all(each['payment_to_date'] >= 100 for each in results))
        results = self._results(api.url_for(ScheduleCView, max_payment_to_date=150))
        self.assertTrue(all(each['payment_to_date'] <= 150 for each in results))
        results = self._results(
            api.url_for(ScheduleCView, min_payment_to_date=100, max_payment_to_date=200)
        )
        self.assertTrue(all(100 <= each['payment_to_date'] <= 200 for each in results))

    def test_filter_original_loan_amount(self):
        [
            factories.ScheduleCFactory(original_loan_amount=50),
            factories.ScheduleCFactory(original_loan_amount=100),
            factories.ScheduleCFactory(original_loan_amount=150),
            factories.ScheduleCFactory(original_loan_amount=200),
        ]
        results = self._results(api.url_for(ScheduleCView, min_amount=100))
        self.assertTrue(all(each['original_loan_amount'] >= 100 for each in results))
        results = self._results(api.url_for(ScheduleCView, max_amount=150))
        self.assertTrue(all(each['original_loan_amount'] <= 150 for each in results))
        results = self._results(
            api.url_for(ScheduleCView, min_amount=100, max_amount=200)
        )
        self.assertTrue(
            all(100 <= each['original_loan_amount'] <= 200 for each in results)
        )

    def test_filter_incurred_date(self):
        [
            factories.ScheduleCFactory(incurred_date=datetime.date(2015, 1, 1)),
            factories.ScheduleCFactory(incurred_date=datetime.date(2016, 1, 1)),
            factories.ScheduleCFactory(incurred_date=datetime.date(2017, 1, 1)),
            factories.ScheduleCFactory(incurred_date=datetime.date(2018, 1, 1)),
        ]
        min_date = datetime.date(2015, 1, 1)
        results = self._results(api.url_for(ScheduleCView, min_incurred_date=min_date))
        self.assertTrue(
            all(
                each
                for each in results
                if each['incurred_date'] >= min_date.isoformat()
            )
        )
        max_date = datetime.date(2018, 1, 1)
        results = self._results(api.url_for(ScheduleCView, max_incurred_date=max_date))
        self.assertTrue(
            all(
                each
                for each in results
                if each['incurred_date'] <= max_date.isoformat()
            )
        )
        results = self._results(
            api.url_for(
                ScheduleCView, min_incurred_date=min_date, max_incurred_date=max_date
            )
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_date.isoformat() <= each['incurred_date'] <= max_date.isoformat()
            )
        )

    def test_filter_image_number(self):
        image_number = '12345'
        [
            factories.ScheduleCFactory(),
            factories.ScheduleCFactory(image_number=image_number),
        ]
        results = self._results(api.url_for(ScheduleCView, image_number=image_number))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['image_number'], image_number)

    def test_image_number_range(self):
        [
            factories.ScheduleCFactory(image_number='1'),
            factories.ScheduleCFactory(image_number='2'),
            factories.ScheduleCFactory(image_number='3'),
            factories.ScheduleCFactory(image_number='4'),
        ]
        results = self._results(api.url_for(ScheduleCView, min_image_number='2'))
        self.assertTrue(all(each['image_number'] >= '2' for each in results))
        results = self._results(api.url_for(ScheduleCView, max_image_number='3'))
        self.assertTrue(all(each['image_number'] <= '3' for each in results))
        results = self._results(
            api.url_for(ScheduleCView, min_image_number='2', max_image_number='3')
        )
        self.assertTrue(all('2' <= each['image_number'] <= '3' for each in results))

    def test_schedule_c_filter_line_number(self):
        [
            factories.ScheduleCFactory(line_number_short='10', filing_form='F3X'),
            factories.ScheduleCFactory(line_number_short='9', filing_form='F3X'),
        ]
        results = self._results(
            api.url_for(ScheduleCView, line_number='f3x-10')
        )
        self.assertEqual(len(results), 1)
        response = self.app.get(
            api.url_for(ScheduleCView, line_number='f3x21')
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn(b'Invalid line_number', response.data)


class TestScheduleCViewBySubId(ApiBaseTest):
    def test_fields(self):
        [
            factories.ScheduleCViewBySubIdFactory(sub_id='123'),
        ]
        results = self._results(api.url_for(ScheduleCViewBySubId, sub_id='123'))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0].keys(), ScheduleCSchema().fields.keys())
