from flask.ext.restful import Resource

import sqlalchemy as sa

from webservices import args
from webservices import docs
from webservices import spec
from webservices import paging
from webservices import schemas
from webservices.common import models


totals_schema_map = {
    'P': (models.CommitteeTotalsPresidential, schemas.TotalsPresidentialPageSchema),
    'H': (models.CommitteeTotalsHouseOrSenate, schemas.TotalsHouseSenatePageSchema),
    'S': (models.CommitteeTotalsHouseOrSenate, schemas.TotalsHouseSenatePageSchema),
}
default_schemas = (models.CommitteeTotalsPacOrParty, schemas.TotalsPacPartyPageSchema)


@spec.doc(
    tags=['financial'],
    description=docs.TOTALS,
    path_params=[
        {'name': 'id', 'in': 'path', 'type': 'string'},
    ],
)
class TotalsView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.totals)
    def get(self, committee_id, **kwargs):
        # TODO(jmcarp) Handle multiple results better
        committee = models.Committee.query.filter_by(committee_id=committee_id).first_or_404()
        totals_class, totals_schema = totals_schema_map.get(committee.committee_type, default_schemas)
        totals = self.get_totals(committee_id, totals_class, kwargs)
        paginator = paging.SqlalchemyPaginator(totals, kwargs['per_page'])
        return totals_schema().dump(paginator.get_page(kwargs['page'])).data

    def get_totals(self, committee_id, totals_class, kwargs):
        totals = totals_class.query.filter_by(committee_id=committee_id)
        if kwargs['cycle']:
            totals = totals.filter(totals_class.cycle.in_(kwargs['cycle']))
        return totals.order_by(sa.desc(totals_class.cycle))
