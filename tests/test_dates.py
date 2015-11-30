''' Testing reporting dates and election dates '''

import datetime

from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.resources.dates import ElectionDatesView
from webservices.resources.dates import ReportingDatesView


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

        for field, example in filter_fields:
            page = api.url_for(ReportingDatesView, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)

    def test_upcoming(self):
        [
            factories.ReportingDatesFactory(report_type='YE', due_date=datetime.datetime(2014, 1, 2)),
            factories.ReportingDatesFactory(report_type='YE', due_date=datetime.datetime(2017, 1, 3)),
        ]

        page = api.url_for(ReportingDatesView, upcoming='true')
        results = self._results(page)

        self.assertEqual(len(results), 1)


class TestElectionDates(ApiBaseTest):

    def test_upcoming(self):
        [
            factories.ElectionDatesFactory(election_date=datetime.datetime(2014, 1, 2)),
            factories.ElectionDatesFactory(election_date=datetime.datetime(2017, 1, 3)),
        ]

        page = api.url_for(ElectionDatesView, upcoming='true')
        results = self._results(page)

        self.assertEqual(len(results), 1)

    def test_election_type(self):
        election_date = factories.ElectionDatesFactory(trc_election_type_id='PR')
        self.assertEqual(election_date.election_type_full, 'Primary runoff')
        election_date = factories.ElectionDatesFactory(trc_election_type_id='INVALID')
        self.assertEqual(election_date.election_type_full, None)
        election_date = factories.ElectionDatesFactory(trc_election_type_id=None)
        self.assertEqual(election_date.election_type_full, None)
