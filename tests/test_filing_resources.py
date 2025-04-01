from tests import factories
from tests.common import ApiBaseTest

from webservices.api_setup import api
from webservices.resources.rad_analyst import RadAnalystView


class TestFilerResources(ApiBaseTest):
    def test_committee_id_fetch(self):
        """ Check Analyst is returned with a specified committee id"""
        committee_id = 'C86753090'
        factories.RadAnalystFactory(committee_id=committee_id)

        results = self._results(api.url_for(RadAnalystView, committee_id=committee_id))
        self.assertEqual(results[0]['committee_id'], committee_id)

    def test_rad(self):
        """ Check RAD returns in general endpoint"""
        factories.RadAnalystFactory(committee_id='C00000001')
        factories.RadAnalystFactory(committee_id='C00000002')

        results = self._results(api.url_for(RadAnalystView))
        self.assertEqual(len(results), 2)

    def test_filters(self):
        [
            factories.RadAnalystFactory(
                telephone_ext=123, committee_id='C0000001', title='xyz 111'
            ),
            factories.RadAnalystFactory(
                telephone_ext=456,
                committee_id='C00000002',
                title='abc',
                email='test2@fec.gov',
            ),
            factories.RadAnalystFactory(
                analyst_id=789, committee_id='C00000003', email='test1@fec.gov'
            ),
            factories.RadAnalystFactory(
                analyst_id=1011, analyst_short_id=11, committee_id='C00000004'
            ),
        ]

        filter_fields = (
            ('committee_id', 'C00000002'),
            ('telephone_ext', 123),
            ('analyst_id', 789),
            ('analyst_short_id', 11),
            ('title', 'xyz 111'),
            ('email', ['test1@fec.gov', 'test2@fec.gov']),
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(RadAnalystView))
        original_count = orig_response['pagination']['count']

        for field, example in filter_fields:
            page = api.url_for(RadAnalystView, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])

    def test_sort(self):
        [
            factories.RadAnalystFactory(last_name='Young', committee_id='C00000005'),
            factories.RadAnalystFactory(last_name='Old', committee_id='C00000006'),
            factories.RadAnalystFactory(last_name='Someone-Else', committee_id='C00000007'),
        ]
        results = self._results(api.url_for(RadAnalystView, sort='last_name'))
        self.assertEqual(
            [each['last_name'] for each in results], ['Old', 'Someone-Else', 'Young']
        )

    def test_assignment_date_filters(self):
        [
            factories.RadAnalystFactory(
                assignment_update_date='2015-01-01', committee_id='C00000007'
            ),
            factories.RadAnalystFactory(
                assignment_update_date='2015-02-01', committee_id='C00000008'
            ),
            factories.RadAnalystFactory(
                assignment_update_date='2015-03-01', committee_id='C00000009'
            ),
            factories.RadAnalystFactory(
                assignment_update_date='2015-04-01', committee_id='C00000010'
            ),
        ]
        results = self._results(
            api.url_for(RadAnalystView, min_assignment_update_date='2015-02-01')
        )
        self.assertTrue(
            all(each['assignment_update_date'] >= '2015-02-01' for each in results)
        )
        results = self._results(
            api.url_for(RadAnalystView, max_assignment_update_date='2015-02-03')
        )
        self.assertTrue(
            all(each['assignment_update_date'] <= '2015-02-03' for each in results)
        )
        results = self._results(
            api.url_for(
                RadAnalystView,
                min_assignment_update_date='2015-02-01',
                max_assignment_update_date='2015-03-01',
            )
        )
        self.assertTrue(
            all(
                '2015-02-01' <= each['assignment_update_date'] <= '2015-03-01'
                for each in results
            )
        )
