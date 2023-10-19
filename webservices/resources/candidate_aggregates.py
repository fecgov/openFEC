import sqlalchemy as sa

from flask_apispec import doc, marshal_with

from webservices import args
from webservices import utils
from webservices import docs
from webservices import filters
from webservices import schemas
from webservices.utils import use_kwargs
from webservices.common.views import ApiResource
from webservices.common import models
from webservices.common.models import (
    CandidateCommitteeLink,
    ScheduleABySize,
    ScheduleAByState,
    db,
)


def candidate_aggregate(aggregate_model, label_columns, group_columns, kwargs):
    """
    This fix is for doubled totals caused by linkage_mv #3816

    Use linkage.election_yr_to_be_included instead od ofec_candidate_election_mv for election_full=true

    When election_full=true, aggregate is calculated on election_yr_to_be_included
    When election_full=false, aggregate is calculated on fec_election_yr

    As long as the linkage.election_yr_to_be_included is correct for PR, the aggregate data will be correct too
    election year covers more than one fec_election_year
    Aggregated data are calculated per fec_cycle only, no odd year

    """
    rows = (
        db.session.query(
            CandidateCommitteeLink.candidate_id.label('candidate_id'),
            CandidateCommitteeLink.committee_id.label('committee_id'),
            CandidateCommitteeLink.fec_election_year.label('fec_election_year'),
            CandidateCommitteeLink.election_yr_to_be_included.label(
                'election_yr_to_be_included'
            ),
        )
        .filter(
            (
                CandidateCommitteeLink.fec_election_year.in_(kwargs['cycle'])
                if not kwargs.get('election_full')
                else CandidateCommitteeLink.election_yr_to_be_included.in_(
                    kwargs['cycle']
                )
            ),
            CandidateCommitteeLink.candidate_id.in_(kwargs['candidate_id']),
            CandidateCommitteeLink.committee_designation.in_(['P', 'A']),
        )
        .distinct()
        .subquery()
    )

    cycle_column = (
        rows.c.election_yr_to_be_included
        if kwargs.get('election_full')
        else rows.c.fec_election_year
    ).label('cycle')

    aggregates = (
        db.session.query(rows.c.candidate_id, cycle_column, *label_columns)
        .join(
            aggregate_model,
            sa.and_(
                rows.c.committee_id == aggregate_model.committee_id,
                rows.c.fec_election_year == aggregate_model.cycle,
            ),
        )
        .group_by(rows.c.candidate_id, cycle_column, *group_columns)
    )
    return rows, aggregates


# used for 'schedules/schedule_a/by_size/by_candidate/'
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_a/by_size/by_candidate/?sort=-count&candidate_id=H8CA05035&cycle=2022
# &election_full=true
@doc(
    tags=['receipts'], description=docs.SCHEDULE_A_SIZE_CANDIDATE_TAG,
)
class ScheduleABySizeCandidateView(ApiResource):
    schema = schemas.ScheduleABySizeCandidateSchema
    page_schema = schemas.ScheduleABySizeCandidatePageSchema()
    sort_option = [
            'total',
            'size',
            'count'
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_a_candidate_aggregate,
            args.make_multi_sort_args(default=["size", ], validator=args.SortMultiOptionValidator(
                self.sort_option),
            ),
        )

    def build_query(self, **kwargs):
        label_columns = [
            ScheduleABySize.size,
            sa.func.sum(ScheduleABySize.total).label('total'),
            sa.func.sum(ScheduleABySize.count).label('count'),
        ]
        group_columns = [ScheduleABySize.size]

        _, query = candidate_aggregate(
            ScheduleABySize, label_columns, group_columns, kwargs
        )
        return query


# used for 'schedules/schedule_a/by_state/by_candidate/'
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_a/by_state/by_candidate/?sort=state&candidate_id=H8CA05035
# &cycle=2022&election_full=true
@doc(
    tags=['receipts'], description=docs.SCHEDULE_A_STATE_CANDIDATE_TAG,
)
class ScheduleAByStateCandidateView(ApiResource):
    schema = schemas.ScheduleAByStateCandidateSchema
    page_schema = schemas.ScheduleAByStateCandidatePageSchema()
    sort_option = [
            'total',
            'count',
            'state',
            'state_full',
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_a_candidate_aggregate,
            args.make_multi_sort_args(default=["state", ], validator=args.SortMultiOptionValidator(
                self.sort_option),
            ),
        )

    def build_query(self, **kwargs):
        _, query = candidate_aggregate(
            ScheduleAByState,
            [
                ScheduleAByState.state,
                sa.func.sum(ScheduleAByState.total).label('total'),
                sa.func.max(ScheduleAByState.state_full).label('state_full'),
                sa.func.sum(ScheduleAByState.count).label('count'),
            ],
            [ScheduleAByState.state],
            kwargs,
        )
        return query


