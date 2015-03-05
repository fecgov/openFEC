from .common import ApiBaseTest
import unittest

@unittest.skip('I think there are issues with the API not returning the most recent info')
class CandidateFormatTest(ApiBaseTest):
    """Test/Document expected formats"""
    def test_for_regressions(self):
        """Compare results to expected fields."""
        # @todo - use a factory rather than the test data
        response = self._response('/candidate/H0VA08040?fields=*')
        self.assertResultsEqual(
            response['pagination'],
            {'count': 1, 'page': 1, 'pages': 1, 'per_page': 1})
        self.assertEqual(len(response['results']), 1)

        result = response['results'][0]
        self.assertEqual(result['candidate_id'], 'H0VA08040')
        self.assertEqual(result['form_type'], 'F2')
        # @todo - check for a value for expire_data
        self.assertEqual(result['expire_date'], None)
        self.assertEqual(result['load_date'], '1990-02-05 00:00:00')
        self.assertResultsEqual(
            result['name'],
            {
                "full_name": "MORAN, JAMES P. JR.",
                "name_1": "JAMES P JR",
                "name_2": "MORAN",
                "other_names": [
                    "MORAN, JAMES P JR", "MORAN, JAMES P",
                    "MORAN, JAMES PATRICK", "MORAN, JAMES P  JR."]
            })
        address = {
            "city": "ALEXANDRIA",
            "expire_date": "2009-01-01",
            "state": "VA",
            "street_1": "311 NORTH WASHINGTON STREET",
            "street_2": "SUITE 200L",
            "zip": "22314"
        }
        self.assertTrue(address in result['mailing_addresses'])

        self.assertEqual(2, len(result['elections']))
        election = result['elections'][0]
        primary_committee = election['primary_committee']  # tested separately
        del election['primary_committee']
        self.assertResultsEqual(
            election,
            {
                # From office_mapping
                "office": "H",
                "district": "08",
                "state": "VA",
                "office_sought": "H",
                "office_sought_full": "House",
                # From party_mapping
                "party": "DEM",
                "party_affiliation": "Democratic Party",
                # From status_mapping
                "election_year": 2014,
                "candidate_inactive": "Y",
                "candidate_status": "C",
                "incumbent_challenge": None,
                # Expanded from candidate_status
                "candidate_status_full": "candidate",
            })

        self.assertResultsEqual(
            primary_committee,
            {
                # From cand_committee_format_mapping
                "committee_id": "C00241349",
                "designation": "P",
                "type": "H",
                "election_year": 2014,
                # Calculated separately
                "committee_name": "MORAN FOR CONGRESS",
                "designation_full": "Principal campaign committee",
                "type_full": "House"
            })

        # The above candidate is missing a few fields
        response = self._response('/candidate/P20003984?fields=*')
        election = response['results'][0]['elections'][0]
        self.assertEqual(election["incumbent_challenge"], "C")
        self.assertEqual(election["incumbent_challenge_full"], "challenger")
        self.assertResultsEqual(
            election['affiliated_committees'],
            [{
                "committee_id": "C00527648",
                "committee_name": "CONNECTICUT GREEN PRESIDENTIAL COMMITTEE",
                "designation": "U",
                "designation_full": "Unauthorized",
                "election_year": 2012.0,
                "type": "I",
                "type_full": "Independent Expenditor (Person or Group)"
            }])
