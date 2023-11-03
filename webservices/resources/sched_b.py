import sqlalchemy as sa
from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common import views
from webservices.common.views import ItemizedResource
from webservices import exceptions
"""
two years restriction removed from schedule_b. For details, refer:
https://github.com/fecgov/openFEC/issues/3595
"""


# Used for '/schedules/schedule_b/'
# '/schedules/schedule_b/<string:sub_id>/'
# under tag: disbursements
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_b/
# http://127.0.0.1:5000/v1/schedules/schedule_b/4123120201987370164/
@doc(
    tags=['disbursements'],
    description=docs.SCHEDULE_B,
)
class ScheduleBView(ItemizedResource):

    model = models.ScheduleB
    schema = schemas.ScheduleBSchema
    page_schema = schemas.ScheduleBPageSchema

    @property
    def year_column(self):
        return self.model.two_year_transaction_period

    @property
    def index_column(self):
        return self.model.sub_id

    filter_multi_fields = [
        ('image_number', models.ScheduleB.image_number),
        ('committee_id', models.ScheduleB.committee_id),
        ('recipient_city', models.ScheduleB.recipient_city),
        ('recipient_state', models.ScheduleB.recipient_state),
        ('recipient_committee_id', models.ScheduleB.recipient_committee_id),
        ('disbursement_purpose_category',
         models.ScheduleB.disbursement_purpose_category),
        ('spender_committee_type', models.ScheduleB.spender_committee_type),
        ('spender_committee_org_type', models.ScheduleB.spender_committee_org_type),
        ('spender_committee_designation', models.ScheduleB.spender_committee_designation),
        ('two_year_transaction_period',
         models.ScheduleB.two_year_transaction_period),
    ]
    filter_fulltext_fields = [
        ('recipient_name', models.ScheduleB.recipient_name_text),
        ('disbursement_description',
         models.ScheduleB.disbursement_description_text),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleB.disbursement_date),
        (('min_amount', 'max_amount'), models.ScheduleB.disbursement_amount),
        (('min_image_number', 'max_image_number'),
         models.ScheduleB.image_number),
    ]
    sort_options = ['disbursement_date', 'disbursement_amount']
    filters_with_max_count = [
        'committee_id',
        'recipient_name',
        'recipient_city',
    ]
    use_pk_for_count = True
    query_options = [
        sa.orm.joinedload(models.ScheduleB.committee),
        sa.orm.joinedload(models.ScheduleB.recipient_committee),
    ]

    @property
    def args(self):
        return utils.extend(
            args.itemized, args.schedule_b, args.make_seek_args(),
            args.make_sort_args(
                default='-disbursement_date',
                validator=args.OptionValidator(self.sort_options),
                show_nulls_last_arg=False,
            ))

    def build_query(self, **kwargs):
        query = super(ScheduleBView, self).build_query(**kwargs)
        # might be worth looking to factoring these out into the filter script
        if kwargs.get('sub_id'):
            query = query.filter_by(sub_id=int(kwargs.get('sub_id')))
        if kwargs.get('line_number'):
            # line number is a composite value of 'filing_form-line_number'
            if len(kwargs.get('line_number').split('-')) == 2:
                form, line_no = kwargs.get('line_number').split('-')
                query = query.filter_by(filing_form=form.upper())
                query = query.filter_by(line_number=line_no)
            else:
                raise exceptions.ApiError(
                    exceptions.LINE_NUMBER_ERROR,
                    status_code=400,
                )
        return query


# Used for '/schedules/schedule_b/efile/'
# under tag: disbursements
# Ex: http://127.0.0.1:5000/v1/schedules/schedule_b/efile/
@doc(tags=['disbursements'], description=docs.EFILING_TAG)
class ScheduleBEfileView(views.ApiResource):
    model = models.ScheduleBEfile
    schema = schemas.ItemizedScheduleBfilingsSchema
    page_schema = schemas.ScheduleBEfilePageSchema

    filter_multi_fields = [
        ('image_number', models.ScheduleBEfile.image_number),
        ('committee_id', models.ScheduleBEfile.committee_id),
        ('recipient_city', models.ScheduleBEfile.recipient_city),
        ('recipient_state', models.ScheduleBEfile.recipient_state),
    ]

    filter_fulltext_fields = [
        ('disbursement_description',
         models.ScheduleBEfile.disbursement_description),
    ]

    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleBEfile.disbursement_date),
        (('min_amount', 'max_amount'),
         models.ScheduleBEfile.disbursement_amount),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_b_efile,
            args.make_sort_args(
                default='-disbursement_date',
                validator=args.OptionValidator(
                    ['disbursement_date', 'disbursement_amount']),
            ),
        )
