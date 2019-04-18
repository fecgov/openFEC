from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.resources.rad_analyst import RadAnalystView


class TestFilerResources(ApiBaseTest):

    def test_committee_id_fetch(self):
        """ Check Analyst is returned with a specified committee id"""
        committee_id = 'C8675309'
        factories.RadAnalystFactory(committee_id=committee_id)

        results = self._results(api.url_for(RadAnalystView, committee_id=committee_id))
        self.assertEqual(results[0]['committee_id'], committee_id)

    def test_rad(self):
        """ Check RAD returns in general endpoint"""
        factories.RadAnalystFactory(committee_id='C001')
        factories.RadAnalystFactory(committee_id='C002')

        results = self._results(api.url_for(RadAnalystView))
        self.assertEqual(len(results), 2)

    def test_filters(self):
        [
            factories.RadAnalystFactory(telephone_ext=123, committee_id='C0001', title='xyz'),
            factories.RadAnalystFactory(telephone_ext=456, committee_id='C0002', title='abc'),
            factories.RadAnalystFactory(analyst_id=789, committee_id='C0003'),
            factories.RadAnalystFactory(analyst_id=1011, analyst_short_id=11, committee_id='C0004'),
        ]

        filter_fields = (
            ('committee_id', 'C0002'),
            ('telephone_ext', 123),
            ('analyst_id', 789),
            ('analyst_short_id', 11),
            ('title', 'abc'),
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
            factories.RadAnalystFactory(last_name='Young', committee_id='C0005'),
            factories.RadAnalystFactory(last_name='Old', committee_id='C0006'),
            factories.RadAnalystFactory(last_name='Someone-Else', committee_id='C0007'),
        ]
        results = self._results(api.url_for(RadAnalystView, sort='last_name'))
        self.assertEqual(
            [each['last_name'] for each in results],
            ['Old', 'Someone-Else', 'Young']
        )

    def test_assignment_date_filters(self):
        [
            factories.RadAnalystFactory(assignment_update_date='2015-01-01', committee_id='C0007'),
            factories.RadAnalystFactory(assignment_update_date='2015-02-01', committee_id='C0008'),
            factories.RadAnalystFactory(assignment_update_date='2015-03-01', committee_id='C0009'),
            factories.RadAnalystFactory(assignment_update_date='2015-04-01', committee_id='C0010'),
        ]
        results = self._results(
            api.url_for(RadAnalystView, min_assignment_update_date='2015-02-01'))
        self.assertTrue(
            all(each['assignment_update_date'] >= '2015-02-01' for each in results))
        results = self._results(
            api.url_for(RadAnalystView, max_assignment_update_date='2015-02-03'))
        self.assertTrue(
            all(each['assignment_update_date'] <= '2015-02-03' for each in results))
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
