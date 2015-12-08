import sqlalchemy as sa

from flask_apispec import doc, use_kwargs, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models


def search_typeahead_text(model, text, order_by):
    query = utils.search_text(model.query, model.fulltxt, text)
    query = query.order_by(order_by)
    query = query.limit(20)
    return {'results': query.all()}

@doc(
    tags=['search'],
    description=docs.NAME_SEARCH,
)
class CandidateNameSearch(utils.Resource):

    @use_kwargs(args.names)
    @marshal_with(schemas.CandidateSearchListSchema())
    def get(self, **kwargs):
        return search_typeahead_text(
            models.CandidateSearch,
            kwargs['q'],
            sa.desc(models.CandidateSearch.receipts),
        )


@doc(
    tags=['search'],
    description=docs.NAME_SEARCH,
)
class CommitteeNameSearch(utils.Resource):

    @use_kwargs(args.names)
    @marshal_with(schemas.CommitteeSearchListSchema())
    def get(self, **kwargs):
        return search_typeahead_text(
            models.CommitteeSearch,
            kwargs['q'],
            sa.desc(models.CommitteeSearch.receipts),
        )
