import json
import datetime

from webservices import utils
from webservices.rest import api
from webservices.resources.filings import FilingsView

from tests import factories
from .common import ApiBaseTest


class TestFilings(ApiBaseTest):

    def test_committee_filing(self):
        """ Check filing returns with a specified committee id"""
        committee_id = 'C8675309'
        filing = factories.FilingsFactory(
            committee_id = committee_id,
        )

        results = self._results(api.url_for(FilingsView, committee_id=committee_id))
        self.assertEqual(results[0]['committee_id'], committee_id)

    def test_filings(self):
        """ Check filings returns in general endpoint"""
        filing_1 = factories.FilingsFactory(committee_id = 'C001')
        filing_2 = factories.FilingsFactory(committee_id = 'C002')

        results = self._results(api.url_for(FilingsView))
        self.assertEqual(len(results), 2)

    def test_filings_filters(self):
        [
            factories.FilingsFactory(committee_id='C0004'),
            factories.FilingsFactory(committee_id='C0005'),
            factories.FilingsFactory(begin_image_numeric=123456789021234567890),
            factories.FilingsFactory(form_type='3'),
            factories.FilingsFactory(report_pgi='G'),
            factories.FilingsFactory(amendment_indicator='A'),
            factories.FilingsFactory(report_type='Post General'),
            factories.FilingsFactory(report_year=1999),
        ]

        filter_fields = (
            ('committee_id', ['00', '02']),
            ('begin_image_numeric', 123456789021234567890),
            ('form_type', '3'),
            ('report_pgi', 'G'),
            ('amendment_indicator', 'A'),
            ('report_type', 'Post General'),
            ('report_year', 1999),
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(FilingsView))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(FilingsView, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])