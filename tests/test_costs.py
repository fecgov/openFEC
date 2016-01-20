from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.common.models import CommunicationCost, ElectioneeringCost
from webservices.schemas import CommunicationCostSchema, ElectioneeringCostSchema
from webservices.resources.costs import CommunicationCostView, ElectioneeringCostView


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

class TestElectioneeringCost(ApiBaseTest):

    def test_fields(self):
        factories.ElectioneeringCostFactory()
        results = self._results(api.url_for(ElectioneeringCostView))
        assert len(results) == 1
        assert results[0].keys() == ElectioneeringCostSchema().fields.keys()

    def test_filters(self):
        filters = [
            ('report_year', ElectioneeringCost.report_year, [2012, 2014]),
            ('committee_id', ElectioneeringCost.committee_id, ['C01', 'C02']),
            ('candidate_id', ElectioneeringCost.candidate_id, ['S01', 'S02']),
        ]
        for label, column, values in filters:
            [
                factories.ElectioneeringCostFactory(**{column.key: value})
                for value in values
            ]
            results = self._results(api.url_for(ElectioneeringCostView, **{label: values[0]}))
            assert len(results) == 1
            assert results[0][column.key] == values[0]
