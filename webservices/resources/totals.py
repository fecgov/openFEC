import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource
from webservices.utils import use_kwargs

committee_type_map = {
    'house-senate': 'H',
    'presidential': 'P',
    'ie-only': 'I',
    'pac-party': None,
    'pac': 'O',
    'party': 'X'
}

totals_schema_map = {
    'P': (models.CommitteeTotalsPerCycle, schemas.CommitteeTotalsPerCyclePageSchema),
    'H': (models.CommitteeTotalsHouseSenate, schemas.CommitteeTotalsHouseSenatePageSchema),
    'S': (models.CommitteeTotalsHouseSenate, schemas.CommitteeTotalsHouseSenatePageSchema),
    'I': (models.CommitteeTotalsIEOnly, schemas.CommitteeTotalsIEOnlyPageSchema),
}
default_schemas = (models.CommitteeTotalsPacParty, schemas.CommitteeTotalsPacPartyPageSchema)

candidate_totals_schema_map = {
    'P': (models.CandidateCommitteeTotalsPresidential, schemas.CandidateCommitteeTotalsPresidentialPageSchema),
    'H': (models.CandidateCommitteeTotalsHouseSenate, schemas.CandidateCommitteeTotalsHouseSenatePageSchema),
    'S': (models.CandidateCommitteeTotalsHouseSenate, schemas.CandidateCommitteeTotalsHouseSenatePageSchema),
}
pac_cmte_list = {'N', 'O', 'Q', 'V', 'W'}

party_cmte_list = {'X', 'Y'}

default_candidate_schemas = (models.CandidateCommitteeTotalsHouseSenate, schemas.CandidateCommitteeTotalsHouseSenatePageSchema)

@doc(
    tags=['financial'],
    description=docs.TOTALS,
    params={
        'committee_type': {
            'description': 'House, Senate, presidential, independent expenditure only',
            'enum': ['presidential', 'pac', 'party', 'pac-party', 'house-senate', 'ie-only'],
        },
    },
)
class TotalsView(utils.Resource):

    @use_kwargs(args.paging)
    @use_kwargs(args.totals_all)
    @use_kwargs(args.make_sort_args(default='-cycle'))
    @marshal_with(schemas.CommitteeTotalsPageSchema(), apply=False)
    def get(self, committee_id=None, committee_type=None, **kwargs):
        query, totals_class, totals_schema = self.build_query(
            committee_id=committee_id,
            committee_type=committee_type,
            **kwargs
        )
        page = utils.fetch_page(query, kwargs, model=totals_class)
        return totals_schema().dump(page).data

    def build_query(self, committee_id=None, committee_type=None, **kwargs):
        totals_class, totals_schema = totals_schema_map.get(
            self._resolve_committee_type(
                committee_id=committee_id,
                committee_type=committee_type,
                **kwargs
            ),
            default_schemas,
        )
        query = totals_class.query
        if committee_id is not None:
            query = query.filter(totals_class.committee_id == committee_id)
        if kwargs.get('cycle'):
            query = query.filter(totals_class.cycle.in_(kwargs['cycle']))
        if committee_type == 'pac':
            query = query.filter(
                models.CommitteeTotalsPacParty.committee_type.in_(pac_cmte_list)
            )
        if committee_type == 'party':
            query = query.filter(
                models.CommitteeTotalsPacParty.committee_type.in_(party_cmte_list)
            )
        if committee_type == 'pac-party':
            query = query.filter(
                models.CommitteeTotalsPacParty.committee_type.in_(pac_cmte_list.union(party_cmte_list))
            )
        return query, totals_class, totals_schema

    def _resolve_committee_type(self, committee_id=None, committee_type=None, **kwargs):
        if committee_id is not None:
            query = models.CommitteeHistory.query.filter_by(committee_id=committee_id)
            if kwargs.get('cycle'):
                query = query.filter(models.CommitteeHistory.cycle.in_(kwargs['cycle']))
            query = query.order_by(sa.desc(models.CommitteeHistory.cycle))
            committee = query.first_or_404()
            return committee.committee_type
        elif committee_type is not None:
            return committee_type_map.get(committee_type)

