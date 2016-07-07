import datetime

import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.common.models import ScheduleA, ScheduleE
from webservices.schemas import ScheduleASchema
from webservices.schemas import ScheduleBSchema
from webservices.resources.sched_a import ScheduleAView
from webservices.resources.sched_b import ScheduleBView
from webservices.resources.sched_e import ScheduleEView


class TestItemized(ApiBaseTest):

    def test_fields(self):
        params = [
            (factories.ScheduleAFactory, ScheduleAView, ScheduleASchema),
            (factories.ScheduleBFactory, ScheduleBView, ScheduleBSchema),
        ]
        for factory, resource, schema in params:
            factory()
            results = self._results(api.url_for(resource))
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0].keys(), schema().fields.keys())

    def test_sorting(self):
        receipts = [
            factories.ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016
            ),
            factories.ScheduleAFactory(
                report_year=2015,
                contribution_receipt_date=datetime.date(2015, 1, 1),
                two_year_transaction_period=2016
            ),
        ]
        response = self._response(api.url_for(ScheduleAView, sort='contribution_receipt_date'))
        self.assertEqual(
            [each['report_year'] for each in response['results']],
            [2015, 2016]
        )
        self.assertEqual(
            response['pagination']['last_indexes'],
            {
                'last_index': receipts[0].sub_id,
                'last_contribution_receipt_date': receipts[0].contribution_receipt_date.isoformat(),
            }
        )

    def test_two_year_transaction_period_default_supplied_automatically(self):
        receipts = [
            factories.ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014
            ),
            factories.ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016
            ),
        ]

        response = self._response(api.url_for(ScheduleAView))
        self.assertEqual(len(response['results']), 1)

    def test_two_year_transaction_period_limits_results_per_cycle(self):
        receipts = [
            factories.ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014
            ),
            factories.ScheduleAFactory(
                report_year=2012,
                contribution_receipt_date=datetime.date(2012, 1, 1),
                two_year_transaction_period=2012
            ),
        ]

        response = self._response(
            api.url_for(ScheduleAView, two_year_transaction_period=2014)
        )
        self.assertEqual(len(response['results']), 1)

    def test_sorting_bad_column(self):
        response = self.app.get(api.url_for(ScheduleAView, sort='bad_column'))
        self.assertEqual(response.status_code, 422)
        self.assertIn(b'Cannot sort on value', response.data)

    def test_filter(self):
        [
            factories.ScheduleAFactory(contributor_state='NY'),
            factories.ScheduleAFactory(contributor_state='CA'),
        ]
        results = self._results(api.url_for(ScheduleAView, contributor_state='CA'))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_state'], 'CA')

    def test_filter_case_insensitive(self):
        [
            factories.ScheduleAFactory(contributor_city='NEW YORK'),
            factories.ScheduleAFactory(contributor_city='DES MOINES'),
        ]
        results = self._results(api.url_for(ScheduleAView, contributor_city='new york'))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_city'], 'NEW YORK')

    def test_filter_fulltext(self):
        names = ['David Koch', 'George Soros']
        filings = [
            factories.ScheduleAFactory(contributor_name=name)
            for name in names
        ]
        results = self._results(api.url_for(ScheduleAView, contributor_name='soros'))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_name'], 'George Soros')

    def test_filter_fulltext_employer(self):
        employers = ['Acme Corporation', 'Vandelay Industries']
        filings = [
            factories.ScheduleAFactory(contributor_employer=employer)
            for employer in employers
        ]
        results = self._results(api.url_for(ScheduleAView, contributor_employer='vandelay'))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_employer'], 'Vandelay Industries')

    def test_filter_fulltext_occupation(self):
        occupations = ['Attorney at Law', 'Doctor of Philosophy']
        filings = [
            factories.ScheduleAFactory(contributor_occupation=occupation)
            for occupation in occupations
        ]
        results = self._results(api.url_for(ScheduleAView, contributor_occupation='doctor'))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_occupation'], 'Doctor of Philosophy')

    def test_pagination(self):
        filings = [
            factories.ScheduleAFactory()
            for _ in range(30)
        ]
        page1 = self._results(api.url_for(ScheduleAView))
        self.assertEqual(len(page1), 20)
        self.assertEqual(
            [int(each['sub_id']) for each in page1],
            [each.sub_id for each in filings[:20]],
        )
        page2 = self._results(api.url_for(ScheduleAView, last_index=page1[-1]['sub_id']))
        self.assertEqual(len(page2), 10)
        self.assertEqual(
            [int(each['sub_id']) for each in page2],
            [each.sub_id for each in filings[20:]],
        )

    def test_pagination_bad_per_page(self):
        response = self.app.get(api.url_for(ScheduleAView, per_page=999))
        self.assertEqual(response.status_code, 422)

    def test_image_number(self):
        image_number = '12345'
        [
            factories.ScheduleAFactory(),
            factories.ScheduleAFactory(image_number=image_number),
        ]
        results = self._results(api.url_for(ScheduleAView, image_number=image_number))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['image_number'], image_number)

    def test_image_number_range(self):
        [
            factories.ScheduleAFactory(image_number='1'),
            factories.ScheduleAFactory(image_number='2'),
            factories.ScheduleAFactory(image_number='3'),
            factories.ScheduleAFactory(image_number='4'),
        ]
        results = self._results(api.url_for(ScheduleAView, min_image_number='2'))
        self.assertTrue(all(each['image_number'] >= '2' for each in results))
        results = self._results(api.url_for(ScheduleAView, max_image_number='3'))
        self.assertTrue(all(each['image_number'] <= '3' for each in results))
        results = self._results(api.url_for(ScheduleAView, min_image_number='2', max_image_number='3'))
        self.assertTrue(all('2' <= each['image_number'] <= '3' for each in results))

    def test_memoed(self):
        params = [
            (factories.ScheduleAFactory, ScheduleAView),
            (factories.ScheduleBFactory, ScheduleBView),
        ]
        for factory, resource in params:
            [
                factory(),
                factory(memo_code='X'),
            ]
            results = self._results(api.url_for(resource))
            self.assertFalse(results[0]['memoed_subtotal'])
            self.assertTrue(results[1]['memoed_subtotal'])

    def test_filter_individual_sched_a(self):
        individuals = [
            factories.ScheduleAFactory(receipt_type='15J'),
            factories.ScheduleAFactory(line_number='12', contribution_receipt_amount=150),
        ]
        earmarks = [
            factories.ScheduleAFactory(),
            factories.ScheduleAFactory(
                line_number='12',
                contribution_receipt_amount=150,
                memo_text='earmark',
                memo_code='X',
            ),
        ]

        is_individual = sa.func.is_individual(
            ScheduleA.contribution_receipt_amount,
            ScheduleA.receipt_type,
            ScheduleA.line_number,
            ScheduleA.memo_code,
            ScheduleA.memo_text,
        )

        rows = ScheduleA.query.all()
        self.assertEqual(rows, individuals + earmarks)

        rows = ScheduleA.query.filter(is_individual).all()
        self.assertEqual(rows, individuals)

    def test_amount_sched_a(self):
        [
            factories.ScheduleAFactory(contribution_receipt_amount=50),
            factories.ScheduleAFactory(contribution_receipt_amount=100),
            factories.ScheduleAFactory(contribution_receipt_amount=150),
            factories.ScheduleAFactory(contribution_receipt_amount=200),
        ]
        results = self._results(api.url_for(ScheduleAView, min_amount=100))
        self.assertTrue(all(each['contribution_receipt_amount'] >= 100 for each in results))
        results = self._results(api.url_for(ScheduleAView, max_amount=150))
        self.assertTrue(all(each['contribution_receipt_amount'] <= 150 for each in results))
        results = self._results(api.url_for(ScheduleAView, min_amount=100, max_amount=150))
        self.assertTrue(all(100 <= each['contribution_receipt_amount'] <= 150 for each in results))

    def test_amount_sched_b(self):
        [
            factories.ScheduleBFactory(disbursement_amount=50),
            factories.ScheduleBFactory(disbursement_amount=100),
            factories.ScheduleBFactory(disbursement_amount=150),
            factories.ScheduleBFactory(disbursement_amount=200),
        ]
        results = self._results(api.url_for(ScheduleBView, min_amount=100))
        self.assertTrue(all(each['disbursement_amount'] >= 100 for each in results))
        results = self._results(api.url_for(ScheduleBView, max_amount=150))
        self.assertTrue(all(each['disbursement_amount'] <= 150 for each in results))
        results = self._results(api.url_for(ScheduleBView, min_amount=100, max_amount=150))
        self.assertTrue(all(100 <= each['disbursement_amount'] <= 150 for each in results))

    def test_amount_sched_e(self):
        [
            factories.ScheduleEFactory(expenditure_amount=50),
            factories.ScheduleEFactory(expenditure_amount=100),
            factories.ScheduleEFactory(expenditure_amount=150),
            factories.ScheduleEFactory(expenditure_amount=200),
        ]
        results = self._results(api.url_for(ScheduleEView, min_amount=100))
        self.assertTrue(all(each['expenditure_amount'] >= 100 for each in results))
        results = self._results(api.url_for(ScheduleEView, max_amount=150))
        self.assertTrue(all(each['expenditure_amount'] <= 150 for each in results))
        results = self._results(api.url_for(ScheduleEView, min_amount=100, max_amount=150))
        self.assertTrue(all(100 <= each['expenditure_amount'] <= 150 for each in results))

    def test_filters_sched_e(self):
        filters = [
            ('image_number', ScheduleE.image_number, ['123', '456']),
            ('committee_id', ScheduleE.committee_id, ['C01', 'C02']),
            ('support_oppose_indicator', ScheduleE.support_oppose_indicator, ['S', 'O']),
            ('is_notice', ScheduleE.is_notice, [True, False]),
        ]
        for label, column, values in filters:
            [
                factories.ScheduleEFactory(**{column.key: value})
                for value in values
            ]
            results = self._results(api.url_for(ScheduleEView, **{label: values[0]}))
            assert len(results) == 1
            assert results[0][column.key] == values[0]
