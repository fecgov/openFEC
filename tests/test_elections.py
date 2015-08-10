import datetime

from webservices.rest import db, api
from webservices.resources.elections import ElectionList, ElectionView

from tests import factories
from tests.common import ApiBaseTest


class TestElectionSearch(ApiBaseTest):

    def setUp(self):
        super().setUp()
        self.candidates = [
            factories.CandidateHistoryFactory(office='P', state='US', district=None, two_year_period=2012),
            factories.CandidateHistoryFactory(office='S', state='NJ', district=None, two_year_period=2012),
            factories.CandidateHistoryFactory(office='H', state='NJ', district='09', two_year_period=2012),
            factories.CandidateHistoryFactory(office='S', state='VA', district=None, two_year_period=2012),
            factories.CandidateHistoryFactory(office='H', state='VA', district='05', two_year_period=2012),
        ]

    def test_search_district(self):
        results = self._results(api.url_for(ElectionList, state='NJ', district='09'))
        self.assertEqual(len(results), 3)
        self.assertEqual(results[0], {'cycle': 2012, 'office': 'P', 'state': 'US', 'district': None})
        self.assertEqual(results[1], {'cycle': 2012, 'office': 'S', 'state': 'NJ', 'district': None})
        self.assertEqual(results[2], {'cycle': 2012, 'office': 'H', 'state': 'NJ', 'district': '09'})

    def test_search_zip(self):
        results = self._results(api.url_for(ElectionList, zip='22902'))
        self.assertEqual(len(results), 3)
        self.assertEqual(results[0], {'cycle': 2012, 'office': 'P', 'state': 'US', 'district': None})
        self.assertEqual(results[1], {'cycle': 2012, 'office': 'S', 'state': 'VA', 'district': None})
        self.assertEqual(results[2], {'cycle': 2012, 'office': 'H', 'state': 'VA', 'district': '05'})


class TestElections(ApiBaseTest):

    def setUp(self):
        super().setUp()
        self.candidate = factories.CandidateHistoryFactory(
            state='NY',
            district='07',
            two_year_period=2012,
            office='H',
        )
        self.committees = [
            factories.CommitteeHistoryFactory(cycle=2012, designation='P'),
            factories.CommitteeHistoryFactory(cycle=2012, designation='A'),
        ]
        factories.CandidateDetailFactory(candidate_key=self.candidate.candidate_key)
        [
            factories.CommitteeDetailFactory(committee_key=each.committee_key)
            for each in self.committees
        ]
        db.session.flush()
        factories.CandidateCommitteeLinkFactory(
            candidate_key=self.candidate.candidate_key,
            committee_key=self.committees[0].committee_key,
        )
        factories.CandidateCommitteeLinkFactory(
            candidate_key=self.candidate.candidate_key,
            committee_key=self.committees[1].committee_key,
        )
        self.filings = [
            factories.FilingsFactory(
                form_type='F3',
                report_type='Q3',
                report_year=2012,
                total_receipts=50,
                total_disbursements=75,
                cash_on_hand_end_period=1979,
                committee_id=self.committees[0].committee_id,
                report_type_full='Quarter Three',
                coverage_end_date=datetime.datetime(2012, 9, 30),
            ),
            factories.FilingsFactory(
                form_type='F3',
                report_type='Q4',
                report_year=2012,
                total_receipts=50,
                total_disbursements=75,
                cash_on_hand_end_period=25,
                committee_id=self.committees[1].committee_id,
                report_type_full='Quarter Four',
                coverage_end_date=datetime.datetime(2012, 12, 31),
            ),
        ]

    def test_missing_params(self):
        response = self.app.get(api.url_for(ElectionView))
        self.assertEquals(response.status_code, 422)

    def test_conditional_missing_params(self):
        response = self.app.get(api.url_for(ElectionView, office='president', cycle=2012))
        self.assertEquals(response.status_code, 200)
        response = self.app.get(api.url_for(ElectionView, office='senate', cycle=2012))
        self.assertEquals(response.status_code, 422)
        response = self.app.get(api.url_for(ElectionView, office='senate', cycle=2012, state='NY'))
        self.assertEquals(response.status_code, 200)
        response = self.app.get(api.url_for(ElectionView, office='house', cycle=2012, state='NY'))
        self.assertEquals(response.status_code, 422)
        response = self.app.get(api.url_for(ElectionView, office='house', cycle=2012, state='NY', district='01'))
        self.assertEquals(response.status_code, 200)

    def test_elections(self):
        results = self._results(api.url_for(ElectionView, office='house', cycle=2012, state='NY', district='07'))
        self.assertEqual(len(results), 1)
        expected = {
            'candidate_id': self.candidate.candidate_id,
            'candidate_name': self.candidate.name,
            'candidate_status_full': self.candidate.candidate_status_full,
            'total_receipts': sum(each.total_receipts for each in self.filings),
            'total_disbursements': sum(each.total_disbursements for each in self.filings),
            'cash_on_hand_end_period': sum(each.cash_on_hand_end_period for each in self.filings),
            'document_description': self.filings[1].document_description,
            'pdf_url': self.filings[1].pdf_url,
        }
        self.assertEqual(results[0], expected)
