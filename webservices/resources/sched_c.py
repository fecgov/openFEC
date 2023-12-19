"""Schedule C shows all loans, endorsements and loan guarantees a committee receives or makes."""
from flask_apispec import doc
from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


# Used for '/schedules/schedule_c/'
# under tag: loans
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_c/
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
        ('form_line_number', models.ScheduleC.form_line_number),
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
        utils.check_form_line_number(kwargs)
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


# Used for '/schedules/schedule_c/<string:sub_id>/'
# under tag: loans
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_c/4101720231804739584/
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
