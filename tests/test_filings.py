import datetime
import sqlalchemy as sa
from webservices import rest
from tests import factories
from tests.common import ApiBaseTest
from webservices.api_setup import api
from webservices.resources.filings import FilingsView, FilingsList, EFilingsView, F2EFilingsView, F1EFilingsView


# Test 3 endpoints:
# `/filings/` under tag:filing (filings.FilingsList)
# `/committee/<committee_id>/filings/` under tag:filing (filings.FilingsView)
# `/candidate/<candidate_id>/filings/` under tag:filing (filings.FilingsView)
class TestFilings(ApiBaseTest):
    def test_committee_filings(self):
        """ Check filing returns with a specified committee id"""
        committee_id = 'C86753090'
        factories.FilingsFactory(committee_id=committee_id)

        results = self._results(api.url_for(FilingsView, committee_id=committee_id))
        self.assertEqual(results[0]['committee_id'], committee_id)

    def test_candidate_filings(self):
        candidate_id = 'P12345000'
        factories.FilingsFactory(candidate_id=candidate_id)
        results = self._results(api.url_for(FilingsView, candidate_id=candidate_id))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['candidate_id'], candidate_id)

    def test_filings(self):
        """ Check filings returns in general endpoint"""
        factories.FilingsFactory(committee_id='C00000001')
        factories.FilingsFactory(committee_id='C00000002')

        results = self._results(api.url_for(FilingsList))
        self.assertEqual(len(results), 2)

    def test_filings_with_bank(self):
        """ Check filings returns bank information"""
        factories.FilingsFactory(committee_id='C00000001', bank_depository_name='Bank A')

        results = self._results(api.url_for(FilingsList))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['bank_depository_name'], 'Bank A')

    def test_filter_date(self):
        [
            factories.FilingsFactory(receipt_date=datetime.date(2012, 1, 1)),
            factories.FilingsFactory(receipt_date=datetime.date(2013, 1, 1)),
            factories.FilingsFactory(receipt_date=datetime.date(2014, 1, 1)),
            factories.FilingsFactory(receipt_date=datetime.date(2015, 1, 1)),
        ]
        min_date = datetime.date(2013, 1, 1)
        results = self._results(api.url_for(FilingsList, min_receipt_date=min_date))
        self.assertTrue(
            all(
                each for each in results if each['receipt_date'] >= min_date.isoformat()
            )
        )
        max_date = datetime.date(2014, 1, 1)
        results = self._results(api.url_for(FilingsList, max_receipt_date=max_date))
        self.assertTrue(
            all(
                each for each in results if each['receipt_date'] <= max_date.isoformat()
            )
        )
        results = self._results(
            api.url_for(
                FilingsList, min_receipt_date=min_date, max_receipt_date=max_date
            )
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_date.isoformat() <= each['receipt_date'] <= max_date.isoformat()
            )
        )

    def test_filings_filters(self):
        [
            factories.FilingsFactory(committee_id='C00000004'),
            factories.FilingsFactory(committee_id='C00000005'),
            factories.FilingsFactory(candidate_id='H00000001'),
            factories.FilingsFactory(amendment_indicator='A'),
            factories.FilingsFactory(beginning_image_number=123456789021234567),
            factories.FilingsFactory(committee_type='P'),
            factories.FilingsFactory(cycle=2000),
            factories.FilingsFactory(document_type='X'),
            factories.FilingsFactory(file_number=123),
            factories.FilingsFactory(form_category='REPORT'),
            factories.FilingsFactory(form_category='REPORT'),
            factories.FilingsFactory(form_type='3'),
            factories.FilingsFactory(office='H'),
            factories.FilingsFactory(party='DEM'),
            factories.FilingsFactory(primary_general_indicator='G'),
            factories.FilingsFactory(report_type='POST GENERAL'),
            factories.FilingsFactory(report_year=1999),
            factories.FilingsFactory(request_type='5'),
            factories.FilingsFactory(state='MD'),
            factories.FilingsFactory(filer_name_text=sa.func.to_tsvector('international abc action committee C004')),
            factories.FilingsFactory(filer_name_text=sa.func.to_tsvector('international xyz action committee C004')),
        ]

        filter_fields = (
            ('amendment_indicator', 'A'),
            ('beginning_image_number', 123456789021234567),
            ('committee_type', 'P'),
            ('cycle', 2000),
            ('document_type', 'X'),
            ('file_number', 123),
            ('form_category', 'REPORT'),
            ('form_type', '3'),
            ('office', 'H'),
            ('party', 'DEM'),
            ('primary_general_indicator', 'G'),
            ('report_type', 'Post General'),
            ('report_year', 1999),
            ('request_type', '5'),
            ('state', 'MD'),
            ('candidate_id', 'H00000001'),
            ('q_filer', 'action'),
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
        self.assertTrue([each['beginning_image_number'] for each in results], [1, 2])

    def test_sort_bad_column(self):
        response = self.app.get(api.url_for(FilingsList, sort='request_type'))
        self.assertEqual(response.status_code, 422)

    def test_secondary_sort_ascending(self):
        [
            factories.FilingsFactory(
                beginning_image_number=2, coverage_end_date='2017-01-01'
            ),
            factories.FilingsFactory(
                beginning_image_number=1, coverage_end_date='2017-01-01'
            ),
            factories.FilingsFactory(
                beginning_image_number=0, coverage_end_date='2017-01-02'
            ),
        ]
        results = self._results(
            api.url_for(
                FilingsList, sort=['coverage_end_date', 'beginning_image_number']
            )
        )
        self.assertEqual(results[0]['beginning_image_number'], '1')
        self.assertEqual(results[2]['beginning_image_number'], '0')

    def test_secondary_sort_descending(self):
        [
            factories.FilingsFactory(
                beginning_image_number=2, coverage_end_date='2017-01-01'
            ),
            factories.FilingsFactory(
                beginning_image_number=1, coverage_end_date='2017-01-01'
            ),
            factories.FilingsFactory(
                beginning_image_number=0, coverage_end_date='2017-01-02'
            ),
        ]
        results = self._results(
            api.url_for(
                FilingsList, sort=['coverage_end_date', '-beginning_image_number']
            )
        )
        self.assertEqual(results[0]['beginning_image_number'], '2')

    def test_primary_sort_takes_overrides_secondary_sort(self):
        [
            factories.FilingsFactory(
                beginning_image_number=2, coverage_end_date='2017-01-01'
            ),
            factories.FilingsFactory(
                beginning_image_number=1, coverage_end_date='2017-01-01'
            ),
            factories.FilingsFactory(
                beginning_image_number=0, coverage_end_date='2017-01-02'
            ),
        ]
        results = self._results(
            api.url_for(
                FilingsList, sort=['-coverage_end_date', '-beginning_image_number']
            )
        )
        self.assertEqual(results[0]['beginning_image_number'], '0')

    def test_regex(self):
        """ Getting rid of extra text that comes in the tables."""
        factories.FilingsFactory(
            report_type_full_original='report    {more information than we want}',
            committee_id='C00000007',
            form_type='RFAI',
            report_year=2004,
        )

        results = self._results(api.url_for(FilingsView, committee_id='C00000007'))

        self.assertEqual(results[0]['document_description'], 'RFAI: report 2004')

    def test_invalid_keyword(self):
        response = self.app.get(
            api.url_for(FilingsList, q_filer="ab")
        )
        self.assertEqual(response.status_code, 422)


# Test for endpoint:/efile/filings/ under tag:efiling (filings.EFilingsView)
class TestEfileFiles(ApiBaseTest):
    def test_filter_date_efile(self):
        [
            factories.EFilingsFactory(
                committee_id="C010",
                beginning_image_number=2,
                filed_date=datetime.date(2012, 1, 1),
            ),
            factories.EFilingsFactory(
                committee_id="C011",
                beginning_image_number=3,
                filed_date=datetime.date(2013, 1, 1),
            ),
            factories.EFilingsFactory(
                committee_id="C012",
                beginning_image_number=4,
                filed_date=datetime.date(2014, 1, 1),
            ),
            factories.EFilingsFactory(
                committee_id="C013",
                beginning_image_number=5,
                filed_date=datetime.date(2015, 1, 1),
            ),
        ]

        min_date = datetime.date(2013, 1, 1)
        results = self._results(api.url_for(EFilingsView, min_receipt_date=min_date))
        self.assertTrue(
            all(each for each in results if each["filed_date"] >= min_date.isoformat())
        )
        max_date = datetime.date(2014, 1, 1)
        results = self._results(api.url_for(EFilingsView, max_receipt_date=max_date))
        self.assertTrue(
            all(each for each in results if each["filed_date"] <= max_date.isoformat())
        )
        results = self._results(
            api.url_for(
                EFilingsView, min_receipt_date=min_date, max_receipt_date=max_date
            )
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_date.isoformat() <= each["filed_date"] <= max_date.isoformat()
            )
        )

    def test_filter_receipt_date_efile(self):

        [
            factories.EFilingsFactory(
                committee_id="C00000013",
                beginning_image_number=5,
                filed_date=datetime.date(2015, 1, 1),
            ),
            factories.EFilingsFactory(
                committee_id="C00000014",
                beginning_image_number=6,
                filed_date=datetime.date(2015, 1, 2),
            ),
        ]
        results = self._results(
            api.url_for(
                EFilingsView,
                min_receipt_date=datetime.date(2015, 1, 1),
                max_receipt_date=datetime.date(2015, 1, 2),
            )
        )
        self.assertEqual(len(results), 2)

    def test_efilings(self):
        """ Check filings returns in general endpoint"""
        factories.EFilingsFactory(committee_id="C00000001")
        factories.EFilingsFactory(committee_id="C00000002")

        results = self._results(api.url_for(EFilingsView))
        self.assertEqual(len(results), 2)

    def test_committee_efilings(self):
        """ Check filing returns with a specified committee id"""
        committee_id = "C86753090"
        factories.EFilingsFactory(committee_id=committee_id)

        results = self._results(api.url_for(EFilingsView, committee_id=committee_id))
        self.assertEqual(results[0]["committee_id"], committee_id)

    def test_file_number_efilings(self):
        """ Check filing returns with a specified file number"""
        file_number = 1124839
        factories.EFilingsFactory(file_number=file_number)

        results = self._results(api.url_for(EFilingsView, file_number=file_number))
        self.assertEqual(results[0]["file_number"], file_number)

    def test_filter_form_type_efile(self):

        [
            factories.EFilingsFactory(
                form_type="F2A",
                beginning_image_number=5,
            ),
            factories.EFilingsFactory(
                form_type="F2N",
                beginning_image_number=6,
            ),
            factories.EFilingsFactory(
                form_type="F99",
                beginning_image_number=8,
            ),
            factories.EFilingsFactory(
                form_type="F24",
                beginning_image_number=9,
            ),
        ]
        results = self._results(
            api.url_for(
                EFilingsView,
                form_type='F2',
            )
        )
        self.assertEqual(len(results), 2)
        results = self._results(
            api.url_for(
                EFilingsView,
                form_type='F2A',
            )
        )
        self.assertEqual(len(results), 1)

    def test_fulltext_keyword_search(self):
        [
            factories.EFilingsFactory(
                committee_id="C00000001",
                committee_name="Danielle",
            ),
            factories.EFilingsFactory(
                committee_id="C00000002",
                committee_name="Dana",
            ),
        ]

        factories.CommitteeSearchFactory(
            id="C00000001", fulltxt=sa.func.to_tsvector("Danielle")
        )
        factories.CommitteeSearchFactory(
            id="C00000002", fulltxt=sa.func.to_tsvector("Dana")
        )
        rest.db.session.flush()
        results = self._results(api.url_for(EFilingsView, q_filer="Danielle"))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["committee_id"], "C00000001")

        results = self._results(api.url_for(EFilingsView, q_filer="dan"))
        self.assertEqual(len(results), 2)
        self.assertEqual(results[0]["committee_id"], "C00000001")
        self.assertEqual(results[1]["committee_id"], "C00000002")

    def test_invalid_keyword(self):
        response = self.app.get(
            api.url_for(EFilingsView, q_filer="ab")
        )
        self.assertEqual(response.status_code, 422)


