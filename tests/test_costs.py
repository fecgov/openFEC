from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.common.models import CommunicationCost, Electioneering
from webservices.schemas import CommunicationCostSchema, ElectioneeringSchema
from webservices.resources.costs import CommunicationCostView, ElectioneeringView


class TestCommunicationCost(ApiBaseTest):

    def test_fields(self):
        factories.CommunicationCostFactory()
        results = self._results(api.url_for(CommunicationCostView))
        assert len(results) == 1
        assert results[0].keys() == CommunicationCostSchema().fields.keys()

    def test_filters(self):
        filters = [
            ('image_number', CommunicationCost.image_number, ['123', '456']),
            ('committee_id', CommunicationCost.committee_id, ['C01', 'C02']),
            ('candidate_id', CommunicationCost.candidate_id, ['S01', 'S02']),
        ]
        for label, column, values in filters:
            [
                factories.CommunicationCostFactory(**{column.key: value})
                for value in values
            ]
            results = self._results(api.url_for(CommunicationCostView, **{label: values[0]}))
            assert len(results) == 1
            assert results[0][column.key] == values[0]

class TestElectioneering(ApiBaseTest):

    def test_fields(self):
        factories.ElectioneeringFactory()
        results = self._results(api.url_for(ElectioneeringView))
        assert len(results) == 1
        assert results[0].keys() == ElectioneeringSchema().fields.keys()

    def test_filters(self):
        filters = [
            ('report_year', Electioneering.report_year, [2012, 2014]),
            ('committee_id', Electioneering.committee_id, ['C01', 'C02']),
            ('candidate_id', Electioneering.candidate_id, ['S01', 'S02']),
        ]
        for label, column, values in filters:
            [
                factories.ElectioneeringFactory(**{column.key: value})
                for value in values
            ]
            results = self._results(api.url_for(ElectioneeringView, **{label: values[0]}))
            assert len(results) == 1
            assert results[0][column.key] == values[0]

    def test_filter_fulltext(self):
        factories.ElectioneeringFactory()
        factories.ElectioneeringFactory(purpose_description='fitter happier')
        results = self._results(api.url_for(ElectioneeringView, description='happier'))
        assert len(results) == 1
        assert results[0]['purpose_description'] == 'fitter happier'
