import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import filters
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource
from webservices.utils import use_kwargs
from webservices import exceptions

committee_type_map = {
    'house-senate': 'H',
    'presidential': 'P',
    'ie-only': 'I',
    'pac-party': None,
    'pac': 'O',
    'party': 'X',
}

totals_schema_map = {
    'P': (models.CommitteeTotalsPerCycle, schemas.CommitteeTotalsPerCyclePageSchema),
    'H': (
        models.CommitteeTotalsHouseSenate,
        schemas.CommitteeTotalsHouseSenatePageSchema,
    ),
    'S': (
        models.CommitteeTotalsHouseSenate,
        schemas.CommitteeTotalsHouseSenatePageSchema,
    ),
    'I': (models.CommitteeTotalsIEOnly, schemas.CommitteeTotalsIEOnlyPageSchema),
}
default_schemas = (
    models.CommitteeTotalsPacParty,
    schemas.CommitteeTotalsPacPartyPageSchema,
)

candidate_totals_schema_map = {
    'P': (
        models.CandidateCommitteeTotalsPresidential,
        schemas.CandidateCommitteeTotalsPresidentialPageSchema,
    ),
    'H': (
        models.CandidateCommitteeTotalsHouseSenate,
        schemas.CandidateCommitteeTotalsHouseSenatePageSchema,
    ),
    'S': (
        models.CandidateCommitteeTotalsHouseSenate,
        schemas.CandidateCommitteeTotalsHouseSenatePageSchema,
    ),
}
pac_cmte_list = {'N', 'O', 'Q', 'V', 'W'}

party_cmte_list = {'X', 'Y'}

default_candidate_schemas = (
    models.CandidateCommitteeTotalsHouseSenate,
    schemas.CandidateCommitteeTotalsHouseSenatePageSchema,
)


@doc(
    tags=['financial'],
    description=docs.TOTALS,
    params={
        'entity_type': {
            'description': 'Committee groupings based on FEC filing form. \
                Choose one of: `presidential`, `pac`, `party`, `pac-party`, \
                `house-senate`, or `ie-only`',
            'enum': [
                'presidential',
                'pac',
                'party',
                'pac-party',
                'house-senate',
                'ie-only',
            ],
        },
    },
)
class TotalsByEntityTypeView(ApiResource):
    @use_kwargs(args.paging)
    @use_kwargs(args.totals_by_entity_type)
    @use_kwargs(args.make_sort_args(default='-cycle'))
    @marshal_with(schemas.CommitteeTotalsPageSchema(), apply=False)
    def get(self, committee_id=None, entity_type=None, **kwargs):
        query, totals_class, totals_schema = self.build_query(
            committee_id=committee_id, entity_type=entity_type, **kwargs
        )
        page = utils.fetch_page(query, kwargs, model=totals_class)
        return totals_schema().dump(page).data

    def build_query(self, committee_id=None, entity_type=None, **kwargs):
        totals_class, totals_schema = totals_schema_map.get(
            committee_type_map.get(entity_type),
            default_schemas,
        )
        query = totals_class.query

        # Committee ID needs to be handled separately because it's not in kwargs
        if committee_id is not None:
            query = query.filter(totals_class.committee_id.in_(committee_id))

        query = filters.filter_multi(
            query,
            kwargs,
            self.get_filter_multi_fields(entity_type, totals_class)
        )
        query = filters.filter_range(
            query,
            kwargs,
            self.get_filter_range_fields(entity_type, totals_class))
        query = filters.filter_fulltext(
            query,
            kwargs,
            self.get_filter_fulltext_fields(entity_type, totals_class))
        query = filters.filter_overlap(
            query,
            kwargs,
            self.get_filter_overlap_fields(entity_type, totals_class)
        )

        if entity_type == 'pac':
            query = query.filter(
                models.CommitteeTotalsPacParty.committee_type.in_(pac_cmte_list)
            )
        if entity_type == 'party':
            query = query.filter(
                models.CommitteeTotalsPacParty.committee_type.in_(party_cmte_list)
            )
        if entity_type == 'pac-party':
            query = query.filter(
                models.CommitteeTotalsPacParty.committee_type.in_(
                    pac_cmte_list.union(party_cmte_list)
                )
            )

        return query, totals_class, totals_schema

    def get_filter_multi_fields(self, entity_type, totals_class):

        filter_multi_fields = [
            ("cycle", totals_class.cycle),
            ("committee_state", totals_class.committee_state),
            ("filing_frequency", totals_class.filing_frequency),
        ]

        if entity_type == 'ie-only':
            return filter_multi_fields

        # All other entity types
        filter_multi_fields.extend([
            ("committee_type", totals_class.committee_type),
            ("committee_designation", totals_class.committee_designation),
            ("organization_type", totals_class.organization_type),
        ])

        return filter_multi_fields

    def get_filter_range_fields(self, entity_type, totals_class):
        if entity_type == 'ie-only':
            return []

        return [
            (
                ('min_receipts', 'max_receipts'),
                totals_class.receipts,
            ),
            (
                ('min_disbursements', 'max_disbursements'),
                totals_class.disbursements,
            ),
            (
                (
                    'min_last_cash_on_hand_end_period',
                    'max_last_cash_on_hand_end_period',
                ),
                totals_class.last_cash_on_hand_end_period,
            ),
            (
                ('min_last_debts_owed_by_committee', 'max_last_debts_owed_by_committee'),
                totals_class.last_debts_owed_by_committee,
            ),
        ]

    def get_filter_fulltext_fields(self, entity_type, totals_class):
        if entity_type == 'ie-only':
            return []

        return [
            ("treasurer_name", totals_class.treasurer_text),
        ]

    def get_filter_overlap_fields(self, entity_type, totals_class):

        if 'pac' not in entity_type:
            return []

        # Only for 'pac' and 'pac-party'
        return [
            ("sponsor_candidate_id", totals_class.sponsor_candidate_ids),
        ]


