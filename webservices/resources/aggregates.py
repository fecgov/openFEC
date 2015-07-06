from flask.ext.restful import Resource

from webservices import args
from webservices import utils
from webservices import schemas
from webservices.common import models


class ScheduleAAggregateView(Resource):

    model = None
    fields = {}

    def get(self, committee_id=None, **kwargs):
        query = self._build_query(committee_id, kwargs)
        return utils.fetch_page(query, kwargs)

    def _build_query(self, committee_id, kwargs):
        query = self.model.query
        if committee_id is not None:
            query = query.filter(self.model.committee_id == committee_id)
        query = utils.filter_multi(query, kwargs, self.fields)
        return query


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
