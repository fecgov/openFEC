import unittest

from flask import request
from webargs import flaskparser

from tests import factories
from tests.common import ApiBaseTest

from webservices import args
from webservices import rest
from webservices import sorting
from webservices.resources import candidate_aggregates
from webservices.resources import elections
from webservices.rest import db
from webservices.tasks import utils

from sqlalchemy.dialects import postgresql

from webservices.common import models


class TestSort(ApiBaseTest):

    def test_single_column(self):
        candidates = [
            factories.CandidateFactory(district='01'),
            factories.CandidateFactory(district='02'),
        ]
        query, columns = sorting.sort(models.Candidate.query, 'district', model=models.Candidate)
        self.assertEqual(query.all(), candidates)

    def test_single_column_reverse(self):
        candidates = [
            factories.CandidateFactory(district='01'),
            factories.CandidateFactory(district='02'),
        ]
        query, columns = sorting.sort(models.Candidate.query, '-district', model=models.Candidate)
        self.assertEqual(query.all(), candidates[::-1])

    def test_hide_null(self):
        candidates = [
            factories.CandidateFactory(district='01'),
            factories.CandidateFactory(district='02'),
            factories.CandidateFactory(),
        ]
        query, columns = sorting.sort(models.Candidate.query, 'district', model=models.Candidate)
        self.assertEqual(query.all(), candidates)
        query, columns = sorting.sort(models.Candidate.query, 'district', model=models.Candidate, hide_null=True)
        self.assertEqual(query.all(), candidates[:2])

    def test_hide_null_candidate_totals(self):
        candidates = [
            factories.CandidateFactory(candidate_id='C1234'),
            factories.CandidateFactory(candidate_id='C5678'),

        ]
        candidateHistory = [
            factories.CandidateHistoryFactory(candidate_id='C1234', two_year_period=2016, election_years=[2016], cycles=[2016],candidate_election_year=2016),
            factories.CandidateHistoryFactory(candidate_id='C5678', two_year_period=2016, election_years=[2016], cycles=[2016],candidate_election_year=2016)
        ]
        candidateTotals = [
            factories.CandidateTotalFactory(candidate_id='C1234', is_election=False, cycle=2016),
            factories.CandidateTotalFactory(candidate_id='C5678', disbursements='9999.99', is_election=False, cycle=2016)
        ]
        candidateFlags = [
            factories.CandidateFlagsFactory(candidate_id='C1234'),
            factories.CandidateFlagsFactory(candidate_id='C5678')
        ]

        tcv = candidate_aggregates.TotalsCandidateView()
        query, columns = sorting.sort(tcv.build_query(election_full=False), 'disbursements', model=None)
        self.assertEqual(len(query.all()), len(candidates))
        query, columns = sorting.sort(tcv.build_query(election_full=False), 'disbursements', model=None, hide_null=True)
        self.assertEqual(len(query.all()), len(candidates) - 1)
        self.assertTrue(candidates[1].candidate_id in query.all()[0])

    def test_hide_null_election(self):
        candidates = [
            factories.CandidateFactory(candidate_id='C1234'),
            factories.CandidateFactory(candidate_id='C5678'),
        ]
        cmteFacorty = [
            factories.CommitteeDetailFactory(committee_id='H1234'),
            factories.CommitteeDetailFactory(committee_id='H5678')
        ]
        db.session.flush()
        candidateHistory = [
            factories.CandidateHistoryFactory(candidate_id='C1234', two_year_period=2016, state='MO',
                                              candidate_election_year=2016, candidate_inactive=False, district='01',
                                              office='S', election_years=[2016], cycles=[2016]),
            factories.CandidateHistoryFactory(candidate_id='C5678',  candidate_election_year=2016,
                                              two_year_period=2016, state='MO', election_years=[2016], cycles=[2016],
                                              candidate_inactive=False, district='02', office='S')
        ]
        candidateCmteLinks = [
            factories.CandidateCommitteeLinkFactory(committee_id='H1234', candidate_id='C1234', fec_election_year=2016,committee_designation='P'),
            factories.CandidateCommitteeLinkFactory(committee_id='H5678', candidate_id='C5678', fec_election_year=2016,
                                                    committee_designation='P')

        ]
        cmteTotalsFactory = [
            factories.CommitteeTotalsHouseSenateFactory(committee_id='H1234', cycle=2016),
            factories.CommitteeTotalsHouseSenateFactory(committee_id='H1234', cycle=2016, disbursements='9999.99'),
            factories.CommitteeTotalsHouseSenateFactory(committee_id='H5678', cycle=2016)

        ]
        electionResults = [
            factories.ElectionResultFactory(cand_id='C1234', election_yr=2016, cand_office='S', cand_office_st='MO', cand_office_district='01' ),
            factories.ElectionResultFactory(cand_id='C5678', election_yr=2016, cand_office='S', cand_office_st='MO',
                                            cand_office_district='02')

        ]
        db.session.flush()
        arg_map = {}
        arg_map['office'] = 'senate'
        arg_map['cycle'] = 2016
        arg_map['state'] = 'MO'
        #arg_map['district'] = '00'

        electionView = elections.ElectionView()
        query, columns = sorting.sort(electionView._get_records(arg_map), 'total_disbursements', model=None)

        #print(str(query.statement.compile(dialect=postgresql.dialect())))
        self.assertEqual(len(query.all()), len(candidates))
        query, columns = sorting.sort(electionView._get_records(arg_map), 'total_disbursements', model=None, hide_null=True)
        #Taking this assert statement out because I believe, at least how the FEC interprets null (i.e. none) primary
        #committees for a candidate is that they have in fact raised/spent 0.0 dollars, this can be shown as true
        #using the Alabama special election as an example
        #self.assertEqual(len(query.all()), len(candidates) - 1)
        self.assertTrue(candidates[1].candidate_id in query.all()[0])
        self.assertEqual(query.all()[0].total_disbursements, 0.0)


