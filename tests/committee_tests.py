import urllib
import datetime
import functools

import sqlalchemy as sa
from marshmallow.utils import isoformat

from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import db
from webservices.rest import api
from webservices.rest import CommitteeList
from webservices.rest import CommitteeView
from webservices.rest import CandidateList
from webservices.rest import CandidateView


def extend(*dicts):
    ret = {}
    for each in dicts:
        ret.update(each)
    return ret


## old, re-factored Committee tests ##
class CommitteeFormatTest(ApiBaseTest):
    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_committee_list_fields(self):
        committee = factories.CommitteeFactory(
            first_file_date=datetime.datetime(1982, 12, 31),
            committee_type='P',
            treasurer_name='Robert J. Lipshutz',
            party='DEM',
        )
        response = self._response(api.url_for(CommitteeView, committee_id=committee.committee_id))
        result = response['results'][0]
        # main fields
        # original registration date doesn't make sense in this example, need to look into this more
        self.assertEqual(result['first_file_date'], isoformat(committee.first_file_date))
        self.assertEqual(result['committee_type'], committee.committee_type)
        self.assertEqual(result['treasurer_name'], committee.treasurer_name)
        self.assertEqual(result['party'], committee.party)

    def test_fulltext_search(self):
        committee = factories.CommitteeFactory(name='Americans for a Better Tomorrow, Tomorrow')
        decoy_committee = factories.CommitteeFactory()
        factories.CommitteeSearchFactory(
            cmte_sk=committee.committee_key,
            fulltxt=sa.func.to_tsvector(committee.name),
        )
        results = self._results(api.url_for(CommitteeList, q='tomorrow'))
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['committee_id'], committee.committee_id)
        self.assertNotEqual(results[0]['committee_id'], decoy_committee.committee_id)

    def test_filter_by_candidate_id(self):
        candidate_id = 'id0'
        candidate_committees = [factories.CommitteeFactory(candidate_ids=[candidate_id]) for _ in range(2)]
        other_committees = [factories.CommitteeFactory() for _ in range(3)]  # noqa
        response = self._response(api.url_for(CommitteeList, candidate_id=candidate_id))
        self.assertEqual(
            len(response['results']),
            len(candidate_committees)
        )

    def test_filter_by_candidate_ids(self):
        candidate_ids = ['id0', 'id1']
        candidate1_committees = [factories.CommitteeFactory(candidate_ids=[candidate_ids[0]]) for _ in range(2)]
        candidate2_committees = [factories.CommitteeFactory(candidate_ids=[candidate_ids[1]]) for _ in range(2)]
        other_committees = [factories.CommitteeFactory() for _ in range(3)]  # noqa
        response = self._response(api.url_for(CommitteeList, candidate_id=candidate_ids))
        self.assertEqual(
            len(response['results']),
            len(candidate1_committees) + len(candidate2_committees)
        )

    def test_committee_detail_fields(self):
        committee = factories.CommitteeDetailFactory(
            first_file_date=datetime.datetime(1982, 12, 31),
            committee_type='P',
            treasurer_name='Robert J. Lipshutz',
            party='DEM',
            form_type='F1Z',
            load_date=datetime.datetime(1982, 12, 31),
            street_1='1795 Peachtree Road',
            zip='30309',
        )
        response = self._response(api.url_for(CommitteeView, committee_id=committee.committee_id))
        result = response['results'][0]
        # main fields
        self.assertEqual(result['first_file_date'], isoformat(committee.first_file_date))
        self.assertEqual(result['committee_type'], committee.committee_type)
        self.assertEqual(result['treasurer_name'], committee.treasurer_name)
        self.assertEqual(result['party'], committee.party)
        # Things on the detailed view
        self.assertEqual(result['form_type'], committee.form_type)
        self.assertEqual(result['load_date'], str(committee.load_date))
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
            party='REP',
            party_full='Republican Party',
        )
        response = self._results(api.url_for(CommitteeList, party='REP'))
        self.assertEquals(response[0]['party'], 'REP')
        self.assertEquals(response[0]['party_full'], 'Republican Party')

    # TODO(jmcarp) Refactor as parameterized tests
    # TODO(jmcarp) Generalize to /committees endpoint
    # TODO(jmcarp) Generalize to candidate models
    def test_filters_generic(self):
        committee = factories.CommitteeFactory()
        committee_id = committee.committee_id
        base_url = api.url_for(CommitteeView, committee_id=committee_id)
        self._check_filter('designation', ['B', 'P'], base_url, committee_id=committee_id)
        self._check_filter('organization_type', ['M', 'T'], base_url, committee_id=committee_id)
        self._check_filter('committee_type', ['H', 'X'], base_url, committee_id=committee_id)

    def _check_filter(self, field, values, base_url, alt=None, **attrs):

        # Build fixtures
        factories.CommitteeFactory(**extend(attrs, {field: alt}))
        [
            factories.CommitteeFactory(**extend(attrs, {field: value}))
            for value in values
        ]

        # Assert that exactly one record is found for each single-valued search
        # (e.g. field=value1)
        for value in values:
            url = '{0}?{1}={2}'.format(base_url, field, value)
            results = self._results(url)
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0][field], value)

        # Assert that `len(values)` records are found for multi-valued search
        # (e.g. field=value1,value2...valueN)
        url = '{0}?{1}'.format(
            base_url,
            urllib.parse.urlencode({field: values}, doseq=True)
        )
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
            ('name', 'Obama'),
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
        committee_id = 'concannon'
        dates = [
            datetime.datetime(2012, 1, 1),
            datetime.datetime(2015, 1, 1),
        ]
        partial = functools.partial(factories.CommitteeFactory, committee_id=committee_id)
        [
            partial(first_file_date=None, last_file_date=None),
            partial(first_file_date=dates[0], last_file_date=None),
            partial(first_file_date=None, last_file_date=dates[1]),
            partial(first_file_date=dates[0], last_file_date=dates[1]),
        ]

        # Check committee list results
        results = self._results(api.url_for(CommitteeList, year=2013))
        self.assertEqual(len(results), 2)
        for each in results:
            self.assertIsNotNone(each['first_file_date'])

        # Check committee detail results
        results = self._results(
            api.url_for(CommitteeView, committee_id=committee_id, year=2013)
        )
        self.assertEqual(len(results), 2)
        for each in results:
            self.assertIsNotNone(each['first_file_date'])

    def test_committees_by_cand_id(self):
        candidate_id = 'id0'
        committees = [factories.CommitteeFactory() for _ in range(3)]
        db.session.flush()
        [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=candidate_id,
                committee_id=committee.committee_id,
                committee_key=committee.committee_key,
            )
            for committee in committees
        ]
        results = self._results(api.url_for(CommitteeView, candidate_id=candidate_id))

        self.assertEqual(
            set((each['committee_id'] for each in results)),
            set((each.committee_id for each in committees)),
        )

    def test_committee_by_cand_filter(self):
        candidate_id = 'id0'
        committee = factories.CommitteeFactory(designation='P')
        db.session.flush()
        factories.CandidateCommitteeLinkFactory(
            candidate_id=candidate_id,
            committee_key=committee.committee_key,
            committee_id=committee.committee_id,
        )
        results = self._results(
            api.url_for(CommitteeView, candidate_id=candidate_id, designation='P')
        )
        self.assertEqual(1, len(results))

    def test_candidates_by_com(self):
        committee_id = 'id0'
        candidate = factories.CandidateFactory()
        db.session.flush()
        factories.CandidateCommitteeLinkFactory(
            candidate_id=candidate.candidate_id,
            candidate_key=candidate.candidate_key,
            committee_id=committee_id,
        )
        results = self._results(api.url_for(CandidateView, committee_id=committee_id))
        self.assertEquals(1, len(results))

    def test_candidate_sort(self):
        candidates = [
            factories.CandidateFactory(candidate_status='P'),
            factories.CandidateFactory(candidate_status='C'),
        ]
        candidate_ids = [each.candidate_id for each in candidates]
        results = self._results(api.url_for(CandidateList, sort='candidate_status'))
        self.assertEqual([each['candidate_id'] for each in results], candidate_ids[::-1])
        results = self._results(api.url_for(CandidateList, sort='-candidate_status'))

    def test_candidate_multi_sort(self):
        candidates = [
            factories.CandidateFactory(candidate_status='C', party='DFL'),
            factories.CandidateFactory(candidate_status='P', party='FLP'),
            factories.CandidateFactory(candidate_status='P', party='REF'),
        ]
        candidate_ids = [each.candidate_id for each in candidates]
        results = self._results(api.url_for(CandidateList, sort=['candidate_status', 'party']))
        self.assertEqual([each['candidate_id'] for each in results], candidate_ids)
        results = self._results(api.url_for(CandidateList, sort=['candidate_status', '-party']))
        self.assertEqual(
            [each['candidate_id'] for each in results],
            [candidate_ids[0], candidate_ids[2], candidate_ids[1]],
        )
