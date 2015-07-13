from flask.ext.restful import Resource

from webservices import args
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models


@spec.doc(
    tags=['schedules'],
    path_params=[utils.committee_param],
)
class ScheduleAAggregateView(Resource):

    model = None
    fields = {}

    def get(self, committee_id=None, **kwargs):
        query = self._build_query(committee_id, kwargs)
        return utils.fetch_page(query, kwargs, model=self.model)

    def _build_query(self, committee_id, kwargs):
        query = self.model.query
        if committee_id is not None:
            query = query.filter(self.model.committee_id == committee_id)
        query = utils.filter_multi(query, kwargs, self.fields)
        return query


@spec.doc(description='Schedule A receipts aggregated by contribution size')
class ScheduleABySizeView(ScheduleAAggregateView):

    model = models.ScheduleABySize
    fields = [
        ('cycle', models.ScheduleABySize.cycle),
        ('size', models.ScheduleABySize.size),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.schedule_a_by_size)
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.IndexValidator(models.ScheduleABySize)
        )
    )
    @schemas.marshal_with(schemas.ScheduleABySizePageSchema())
    def get(self, committee_id=None, **kwargs):
        return super(ScheduleABySizeView, self).get(committee_id=committee_id, **kwargs)


@spec.doc(description='Schedule A receipts aggregated by contributor state')
class ScheduleAByStateView(ScheduleAAggregateView):

    model = models.ScheduleAByState
    fields = [
        ('cycle', models.ScheduleAByState.cycle),
        ('state', models.ScheduleAByState.state),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.schedule_a_by_state)
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.IndexValidator(models.ScheduleAByState)
        )
    )
    @schemas.marshal_with(schemas.ScheduleAByStatePageSchema())
    def get(self, committee_id=None, **kwargs):
        return super(ScheduleAByStateView, self).get(committee_id=committee_id, **kwargs)


@spec.doc(description='Schedule A receipts aggregated by contributor zip code')
class ScheduleAByZipView(ScheduleAAggregateView):

    model = models.ScheduleAByZip
    fields = [
        ('cycle', models.ScheduleAByZip.cycle),
        ('zip', models.ScheduleAByZip.zip),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.schedule_a_by_zip)
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.IndexValidator(models.ScheduleAByZip)
        )
    )
    @schemas.marshal_with(schemas.ScheduleAByZipPageSchema())
    def get(self, committee_id=None, **kwargs):
        return super(ScheduleAByZipView, self).get(committee_id=committee_id, **kwargs)


@spec.doc(
    description='Schedule A receipts aggregated by contributor ID',
)
class ScheduleAByContributorView(ScheduleAAggregateView):

    model = models.ScheduleAByContributor
    fields = [
        ('cycle', models.ScheduleAByContributor.cycle),
        ('contributor_id', models.ScheduleAByContributor.contributor_id),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.schedule_a_by_contributor)
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.IndexValidator(models.ScheduleAByContributor)
        )
    )
    @schemas.marshal_with(schemas.ScheduleAByContributorPageSchema())
    def get(self, committee_id=None, **kwargs):
        return super(ScheduleAByContributorView, self).get(committee_id=committee_id, **kwargs)
