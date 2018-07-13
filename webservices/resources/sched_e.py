import sqlalchemy as sa
from sqlalchemy import func
from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import filters
from webservices import utils
from webservices import schemas

from webservices.common import models
from webservices.common import views
from webservices.common.views import ItemizedResource

from webservices.common.models import (
    EFilings,
    db
)


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

    filter_multi_fields = [
        ('image_number', models.ScheduleEEfile.image_number),
        ('committee_id', models.ScheduleEEfile.committee_id),
        ('candidate_id', models.ScheduleEEfile.candidate_id),
        ('support_oppose_indicator', models.ScheduleEEfile.support_oppose_indicator),
        #('candidate_name', models.ScheduleEEfile.candidate_name),
    ]

    filter_range_fields = [
        (('min_expenditure_date', 'max_expenditure_date'), models.ScheduleEEfile.expenditure_date),
    ]

    filter_fulltext_fields = [
        ('candidate_name', models.ScheduleEEfile.candidate_name),
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
