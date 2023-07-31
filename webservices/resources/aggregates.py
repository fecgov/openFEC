import sqlalchemy as sa

from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices import exceptions
from webservices.common import models, counts
from webservices.common.views import ApiResource


CANDIDATE_NAME_LABEL = 'candidate_name'
COMMITTEE_NAME_LABEL = 'committee_name'


class AggregateResource(ApiResource):
    query_args = {}

    @property
    def args(self):
        return utils.extend(
            args.paging,
            self.query_args,
            self.sort_args,
        )

    @property
    def sort_args(self):
        return args.make_sort_args(
            validator=args.IndexValidator(self.model)
        )

    @property
    def index_column(self):
        return self.model.idx


class IndividualColumnAggregateResource(AggregateResource):

    def get(self, *args, **kwargs):
        query = self.build_query(*args, **kwargs)
        is_estimate = counts.is_estimated_count(self, query)
        if not is_estimate:
            count = None
        else:
            count, _ = counts.get_count(self, query)
        multi = False
        if isinstance(kwargs['sort'], (list, tuple)):
            multi = True
        return utils.fetch_page(
            query,
            kwargs,
            models.db.session,
            count=count,
            model=self.model,
            join_columns=self.join_columns,
            aliases=self.aliases,
            index_column=self.index_column,
            cap=self.cap,
            multi=multi,
            contains_individual_columns=True
        )


@doc(
    tags=['receipts'],
    description=docs.SCHEDULE_A_BY_EMPLOYER,
)
class ScheduleAByEmployerView(AggregateResource):
    model = models.ScheduleAByEmployer
    schema = schemas.ScheduleAByEmployerSchema
    page_schema = schemas.ScheduleAByEmployerPageSchema
    query_args = args.schedule_a_by_employer
    filter_multi_fields = [
        ('cycle', models.ScheduleAByEmployer.cycle),
        ('committee_id', models.ScheduleAByEmployer.committee_id),
    ]
    filter_fulltext_fields = [
        ('employer', models.ScheduleAByEmployer.employer),
    ]


@doc(
    tags=['receipts'],
    description=docs.SCHEDULE_A_BY_OCCUPATION,
)
class ScheduleAByOccupationView(AggregateResource):

    model = models.ScheduleAByOccupation
    schema = schemas.ScheduleAByOccupationSchema
    page_schema = schemas.ScheduleAByOccupationPageSchema
    query_args = args.schedule_a_by_occupation
    filter_multi_fields = [
        ('cycle', models.ScheduleAByOccupation.cycle),
        ('committee_id', models.ScheduleAByOccupation.committee_id),
    ]
    filter_fulltext_fields = [
        ('occupation', models.ScheduleAByOccupation.occupation),
    ]


@doc(
    tags=['receipts'],
    description=docs.SCHEDULE_A_BY_SIZE,
)
class ScheduleABySizeView(AggregateResource):

    model = models.ScheduleABySize
    schema = schemas.ScheduleABySizeSchema
    page_schema = schemas.ScheduleABySizePageSchema
    query_args = args.schedule_a_by_size
    filter_multi_fields = [
        ('cycle', models.ScheduleABySize.cycle),
        ('size', models.ScheduleABySize.size),
        ('committee_id', models.ScheduleABySize.committee_id),
    ]


