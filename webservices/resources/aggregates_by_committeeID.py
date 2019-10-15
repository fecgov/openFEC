"""
    This file include 9 endpoints which will be DEPRECATED soon.
"""
import sqlalchemy as sa

from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices import exceptions
from webservices.common import counts
from webservices.common import models
from webservices.common.views import ApiResource

@doc(params={'committee_id': {'description': docs.COMMITTEE_ID}})
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

    def build_query(self, committee_id=None, **kwargs):
        query = super().build_query(**kwargs)
        if committee_id is not None:
            query = query.filter(self.model.committee_id == committee_id)
        return query


@doc(
    tags=['receipts'],
    description=docs.SCHEDULE_A_BY_SIZE_COMMITTEE_ID,
)
class ScheduleABySizeByCommitteeIDView(AggregateResource):

    model = models.ScheduleABySize
    schema = schemas.ScheduleABySizeSchema
    page_schema = schemas.ScheduleABySizePageSchema
    query_args = args.schedule_a_by_size_committee_id
    filter_multi_fields = [
        ('cycle', models.ScheduleABySize.cycle),
        ('size', models.ScheduleABySize.size),
    ]


@doc(
    tags=['receipts'],
    description=(
        'Schedule A individual receipts aggregated by contributor state.'
        'This is an aggregate of only individual contributions. To avoid double counting,memoed items are not included.'
        'Transactions $200 and under do not have to beitemized, if those contributions are not itemized,'
        'they will not be included in thestate totals.'
    )
)
class ScheduleAByStateByCommitteeIDView(AggregateResource):

    model = models.ScheduleAByState
    schema = schemas.ScheduleAByStateSchema
    page_schema = schemas.ScheduleAByStatePageSchema
    query_args = args.schedule_a_by_state_committee_id
    filter_multi_fields = [
        ('cycle', models.ScheduleAByState.cycle),
        ('state', models.ScheduleAByState.state),
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

    def build_query(self, committee_id=None, **kwargs):
        query = super().build_query(committee_id, **kwargs)
        if kwargs['hide_null']:
            query = query.filter(self.model.state_full != None)  # noqa
        return query

@doc(
    tags=['receipts'],
    description=(
        'Schedule A receipts aggregated by contributor zip code.'
        'To avoid double counting, memoed items are not included.'
    )
)
class ScheduleAByZipByCommitteeIDView(AggregateResource):

    model = models.ScheduleAByZip
    schema = schemas.ScheduleAByZipSchema
    page_schema = schemas.ScheduleAByZipPageSchema
    query_args = args.schedule_a_by_zip_committee_id
    filter_multi_fields = [
        ('cycle', models.ScheduleAByZip.cycle),
        ('zip', models.ScheduleAByZip.zip),
    ]


@doc(
    tags=['receipts'],
    description=(
        'Schedule A receipts aggregated by contributor zip code.'
        'To avoid double counting, memoed items are not included.'
    )
)
class ScheduleAByEmployerByCommitteeIDView(AggregateResource):

    model = models.ScheduleAByEmployer
    schema = schemas.ScheduleAByEmployerSchema
    page_schema = schemas.ScheduleAByEmployerPageSchema
    query_args = args.schedule_a_by_employer_committee_id
    filter_multi_fields = [
        ('cycle', models.ScheduleAByEmployer.cycle),
    ]
    filter_fulltext_fields = [
        ('employer', models.ScheduleAByEmployer.employer),
    ]

    def get(self, committee_id=None, **kwargs):
        query = self.build_query(committee_id=committee_id, **kwargs)
        count = counts.count_estimate(query, models.db.session)
        return utils.fetch_page(query, kwargs, model=self.model, count=count, index_column=self.index_column)


@doc(
    tags=['receipts'],
    description=(
        'Schedule A receipts aggregated by contributor occupation.'
        'To avoid double counting, memoed items are not included.'
    )
)
class ScheduleAByOccupationByCommitteeIDView(AggregateResource):

    model = models.ScheduleAByOccupation
    schema = schemas.ScheduleAByOccupationSchema
    page_schema = schemas.ScheduleAByOccupationPageSchema
    query_args = args.schedule_a_by_occupation_committee_id
    filter_multi_fields = [
        ('cycle', models.ScheduleAByOccupation.cycle),
    ]
    filter_fulltext_fields = [
        ('occupation', models.ScheduleAByOccupation.occupation),
    ]

    def get(self, committee_id=None, **kwargs):
        query = self.build_query(committee_id=committee_id, **kwargs)
        count = counts.count_estimate(query, models.db.session)
        return utils.fetch_page(query, kwargs, model=self.model, count=count, index_column=self.index_column)


@doc(
    tags=['disbursements'],
    description=(
        'Schedule B disbursements aggregated by disbursement purpose category.'
        'To avoid double counting, memoed items are not included.Purpose is a combination of transaction codes,'
        'category codes and disbursement description.'
        'See the `disbursement_purpose` sql function within the migrations for more details.'
    )
)
class ScheduleBByPurposeByCommitteeIDView(AggregateResource):

    model = models.ScheduleBByPurpose
    schema = schemas.ScheduleBByPurposeSchema
    page_schema = schemas.ScheduleBByPurposePageSchema
    query_args = args.schedule_b_by_purpose_committee_id
    filter_multi_fields = [
        ('cycle', models.ScheduleBByPurpose.cycle),
    ]
    filter_fulltext_fields = [
        ('purpose', models.ScheduleBByPurpose.purpose),
    ]

@doc(
    tags=['disbursements'],
    description=(
        'Schedule B disbursements aggregated by recipient name.'
        'To avoid double counting, memoed items are not included.'
    )
)
class ScheduleBByRecipientByCommitteeIDView(AggregateResource):

    model = models.ScheduleBByRecipient
    schema = schemas.ScheduleBByRecipientSchema
    page_schema = schemas.ScheduleBByRecipientPageSchema
    query_args = args.schedule_b_by_recipient_committee_id
    filter_multi_fields = [
        ('cycle', models.ScheduleBByRecipient.cycle),
    ]
    filter_fulltext_fields = [
        ('recipient_name', models.ScheduleBByRecipient.recipient_name),
    ]


@doc(
    tags=['disbursements'],
    description=(
        'Schedule B disbursements aggregated by recipient committee ID, if applicable.'
        'To avoid double counting, memoed items are not included.'
    )
)
class ScheduleBByRecipientIDByCommitteeIDView(AggregateResource):

    model = models.ScheduleBByRecipientID
    schema = schemas.ScheduleBByRecipientIDSchema
    page_schema = schemas.ScheduleBByRecipientIDPageSchema
    query_args = args.schedule_b_by_recipient_id_committee_id
    filter_multi_fields = [
        ('cycle', models.ScheduleBByRecipientID.cycle),
        ('recipient_id', models.ScheduleBByRecipientID.recipient_id),
    ]
    query_options = [
        sa.orm.joinedload(models.ScheduleBByRecipientID.committee),
        sa.orm.joinedload(models.ScheduleBByRecipientID.recipient),
    ]


class CandidateAggregateResource(AggregateResource):

    # Since candidate aggregates are aggregated on the fly, they don't have a
    # consistent unique index. We nullify `index_column` to avoiding sorting
    # on the unique index of the base model.
    index_column = None

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
        return self.join_entity_names(query)

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

@doc(
    tags=['independent expenditures'],
    description=(
        'Schedule E receipts aggregated by recipient candidate. To avoid double '
        'counting, memoed items are not included.'
    )
)
class ScheduleEByCandidateByCommitteeIDView(CandidateAggregateResource):

    model = models.ScheduleEByCandidate
    schema = schemas.ScheduleEByCandidateSchema
    page_schema = schemas.ScheduleEByCandidatePageSchema
    query_args = utils.extend(args.elections, args.schedule_e_by_candidate_committee_id)
    filter_multi_fields = [
        ('candidate_id', models.ScheduleEByCandidate.candidate_id),
    ]
    filter_match_fields = [
        ('support_oppose', models.ScheduleEByCandidate.support_oppose_indicator),
    ]

    label_columns = [models.ScheduleEByCandidate.support_oppose_indicator]
    group_columns = [models.ScheduleEByCandidate.support_oppose_indicator]
