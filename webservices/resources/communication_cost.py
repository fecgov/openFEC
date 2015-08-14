from flask.ext.restful import Resource

from webservices import args
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models

@spec.doc(path_params=[utils.committee_param])
class BaseAggregateView(Resource):

    model = None
    match_fields = []
    fields = []

    def get(self, committee_id=None, **kwargs):
        query = self._build_query(committee_id, kwargs)
        return utils.fetch_page(query, kwargs, model=self.model)

    def _build_query(self, committee_id, kwargs):
        query = self.model.query
        if committee_id is not None:
            query = query.filter(self.model.committee_id == committee_id)
        query = utils.filter_match(query, kwargs, self.match_fields)
        query = utils.filter_multi(query, kwargs, self.fields)
        return query


@spec.doc(
    tags=['communicaiton_cost'],
    path_params=[
        utils.candidate_param,
        utils.committee_param,
    ],
    description=(
        'Communication cost by candidate aggregated by candidate ID and committee ID.'
    ),
)
class CommunicationCostByCandidateView(BaseAggregateView):

    model = models.CommunicationCostByCandidate
    fields = [
        ('cycle', models.CommunicationCostByCandidate.cycle),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.communicaion_cost_by_candidate)
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.IndexValidator(models.CommunicationCostByCandidate)
        )
    )
    @schemas.marshal_with(schemas.CommunicationCostByCandidatePageSchema())
    def get(self, committee_id=None, **kwargs):
        return super().get(committee_id=committee_id, **kwargs)