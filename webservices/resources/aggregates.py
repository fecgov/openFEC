from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import counts
from webservices.common import models


@spec.doc(
    tags=['schedules/schedule_a'],
    path_params=[utils.committee_param],
)
class ScheduleAAggregateView(Resource):

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
    tags=['schedules/schedule_a'],
    description=docs.SIZE_DESCRIPTION,
)
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


@spec.doc(
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor state. To avoid double counting, '
        'memoed items are not included.'
    )
)
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

    def _build_query(self, committee_id, kwargs):
        query = super()._build_query(committee_id, kwargs)
        if kwargs['hide_null']:
            query = query.filter(self.model.state_full != None)
        return query


@spec.doc(
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor zip code. To avoid double '
        'counting, memoed items are not included.'
    )
)
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
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor employer name. To avoid double '
        'counting, memoed items are not included.'
    )
)
class ScheduleAByEmployerView(ScheduleAAggregateView):

    model = models.ScheduleAByEmployer
    fields = [
        ('cycle', models.ScheduleAByEmployer.cycle),
        ('employer', models.ScheduleAByEmployer.employer),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.schedule_a_by_employer)
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.IndexValidator(models.ScheduleAByEmployer)
        )
    )
    @schemas.marshal_with(schemas.ScheduleAByEmployerPageSchema())
    def get(self, committee_id=None, **kwargs):
        query = self._build_query(committee_id, kwargs)
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_page(query, kwargs, model=self.model, count=count)


@spec.doc(
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor occupation. To avoid double '
        'counting, memoed items are not included.'
    )
)
class ScheduleAByOccupationView(ScheduleAAggregateView):

    model = models.ScheduleAByOccupation
    fields = [
        ('cycle', models.ScheduleAByOccupation.cycle),
        ('occupation', models.ScheduleAByOccupation.occupation),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.schedule_a_by_occupation)
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.IndexValidator(models.ScheduleAByOccupation)
        )
    )
    @schemas.marshal_with(schemas.ScheduleAByOccupationPageSchema())
    def get(self, committee_id=None, **kwargs):
        query = self._build_query(committee_id, kwargs)
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_page(query, kwargs, model=self.model, count=count)


@spec.doc(
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor FEC ID, if applicable. To avoid '
        'double counting, memoed items are not included.'
    )
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


@spec.doc(
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor type (individual or committee), if applicable. '
        'To avoid double counting, memoed items are not included.'
    )
)
class ScheduleAByContributorTypeView(ScheduleAAggregateView):

    model = models.ScheduleAByContributorType
    match_fields = [
        ('individual', models.ScheduleAByContributorType.individual),
    ]
    fields = [
        ('cycle', models.ScheduleAByContributorType.cycle),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.schedule_a_by_contributor_type)
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.IndexValidator(models.ScheduleAByContributorType)
        )
    )
    @schemas.marshal_with(schemas.ScheduleAByContributorTypePageSchema())
    def get(self, committee_id=None, **kwargs):
        return super(ScheduleAByContributorTypeView, self).get(committee_id=committee_id, **kwargs)


@spec.doc(
    tags=['schedules/schedule_b'],
    description=(
        'Schedule B receipts aggregated by recipient name. To avoid '
        'double counting, memoed items are not included.'
    )
)
class ScheduleBByRecipientView(ScheduleAAggregateView):

    model = models.ScheduleBByRecipient
    fields = [
        ('cycle', models.ScheduleBByRecipient.cycle),
        ('recipient_name', models.ScheduleBByRecipient.recipient_name),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.schedule_b_by_recipient)
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.IndexValidator(models.ScheduleBByRecipient)
        )
    )
    @schemas.marshal_with(schemas.ScheduleBByRecipientPageSchema())
    def get(self, committee_id=None, **kwargs):
        return super().get(committee_id=committee_id, **kwargs)


@spec.doc(
    tags=['schedules/schedule_b'],
    description=(
        'Schedule B receipts aggregated by recipient committee ID, if applicable. To avoid '
        'double counting, memoed items are not included.'
    )
)
class ScheduleBByRecipientIDView(ScheduleAAggregateView):

    model = models.ScheduleBByRecipientID
    fields = [
        ('cycle', models.ScheduleBByRecipientID.cycle),
        ('recipient_id', models.ScheduleBByRecipientID.recipient_id),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.schedule_b_by_recipient_id)
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.IndexValidator(models.ScheduleBByRecipientID)
        )
    )
    @schemas.marshal_with(schemas.ScheduleBByRecipientIDPageSchema())
    def get(self, committee_id=None, **kwargs):
        return super().get(committee_id=committee_id, **kwargs)
