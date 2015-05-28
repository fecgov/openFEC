from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models


totals_schema_map = {
    'P': (models.CommitteeTotalsPresidential, schemas.CommitteeTotalsPresidentialPageSchema),
    'H': (models.CommitteeTotalsHouseSenate, schemas.CommitteeTotalsHouseSenatePageSchema),
    'S': (models.CommitteeTotalsHouseSenate, schemas.CommitteeTotalsHouseSenatePageSchema),
}
default_schemas = (models.CommitteeTotalsPacParty, schemas.CommitteeTotalsPacPartyPageSchema)


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
    @args.register_kwargs(args.make_sort_args(default=['-cycle']))
    def get(self, committee_id, **kwargs):
        # TODO(jmcarp) Handle multiple results better
        committee = models.Committee.query.filter_by(committee_id=committee_id).first_or_404()
        totals_class, totals_schema = totals_schema_map.get(committee.committee_type, default_schemas)
        totals = self.get_totals(committee_id, totals_class, kwargs)
        page = utils.fetch_page(totals, kwargs)
        return totals_schema().dump(page).data

    def get_totals(self, committee_id, totals_class, kwargs):
        totals = totals_class.query.filter_by(committee_id=committee_id)
        if kwargs['cycle']:
            totals = totals.filter(totals_class.cycle.in_(kwargs['cycle']))
        return totals
