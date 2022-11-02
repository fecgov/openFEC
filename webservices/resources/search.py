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
    tags=['search'],
    description=docs.NAME_SEARCH,
)
class CandidateNameSearch(utils.Resource):

    filter_fulltext_fields = [
        ('q', models.CandidateSearch.fulltxt),
    ]

    @use_kwargs(args.names)
    @marshal_with(schemas.CandidateSearchListSchema())
    def get(self, **kwargs):
        query = filters.filter_fulltext(models.CandidateSearch.query, kwargs, self.filter_fulltext_fields)
        query = query.order_by(
            sa.desc(models.CandidateSearch.total_activity)
        ).limit(20)
        return {'results': query.all()}


# search committee full text name
# model class: CommitteeSearch
# use for endpoint:'/names/committees/'
@doc(
    tags=['search'],
    description=docs.NAME_SEARCH,
)
class CommitteeNameSearch(utils.Resource):

    filter_fulltext_fields = [
        ('q', models.CommitteeSearch.fulltxt),
    ]

    @use_kwargs(args.names)
    @marshal_with(schemas.CommitteeSearchListSchema())
    def get(self, **kwargs):
        query = filters.filter_fulltext(models.CommitteeSearch.query, kwargs, self.filter_fulltext_fields)
        query = query.order_by(
            sa.desc(models.CommitteeSearch.total_activity)
        ).limit(20)
        return {'results': query.all()}
