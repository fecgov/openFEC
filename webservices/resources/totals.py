import sqlalchemy as sa
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
    'I': (models.CommitteeTotalsIEOnly, schemas.
        CommitteeTotalsIEOnlyPageSchema)
}
default_schemas = (models.CommitteeTotalsPacParty, schemas.CommitteeTotalsPacPartyPageSchema)


@spec.doc(
    tags=['financial'],
    description=docs.TOTALS,
    path_params=[utils.committee_param],
)
class TotalsView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.totals)
    @args.register_kwargs(args.make_sort_args(default=['-cycle']))
    @schemas.marshal_with(schemas.CommitteeTotalsPageSchema(), wrap=False)
    def get(self, committee_id, **kwargs):
        totals_class, totals_schema = totals_schema_map.get(
            self._resolve_committee_type(committee_id, kwargs),
            default_schemas,
        )
        validator = args.IndexValidator(totals_class)
        for key in kwargs['sort']:
            validator(key)
        totals = self.get_totals(committee_id, totals_class, kwargs)
        page = utils.fetch_page(totals, kwargs)
        return totals_schema().dump(page).data

    def get_totals(self, committee_id, totals_class, kwargs):
        totals = totals_class.query.filter_by(committee_id=committee_id)
        if kwargs['cycle']:
            totals = totals.filter(totals_class.cycle.in_(kwargs['cycle']))
        return totals

    def _resolve_committee_type(self, committee_id, kwargs):
        query = models.CommitteeHistory.query.filter_by(committee_id=committee_id)
        if kwargs['cycle']:
            query = query.filter(models.CommitteeHistory.cycle.in_(kwargs['cycle']))
        query = query.order_by(sa.desc(models.CommitteeHistory.cycle))
        committee = query.first_or_404()
        return committee.committee_type
