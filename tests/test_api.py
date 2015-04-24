import json
import unittest

import sqlalchemy as sa

from webservices import rest
from webservices import schemas
from webservices.common import models
from .common import ApiBaseTest


class OverallTest(ApiBaseTest):
    # Candidate
    def test_header_info(self):
        response = self._response('/candidates')
        self.assertIn('api_version', response)
        self.assertIn('pagination', response)

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_full_text_search(self):
        # changed from 'james' to 'arnold' because 'james' falls victim to stemming,
        # and some results return 'jame' causing the assert to fail
        results = self._results('/candidates?q=arnold')
        for r in results:
            #txt = json.dumps(r).lower()
            self.assertIn('arnold', r['name'].lower())

    def test_full_text_search_with_whitespace(self):
        results = self._results('/candidates?q=barack obama')
        for r in results:
            txt = json.dumps(r).lower()
            self.assertIn('obama', txt)

    def test_full_text_no_results(self):
        results = self._results('/candidates?q=asdlkflasjdflkjasdl;kfj')
        self.assertEquals(results, [])

    def test_year_filter(self):
        results = self._results('/candidates?year=1988')
        for r in results:
            self.assertIn(1988, r['election_years'])

    def test_per_page_defaults_to_20(self):
        results = self._results('/candidates')
        self.assertEquals(len(results), 20)

    def test_per_page_param(self):
        results = self._results('/candidates?per_page=5')
        self.assertEquals(len(results), 5)

    def test_invalid_per_page_param(self):
        response = self.app.get('/candidates?per_page=-10')
        self.assertEquals(response.status_code, 400)
        response = self.app.get('/candidates?per_page=34.2')
        self.assertEquals(response.status_code, 400)
        response = self.app.get('/candidates?per_page=dynamic-wombats')
        self.assertEquals(response.status_code, 400)

    def test_page_param(self):
        page_one_and_two = self._results('/candidates?per_page=10&page=1')
        page_two = self._results('/candidates?per_page=5&page=2')
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

    def test_cand_filters(self):
        # checking one example from each field
        orig_response = self._response('/candidates')
        original_count = orig_response['pagination']['count']

        filter_fields = (
            ('office', 'H'),
            ('district', '00,02'),
            ('state', 'CA'),
            ('name', 'Obama'),
            ('party', 'DEM'),
            ('year', '2012,2014'),
            ('candidate_id', 'H0VA08040,P80003338'),
        )

        for field, example in filter_fields:
            page = "/candidates?%s=%s" % (field, example)
            print(page)
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])

    def test_name_endpoint_returns_unique_candidates_and_committees(self):
        results = self._results('/names?q=obama')
        cand_ids = [r['candidate_id'] for r in results if r['candidate_id']]
        self.assertEqual(len(cand_ids), len(set(cand_ids)))
        cmte_ids = [r['committee_id'] for r in results if r['committee_id']]
        self.assertEqual(len(cmte_ids), len(set(cmte_ids)))

    @unittest.skip('This is not a great view anymore')
    def test_multiple_cmtes_in_detail(self):
        response = self._results('/candidate/P80003338/committees')
        self.assertEquals(len(response[0]), 11)
        self.assertEquals(response['pagination']['count'], 11)

    def test_reports_house(self):
        committee = models.Committee.query.filter(models.Committee.committee_type == 'H').first()
        results = self._results(rest.api.url_for(rest.ReportsView, committee_id=committee.committee_id))
        assert results[0].keys() == schemas.ReportsHouseSenateSchema._declared_fields.keys()

    def test_reports_senate(self):
        committee = models.Committee.query.filter(models.Committee.committee_type == 'S').first()
        results = self._results(rest.api.url_for(rest.ReportsView, committee_id=committee.committee_id))
        assert results[0].keys() == schemas.ReportsHouseSenateSchema._declared_fields.keys()

    def test_reports_pac_party(self):
        committee = models.Committee.query.filter(sa.not_(models.Committee.committee_type.in_(['P', 'H', 'S']))).first()
        results = self._results(rest.api.url_for(rest.ReportsView, committee_id=committee.committee_id))
        assert results[0].keys() == schemas.ReportsPacPartySchema._declared_fields.keys()

    def test_reports_committee_not_found(self):
        resp = self.app.get(rest.api.url_for(rest.ReportsView, committee_id='fake'))
        self.assertEqual(resp.status_code, 404)
        self.assertEqual(resp.content_type, 'application/json')
        data = json.loads(resp.data.decode('utf-8'))
        self.assertIn('not found', data['message'].lower())

    @unittest.skip('Failing on Travis CI')
    def test_reports_presidential(self):
        committee = models.Committee.query.filter(models.Committee.committee_type == 'P').first()
        results = self._results(rest.api.url_for(rest.ReportsView, committee_id=committee.committee_id))
        assert results[0].keys() == schemas.ReportsPresidentialSchema._declared_fields.keys()

    @unittest.skip("Not implementing for now.")
    def test_total_field_filter(self):
        results_disbursements = self._results('/committee/C00347583/totals?fields=disbursements')
        results_recipts = self._results('/committee/C00347583/totals?fields=total_receipts_period')

        self.assertIn('disbursements', results_disbursements[0]['totals'][0])
        self.assertIn('total_receipts_period', results_recipts[0]['reports'][0])
        self.assertNotIn('reports', results_disbursements[0])
        self.assertNotIn('totals', results_recipts[0])

    def test_totals_committee_not_found(self):
        resp = self.app.get(rest.api.url_for(rest.TotalsView, committee_id='fake'))
        self.assertEqual(resp.status_code, 404)
        self.assertEqual(resp.content_type, 'application/json')
        data = json.loads(resp.data.decode('utf-8'))
        self.assertIn('not found', data['message'].lower())

    def test_total_cycle(self):
        committee, totals = models.db.session.query(
            models.Committee,
            models.CommitteeTotalsPresidential,
        ).join(
            models.CommitteeTotalsPresidential,
            models.Committee.committee_id == models.CommitteeTotalsPresidential.committee_id,
        ).filter(
            models.CommitteeTotalsPresidential.receipts != None,  # noqa
        ).order_by(
            models.CommitteeTotalsPresidential.cycle
        ).first()

        results = self._results(rest.api.url_for(rest.TotalsView, committee_id=committee.committee_id))
        self.assertEqual(results[0]['receipts'], totals.receipts)

    @unittest.skip("Not implementing for now.")
    def test_multiple_committee(self):
        results = self._results('/total?committee_id=C00002600,C00000422&fields=committtee_id')
        print(len(results))
        self.assertEquals(len(results), 2)

    # Typeahead name search
    def test_typeahead_name_search(self):
        results = self._results('/names?q=oba')
        self.assertGreaterEqual(len(results), 10)
        for r in results:
            self.assertIn('OBA', r['name'])

    def test_typeahead_name_search_missing_param(self):
        resp = self.app.get('/names')
        self.assertEqual(resp.status_code, 400)
        self.assertEqual(resp.content_type, 'application/json')
        data = json.loads(resp.data.decode('utf-8'))
        self.assertEqual(data['message'], 'Required parameter "q" not found.')
