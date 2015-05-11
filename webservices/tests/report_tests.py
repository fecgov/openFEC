from .common import ApiBaseTest
from tests import factories

from webservices.rest import api
from webservices.rest import ReportsView


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
