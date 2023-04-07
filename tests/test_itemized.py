import datetime
import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest
from webservices.rest import db, api
from webservices.schemas import ScheduleASchema
from webservices.schemas import ScheduleBSchema
from webservices.common.models import (
    ScheduleE,
    ScheduleAEfile,
    ScheduleBEfile,
    ScheduleEEfile,
)
from webservices.resources.sched_a import ScheduleAView, ScheduleAEfileView
from webservices.resources.sched_b import ScheduleBView, ScheduleBEfileView
from webservices.resources.sched_e import ScheduleEView, ScheduleEEfileView
from webservices.resources.sched_h4 import ScheduleH4View


class TestItemized(ApiBaseTest):
    kwargs = {'two_year_transaction_period': 2016}

    def test_fields(self):

        params = [
            (factories.ScheduleAFactory, ScheduleAView, ScheduleASchema),
            (factories.ScheduleBFactory, ScheduleBView, ScheduleBSchema),
        ]
        for factory, resource, schema in params:
            factory()
            results = self._results(api.url_for(resource, **self.kwargs))
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0].keys(), schema().fields.keys())


class TestScheduleA(ApiBaseTest):
    kwargs = {'two_year_transaction_period': 2016}

    def test_schedule_a_sorting(self):
        receipts = [
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
        response = self._response(
            api.url_for(ScheduleAView, sort='contribution_receipt_date', **self.kwargs)
        )
        self.assertEqual(
            [each['report_year'] for each in response['results']], [2015, 2016]
        )
        self.assertEqual(
            response['pagination']['last_indexes'],
            {
                'last_index': str(receipts[0].sub_id),
                'last_contribution_receipt_date': receipts[
                    0
                ].contribution_receipt_date.isoformat(),
            },
        )

    def test_schedule_a_multiple_two_year_transaction_period(self):
        """
        testing schedule_a api can take multiple cycles now
        """
        receipts = [  # noqa
            factories.ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014,
                committee_id='C001',
            ),
            factories.ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016,
                committee_id='C001',
            ),
            factories.ScheduleAFactory(
                report_year=2018,
                contribution_receipt_date=datetime.date(2018, 1, 1),
                two_year_transaction_period=2018,
                committee_id='C001',
            ),
        ]
        response = self._response(
            api.url_for(
                ScheduleAView,
                two_year_transaction_period=[2016, 2018],
                committee_id='C001',
            )
        )
        self.assertEqual(len(response['results']), 2)

    def test_schedule_a_multiple_cmte_id_and_two_year_transaction_period(self):
        """
        testing schedule_a api can take multiple cycles now
        """
        receipts = [  # noqa
            factories.ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014,
                committee_id='C001',
            ),
            factories.ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016,
                committee_id='C001',
            ),
            factories.ScheduleAFactory(
                report_year=2018,
                contribution_receipt_date=datetime.date(2018, 1, 1),
                two_year_transaction_period=2018,
                committee_id='C001',
            ),
            factories.ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014,
                committee_id='C002',
            ),
            factories.ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016,
                committee_id='C002',
            ),
            factories.ScheduleAFactory(
                report_year=2018,
                contribution_receipt_date=datetime.date(2018, 1, 1),
                two_year_transaction_period=2018,
                committee_id='C002',
            ),
            factories.ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014,
                committee_id='C003',
            ),
            factories.ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016,
                committee_id='C003',
            ),
            factories.ScheduleAFactory(
                report_year=2018,
                contribution_receipt_date=datetime.date(2018, 1, 1),
                two_year_transaction_period=2018,
                committee_id='C003',
            ),
        ]
        response = self._response(
            api.url_for(
                ScheduleAView,
                two_year_transaction_period=[2016, 2018],
                committee_id=['C001', 'C002'],
            )
        )
        self.assertEqual(len(response['results']), 4)
        response = self._response(
            api.url_for(
                ScheduleAView,
                committee_id='C001',
            )
        )
        self.assertEqual(len(response['results']), 3)

    def test_schedule_a_two_year_transaction_period_limits_results_per_cycle(self):
        receipts = [  # noqa
            factories.ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014,
            ),
            factories.ScheduleAFactory(
                report_year=2012,
                contribution_receipt_date=datetime.date(2012, 1, 1),
                two_year_transaction_period=2012,
            ),
        ]
        response = self._response(
            api.url_for(ScheduleAView, two_year_transaction_period=2014)
        )
        self.assertEqual(len(response['results']), 1)

    def test_schedule_a_sorting_bad_column(self):
        response = self.app.get(api.url_for(ScheduleAView, sort='bad_column'))
        self.assertEqual(response.status_code, 422)
        self.assertIn(b'Cannot sort on value', response.data)

    def test_schedule_a_filter(self):
        [
            factories.ScheduleAFactory(contributor_state='NY'),
            factories.ScheduleAFactory(contributor_state='CA'),
        ]
        results = self._results(
            api.url_for(ScheduleAView, contributor_state='CA', **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_state'], 'CA')

    def test_schedule_a_filter_zip(self):
        [
            factories.ScheduleAFactory(contributor_zip=96789),
            factories.ScheduleAFactory(contributor_zip=9678912),
            factories.ScheduleAFactory(contributor_zip=967891234),
            factories.ScheduleAFactory(contributor_zip='M4C 1M7'),
        ]
        results = self._results(
            api.url_for(ScheduleAView, contributor_zip=967893405, **self.kwargs)
        )
        self.assertEqual(len(results), 3)

        results = self._results(
            api.url_for(ScheduleAView, contributor_zip='M4C 1M55', **self.kwargs)
        )
        self.assertEqual(len(results), 1)

        contributor_zips = ['M4C 1M5555', 96789]
        results = self._results(
            api.url_for(ScheduleAView, contributor_zip=contributor_zips, **self.kwargs)
        )
        self.assertEqual(len(results), 4)

    def test_schedule_a_invalid_zip(self):
        response = self.app.get(
            api.url_for(ScheduleAView, contributor_zip='96%', cycle=2018)
        )
        self.assertEqual(response.status_code, 422)

    def test_schedule_a_missing_secondary_index(self):
        response = self.app.get(
            api.url_for(ScheduleAView, contributor_state='WY')
        )
        self.assertEqual(response.status_code, 400)

    def test_schedule_a_recipient_committee_type_filter(self):
        [
            factories.ScheduleAFactory(recipient_committee_type='S'),
            factories.ScheduleAFactory(recipient_committee_type='S'),
            factories.ScheduleAFactory(recipient_committee_type='P'),
        ]
        results = self._results(
            api.url_for(ScheduleAView, recipient_committee_type='S', **self.kwargs)
        )
        self.assertEqual(len(results), 2)

    def test_schedule_a_recipient_org_type_filter(self):
        [
            factories.ScheduleAFactory(recipient_committee_org_type='W'),
            factories.ScheduleAFactory(recipient_committee_org_type='W'),
            factories.ScheduleAFactory(recipient_committee_org_type='C'),
        ]
        results = self._results(
            api.url_for(ScheduleAView, recipient_committee_org_type='W', **self.kwargs)
        )
        self.assertEqual(len(results), 2)

    def test_schedule_a_recipient_designation_filter(self):
        [
            factories.ScheduleAFactory(recipient_committee_designation='P'),
            factories.ScheduleAFactory(recipient_committee_designation='P'),
            factories.ScheduleAFactory(recipient_committee_designation='A'),
        ]
        results = self._results(
            api.url_for(
                ScheduleAView, recipient_committee_designation='P', **self.kwargs
            )
        )
        self.assertEqual(len(results), 2)

    def test_schedule_a_filter_multi_start_with(self):
        [factories.ScheduleAFactory(contributor_zip=1296789)]
        results = self._results(
            api.url_for(ScheduleAView, contributor_zip=96789, **self.kwargs)
        )
        self.assertEqual(len(results), 0)

    def test_schedule_a_filter_case_insensitive(self):
        [
            factories.ScheduleAFactory(contributor_city='NEW YORK'),
            factories.ScheduleAFactory(contributor_city='DES MOINES'),
        ]
        results = self._results(
            api.url_for(ScheduleAView, contributor_city='new york', **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_city'], 'NEW YORK')

    def test_schedule_a_filter_fulltext(self):
        """
        Note: this is the only test for filter_fulltext.
        If this is removed, please add a test to test_filters.py
        """
        names = ['David Koch', 'George Soros']
        filings = [  # noqa
            factories.ScheduleAFactory(contributor_name=name) for name in names
        ]
        results = self._results(
            api.url_for(ScheduleAView, contributor_name='soros', **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_name'], 'George Soros')

    def test_schedule_a_filter_line_number(self):
        [
            factories.ScheduleAFactory(line_number='16', filing_form='F3X'),
            factories.ScheduleAFactory(line_number='17', filing_form='F3X'),
        ]
        results = self._results(
            api.url_for(ScheduleAView, line_number='f3X-16', **self.kwargs)
        )
        self.assertEqual(len(results), 1)

        [
            factories.ScheduleBFactory(line_number='21', filing_form='F3X'),
            factories.ScheduleBFactory(line_number='22', filing_form='F3X'),
        ]

        results = self._results(
            api.url_for(ScheduleBView, line_number='f3X-21', **self.kwargs)
        )
        self.assertEqual(len(results), 1)

        # invalid line_number testing for sched_b
        response = self.app.get(
            api.url_for(ScheduleBView, line_number='f3x21', **self.kwargs)
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn(b'Invalid line_number', response.data)

        # invalid line_number testing for sched_a
        response = self.app.get(
            api.url_for(ScheduleAView, line_number='f3x16', **self.kwargs)
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn(b'Invalid line_number', response.data)

    def test_schedule_a_filter_fulltext_employer(self):
        employers = ['Acme Corporation', 'Vandelay Industries']
        filings = [  # noqa
            factories.ScheduleAFactory(contributor_employer=employer)
            for employer in employers
        ]
        results = self._results(
            api.url_for(ScheduleAView, contributor_employer='vandelay', **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_employer'], 'Vandelay Industries')

    def test_schedule_a_filter_fulltext_employer_and(self):
        employers = ['Test&Test', 'Test & Test', 'Test& Test', 'Test &Test']
        [
            factories.ScheduleAFactory(contributor_employer=employer)
            for employer in employers
        ]
        results = self._results(
            api.url_for(ScheduleAView, contributor_employer='Test&Test', **self.kwargs)
        )
        self.assertIn(results[0]['contributor_employer'], employers)
        results = self._results(
            api.url_for(
                ScheduleAView, contributor_employer='Test & Test', **self.kwargs
            )
        )
        self.assertIn(results[0]['contributor_employer'], employers)
        results = self._results(
            api.url_for(ScheduleAView, contributor_employer='Test& Test', **self.kwargs)
        )
        self.assertIn(results[0]['contributor_employer'], employers)
        results = self._results(
            api.url_for(ScheduleAView, contributor_employer='Test &Test', **self.kwargs)
        )
        self.assertIn(results[0]['contributor_employer'], employers)

    def test_schedule_a_filter_fulltext_occupation(self):
        occupations = ['Attorney at Law', 'Doctor of Philosophy']
        filings = [  # noqa
            factories.ScheduleAFactory(contributor_occupation=occupation)
            for occupation in occupations
        ]
        results = self._results(
            api.url_for(ScheduleAView, contributor_occupation='doctor', **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_occupation'], 'Doctor of Philosophy')

    def test_schedule_a_pagination(self):
        filings = [
            factories.ScheduleAFactory(contribution_receipt_date=datetime.date(2016, 1, 1))
            for _ in range(30)
        ]
        page1 = self._results(api.url_for(ScheduleAView, **self.kwargs))
        self.assertEqual(len(page1), 20)
        self.assertEqual(
            [int(each['sub_id']) for each in page1],
            [each.sub_id for each in filings[29:9:-1]],
        )
        page2 = self._results(
            api.url_for(
                ScheduleAView,
                last_index=page1[-1]['sub_id'],
                last_contribution_receipt_date=page1[-1]['contribution_receipt_date'],
                **self.kwargs
            )
        )
        self.assertEqual(len(page2), 10)
        self.assertEqual(
            [int(each['sub_id']) for each in page2],
            [each.sub_id for each in filings[9::-1]],
        )

    def test_schedule_a_pagination_with_null_sort_column_values_hidden(self):
        # First 5 results [0:4] have missing receipt date
        filings = [
            factories.ScheduleAFactory(
                contribution_receipt_date=None,
                committee_id="1") for _ in range(5)
        ]
        # Results [5:30] have date
        filings = filings + [
            factories.ScheduleAFactory(
                contribution_receipt_date=datetime.date(2016, 1, 1),
                committee_id="2")
            for _ in range(25)
        ]
        page1 = self._results(
            api.url_for(
                ScheduleAView,
                sort='contribution_receipt_date',
                sort_hide_null=True,
                **self.kwargs)
        )
        self.assertEqual(len(page1), 20)
        self.assertEqual(
            [int(each['sub_id']) for each in page1],
            [each.sub_id for each in filings[5:25]],
        )
        self.assertEqual(
            [each['contribution_receipt_date'] for each in page1],
            [
                each.contribution_receipt_date.strftime('%Y-%m-%d')
                for each in filings[5:25]
            ],
        )
        page2 = self._results(
            api.url_for(
                ScheduleAView,
                last_index=page1[-1]['sub_id'],
                last_contribution_receipt_date=page1[-1]['contribution_receipt_date'],
                sort='contribution_receipt_date',
                sort_hide_null=True,
                **self.kwargs
            )
        )
        self.assertEqual(len(page2), 5)
        self.assertEqual(
            [int(each['sub_id']) for each in page2],
            [each.sub_id for each in filings[25:]],
        )
        self.assertEqual(
            [each['contribution_receipt_date'] for each in page2],
            [
                each.contribution_receipt_date.strftime('%Y-%m-%d')
                for each in filings[25:]
            ],
        )
        # Test pagination counts - only 25 have dates
        # Multiple committee ID's
        response = self._response(
            api.url_for(
                ScheduleAView,
                sort='contribution_receipt_date',
                sort_hide_null=True,
                per_page=30,
                committee_id=["1", "2"],
                **self.kwargs)
        )
        count = response["pagination"]["count"]
        self.assertEqual(count, 25)
        # One committee ID
        response = self._response(
            api.url_for(
                ScheduleAView,
                sort='contribution_receipt_date',
                sort_hide_null=True,
                per_page=30,
                committee_id=["1"],
                **self.kwargs)
        )
        count = response["pagination"]["count"]
        self.assertEqual(count, 0)

    def test_schedule_a_pagination_with_null_sort_column_values_showing(self):
        # First 5 results [0:4] have missing receipt date
        filings = [
            factories.ScheduleAFactory(contribution_receipt_date=None) for _ in range(5)
        ]
        # Results [5:30] have date
        filings = filings + [
            factories.ScheduleAFactory(
                contribution_receipt_date=datetime.date(2016, 1, 1)
            )
            for _ in range(25)
        ]
        page1 = self._results(
            api.url_for(ScheduleAView, sort='contribution_receipt_date', **self.kwargs)
        )
        self.assertEqual(len(page1), 20)
        self.assertEqual(
            [int(each['sub_id']) for each in page1],
            [each.sub_id for each in filings[5:25]],
        )
        self.assertEqual(
            [each['contribution_receipt_date'] for each in page1],
            [
                each.contribution_receipt_date.strftime('%Y-%m-%d')
                if each.contribution_receipt_date
                else None
                for each in filings[5:25]
            ],
        )

        page2_missing_last_contribution_receipt_date = self.app.get(
            api.url_for(
                ScheduleAView,
                last_index=page1[-1]['sub_id'],
                sort='contribution_receipt_date',
                **self.kwargs
            )
        )
        self.assertEqual(page2_missing_last_contribution_receipt_date.status_code, 422)

        page2 = self._results(
            api.url_for(
                ScheduleAView,
                last_index=page1[-1]['sub_id'],
                last_contribution_receipt_date=page1[-1]['contribution_receipt_date'],
                sort='contribution_receipt_date',
                **self.kwargs
            )
        )
        self.assertEqual(len(page2), 10)
        last_date_results = filings[25:]
        null_date_results = filings[:5]
        last_date_results.extend(null_date_results)
        self.assertEqual(
            [int(each['sub_id']) for each in page2],
            [each.sub_id for each in last_date_results],
        )
        self.assertEqual(
            [each['contribution_receipt_date'] for each in page2],
            [
                each.contribution_receipt_date.strftime('%Y-%m-%d')
                if each.contribution_receipt_date
                else None
                for each in last_date_results
            ],
        )

    def test_schedule_a_null_pagination_with_null_sort_column_values_descending(self):
        filings = [
            factories.ScheduleAFactory(contribution_receipt_date=None)
            # this range should ensure the page has a null transition
            for _ in range(10)
        ]
        filings = filings + [
            factories.ScheduleAFactory(
                contribution_receipt_date=datetime.date(2016, 1, 1)
            )
            for _ in range(15)
        ]

        page1 = self._results(
            api.url_for(
                ScheduleAView,
                sort='-contribution_receipt_date',
                sort_reverse_nulls='true',
                **self.kwargs
            )
        )

        self.assertEqual(len(page1), 20)

        top_reversed_from_middle = filings[9::-1]
        reversed_from_bottom_to_middle = filings[-1:14:-1]
        top_reversed_from_middle.extend(reversed_from_bottom_to_middle)
        self.assertEqual(
            [int(each['sub_id']) for each in page1],
            [each.sub_id for each in top_reversed_from_middle],
        )
        self.assertEqual(
            [each['contribution_receipt_date'] for each in page1],
            [
                each.contribution_receipt_date.strftime('%Y-%m-%d')
                if each.contribution_receipt_date
                else None
                for each in top_reversed_from_middle
            ],
        )
        page2 = self._results(
            api.url_for(
                ScheduleAView,
                last_index=page1[-1]['sub_id'],
                last_contribution_receipt_date=page1[-1]['contribution_receipt_date'],
                sort='-contribution_receipt_date',
                **self.kwargs
            )
        )
        self.assertEqual(len(page2), 5)
        self.assertEqual(
            [int(each['sub_id']) for each in page2],
            [each.sub_id for each in filings[14:9:-1]],
        )
        self.assertEqual(
            [each['contribution_receipt_date'] for each in page2],
            [
                each.contribution_receipt_date.strftime('%Y-%m-%d')
                if each.contribution_receipt_date
                else None
                for each in filings[14:9:-1]
            ],
        )

    def test_schedule_a_null_pagination_with_null_sort_column_values_ascending(self):
        filings = [
            factories.ScheduleAFactory(contribution_receipt_date=None)
            # this range should ensure the page has a null transition
            for _ in range(10)
        ]
        filings = filings + [
            factories.ScheduleAFactory(
                contribution_receipt_date=datetime.date(2016, 1, 1)
            )
            for _ in range(15)
        ]

        page1 = self._results(
            api.url_for(
                ScheduleAView,
                sort='contribution_receipt_date',
                sort_reverse_nulls='true',
                **self.kwargs
            )
        )

        self.assertEqual(len(page1), 20)

        top_reversed_from_middle = filings[10::]
        reversed_from_bottom_to_middle = filings[0:5:]
        top_reversed_from_middle.extend(reversed_from_bottom_to_middle)
        self.assertEqual(
            [int(each['sub_id']) for each in page1],
            [each.sub_id for each in top_reversed_from_middle],
        )
        self.assertEqual(
            [each['contribution_receipt_date'] for each in page1],
            [
                each.contribution_receipt_date.strftime('%Y-%m-%d')
                if each.contribution_receipt_date
                else None
                for each in top_reversed_from_middle
            ],
        )

        page2_missing_sort_null_only = self.app.get(
            api.url_for(
                ScheduleAView,
                last_index=page1[-1]['sub_id'],
                sort='contribution_receipt_date',
                **self.kwargs
            )
        )
        self.assertEqual(page2_missing_sort_null_only.status_code, 422)

        page2 = self._results(
            api.url_for(
                ScheduleAView,
                last_index=page1[-1]['sub_id'],
                sort_null_only=True,
                sort='contribution_receipt_date',
                **self.kwargs
            )
        )
        self.assertEqual(len(page2), 5)
        self.assertEqual(
            [int(each['sub_id']) for each in page2],
            [each.sub_id for each in filings[5:10:]],
        )
        self.assertEqual(
            [each['contribution_receipt_date'] for each in page2],
            [
                each.contribution_receipt_date.strftime('%Y-%m-%d')
                if each.contribution_receipt_date
                else None
                for each in filings[5:10:]
            ],
        )

    def test_schedule_a_pagination_with_null_sort_column_parameter(self):
        response = self.app.get(
            api.url_for(
                ScheduleAView,
                sort='contribution_receipt_date',
                last_contribution_receipt_date='null',
            )
        )
        self.assertEqual(response.status_code, 422)

    def test_schedule_a_pagination_bad_per_page(self):
        response = self.app.get(
            api.url_for(ScheduleAView, two_year_transaction_period=2018, per_page=999)
        )
        self.assertEqual(response.status_code, 422)

    def test_schedule_a_image_number(self):
        image_number = '12345'
        [
            factories.ScheduleAFactory(),
            factories.ScheduleAFactory(image_number=image_number),
        ]
        results = self._results(
            api.url_for(ScheduleAView, image_number=image_number, **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['image_number'], image_number)

    def test_schedule_a_image_number_range(self):
        [
            factories.ScheduleAFactory(image_number='1'),
            factories.ScheduleAFactory(image_number='2'),
            factories.ScheduleAFactory(image_number='3'),
            factories.ScheduleAFactory(image_number='4'),
        ]
        results = self._results(
            api.url_for(
                ScheduleAView, min_image_number='2', two_year_transaction_period=2016
            )
        )
        self.assertTrue(all(each['image_number'] >= '2' for each in results))
        results = self._results(
            api.url_for(
                ScheduleAView, max_image_number='3', two_year_transaction_period=2016
            )
        )
        self.assertTrue(all(each['image_number'] <= '3' for each in results))
        results = self._results(
            api.url_for(
                ScheduleAView,
                min_image_number='2',
                max_image_number='3',
                two_year_transaction_period=2016,
            )
        )
        self.assertTrue(all('2' <= each['image_number'] <= '3' for each in results))

    def test_schedule_a_amount(self):
        [
            factories.ScheduleAFactory(contribution_receipt_amount=50),
            factories.ScheduleAFactory(contribution_receipt_amount=100),
            factories.ScheduleAFactory(contribution_receipt_amount=150),
            factories.ScheduleAFactory(contribution_receipt_amount=200),
        ]
        results = self._results(
            api.url_for(ScheduleAView, min_amount=100, two_year_transaction_period=2016)
        )
        self.assertTrue(
            all(each['contribution_receipt_amount'] >= 100 for each in results)
        )
        results = self._results(
            api.url_for(ScheduleAView, max_amount=150, two_year_transaction_period=2016)
        )
        self.assertTrue(
            all(each['contribution_receipt_amount'] <= 150 for each in results)
        )
        results = self._results(
            api.url_for(
                ScheduleAView,
                min_amount=100,
                max_amount=150,
                two_year_transaction_period=2016,
            )
        )
        self.assertTrue(
            all(100 <= each['contribution_receipt_amount'] <= 150 for each in results)
        )

    def test_schedule_a_max_filter_count(self):
        max_count = 10
        filters_with_max_count = [
            ('committee_id', [str(number) for number in range(max_count + 1)]),
            ('contributor_name', [str(number) for number in range(max_count + 1)]),
            ('contributor_zip', [str(number) for number in range(max_count + 1)]),
            ('contributor_city', [str(number) for number in range(max_count + 1)]),
            ('contributor_employer', [str(number) for number in range(max_count + 1)]),
            ('contributor_occupation', [str(number) for number in range(max_count + 1)]),
        ]
        for label, values in filters_with_max_count:
            response = self.app.get(
                api.url_for(ScheduleAView, **{label: values})
            )
            self.assertEqual(response.status_code, 422)

    def test_schedule_a_efile_filters(self):
        filters = [
            ('image_number', ScheduleAEfile.image_number, ['123', '456']),
            ('committee_id', ScheduleAEfile.committee_id, ['C01', 'C02']),
            # may have to rethink this, currently on efile itemized resources the city isn't all caps
            # but for processed it is, is that something we are forcing when when
            # we build the tables?
            (
                'contributor_city',
                ScheduleAEfile.contributor_city,
                ['KANSAS CITY', 'HONOLULU'],
            ),
        ]
        for label, column, values in filters:
            [factories.ScheduleAEfileFactory(**{column.key: value}) for value in values]
            results = self._results(
                api.url_for(ScheduleAEfileView, **{label: values[0]})
            )
            assert len(results) == 1
            assert results[0][column.key] == values[0]

    def test_schedule_a_load_date_filter(self):
        [
            factories.ScheduleAFactory(load_date=datetime.date(2020, 1, 2)),
            factories.ScheduleAFactory(load_date=datetime.date(2020, 1, 3)),
            factories.ScheduleAFactory(load_date=datetime.date(2020, 1, 1)),
            factories.ScheduleAFactory(load_date=datetime.date(2019, 12, 31)),
        ]

        results = self._results(
            api.url_for(ScheduleAView, min_load_date='2020-01-01', **self.kwargs)
        )
        self.assertTrue(
            all(
                datetime.datetime.strptime(each['load_date'][:10], '%Y-%m-%d').date()
                >= datetime.date(2020, 1, 1)
                for each in results
            )
        )

        results = self._results(
            api.url_for(ScheduleAView, max_load_date='2020-01-01', **self.kwargs)
        )
        self.assertTrue(
            all(
                datetime.datetime.strptime(each['load_date'][:10], '%Y-%m-%d').date()
                <= datetime.date(2020, 1, 1)
                for each in results
            )
        )


class TestScheduleB(ApiBaseTest):
    kwargs = {'two_year_transaction_period': 2016}

    def test_schedule_b_multiple_two_year_transaction_period(self):
        """
        testing schedule_b api can take multiple cyccles now
        """
        disbursements = [  # noqa
            factories.ScheduleBFactory(
                report_year=2014, two_year_transaction_period=2014
            ),
            factories.ScheduleBFactory(
                report_year=2016, two_year_transaction_period=2016
            ),
            factories.ScheduleBFactory(
                report_year=2018, two_year_transaction_period=2018
            ),
        ]
        response = self._response(
            api.url_for(ScheduleBView, two_year_transaction_period=[2016, 2018],)
        )
        self.assertEqual(len(response['results']), 2)

    def test_schedule_b_spender_committee_type_filter(self):
        [
            factories.ScheduleBFactory(spender_committee_type='S'),
            factories.ScheduleBFactory(spender_committee_type='S'),
            factories.ScheduleBFactory(spender_committee_type='P'),
        ]
        results = self._results(
            api.url_for(ScheduleBView, spender_committee_type='S', **self.kwargs)
        )
        self.assertEqual(len(results), 2)

    def test_schedule_b_spender_org_type_filter(self):
        [
            factories.ScheduleBFactory(spender_committee_org_type='W'),
            factories.ScheduleBFactory(spender_committee_org_type='W'),
            factories.ScheduleBFactory(spender_committee_org_type='C'),
        ]
        results = self._results(
            api.url_for(ScheduleBView, spender_committee_org_type='W', **self.kwargs)
        )
        self.assertEqual(len(results), 2)

    def test_schedule_b_spender_designation_filter(self):
        [
            factories.ScheduleBFactory(spender_committee_designation='P'),
            factories.ScheduleBFactory(spender_committee_designation='P'),
            factories.ScheduleBFactory(spender_committee_designation='A'),
        ]
        results = self._results(
            api.url_for(ScheduleBView, spender_committee_designation='P', **self.kwargs)
        )
        self.assertEqual(len(results), 2)

    def test_schedule_b_pagination_with_sort_expression(self):
        # NOTE:  Schedule B is sorted by disbursement date with the expression
        # sa.func.coalesce(self.disbursement_date, sa.cast('9999-12-31', sa.Date))
        # by default (in descending order), so we must account for that with the
        # results and slice the baseline list of objects accordingly!
        filings = [factories.ScheduleBFactory() for _ in range(30)]
        page1 = self._results(api.url_for(ScheduleBView, **self.kwargs))
        self.assertEqual(len(page1), 20)
        self.assertEqual(
            [int(each['sub_id']) for each in page1],
            [each.sub_id for each in filings[:-21:-1]],
        )
        page2_missing_sort_null_only = self.app.get(
            api.url_for(
                ScheduleBView,
                last_index=page1[-1]['sub_id'],
                **self.kwargs
            )
        )
        self.assertEqual(page2_missing_sort_null_only.status_code, 422)
        page2 = self._results(
            api.url_for(
                ScheduleBView,
                last_index=page1[-1]['sub_id'],
                sort_null_only=True,
                **self.kwargs
            )
        )
        self.assertEqual(len(page2), 10)
        self.assertEqual(
            [int(each['sub_id']) for each in page2],
            [each.sub_id for each in filings[9::-1]],
        )

    def test_schedule_b_pagination_with_null_sort_column_values_with_sort_expression(
        self,
    ):
        # NOTE:  Schedule B is sorted by disbursement date with the expression
        # sa.func.coalesce(self.disbursement_date, sa.cast('9999-12-31', sa.Date))
        # by default (in descending order), so we must account for that with the
        # results and slice the baseline list of objects accordingly!
        filings = [factories.ScheduleBFactory(disbursement_date=None) for _ in range(5)]
        filings = filings + [
            factories.ScheduleBFactory(disbursement_date=datetime.date(2016, 1, 1))
            for _ in range(25)
        ]
        page1 = self._results(
            api.url_for(ScheduleBView, sort='disbursement_date', **self.kwargs)
        )
        self.assertEqual(len(page1), 20)
        self.assertEqual(
            [int(each['sub_id']) for each in page1],
            [each.sub_id for each in filings[5:25]],
        )
        self.assertEqual(
            [each['disbursement_date'] for each in page1],
            [
                each.disbursement_date.strftime('%Y-%m-%d')
                if each.disbursement_date
                else None
                for each in filings[5:25]
            ],
        )
        page2_missing_last_disbursement_date = self.app.get(
            api.url_for(
                ScheduleBView,
                last_index=page1[-1]['sub_id'],
                sort='disbursement_date',
                **self.kwargs
            )
        )
        self.assertEqual(page2_missing_last_disbursement_date.status_code, 422)

        page2 = self._results(
            api.url_for(
                ScheduleBView,
                last_index=page1[-1]['sub_id'],
                last_disbursement_date=page1[-1]['disbursement_date'],
                sort='disbursement_date',
                **self.kwargs
            )
        )
        self.assertEqual(len(page2), 10)
        last_date_results = filings[25:]
        null_date_results = filings[:5]
        last_date_results.extend(null_date_results)
        self.assertEqual(
            [int(each['sub_id']) for each in page2],
            [each.sub_id for each in last_date_results],
        )
        self.assertEqual(
            [each['disbursement_date'] for each in page2],
            [
                each.disbursement_date.strftime('%Y-%m-%d')
                if each.disbursement_date
                else None
                for each in last_date_results
            ],
        )

    def test_schedule_b_null_pagination_with_null_sort_column_values_descending_with_sort_expression(
        self,
    ):
        # NOTE:  Schedule B is sorted by disbursement date with the expression
        # sa.func.coalesce(self.disbursement_date, sa.cast('9999-12-31', sa.Date))
        # by default (in descending order), so we must account for that with the
        # results and slice the baseline list of objects accordingly!
        filings = [
            factories.ScheduleBFactory(disbursement_date=None)
            # this range should ensure the page has a null transition
            for _ in range(10)
        ]
        filings = filings + [
            factories.ScheduleBFactory(disbursement_date=datetime.date(2016, 1, 1))
            for _ in range(15)
        ]

        page1 = self._results(
            api.url_for(
                ScheduleBView,
                sort='-disbursement_date',
                sort_reverse_nulls='true',
                **self.kwargs
            )
        )

        self.assertEqual(len(page1), 20)

        top_reversed_from_middle = filings[9::-1]
        reversed_from_bottom_to_middle = filings[-1:14:-1]
        top_reversed_from_middle.extend(reversed_from_bottom_to_middle)
        self.assertEqual(
            [int(each['sub_id']) for each in page1],
            [each.sub_id for each in top_reversed_from_middle],
        )
        self.assertEqual(
            [each['disbursement_date'] for each in page1],
            [
                each.disbursement_date.strftime('%Y-%m-%d')
                if each.disbursement_date
                else None
                for each in top_reversed_from_middle
            ],
        )
        page2 = self._results(
            api.url_for(
                ScheduleBView,
                last_index=page1[-1]['sub_id'],
                last_disbursement_date=page1[-1]['disbursement_date'],
                sort='-disbursement_date',
                **self.kwargs
            )
        )
        self.assertEqual(len(page2), 5)
        self.assertEqual(
            [int(each['sub_id']) for each in page2],
            [each.sub_id for each in filings[14:9:-1]],
        )
        self.assertEqual(
            [each['disbursement_date'] for each in page2],
            [
                each.disbursement_date.strftime('%Y-%m-%d')
                if each.disbursement_date
                else None
                for each in filings[14:9:-1]
            ],
        )

    def test_schedule_b_null_pagination_with_null_sort_column_values_ascending_with_sort_expression(
        self,
    ):
        # NOTE:  Schedule B is sorted by disbursement date with the expression
        # sa.func.coalesce(self.disbursement_date, sa.cast('9999-12-31', sa.Date))
        # by default (in descending order), so we must account for that with the
        # results and slice the baseline list of objects accordingly!
        filings = [
            factories.ScheduleBFactory(disbursement_date=None)
            # this range should ensure the page has a null transition
            for _ in range(10)
        ]
        filings = filings + [
            factories.ScheduleBFactory(disbursement_date=datetime.date(2016, 1, 1))
            for _ in range(15)
        ]

        page1 = self._results(
            api.url_for(
                ScheduleBView,
                sort='disbursement_date',
                sort_reverse_nulls='true',
                **self.kwargs
            )
        )

        self.assertEqual(len(page1), 20)

        top_reversed_from_middle = filings[10::]
        reversed_from_bottom_to_middle = filings[0:5:]
        top_reversed_from_middle.extend(reversed_from_bottom_to_middle)
        self.assertEqual(
            [int(each['sub_id']) for each in page1],
            [each.sub_id for each in top_reversed_from_middle],
        )
        self.assertEqual(
            [each['disbursement_date'] for each in page1],
            [
                each.disbursement_date.strftime('%Y-%m-%d')
                if each.disbursement_date
                else None
                for each in top_reversed_from_middle
            ],
        )
        page2 = self._results(
            api.url_for(
                ScheduleBView,
                last_index=page1[-1]['sub_id'],
                sort_null_only=True,
                sort='disbursement_date',
                **self.kwargs
            )
        )
        self.assertEqual(len(page2), 5)
        self.assertEqual(
            [int(each['sub_id']) for each in page2],
            [each.sub_id for each in filings[5:10:]],
        )
        self.assertEqual(
            [each['disbursement_date'] for each in page2],
            [
                each.disbursement_date.strftime('%Y-%m-%d')
                if each.disbursement_date
                else None
                for each in filings[5:10:]
            ],
        )

    def test_schedule_b_pagination_with_null_sort_column_parameter_with_sort_expression(
        self,
    ):
        # NOTE:  Schedule B is sorted by disbursement date with the expression
        # sa.func.coalesce(self.disbursement_date, sa.cast('9999-12-31', sa.Date))
        # by default (in descending order), so we must account for that with the
        # results and slice the baseline list of objects accordingly!
        response = self.app.get(
            api.url_for(
                ScheduleBView, sort='disbursement_date', last_disbursement_date='null'
            )
        )
        self.assertEqual(response.status_code, 422)

    def test_schedule_b_amount(self):
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
        results = self._results(
            api.url_for(ScheduleBView, min_amount=100, max_amount=150)
        )
        self.assertTrue(
            all(100 <= each['disbursement_amount'] <= 150 for each in results)
        )

    def test_schedule_b_sort_ignores_nulls_last_parameter(self):
        disbursements = [
            factories.ScheduleBFactory(disbursement_amount=50),
            factories.ScheduleBFactory(
                disbursement_amount=200, disbursement_date=datetime.date(2016, 3, 1)
            ),
            factories.ScheduleBFactory(
                disbursement_amount=150, disbursement_date=datetime.date(2016, 2, 1)
            ),
            factories.ScheduleBFactory(
                disbursement_amount=100, disbursement_date=datetime.date(2016, 1, 1)
            ),
        ]
        sub_ids = [str(each.sub_id) for each in disbursements]
        results = self._results(
            api.url_for(
                ScheduleBView,
                sort='-disbursement_date',
                sort_nulls_last=True,
                **self.kwargs
            )
        )
        self.assertEqual([each['sub_id'] for each in results], sub_ids)

    def test_schedule_b_efile_filters(self):
        filters = [
            ('image_number', ScheduleBEfile.image_number, ['123', '456']),
            ('committee_id', ScheduleBEfile.committee_id, ['C01', 'C02']),
            (
                'recipient_state',
                ScheduleBEfile.recipient_state,
                ['MISSOURI', 'NEW YORK'],
            ),
        ]
        for label, column, values in filters:
            [factories.ScheduleBEfileFactory(**{column.key: value}) for value in values]
            results = self._results(
                api.url_for(ScheduleBEfileView, **{label: values[0]})
            )
            assert len(results) == 1
            assert results[0][column.key] == values[0]


# Test endpoints:
# /schedules/schedule_e/ (sched_e.ScheduleEView)
# /schedules/schedule_e/efile/ (sched_e.ScheduleEEfileView)
class TestScheduleE(ApiBaseTest):
    kwargs = {'two_year_transaction_period': 2016}

    def test_schedule_e_sort_args_ascending(self):
        [
            factories.ScheduleEFactory(
                expenditure_amount=100,
                expenditure_date=datetime.date(2016, 1, 1),
                committee_id='101',
                support_oppose_indicator='s',
            ),
            factories.ScheduleEFactory(
                expenditure_amount=100,
                expenditure_date=datetime.date(2016, 1, 1),
                committee_id='101',
                support_oppose_indicator='o',
            ),
        ]
        results = self._results(
            api.url_for(ScheduleEView, sort='support_oppose_indicator')
        )
        self.assertEqual(results[0]['support_oppose_indicator'], 'o')

    def test_schedule_e_filter_dissemination_date_range(self):
        factories.ScheduleEFactory(dissemination_date=datetime.datetime(2023, 12, 30))
        factories.ScheduleEFactory(dissemination_date=datetime.datetime(2021, 8, 29))
        factories.ScheduleEFactory(dissemination_date=datetime.datetime(2019, 10, 25))
        factories.ScheduleEFactory(dissemination_date=datetime.datetime(2017, 6, 22))
        factories.ScheduleEFactory(dissemination_date=datetime.datetime(2015, 10, 15))

        results = self._results(
            api.url_for(
                ScheduleEView,
                min_dissemination_date=datetime.date.fromisoformat('2015-01-01'),
            )
        )
        assert len(results) == 5

        results = self._results(
            api.url_for(
                ScheduleEView,
                max_dissemination_date=datetime.date.fromisoformat('2021-10-25'),
            )
        )
        assert len(results) == 4

    def test_schedule_e_filters_date_range(self):
        factories.ScheduleEFactory(filing_date=datetime.datetime(2023, 12, 30))
        factories.ScheduleEFactory(filing_date=datetime.datetime(2021, 8, 29))
        factories.ScheduleEFactory(filing_date=datetime.datetime(2019, 10, 25))
        factories.ScheduleEFactory(filing_date=datetime.datetime(2017, 6, 22))
        factories.ScheduleEFactory(filing_date=datetime.datetime(2015, 10, 15))

        results = self._results(
            api.url_for(
                ScheduleEView, min_filing_date=datetime.date.fromisoformat('2015-01-01')
            )
        )
        assert len(results) == 5

        results = self._results(
            api.url_for(
                ScheduleEView, max_filing_date=datetime.date.fromisoformat('2021-10-25')
            )
        )
        assert len(results) == 4

    def test_schedule_e_amount(self):
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
        results = self._results(
            api.url_for(ScheduleEView, min_amount=100, max_amount=150)
        )
        self.assertTrue(
            all(100 <= each['expenditure_amount'] <= 150 for each in results)
        )

    def test_schedule_e_sort(self):
        expenditures = [
            factories.ScheduleEFactory(expenditure_amount=50),
            factories.ScheduleEFactory(
                expenditure_amount=100, expenditure_date=datetime.date(2016, 1, 1)
            ),
            factories.ScheduleEFactory(
                expenditure_amount=150, expenditure_date=datetime.date(2016, 2, 1)
            ),
            factories.ScheduleEFactory(
                expenditure_amount=200, expenditure_date=datetime.date(2016, 3, 1)
            ),
        ]
        sub_ids = [str(each.sub_id) for each in expenditures]
        results = self._results(
            api.url_for(ScheduleEView, sort='-expenditure_date', sort_nulls_last=True)
        )
        self.assertEqual([each['sub_id'] for each in results], sub_ids[::-1])

    def test_schedule_e_filters(self):
        filters = [
            ('image_number', ScheduleE.image_number, ['123', '456']),
            ('committee_id', ScheduleE.committee_id, ['C01', 'C02']),
            (
                'support_oppose_indicator',
                ScheduleE.support_oppose_indicator,
                ['S', 'O'],
            ),
            ('is_notice', ScheduleE.is_notice, [True, False]),
            ('candidate_office_state', ScheduleE.candidate_office_state, ['AZ', 'AK']),
            (
                'candidate_office_district',
                ScheduleE.candidate_office_district,
                ['00', '01'],
            ),
            ('candidate_party', ScheduleE.candidate_party, ['DEM', 'REP']),
            ('candidate_office', ScheduleE.candidate_office, ['H', 'S', 'P']),
        ]
        for label, column, values in filters:
            [factories.ScheduleEFactory(**{column.key: value}) for value in values]
            results = self._results(api.url_for(ScheduleEView, **{label: values[0]}))
            assert len(results) == 1
            assert results[0][column.key] == values[0]

    def test_schedule_e_filter_fulltext_pass(self):
        """
        test names that expect to be returned
        """
        payee_names = [
            'Test.com',
            'Test com',
            'Testerosa',
            'Test#com',
            'Test.com and Test.com',
        ]
        [factories.ScheduleEFactory(payee_name=payee) for payee in payee_names]
        results = self._results(api.url_for(ScheduleEView, payee_name='test'))
        self.assertEqual(len(results), len(payee_names))

    def test_filter_sched_e_spender_name_text(self):
        [
            factories.ScheduleEFactory(
                committee_id='C001', spender_name_text=sa.func.to_tsvector('international abc action committee C001'),
            ),
            factories.ScheduleEFactory(
                committee_id='C002', spender_name_text=sa.func.to_tsvector('international xyz action committee C002'),
            ),
        ]
        results = self._results(
            api.url_for(ScheduleEView, q_spender='action', **self.kwargs)
        )
        self.assertEqual(len(results), 2)
        results = self._results(
            api.url_for(ScheduleEView, q_spender='abc', **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        results = self._results(
            api.url_for(ScheduleEView, q_spender='C001', **self.kwargs)
        )
        self.assertEqual(len(results), 1)

    def test_schedule_e_filter_fulltext_fail(self):
        """
        test names that expect no returns
        """
        payee_names = ['#', '##', '@#$%^&*', '%', '', '  ']
        [factories.ScheduleEFactory(payee_name_text=payee) for payee in payee_names]
        results = self._results(api.url_for(ScheduleEView, payee_name=payee_names))
        self.assertEqual(len(results), 0)

    def test_schedule_e_sort_args_descending(self):
        [
            factories.ScheduleEFactory(
                expenditure_amount=100,
                expenditure_date=datetime.date(2016, 1, 1),
                committee_id='101',
                support_oppose_indicator='s',
            ),
            factories.ScheduleEFactory(
                expenditure_amount=100,
                expenditure_date=datetime.date(2016, 1, 1),
                committee_id='101',
                support_oppose_indicator='o',
            ),
        ]
        results = self._results(
            api.url_for(ScheduleEView, sort='-support_oppose_indicator')
        )
        self.assertEqual(results[0]['support_oppose_indicator'], 's')

    def test_schedule_e_expenditure_description_field(self):
        factories.ScheduleEFactory(committee_id='C001', expenditure_description='Advertising Costs')
        results = self._results(
            api.url_for(ScheduleEView, **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['expenditure_description'], 'Advertising Costs')

    def test_schedule_e_efile_filters(self):
        filters = [
            ('image_number', ScheduleEEfile.image_number, ['456', '789']),
            ('committee_id', ScheduleEEfile.committee_id, ['C01', 'C02']),
            (
                'support_oppose_indicator',
                ScheduleEEfile.support_oppose_indicator,
                ['S', 'O'],
            ),
            ('candidate_office', ScheduleEEfile.candidate_office, ['H', 'S', 'P']),
            ('candidate_party', ScheduleEEfile.candidate_party, ['DEM', 'REP']),
            (
                'candidate_office_state',
                ScheduleEEfile.candidate_office_state,
                ['AZ', 'AK'],
            ),
            (
                'candidate_office_district',
                ScheduleEEfile.candidate_office_district,
                ['00', '01'],
            ),
            ('filing_form', ScheduleEEfile.filing_form, ['F3X', 'F5']),
            ('is_notice', ScheduleE.is_notice, [True, False]),
        ]
        factories.EFilingsFactory(file_number=123)
        for label, column, values in filters:
            [factories.ScheduleEEfileFactory(**{column.key: value}) for value in values]
            results = self._results(
                api.url_for(ScheduleEEfileView, **{label: values[0]})
            )
            assert len(results) == 1
            assert results[0][column.key] == values[0]

    def test_schedule_e_efile_candidate_id_filter(self):
        filters = [
            ('candidate_id', ScheduleEEfile.candidate_id, ['S01', 'S02']),
        ]
        factories.EFilingsFactory(file_number=123)
        for label, column, values in filters:
            [factories.ScheduleEEfileFactory(**{column.key: value}) for value in values]
            results = self._results(
                api.url_for(ScheduleEEfileView, **{label: values[0]})
            )
            assert len(results) == 1
            assert results[0][column.key] == values[0]

    def test_schedule_e_efile_dissemination_date_range(self):

        min_date = datetime.date(2018, 1, 1)
        max_date = datetime.date(2019, 12, 31)

        results = self._results(
            api.url_for(ScheduleEEfileView, min_dissemination_date=min_date)
        )
        self.assertTrue(
            all(
                each for each in results if each['receipt_date'] >= min_date.isoformat()
            )
        )

        results = self._results(
            api.url_for(ScheduleEEfileView, max_dissemination_date=max_date)
        )
        self.assertTrue(
            all(
                each for each in results if each['receipt_date'] <= max_date.isoformat()
            )
        )

        results = self._results(
            api.url_for(
                ScheduleEEfileView,
                min_dissemination_date=min_date,
                max_dissemination_date=max_date,
            )
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_date.isoformat()
                <= each['dissemination_date']
                <= max_date.isoformat()
            )
        )

    def test_schedule_e_efile_filter_cand_search(self):
        [
            factories.ScheduleEEfileFactory(
                cand_fulltxt=sa.func.to_tsvector('C001, Rob, Senior')
            ),
            factories.ScheduleEEfileFactory(
                cand_fulltxt=sa.func.to_tsvector('C002, Ted, Berry')
            ),
            factories.ScheduleEEfileFactory(
                cand_fulltxt=sa.func.to_tsvector('C003, Rob, Junior')
            ),
        ]
        factories.EFilingsFactory(file_number=123)
        db.session.flush()
        results = self._results(api.url_for(ScheduleEEfileView, candidate_search='Rob'))
        assert len(results) == 2

    def test_filter_sched_e_most_recent(self):
        [
            factories.ScheduleEFactory(
                committee_id='C001', filing_form='F24', most_recent=True
            ),
            factories.ScheduleEFactory(
                committee_id='C002', filing_form='F5', most_recent=False
            ),
            factories.ScheduleEFactory(
                committee_id='C003', filing_form='F24', most_recent=True
            ),
            factories.ScheduleEFactory(
                committee_id='C004', filing_form='F3X', most_recent=True
            ),
            factories.ScheduleEFactory(committee_id='C005', filing_form='F3X'),
            factories.ScheduleEFactory(committee_id='C006', filing_form='F3X'),
        ]
        results = self._results(
            api.url_for(ScheduleEView, most_recent=True, **self.kwargs)
        )
        # Most recent should include null values
        self.assertEqual(len(results), 5)

    def test_filter_sched_e_efile_most_recent(self):
        [
            factories.ScheduleEEfileFactory(
                committee_id='C001', filing_form='F24', most_recent=True
            ),
            factories.ScheduleEEfileFactory(
                committee_id='C002', filing_form='F5', most_recent=False
            ),
            factories.ScheduleEEfileFactory(
                committee_id='C003', filing_form='F24', most_recent=True
            ),
            factories.ScheduleEEfileFactory(
                committee_id='C004', filing_form='F3X', most_recent=True
            ),
            factories.ScheduleEEfileFactory(committee_id='C005', filing_form='F3X'),
            factories.ScheduleEEfileFactory(committee_id='C006', filing_form='F3X'),
        ]
        factories.EFilingsFactory(file_number=123)
        db.session.flush()
        results = self._results(
            api.url_for(ScheduleEEfileView, most_recent=True, **self.kwargs)
        )
        # Most recent should include null values
        self.assertEqual(len(results), 5)


class TestScheduleH4(ApiBaseTest):
    kwargs = {'two_year_transaction_period': 2016}

    def test_schedule_h4_basic_accessibility(self):
        """
        testing schedule_h4 api_for very basic accessibility
        """
        factories.ScheduleH4Factory(report_year=2016, cycle=2016)
        results = self._results(api.url_for(ScheduleH4View, cycle=2016))
        self.assertEqual(len(results), 1)
        self.assertIn('cycle', results[0].keys())
        self.assertEqual(results[0]['cycle'], 2016)

    def test_schedule_h4_image_number(self):
        factories.ScheduleH4Factory(report_year=2016, cycle=2016, image_number='111')
        results = self._results(
            api.url_for(ScheduleH4View, cycle=2016, image_number='112')
        )
        self.assertEqual(len(results), 0)
        results = self._results(
            api.url_for(ScheduleH4View, cycle=2016, image_number='111')
        )
        self.assertEqual(len(results), 1)

    def test_schedule_h4_filters(self):
        [
            factories.ScheduleH4Factory(committee_id='C001', cycle=2016),
            factories.ScheduleH4Factory(committee_id='C002', cycle=2016),
            factories.ScheduleH4Factory(committee_id='C003', cycle=2016),
            factories.ScheduleH4Factory(committee_id='C004', cycle=2018),
        ]
        results = self._results(api.url_for(ScheduleH4View, cycle=2016))
        self.assertEqual(len(results), 3)
        results = self._results(api.url_for(ScheduleH4View, committee_id='C001'))
        self.assertEqual(len(results), 1)

    def test_schedule_h4_filter_fulltext_purpose_and(self):
        purposes = ['Test&Test', 'Test & Test', 'Test& Test', 'Test &Test']
        [
            factories.ScheduleH4Factory(disbursement_purpose=purpose)
            for purpose in purposes
        ]
        results = self._results(
            api.url_for(ScheduleH4View, disbursement_purpose='Test&Test', **self.kwargs)
        )
        self.assertIn(results[0]['disbursement_purpose'], purposes)
        results = self._results(
            api.url_for(
                ScheduleH4View, disbursement_purpose='Test & Test', **self.kwargs
            )
        )
        self.assertIn(results[0]['disbursement_purpose'], purposes)
        results = self._results(
            api.url_for(ScheduleH4View, disbursement_purpose='Test& Test', **self.kwargs)
        )
        self.assertIn(results[0]['disbursement_purpose'], purposes)
        results = self._results(
            api.url_for(ScheduleH4View, disbursement_purpose='Test &Test', **self.kwargs)
        )
        self.assertIn(results[0]['disbursement_purpose'], purposes)

    def test_schedule_h4_filter_payee_name_text_pass(self):
        payee_names = [
            'Test.com',
            'Test com',
            'Testerosa',
            'Test#com',
            'Not.com',
            'Test.com and Test.com',
        ]
        [factories.ScheduleH4Factory(payee_name=payee) for payee in payee_names]
        results = self._results(api.url_for(ScheduleH4View, payee_name='test'))
        self.assertEqual(len(results), len(payee_names))
