import sqlalchemy as sa

from flask_apispec import doc, marshal_with
from flask_apispec.utils import Ref

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices import exceptions
from webservices.common import counts
from webservices.common import models
from webservices.utils import use_kwargs
from webservices.common.views import ApiResource
from webservices.resources.candidate_aggregates import get_elections


@doc(params={'committee_id': {'description': docs.COMMITTEE_ID}})
class AggregateResource(ApiResource):

    schema = None
    query_args = {}

    @property
    def sort_args(self):
        return args.make_sort_args(validator=args.IndexValidator(self.model))

    @use_kwargs(args.paging)
    @use_kwargs(Ref('sort_args'))
    @use_kwargs(Ref('query_args'))
    @marshal_with(Ref('schema'))
    def get(self, committee_id=None, **kwargs):
        return super().get(committee_id=committee_id, **kwargs)

    def build_query(self, committee_id, **kwargs):
        query = super().build_query(**kwargs)
        if committee_id is not None:
            query = query.filter(self.model.committee_id == committee_id)
        return query


@doc(
    tags=['schedules/schedule_a'],
    description=docs.SIZE_DESCRIPTION,
)
class ScheduleABySizeView(AggregateResource):

    model = models.ScheduleABySize
    schema = schemas.ScheduleABySizePageSchema
    query_args = args.schedule_a_by_size
    filter_multi_fields = [
        ('cycle', models.ScheduleABySize.cycle),
        ('size', models.ScheduleABySize.size),
    ]


@doc(
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor state. To avoid double counting, '
        'memoed items are not included.'
    )
)
class ScheduleAByStateView(AggregateResource):

    model = models.ScheduleAByState
    schema = schemas.ScheduleAByStatePageSchema
    query_args = args.schedule_a_by_state
    filter_multi_fields = [
        ('cycle', models.ScheduleAByState.cycle),
        ('state', models.ScheduleAByState.state),
    ]

    def build_query(self, committee_id, **kwargs):
        query = super().build_query(committee_id, **kwargs)
        if kwargs['hide_null']:
            query = query.filter(self.model.state_full != None)  # noqa
        return query


@doc(
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor zip code. To avoid double '
        'counting, memoed items are not included.'
    )
)
class ScheduleAByZipView(AggregateResource):

    model = models.ScheduleAByZip
    schema = schemas.ScheduleAByZipPageSchema
    query_args = args.schedule_a_by_zip
    filter_multi_fields = [
        ('cycle', models.ScheduleAByZip.cycle),
        ('zip', models.ScheduleAByZip.zip),
    ]


@doc(
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor employer name. To avoid double '
        'counting, memoed items are not included.'
    )
)
class ScheduleAByEmployerView(AggregateResource):

    model = models.ScheduleAByEmployer
    schema = schemas.ScheduleAByEmployerPageSchema
    query_args = args.schedule_a_by_employer
    filter_multi_fields = [
        ('cycle', models.ScheduleAByEmployer.cycle),
        ('employer', models.ScheduleAByEmployer.employer),
    ]

    def get(self, committee_id=None, **kwargs):
        query = self.build_query(committee_id=committee_id, **kwargs)
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_page(query, kwargs, model=self.model, count=count)


@doc(
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor occupation. To avoid double '
        'counting, memoed items are not included.'
    )
)
class ScheduleAByOccupationView(AggregateResource):

    model = models.ScheduleAByOccupation
    schema = schemas.ScheduleAByOccupationPageSchema
    query_args = args.schedule_a_by_occupation
    filter_multi_fields = [
        ('cycle', models.ScheduleAByOccupation.cycle),
        ('occupation', models.ScheduleAByOccupation.occupation),
    ]

    def get(self, committee_id=None, **kwargs):
        query = self.build_query(committee_id=committee_id, **kwargs)
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_page(query, kwargs, model=self.model, count=count)


@doc(
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor FEC ID, if applicable. To avoid '
        'double counting, memoed items are not included.'
    )
)
class ScheduleAByContributorView(AggregateResource):

    model = models.ScheduleAByContributor
    schema = schemas.ScheduleAByContributorPageSchema
    query_args = args.schedule_a_by_contributor
    filter_multi_fields = [
        ('cycle', models.ScheduleAByContributor.cycle),
        ('contributor_id', models.ScheduleAByContributor.contributor_id),
    ]


@doc(
    tags=['schedules/schedule_b'],
    description=(
        'Schedule B receipts aggregated by recipient name. To avoid '
        'double counting, memoed items are not included.'
    )
)
class ScheduleBByRecipientView(AggregateResource):

    model = models.ScheduleBByRecipient
    schema = schemas.ScheduleBByRecipientPageSchema
    query_args = args.schedule_b_by_recipient
    filter_multi_fields = [
        ('cycle', models.ScheduleBByRecipient.cycle),
        ('recipient_name', models.ScheduleBByRecipient.recipient_name),
    ]


@doc(
    tags=['schedules/schedule_b'],
    description=(
        'Schedule B receipts aggregated by recipient committee ID, if applicable. To avoid '
        'double counting, memoed items are not included.'
    )
)
class ScheduleBByRecipientIDView(AggregateResource):

    model = models.ScheduleBByRecipientID
    schema = schemas.ScheduleBByRecipientIDPageSchema
    query_args = args.schedule_b_by_recipient_id
    filter_multi_fields = [
        ('cycle', models.ScheduleBByRecipientID.cycle),
        ('recipient_id', models.ScheduleBByRecipientID.recipient_id),
    ]


