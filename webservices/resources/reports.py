import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices import filters
from webservices.common import models
from webservices.common import views
from webservices.utils import use_kwargs


reports_schema_map = {
    'P': (
        models.CommitteeReportsPresidential,
        schemas.CommitteeReportsPresidentialPageSchema,
    ),
    'H': (
        models.CommitteeReportsHouseSenate,
        schemas.CommitteeReportsHouseSenatePageSchema,
    ),
    'S': (
        models.CommitteeReportsHouseSenate,
        schemas.CommitteeReportsHouseSenatePageSchema,
    ),
    'I': (models.CommitteeReportsIEOnly, schemas.CommitteeReportsIEOnlyPageSchema),
}

efile_reports_schema_map = {
    'P': (
        models.BaseF3PFiling,
        schemas.BaseF3PFilingSchema,
        schemas.BaseF3PFilingPageSchema,
    ),
    'H': (
        models.BaseF3Filing,
        schemas.BaseF3FilingSchema,
        schemas.BaseF3FilingPageSchema,
    ),
    'S': (
        models.BaseF3Filing,
        schemas.BaseF3FilingSchema,
        schemas.BaseF3FilingPageSchema,
    ),
    'X': (
        models.BaseF3XFiling,
        schemas.BaseF3XFilingSchema,
        schemas.BaseF3XFilingPageSchema,
    ),
}
# We don't have report data for C and E yet
default_schemas = (
    models.CommitteeReportsPacParty,
    schemas.CommitteeReportsPacPartyPageSchema,
)

reports_type_map = {
    'house-senate': 'H',
    'presidential': 'P',
    'ie-only': 'I',
    'pac-party': None,
    'pac': 'O',
    'party': 'XY',
}

form_type_map = {
    'presidential': 'P',
    'pac-party': 'X',
    'house-senate': 'H',
}


def get_range_filters():
    filter_range_fields = [
        (
            ('min_receipt_date', 'max_receipt_date'),
            models.CommitteeReports.receipt_date,
        ),
        (
            ('min_disbursements_amount', 'max_disbursements_amount'),
            models.CommitteeReports.total_disbursements_period,
        ),
        (
            ('min_receipts_amount', 'max_receipts_amount'),
            models.CommitteeReports.total_receipts_period,
        ),
        (
            (
                'min_cash_on_hand_end_period_amount',
                'max_cash_on_hand_end_period_amount',
            ),
            models.CommitteeReports.cash_on_hand_end_period,
        ),
        (
            ('min_debts_owed_amount', 'max_debts_owed_amount'),
            models.CommitteeReports.debts_owed_by_committee,
        ),
        (
            ('min_independent_expenditures', 'max_independent_expenditures'),
            models.CommitteeReportsPacParty.independent_expenditures_period,
        ),
        (
            (
                'min_party_coordinated_expenditures',
                'max_party_coordinated_expenditures',
            ),
            models.CommitteeReportsPacParty.coordinated_expenditures_by_party_committee_period,
        ),
        (
            ('min_total_contributions', 'max_total_contributions'),
            models.CommitteeReportsIEOnly.independent_contributions_period,
        ),
    ]
    return filter_range_fields


def get_match_filters():
    filter_match_fields = [
        ('filer_type', models.CommitteeReports.means_filed),
        ('is_amended', models.CommitteeReports.is_amended),
        ('most_recent', models.CommitteeReports.most_recent),
    ]
    return filter_match_fields


