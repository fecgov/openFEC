import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest

from webservices import rest
from webservices.rest import api
from webservices.rest import CandidateNameSearch
from webservices.rest import CommitteeNameSearch
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
        self.assertEquals(results.status_code, 422)
        results = self.app.get(api.url_for(CandidateList, per_page=101))
        self.assertEquals(results.status_code, 422)
        results = self.app.get(api.url_for(CandidateList, per_page=34.2))
        self.assertEquals(results.status_code, 422)
        results = self.app.get(api.url_for(CandidateList, per_page='dynamic-wombats'))
        self.assertEquals(results.status_code, 422)

    def test_page_param(self):
        [factories.CandidateFactory() for _ in range(20)]
        page_one_and_two = self._results(api.url_for(CandidateList, per_page=10, page=1))
        page_two = self._results(api.url_for(CandidateList, per_page=5, page=2))
        self.assertEqual(page_two[0], page_one_and_two[5])
        for itm in page_two:
            self.assertIn(itm, page_one_and_two)

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
