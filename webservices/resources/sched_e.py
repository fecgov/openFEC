import sqlalchemy as sa

from flask_apispec import doc
from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from sqlalchemy.orm import aliased, contains_eager
from webservices.common import models
from webservices.common import views
from webservices.common.views import ItemizedResource

@doc(
    tags=['independent expenditures'],
    description=docs.SCHEDULE_E,
)
class ScheduleEView(ItemizedResource):

    model = models.ScheduleE
    schema = schemas.ScheduleESchema
    page_schema = schemas.ScheduleEPageSchema

    @property
    def year_column(self):
        return self.model.report_year
    @property
    def index_column(self):
        return self.model.sub_id
    @property
    def amount_column(self):
        return self.model.expenditure_amount

    filter_multi_fields = [
        ('cycle', sa.func.get_cycle(models.ScheduleE.report_year)),
        ('image_number', models.ScheduleE.image_number),
        ('committee_id', models.ScheduleE.committee_id),
        ('candidate_id', models.ScheduleE.candidate_id),
        ('support_oppose_indicator', models.ScheduleE.support_oppose_indicator),
        ('filing_form', models.ScheduleE.filing_form),
        ('is_notice', models.ScheduleE.is_notice),
        ('candidate_office', models.ScheduleE.candidate_office),
        ('candidate_office_state', models.ScheduleE.candidate_office_state),
        ('candidate_office_district', models.ScheduleE.candidate_office_district),
        ('candidate_party', models.ScheduleE.candidate_party),
    ]
    filter_fulltext_fields = [
        ('payee_name', models.ScheduleE.payee_name_text),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleE.expenditure_date),
        (('min_amount', 'max_amount'), models.ScheduleE.expenditure_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleE.image_number),
        (('min_dissemination_date', 'max_dissemination_date'), models.ScheduleE.dissemination_date),
        (('min_filing_date', 'max_filing_date'), models.ScheduleE.filing_date),

    ]
    query_options = [
        sa.orm.joinedload(models.ScheduleE.candidate),
        sa.orm.joinedload(models.ScheduleE.committee),
    ]

    @property
    def args(self):
        return utils.extend(
            args.itemized,
            args.schedule_e,
            args.make_seek_args(),
            args.make_sort_args(
                default='-expenditure_date',
                validator=args.OptionValidator([
                    'expenditure_date',
                    'expenditure_amount',
                    'office_total_ytd',
                    'support_oppose_indicator'
                ]),
            ),
        )

    def filter_election(self, query, kwargs):
        if not kwargs['office']:
            return query
        utils.check_election_arguments(kwargs)
        query = query.join(
            models.CandidateHistory,
            models.ScheduleE.candidate_id == models.CandidateHistory.candidate_id,
        ).filter(
            models.CandidateHistory.two_year_period == kwargs['cycle'],
            models.CandidateHistory.office == kwargs['office'][0].upper(),
            models.ScheduleE.report_year.in_([kwargs['cycle'], kwargs['cycle'] - 1]),
        )
        if kwargs['state']:
            query = query.filter(models.CandidateHistory.state == kwargs['state'])
        if kwargs['district']:
            query = query.filter(models.CandidateHistory.district == kwargs['district'])
        return query


@doc(
    tags=['independent expenditures'],
    description=docs.EFILING_TAG,
)
class ScheduleEEfileView(views.ApiResource):
    model = models.ScheduleEEfile
    schema = schemas.ItemizedScheduleEfilingsSchema
    page_schema = schemas.ScheduleEEfilePageSchema
    # Use exact count for this endpoint only because the estimate is way off
    use_estimated_counts = False

    filter_multi_fields = [
        ('image_number', models.ScheduleEEfile.image_number),
        ('committee_id', models.ScheduleEEfile.committee_id),
        ('candidate_id', models.ScheduleEEfile.candidate_id),
        ('support_oppose_indicator', models.ScheduleEEfile.support_oppose_indicator),
        ('candidate_party', models.ScheduleEEfile.candidate_party),
        ('candidate_office', models.ScheduleEEfile.candidate_office),
        ('candidate_office_state', models.ScheduleEEfile.candidate_office_state),
        ('candidate_office_district', models.ScheduleEEfile.candidate_office_district),
    ]

    filter_range_fields = [
        (('min_expenditure_date', 'max_expenditure_date'), models.ScheduleEEfile.expenditure_date),
        (('min_dissemination_date', 'max_dissemination_date'), models.ScheduleEEfile.dissemination_date),
    ]

    filter_fulltext_fields = [
        ('candidate_search', models.ScheduleEEfile.cand_fulltxt),
    ]

    filter_match_fields = [
        ('most_recent', models.ScheduleEEfile.most_recent),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_e_efile,
            args.make_sort_args(
                default='-expenditure_date',
                validator=args.OptionValidator([
                    'expenditure_date',
                    'expenditure_amount',
                    'office_total_ytd',
                ]),
            ),
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        filing_alias = aliased(models.EFilings)
        query = query.join(filing_alias, self.model.filing)
        query = query.options(contains_eager(self.model.filing, alias=filing_alias))

        if kwargs.get('spender_name'):
                spender_filter = [
                    filing_alias.committee_name.like('%' + value.upper() + '%')
                    for value in kwargs.get('spender_name')
                ]
                query = query.filter(sa.or_(*spender_filter))

        if kwargs.get('min_filed_date') is not None:
            query = query.filter(filing_alias.filed_date >= kwargs['min_filed_date'])
        if kwargs.get('max_filed_date') is not None:
            query = query.filter(filing_alias.filed_date <= kwargs['max_filed_date'])
        return query
