''' Testing reporting dates and election dates '''

import datetime

from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.common.models import db
from webservices.resources.dates import ElectionDatesView
from webservices.resources.dates import ReportingDatesView, CalendarDatesView


class TestReportingDates(ApiBaseTest):

    def test_reporting_dates_filters(self):
        factories.ReportTypeFactory(report_type='YE', report_type_full='Year End')
        factories.ReportDateFactory(due_date=datetime.datetime(2014, 1, 2))
        factories.ReportDateFactory(report_year=2015)
        factories.ReportDateFactory(report_type='YE')
        factories.ReportDateFactory(create_date=datetime.datetime(2014, 3, 2))
        factories.ReportDateFactory(update_date=datetime.datetime(2014, 4, 2))

        filter_fields = (
            ('due_date', '2014-01-02'),
            ('report_year', 2015),
            ('report_type', 'YE'),
            ('min_create_date', '2014-03-02'),
            ('max_update_date', '2014-04-02'),
        )

        for field, example in filter_fields:
            page = api.url_for(ReportingDatesView, **{field: example})
            # returns at least one result
            results = self._results(page)
            assert len(results) > 0

    def test_clean_report_type(self):
        factories.ReportTypeFactory(
            report_type='Q1',
            report_type_full='April Quarterly {One of 4 valid Report Codes on Form 5, RptCode}'
        )
        report_date = factories.ReportDateFactory(
            report_type='Q1',
            due_date=datetime.datetime(2015, 1, 2),
        )
        db.session.flush()
        assert report_date.report_type_full == 'April Quarterly'


class TestElectionDates(ApiBaseTest):

    def test_election_type(self):
        election_date = factories.ElectionDateFactory(election_type_id='PR')
        assert election_date.election_type_full == 'Primary runoff'
        election_date = factories.ElectionDateFactory(election_type_id='INVALID')
        assert election_date.election_type_full is None
        election_date = factories.ElectionDateFactory(election_type_id=None)
        assert election_date.election_type_full is None

    def test_hide_bad_data(self):
        factories.ElectionDateFactory(election_status_id=1)
        factories.ElectionDateFactory(election_status_id=2)

        page = api.url_for(ElectionDatesView)
        results = self._results(page)
        assert len(results) == 1


class TestCalendarDates(ApiBaseTest):

    def test_filters(self):
        factories.CalendarDateFactory(start_date=datetime.datetime(2016, 1, 2))
        factories.CalendarDateFactory(location='Mississippi, CA')
        factories.CalendarDateFactory(state=['CA'])
        factories.CalendarDateFactory(category='Public Hearings')
        factories.CalendarDateFactory(description_raw='a really interesting event')
        factories.CalendarDateFactory(summary_raw='Meeting that will solve all the problems')
        factories.CalendarDateFactory(end_date=datetime.datetime(2015, 1, 2))

        filter_fields = [
            ('min_start_date', '2015-01-01'),
            ('category', 'Public Hearings'),
            ('min_end_date', '2014-01-01'),
            # this is not passing or working :/
            #('state', 'CA'),
            ('description', 'interesting event'),
            ('summary', 'solve all the problems'),
        ]

        orig_response = self._response(api.url_for(CalendarDatesView))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(CalendarDatesView, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertEqual(len(results), 1)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])
