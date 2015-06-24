import datetime

import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import db
from webservices.rest import api
from webservices.resources.sched_a import ScheduleAView


class TestItemized(ApiBaseTest):

    def test_sorting(self):
        [
            factories.ScheduleAFactory(report_year=2014, receipt_date=datetime.datetime(2014, 1, 1)),
            factories.ScheduleAFactory(report_year=2012, receipt_date=datetime.datetime(2012, 1, 1)),
            factories.ScheduleAFactory(report_year=1986, receipt_date=datetime.datetime(1986, 1, 1)),
        ]
        db.session.flush()
        response = self._response(api.url_for(ScheduleAView, sort='receipt_date'))
        self.assertEqual(
            [each['report_year'] for each in response['results']],
            [2012, 2014]
        )

    def test_sorting_bad_column(self):
        response = self.app.get(api.url_for(ScheduleAView, sort='bad_column'))
        self.assertEqual(response.status_code, 400)
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
