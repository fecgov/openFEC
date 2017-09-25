from tests import factories
from tests.common import ApiBaseTest

from webservices.resources.auditsearch import AuditSearchView
from webservices.rest import api


class TestAuditSearch(ApiBaseTest):

    def test_audit_id_fetch(self):
        """ check if the specified audit_id exist """
        audit_id = 565
        factories.AuditSearchViewFactory(audit_id=audit_id)

        results = self._results(api.url_for(AuditSearchView, audit_id=audit_id))
        self.assertEqual(results[0]['audit_id'], audit_id)

    def test_rad(self):
        """ Check Audit Search returns general endpoint"""
        factories.AuditSearchViewFactory(committee_id='C00241083')
        factories.AuditSearchViewFactory(committee_id='C00135558')

        results = self._results(api.url_for(AuditSearchView))
        self.assertEqual(len(results), 2)

    def test_filters(self):
        [
            factories.AuditSearchViewFactory(category_id=3),
            factories.AuditSearchViewFactory(category='Disclosure'),
            factories.AuditSearchViewFactory(subcategory_id=220),
            factories.AuditSearchViewFactory(subcategory='Coordinated Expenditures'),
            factories.AuditSearchViewFactory(election_cycle=2002),
            factories.AuditSearchViewFactory(committee_id='C00161786'),
            # factories.AuditSearchViewFactory(committee_name='COLORADO DEMOCRATIC PARTY'),
            factories.AuditSearchViewFactory(committee_designation='U'),
            factories.AuditSearchViewFactory(committee_type='Y'),
            factories.AuditSearchViewFactory(committee_description='Party'),
            factories.AuditSearchViewFactory(candidate_id=''),
            # factories.AuditSearchViewFactory(candidate_name=''),

        ]

        filter_fields = (
            ('category_id', 3),
            ('category', 'Disclosure'),
            ('subcategory_id', 220),
            ('subcategory', 'Coordinated Expenditures'),
            ('election_cycle', 2002),
            ('committee_id', 'C00161786'),
            # ('committee_name', 'COLORADO DEMOCRATIC PARTY'),
            ('committee_designation', 'U'),
            ('committee_type', 'Y'),
            ('committee_description', 'Party'),
            ('candidate_id', ''),
            # ('candidate_name', ''),

        )
        # filter_range_fields = [
            # ('election_cycle', AuditSearchView.election_cycle, [2010, 2014]),
        # ]

        # checking one example from each field
        orig_response = self._response(api.url_for(AuditSearchView))
        original_count = orig_response['pagination']['count']
        print('Original Count :::', original_count)

        for field, example in filter_fields:
            page = api.url_for(AuditSearchView, **{field: example})
            # returns at least one result
            results = self._results(page)
            self.assertGreater(len(results), 0)
            # doesn't return all results
            response = self._response(page)
            self.assertGreater(original_count, response['pagination']['count'])



    def test_sort(self):
        [
            factories.AuditSearchViewFactory(candidate_name='Young', committee_id='C00241083'),
            factories.AuditSearchViewFactory(candidate_name='Old', committee_id='C00135558'),
        ]
        results = self._results(api.url_for(AuditSearchView, sort='committee_id'))
        self.assertTrue(
            [each['committee_id'] for each in results],
            ['C00241083', 'C00135558']
        )

    def test_sort_bad_column(self):
        response = self.app.get(api.url_for(AuditSearchView, sort='request_type'))
        self.assertEqual(response.status_code, 422)
