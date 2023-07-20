import json
import datetime

from marshmallow.utils import isoformat

from tests import factories
from tests.common import ApiBaseTest

from webservices import schemas
from webservices.rest import db
from webservices.rest import api
from webservices.resources.reports import (
    ReportsView,
    CommitteeReportsView,
    EFilingHouseSenateSummaryView,
    EFilingPresidentialSummaryView,
    EFilingPacPartySummaryView,
)


# Test endpoint:
# '/reports/<string:entity_type>/' under tag:'financial' (reports.ReportsView)
class TestReports(ApiBaseTest):
    def _check_committee_ids(self, results, positives=None, negatives=None):
        ids = [each['committee_id'] for each in results]
        for positive in positives or []:
            self.assertIn(positive.committee_id, ids)
        for negative in negatives or []:
            self.assertNotIn(negative.committee_id, ids)

    def test_reports_by_entity_type(self):
        presidential_report = factories.ReportsPresidentialFactory()
        house_report = factories.ReportsHouseSenateFactory()
        results = self._results(api.url_for(ReportsView, entity_type='presidential'))
        self._check_committee_ids(results, [presidential_report], [house_report])

    def test_reports_by_entity_type_and_cycle(self):
        presidential_report_2012 = factories.ReportsPresidentialFactory(cycle=2012)
        presidential_report_2016 = factories.ReportsPresidentialFactory(cycle=2016)
        house_report_2016 = factories.ReportsHouseSenateFactory(cycle=2016)
        results = self._results(
            api.url_for(ReportsView, entity_type='presidential', cycle=2016,)
        )
        self._check_committee_ids(
            results,
            [presidential_report_2016],
            [presidential_report_2012, house_report_2016],
        )
        # Test repeated cycle parameter
        results = self._results(
            api.url_for(ReportsView, entity_type='presidential', cycle=[2016, 2018],)
        )
        self._check_committee_ids(
            results,
            [presidential_report_2016],
            [presidential_report_2012, house_report_2016],
        )

    def test_reports_by_amended(self):
        params = [
            ('house-senate', factories.ReportsHouseSenateFactory),
            ('presidential', factories.ReportsPresidentialFactory),
            ('pac-party', factories.ReportsPacPartyFactory),
            ('ie-only', factories.ReportsIEOnlyFactory),
        ]

        for category, factory in params:
            reports = [
                factory(is_amended=False),
                factory(is_amended=True),
            ]
            results = self._results(api.url_for(ReportsView, entity_type=category))
            self.assertEqual(len(results), 2)

            results = self._results(
                api.url_for(ReportsView, entity_type=category, is_amended='false')
            )
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0]['committee_id'], reports[0].committee_id)

            results = self._results(
                api.url_for(ReportsView, entity_type=category, is_amended='true')
            )
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0]['committee_id'], reports[1].committee_id)

    def test_reports_by_entity_type_and_year(self):
        presidential_report_2012 = factories.ReportsPresidentialFactory(
            report_year=2012
        )
        presidential_report_2016 = factories.ReportsPresidentialFactory(
            report_year=2016
        )
        house_report_2016 = factories.ReportsHouseSenateFactory(report_year=2016)
        results = self._results(
            api.url_for(ReportsView, entity_type='presidential', year=2016,)
        )
        self._check_committee_ids(
            results,
            [presidential_report_2016],
            [presidential_report_2012, house_report_2016],
        )
        # Test repeated cycle parameter
        results = self._results(
            api.url_for(ReportsView, entity_type='presidential', year=[2016, 2018],)
        )
        self._check_committee_ids(
            results,
            [presidential_report_2016],
            [presidential_report_2012, house_report_2016],
        )

    def test_ie_only(self):
        number = 12345678902
        report = factories.ReportsIEOnlyFactory(
            beginning_image_number=number,
            independent_contributions_period=200,
            independent_expenditures_period=100,
        )
        results = self._results(
            api.url_for(
                ReportsView, entity_type='ie-only', beginning_image_number=number,
            )
        )
        result = results[0]
        for key in [
            'report_form',
            'independent_contributions_period',
            'independent_expenditures_period',
        ]:
            self.assertEqual(result[key], getattr(report, key))


