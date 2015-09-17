import sqlalchemy as sa

from flask_smore import doc, use_kwargs, marshal_with
from flask_smore.utils import Ref

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.common import counts
from webservices.common import models
from webservices.common.views import ApiResource


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
    tags=['schedules/schedule_a'],
    description=(
        'Schedule A receipts aggregated by contributor type (individual or committee), if applicable. '
        'To avoid double counting, memoed items are not included.'
    )
)
class ScheduleAByContributorTypeView(AggregateResource):

    model = models.ScheduleAByContributorType
    schema = schemas.ScheduleAByContributorTypePageSchema
    query_args = args.schedule_a_by_contributor_type
    filter_match_fields = [
        ('individual', models.ScheduleAByContributorType.individual),
    ]
    filter_multi_fields = [
        ('cycle', models.ScheduleAByContributorType.cycle),
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

    @property
    def query_options(self):
        return [
            sa.orm.joinedload(self.model.candidate),
            sa.orm.joinedload(self.model.committee),
        ]

    @property
    def join_columns(self):
        return {
            'committee': (models.CommitteeDetail.name, self.model.committee),
            'candidate': (models.CandidateDetail.name, self.model.candidate),
        }


@doc(
    tags=['schedules/schedule_b'],
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
        ('cycle', models.ScheduleEByCandidate.cycle),
        ('candidate_id', models.ScheduleEByCandidate.candidate_id),
    ]
    filter_match_fields = [
        ('support_oppose', models.ScheduleEByCandidate.support_oppose_indicator),
    ]

    def build_query(self, committee_id, **kwargs):
        query = super().build_query(committee_id, **kwargs)
        return filters.filter_election(query, kwargs, self.model.candidate_id, self.model.cycle)


@doc(
    tags=['communication_cost'],
    description='Communication cost aggregated by candidate ID and committee ID.',
)
class CommunicationCostByCandidateView(CandidateAggregateResource):

    model = models.CommunicationCostByCandidate
    schema = schemas.CommunicationCostByCandidatePageSchema
    query_args = utils.extend(args.elections, args.communication_cost_by_candidate)
    filter_multi_fields = [
        ('cycle', models.CommunicationCostByCandidate.cycle),
        ('candidate_id', models.CommunicationCostByCandidate.candidate_id),
    ]
    filter_match_fields = [
        ('support_oppose', models.CommunicationCostByCandidate.support_oppose_indicator),
    ]

    def build_query(self, committee_id, **kwargs):
        query = super().build_query(committee_id, **kwargs)
        return filters.filter_election(query, kwargs, self.model.candidate_id, self.model.cycle)


@doc(
    tags=['electioneering'],
    description='Electioneering costs aggregated by candidate.',
)
class ElectioneeringByCandidateView(CandidateAggregateResource):

    model = models.ElectioneeringByCandidate
    schema = schemas.ElectioneeringByCandidatePageSchema
    query_args = utils.extend(args.elections, args.electioneering_by_candidate)
    filter_multi_fields = [
        ('cycle', models.ElectioneeringByCandidate.cycle),
        ('candidate_id', models.ElectioneeringByCandidate.candidate_id),
    ]

    def build_query(self, committee_id, **kwargs):
        query = super().build_query(committee_id, **kwargs)
        return filters.filter_election(query, kwargs, self.model.candidate_id, self.model.cycle)
