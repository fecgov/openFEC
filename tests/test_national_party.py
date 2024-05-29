import datetime
import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest
from webservices.rest import api
from webservices.schemas import NationalPartyScheduleASchema
from webservices.resources.national_party import (
    NationalParty_ScheduleAView,
    NationalParty_ScheduleBView,
    NationalPartyTotalsView
)


class TestNationalParty(ApiBaseTest):
    kwargs = {'two_year_transaction_period': 2024}

    def test_fields(self):

        params = [
            (factories.NationalParty_ScheduleAFactory, NationalParty_ScheduleAView, NationalPartyScheduleASchema)
        ]
        for factory, resource, schema in params:
            factory()
            results = self._results(api.url_for(resource, **self.kwargs))
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0].keys(), schema().fields.keys())

    def test_multiple_two_year_transaction_period(self):
        """
        testing schedule_a api can take multiple cycles now
        """
        receipts = [  # noqa
            factories.NationalParty_ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014,
                committee_id='C00000001',
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016,
                committee_id='C00000001',
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2018,
                contribution_receipt_date=datetime.date(2018, 1, 1),
                two_year_transaction_period=2018,
                committee_id='C00000001',
            ),
        ]
        response = self._response(
            api.url_for(
                NationalParty_ScheduleAView,
                two_year_transaction_period=[2016, 2018],
                committee_id='C00000001',
            )
        )
        self.assertEqual(len(response['results']), 2)

    def test_multiple_cmte_id_and_two_year_transaction_period(self):
        """
        testing schedule_a api can take multiple cycles now
        """
        receipts = [  # noqa
            factories.NationalParty_ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014,
                committee_id='C00000001',
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016,
                committee_id='C00000001',
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2018,
                contribution_receipt_date=datetime.date(2018, 1, 1),
                two_year_transaction_period=2018,
                committee_id='C00000001',
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014,
                committee_id='C00000002',
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016,
                committee_id='C00000002',
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2018,
                contribution_receipt_date=datetime.date(2018, 1, 1),
                two_year_transaction_period=2018,
                committee_id='C00000002',
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014,
                committee_id='C00000003',
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2016,
                contribution_receipt_date=datetime.date(2016, 1, 1),
                two_year_transaction_period=2016,
                committee_id='C00000003',
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2018,
                contribution_receipt_date=datetime.date(2018, 1, 1),
                two_year_transaction_period=2018,
                committee_id='C00000003',
            ),
        ]
        response = self._response(
            api.url_for(
                NationalParty_ScheduleAView,
                two_year_transaction_period=[2016, 2018],
                committee_id=['C00000001', 'C00000002'],
            )
        )
        self.assertEqual(len(response['results']), 4)
        response = self._response(
            api.url_for(
                NationalParty_ScheduleAView,
                committee_id='C00000001',
            )
        )
        self.assertEqual(len(response['results']), 3)

    def test_schedule_a_two_year_transaction_period_limits_results_per_cycle(self):
        receipts = [  # noqa
            factories.NationalParty_ScheduleAFactory(
                report_year=2014,
                contribution_receipt_date=datetime.date(2014, 1, 1),
                two_year_transaction_period=2014,
            ),
            factories.NationalParty_ScheduleAFactory(
                report_year=2012,
                contribution_receipt_date=datetime.date(2012, 1, 1),
                two_year_transaction_period=2012,
            ),
        ]
        response = self._response(
            api.url_for(NationalParty_ScheduleAView, two_year_transaction_period=2014)
        )
        self.assertEqual(len(response['results']), 1)

    def test_sorting_bad_column(self):
        response = self.app.get(api.url_for(NationalParty_ScheduleAView, sort='bad_column'))
        self.assertEqual(response.status_code, 422)
        self.assertIn(b'Cannot sort on value', response.data)

    def test_filterby_contributor_state(self):
        [
            factories.NationalParty_ScheduleAFactory(contributor_state='NY'),
            factories.NationalParty_ScheduleAFactory(contributor_state='CA'),
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_state='CA', **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_state'], 'CA')

    def test_filterby_zip(self):
        [
            factories.NationalParty_ScheduleAFactory(contributor_zip=96789),
            factories.NationalParty_ScheduleAFactory(contributor_zip=9678912),
            factories.NationalParty_ScheduleAFactory(contributor_zip=967891234),
            factories.NationalParty_ScheduleAFactory(contributor_zip='M4C 1M7'),
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_zip=96789, **self.kwargs)
        )
        self.assertEqual(len(results), 3)

        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_zip='M4C 1M55', **self.kwargs)
        )
        self.assertEqual(len(results), 1)

        contributor_zips = ['M4C 1M5555', 96789]
        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_zip=contributor_zips, **self.kwargs)
        )
        self.assertEqual(len(results), 4)

    def test_invalid_zip(self):
        response = self.app.get(
            api.url_for(NationalParty_ScheduleAView, contributor_zip='96%')
        )
        self.assertEqual(response.status_code, 422)

    def test_contributor_committee_type_filter(self):
        [
            factories.NationalParty_ScheduleAFactory(contributor_committee_type='S'),
            factories.NationalParty_ScheduleAFactory(contributor_committee_type='S'),
            factories.NationalParty_ScheduleAFactory(contributor_committee_type='P'),
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_committee_type='S', **self.kwargs)
        )
        self.assertEqual(len(results), 2)

    def test_contributor_committee_designation_type_filter(self):
        [
            factories.NationalParty_ScheduleAFactory(contributor_committee_designation='J'),
            factories.NationalParty_ScheduleAFactory(contributor_committee_designation='U'),
            factories.NationalParty_ScheduleAFactory(contributor_committee_designation='J'),
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_committee_designation='J', **self.kwargs)
        )
        self.assertEqual(len(results), 2)

    def test_filter_multi_start_with(self):
        [
            factories.NationalParty_ScheduleAFactory(contributor_zip='1296789')
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_zip='96789')
        )
        self.assertEqual(len(results), 0)

    def test_filter_case_insensitive(self):
        [
            factories.NationalParty_ScheduleAFactory(contributor_city='NEW YORK'),
            factories.NationalParty_ScheduleAFactory(contributor_city='DES MOINES'),
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_city='new york', **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['contributor_city'], 'NEW YORK')

    def test_filter_fulltext_contributor_name(self):
        [
            factories.NationalParty_ScheduleAFactory(
                contributor_name_text=sa.func.to_tsvector('SOROS, ALEXANDER GEORGE'),
                contributor_name='SOROS, ALEXANDER GEORGE'),
            factories.NationalParty_ScheduleAFactory(
                contributor_name_text=sa.func.to_tsvector('George Soros'),
                contributor_name='George Soros'),
            factories.NationalParty_ScheduleAFactory(
                contributor_name_text=sa.func.to_tsvector('COX, BOBBY D. MR.'),
                contributor_name='COX, BOBBY D. MR.'),
            factories.NationalParty_ScheduleAFactory(
                contributor_name_text=sa.func.to_tsvector('LOQUERCIO, BOB'),
                contributor_name='LOQUERCIO, BOB'),
            factories.NationalParty_ScheduleAFactory(
                contributor_name_text=sa.func.to_tsvector('FLORENTZ, BOBBY'),
                contributor_name='FLORENTZ, BOBBY'),
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_name='bob', **self.kwargs)
        )
        self.assertEqual(len(results), 3)

        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_name='george')
        )
        self.assertEqual(len(results), 2)

        results = self._results(
            api.url_for(NationalParty_ScheduleAView, contributor_name='N/A')
        )
        self.assertEqual(len(results), 0)

    def test_filter_party_account_type(self):
        [
            factories.NationalParty_ScheduleAFactory(
                committee_id='C00000001',
                committee_name='NRCC',
                contributor_committee_name='',
                contributor_committee_designation='U',
                contributor_committee_state='VA',
                contributor_city='PLEASANTON',
                contributor_employer='RETIRED',
                contributor_first_name='CAROL',
                contributor_id='C00694323',
                contributor_last_name='LEHMAN',
                contributor_name='LEHMAN, CAROL',
                contributor_occupation='RETIRED',
                contributor_state='CA',
                contribution_receipt_amount='35.00',
                contribution_receipt_date=datetime.date.fromisoformat('2024-02-29'),
                contributor_aggregate_ytd='340.00',
                party_account_type='RECOUNT',
                party_full='REPUBLICAN PARTY',
                pdf_url='https://docquery.fec.gov/cgi-bin/fecimg/?202403209627299691',
                receipt_desc='CONTRIBUTION',
                receipt_type='32E',
                receipt_type_desc='EARMARKED – RECOUNT',
                recipient_committee_designation='U',
                report_type='M3',
                report_year='2024',
                schedule_type='SA',
                schedule_type_desc='ITEMIZED RECEIPTS',
                state='DC',
                state_full='District Of Columbia',
                two_year_transaction_period='2024',
            ),
            factories.NationalParty_ScheduleAFactory(
                committee_id='C00000002',
                committee_name='NRCC',
                contributor_committee_name='',
                contributor_committee_designation='U',
                contributor_committee_state='VA',
                contributor_city='PLEASANTON',
                contributor_employer='RETIRED',
                contributor_first_name='CAROL',
                contributor_id='C00694323',
                contributor_last_name='LEHMAN',
                contributor_name='LEHMAN, CAROL',
                contributor_occupation='RETIRED',
                contributor_state='CA',
                contribution_receipt_amount='35.00',
                contribution_receipt_date=datetime.date.fromisoformat('2024-02-29'),
                contributor_aggregate_ytd='340.00',
                party_account_type='RECOUNT',
                party_full='REPUBLICAN PARTY',
                pdf_url='https://docquery.fec.gov/cgi-bin/fecimg/?202403209627299691',
                receipt_desc='CONTRIBUTION',
                receipt_type='32E',
                receipt_type_desc='EARMARKED – RECOUNT',
                recipient_committee_designation='U',
                report_type='M3',
                report_year='2024',
                schedule_type='SA',
                schedule_type_desc='ITEMIZED RECEIPTS',
                state='DC',
                state_full='District Of Columbia',
                two_year_transaction_period='2024',
            ),
            factories.NationalParty_ScheduleAFactory(
                committee_id='C00000003',
                committee_name='NRCC',
                contributor_committee_name='',
                contributor_committee_designation='U',
                contributor_committee_state='VA',
                contributor_city='PLEASANTON',
                contributor_employer='RETIRED',
                contributor_first_name='CAROL',
                contributor_id='C00694323',
                contributor_last_name='LEHMAN',
                contributor_name='LEHMAN, CAROL',
                contributor_occupation='RETIRED',
                contributor_state='CA',
                contribution_receipt_amount='35.00',
                contribution_receipt_date=datetime.date.fromisoformat('2024-02-29'),
                contributor_aggregate_ytd='340.00',
                party_account_type='HEADQUARTERS',
                party_full='REPUBLICAN PARTY',
                pdf_url='https://docquery.fec.gov/cgi-bin/fecimg/?202403209627299691',
                receipt_desc='CONTRIBUTION',
                receipt_type='32E',
                receipt_type_desc='EARMARKED – RECOUNT',
                recipient_committee_designation='U',
                report_type='M3',
                report_year='2024',
                schedule_type='SA',
                schedule_type_desc='ITEMIZED RECEIPTS',
                state='DC',
                state_full='District Of Columbia',
                two_year_transaction_period='2024',
            ),
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleAView, party_account_type='HEADQUARTERS', **self.kwargs)
        )
        self.assertEqual(len(results), 1)
        assert results[0]['committee_id'] == 'C00000003'

        results = self._results(
            api.url_for(NationalParty_ScheduleAView, party_account_type='RECOUNT', **self.kwargs)
        )
        self.assertEqual(len(results), 2)