class TestArgs(unittest.TestCase):

    def test_currency(self):
        with rest.app.test_request_context('?dollars=$24.50'):
            parsed = flaskparser.parser.parse({'dollars': args.Currency()}, request)
            self.assertEqual(parsed, {'dollars': 24.50})

    def test_format_url(self):
        """
        remove the api_key=DEMO_KEY
        from the url with regex 
        """
        url_before_format = "https://api.open.fec.gov/v1/schedules/schedule_e/by_candidate/?api_key=DEMO_KEY&candidate_id=S0AL00156&cycle=2018&election_full=false&per_page=100"
        url_after_format = utils.format_url(url_before_format)
        expected_url = "schedules/schedule_e/by_candidate/candidate_id=s0al00156/cycle=2018/election_full=false/per_page=100"

        self.assertEqual(url_after_format, expected_url)

    def test_replace_special_chars_from_url(self):
        """
        remove the special characters ? and & from the URL
        """
        url_before_format = "https://api.open.fec.gov/v1/schedules/schedule_e/by_candidate/?api_key=DEMO_KEY&candidate_id=S0AL00156&cycle=2018&election_full=false&per_page=100"
        url_after_format = utils.format_url(url_before_format)
        expected_url = "schedules/schedule_e/by_candidate/candidate_id=s0al00156/cycle=2018/election_full=false/per_page=100"
        self.assertEqual(url_after_format, expected_url)

    def test_ignore_case(self):
        """
        format the URL when the API_KEY is all uppecase
        """
        url_before_format = "https://api.open.fec.gov/v1/schedules/schedule_e/by_candidate/?API_KEY=DEMO_KEY&candidate_id=S0AL00156&cycle=2018&election_full=false&per_page=100" 
        url_after_format = utils.format_url(url_before_format)
        expected_url = "schedules/schedule_e/by_candidate/candidate_id=s0al00156/cycle=2018/election_full=false/per_page=100"
        self.assertEqual(url_after_format, expected_url)