class TestEfileForm2(ApiBaseTest):
    def test_filter_load_timestamp(self):
        [
            factories.Form2EFilingFactory(
                candidate_id="H010",
                file_number=2,
                load_timestamp=datetime.date(2012, 1, 1),
            ),
            factories.Form2EFilingFactory(
                candidate_id="S011",
                file_number=3,
                load_timestamp=datetime.date(2013, 1, 1),
            ),
            factories.Form2EFilingFactory(
                candidate_id="P012",
                file_number=4,
                load_timestamp=datetime.date(2014, 1, 1),
            ),
            factories.Form2EFilingFactory(
                candidate_id="H013",
                file_number=5,
                load_timestamp=datetime.date(2015, 1, 1),
            ),
        ]

        min_load_timestamp = datetime.date(2013, 1, 1)
        results = self._results(api.url_for(F2EFilingsView, min_load_timestamp=min_load_timestamp))
        self.assertTrue(
            all(each for each in results if each["load_timestamp"] >= min_load_timestamp.isoformat())
        )
        max_load_timestamp = datetime.date(2014, 1, 1)
        results = self._results(api.url_for(F2EFilingsView, max_load_timestamp=max_load_timestamp))
        self.assertTrue(
            all(each for each in results if each["load_timestamp"] <= max_load_timestamp.isoformat())
        )
        results = self._results(
            api.url_for(
                F2EFilingsView, min_load_timestamp=min_load_timestamp, max_load_timestamp=max_load_timestamp
            )
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_load_timestamp.isoformat() <= each["load_timestamp"] <= max_load_timestamp.isoformat()
            )
        )

    def test_filter_load_timestamp_efile(self):

        [
            factories.Form2EFilingFactory(
                committee_id="C00000013",
                file_number=5,
                load_timestamp=datetime.date(2015, 1, 1),
            ),
            factories.Form2EFilingFactory(
                committee_id="C00000014",
                file_number=6,
                load_timestamp=datetime.date(2015, 1, 2),
            ),
        ]
        results = self._results(
            api.url_for(
                F2EFilingsView,
                min_load_timestamp=datetime.date(2015, 1, 1),
                max_load_timestamp=datetime.date(2015, 1, 2),
            )
        )
        self.assertEqual(len(results), 2)

    def test_efilings(self):
        factories.Form2EFilingFactory(candidate_id="H00000001")
        factories.Form2EFilingFactory(candidate_id="S00000002")

        results = self._results(api.url_for(F2EFilingsView))
        self.assertEqual(len(results), 2)

    def test_file_number_efilings(self):
        """ Check filing returns with a specified file number"""
        file_number = 1124839
        factories.Form2EFilingFactory(file_number=file_number)

        results = self._results(api.url_for(F2EFilingsView, file_number=file_number))
        self.assertEqual(results[0]["file_number"], file_number)

    def test_filter_election_state(self):

        [
            factories.Form2EFilingFactory(
                election_state="AK",
                file_number=5,
                candidate_district=1,
                candidate_office="H",
                candidate_id="H8UGH0000",

            ),
            factories.Form2EFilingFactory(
                election_state="IN",
                file_number=6,
                candidate_district=7,
                candidate_office="H",
                candidate_id="H00000000",
            ),
            factories.Form2EFilingFactory(
                election_state="IN",
                file_number=8,
                candidate_district="null",
                candidate_office="S",
                candidate_id="S00000000",
            ),
            factories.Form2EFilingFactory(
                election_state="null",
                file_number=9,
                candidate_district="null",
                candidate_office="P",
                candidate_id="P00000000",

            ),
        ]
        results = self._results(
            api.url_for(
                F2EFilingsView,
                election_state='IN',
            )
        )
        self.assertEqual(len(results), 2)
        results = self._results(
            api.url_for(
                F2EFilingsView,
                candidate_office='P',
            )
        )
        self.assertEqual(len(results), 1)
        results = self._results(
            api.url_for(
                F2EFilingsView,
                election_state='IN',
            )
        )
        self.assertEqual(len(results), 2)
        results = self._results(
            api.url_for(
                F2EFilingsView,
                candidate_district='1',
            )
        )
        self.assertEqual(len(results), 1)
        results = self._results(
            api.url_for(
                F2EFilingsView,
                candidate_id='H8UGH0000',
            )
        )
        self.assertEqual(len(results), 1)