# Test endpoint:
# '/committee/<string:committee_id>/reports/' under tag:'financial' (reports.CommitteeReportsView)
class TestCommitteeReports(ApiBaseTest):
    def _check_committee_ids(self, results, positives=None, negatives=None):
        ids = [each['committee_id'] for each in results]
        for positive in positives or []:
            self.assertIn(positive.committee_id, ids)
        for negative in negatives or []:
            self.assertNotIn(negative.committee_id, ids)

    def test_reports_by_committee_id(self):
        committee = factories.CommitteeFactory(committee_type='P')
        committee_id = committee.committee_id
        factories.CommitteeHistoryFactory(
            committee_id=committee_id, committee_type='P',
        )
        committee_report = factories.ReportsPresidentialFactory(
            committee_id=committee_id
        )
        other_report = factories.ReportsPresidentialFactory()
        results = self._results(
            api.url_for(CommitteeReportsView, committee_id=committee_id)
        )
        self._check_committee_ids(results, [committee_report], [other_report])

    def test_reports_sort(self):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        factories.CommitteeHistoryFactory(
            committee_id=committee_id, committee_type='H',
        )
        contributions = [0, 100]
        factories.ReportsHouseSenateFactory(
            committee_id=committee_id, net_contributions_period=contributions[0]
        )
        factories.ReportsHouseSenateFactory(
            committee_id=committee_id, net_contributions_period=contributions[1]
        )
        results = self._results(
            api.url_for(
                CommitteeReportsView,
                committee_id=committee_id,
                sort=['-net_contributions_period'],
            )
        )
        self.assertEqual(
            [each['net_contributions_period'] for each in results], contributions[::-1]
        )

    def test_reports_sort_default(self):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        factories.CommitteeHistoryFactory(
            committee_id=committee_id, committee_type='H',
        )
        dates = [
            datetime.datetime(2015, 7, 4),
            datetime.datetime(2015, 7, 5),
        ]
        dates_formatted = [isoformat(each) for each in dates]
        factories.ReportsHouseSenateFactory(
            committee_id=committee_id, coverage_end_date=dates[0]
        )
        factories.ReportsHouseSenateFactory(
            committee_id=committee_id, coverage_end_date=dates[1]
        )
        results = self._results(
            api.url_for(CommitteeReportsView, committee_id=committee_id)
        )
        self.assertEqual(
            [each['coverage_end_date'] for each in results], dates_formatted[::-1]
        )

    def test_reports_for_pdf_link(self):
        committee = factories.CommitteeFactory(committee_type='P')
        committee_id = committee.committee_id
        db.session.flush()
        number = 12345678901
        factories.ReportsPresidentialFactory(
            report_year=2016, beginning_image_number=number, committee_id=committee_id,
        )

        results = self._results(
            api.url_for(
                ReportsView,
                entity_type='presidential',
                beginning_image_number=number,
            )
        )
        self.assertEqual(
            results[0]['pdf_url'],
            'https://docquery.fec.gov/pdf/901/12345678901/12345678901.pdf',
        )

    def test_no_pdf_link(self):
        """
        Old pdfs don't exist so we should not build links.
        """
        committee = factories.CommitteeFactory(committee_type='P')
        committee_id = committee.committee_id
        db.session.flush()
        number = 56789012345
        factories.ReportsPresidentialFactory(
            report_year=1990, beginning_image_number=number, committee_id=committee_id,
        )

        results = self._results(
            api.url_for(
                ReportsView,
                entity_type='presidential',
                beginning_image_number=number,
            )
        )
        self.assertIsNone(results[0]['pdf_url'])

    def test_no_pdf_link_senate(self):
        """
        Old pdfs don't exist so we should not build links.
        """
        committee = factories.CommitteeFactory(committee_type='S')
        committee_id = committee.committee_id
        db.session.flush()
        number = 56789012346
        factories.ReportsHouseSenateFactory(
            report_year=1999, beginning_image_number=number, committee_id=committee_id,
        )

        results = self._results(
            api.url_for(
                ReportsView,
                entity_type='house-senate',
                beginning_image_number=number,
            )
        )
        self.assertIsNone(results[0]['pdf_url'])

    def test_report_type_include(self):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        factories.CommitteeHistoryFactory(
            committee_id=committee_id, committee_type='H',
        )
        factories.ReportsHouseSenateFactory(committee_id=committee_id, report_type='Q2')
        factories.ReportsHouseSenateFactory(committee_id=committee_id, report_type='M3')
        factories.ReportsHouseSenateFactory(
            committee_id=committee_id, report_type='TER'
        )
        results = self._results(
            api.url_for(
                CommitteeReportsView,
                committee_id=committee_id,
                report_type=['Q2', 'M3'],
            )
        )
        self.assertTrue(all(each['report_type'] in ['Q2', 'M3'] for each in results))

    def test_report_type_exclude(self):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        factories.CommitteeHistoryFactory(
            committee_id=committee_id, committee_type='H',
        )
        factories.ReportsHouseSenateFactory(committee_id=committee_id, report_type='Q2')
        factories.ReportsHouseSenateFactory(committee_id=committee_id, report_type='M3')
        factories.ReportsHouseSenateFactory(
            committee_id=committee_id, report_type='TER'
        )
        results = self._results(
            api.url_for(
                CommitteeReportsView, committee_id=committee_id, report_type=['-M3']
            )
        )
        self.assertTrue(all(each['report_type'] in ['Q2', 'TER'] for each in results))

    def test_ie_committee(self):
        committee = factories.CommitteeFactory(committee_type='I')
        committee_id = committee.committee_id
        factories.CommitteeHistoryFactory(
            committee_id=committee_id, committee_type='I',
        )
        report = factories.ReportsIEOnlyFactory(
            committee_id=committee_id,
            independent_contributions_period=200,
            independent_expenditures_period=100,
        )
        results = self._results(
            api.url_for(CommitteeReportsView, committee_id=committee_id,)
        )
        result = results[0]
        for key in [
            'report_form',
            'independent_contributions_period',
            'independent_expenditures_period',
        ]:
            self.assertEqual(result[key], getattr(report, key))

    def test_case_insensitivity(self):
        committee = factories.CommitteeFactory()
        committee_id = committee.committee_id
        factories.CommitteeHistoryFactory(
            committee_id=committee_id,
        )
        factories.ReportsIEOnlyFactory(
            committee_id=committee_id,
            independent_contributions_period=200,
            independent_expenditures_period=100,
        )
        results = self._results(
            api.url_for(CommitteeReportsView, committee_id=committee_id.lower(),)
        )
        for result in results:
            self.assertEqual(result["committee_id"], committee_id)

    def _check_reports(self, committee_type, factory, schema):
        committee = factories.CommitteeFactory(committee_type=committee_type)
        factories.CommitteeHistoryFactory(
            committee_id=committee.committee_id,
            committee_type=committee_type,
            cycle=2012,
        )
        end_dates = [datetime.datetime(2012, 1, 1), datetime.datetime(2008, 1, 1)]
        committee_id = committee.committee_id
        db.session.flush()
        [
            factory(
                committee_id=committee_id, coverage_end_date=end_date, report_year=2011,
            )
            for end_date in end_dates
        ]
        response = self._results(
            api.url_for(CommitteeReportsView, committee_id=committee_id)
        )
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['coverage_end_date'], isoformat(end_dates[0]))
        self.assertEqual(response[1]['coverage_end_date'], isoformat(end_dates[1]))
        assert response[0].keys() == schema().fields.keys()

    # TODO(jmcarp) Refactor as parameterized tests
    def test_reports(self):
        self._check_reports(
            'H',
            factories.ReportsHouseSenateFactory,
            schemas.CommitteeReportsHouseSenateSchema,
        )
        self._check_reports(
            'S',
            factories.ReportsHouseSenateFactory,
            schemas.CommitteeReportsHouseSenateSchema,
        )
        self._check_reports(
            'P',
            factories.ReportsPresidentialFactory,
            schemas.CommitteeReportsPresidentialSchema,
        )
        self._check_reports(
            'X',
            factories.ReportsPacPartyFactory,
            schemas.CommitteeReportsPacPartySchema,
        )

    def test_reports_committee_not_found(self):
        resp = self.app.get(api.url_for(CommitteeReportsView, committee_id='fake'))
        self.assertEqual(resp.status_code, 404)
        self.assertEqual(resp.content_type, 'application/json')
        data = json.loads(resp.data.decode('utf-8'))
        self.assertIn('not found', data['message'].lower())


