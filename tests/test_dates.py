''' Testing reporting dates and election dates '''

import datetime

from webservices.rest import db, api
from webservices.resources.dates import ReportingDatesView

from tests import factories
from tests.common import ApiBaseTest

class TestReportingDates(ApiBaseTest):

    def test_reporting_dates_filters(self):
        [
            factories.ReportingDatesFactory(due_date=datetime.datetime(2014, 1, 2)),
            factories.ReportingDatesFactory(report_year=datetime.datetime(2014, 2, 2)),
            factories.ReportingDatesFactory(report_type='YE'),
            factories.ReportingDatesFactory(create_date=datetime.datetime(2014, 3, 2)),
            factories.ReportingDatesFactory(update_date=datetime.datetime(2014, 4, 2)),
        ]

        filter_fields = (
            ('due_date', '01-02-2014'),
            ('report_year', '01-03-2014'),
            ('report_type', 'YE'),
            ('create_date', '01-04-2014'),
            ('update_date', '01-05-2014'),
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
    # def test_next(self):