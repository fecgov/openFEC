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


@doc(
    tags=['disbursements'],
    description=docs.SCHEDULE_H,
)
class ScheduleHView(ItemizedResource):

    model = models.ScheduleH
    schema = schemas.ScheduleHSchema
    page_schema = schemas.ScheduleHPageSchema

    @property
    def year_column(self):
        return self.model.two_year_transaction_period

    @property
    def index_column(self):
        return self.model.sub_id

    filter_multi_fields = [
        ('image_number', models.ScheduleH.image_number),
        ('committee_id', models.ScheduleH.committee_id),
        ('recipient_city', models.ScheduleH.recipient_city),
        ('recipient_state', models.ScheduleH.recipient_state),
        ('recipient_committee_id', models.ScheduleH.recipient_committee_id),
        ('disbursement_purpose_category',
         models.ScheduleH.disbursement_purpose_category),
        ('spender_committee_type', models.ScheduleH.spender_committee_type),
        ('spender_committee_org_type', models.ScheduleH.spender_committee_org_type),
        ('spender_committee_designation', models.ScheduleH.spender_committee_designation),
        ('two_year_transaction_period',
         models.ScheduleH.two_year_transaction_period),
    ]
    filter_fulltext_fields = [
        ('recipient_name', models.ScheduleH.recipient_name_text),
        ('disbursement_description',
         models.ScheduleH.disbursement_description_text),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleH.disbursement_date),
        (('min_amount', 'max_amount'), models.ScheduleH.disbursement_amount),
        (('min_image_number', 'max_image_number'),
         models.ScheduleH.image_number),
    ]

    @property
    def args(self):
        return utils.extend(
            args.itemized, args.schedule_h, args.make_seek_args(),
            args.make_sort_args(
                default='-disbursement_date',
                validator=args.OptionValidator(
                    ['disbursement_date', 'disbursement_amount']),
                show_nulls_last_arg=False,
            ))

    def build_query(self, **kwargs):
        query = super(ScheduleHView, self).build_query(**kwargs)
        query = query.options(sa.orm.joinedload(models.ScheduleH.committee))
        query = query.options(
            sa.orm.joinedload(models.ScheduleH.recipient_committee))
        #might be worth looking to factoring these out into the filter script
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
