import json
import datetime
import unittest

import sqlalchemy as sa

from marshmallow.utils import isoformat

from webservices import rest
from webservices import schemas
from webservices.common import models

from tests import factories
from tests.common import ApiBaseTest


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
        candidate = factories.CandidateFactory(name='Josiah Bartlet')
        factories.CandidateSearchFactory(
            cand_sk=candidate.candidate_key,
            fulltxt=sa.func.to_tsvector('Josiah Bartlet'),
        )
        rest.db.session.flush()
        results = self._results('/candidates?q=bartlet')
        self.assertEqual(len(results), 1)
        self.assertIn('josiah', results[0]['name'].lower())

    def test_full_text_search_with_whitespace(self):
        candidate = factories.CandidateFactory(name='Josiah Bartlet')
        factories.CandidateSearchFactory(
            cand_sk=candidate.candidate_key,
            fulltxt=sa.func.to_tsvector('Josiah Bartlet'),
        )
        rest.db.session.flush()
        results = self._results('/candidates?q=bartlet josiah')
        self.assertEqual(len(results), 1)
        self.assertIn('josiah', results[0]['name'].lower())

    def test_full_text_no_results(self):
        results = self._results('/candidates?q=asdlkflasjdflkjasdl;kfj')
        self.assertEquals(results, [])

    def test_year_filter(self):
        factories.CandidateFactory(election_years=[1986, 1988])
        factories.CandidateFactory(election_years=[2000, 2002])
        results = self._results('/candidates?year=1988')
        self.assertEqual(len(results), 1)
        for each in results:
            self.assertIn(1988, each['election_years'])

    def test_per_page_defaults_to_20(self):
        [factories.CandidateFactory() for _ in range(40)]
        results = self._results('/candidates')
        self.assertEquals(len(results), 20)

    def test_per_page_param(self):
        [factories.CandidateFactory() for _ in range(20)]
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
        [factories.CandidateFactory() for _ in range(20)]
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

    @unittest.skip('This is not a great view anymore')
    def test_multiple_cmtes_in_detail(self):
        response = self._results('/candidate/P80003338/committees')
        self.assertEquals(len(response[0]), 11)
        self.assertEquals(response['pagination']['count'], 11)

    def test_totals_house_senate(self):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        [
            factories.TotalsHouseSenateFactory(committee_id=committee_id, cycle=2008),
            factories.TotalsHouseSenateFactory(committee_id=committee_id, cycle=2012),
        ]
        response = self._results('/committee/{0}/totals'.format(committee_id))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['cycle'], 2012)
        self.assertEqual(response[1]['cycle'], 2008)

    def _check_reports(self, committee_type, factory, schema):
        committee = factories.CommitteeFactory(committee_type=committee_type)
        end_dates = [datetime.datetime(2012, 1, 1), datetime.datetime(2008, 1, 1)]
        committee_id = committee.committee_id
        [
            factory(
                committee_id=committee_id,
                coverage_end_date=end_date
            )
            for end_date in end_dates
        ]
        response = self._results('/committee/{0}/reports'.format(committee_id))
        self.assertEqual(len(response), 2)
        self.assertEqual(response[0]['coverage_end_date'], isoformat(end_dates[0]))
        self.assertEqual(response[1]['coverage_end_date'], isoformat(end_dates[1]))
        assert response[0].keys() == schema._declared_fields.keys()

    def test_reports(self):
        self._check_reports('H', factories.ReportsHouseSenateFactory, schemas.ReportsHouseSenateSchema)
        self._check_reports('S', factories.ReportsHouseSenateFactory, schemas.ReportsHouseSenateSchema)
        self._check_reports('P', factories.ReportsPresidentialFactory, schemas.ReportsPresidentialSchema)
        self._check_reports('X', factories.ReportsPacPartyFactory, schemas.ReportsPacPartySchema)

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
        committee = factories.CommitteeFactory(committee_type='P')
        committee_id = committee.committee_id
        receipts = 5
        totals = factories.TotalsPresidentialFactory(cycle=2012, committee_id=committee_id, receipts=receipts)

        results = self._results(rest.api.url_for(rest.TotalsView, committee_id=committee.committee_id))
        self.assertEqual(results[0]['receipts'], totals.receipts)

    @unittest.skip("Not implementing for now.")
    def test_multiple_committee(self):
        results = self._results('/total?committee_id=C00002600,C00000422&fields=committtee_id')
        print(len(results))
        self.assertEquals(len(results), 2)

    # Typeahead name search
    def test_typeahead_name_search(self):
        [
            factories.NameSearchFactory(
                name='Bartlet {0}'.format(idx),
                name_vec=sa.func.to_tsvector('Bartlet for America {0}'.format(idx)),
            )
            for idx in range(30)
        ]
        rest.db.session.flush()
        results = self._results('/names?q=bartlet')
        self.assertEqual(len(results), 20)
        cand_ids = [r['candidate_id'] for r in results if r['candidate_id']]
        self.assertEqual(len(cand_ids), len(set(cand_ids)))
        for each in results:
            self.assertIn('bartlet', each['name'].lower())