# used for 'schedules/schedule_a/by_state/by_candidate/totals/'. always return one row.
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_a/by_state/by_candidate/totals/?sort=total&candidate_id=H8CA05035
# &cycle=2022&election_full=true
@doc(
    tags=['receipts'], description=docs.SCHEDULE_A_STATE_CANDIDATE_TOTAL_TAG,
)
class ScheduleAByStateCandidateTotalsView(ApiResource):
    schema = schemas.ScheduleAByStateCandidateSchema
    page_schema = schemas.ScheduleAByStateCandidatePageSchema()
    sort_option = [
            'total',
            'count',
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_a_candidate_aggregate,
            args.make_multi_sort_args(default=["total", ], validator=args.SortMultiOptionValidator(
                self.sort_option),
            ),
        )

    def build_query(self, **kwargs):
        _, query = candidate_aggregate(
            ScheduleAByState,
            [
                ScheduleAByState.state,
                sa.func.sum(ScheduleAByState.total).label('total'),
                sa.func.max(ScheduleAByState.state_full).label('state_full'),
                ScheduleAByState.count,
            ],
            [ScheduleAByState.state, ScheduleAByState.count],
            kwargs,
        )
        q = query.subquery()
        query = db.session.query(
            sa.func.sum(q.c.total).label('total'),
            sa.func.sum(q.c.count).label('count'),
            q.c.candidate_id.label('candidate_id'),
            q.c.cycle,
        ).group_by(q.c.candidate_id, q.c.cycle)

        return query


# used for '/candidates/totals/'
# Ex: http://127.0.0.1:5000/v1/candidates/totals/?sort=-election_year&election_full=true
@doc(
    tags=['candidate'], description=docs.TOTAL_CANDIDATE_TAG,
)
class TotalsCandidateView(ApiResource):

    schema = schemas.CandidateHistoryTotalSchema
    page_schema = schemas.CandidateHistoryTotalPageSchema

    sort_options = [
        'election_year',
        'name',
        'party',
        'party_full',
        'state',
        'office',
        'district',
        'receipts',
        'disbursements',
        'individual_itemized_contributions',
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.candidate_totals,
            args.make_sort_args(
                default='-election_year',
                validator=args.OptionValidator(self.sort_options)
            ),
        )

    def filter_multi_fields(self, history, total):
        return [
            ('candidate_id', history.candidate_id),
            ('election_year', total.election_year),
            ('cycle', total.cycle),
            ('office', history.office),
            ('party', history.party),
            ('state', history.state),
            ('district', history.district),
        ]

    def filter_range_fields(self, model):
        return [
            (('min_receipts', 'max_receipts'), model.receipts),
            (('min_disbursements', 'max_disbursements'), model.disbursements),
            (
                ('min_cash_on_hand_end_period', 'max_cash_on_hand_end_period'),
                model.cash_on_hand_end_period,
            ),
            (
                ('min_debts_owed_by_committee', 'max_debts_owed_by_committee'),
                model.debts_owed_by_committee,
            ),
        ]

    filter_fulltext_fields = [('q', models.CandidateSearch.fulltxt)]

    filter_match_fields = [
        ('has_raised_funds', models.CandidateTotal.has_raised_funds),
        ('federal_funds_flag', models.CandidateTotal.federal_funds_flag),
        ('election_full', models.CandidateTotal.is_election),
    ]

    def build_query(self, **kwargs):
        history = models.CandidateHistoryWithFuture
        query = (
            db.session.query(history.__table__, models.CandidateTotal.__table__)
            .join(
                models.CandidateTotal,
                sa.and_(
                    history.candidate_id == models.CandidateTotal.candidate_id,
                    history.two_year_period == models.CandidateTotal.cycle,
                ),
            )
            .join(
                models.Candidate, history.candidate_id == models.Candidate.candidate_id,
            )
        )
        if kwargs.get('q'):
            query = query.join(
                models.CandidateSearch,
                history.candidate_id == models.CandidateSearch.id,
            )

        if 'is_active_candidate' in kwargs and kwargs.get(
            'is_active_candidate'
        ):  # load active candidates only if True
            query = query.filter(history.candidate_inactive == False)  # noqa
        elif 'is_active_candidate' in kwargs and not kwargs.get(
            'is_active_candidate'
        ):  # load inactive candidates only if False
            query = query.filter(history.candidate_inactive == True)  # noqa
        else:  # load all candidates
            pass

        query = filters.filter_multi(
            query, kwargs, self.filter_multi_fields(history, models.CandidateTotal)
        )
        query = filters.filter_range(
            query, kwargs, self.filter_range_fields(models.CandidateTotal)
        )
        query = filters.filter_fulltext(query, kwargs, self.filter_fulltext_fields)
        query = filters.filter_match(query, kwargs, self.filter_match_fields)
        return query


