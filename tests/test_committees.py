import datetime

import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest

from webservices import utils
from webservices.rest import db
from webservices.rest import api
from webservices.resources.committees import CommitteeList
from webservices.resources.committees import CommitteeView
from webservices.resources.committees import CommitteeHistoryView
from webservices.resources.candidates import CandidateView


class CommitteeFormatTest(ApiBaseTest):
    def test_committee_list_fields(self):
        committee = factories.CommitteeFactory(
            first_file_date=datetime.date.fromisoformat('1982-12-31'),
            committee_type='P',
            treasurer_name='Robert J. Lipshutz',
            party='DEM',
        )
        response = self._response(
            api.url_for(CommitteeView, committee_id=committee.committee_id)
        )
        result = response['results'][0]
        # main fields
        # original registration date doesn't make sense in this example, need to look into this more
        self.assertEqual(
            result['first_file_date'],
            datetime.date.fromisoformat('1982-12-31').isoformat(),
        )
        self.assertEqual(result['committee_type'], committee.committee_type)
        self.assertEqual(result['treasurer_name'], committee.treasurer_name)
        self.assertEqual(result['party'], committee.party)

    def test_fulltext_search(self):
        committee = factories.CommitteeFactory(
            name='Americans for a Better Tomorrow, Tomorrow'
        )
        decoy_committee = factories.CommitteeFactory()
        factories.CommitteeSearchFactory(
            id=committee.committee_id,
            fulltxt=sa.func.to_tsvector(committee.name),
            is_active=True,
        )
        queries = [
            'america',
            'tomorrow',
            'america tomorrow',
            'america & tomorrow',
        ]
        for query in queries:
            results = self._results(api.url_for(CommitteeList, q=query))
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0]['committee_id'], committee.committee_id)
            self.assertNotEqual(
                results[0]['committee_id'], decoy_committee.committee_id
            )

    def test_filter_by_candidate_id(self):
        candidate_id = 'ID0'
        candidate_committees = [
            factories.CommitteeFactory(candidate_ids=[candidate_id]) for _ in range(2)
        ]
        other_committees = [factories.CommitteeFactory() for _ in range(3)]  # noqa
        response = self._response(api.url_for(CommitteeList, candidate_id=candidate_id))
        self.assertEqual(len(response['results']), len(candidate_committees))

    def test_filter_by_candidate_ids(self):
        candidate_ids = ['ID0', 'ID1']
        candidate1_committees = [
            factories.CommitteeFactory(candidate_ids=[candidate_ids[0]])
            for _ in range(2)
        ]
        candidate2_committees = [
            factories.CommitteeFactory(candidate_ids=[candidate_ids[1]])
            for _ in range(2)
        ]
        other_committees = [factories.CommitteeFactory() for _ in range(3)]  # noqa
        response = self._response(
            api.url_for(CommitteeList, candidate_id=candidate_ids)
        )
        self.assertEqual(
            len(response['results']),
            len(candidate1_committees) + len(candidate2_committees),
        )

    def test_committee_detail_fields(self):
        committee = factories.CommitteeDetailFactory(
            first_file_date=datetime.date.fromisoformat('1982-12-31'),
            committee_type='P',
            treasurer_name='Robert J. Lipshutz',
            party='DEM',
            form_type='F1Z',
            street_1='1795 Peachtree Road',
            zip='30309',
        )
        response = self._response(
            api.url_for(CommitteeView, committee_id=committee.committee_id)
        )
        result = response['results'][0]
        # main fields
        self.assertEqual(
            result['first_file_date'], committee.first_file_date.isoformat()
        )
        self.assertEqual(result['committee_type'], committee.committee_type)
        self.assertEqual(result['treasurer_name'], committee.treasurer_name)
        self.assertEqual(result['party'], committee.party)
        # Things on the detailed view
        self.assertEqual(result['form_type'], committee.form_type)
        self.assertEqual(result['street_1'], committee.street_1)
        self.assertEqual(result['zip'], committee.zip)

    def test_committee_search_double_committee_id(self):
        committees = [factories.CommitteeFactory() for _ in range(2)]
        ids = [each.committee_id for each in committees]
        response = self._response(api.url_for(CommitteeList, committee_id=ids))
        results = response['results']
        self.assertEqual(len(results), 2)

    def test_committee_party(self):
        factories.CommitteeFactory(
            party='REP', party_full='Republican Party',
        )
        response = self._results(api.url_for(CommitteeList, party='REP'))
        self.assertEqual(response[0]['party'], 'REP')
        self.assertEqual(response[0]['party_full'], 'Republican Party')

    def test_filters_generic(self):
        self._check_filter('designation', ['B', 'P'])
        self._check_filter('organization_type', ['M', 'T'])
        self._check_filter('committee_type', ['H', 'X'])

    def _check_filter(self, field, values, alt=None, **attrs):

        # Build fixtures
        factories.CommitteeFactory(**utils.extend(attrs, {field: alt}))
        [
            factories.CommitteeFactory(**utils.extend(attrs, {field: value}))
            for value in values
        ]

        # Assert that exactly one record is found for each single-valued search
        # (e.g. field=value1)
        for value in values:
            url = api.url_for(CommitteeList, **{field: value})
            results = self._results(url)
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0][field], value)

        # Assert that `len(values)` records are found for multi-valued search
        # (e.g. field=value1,value2...valueN)
        url = api.url_for(CommitteeList, **{field: values})
        results = self._results(url)
        self.assertEqual(len(results), len(values))
        for result in results:
            self.assertIn(result[field], values)

    def test_committee_filters(self):
        [
            factories.CommitteeFactory(state='CA'),
            factories.CommitteeFactory(name='Obama'),
            factories.CommitteeFactory(committee_type='S'),
            factories.CommitteeFactory(designation='P'),
            factories.CommitteeFactory(party='DEM'),
            factories.CommitteeFactory(organization_type='C'),
            factories.CommitteeFactory(committee_id='C01'),
        ]

        # checking one example from each field
        filter_fields = (
            ('committee_id', ['C01', 'C02']),
            ('state', ['CA', 'DC']),
            ('committee_type', 'S'),
            ('designation', 'P'),
            ('party', ['REP', 'DEM']),
            ('organization_type', 'C'),
        )

        org_response = self._response(api.url_for(CommitteeList))
        original_count = org_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(CommitteeList, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])

    def test_committee_year_filter_skips_null_first_file_date(self):
        # Build fixtures
        dates = [
            datetime.date.fromisoformat('2012-01-01'),
            datetime.date.fromisoformat('2015-01-01'),
        ]
        [
            factories.CommitteeFactory(first_file_date=None, last_file_date=None),
            factories.CommitteeFactory(first_file_date=dates[0], last_file_date=None),
            factories.CommitteeFactory(first_file_date=None, last_file_date=dates[1]),
            factories.CommitteeFactory(
                first_file_date=dates[0], last_file_date=dates[1]
            ),
        ]

        # Check committee list results
        results = self._results(api.url_for(CommitteeList, year=2013))
        self.assertEqual(len(results), 2)
        for each in results:
            self.assertIsNotNone(each['first_file_date'])

    def test_committees_by_cand_id(self):
        committees = [factories.CommitteeFactory() for _ in range(3)]
        candidate = factories.CandidateFactory()
        db.session.flush()
        [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=candidate.candidate_id,
                committee_id=committee.committee_id,
            )
            for committee in committees
        ]
        results = self._results(
            api.url_for(CommitteeView, candidate_id=candidate.candidate_id)
        )

        self.assertEqual(
            set((each['committee_id'] for each in results)),
            set((each.committee_id for each in committees)),
        )

    def test_committees_by_candidate_count(self):
        committee = factories.CommitteeFactory()
        candidate = factories.CandidateFactory()
        db.session.flush()
        [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=candidate.candidate_id,
                committee_id=committee.committee_id,
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=candidate.candidate_id,
                committee_id=committee.committee_id,
            ),
        ]
        response = self._response(
            api.url_for(CommitteeView, candidate_id=candidate.candidate_id)
        )
        self.assertEqual(response['pagination']['count'], 1)
        self.assertEqual(len(response['results']), 1)

    def test_committee_by_cand_filter(self):
        committee = factories.CommitteeFactory(designation='P')
        candidate = factories.CandidateFactory()
        db.session.flush()
        factories.CandidateCommitteeLinkFactory(
            candidate_id=candidate.candidate_id, committee_id=committee.committee_id,
        )
        results = self._results(
            api.url_for(
                CommitteeView, candidate_id=candidate.candidate_id, designation='P'
            )
        )
        self.assertEqual(1, len(results))

    def test_candidates_by_committee(self):
        committee = factories.CommitteeFactory()
        candidate = factories.CandidateFactory()
        db.session.flush()
        factories.CandidateCommitteeLinkFactory(
            candidate_id=candidate.candidate_id, committee_id=committee.committee_id,
        )
        results = self._results(
            api.url_for(CandidateView, committee_id=committee.committee_id)
        )
        self.assertEqual(1, len(results))

    def test_committee_sort(self):
        committees = [
            factories.CommitteeFactory(designation='B'),
            factories.CommitteeFactory(designation='U'),
        ]
        committee_ids = [each.committee_id for each in committees]
        results = self._results(api.url_for(CommitteeList, sort='designation'))
        self.assertEqual([each['committee_id'] for each in results], committee_ids)
        results = self._results(api.url_for(CommitteeList, sort='-designation'))
        self.assertEqual(
            [each['committee_id'] for each in results], committee_ids[::-1]
        )

    def test_committee_sort_default(self):
        committees = [
            factories.CommitteeFactory(name='Zartlet for America'),
            factories.CommitteeFactory(name='Bartlet for America'),
        ]
        committee_ids = [each.committee_id for each in committees]
        results = self._results(api.url_for(CommitteeList))
        self.assertEqual(
            [each['committee_id'] for each in results], committee_ids[::-1]
        )

    def test_treasurer_filter(self):
        committees = [
            factories.CommitteeFactory(
                treasurer_text=sa.func.to_tsvector('uncle pennybags')
            ),
            factories.CommitteeFactory(
                treasurer_text=sa.func.to_tsvector('eve moneypenny')
            ),
        ]
        results = self._results(api.url_for(CommitteeList, treasurer_name='moneypenny'))
        assert len(results) == 1
        assert results[0]['committee_id'] == committees[1].committee_id

    def test_committee_date_filters(self):
        [
            factories.CommitteeFactory(
                first_file_date=datetime.date.fromisoformat('2015-01-01')
            ),
            factories.CommitteeFactory(
                first_file_date=datetime.date.fromisoformat('2015-02-01')
            ),
            factories.CommitteeFactory(
                first_file_date=datetime.date.fromisoformat('2015-03-01')
            ),
            factories.CommitteeFactory(
                first_file_date=datetime.date.fromisoformat('2015-04-01')
            ),
        ]
        results = self._results(
            api.url_for(
                CommitteeList,
                min_first_file_date=datetime.date.fromisoformat('2015-02-01'),
            )
        )
        self.assertTrue(
            all(
                each['first_file_date']
                >= datetime.date.fromisoformat('2015-02-01').isoformat()
                for each in results
            )
        )
        results = self._results(
            api.url_for(
                CommitteeList,
                max_first_file_date=datetime.date.fromisoformat('2015-02-03'),
            )
        )
        self.assertTrue(
            all(
                each['first_file_date']
                <= datetime.date.fromisoformat('2015-02-03').isoformat()
                for each in results
            )
        )
        results = self._results(
            api.url_for(
                CommitteeList,
                min_first_file_date=datetime.date.fromisoformat('2015-02-01'),
                max_first_file_date=datetime.date.fromisoformat('2015-03-01'),
            )
        )
        self.assertTrue(
            all(
                datetime.date.fromisoformat('2015-02-01').isoformat()
                <= each['first_file_date']
                <= datetime.date.fromisoformat('2015-03-01').isoformat()
                for each in results
            )
        )