class TestNationalPartyScheduleB(ApiBaseTest):
    kwargs = {'two_year_transaction_period': 2024}

    def test_multiple_two_year_transaction_period(self):
        """
        testing schedule_b api can take multiple cycles now
        """
        [  # noqa
            factories.NationalParty_ScheduleBFactory(
                report_year=2014, two_year_transaction_period=2014
            ),
            factories.NationalParty_ScheduleBFactory(
                report_year=2016, two_year_transaction_period=2016
            ),
            factories.NationalParty_ScheduleBFactory(
                report_year=2018, two_year_transaction_period=2018
            ),
        ]
        response = self._response(
            api.url_for(NationalParty_ScheduleBView, two_year_transaction_period=[2016, 2018],)
        )
        self.assertEqual(len(response['results']), 2)

    def test_recipient_committee_designation_filter(self):
        [
            factories.NationalParty_ScheduleBFactory(recipient_committee_designation='A'),
            factories.NationalParty_ScheduleBFactory(recipient_committee_designation='B'),
            factories.NationalParty_ScheduleBFactory(recipient_committee_designation='B'),
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleBView, recipient_committee_designation='B', **self.kwargs)
        )
        self.assertEqual(len(results), 2)

    def test_recipient_committee_type_filter(self):
        [
            factories.NationalParty_ScheduleBFactory(recipient_committee_type='Y'),
            factories.NationalParty_ScheduleBFactory(recipient_committee_type='Y'),
            factories.NationalParty_ScheduleBFactory(recipient_committee_type='Z'),
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleBView, recipient_committee_type='Y', **self.kwargs)
        )
        self.assertEqual(len(results), 2)

    def test_disbursement_description_filter(self):
        [
            factories.NationalParty_ScheduleBFactory(
                disbursement_description_text=sa.func.to_tsvector('RECOUNT - TRAVEL'),
                disbursement_description='RECOUNT - TRAVEL'),
            factories.NationalParty_ScheduleBFactory(
                disbursement_description_text=sa.func.to_tsvector('LEGAL/RECOUNT TRAVEL'),
                disbursement_description='LEGAL/RECOUNT TRAVEL'),
            factories.NationalParty_ScheduleBFactory(
                disbursement_description_text=sa.func.to_tsvector('LEGAL FEES'),
                disbursement_description='LEGAL FEES'),
            factories.NationalParty_ScheduleBFactory(
                disbursement_description_text=sa.func.to_tsvector('N/A'),
                disbursement_description='N/A'),
        ]
        results = self._results(
            api.url_for(NationalParty_ScheduleBView, disbursement_description='N/A', **self.kwargs)
        )
        self.assertEqual(len(results), 1)

        results = self._results(
            api.url_for(NationalParty_ScheduleBView, disbursement_description='LEGAL')
        )
        self.assertEqual(len(results), 2)