@doc(
    tags=['financial'],
    description=docs.TOTALS,
    params={
        'committee_id': {'description': docs.COMMITTEE_ID},
        'committee_type': {
            'description': 'House, Senate, presidential, independent expenditure only',
            'enum': ['presidential', 'pac-party', 'pac', 'party', 'house-senate', 'ie-only'],
        },
    },
)
class TotalsCommitteeView(ApiResource):

    @use_kwargs(args.paging)
    @use_kwargs(args.totals)
    @use_kwargs(args.make_sort_args(default='-cycle'))
    @marshal_with(schemas.CommitteeTotalsPageSchema(), apply=False)
    def get(self, committee_id=None, committee_type=None, **kwargs):
        query, totals_class, totals_schema = self.build_query(
            committee_id=committee_id,
            committee_type=committee_type,
            **kwargs
        )
        page = utils.fetch_page(query, kwargs, model=totals_class)
        return totals_schema().dump(page).data

    def build_query(self, committee_id=None, committee_type=None, **kwargs):
        totals_class, totals_schema = totals_schema_map.get(
            self._resolve_committee_type(
                committee_id=committee_id,
                committee_type=committee_type,
                **kwargs
            ),
            default_schemas,
        )
        query = totals_class.query
        if committee_id is not None:
            query = query.filter(totals_class.committee_id == committee_id)
        if kwargs.get('cycle'):
            query = query.filter(totals_class.cycle.in_(kwargs['cycle']))

        return query, totals_class, totals_schema

    def _resolve_committee_type(self, committee_id=None, committee_type=None, **kwargs):
        if committee_id is not None:
            query = models.CommitteeHistory.query.filter_by(committee_id=committee_id)
            if kwargs.get('cycle'):
                query = query.filter(models.CommitteeHistory.cycle.in_(kwargs['cycle']))
            query = query.order_by(sa.desc(models.CommitteeHistory.cycle))
            committee = query.first_or_404()
            return committee.committee_type

@doc(
    tags=['candidate'],
    description=docs.TOTALS,
    params={
        'candidate_id': {'description': docs.CANDIDATE_ID},
    },
)
class CandidateTotalsView(utils.Resource):
    @use_kwargs(args.paging)
    @use_kwargs(args.candidate_totals_detail)
    @use_kwargs(args.make_sort_args(default='-cycle'))
    @marshal_with(schemas.CommitteeTotalsPageSchema(), apply=False)
    def get(self, candidate_id, **kwargs):
        query, totals_class, totals_schema = self.build_query(
            candidate_id=candidate_id,
            **kwargs
        )
        if kwargs['sort']:
            validator = args.IndexValidator(totals_class)
            validator(kwargs['sort'])
        page = utils.fetch_page(query, kwargs, model=totals_class)
        return totals_schema().dump(page).data

    def build_query(self, candidate_id=None, **kwargs):
        totals_class, totals_schema = candidate_totals_schema_map.get(
            self._resolve_committee_type(
                candidate_id=candidate_id,
                **kwargs
            ),
            default_schemas,
        )
        query = totals_class.query
        query = query.filter(totals_class.candidate_id == candidate_id)

        if kwargs.get('election_full') is None:
            # not pass election_full
            if kwargs.get('cycle'):
                # only filter by cycle
                query = query.filter(totals_class.cycle.in_(kwargs['cycle']))
        else:
            # pass election_full (true or false)
            query = query.filter(totals_class.election_full == kwargs['election_full'])
            if kwargs.get('cycle'):
                if kwargs.get('election_full'):
                    # if election_full = true, filter by candidate_election_year = cycle
                    query = query.filter(totals_class.candidate_election_year.in_(kwargs['cycle']))
                else:
                    # if election_full = false, filter by cycle = cycle
                    query = query.filter(totals_class.cycle.in_(kwargs['cycle']))
        return query, totals_class, totals_schema

    def _resolve_committee_type(self, candidate_id=None, **kwargs):
        if candidate_id is not None:
            return candidate_id[0]

@doc(
    tags=['receipts'],
    description=(docs.STATE_AGGREGATE_RECIPIENT_TOTALS)
)
class ScheduleAByStateRecipientTotalsView(ApiResource):
    model = models.ScheduleAByStateRecipientTotals
    schema = schemas.ScheduleAByStateRecipientTotalsSchema
    page_schema = schemas.ScheduleAByStateRecipientTotalsPageSchema

    filter_multi_fields = [
        ('cycle', models.ScheduleAByStateRecipientTotals.cycle),
        ('state', models.ScheduleAByStateRecipientTotals.state),
        ('committee_type', models.ScheduleAByStateRecipientTotals.committee_type),
    ]

    @property
    def args(self):
        return utils.extend(
            args.schedule_a_by_state_recipient_totals,
            args.paging,
            args.make_sort_args(
                default='cycle',
                validator=args.OptionValidator([
                    'cycle',
                    'state',
                    'committee_type',
                    'total'
                ]),
            )
        )

    @property
    def index_column(self):
        return self.model.idx
