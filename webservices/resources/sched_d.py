from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


# Used for '/schedules/schedule_d/'
# under tag: debts
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_d/
@doc(
    tags=['debts'],
    description=docs.SCHEDULE_D,
)
class ScheduleDView(ApiResource):

    model = models.ScheduleD
    schema = schemas.ScheduleDSchema
    page_schema = schemas.ScheduleDPageSchema

    @property
    def index_column(self):
        return self.model.sub_id

    filter_multi_fields = [
        ('image_number', models.ScheduleD.image_number),
        ('committee_id', models.ScheduleD.committee_id),
        ('report_year', models.ScheduleD.report_year),
        ('report_type', models.ScheduleD.report_type),
        ('filing_form', models.ScheduleD.filing_form),
        ('committee_type', models.ScheduleD.committee_type),
        ('form_line_number', models.ScheduleD.form_line_number),
    ]

    filter_range_fields = [
        (('min_payment_period', 'max_payment_period'), models.ScheduleD.payment_period),
        (('min_amount_incurred', 'max_amount_incurred'), models.ScheduleD.amount_incurred_period),
        (('min_image_number', 'max_image_number'), models.ScheduleD.image_number),
        (('min_amount_outstanding_beginning', 'max_amount_outstanding_beginning'),
         models.ScheduleD.outstanding_balance_beginning_of_period),
        (('min_amount_outstanding_close', 'max_amount_outstanding_close'),
         models.ScheduleD.outstanding_balance_close_of_period),
        (('min_amount_outstanding_close', 'max_amount_outstanding_close'),
         models.ScheduleD.outstanding_balance_close_of_period),
        (('min_coverage_start_date', 'max_coverage_start_date'), models.ScheduleD.coverage_start_date),
        (('min_coverage_end_date', 'max_coverage_end_date'), models.ScheduleD.coverage_end_date)
    ]

    filter_match_fields = [
        ('nature_of_debt', models.ScheduleD.nature_of_debt)
    ]

    filter_fulltext_fields = [
        ('creditor_debtor_name', models.ScheduleD.creditor_debtor_name_text),
    ]

    @property
    def args(self):
        return utils.extend(
            args.schedule_d,
            args.paging,
            args.make_sort_args(
                default='-coverage_end_date',
            )
        )

    def build_query(self, **kwargs):
        query = super(ScheduleDView, self).build_query(**kwargs)
        # might be worth looking to factoring these out into the filter script
        if kwargs.get('sub_id'):
            query = query.filter_by(sub_id=int(kwargs.get('sub_id')))
        utils.check_form_line_number(kwargs)
        return query


# Used for '/schedules/schedule_d/<string:sub_id>/'
# under tag: debts
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_d/4101720231805131096/
@doc(
    tags=['debts'],
    description=docs.SCHEDULE_D,
)
class ScheduleDViewBySubId(ApiResource):
    model = models.ScheduleD
    schema = schemas.ScheduleDSchema
    page_schema = schemas.ScheduleDPageSchema

    @property
    def index_column(self):
        return self.model.sub_id

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        query = query.filter_by(sub_id=int(kwargs.get('sub_id')))
        return query

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.make_sort_args(
                default='-coverage_end_date',
            )
        )
