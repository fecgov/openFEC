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
class RADAnalyst(utils.Resource):

    filter_fulltext_fields = [
        ('name', models.RadAnalyst.name),
    ]
    filter_multi_fields = models.RADAnalyst

    @use_kwargs(args.rad_analyst)
    @marshal_with(schemas.RadAnalystPageSchema())
    def get(self, **kwargs):
        query = filters.filter_fulltext(models.RadAnalyst.query, kwargs, self.filter_fulltext_fields)
        query = query.order_by(
            sa.desc(models.RadAnalyst.last_name)
        ).limit(20)
        return {'results': query.all()}