@doc(
    tags=['receipts'],
    description=docs.SCHEDULE_A_BY_STATE,
)
class ScheduleAByStateView(AggregateResource):

    model = models.ScheduleAByState
    schema = schemas.ScheduleAByStateSchema
    page_schema = schemas.ScheduleAByStatePageSchema
    query_args = args.schedule_a_by_state
    filter_multi_fields = [
        ('cycle', models.ScheduleAByState.cycle),
        ('state', models.ScheduleAByState.state),
        ('committee_id', models.ScheduleAByState.committee_id),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_a_by_state,
            args.make_sort_args(
                default='-total',
            ),
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        if kwargs['hide_null']:
            query = query.filter(self.model.state_full != None)  # noqa
        return query


@doc(
    tags=['receipts'],
    description=docs.SCHEDULE_A_BY_ZIP,
)
class ScheduleAByZipView(AggregateResource):

    model = models.ScheduleAByZip
    schema = schemas.ScheduleAByZipSchema
    page_schema = schemas.ScheduleAByZipPageSchema
    query_args = args.schedule_a_by_zip
    filter_multi_fields = [
        ('cycle', models.ScheduleAByZip.cycle),
        ('zip', models.ScheduleAByZip.zip),
        ('committee_id', models.ScheduleAByZip.committee_id),
    ]


@doc(
    tags=['disbursements'],
    description=docs.SCHEDULE_B_BY_PURPOSE,
)
class ScheduleBByPurposeView(AggregateResource):

    model = models.ScheduleBByPurpose
    schema = schemas.ScheduleBByPurposeSchema
    page_schema = schemas.ScheduleBByPurposePageSchema
    query_args = args.schedule_b_by_purpose
    filter_multi_fields = [
        ('cycle', models.ScheduleBByPurpose.cycle),
        ('committee_id', models.ScheduleBByPurpose.committee_id),
    ]
    filter_fulltext_fields = [
        ('purpose', models.ScheduleBByPurpose.purpose),
    ]


@doc(
    tags=['disbursements'],
    description=docs.SCHEDULE_B_BY_RECIPIENT,
)
class ScheduleBByRecipientView(AggregateResource):

    model = models.ScheduleBByRecipient
    schema = schemas.ScheduleBByRecipientSchema
    page_schema = schemas.ScheduleBByRecipientPageSchema
    query_args = args.schedule_b_by_recipient
    filter_multi_fields = [
        ('cycle', models.ScheduleBByRecipient.cycle),
        ('committee_id', models.ScheduleBByRecipient.committee_id),
    ]
    filter_fulltext_fields = [
        ('recipient_name', models.ScheduleBByRecipient.recipient_name),
    ]


@doc(
    tags=['disbursements'],
    description=docs.SCHEDULE_B_BY_RECIPIENT_ID,
)
class ScheduleBByRecipientIDView(AggregateResource):

    model = models.ScheduleBByRecipientID
    schema = schemas.ScheduleBByRecipientIDSchema
    page_schema = schemas.ScheduleBByRecipientIDPageSchema
    query_args = args.schedule_b_by_recipient_id
    filter_multi_fields = [
        ('cycle', models.ScheduleBByRecipientID.cycle),
        ('recipient_id', models.ScheduleBByRecipientID.recipient_id),
        ('committee_id', models.ScheduleBByRecipientID.committee_id),
    ]
    query_options = [
        sa.orm.joinedload(models.ScheduleBByRecipientID.committee),
        sa.orm.joinedload(models.ScheduleBByRecipientID.recipient),
    ]


class CandidateAggregateResource(IndividualColumnAggregateResource):

    # Since candidate aggregates are aggregated on the fly, they don't have a
    # consistent unique index. We nullify `index_column` to avoiding sorting
    # on the unique index of the base model.
    index_column = None

    @property
    def sort_args(self):
        return args.make_sort_args(
            validator=args.IndexValidator(
                self.model,
                extra=[CANDIDATE_NAME_LABEL, COMMITTEE_NAME_LABEL, 'candidate_id', 'committee_id'],
            ),
        )

    label_columns = []
    group_columns = []

    def build_query(self, committee_id=None, **kwargs):
        query = super().build_query(committee_id=committee_id, **kwargs)
        election_full = kwargs.get('election_full')
        if election_full and not (kwargs.get('candidate_id') or kwargs.get('office')):
            raise exceptions.ApiError(
                'Must include "candidate_id" or "office" argument(s)',
                status_code=422,
            )
        cycle_column = (
            models.CandidateElection.cand_election_year
            if election_full
            else self.model.cycle
        )
        query = filters.filter_election(query, kwargs, self.model.candidate_id, cycle_column)
        query = query.filter(
            cycle_column.in_(kwargs['cycle'])
            if kwargs.get('cycle')
            else True
        )
        if election_full:
            query = self.aggregate_cycles(query, cycle_column)
        return join_cand_cmte_names(query)

    def aggregate_cycles(self, query, cycle_column):
        election_duration = utils.get_election_duration(sa.func.left(self.model.candidate_id, 1))
        query = query.join(
            models.CandidateElection,
            sa.and_(
                self.model.candidate_id == models.CandidateElection.candidate_id,
                self.model.cycle <= models.CandidateElection.cand_election_year,
                self.model.cycle > (models.CandidateElection.cand_election_year - election_duration),
            ),
        )
        query = query.with_only_columns(
            self.model.candidate_id.label('cand_id'),
            self.model.committee_id.label('cmte_id'),
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
        return query


@doc(
    tags=['independent expenditures'],
    description=docs.SCHEDULE_E_BY_CANDIDATE,
)
class ScheduleEByCandidateView(CandidateAggregateResource):
    model = models.ScheduleEByCandidate
    schema = schemas.ScheduleEByCandidateSchema
    page_schema = schemas.ScheduleEByCandidatePageSchema
    query_args = utils.extend(args.elections, args.schedule_e_by_candidate)
    filter_multi_fields = [
        ('candidate_id', models.ScheduleEByCandidate.candidate_id),
        ('committee_id', models.ScheduleEByCandidate.committee_id),
    ]
    filter_match_fields = [
        ('support_oppose', models.ScheduleEByCandidate.support_oppose_indicator),
    ]

    label_columns = [models.ScheduleEByCandidate.support_oppose_indicator]
    group_columns = [models.ScheduleEByCandidate.support_oppose_indicator]


@doc(
    tags=['communication cost'],
    description=docs.COMMUNICATION_COST_AGGREGATE,
)
class CommunicationCostByCandidateView(CandidateAggregateResource):
    model = models.CommunicationCostByCandidate
    schema = schemas.CommunicationCostByCandidateSchema
    page_schema = schemas.CommunicationCostByCandidatePageSchema
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
    tags=['communication cost'],
    description=docs.COMMUNICATION_COST_AGGREGATE,
)
class CCAggregatesView(IndividualColumnAggregateResource):

    @property
    def sort_args(self):
        return args.make_sort_args(
            validator=args.IndexValidator(
                self.model,
                extra=[CANDIDATE_NAME_LABEL, COMMITTEE_NAME_LABEL],
            ),
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        cycle_column = self.model.cycle

        query = query.filter(
            cycle_column.in_(kwargs['cycle'])
            if kwargs.get('cycle')
            else True
        )
        return join_cand_cmte_names(query)

    model = models.CommunicationCostByCandidate
    schema = schemas.CCAggregatesSchema
    page_schema = schemas.CCAggregatesPageSchema
    query_args = utils.extend(args.CC_aggregates)

    filter_multi_fields = [
        ('candidate_id', model.candidate_id),
        ('committee_id', model.committee_id),
    ]
    filter_match_fields = [
        ('support_oppose_indicator', model.support_oppose_indicator),
    ]


@doc(
    tags=['electioneering'],
    description=docs.ELECTIONEERING_AGGREGATE_BY_CANDIDATE,
)
class ElectioneeringByCandidateView(CandidateAggregateResource):

    model = models.ElectioneeringByCandidate
    schema = schemas.ElectioneeringByCandidateSchema
    page_schema = schemas.ElectioneeringByCandidatePageSchema
    query_args = utils.extend(args.elections, args.electioneering_by_candidate)
    filter_multi_fields = [
        ('candidate_id', models.ElectioneeringByCandidate.candidate_id),
    ]


@doc(
    tags=['electioneering'],
    description=docs.ELECTIONEERING_AGGREGATE,
)
class ECAggregatesView(IndividualColumnAggregateResource):

    @property
    def sort_args(self):
        return args.make_sort_args(
            validator=args.IndexValidator(
                self.model,
                extra=[CANDIDATE_NAME_LABEL, COMMITTEE_NAME_LABEL],
            ),
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        cycle_column = self.model.cycle

        query = query.filter(
            cycle_column.in_(kwargs['cycle'])
            if kwargs.get('cycle')
            else True
        )
        return join_cand_cmte_names(query)

    model = models.ElectioneeringByCandidate
    schema = schemas.ECAggregatesSchema
    page_schema = schemas.ECAggregatesPageSchema
    query_args = utils.extend(args.EC_aggregates)

    filter_multi_fields = [
        ('candidate_id', model.candidate_id),
        ('committee_id', model.committee_id),
    ]


def join_cand_cmte_names(query):
    query = query.subquery()
    return models.db.select(
        query,
        models.CandidateHistory.candidate_id.label('candidate_id'),
        models.CommitteeHistory.committee_id.label('committee_id'),
        models.CandidateHistory.name.label(CANDIDATE_NAME_LABEL),
        models.CommitteeHistory.name.label(COMMITTEE_NAME_LABEL),
    ).outerjoin(
        models.CandidateHistory,
        sa.and_(
            query.c.cand_id == models.CandidateHistory.candidate_id,
            query.c.cycle == models.CandidateHistory.two_year_period,
        ),
    ).outerjoin(
        models.CommitteeHistory,
        sa.and_(
            query.c.cmte_id == models.CommitteeHistory.committee_id,
            query.c.cycle == models.CommitteeHistory.cycle,
        ),
    )
