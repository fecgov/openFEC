from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.resources.presidential import(
    PresidentialByCandidateView,
    PresidentialByStateView,
    PresidentialSummaryView,
    PresidentialBySizeView,
)


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
        factories.PresidentialByCandidateFactory(candidate_id='C002', election_year=2020, contributor_state='VA')
        factories.PresidentialByCandidateFactory(candidate_id='C002', election_year=2020, contributor_state='CA')

        filter_fields = (
            ('election_year', [2020]),
            ('contributor_state', ['US', 'CA']),
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
        factories.PresidentialByCandidateFactory(candidate_id='C003', net_receipts=333)
        factories.PresidentialByCandidateFactory(candidate_id='C001', net_receipts=222)
        factories.PresidentialByCandidateFactory(candidate_id='C004', net_receipts=111)
        factories.PresidentialByCandidateFactory(candidate_id='C002', net_receipts=444)

        results = self._results(api.url_for(PresidentialByCandidateView))
        self.assertEqual(
            [each['candidate_id'] for each in results],
            ['C002', 'C003', 'C001', 'C004']
        )

class PresidentialByState(ApiBaseTest):
    """ Test /presidential/contributions/by_state/"""

    def test_without_filter(self):
        """ Check results without filter"""
        factories.PresidentialByStateFactory(candidate_id='C001', election_year=2016)
        factories.PresidentialByStateFactory(candidate_id='C002', election_year=2016)
        factories.PresidentialByStateFactory(candidate_id='C001', election_year=2020)
        factories.PresidentialByStateFactory(candidate_id='C002', election_year=2020)

        results = self._results(api.url_for(PresidentialByStateView))
        self.assertEqual(len(results), 4)

    def test_filters_election_year(self):
        factories.PresidentialByStateFactory(candidate_id='C001', election_year=2016, contribution_receipt_amount=100)
        factories.PresidentialByStateFactory(candidate_id='C002', election_year=2016, contribution_receipt_amount=200)
        factories.PresidentialByStateFactory(candidate_id='C001', election_year=2020, contribution_receipt_amount=300)
        factories.PresidentialByStateFactory(candidate_id='C002', election_year=2020, contribution_receipt_amount=400)
        factories.PresidentialByStateFactory(candidate_id='C002', election_year=2020, contribution_receipt_amount=500)
        factories.PresidentialByStateFactory(candidate_id='C002', election_year=2020, contribution_receipt_amount=600)

        filter_fields = (
            ('election_year', [2020]),
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(PresidentialByStateView))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(PresidentialByStateView, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])

    def test_filters_candidate_id(self):
        """ always return 51 rows(51 states) for each candidate_id/"""
        factories.PresidentialByStateFactory(candidate_id='C001', election_year=2016)
        factories.PresidentialByStateFactory(candidate_id='C002', election_year=2016)
        factories.PresidentialByStateFactory(candidate_id='C001', election_year=2020)
        factories.PresidentialByStateFactory(candidate_id='C002', election_year=2020)
        factories.PresidentialByStateFactory(candidate_id='C002', election_year=2020)
        factories.PresidentialByStateFactory(candidate_id='C002', election_year=2020)

        filter_fields = (
            ('candidate_id', ['C001', 'C002']),
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(PresidentialByStateView))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(PresidentialByStateView, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results, but return same records
            response = self._response(page)
            self.assertEqual(original_count, response['pagination']['count'])

    def test_sort(self):
        factories.PresidentialByStateFactory(candidate_id='C003', contribution_receipt_amount=333)
        factories.PresidentialByStateFactory(candidate_id='C001', contribution_receipt_amount=222)
        factories.PresidentialByStateFactory(candidate_id='C004', contribution_receipt_amount=111)
        factories.PresidentialByStateFactory(candidate_id='C002', contribution_receipt_amount=444)

        results = self._results(api.url_for(PresidentialByStateView))
        self.assertEqual(
            [each['candidate_id'] for each in results],
            ['C002', 'C003', 'C001', 'C004']
        )

class PresidentialSummary(ApiBaseTest):
    """ Test /presidential/financial_summary/"""

    def test_without_filter(self):
        """ Check results without filter"""
        factories.PresidentialSummaryFactory(candidate_id='C001', election_year=2016)
        factories.PresidentialSummaryFactory(candidate_id='C002', election_year=2016)
        factories.PresidentialSummaryFactory(candidate_id='C001', election_year=2020)
        factories.PresidentialSummaryFactory(candidate_id='C002', election_year=2020)

        results = self._results(api.url_for(PresidentialSummaryView))
        self.assertEqual(len(results), 4)

    def test_filters(self):
        factories.PresidentialSummaryFactory(candidate_id='C001', election_year=2016, net_receipts=100)
        factories.PresidentialSummaryFactory(candidate_id='C002', election_year=2016, net_receipts=200)
        factories.PresidentialSummaryFactory(candidate_id='C001', election_year=2020, net_receipts=300)
        factories.PresidentialSummaryFactory(candidate_id='C002', election_year=2020, net_receipts=400)
        factories.PresidentialSummaryFactory(candidate_id='C003', election_year=2020, net_receipts=500)
        factories.PresidentialSummaryFactory(candidate_id='C004', election_year=2020, net_receipts=600)

        filter_fields = (
            ('election_year', [2020]),
            ('candidate_id', ['C001', 'C002']),
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(PresidentialSummaryView))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(PresidentialSummaryView, **{field: example})


class PresidentialBySize(ApiBaseTest):
    """ Test /presidential/contributions/by_size/"""

    def test_without_filter(self):
        """ Check results without filter"""
        factories.PresidentialBySizeFactory(candidate_id='C001', election_year=2016)
        factories.PresidentialBySizeFactory(candidate_id='C002', election_year=2016)
        factories.PresidentialBySizeFactory(candidate_id='C001', election_year=2020)
        factories.PresidentialBySizeFactory(candidate_id='C002', election_year=2020)

        results = self._results(api.url_for(PresidentialBySizeView))
        self.assertEqual(len(results), 4)

    def test_filters_election_year(self):
        factories.PresidentialBySizeFactory(candidate_id='C001', election_year=2016, contribution_receipt_amount=100)
        factories.PresidentialBySizeFactory(candidate_id='C002', election_year=2016, contribution_receipt_amount=200)
        factories.PresidentialBySizeFactory(candidate_id='C001', election_year=2020, contribution_receipt_amount=300)
        factories.PresidentialBySizeFactory(candidate_id='C002', election_year=2020, contribution_receipt_amount=400)
        factories.PresidentialBySizeFactory(candidate_id='C002', election_year=2020, contribution_receipt_amount=500)
        factories.PresidentialBySizeFactory(candidate_id='C002', election_year=2020, contribution_receipt_amount=600)

        filter_fields = (
            ('election_year', [2020]),
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(PresidentialBySizeView))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(PresidentialBySizeView, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])

    def test_sort(self):
        factories.PresidentialSummaryFactory(candidate_id='C003', net_receipts=333)
        factories.PresidentialSummaryFactory(candidate_id='C001', net_receipts=222)
        factories.PresidentialSummaryFactory(candidate_id='C004', net_receipts=111)
        factories.PresidentialSummaryFactory(candidate_id='C002', net_receipts=444)

        results = self._results(api.url_for(PresidentialSummaryView))
        self.assertEqual(
            [each['candidate_id'] for each in results],
            ['C002', 'C003', 'C001', 'C004']
