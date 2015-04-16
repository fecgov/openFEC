from flask.ext.restful import Resource
from sqlalchemy.orm.exc import NoResultFound

from webservices import args
from webservices import spec
from webservices import paging
from webservices import schemas
from webservices.common import models


totals_schema_map = {
    'P': (models.CommitteeTotalsPresidential, schemas.TotalsPresidentialPageSchema),
    'H': (models.CommitteeTotalsHouseOrSenate, schemas.TotalsHouseSenatePageSchema),
    'S': (models.CommitteeTotalsHouseOrSenate, schemas.TotalsHouseSenatePageSchema),
    None: (models.CommitteeTotalsPacOrParty, schemas.TotalsPacPartyPageSchema),
}

@spec.doc(path_params=[
    {'name': 'id', 'in': 'path', 'type': 'string'},
])
class TotalsView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.totals)
    def get(self, committee_id, **kwargs):
        committee = models.Committee.query.filter_by(committee_id=committee_id).one()
        totals_class, totals_schema = totals_schema_map[committee.committee_type]
        totals = self.get_totals(committee_id, totals_class)
        paginator = paging.SqlalchemyPaginator(totals, kwargs['per_page'])
        return totals_schema().dump(paginator.get_page(kwargs['page'])).data

    def get_totals(self, committee_id, totals_class, kwargs):
        totals = totals_class.query.filter_by(committee_id=committee_id)
        if kwargs['cycle'] != '*':
            totals = totals.filter(
                totals_class.cycle.in_(kwargs['cycle'].split(','))
            )
        return totals.order_by(totals_class.cycle)
