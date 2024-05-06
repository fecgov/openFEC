import sqlalchemy as sa
from flask_apispec import doc
import re

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.common import models
from webservices.common import views
from webservices.common.views import ItemizedResource
from webservices import exceptions

"""
two years restriction removed from schedule_a. For details, refer:
https://github.com/fecgov/openFEC/issues/3595
"""


# Used for '/schedules/schedule_a/'
# /schedules/schedule_a/<string:sub_id>/
# under tag:'receipts'
# Ex:
# http://127.0.0.1:5000/v1/schedules/schedule_a/?two_year_transaction_period=2020
# http://127.0.0.1:5000/v1/schedules/schedule_a/2071120191659332613/?two_year_transaction_period=2020
@doc(
    tags=['receipts'], description=docs.SCHEDULE_A,
)
class ScheduleAView(ItemizedResource):

    model = models.ScheduleA
    schema = schemas.ScheduleASchema
    page_schema = schemas.ScheduleAPageSchema

    @property
    def year_column(self):
        return self.model.two_year_transaction_period

    @property
    def index_column(self):
        return self.model.sub_id

    @property
    def amount_column(self):
        return self.model.contribution_receipt_amount

    filter_multi_fields = [
        ('image_number', models.ScheduleA.image_number),
        ('committee_id', models.ScheduleA.committee_id),
        ('contributor_id', models.ScheduleA.contributor_id),
        ('contributor_city', models.ScheduleA.contributor_city),
        ('contributor_state', models.ScheduleA.contributor_state),
        ('recipient_committee_type', models.ScheduleA.recipient_committee_type),
        ('recipient_committee_org_type', models.ScheduleA.recipient_committee_org_type),
        (
            'recipient_committee_designation',
            models.ScheduleA.recipient_committee_designation,
        ),
        ('two_year_transaction_period', models.ScheduleA.two_year_transaction_period),
    ]
    filter_match_fields = [
        ('is_individual', models.ScheduleA.is_individual),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleA.contribution_receipt_date),
        (('min_amount', 'max_amount'), models.ScheduleA.contribution_receipt_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleA.image_number),
        (('min_load_date', 'max_load_date'), models.ScheduleA.load_date),
    ]
    filter_fulltext_fields_NA = [
        ('contributor_name',
         models.ScheduleA.contributor_name_text,
         models.ScheduleA.contributor_name),
        ('contributor_employer',
         models.ScheduleA.contributor_employer_text,
         models.ScheduleA.contributor_employer),
        ('contributor_occupation',
         models.ScheduleA.contributor_occupation_text,
         models.ScheduleA.contributor_occupation),
    ]
    filter_multi_start_with_fields = [
        ('contributor_zip', models.ScheduleA.contributor_zip),
    ]
    query_options = [
        sa.orm.joinedload(models.ScheduleA.committee),
        sa.orm.joinedload(models.ScheduleA.contributor),
    ]
    sort_options = [
        'contribution_receipt_date',
        'contribution_receipt_amount',
    ]
    filters_with_max_count = [
        'committee_id',
        'contributor_name',
        'contributor_zip',
        'contributor_city',
        'contributor_employer',
        'contributor_occupation',
    ]
    secondary_index_options = [
        'committee_id',
        'contributor_id',
        'contributor_name',
        'contributor_city',
        'contributor_zip',
        'contributor_employer',
        'contributor_occupation',
        'image_number',
    ]
    use_pk_for_count = True

    @property
    def args(self):
        return utils.extend(
            args.itemized,
            args.schedule_a,
            args.make_seek_args(),
            args.make_sort_args(
                default='-contribution_receipt_date',
                validator=args.OptionValidator(self.sort_options),
                show_nulls_last_arg=False,
            ),
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        query = filters.filter_contributor_type(query, self.model.entity_type, kwargs)
        zip_list = []
        if kwargs.get('contributor_zip'):
            for value in kwargs['contributor_zip']:
                if re.search('[^a-zA-Z0-9-\s]', value):  # noqa
                    raise exceptions.ApiError(
                        'Invalid zip code. It can not have special character',
                        status_code=422,
                    )
                else:
                    zip_list.append(value[:5])
            contributor_zip_list = {'contributor_zip': zip_list}
            query = filters.filter_multi_start_with(
                query, contributor_zip_list, self.filter_multi_start_with_fields
            )
        if kwargs.get('sub_id'):
            query = query.filter_by(sub_id=int(kwargs.get('sub_id')))
        if kwargs.get('line_number'):
            # line_number is a composite value of 'filing_form-line_number'
            if len(kwargs.get('line_number').split('-')) == 2:
                form, line_no = kwargs.get('line_number').split('-')
                query = query.filter_by(filing_form=form.upper())
                query = query.filter_by(line_number=line_no)
            else:
                raise exceptions.ApiError(
                    exceptions.LINE_NUMBER_ERROR, status_code=400,
                )
        return query


# Used for '/schedules/schedule_a/efile/'
# under tag:'receipts'
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_a/efile/
@doc(
    tags=['receipts'], description=docs.EFILING_TAG,
)
class ScheduleAEfileView(views.ApiResource):
    model = models.ScheduleAEfile
    schema = schemas.ItemizedScheduleAfilingsSchema
    page_schema = schemas.ScheduleAEfilePageSchema

    filter_multi_fields = [
        ('image_number', models.ScheduleAEfile.image_number),
        ('committee_id', models.ScheduleAEfile.committee_id),
        ('contributor_city', models.ScheduleAEfile.contributor_city),
        ('contributor_state', models.ScheduleAEfile.contributor_state),
    ]

    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleAEfile.contribution_receipt_date),
        (
            ('min_amount', 'max_amount'),
            models.ScheduleAEfile.contribution_receipt_amount,
        ),
        (('min_image_number', 'max_image_number'), models.ScheduleAEfile.image_number),
    ]

    filter_fulltext_fields = [
        ('contributor_name', models.ScheduleAEfile.contributor_name_text),
        ('contributor_employer', models.ScheduleAEfile.contributor_employer_text),
        ('contributor_occupation', models.ScheduleAEfile.contributor_occupation_text),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_a_e_file,
            args.itemized,
            args.make_sort_args(
                default='-contribution_receipt_date',
                validator=args.OptionValidator(
                    [
                        'contribution_receipt_date',
                        'contribution_receipt_amount',
                    ]
                ),
            ),
        )
