import datetime

from marshmallow.utils import isoformat

from .common import ApiBaseTest
from tests import factories

from webservices.rest import api
from webservices.resources.reports import ReportsView


class TestReports(ApiBaseTest):

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def _check_committee_ids(self, results, positives=None, negatives=None):
        ids = [each['committee_id'] for each in results]
        for positive in (positives or []):
            self.assertIn(positive.committee_id, ids)
        for negative in (negatives or []):
            self.assertNotIn(negative.committee_id, ids)

    def test_reports_by_committee_id(self):
        committee = factories.CommitteeFactory(committee_type='P')
        committee_id = committee.committee_id
        history = factories.CommitteeHistoryFactory(
            committee_id=committee_id,
            committee_type='P',
        )
        committee_report = factories.ReportsPresidentialFactory(committee_id=committee_id)
        other_report = factories.ReportsPresidentialFactory()
        results = self._results(api.url_for(ReportsView, committee_id=committee_id))
        self._check_committee_ids(results, [committee_report], [other_report])

    def test_reports_by_committee_type(self):
        presidential_report = factories.ReportsPresidentialFactory()
        house_report = factories.ReportsHouseSenateFactory()
        results = self._results(api.url_for(ReportsView, committee_type='presidential'))
        self._check_committee_ids(results, [presidential_report], [house_report])

    def test_reports_by_committee_type_and_cycle(self):
        presidential_report_2012 = factories.ReportsPresidentialFactory(cycle=2012)
        presidential_report_2016 = factories.ReportsPresidentialFactory(cycle=2016)
        house_report_2016 = factories.ReportsHouseSenateFactory(cycle=2016)
        results = self._results(
            api.url_for(
                ReportsView,
                committee_type='presidential',
                cycle=2016,
            )
        )
        self._check_committee_ids(
            results,
            [presidential_report_2016],
            [presidential_report_2012, house_report_2016],
        )
        # Test repeated cycle parameter
        results = self._results(
            api.url_for(
                ReportsView,
                committee_type='presidential',
                cycle=[2016, 2018],
            )
        )
        self._check_committee_ids(
            results,
            [presidential_report_2016],
            [presidential_report_2012, house_report_2016],
        )

    def test_reports_by_committee_type_and_year(self):
        presidential_report_2012 = factories.ReportsPresidentialFactory(report_year=2012)
        presidential_report_2016 = factories.ReportsPresidentialFactory(report_year=2016)
        house_report_2016 = factories.ReportsHouseSenateFactory(report_year=2016)
        results = self._results(
            api.url_for(
                ReportsView,
                committee_type='presidential',
                year=2016,
            )
        )
        self._check_committee_ids(
            results,
            [presidential_report_2016],
            [presidential_report_2012, house_report_2016],
        )
        # Test repeated cycle parameter
        results = self._results(
            api.url_for(
                ReportsView,
                committee_type='presidential',
                year=[2016, 2018],
            )
        )
        self._check_committee_ids(
            results,
            [presidential_report_2016],
            [presidential_report_2012, house_report_2016],
        )

    def test_reports_sort(self):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        history = factories.CommitteeHistoryFactory(
            committee_id=committee_id,
            committee_type='H',
        )
        contributions = [0, 100]
        reports = [
            factories.ReportsHouseSenateFactory(committee_id=committee_id, net_contributions_period=contributions[0]),
            factories.ReportsHouseSenateFactory(committee_id=committee_id, net_contributions_period=contributions[1]),
        ]
        results = self._results(api.url_for(ReportsView, committee_id=committee_id, sort='-net_contributions_period'))
        self.assertEqual([each['net_contributions_period'] for each in results], contributions[::-1])

    def test_reports_sort_default(self):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        history = factories.CommitteeHistoryFactory(
            committee_id=committee_id,
            committee_type='H',
        )
        dates = [
            datetime.datetime(2015, 7, 4),
            datetime.datetime(2015, 7, 5),
        ]
        dates_formatted = [isoformat(each) for each in dates]
        reports = [
            factories.ReportsHouseSenateFactory(committee_id=committee_id, coverage_end_date=dates[0]),
            factories.ReportsHouseSenateFactory(committee_id=committee_id, coverage_end_date=dates[1]),
        ]
        results = self._results(api.url_for(ReportsView, committee_id=committee_id))
        self.assertEqual([each['coverage_end_date'] for each in results], dates_formatted[::-1])

    def test_reports_for_pdf_link(self):
        factories.ReportsPresidentialFactory(
            report_year=2016,
            beginning_image_number=12345678901,
        )

        results = self._results(
            api.url_for(
                ReportsView,
                committee_type='presidential',
            )
        )
        self.assertEqual(
            results[0]['pdf_url'],
            'http://docquery.fec.gov/pdf/901/12345678901/12345678901.pdf',
        )

    def test_no_pdf_link(self):
        """
        Old pdfs don't exist so we should not build links.
        """
        factories.ReportsPresidentialFactory(
            report_year=1990,
            beginning_image_number=56789012345,
        )

        results = self._results(
            api.url_for(
                ReportsView,
                committee_type='presidential',
            )
        )
        self.assertIsNone(results[0]['pdf_url'])