@doc(
    tags=['schedules/schedule_b'],
    description=(
        'Schedule B receipts aggregated by disbursement purpose category. To avoid double '
        'counting, memoed items are not included.'
    )
)
class ScheduleBByPurposeView(AggregateResource):

    model = models.ScheduleBByPurpose
    schema = schemas.ScheduleBByPurposePageSchema
    query_args = args.schedule_b_by_purpose
    filter_multi_fields = [
        ('cycle', models.ScheduleBByPurpose.cycle),
        ('purpose', models.ScheduleBByPurpose.purpose),
    ]


class CandidateAggregateResource(AggregateResource):
    @property
    def sort_args(self):
        return args.make_sort_args(
            validator=args.IndexValidator(
                self.model,
                extra=['candidate', 'committee'],
            ),
        )

    label_columns = []
    group_columns = []

    def build_query(self, committee_id, **kwargs):
        query = super().build_query(committee_id, **kwargs)
        elections = get_elections(kwargs).subquery()
        use_period = kwargs.get('period')
        if use_period and not (kwargs.get('candidate_id') or kwargs.get('office')):
            raise exceptions.ApiError(
                'Must include "candidate_id" or "office" argument(s)',
                status_code=422,
            )
        cycle_column = (
            elections.c.cand_election_year
            if use_period
            else self.model.cycle
        )
        query = filters.filter_election(query, kwargs, self.model.candidate_id, cycle_column)
        query = query.filter(
            cycle_column.in_(kwargs['cycle'])
            if kwargs.get('cycle')
            else True
        )
        if use_period:
            query = self.aggregate_cycles(query, elections, cycle_column)
        return self.join_entity_names(query)

    def aggregate_cycles(self, query, elections, cycle_column):
        election_duration = utils.get_election_duration(sa.func.left(self.model.candidate_id, 1))
        query = query.join(
            elections,
            sa.and_(
                self.model.candidate_id == elections.c.candidate_id,
                self.model.cycle <= elections.c.cand_election_year,
                self.model.cycle > (elections.c.cand_election_year - election_duration),
            ),
        )
        return query.with_entities(
            self.model.candidate_id,
            self.model.committee_id,
            cycle_column.label('cycle'),
            sa.func.sum(self.model.total).label('total'),
            sa.func.sum(self.model.count).label('count'),
            *self.label_columns
        ).group_by(
            self.model.candidate_id,
            self.model.committee_id,
            cycle_column,
            *self.group_columns
        )

    def join_entity_names(self, query):
        query = query.subquery()
        return models.db.session.query(
            query,
            models.CandidateHistory.candidate_id.label('candidate_id'),
            models.CommitteeHistory.committee_id.label('committee_id'),
            models.CandidateHistory.name.label('candidate_name'),
            models.CommitteeHistory.name.label('committee_name'),
        ).join(
            models.CandidateHistory,
            sa.and_(
                query.c.cand_id == models.CandidateHistory.candidate_id,
                query.c.cycle == models.CandidateHistory.two_year_period,
            ),
        ).join(
            models.CommitteeHistory,
            sa.and_(
                query.c.cmte_id == models.CommitteeHistory.committee_id,
                query.c.cycle == models.CommitteeHistory.cycle,
            ),
        )

@doc(
    tags=['schedules/schedule_e'],
    description=(
        'Schedule E receipts aggregated by recipient candidate. To avoid double '
        'counting, memoed items are not included.'
    )
)
class ScheduleEByCandidateView(CandidateAggregateResource):

    model = models.ScheduleEByCandidate
    schema = schemas.ScheduleEByCandidatePageSchema
    query_args = utils.extend(args.elections, args.schedule_e_by_candidate)
    filter_multi_fields = [
        ('candidate_id', models.ScheduleEByCandidate.candidate_id),
    ]
    filter_match_fields = [
        ('support_oppose', models.ScheduleEByCandidate.support_oppose_indicator),
    ]

    label_columns = [models.ScheduleEByCandidate.support_oppose_indicator]
    group_columns = [models.ScheduleEByCandidate.support_oppose_indicator]

@doc(
    tags=['communication_cost'],
    description='Communication cost aggregated by candidate ID and committee ID.',
)
class CommunicationCostByCandidateView(CandidateAggregateResource):

    model = models.CommunicationCostByCandidate
    schema = schemas.CommunicationCostByCandidatePageSchema
    query_args = utils.extend(args.elections, args.communication_cost_by_candidate)
    filter_multi_fields = [
        ('candidate_id', models.CommunicationCostByCandidate.candidate_id),
    ]
    filter_match_fields = [
        ('support_oppose', models.CommunicationCostByCandidate.support_oppose_indicator),
    ]

    label_columns = [models.CommunicationCostByCandidate.support_oppose_indicator]
    group_columns = [models.CommunicationCostByCandidate.support_oppose_indicator]

@doc(
    tags=['electioneering'],
    description='Electioneering costs aggregated by candidate.',
)
class ElectioneeringByCandidateView(CandidateAggregateResource):

    model = models.ElectioneeringByCandidate
    schema = schemas.ElectioneeringByCandidatePageSchema
    query_args = utils.extend(args.elections, args.electioneering_by_candidate)
    filter_multi_fields = [
        ('candidate_id', models.ElectioneeringByCandidate.candidate_id),
    ]
