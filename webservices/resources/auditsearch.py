from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


@doc(
    tags=['filer resources'],
    description=docs.FINDING,
)
class AuditFinding(ApiResource):

    model = models.AuditFinding
    schema = schemas.AuditFindingSchema
    page_schema = schemas.AuditFindingPageSchema


    filter_multi_fields = [
        ('finding_id', model.finding_id),
        ('finding', model.finding),
        ('tier', model.tier),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.AuditFinding,
            args.make_sort_args(
                validator=args.IndexValidator(models.AuditFinding),
            ),
        )

    @property
    def index_column(self):
        return self.model.idx