@doc(
    tags=['financial'],
    description=docs.TOTALS,
    params={
        'committee_id': {'description': docs.COMMITTEE_ID},
        'committee_type': {
            'description': 'House, Senate, presidential, independent expenditure only',
            'enum': [
                'presidential',
                'pac-party',
                'pac',
                'party',
                'house-senate',
                'ie-only',
            ],
        },
    },
)
class TotalsCommitteeView(ApiResource):
    @use_kwargs(args.paging)
    @use_kwargs(args.committee_totals)
    @use_kwargs(args.make_sort_args(default='-cycle'))
    @marshal_with(schemas.CommitteeTotalsPageSchema(), apply=False)
    def get(self, committee_id=None, committee_type=None, **kwargs):
        query, totals_class, totals_schema = self.build_query(
            committee_id=committee_id.upper(), committee_type=committee_type, **kwargs
        )
        page = utils.fetch_page(query, kwargs, model=totals_class)
        return totals_schema().dump(page).data

    def build_query(self, committee_id=None, committee_type=None, **kwargs):
        totals_class, totals_schema = totals_schema_map.get(
            self._resolve_committee_type(
                committee_id=committee_id.upper(), committee_type=committee_type, **kwargs
            ),
            default_schemas,
        )
        query = totals_class.query
        if committee_id is not None:
            query = query.filter(totals_class.committee_id == committee_id.upper())
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
    params={'candidate_id': {'description': docs.CANDIDATE_ID}, },
)
class CandidateTotalsView(utils.Resource):
    @use_kwargs(args.paging)
    @use_kwargs(args.candidate_totals_detail)
    @use_kwargs(args.make_sort_args(default='-cycle'))
    @marshal_with(schemas.CommitteeTotalsPageSchema(), apply=False)
    def get(self, candidate_id, **kwargs):
        query, totals_class, totals_schema = self.build_query(
            candidate_id=candidate_id.upper(), **kwargs
        )
        if kwargs['sort']:
            validator = args.IndexValidator(totals_class)
            validator(kwargs['sort'])
        page = utils.fetch_page(query, kwargs, model=totals_class)
        return totals_schema().dump(page).data

    def build_query(self, candidate_id=None, **kwargs):
        totals_class, totals_schema = candidate_totals_schema_map.get(
            self._resolve_committee_type(candidate_id=candidate_id.upper(), **kwargs),
            default_schemas,
        )
        query = totals_class.query
        query = query.filter(totals_class.candidate_id == candidate_id.upper())

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
                    query = query.filter(
                        totals_class.candidate_election_year.in_(kwargs['cycle'])
                    )
                else:
                    # if election_full = false, filter by cycle = cycle
                    query = query.filter(totals_class.cycle.in_(kwargs['cycle']))
        return query, totals_class, totals_schema

    def _resolve_committee_type(self, candidate_id=None, **kwargs):
        if candidate_id is not None:
            return candidate_id[0]


@doc(tags=['receipts'], description=(docs.STATE_AGGREGATE_RECIPIENT_TOTALS))
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
                validator=args.OptionValidator(
                    ['cycle', 'state', 'committee_type', 'total']
                ),
            ),
        )

    @property
    def index_column(self):
        return self.model.idx
