from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.resources.presidential import PresidentialByCandidateView


class PresidentialByCandidate(ApiBaseTest):
    """ Test /presidential/contributions/by_candidate/"""

    def test_without_filter(self):
        """ Check results without filter"""
        factories.PresidentialByCandidateFactory(candidate_id='C001', election_year=2016, contributor_state='US')
        factories.PresidentialByCandidateFactory(candidate_id='C002', election_year=2016, contributor_state='NY')
        factories.PresidentialByCandidateFactory(candidate_id='C001', election_year=2020, contributor_state='US')
        factories.PresidentialByCandidateFactory(candidate_id='C002', election_year=2020, contributor_state='NY')

        results = self._results(api.url_for(PresidentialByCandidateView))
        self.assertEqual(len(results), 4)

    def test_filters(self):
        factories.PresidentialByCandidateFactory(candidate_id='C001', election_year=2016, contributor_state='US')
        factories.PresidentialByCandidateFactory(candidate_id='C002', election_year=2016, contributor_state='NY')
        factories.PresidentialByCandidateFactory(candidate_id='C001', election_year=2020, contributor_state='US')
        factories.PresidentialByCandidateFactory(candidate_id='C002', election_year=2020, contributor_state='NY')

        filter_fields = (
            ('election_year', 2020),
            ('contributor_state', 'US'),
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(PresidentialByCandidateView))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(PresidentialByCandidateView, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])

    def test_sort(self):
        factories.PresidentialByCandidateFactory(candidate_id='C003', net_receipts=333),
        factories.PresidentialByCandidateFactory(candidate_id='C001', net_receipts=222)
        factories.PresidentialByCandidateFactory(candidate_id='C004', net_receipts=111)
        factories.PresidentialByCandidateFactory(candidate_id='C002', net_receipts=444)

        results = self._results(api.url_for(PresidentialByCandidateView))
        self.assertEqual(
            [each['candidate_id'] for each in results],
            ['C002', 'C003', 'C001', 'C004']
        )

