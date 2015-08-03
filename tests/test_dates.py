''' Testing reporting dates and election dates '''

import datetime

from webservices.rest import api
from webservices.resources.dates import ReportingDatesView

from tests import factories
from tests.common import ApiBaseTest

class TestReportingDates(ApiBaseTest):

    def test_reporting_dates_filters(self):
        [
            factories.ReportingDatesFactory(due_date=datetime.datetime(2014, 1, 2)),
            factories.ReportingDatesFactory(report_year=2015),
            factories.ReportingDatesFactory(report_type='YE'),
            factories.ReportingDatesFactory(create_date=datetime.datetime(2014, 3, 2)),
            factories.ReportingDatesFactory(update_date=datetime.datetime(2014, 4, 2)),
        ]

        filter_fields = (
            ('due_date', '2014-01-02'),
            ('report_year', 2015),
            ('report_type', 'YE'),
            ('create_date', '2014-03-02'),
            ('update_date', '2014-04-02'),
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(ReportingDatesView))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(ReportingDatesView, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)

    def test_upcoming(self):
        [
            factories.ReportingDatesFactory(report_type='YE', due_date=datetime.datetime(2014, 1, 2)),
            factories.ReportingDatesFactory(report_type='YE', due_date=datetime.datetime(2017, 1, 3)),
        ]

        page = api.url_for(ReportingDatesView, **{'upcoming': 'true'})
        results = self._results(page)

        self.assertEquals(len(results), 1)