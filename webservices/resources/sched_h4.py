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
    description=docs.SCHEDULE_H4,
)
class ScheduleH4View(ItemizedResource):

    model = models.ScheduleH4
    schema = schemas.ScheduleH4Schema
    page_schema = schemas.ScheduleH4PageSchema

    @property
    def year_column(self):
        return self.model.two_year_transaction_period

    @property
    def index_column(self):
        return self.model.sub_id

    filter_multi_fields = [
        ('image_number', models.ScheduleH4.image_number),
        ('committee_id', models.ScheduleH4.committee_id),
        ('payee_city', models.ScheduleH4.payee_city),
        ('payee_state', models.ScheduleH4.payee_state),
        ('conduit_committee_id', models.ScheduleH4.conduit_committee_id),
        ('event_purpose_category_type', models.ScheduleH4.event_purpose_category_type),
        # ('spender_committee_type', models.ScheduleH4.spender_committee_type),
        # ('spender_committee_org_type', models.ScheduleH4.spender_committee_org_type),
        # ('spender_committee_designation', models.ScheduleH4.spender_committee_designation),
        # ('two_year_transaction_period',
        #  models.ScheduleH4.two_year_transaction_period),
    ]
    filter_fulltext_fields = [
        # ('payee_name', models.ScheduleH4.payee_name_text),
        ('disbursement_description', models.ScheduleH4.disbursement_type_full),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleH4.event_purpose_date),
        (('min_amount', 'max_amount'), models.ScheduleH4.disbursement_amount),
        (('min_image_number', 'max_image_number'),
         models.ScheduleH4.image_number),
    ]

    @property
    def args(self):
        return utils.extend(
            args.itemized, args.schedule_h4, args.make_seek_args(),
            args.make_sort_args(
                default='-event_purpose_date',
                validator=args.OptionValidator(
                    ['event_purpose_date', 'disbursement_amount']),
                show_nulls_last_arg=False,
            ))

    def build_query(self, **kwargs):
        query = super(ScheduleH4View, self).build_query(**kwargs)
        # query = query.options(sa.orm.joinedload(models.ScheduleH4.committee))
        # query = query.options(
        #     sa.orm.joinedload(models.ScheduleH4.recipient_committee))
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
