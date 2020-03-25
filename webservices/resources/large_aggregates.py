from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


@doc(
    tags=['financial'],
    description=docs.ENTITY_RECEIPTS_TOTLAS,
)
class EntityReceiptDisbursementTotalsView(ApiResource):

    model = models.EntityReceiptDisbursementTotals
    schema = schemas.EntityReceiptDisbursementTotalsSchema
    page_schema = schemas.EntityReceiptDisbursementTotalsPageSchema

    filter_match_fields = [
        ('cycle', model.cycle),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.large_aggregates,
            args.make_sort_args(
                default='end_date',
                validator=args.OptionValidator(['end_date', ]),
            )
        )

    @property
    def index_column(self):
        return self.model.idx
