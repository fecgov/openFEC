from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api
from webservices.resources.large_aggregates import EntityReceiptsTotalsView, EntityDisbursementsTotalsView


class TestEntityReceiptsTotals(ApiBaseTest):

    def test_basic_receipts_test(self):
        [
            factories.EntityReceiptsTotalsFactory(cycle=2000, receipts=50000, type='party'),
            factories.EntityReceiptsTotalsFactory(cycle=2020, receipts=90000, type='candidate')
        ]

        filter_fields = (('cycle', int(2020)), ('cycle', int(2000)))

        for field, example in filter_fields:
            page = api.url_for(EntityReceiptsTotalsView, **{field: example})
            # returns one result
            results = self._results(page)
            self.assertEqual(len(results), 1)


class TestEntityDisbursementsTotals(ApiBaseTest):

    def test_basic_disbursements_test(self):
        [
            factories.EntityDisbursementsTotalsFactory(cycle=2000, disbursements=50000, type='party'),
            factories.EntityDisbursementsTotalsFactory(cycle=2020, disbursements=90000, type='candidate')
        ]

        filter_fields = (('cycle', int(2020)), ('cycle', int(2000)))

        for field, example in filter_fields:
            page = api.url_for(EntityDisbursementsTotalsView, **{field: example})
            # returns one result
            results = self._results(page)
            self.assertEqual(len(results), 1)




