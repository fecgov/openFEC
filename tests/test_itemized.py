import datetime

import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import db
from webservices.rest import api
from webservices.resources.sched_a import ScheduleAView
from webservices.resources.sched_b import ScheduleBView


class TestItemized(ApiBaseTest):

    def test_sorting(self):
        [
            factories.ScheduleAFactory(report_year=2014, contributor_receipt_date=datetime.datetime(2014, 1, 1)),
            factories.ScheduleAFactory(report_year=2012, contributor_receipt_date=datetime.datetime(2012, 1, 1)),
            factories.ScheduleAFactory(report_year=1986, contributor_receipt_date=datetime.datetime(1986, 1, 1)),
        ]
        db.session.flush()
        response = self._response(api.url_for(ScheduleAView, sort='contributor_receipt_date'))
        self.assertEqual(
            [each['report_year'] for each in response['results']],
            [2012, 2014]
        )

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

    def test_filter_fulltext(self):
        names = ['David Koch', 'George Soros']
        filings = [
            factories.ScheduleAFactory(contributor_name=name)
            for name in names
        ]
        [
            factories.ScheduleASearchFactory(
                sched_a_sk=filing.sched_a_sk,
                contributor_name_text=sa.func.to_tsvector(name),
            )
            for filing, name in zip(filings, names)
        ]
        results = self._results(api.url_for(ScheduleAView, contributor_name='soros'))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_name'], 'George Soros')

    def test_pagination(self):
        filings = [
            factories.ScheduleAFactory()
            for _ in range(30)
        ]
        page1 = self._results(api.url_for(ScheduleAView))
        self.assertEqual(len(page1), 20)
        self.assertEqual(
            [each['sched_a_sk'] for each in page1],
            [each.sched_a_sk for each in filings[:20]],
        )
        page2 = self._results(api.url_for(ScheduleAView, last_index=page1[-1]['sched_a_sk']))
        self.assertEqual(len(page2), 10)
        self.assertEqual(
            [each['sched_a_sk'] for each in page2],
            [each.sched_a_sk for each in filings[20:]],
        )

    def test_pdf_url(self):
        # TODO(jmcarp) Refactor as parameterized tests
        image_number = 39
        params = [
            (factories.ScheduleAFactory, ScheduleAView),
            (factories.ScheduleBFactory, ScheduleBView),
        ]
        for factory, resource in params:
            factory(image_number=image_number)
            results = self._results(api.url_for(resource))
            self.assertEqual(len(results), 1)
            self.assertEqual(
                results[0]['pdf_url'],
                'http://docquery.fec.gov/cgi-bin/fecimg/?{0}'.format(image_number),
            )

    def test_image_number(self):
        image_number = '12345'
        [
            factories.ScheduleAFactory(),
            factories.ScheduleAFactory(image_number=image_number),
        ]
        results = self._results(api.url_for(ScheduleAView, image_number=image_number))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['image_number'], image_number)

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

    def test_amount_sched_a(self):
        [
            factories.ScheduleAFactory(contributor_receipt_amount=50),
            factories.ScheduleAFactory(contributor_receipt_amount=100),
            factories.ScheduleAFactory(contributor_receipt_amount=150),
            factories.ScheduleAFactory(contributor_receipt_amount=200),
        ]
        results = self._results(api.url_for(ScheduleAView, min_amount=100))
        self.assertTrue(all(each['contributor_receipt_amount'] >= 100 for each in results))
        results = self._results(api.url_for(ScheduleAView, max_amount=150))
        self.assertTrue(all(each['contributor_receipt_amount'] <= 150 for each in results))
        results = self._results(api.url_for(ScheduleAView, min_amount=100, max_amount=150))
        self.assertTrue(all(100 <= each['contributor_receipt_amount'] <= 150 for each in results))

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
