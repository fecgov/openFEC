import sqlalchemy as sa

from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.common import models
from webservices.utils import use_kwargs


@doc(
    tags=['filer_resources'],
    description=docs.FILER_RESOURCES,
)
class RadAnalystView(utils.Resource):

    model = models.RadAnalyst

    filter_fulltext_fields = [
        ('name', model.name_txt),
    ]
    filter_multi_fields = [
        ('last_name', model.last_name),
        ('first_name', model.first_name),
        ('anlyst_id', model.analyst_id),
        ('rad_branch', model.rad_branch),
        ('telephone_ext', model.telephone_ext),
        ('committee_id', model.committee_id),
        ('committe_name', model.committee_name),
    ]

    @use_kwargs(args.rad_analyst)
    @use_kwargs(args.make_sort_args(default='-last_name'))
    @marshal_with(schemas.RadAnalystPageSchema)
    def get(self, **kwargs):
        query = filters.filter_fulltext(models.RadAnalyst.query, kwargs, self.filter_fulltext_fields)
        query = query.order_by(
            sa.desc(models.RadAnalyst.last_name)
        ).limit(20)
        return {'results': query.all()}