# Use for endpoint '/reports/<string:entity_type>/' under tag:'financial'
# Sample urls:
# http://127.0.0.1:5000/v1/reports/presidential/?q_filer=bid
# http://127.0.0.1:5000/v1/reports/house-senate/?q_filer=bid
# http://127.0.0.1:5000/v1/reports/pac-party/q_filer=bid
# http://127.0.0.1:5000/v1/reports/ie-only/q_spender=bid
@doc(
    tags=['financial'],
    description=docs.REPORTS,
    params={
        'entity_type': {
            'description': 'Committee groupings based on FEC filing form. \
                Choose one of: `presidential`, `pac-party`, `house-senate`, or `ie-only`',
            'enum': ['presidential', 'pac-party', 'house-senate', 'ie-only'],
        },
    },
)
class ReportsView(views.ApiResource):
    @use_kwargs(args.paging)
    @use_kwargs(args.reports)
    @use_kwargs(args.make_multi_sort_args(default=['-coverage_end_date']))
    @marshal_with(schemas.CommitteeReportsPageSchema(), apply=False)
    def get(self, entity_type=None, **kwargs):
        query, reports_class, reports_schema = self.build_query(
            entity_type=entity_type, **kwargs
        )
        if kwargs['sort']:
            validator = args.IndicesValidator(reports_class)
            validator(kwargs['sort'])
        page = utils.fetch_page(query, kwargs, model=reports_class, multi=True)
        return reports_schema().dump(page).data

    def build_query(self, entity_type=None, **kwargs):
        # For this endpoint we now enforce the enpoint specified to map the right model.
        reports_class, reports_schema = reports_schema_map.get(
            reports_type_map.get(entity_type), default_schemas,
        )
        query = reports_class.query

        filter_multi_fields = [
            ('amendment_indicator', models.CommitteeReports.amendment_indicator),
            ('report_type', reports_class.report_type),
            ('committee_id', reports_class.committee_id),
            ('year', reports_class.report_year),
            ('cycle', reports_class.cycle),
            ('beginning_image_number', reports_class.beginning_image_number),
        ]

        if entity_type == 'ie-only':
            filter_fulltext_fields = [("q_spender", reports_class.spender_name_text), ]
        else:
            filter_fulltext_fields = [("q_filer", reports_class.filer_name_text), ]

        if hasattr(reports_class, 'committee'):
            query = reports_class.query.outerjoin(reports_class.committee).options(
                sa.orm.contains_eager(reports_class.committee)
            )

        if kwargs.get('candidate_id'):
            query = query.filter(
                models.CommitteeHistory.candidate_ids.overlap(
                    [kwargs.get('candidate_id')]
                )
            )

        if kwargs.get('committee_type'):
            query = query.filter(
                models.CommitteeHistory.committee_type.in_(kwargs.get('committee_type'))
            )
        query = filters.filter_range(query, kwargs, get_range_filters())
        query = filters.filter_match(query, kwargs, get_match_filters())
        query = filters.filter_multi(query, kwargs, filter_multi_fields)
        query = filters.filter_fulltext(query, kwargs, filter_fulltext_fields)
        return query, reports_class, reports_schema


# Use for '/committee/<string:committee_id>/reports/' under tag:'financial'
@doc(
    tags=['financial'],
    description=docs.REPORTS,
    params={'committee_id': {'description': docs.COMMITTEE_ID}, },
)
class CommitteeReportsView(views.ApiResource):
    @use_kwargs(args.paging)
    @use_kwargs(args.committee_reports)
    @use_kwargs(args.make_multi_sort_args(default=['-coverage_end_date']))
    @marshal_with(schemas.CommitteeReportsPageSchema(), apply=False)
    def get(self, committee_id=None, committee_type=None, **kwargs):
        query, reports_class, reports_schema = self.build_query(
            committee_id=committee_id.upper(), committee_type=committee_type, **kwargs
        )
        if kwargs['sort']:
            validator = args.IndicesValidator(reports_class)
            validator(kwargs['sort'])
        page = utils.fetch_page(query, kwargs, model=reports_class, multi=True)
        return reports_schema().dump(page).data

    def build_query(self, committee_id=None, committee_type=None, **kwargs):
        reports_class, reports_schema = reports_schema_map.get(
            self._resolve_committee_type(
                committee_id=committee_id.upper(), committee_type=committee_type, **kwargs
            ),
            default_schemas,
        )
        query = reports_class.query

        filter_multi_fields = [
            ('amendment_indicator', models.CommitteeReports.amendment_indicator),
            ('report_type', reports_class.report_type),
            ('year', reports_class.report_year),
            ('cycle', reports_class.cycle),
            ('beginning_image_number', reports_class.beginning_image_number),
        ]
        # Eagerly load committees if applicable
        if hasattr(reports_class, 'committee'):
            query = reports_class.query.options(
                sa.orm.joinedload(reports_class.committee)
            )
        if committee_id is not None:
            query = query.filter_by(committee_id=committee_id.upper())

        query = filters.filter_range(query, kwargs, get_range_filters())
        query = filters.filter_match(query, kwargs, get_match_filters())
        query = filters.filter_multi(query, kwargs, filter_multi_fields)
        return query, reports_class, reports_schema

    def _resolve_committee_type(self, committee_id=None, committee_type=None, **kwargs):
        if committee_id is not None:
            query = models.CommitteeHistory.query.filter_by(committee_id=committee_id.upper())

            if kwargs.get('cycle'):
                query = query.filter(models.CommitteeHistory.cycle.in_(kwargs['cycle']))
            if kwargs.get('year'):
                cycle_list = [(year + year % 2) for year in kwargs['year']]
                query = query.filter(models.CommitteeHistory.cycle.in_(cycle_list))

            query = query.order_by(sa.desc(models.CommitteeHistory.cycle))
            committee = query.first_or_404()
            return committee.committee_type
        elif committee_type is not None:
            return reports_type_map.get(committee_type)