class TestCommitteeHistory(ApiBaseTest):
    def setUp(self):
        super().setUp()
        self.candidate = factories.CandidateDetailFactory()
        self.committees = [factories.CommitteeDetailFactory() for _ in range(5)]
        self.histories = [
            factories.CommitteeHistoryFactory(
                committee_id=self.committees[0].committee_id,
                cycle=2010,
                designation='P',
                is_active=True,
            ),
            factories.CommitteeHistoryFactory(
                committee_id=self.committees[1].committee_id,
                cycle=2012,
                designation='P',
                is_active=True,
            ),
            factories.CommitteeHistoryFactory(
                committee_id=self.committees[2].committee_id,
                cycle=2014,
                designation='P',
                is_active=True,
            ),
            # Candidate PCC converted to PAC in 2016
            factories.CommitteeHistoryFactory(
                committee_id=self.committees[2].committee_id,
                cycle=2016,
                designation='P',
                is_active=True,
                # Needed to show conversion info
                former_candidate_id=self.candidate.candidate_id,
                former_candidate_election_year=2016,
                former_committee_name="Used to be PCC but I'm a PAC now committeee"
            ),
            factories.CommitteeHistoryFactory(
                committee_id=self.committees[3].committee_id,
                cycle=2014,
                designation='A',
                is_active=False,
            ),
            factories.CommitteeHistoryFactory(
                committee_id=self.committees[4].committee_id,
                cycle=2014,
                designation='J',
                is_active=False,
            ),
        ]

        db.session.flush()
        self.links = [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[0].committee_id,
                fec_election_year=2010,
                election_yr_to_be_included=2012,
                committee_type='P',
                committee_designation='P',
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[1].committee_id,
                fec_election_year=2012,
                election_yr_to_be_included=2012,
                committee_type='P',
                committee_designation='P',
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[2].committee_id,
                fec_election_year=2014,
                committee_type='P',
                committee_designation='P',
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[3].committee_id,
                fec_election_year=2014,
                committee_type='P',
                committee_designation='A',
            ),
            factories.CandidateCommitteeLinkFactory(
                candidate_id=self.candidate.candidate_id,
                committee_id=self.committees[4].committee_id,
                fec_election_year=2014,
                committee_type='P',
                committee_designation='J',
            ),
        ]
        self.elections = [
            factories.CandidateElectionFactory(
                candidate_id=self.candidate.candidate_id,
                cand_election_year=2012,
                prev_election_year=2008,
            ),
            factories.CandidateElectionFactory(
                candidate_id=self.candidate.candidate_id,
                cand_election_year=2016,
                prev_election_year=2012,
            ),
        ]

    def test_is_active(self):
        results = self._results(
            api.url_for(
                CommitteeHistoryView,
                committee_id=self.committees[4].committee_id,
                cycle=2014,
                election_full=False,
                is_active=False,
            )
        )
        assert len(results) == 1

        results = self._results(
            api.url_for(
                CommitteeHistoryView,
                committee_id=self.committees[2].committee_id,
                cycle=2014,
                election_full=False,
                is_active=True,
            )
        )
        assert len(results) == 1

    def test_candidate_cycle(self):
        results = self._results(
            api.url_for(
                CommitteeHistoryView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
                election_full=False,
            )
        )
        assert len(results) == 1
        assert results[0]['cycle'] == 2012
        assert results[0]['committee_id'] == self.committees[1].committee_id

    def test_election_full(self):
        results = self._results(
            api.url_for(
                CommitteeHistoryView,
                candidate_id=self.candidate.candidate_id,
                cycle=2012,
                election_full=True,
            )
        )
        assert len(results) == 2
        # Sort order isn't working properly - see #4012
        assert results[0]['committee_id'] == self.committees[0].committee_id
        assert results[0]['cycle'] == 2010
        assert results[1]['committee_id'] == self.committees[1].committee_id
        assert results[1]['cycle'] == 2012

    def test_designation(self):
        results = self._results(
            api.url_for(
                CommitteeHistoryView,
                candidate_id=self.candidate.candidate_id,
                designation=['P', 'A'],
            )
        )
        assert len(results) == 4
        assert 'J' not in [committee.get('designation') for committee in results]

    def test_converted_commtitee(self):
        """Where PCC converted to PAC in 2016, still show committee history"""
        results = self._results(
            api.url_for(
                CommitteeHistoryView,
                candidate_id=self.candidate.candidate_id,
                cycle=2016,
                election_full=True
            )
        )

        assert len(results) == 1
        assert results[0].get("former_candidate_id") == self.candidate.candidate_id

    def test_case_insensitivity(self):
        lower_candidate = factories.CandidateDetailFactory(candidate_id="H01")
        lower_committee_1 = factories.CommitteeDetailFactory(committee_id="ID01")
        [
            factories.CommitteeHistoryFactory(
                committee_id=lower_committee_1.committee_id,
                cycle=2014,
                designation='J',
                is_active=False,
            ),
        ]
        db.session.flush()
        [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=lower_candidate.candidate_id,
                committee_id=lower_committee_1.committee_id,
                fec_election_year=2014,
                committee_type='P',
                committee_designation='J',
            ),
        ]
        [
            factories.CandidateElectionFactory(
                candidate_id=lower_candidate.candidate_id,
                cand_election_year=2012,
                prev_election_year=2008,
            ),
            factories.CandidateElectionFactory(
                candidate_id=lower_candidate.candidate_id,
                cand_election_year=2016,
                prev_election_year=2012,
            ),
        ]

        results = self._results(
            api.url_for(
                CommitteeHistoryView,
                committee_id="id01",
                cycle=2014,
                election_full=False,
                is_active=False,
            )
        )
        assert len(results) == 1

        results = self._results(
            api.url_for(
                CommitteeHistoryView,
                candidate_id="h01",
                cycle=2014,
                election_full=False,
                is_active=False,
            )
        )
        assert len(results) == 1
