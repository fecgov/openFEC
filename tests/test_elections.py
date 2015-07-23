from webservices.rest import api
from webservices.resources.elections import ElectionView

from tests import factories
from tests.common import ApiBaseTest


class TestElections(ApiBaseTest):

    def setUp(self):
        super().setUp()
        self.candidate = factories.CandidateHistoryFactory(
            state='NY',
            district='07',
            two_year_period=2012,
        )
        self.committee = factories.CommitteeHistoryFactory(cycle=2012, designation='P')
        factories.CandidateCommitteeLinkFactory(
            candidate_id=self.candidate.candidate_id,
            committee_id=self.committee.committee_id,
        )
        self.filing = factories.FilingsFactory(
            form_type='F3',
            report_type='Q3',
            report_year=2012,
            cash_on_hand_end_period=1979,
            committee_id=self.committee.committee_id,
        )

    def test_missing_params(self):
        response = self.app.get(api.url_for(ElectionView))
        self.assertEquals(response.status_code, 422)

    def test_conditional_missing_params(self):
        response = self.app.get(api.url_for(ElectionView, office='presidential', cycle=2012))
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
            'total_receipts': self.filing.total_receipts,
            'total_disbursements': self.filing.total_disbursements,
            'cash_on_hand_end_period': self.filing.cash_on_hand_end_period,
            'document_description': self.filing.document_description,
            'pdf_url': self.filing.pdf_url,
        }
        self.assertEqual(results[0], expected)