# Use for '/efile/reports/house-senate/' under tag:'efiling'
# Sample url:
# http://127.0.0.1:5000/v1/efile/reports/house-senate/?filer_name_text=san
@doc(
    tags=['efiling'], description=docs.EFILE_REPORTS,
)
class EFilingHouseSenateSummaryView(views.ApiResource):

    model = models.BaseF3Filing
    schema = schemas.BaseF3FilingSchema
    page_schema = schemas.BaseF3FilingPageSchema

    filter_range_fields = [
        (('min_receipt_date', 'max_receipt_date'), models.BaseFiling.receipt_date),
    ]
    filter_multi_fields = [
        ('file_number', model.file_number),
        ('committee_id', model.committee_id),
    ]
    filter_fulltext_fields = [("q_filer", models.CommitteeSearch.fulltxt)]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.efilings,
            args.make_sort_args(
                default='-receipt_date', validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)

        if kwargs.get("q_filer"):
            query = query.join(
                models.CommitteeSearch,
                self.model.committee_id == models.CommitteeSearch.id,
            ).distinct()
        return query

    @property
    def index_column(self):
        return self.model.file_number


# Use for '/efile/reports/presidential/' under tag:'efiling'
# Sample url:
# http://127.0.0.1:5000/v1/efile/reports/presidential/?filer_name_text=bid
@doc(
    tags=['efiling'], description=docs.EFILE_REPORTS,
)
class EFilingPresidentialSummaryView(views.ApiResource):

    model = models.BaseF3PFiling
    schema = schemas.BaseF3PFilingSchema
    page_schema = schemas.BaseF3PFilingPageSchema

    filter_range_fields = [
        (('min_receipt_date', 'max_receipt_date'), models.BaseFiling.receipt_date),
    ]
    filter_multi_fields = [
        ('file_number', model.file_number),
        ('committee_id', model.committee_id),
    ]
    filter_fulltext_fields = [("q_filer", models.CommitteeSearch.fulltxt)]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.efilings,
            args.make_sort_args(
                default='-receipt_date', validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)

        if kwargs.get("q_filer"):
            query = query.join(
                models.CommitteeSearch,
                self.model.committee_id == models.CommitteeSearch.id,
            ).distinct()
        return query

    @property
    def index_column(self):
        return self.model.file_number


# Use for '/efile/reports/pac-party/' under tag:'efiling'
# Sample url:
# http://127.0.0.1:5000/v1/efile/reports/pac-party/?filer_name_text=san
@doc(
    tags=['efiling'], description=docs.EFILE_REPORTS,
)
class EFilingPacPartySummaryView(views.ApiResource):

    model = models.BaseF3XFiling
    schema = schemas.BaseF3XFilingSchema
    page_schema = schemas.BaseF3XFilingPageSchema

    filter_range_fields = [
        (('min_receipt_date', 'max_receipt_date'), models.BaseFiling.receipt_date),
    ]
    filter_multi_fields = [
        ('file_number', model.file_number),
        ('committee_id', model.committee_id),
    ]
    filter_fulltext_fields = [("q_filer", models.CommitteeSearch.fulltxt)]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.efilings,
            args.make_sort_args(
                default='-receipt_date', validator=args.IndexValidator(self.model),
            ),
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)

        if kwargs.get("q_filer"):
            query = query.join(
                models.CommitteeSearch,
                self.model.committee_id == models.CommitteeSearch.id,
            ).distinct()
        return query

    @property
    def index_column(self):
        return self.model.file_number
