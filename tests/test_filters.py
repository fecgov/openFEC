from tests import factories
from tests.common import ApiBaseTest

from webservices import filters
from webservices.common import models


class TestFilter(ApiBaseTest):

    def setUp(self):
        super(TestFilter, self).setUp()
        self.receipts = [
            factories.ScheduleAFactory(entity_type='IND'),
            factories.ScheduleAFactory(entity_type='CCM'),
            factories.ScheduleAFactory(entity_type='COM'),
            factories.ScheduleAFactory(entity_type='PAC'),
        ]

    def test_filter_contributor_type_individual(self):
        query = filters.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.entity_type,
            {'contributor_type': ['individual']},
        )
        self.assertEqual(
            set(query.all()),
            set(each for each in self.receipts if each.entity_type == 'IND')
        )

    def test_filter_contributor_type_committee(self):
        query = filters.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.entity_type,
            {'contributor_type': ['committee']},
        )
        self.assertEqual(
            set(query.all()),
            set(each for each in self.receipts if each.entity_type != 'IND')
        )

    def test_filter_contributor_type_none(self):
        query = filters.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.entity_type,
            {'contributor_type': ['individual', 'committee']},
        )
        self.assertEqual(set(query.all()), set(self.receipts))
