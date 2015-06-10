import json
import datetime
import unittest

import sqlalchemy as sa
from marshmallow.utils import isoformat

from tests import factories
from tests.common import ApiBaseTest

from webservices import rest
from webservices import schemas
from webservices.rest import api
from webservices.rest import CandidateNameSearch
from webservices.rest import CommitteeNameSearch
from webservices.resources.totals import TotalsView
from webservices.resources.reports import ReportsView
from webservices.resources.candidates import CandidateList


class OverallTest(ApiBaseTest):
    # Candidate
    def test_header_info(self):
        response = self._response(api.url_for(CandidateList))
        self.assertIn('api_version', response)
        self.assertIn('pagination', response)

    def test_full_text_search(self):
        candidate = factories.CandidateFactory(name='Josiah Bartlet')
        factories.CandidateSearchFactory(
            id=candidate.candidate_id,
            fulltxt=sa.func.to_tsvector('Josiah Bartlet'),
        )
        rest.db.session.flush()
        results = self._results(api.url_for(CandidateList, q='bartlet'))
        self.assertEqual(len(results), 1)
        self.assertIn('josiah', results[0]['name'].lower())

    def test_full_text_search_with_whitespace(self):
        candidate = factories.CandidateFactory(name='Josiah Bartlet')
        factories.CandidateSearchFactory(
            id=candidate.candidate_id,
            fulltxt=sa.func.to_tsvector('Josiah Bartlet'),
        )
        rest.db.session.flush()
        results = self._results(api.url_for(CandidateList, q='bartlet josiah'))
        self.assertEqual(len(results), 1)
        self.assertIn('josiah', results[0]['name'].lower())

    def test_full_text_no_results(self):
        results = self._results(api.url_for(CandidateList, q='asdfasdf'))
        self.assertEquals(results, [])

    def test_cycle_filter(self):
        factories.CandidateFactory(cycles=[1986, 1988])
        factories.CandidateFactory(cycles=[2000, 2002])
        results = self._results(api.url_for(CandidateList, cycle=1988))
        self.assertEqual(len(results), 1)
        for result in results:
            self.assertIn(1988, result['cycles'])
        results = self._results(api.url_for(CandidateList, cycle=[1986, 2002]))
        self.assertEqual(len(results), 2)
        cycles = set([1986, 2002])
        for result in results:
            self.assertTrue(cycles.intersection(result['cycles']))

    def test_per_page_defaults_to_20(self):
        [factories.CandidateFactory() for _ in range(40)]
        results = self._results(api.url_for(CandidateList))
        self.assertEquals(len(results), 20)

    def test_per_page_param(self):
        [factories.CandidateFactory() for _ in range(20)]
        results = self._results(api.url_for(CandidateList, per_page=5))
        self.assertEquals(len(results), 5)

    def test_invalid_per_page_param(self):
        results = self.app.get(api.url_for(CandidateList, per_page=-10))
        self.assertEquals(results.status_code, 400)
        results = self.app.get(api.url_for(CandidateList, per_page=34.2))
        self.assertEquals(results.status_code, 400)
        results = self.app.get(api.url_for(CandidateList, per_page='dynamic-wombats'))
        self.assertEquals(results.status_code, 400)

    def test_page_param(self):
        [factories.CandidateFactory() for _ in range(20)]
        page_one_and_two = self._results(api.url_for(CandidateList, per_page=10, page=1))
        page_two = self._results(api.url_for(CandidateList, per_page=5, page=2))
        self.assertEqual(page_two[0], page_one_and_two[5])
        for itm in page_two:
            self.assertIn(itm, page_one_and_two)

    @unittest.skip('We are just showing one year at a time, this would be a good feature '
                   'for /candidate/<id> but it is not a priority right now')
    def test_multi_year(self):
        # testing search
        response = self._results('/candidate?candidate_id=P80003338&year=2012,2008')
        # search listing should aggregate years
        self.assertIn('2008, 2012', response)
        # testing single resource
        response = self._results('/candidate/P80003338?year=2012,2008')
        elections = response[0]['elections']
        self.assertEquals(len(elections), 2)

    @unittest.skip('This is not a great view anymore')
    def test_multiple_cmtes_in_detail(self):
        response = self._results('/candidate/P80003338/committees')
        self.assertEquals(len(response[0]), 11)
        self.assertEquals(response['pagination']['count'], 11)

    def test_totals_house_senate(self):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        factories.CommitteeHistoryFactory(committee_id=committee_id, committee_type='H')
        [
            factories.TotalsHouseSenateFactory(committee_id=committee_id, cycle=2008),
            factories.TotalsHouseSenateFactory(committee_id=committee_id, cycle=2012),
        ]
        response = self._results(api.url_for(TotalsView, committee_id=committee_id))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['cycle'], 2012)
        self.assertEqual(response[1]['cycle'], 2008)

    def _check_reports(self, committee_type, factory, schema):
        committee = factories.CommitteeFactory(committee_type=committee_type)
        factories.CommitteeHistoryFactory(
            committee_id=committee.committee_id,
            committee_type=committee_type,
        )
        end_dates = [datetime.datetime(2012, 1, 1), datetime.datetime(2008, 1, 1)]
        committee_id = committee.committee_id
        [
            factory(
                committee_id=committee_id,
                coverage_end_date=end_date,
            )
            for end_date in end_dates
        ]
        response = self._results(api.url_for(ReportsView, committee_id=committee_id))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['coverage_end_date'], isoformat(end_dates[0]))
        self.assertEqual(response[1]['coverage_end_date'], isoformat(end_dates[1]))
        assert response[0].keys() == schema().fields.keys()

    # TODO(jmcarp) Refactor as parameterized tests
    def test_reports(self):
        self._check_reports('H', factories.ReportsHouseSenateFactory, schemas.CommitteeReportsHouseSenateSchema)
        self._check_reports('S', factories.ReportsHouseSenateFactory, schemas.CommitteeReportsHouseSenateSchema)
        self._check_reports('P', factories.ReportsPresidentialFactory, schemas.CommitteeReportsPresidentialSchema)
        self._check_reports('X', factories.ReportsPacPartyFactory, schemas.CommitteeReportsPacPartySchema)

    def test_reports_committee_not_found(self):
        resp = self.app.get(api.url_for(ReportsView, committee_id='fake'))
        self.assertEqual(resp.status_code, 404)
        self.assertEqual(resp.content_type, 'application/json')
        data = json.loads(resp.data.decode('utf-8'))
        self.assertIn('not found', data['message'].lower())

    @unittest.skip("Not implementing for now.")
    def test_total_field_filter(self):
        results_disbursements = self._results('/committee/C00347583/totals?fields=disbursements')
        results_recipts = self._results('/committee/C00347583/totals?fields=total_receipts_period')

        self.assertIn('disbursements', results_disbursements[0]['totals'][0])
        self.assertIn('total_receipts_period', results_recipts[0]['reports'][0])
        self.assertNotIn('reports', results_disbursements[0])
        self.assertNotIn('totals', results_recipts[0])

    def test_totals_committee_not_found(self):
        resp = self.app.get(api.url_for(TotalsView, committee_id='fake'))
        self.assertEqual(resp.status_code, 404)
        self.assertEqual(resp.content_type, 'application/json')
        data = json.loads(resp.data.decode('utf-8'))
        self.assertIn('not found', data['message'].lower())

    def test_total_cycle(self):
        committee = factories.CommitteeFactory(committee_type='P')
        committee_id = committee.committee_id
        history = factories.CommitteeHistoryFactory(committee_id=committee_id, committee_type='P')
        receipts = 5
        totals = factories.TotalsPresidentialFactory(cycle=2012, committee_id=committee_id, receipts=receipts)

        results = self._results(api.url_for(TotalsView, committee_id=committee.committee_id))
        self.assertEqual(results[0]['receipts'], totals.receipts)

    # Typeahead name search
    def test_typeahead_candidate_search(self):
        [
            factories.CandidateSearchFactory(
                name='Bartlet {0}'.format(idx),
                fulltxt=sa.func.to_tsvector('Bartlet for America {0}'.format(idx)),
            )
            for idx in range(30)
        ]
        rest.db.session.flush()
        results = self._results(api.url_for(CandidateNameSearch, q='bartlet'))
        self.assertEqual(len(results), 20)
        ids = [r['id'] for r in results if r['id']]
        self.assertEqual(len(ids), len(set(ids)))
        for each in results:
            self.assertIn('bartlet', each['name'].lower())

    def test_typeahead_committee_search(self):
        [
            factories.CommitteeSearchFactory(
                name='Bartlet {0}'.format(idx),
                fulltxt=sa.func.to_tsvector('Bartlet for America {0}'.format(idx)),
            )
            for idx in range(30)
        ]
        rest.db.session.flush()
        results = self._results(api.url_for(CommitteeNameSearch, q='bartlet'))
        self.assertEqual(len(results), 20)
        ids = [r['id'] for r in results if r['id']]
        self.assertEqual(len(ids), len(set(ids)))
        for each in results:
            self.assertIn('bartlet', each['name'].lower())
