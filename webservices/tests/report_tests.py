from .common import ApiBaseTest
from tests import factories

from webservices.rest import api
from webservices.rest import ReportsView


class TestReports(ApiBaseTest):

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_reports_by_committee_id(self):
        committee = factories.CommitteeFactory(committee_type='P')
        committee_id = committee.committee_id
        committee_report = factories.ReportsPresidentialFactory(committee_id=committee_id)
        other_report = factories.ReportsPresidentialFactory()
        results = self._results(api.url_for(ReportsView, committee_id=committee_id))
        committee_ids = [each['committee_id'] for each in results]
        self.assertIn(committee_report.committee_id, committee_ids)
        self.assertNotIn(other_report.committee_id, committee_ids)

    def test_reports_by_committee_type(self):
        presidential_report = factories.ReportsPresidentialFactory()
        house_report = factories.ReportsHouseSenateFactory()
        results = self._results(api.url_for(ReportsView, committee_type='presidential'))
        committee_ids = [each['committee_id'] for each in results]
        self.assertIn(presidential_report.committee_id, committee_ids)
        self.assertNotIn(house_report.committee_id, committee_ids)

    def test_reports_by_committee_type_and_cycle(self):
        presidential_report_2012 = factories.ReportsPresidentialFactory(cycle=2012)
        presidential_report_2016 = factories.ReportsPresidentialFactory(cycle=2016)
        house_report_2016 = factories.ReportsHouseSenateFactory(cycle=2016)
        results = self._results(api.url_for(ReportsView, committee_type='presidential', year=2016))
        committee_ids = [each['committee_id'] for each in results]
        self.assertIn(presidential_report_2016.committee_id, committee_ids)
        self.assertNotIn(presidential_report_2012.committee_id, committee_ids)
        self.assertNotIn(house_report_2016.committee_id, committee_ids)
