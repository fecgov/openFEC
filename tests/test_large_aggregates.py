import datetime

import sqlalchemy as sa

from tests import factories
from tests.common import ApiBaseTest

from webservices.rest import api, db
from webservices.resources.large_aggregates import EntityReceiptDisbursementTotalsView


class TestEntityReceiptDisbursementTotals(ApiBaseTest):
    def test_basic_receipts_test(self):
        [
            factories.EntityReceiptDisbursementTotalsFactory(
                cycle=2000, cumulative_candidate_receipts=50000, month=3, year=1999
            ),
            factories.EntityReceiptDisbursementTotalsFactory(
                cycle=2020, cumulative_party_receipts=90000, month=3, year=2019
            ),
            factories.EntityReceiptDisbursementTotalsFactory(
                cycle=1998, cumulative_pac_disbursements=50000, month=3, year=1997
            ),
            factories.EntityReceiptDisbursementTotalsFactory(
                cycle=2008, cumulative_candidate_disbursements=90000, month=3, year=2008
            ),
        ]

        filter_fields = (
            ('cycle', int(2020)),
            ('cycle', int(2000)),
            ('cycle', int(1998)),
            ('cycle', int(2008)),
        )

        for field, example in filter_fields:
            page = api.url_for(EntityReceiptDisbursementTotalsView, **{field: example})
            # returns one result
            results = self._results(page)
            self.assertEqual(len(results), 1)