class TestNationalPartyTotals(ApiBaseTest):
    kwargs = {'two_year_transaction_period': 2024}

    def test_national_party_totals(self):
        [
            factories. NationalPartyTotalsFactory(
                two_year_transaction_period=2016,
                committee_id='C00075820',
                committee_name='NRCC',
                total_disbursements=100.00,
                total_receipts=50.00,
            ),
            factories.NationalPartyTotalsFactory(
               two_year_transaction_period=2018,
               committee_id='C00075820',
               committee_name='NRCC',
               total_disbursements=120.00,
               total_receipts=70.00,
            ),
            factories.NationalPartyTotalsFactory(
               two_year_transaction_period=2020,
               committee_id='C00075820',
               committee_name='NRCC',
               total_disbursements=130.00,
               total_receipts=90.00,
            ),
            factories.NationalPartyTotalsFactory(
               two_year_transaction_period=2024,
               committee_id='C00255695',
               committee_name='LIBERTARIAN NATIONAL COMMITTEE, INC.',
               total_disbursements=100.00,
               total_receipts=90.00,
            ),
        ]
        response = self._response(
            api.url_for(NationalPartyTotalsView, committee_id='C00075820')
        )
        self.assertEqual(len(response['results']), 3)

        response = self._response(
            api.url_for(NationalPartyTotalsView, committee_id='C00075820', two_year_transaction_period=2016)
        )
        self.assertEqual(len(response['results']), 1)

        response = self._response(
            api.url_for(NationalPartyTotalsView, committee_id='C00255695',)
        )
        self.assertEqual(len(response['results']), 1)