# endpoint: /candidates/totals/aggregates/
@doc(
    tags=["candidate"], description=docs.CANDIDATE_TOTAL_AGGREGATE_TAG,
)
class CandidateTotalAggregateView(ApiResource):
    sort_options = [
        'election_year',
        'office',
        'state',
        'state_full',
        'party',
        'district',
    ]

    schema = schemas.CandidateTotalAggregateSchema
    page_schema = schemas.CandidateTotalAggregatePageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.candidate_total_aggregate,
            args.make_multi_sort_args(default=["-election_year", ], validator=args.SortMultiOptionValidator(
                self.sort_options),
            ),
        )

    def build_query(self, **kwargs):
        total = models.CandidateTotal

        query = db.session.query(
            total.election_year.label("election_year"),
            sa.func.sum(total.receipts).label(
                "total_receipts"),
            sa.func.sum(total.disbursements).label(
                "total_disbursements"),
            sa.func.sum(total.individual_itemized_contributions).label(
                "total_individual_itemized_contributions"),
            sa.func.sum(total.transfers_from_other_authorized_committee).label(
                "total_transfers_from_other_authorized_committee"),
            sa.func.sum(total.other_political_committee_contributions).label(
                "total_other_political_committee_contributions"),
            sa.func.sum(total.cash_on_hand_end_period).label(
                "total_cash_on_hand_end_period"),
            sa.func.sum(total.debts_owed_by_committee).label(
                "total_debts_owed_by_committee"),
        )

        # remove election_year=null
        query = query.filter(total.election_year.isnot(None))
        query = query.filter(
            models.ElectionsList.cycle == total.election_year,
            models.ElectionsList.office == total.office,
            models.ElectionsList.state == total.state,
            models.ElectionsList.district == total.district
        )

        if kwargs.get("election_year"):
            query = query.filter(
                total.election_year.in_(kwargs["election_year"])
            )
        # # is_active_candidate=true  //only show active candidate totals
        # is_active_candidate=false //only show inactive candidate totals
        # is_active_candidate=not specified //show full totals of both active and inactive
        if kwargs.get("is_active_candidate"):
            query = query.filter(total.candidate_inactive.is_(False))

        elif "is_active_candidate" in kwargs and not kwargs.get("is_active_candidate"):
            query = query.filter(total.candidate_inactive.is_(True))

        # if not pass election_full variable, election_full default set `true` in args.py
        # if pass election_full = true, election_year is candidate election year
        # if pass election_full = flase, election_year is finance two-year period
        if kwargs.get("election_full"):
            query = query.filter(total.is_election.is_(kwargs["election_full"]))

        if kwargs.get("min_election_cycle"):
            query = query.filter(
                total.election_year >= kwargs["min_election_cycle"]
            )

        if kwargs.get("max_election_cycle"):
            query = query.filter(
                total.election_year <= kwargs["max_election_cycle"]
            )

        if kwargs.get("office"):
            query = query.filter(total.office == kwargs["office"])

        if kwargs.get("state"):
            query = query.filter(total.state.in_(kwargs["state"]))

        if kwargs.get("district"):
            query = query.filter(total.district.in_(kwargs["district"]))

        if kwargs.get("party"):
            if ("DEM" == kwargs.get("party")):
                query = query.filter(total.party.in_(["DEM", "DFL"]))
            elif ("REP" == kwargs.get("party")):
                query = query.filter(total.party.in_(["REP"]))
            else:
                query = query.filter(total.party.notin_(["DEM", "DFL", "REP"]))

        # aggregate by election_year, office
        if kwargs.get("aggregate_by") and ("office" == kwargs.get("aggregate_by")):

            query = query.add_columns(
                total.office.label("office")
            )
            query = query.group_by(
                total.election_year, total.office,
            )

        # aggregate by election_year, office, state.
        elif kwargs.get("aggregate_by") and "office-state" == kwargs.get("aggregate_by"):
            query = query.add_columns(
                total.office.label("office")
            )
            query = query.add_columns(
                total.state.label("state")
            )
            query = query.add_columns(
                total.state_full.label("state_full")
            )
            query = query.group_by(
                total.election_year, total.office, total.state, total.state_full
            )

        # aggregate by election_year, office, state, district
        elif kwargs.get("aggregate_by") and "office-state-district" == kwargs.get("aggregate_by"):
            query = query.add_columns(
                total.office.label("office")
            )
            query = query.add_columns(
                total.state.label("state")
            )
            query = query.add_columns(
                total.state_full.label("state_full")
            )
            query = query.add_columns(
                total.district.label("district")
            )

            # remove district=null
            query = query.filter(total.district.isnot(None))
            query = query.group_by(
                total.election_year, total.office, total.state, total.district, total.state_full
            )

        # aggregate by election_year, office, party
        elif kwargs.get("aggregate_by") and "office-party" == kwargs.get("aggregate_by"):
            query = query.add_columns(
                total.office.label("office")
            )
            query = query.add_columns(
                sa.case(
                    [
                        (total.party == "DFL", "DEM"),
                        (total.party == "DEM", "DEM"),
                        (total.party == "REP", "REP"),
                    ],
                    else_="Other",
                ).label("party")
            )

            query = query.group_by(
                total.election_year,
                total.office,
                sa.case(
                    [
                        (total.party == "DFL", "DEM"),
                        (total.party == "DEM", "DEM"),
                        (total.party == "REP", "REP"),
                    ],
                    else_="Other",
                ),
            )

        # without `aggregate_by`, aggregate by election_year only
        else:
            query = query.group_by(
                total.election_year,
            )

        return query
