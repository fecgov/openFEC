from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.resources.auditsearch import AuditSearchView
#from webservices.resources.rad_analyst import RadAnalystView


class TestAuditSearch(ApiBaseTest):

    def test_audit_id_fetch(self):
        """ check if the a specified audit_id exist and returned from db """
        audit_id = 461000
        factories.AuditSearchViewFactory(audit_id=audit_id)

        results = self._results(api.url_for(AuditSearchView, audit_id=audit_id))
        self.assertEqual(results[0]['audit_id'], audit_id)

    def test_rad(self):
        """ Check RAD returns in general endpoint"""
        factories.AuditSearchViewFactory(committee_id='C00241083')
        factories.AuditSearchViewFactory(committee_id='C00135558')

        results = self._results(api.url_for(AuditSearchView))
        self.assertEqual(len(results), 2)

    def test_filters(self):
        [
            factories.AuditSearchViewFactory(committee_description='Pac'),
            factories.AuditSearchViewFactory(finding='Allocation Issues'),
            factories.AuditSearchViewFactory(issue_id=220),
            factories.AuditSearchViewFactory(committee_id='C00241083'),
            factories.AuditSearchViewFactory(candidate_name=None),
            factories.AuditSearchViewFactory(far_release_date='1999-12-16'),  
            factories.AuditSearchViewFactory(finding_id=2),
            factories.AuditSearchViewFactory(audit_case_id=1073),     

            factories.AuditSearchViewFactory(issue=260, audit_id=106),
            factories.AuditSearchViewFactory(election_cycle=1996, audit_id=105, committee_designation='U'),  
            factories.AuditSearchViewFactory(finding_id=2, audit_id=104 ,committee_id='C00241081'),
            factories.AuditSearchViewFactory(link_to_report='http://transition.fec.gov/audits/1996/Unauthorized/RepublicansforChoicePAC1996.pdf', audit_id=103),
            factories.AuditSearchViewFactory(committee_designation='U'),
            factories.AuditSearchViewFactory(audit_id=442),
            factories.AuditSearchViewFactory(committee_name='REPUBLICANS FOR CHOICE'), 
            factories.AuditSearchViewFactory(candidate_id=None),
        ]

        filter_fields = (
            ('committee_description', 'Pac'),     
            ('finding', 'Allocation Issues'), 
            ('committee_id', 'C00241083'), 
            ('issue_id', 220), 
            ('candidate_name', None), 
            ('far_release_date', '1999-12-16'), 
            ('finding_id', 2), 
            ('audit_case_id', 1073), 
            # ('issue', 260), 
            # ('election_cycle', 1996), 
            # ('link_to_report', 'http://transition.fec.gov/audits/1996/Unauthorized/RepublicansforChoicePAC1996.pdf'), 
            # ('committee_designation', 'U'), 
            # ('committee_type', 'Q'), 
            # ('audit_id', 442), 
            # ('committee_name', 'REPUBLICANS FOR CHOICE'), 
            # ('candidate_id', None)
        )

        # checking one example from each field
        orig_response = self._response(api.url_for(AuditSearchView))
        original_count = orig_response['pagination']['count']

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
