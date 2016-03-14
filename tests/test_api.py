import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest

from webservices import rest
from webservices.rest import api
from webservices.resources.search import CandidateNameSearch, CommitteeNameSearch
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

    def test_typeahead_candidate_search(self):
        rows = [
            factories.CandidateSearchFactory(
                name='Bartlet {0}'.format(idx),
                fulltxt=sa.func.to_tsvector('Bartlet for America {0}'.format(idx)),
                office_sought='P',
                receipts=idx,
            )
            for idx in range(30)
        ]
        rest.db.session.flush()
        results = self._results(api.url_for(CandidateNameSearch, q='bartlet'))
        expected = [str(each.id) for each in rows[:-21:-1]]
        observed = [each['id'] for each in results]
        assert expected == observed
        assert all('bartlet' in each['name'].lower() for each in results)
        assert all(each['office_sought'] == 'P' for each in results)

    def test_typeahead_candidate_search_id(self):
        row = factories.CandidateSearchFactory(
            name='Bartlet',
            fulltxt=sa.func.to_tsvector('Bartlet P0123'),
        )
        decoy = factories.CandidateSearchFactory()  # noqa
        rest.db.session.flush()
        results = self._results(api.url_for(CandidateNameSearch, q='P0123'))
        assert len(results) == 1
        assert results[0]['name'] == row.name

    def test_typeahead_committee_search(self):
        rows = [
            factories.CommitteeSearchFactory(
                name='Bartlet {0}'.format(idx),
                fulltxt=sa.func.to_tsvector('Bartlet for America {0}'.format(idx)),
                receipts=idx,
            )
            for idx in range(30)
        ]
        rest.db.session.flush()
        results = self._results(api.url_for(CommitteeNameSearch, q='bartlet'))
        expected = [str(each.id) for each in rows[:-21:-1]]
        observed = [each['id'] for each in results]
        assert expected == observed
        assert all('bartlet' in each['name'].lower() for each in results)
