import sqlalchemy as sa
from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.common import models
from webservices.common.views import ItemizedResource


@doc(
    tags=['loans'],
    description=docs.SCHEDULE_C,
)
class ScheduleCView(ItemizedResource):

    model = models.ScheduleC
    schema = schemas.ScheduleCSchema
    page_schema = schemas.ScheduleCPageSchema
    """
    @property
    def year_column(self):
        return self.model.two_year_transaction_period
    """
    @property
    def index_column(self):
        return self.model.sub_id

    filter_multi_fields = [
        ('image_number', models.ScheduleC.image_number),
        ('committee_id', models.ScheduleC.committee_id),
    ]

    filter_fulltext_fields = [
        ('loaner_name', models.ScheduleC.loan_source_name),
    ]

    """
    filter_match_fields = [
        ('is_individual', models.ScheduleA.is_individual),
        ('two_year_transaction_period', models.ScheduleA.two_year_transaction_period),
    ]


    query_options = [
        sa.orm.joinedload(models.ScheduleA.committee),
        sa.orm.joinedload(models.ScheduleA.contributor),
    ]
    """
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleC.incurred_date),
        (('min_amount', 'max_amount'), models.ScheduleC.original_loan_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleC.image_number),
        (('min_payment_to_date', 'max_payment_to_date'), models.ScheduleC.payment_to_date),
    ]

    @property
    def args(self):
        return utils.extend(
            args.itemized,
            args.schedule_c,
            args.make_seek_args(),
            args.make_sort_args(
                default='incurred_date',
            )
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        #query = filters.filter_contributor_type(query, self.model.entity_type, kwargs)
        if kwargs.get('sub_id'):
            query = query.filter_by(sub_id= int(kwargs.get('sub_id')))
        return query