class TestEfileForm1(ApiBaseTest):
    def test_Form1Efilings(self):
        factories.Form1EFilingFactory(candidate_id="H00000001")
        factories.Form1EFilingFactory(candidate_id="S00000002")
        factories.Form1EFilingFactory(committee_id="C00000002")

        results = self._results(api.url_for(F1EFilingsView))
        self.assertEqual(len(results), 3)

    def test_filter_load_timestamp(self):
        factories.Form1EFilingFactory(
            candidate_id="H01000000",
            file_number=2,
            load_timestamp=datetime.date(2012, 1, 1),
        )
        factories.Form1EFilingFactory(
            candidate_id="S00000011",
            file_number=3,
            load_timestamp=datetime.date(2013, 1, 1),
        )
        factories.Form1EFilingFactory(
            candidate_id="P00000012",
            file_number=4,
            load_timestamp=datetime.date(2014, 1, 1),
        )
        factories.Form1EFilingFactory(
            candidate_id="H00000013",
            file_number=5,
            load_timestamp=datetime.date(2015, 1, 1),
        )

        min_load_timestamp = datetime.date(2013, 1, 1)
        results = self._results(api.url_for(F1EFilingsView, min_load_timestamp=min_load_timestamp))
        self.assertTrue(
            all(each for each in results if each["load_timestamp"] >= min_load_timestamp.isoformat())
        )
        max_load_timestamp = datetime.date(2014, 1, 1)
        results = self._results(api.url_for(F1EFilingsView, max_load_timestamp=max_load_timestamp))
        self.assertTrue(
            all(each for each in results if each["load_timestamp"] <= max_load_timestamp.isoformat())
        )
        results = self._results(
            api.url_for(
                F1EFilingsView, min_load_timestamp=min_load_timestamp, max_load_timestamp=max_load_timestamp
            )
        )
        self.assertTrue(
            all(
                each
                for each in results
                if min_load_timestamp.isoformat() <= each["load_timestamp"] <= max_load_timestamp.isoformat()
            )
        )

    def test_filter_file_number(self):
        file_number = 1124839
        factories.Form1EFilingFactory(file_number=file_number)
        factories.Form1EFilingFactory()

        results = self._results(api.url_for(F1EFilingsView, file_number=file_number))

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["file_number"], file_number)

    def test_filter_committee_id(self):
        factories.Form1EFilingFactory(committee_id="C00000001")
        factories.Form1EFilingFactory(committee_id="C00000002")

        results = self._results(api.url_for(F1EFilingsView, committee_id="C00000002"))

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["committee_id"], "C00000002")

    def test_candidate_filters(self):

        factories.Form1EFilingFactory(
            election_state="AK",
            candidate_district=1,
            candidate_office="H",
            candidate_id="H8UGH0000",

        )
        factories.Form1EFilingFactory(
            election_state="IN",
            candidate_district=7,
            candidate_office="H",
            candidate_id="H00000000",
        )
        factories.Form1EFilingFactory(
            election_state="IN",
            candidate_district="null",
            candidate_office="S",
            candidate_id="S00000000",
        )
        factories.Form1EFilingFactory(
            election_state="null",
            candidate_district="null",
            candidate_office="P",
            candidate_id="P00000000",

        )

        results = self._results(
            api.url_for(
                F1EFilingsView,
                election_state='IN',
            )
        )
        self.assertEqual(len(results), 2)
        self.assertEqual(results[0]["election_state"], "IN")

        results = self._results(
            api.url_for(
                F1EFilingsView,
                candidate_office='P',
            )
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["candidate_office"], "P")

        results = self._results(
            api.url_for(
                F1EFilingsView,
                candidate_district='1',
            )
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["candidate_district"], "1")

        results = self._results(api.url_for(F1EFilingsView, candidate_id="H00000000"))

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["candidate_id"], "H00000000")

    def test_filter_image_number(self):
        factories.Form1EFilingFactory(image_number=123456)
        factories.Form1EFilingFactory(image_number=789012)

        results = self._results(api.url_for(F1EFilingsView, image_number=789012))

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["image_number"], "789012")

    def test_filter_committee_type(self):
        factories.Form1EFilingFactory(committee_type="S")
        factories.Form1EFilingFactory(committee_type="X")
        factories.Form1EFilingFactory(committee_type="Y")

        results = self._results(api.url_for(F1EFilingsView, committee_type="Y"))

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["committee_type"], "Y")

    def test_filter_organization_type(self):
        factories.Form1EFilingFactory(organization_type="C")
        factories.Form1EFilingFactory(organization_type="L")
        factories.Form1EFilingFactory(organization_type="M")

        results = self._results(api.url_for(F1EFilingsView, organization_type="L"))

        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["organization_type"], "L")
