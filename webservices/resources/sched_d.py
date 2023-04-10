from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


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
        ('candidate_id', models.ScheduleD.candidate_id),
    ]

    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleD.load_date),
        (('min_payment_period', 'max_payment_period'), models.ScheduleD.payment_period),
        (('min_amount_incurred', 'max_amount_incurred'), models.ScheduleD.amount_incurred_period),
        (('min_image_number', 'max_image_number'), models.ScheduleD.image_number),
        (('min_amount_outstanding_beginning', 'max_amount_outstanding_beginning'), models.ScheduleD.outstanding_balance_beginning_of_period),
        (('min_amount_outstanding_close', 'max_amount_outstanding_close'), models.ScheduleD.outstanding_balance_close_of_period),
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
                default='load_date',
            )
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        if kwargs.get('sub_id'):
            query = query.filter_by(sub_id=int(kwargs.get('sub_id')))
        return query


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
                default='load_date',
            )
        )
