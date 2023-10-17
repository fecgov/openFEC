"""Schedule C shows all loans, endorsements and loan guarantees a committee receives or makes."""
from flask_apispec import doc
from webservices import args
from webservices import docs
from webservices import exceptions
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


@doc(
    tags=['loans'],
    description=docs.SCHEDULE_C,
)
class ScheduleCView(ApiResource):

    model = models.ScheduleC
    schema = schemas.ScheduleCSchema
    page_schema = schemas.ScheduleCPageSchema

    @property
    def index_column(self):
        return self.model.sub_id

    filter_multi_fields = [
        ('image_number', models.ScheduleC.image_number),
        ('committee_id', models.ScheduleC.committee_id),
        ('line_number', models.ScheduleC.line_number),

    ]

    filter_fulltext_fields = [
        ('loan_source_name', models.ScheduleC.loan_source_name_text),
        ('candidate_name', models.ScheduleC.candidate_name_text),
    ]

    filter_range_fields = [
        (('min_incurred_date', 'max_incurred_date'), models.ScheduleC.incurred_date),
        (('min_amount', 'max_amount'), models.ScheduleC.original_loan_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleC.image_number),
        (('min_payment_to_date', 'max_payment_to_date'), models.ScheduleC.payment_to_date),
    ]

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        if 'line_number' in kwargs:
            for each in kwargs['line_number']:
                if len(each.split('-')) != 2:
                    raise exceptions.ApiError(
                        exceptions.LINE_NUMBER_ERROR, status_code=400
                    )
        return query

    @property
    def args(self):
        return utils.extend(
            args.schedule_c,
            args.paging,
            args.make_seek_args(),
            args.make_sort_args(
                default='-incurred_date',
                validator=args.OptionValidator([
                    'incurred_date',
                    'payment_to_date',
                    'original_loan_amount',
                ]),
                default_sort_nulls_last=True,
            )
        )


@doc(
    tags=['loans'],
    description=docs.SCHEDULE_C,
)
class ScheduleCViewBySubId(ApiResource):
    model = models.ScheduleC
    schema = schemas.ScheduleCSchema
    page_schema = schemas.ScheduleCPageSchema

    @property
    def index_column(self):
        return self.model.sub_id

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        query = query.filter_by(sub_id=int(kwargs.get('sub_id')))
        return query

    @property
    def args(self):
        """
        needed to attach a page, trivial since length is one,
        but can't build this view without a pageschema
        """
        return utils.extend(
            args.paging,
            args.make_sort_args(),
        )
