import datetime

from .common import ApiBaseTest
from tests import factories
from webservices import rest

## old, re-factored Committee tests ##
class CommitteeFormatTest(ApiBaseTest):
    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_committee_list_fields(self):
        committee = factories.CommitteeFactory(
            original_registration_date=datetime.datetime(1982, 12, 31),
            committee_type='P',
            treasurer_name='Robert J. Lipshutz',
            party='DEM',
        )
        response = self._response('/committees?committee_id={0}'.format(committee.committee_id))
        result = response['results'][0]
        # main fields
        # original registration date doesn't make sense in this example, need to look into this more
        self.assertEqual(result['original_registration_date'], str(committee.original_registration_date))
        self.assertEqual(result['committee_type'], committee.committee_type)
        self.assertEqual(result['treasurer_name'], committee.treasurer_name)
        self.assertEqual(result['party'], committee.party)

    def test_filter_by_candidate_id(self):
        candidate_id = 'id0'
        candidate_committees = [factories.CommitteeFactory(candidate_ids=[candidate_id]) for _ in range(2)]
        other_committees = [factories.CommitteeFactory() for _ in range(3)]  # noqa
        response = self._response('/committees?candidate_id={0}'.format(candidate_id))
        self.assertEqual(
            len(response['results']),
            len(candidate_committees)
        )

    def test_filter_by_candidate_ids(self):
        candidate_ids = ['id0', 'id1']
        candidate1_committees = [factories.CommitteeFactory(candidate_ids=[candidate_ids[0]]) for _ in range(2)]
        candidate2_committees = [factories.CommitteeFactory(candidate_ids=[candidate_ids[1]]) for _ in range(2)]
        other_committees = [factories.CommitteeFactory() for _ in range(3)]  # noqa
        response = self._response('/committees?candidate_id={0}'.format(','.join(candidate_ids)))
        self.assertEqual(
            len(response['results']),
            len(candidate1_committees) + len(candidate2_committees)
        )

    def test_committee_detail_fields(self):
        committee = factories.CommitteeDetailFactory(
            original_registration_date=datetime.datetime(1982, 12, 31),
            committee_type='P',
            treasurer_name='Robert J. Lipshutz',
            party='DEM',
            form_type='F1Z',
            load_date=datetime.datetime(1982, 12, 31),
            street_1='1795 Peachtree Road',
            zip='30309',
        )
        response = self._response('/committee/{0}'.format(committee.committee_id))
        result = response['results'][0]
        # main fields
        self.assertEqual(result['original_registration_date'], str(committee.original_registration_date))
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
        ids = ','.join(each.committee_id for each in committees)
        response = self._response('/committees?committee_id={0}&year=*'.format(ids))
        results = response['results']
        self.assertEqual(len(results), 2)

    # /committees?
    def test_err_on_unsupported_arg(self):
        response = self.app.get('/committees?bogusArg=1')
        self.assertEquals(response.status_code, 400)

    def test_committee_party(self):
        factories.CommitteeFactory(
            party='REP',
            party_full='Republican Party',
        )
        response = self._results('/committees?party=REP')
        self.assertEquals(response[0]['party'], 'REP')
        self.assertEquals(response[0]['party_full'], 'Republican Party')

    def test_committee_filters(self):
        [
            factories.CommitteeFactory(state='CA'),
            factories.CommitteeFactory(name='Obama'),
            factories.CommitteeFactory(committee_type='S'),
            factories.CommitteeFactory(designation='P'),
            factories.CommitteeFactory(party='DEM'),
            factories.CommitteeFactory(organization_type='C'),
            factories.CommitteeFactory(committee_id='bartlet'),
        ]

        # checking one example from each field
        filter_fields = (
            ('committee_id', 'bartlet,ritchie'),
            ('state', 'CA,DC'),
            ('name', 'Obama'),
            ('committee_type', 'S'),
            ('designation', 'P'),
            ('party', 'REP,DEM'),
            ('organization_type', 'C'),
        )

        org_response = self._response('/committees')
        original_count = org_response['pagination']['count']

        for field, example in filter_fields:
            page = "/committees?%s=%s" % (field, example)
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])

    def test_committees_by_cand_id(self):
        candidate_id = 'id0'
        committees = [factories.CommitteeFactory() for _ in range(3)]
        rest.db.session.flush()
        [
            factories.CandidateCommitteeLinkFactory(
                candidate_id=candidate_id,
                committee_id=committee.committee_id,
                committee_key=committee.committee_key,
            )
            for committee in committees
        ]
        results = self._results('/candidate/{0}/committees'.format(candidate_id))

        self.assertEqual(
            set((each['committee_id'] for each in results)),
            set((each.committee_id for each in committees)),
        )

    def test_committee_by_cand_filter(self):
        candidate_id = 'id0'
        committee = factories.CommitteeFactory(designation='P')
        rest.db.session.flush()
        factories.CandidateCommitteeLinkFactory(
            candidate_id=candidate_id,
            committee_key=committee.committee_key,
            committee_id=committee.committee_id,
        )
        results = self._results(
            '/candidate/{0}/committees?designation=P'.format(
                candidate_id,
            )
        )
        self.assertEqual(1, len(results))

    def test_candidates_by_com(self):
        committee_id = 'id0'
        candidate = factories.CandidateFactory()
        rest.db.session.flush()
        factories.CandidateCommitteeLinkFactory(
            candidate_id=candidate.candidate_id,
            candidate_key=candidate.candidate_key,
            committee_id=committee_id,
        )
        results = self._results('/committee/{0}/candidates?year=*'.format(committee_id))
        self.assertEquals(1, len(results))
