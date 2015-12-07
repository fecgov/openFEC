import datetime

from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.resources.filings import FilingsView, FilingsList


class TestFilings(ApiBaseTest):

    def test_committee_filings(self):
        """ Check filing returns with a specified committee id"""
        committee_id = 'C8675309'
        factories.FilingsFactory(committee_id=committee_id)

        results = self._results(api.url_for(FilingsView, committee_id=committee_id))
        self.assertEqual(results[0]['committee_id'], committee_id)

    def test_candidate_filings(self):
        candidate_id = 'P12345'
        factories.FilingsFactory(candidate_id=candidate_id)
        results = self._results(api.url_for(FilingsView, candidate_id=candidate_id))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['candidate_id'], candidate_id)

    def test_filings(self):
        """ Check filings returns in general endpoint"""
        factories.FilingsFactory(committee_id='C001')
        factories.FilingsFactory(committee_id='C002')

        results = self._results(api.url_for(FilingsList))
        self.assertEqual(len(results), 2)

    def test_filter_date(self):
        [
            factories.FilingsFactory(receipt_date=datetime.date(2012, 1, 1)),
            factories.FilingsFactory(receipt_date=datetime.date(2013, 1, 1)),
            factories.FilingsFactory(receipt_date=datetime.date(2014, 1, 1)),
            factories.FilingsFactory(receipt_date=datetime.date(2015, 1, 1)),
        ]
        min_date = datetime.date(2013, 1, 1)
        results = self._results(api.url_for(FilingsList, min_receipt_date=min_date))
        self.assertTrue(all(each for each in results if each['receipt_date'] >= min_date.isoformat()))
        max_date = datetime.date(2014, 1, 1)
        results = self._results(api.url_for(FilingsList, max_receipt_date=max_date))
        self.assertTrue(all(each for each in results if each['receipt_date'] <= max_date.isoformat()))
        results = self._results(api.url_for(FilingsList, min_receipt_date=min_date, max_receipt_date=max_date))
        self.assertTrue(
            all(
                each for each in results
                if min_date.isoformat() <= each['receipt_date'] <= max_date.isoformat()
            )
        )

    def test_filings_filters(self):
        [
            factories.FilingsFactory(committee_id='C0004'),
            factories.FilingsFactory(committee_id='C0005'),
            factories.FilingsFactory(candidate_id='H0001'),
            factories.FilingsFactory(beginning_image_number=123456789021234567),
            factories.FilingsFactory(form_type='3'),
            factories.FilingsFactory(primary_general_indicator='G'),
            factories.FilingsFactory(amendment_indicator='A'),
            factories.FilingsFactory(report_type='POST GENERAL'),
            factories.FilingsFactory(report_year=1999),
            factories.FilingsFactory(document_type='X'),
            factories.FilingsFactory(cycle=2000),
        ]

        filter_fields = (
            ('beginning_image_number', 123456789021234567),
            ('form_type', '3'),
            ('primary_general_indicator', 'G'),
            ('amendment_indicator', 'A'),
            ('report_type', 'Post General'),
            ('report_year', 1999),
            ('candidate_id', 'H0001'),
            ('document_type', 'X'),
            ('cycle', 2000),
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(FilingsList))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(FilingsList, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])

    def test_sort(self):
        [
            factories.FilingsFactory(beginning_image_number=2),
            factories.FilingsFactory(beginning_image_number=1),
        ]
        results = self._results(api.url_for(FilingsList, sort='beginning_image_number'))
        self.assertTrue(
            [each['beginning_image_number'] for each in results],
            [1, 2]
        )

    def test_sort_bad_column(self):
        response = self.app.get(api.url_for(FilingsList, sort='request_type'))
        self.assertEqual(response.status_code, 422)

    def test_regex(self):
        """ Getting rid of extra text that comes in the tables."""
        factories.FilingsFactory(
            report_type_full='report    {more information than we want}',
            committee_id='C007',
            form_type='RFAI',
            report_year=2004,
        )

        results = self._results(api.url_for(FilingsView, committee_id='C007'))

        self.assertEqual(results[0]['document_description'], 'RFAI: report 2004')

    def test_pdf_url(self):
        factories.FilingsFactory(
            report_type_full='report {more information than we want}',
            beginning_image_number=123456,
            committee_id='C007',
            report_year=2004,
        )
        results = self._results(api.url_for(FilingsView, committee_id='C007'))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['pdf_url'], 'http://docquery.fec.gov/pdf/456/123456/123456.pdf')
