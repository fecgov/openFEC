from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import exceptions
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


@doc(
    tags=['party-coordinated expenditures'],
    description=docs.SCHEDULE_F,
)
class ScheduleFView(ApiResource):

    model = models.ScheduleF
    schema = schemas.ScheduleFSchema
    page_schema = schemas.ScheduleFPageSchema

    @property
    def index_column(self):
        return self.model.sub_id

    filter_multi_fields = [
        ('image_number', models.ScheduleF.image_number),
        ('committee_id', models.ScheduleF.committee_id),
        ('candidate_id', models.ScheduleF.candidate_id),
        ('cycle', models.ScheduleF.election_cycle),
        ('form_line_number', models.ScheduleF.form_line_number),
    ]

    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleF.expenditure_date),
        (('min_amount', 'max_amount'), models.ScheduleF.expenditure_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleF.image_number),
    ]

    filter_fulltext_fields = [
        ('payee_name', models.ScheduleF.payee_name_text)
    ]

    @property
    def args(self):
        return utils.extend(
            args.itemized,
            args.schedule_f,
            args.paging,
            args.make_sort_args(
                default='expenditure_date',
            )
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        if kwargs.get('sub_id'):
            query = query.filter_by(sub_id=int(kwargs.get('sub_id')))
        if 'form_line_number' in kwargs:
            for each in kwargs['form_line_number']:
                if each.startswith('-'):
                    each = each[1:]
                if len(each.split('-')) != 2:
                    raise exceptions.ApiError(
                        exceptions.FORM_LINE_NUMBER_ERROR, status_code=400
                    )
        # added to help with transition to the new form_line_number, to be removed
        if 'line_number' in kwargs:
            raise exceptions.ApiError(
                exceptions.LINE_NUMBER_ERROR, status_code=400
            )
        return query


@doc(
    tags=['party-coordinated expenditures'],
    description=docs.SCHEDULE_F,
)
class ScheduleFViewBySubId(ApiResource):
    model = models.ScheduleF
    schema = schemas.ScheduleFSchema
    page_schema = schemas.ScheduleFPageSchema

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
        )
