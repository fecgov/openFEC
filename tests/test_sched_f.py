import datetime
from tests import factories
from tests.common import ApiBaseTest
from webservices.rest import api
from webservices.schemas import ScheduleFSchema
from webservices.resources.sched_f import ScheduleFView, ScheduleFViewBySubId


class TestScheduleFView(ApiBaseTest):
    def test_fields(self):
        factories.ScheduleFFactory()

        results = self._results(api.url_for(ScheduleFView))

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0].keys(), ScheduleFSchema().fields.keys())

    def test_filter_image_number(self):
        factories.ScheduleFFactory(
            committee_id='C00000001',
            candidate_id='S00000001',
            election_cycle=2012,
            image_number='1'
            )
        factories.ScheduleFFactory(
            committee_id='C00000001',
            candidate_id='S00000001',
            election_cycle=2016,
            image_number='2'
            )
        factories.ScheduleFFactory(
            committee_id='C00000001',
            candidate_id='S00000001',
            election_cycle=2020,
            image_number='3'
            )
        factories.ScheduleFFactory(
            committee_id='C00000001',
            candidate_id='S00000001',
            election_cycle=2024,
            image_number='4'
            )

        results = self._results(api.url_for(ScheduleFView, image_number=2))
        self.assertEqual(results[0]['image_number'], '2')
        self.assertEqual(len(results), 1)

        results = self._results(api.url_for(ScheduleFView, min_image_number=2,
                                            max_image_number=4))
        self.assertEqual(len(results), 3)

    def test_filter_committee_id(self):
        factories.ScheduleFFactory(
            committee_id='C00000001',
            candidate_id='S00000001',
            election_cycle=2012,
            image_number=1
            )
        factories.ScheduleFFactory(
            committee_id='C00000002',
            candidate_id='S00000001',
            election_cycle=2016,
            image_number=2
            )

        results = self._results(api.url_for(ScheduleFView,
                                            committee_id='C00000002'))
        self.assertEqual(results[0]['committee_id'], 'C00000002')
        self.assertEqual(len(results), 1)

    def test_filter_candidate_id(self):
        factories.ScheduleFFactory(
            committee_id='C00000001',
            candidate_id='S00000001',
            election_cycle=2012,
            image_number=1
            )
        factories.ScheduleFFactory(
            committee_id='C00000002',
            candidate_id='H00000001',
            election_cycle=2016,
            image_number=2
            )

        results = self._results(api.url_for(ScheduleFView,
                                            candidate_id='S00000001'))
        self.assertEqual(results[0]['candidate_id'], 'S00000001')
        self.assertEqual(len(results), 1)

    def test_filter_cycle(self):
        factories.ScheduleFFactory(
            committee_id='C00000001',
            candidate_id='S00000001',
            election_cycle=2012,
            image_number=1
            )
        factories.ScheduleFFactory(
            committee_id='C00000001',
            candidate_id='S00000001',
            election_cycle=2016,
            image_number=2
            )
        factories.ScheduleFFactory(
            committee_id='C00000001',
            candidate_id='S00000001',
            election_cycle=2020,
            image_number=3
            )
        factories.ScheduleFFactory(
            committee_id='C00000001',
            candidate_id='S00000001',
            election_cycle=2024,
            image_number=4
            )

        results = self._results(api.url_for(ScheduleFView,
                                            cycle=2024))
        self.assertEqual(results[0]['election_cycle'], 2024)
        self.assertEqual(len(results), 1)

    def test_filter_form_line_number(self):
        factories.ScheduleFFactory(line_number='9', filing_form='F3X')
        factories.ScheduleFFactory(line_number='10', filing_form='F3X')
        factories.ScheduleFFactory(line_number='9', filing_form='F3')
        factories.ScheduleFFactory(line_number='9', filing_form='F3')

        results = self._results(
            api.url_for(ScheduleFView, form_line_number='f3X-9')
        )
        self.assertEqual(len(results), 1)

        results = self._results(
            api.url_for(ScheduleFView, form_line_number=('f3x-9', 'f3X-10'))
        )
        self.assertEqual(len(results), 2)

        # test NOT a form_line_number
        results = self._results(
            api.url_for(ScheduleFView, form_line_number='-F3x-10')
        )
        self.assertEqual(len(results), 3)

        response = self.app.get(
            api.url_for(ScheduleFView, form_line_number='f3x10')
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn(b'Invalid form_line_number', response.data)

    def test_filter_expenditure_date(self):
        factories.ScheduleFFactory(expenditure_date=datetime.date(2024, 1, 1))
        factories.ScheduleFFactory(expenditure_date=datetime.date(2023, 1, 1))
        factories.ScheduleFFactory(expenditure_date=datetime.date(2022, 1, 1))
        factories.ScheduleFFactory(expenditure_date=datetime.date(2021, 1, 1))

        min_date = datetime.date(2022, 1, 1)
        max_date = datetime.date(2024, 1, 1)

        results = self._results(api.url_for(ScheduleFView,
                                            min_date=min_date,
                                            max_date=max_date))
        self.assertEqual(len(results), 3)

        self.assertTrue(
            all(
                each
                for each in results
                if each['expenditure_date'] <= max_date.isoformat()
                and each['expenditure_date'] >= min_date.isoformat()
            )
        )

    def test_filter_expenditure_amount(self):
        factories.ScheduleFFactory(expenditure_amount=500)
        factories.ScheduleFFactory(expenditure_amount=1000)
        factories.ScheduleFFactory(expenditure_amount=200)
        factories.ScheduleFFactory(expenditure_amount=2000)

        results = self._results(api.url_for(ScheduleFView,
                                            min_amount=100,
                                            max_amount=1500))
        self.assertEqual(len(results), 3)

        self.assertTrue(
            all(
                each
                for each in results
                if each['expenditure_amount'] <= 1500
                and each['expenditure_amount'] >= 100
            )
        )

    def test_default_sort(self):
        factories.ScheduleFFactory(committee_id='C00000001',
                                   expenditure_date=datetime.date(2024, 1, 1))
        factories.ScheduleFFactory(committee_id='C00000002',
                                   expenditure_date=datetime.date(2023, 1, 1))
        factories.ScheduleFFactory(committee_id='C00000003',
                                   expenditure_date=datetime.date(2022, 1, 1))
        factories.ScheduleFFactory(committee_id='C00000004',
                                   expenditure_date=datetime.date(2021, 1, 1))

        results = self._results(api.url_for(ScheduleFView))

        self.assertEqual(len(results), 4)
        self.assertEqual(results[0]['committee_id'], 'C00000004')
        self.assertEqual(results[1]['committee_id'], 'C00000003')
        self.assertEqual(results[2]['committee_id'], 'C00000002')
        self.assertEqual(results[3]['committee_id'], 'C00000001')


class TestScheduleFViewBySubId(ApiBaseTest):
    def test_fields(self):

        factories.ScheduleFEfileFactory(sub_id='4321')

        results = self._results(api.url_for(ScheduleFViewBySubId,
                                            sub_id='4321'))

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0].keys(), ScheduleFSchema().fields.keys())
