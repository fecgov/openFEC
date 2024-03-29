from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


# used for endpoint: '/rad-analyst/'
# under tag: filer resources
# Ex: http://127.0.0.1:5000/v1/rad-analyst/
@doc(
    tags=['filer resources'],
    description=docs.RAD_ANALYST,
)
class RadAnalystView(ApiResource):

    model = models.RadAnalyst
    schema = schemas.RadAnalystSchema
    page_schema = schemas.RadAnalystPageSchema

    filter_fulltext_fields = [
        ('name', model.name_txt),
        ('title', model.title),
    ]

    filter_multi_fields = [
        ('analyst_id', model.analyst_id),
        ('analyst_short_id', model.analyst_short_id),
        ('email', model.email),
        ('telephone_ext', model.telephone_ext),
        ('committee_id', model.committee_id),
    ]

    filter_range_fields = [
        (('min_assignment_update_date', 'max_assignment_update_date'), model.assignment_update_date),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.rad_analyst,
            args.make_sort_args(),
        )

    @property
    def index_column(self):
        return self.model.idx