# Test 3 endpoints:
# '/efile/reports/presidential/' under tag:'efiling' (reports.EFilingPresidentialSummaryView)
# '/efile/reports/house-senate/' under tag:'efiling' (reports.EFilingHouseSenateSummaryView)
# '/efile/reports/pac-party/' under tag:'efiling' (reports.EFilingPacPartySummaryView)
class TestEFileReports(ApiBaseTest):
    def _check_committee_ids(self, results, positives=None, negatives=None):
        ids = [each['committee_id'] for each in results]
        for positive in positives or []:
            self.assertIn(positive.committee_id, ids)
        for negative in negatives or []:
            self.assertNotIn(negative.committee_id, ids)

    def test_efile_presidential_reports(self):
        committee_id = 'C86753090'
        other_id = 'C2222222'

        committee_efile = factories.EfileReportsPresidentialFactory(
            committee_id=committee_id, cash_on_hand_end_period=20
        )
        other_efile = factories.EfileReportsPresidentialFactory(
            committee_id=other_id, cash_on_hand_end_period=40
        )

        results = self._results(
            api.url_for(
                EFilingPresidentialSummaryView,
                entity_type='presidential',
                committee_id=committee_id,
            )
        )

        self.assertEqual(results[0]['committee_id'], committee_id)
        self.assertEqual(results[0]['cash_on_hand_end_period'], 20)

        self._check_committee_ids(results, [committee_efile], [other_efile])

    def test_efile_pac_party_reports(self):
        committee_id = 'C8675310'
        other_id = 'C3333333'

        committee_efile = factories.EfileReportsPacPartyFactory(
            committee_id=committee_id
        )
        other_efile = factories.EfileReportsPacPartyFactory(committee_id=other_id)

        results = self._results(
            api.url_for(EFilingPacPartySummaryView, committee_id=committee_id)
        )

        self.assertEqual(results[0]['committee_id'], committee_id)
        self._check_committee_ids(results, [committee_efile], [other_efile])

    def test_efile_house_senate_reports(self):
        committee_id = 'C8675311'
        other_id = 'C1111111'

        committee_efile = factories.EfileReportsHouseSenateFactory(
            committee_id=committee_id
        )
        other_efile = factories.EfileReportsHouseSenateFactory(committee_id=other_id)

        results = self._results(
            api.url_for(
                EFilingHouseSenateSummaryView,
                entity_type='house-senate',
                committee_id=committee_id,
            )
        )

        self.assertEqual(results[0]['committee_id'], committee_id)

        self._check_committee_ids(results, [committee_efile], [other_efile])

    def test_filter_date_efile_reports(self):
        [
            factories.EfileReportsPacPartyFactory(
                receipt_date=datetime.date(2012, 1, 1)
            ),
            factories.EfileReportsPacPartyFactory(
                receipt_date=datetime.date(2013, 1, 1)
            ),
            factories.EfileReportsPacPartyFactory(
                receipt_date=datetime.date(2014, 1, 1)
            ),
            factories.EfileReportsPacPartyFactory(
                receipt_date=datetime.date(2015, 1, 1)
            ),
        ]

        min_date = datetime.date(2013, 1, 1)
        results = self._results(
            api.url_for(EFilingPacPartySummaryView, min_receipt_date=min_date)
        )
        self.assertTrue(
            all(
                each for each in results if each['receipt_date'] >= min_date.isoformat()
            )
        )
        max_date = datetime.date(2014, 1, 1)
        results = self._results(
            api.url_for(EFilingPacPartySummaryView, max_receipt_date=max_date)
        )
        self.assertTrue(
            all(
                each for each in results if each['receipt_date'] <= max_date.isoformat()
            )
        )
        results = self._results(
            api.url_for(
                EFilingPacPartySummaryView,
                min_receipt_date=min_date,
                max_receipt_date=max_date,
            )
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_date.isoformat() <= each['receipt_date'] <= max_date.isoformat()
            )
        )

    def test_reports_by_entity_type_and_committee_type(self):
        committee = factories.CommitteeFactory()
        committee_id = committee.committee_id
        presidential_report = factories.CommitteeHistoryFactory(
            committee_id=committee_id, committee_type='P',
        )
        factories.ReportsPresidentialFactory(
            committee_id=committee_id, report_year=2016,
        )
        results = self._results(
            api.url_for(ReportsView, entity_type='presidential', committee_type='P',)
        )
        self._check_committee_ids(
            results,
            [presidential_report],
        )
