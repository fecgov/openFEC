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
        return self.model.cycle

    @property
    def index_column(self):
        return self.model.sub_id

    filter_multi_fields = [
        ('image_number', models.ScheduleH4.image_number),
        ('spender_committee_name', models.ScheduleH4.spender_committee_name),
        ('spender_committee_type', models.ScheduleH4.spender_committee_type),
        ('spender_committee_designation', models.ScheduleH4.spender_committee_designation),
        ('payee_city', models.ScheduleH4.payee_city),
        ('payee_zip', models.ScheduleH4.payee_zip),
        ('payee_state', models.ScheduleH4.payee_state),
        ('committee_id', models.ScheduleH4.committee_id),
        ('cycle', models.ScheduleH4.cycle),
        ('activity_or_event', models.ScheduleH4.activity_or_event),
        ('report_year', models.ScheduleH4.report_year),
        ('report_type', models.ScheduleH4.report_type),
        ('administrative_voter_drive_activity_indicator',
            models.ScheduleH4.administrative_voter_drive_activity_indicator),
        ('fundraising_activity_indicator', models.ScheduleH4.fundraising_activity_indicator),
        ('exempt_activity_indicator', models.ScheduleH4.exempt_activity_indicator),
        ('direct_candidate_support_activity_indicator', models.ScheduleH4.direct_candidate_support_activity_indicator),
        ('administrative_activity_indicator', models.ScheduleH4.administrative_activity_indicator),
        ('general_voter_drive_activity_indicator', models.ScheduleH4.general_voter_drive_activity_indicator),
        ('public_comm_indicator', models.ScheduleH4.public_comm_indicator),
    ]

    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleH4.event_purpose_date),
        (('min_amount', 'max_amount'), models.ScheduleH4.disbursement_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleH4.image_number),

    ]

    filter_fulltext_fields = [
        ('q_disbursement_purpose', models.ScheduleH4.disbursement_purpose_text),
        ('q_payee_name', models.ScheduleH4.payee_name_text),
    ]

    sort_options = [
        'event_purpose_date',
        'disbursement_amount',
        'payee_name',
        'spender_committee_name',
        'disbursement_purpose',
    ]

    @property
    def args(self):
        return utils.extend(
            args.itemized, args.schedule_h4, args.make_seek_args(),
            args.make_sort_args(
                default='-event_purpose_date',
                validator=args.OptionValidator(self.sort_options),
                show_nulls_last_arg=False,
            ))

    def build_query(self, **kwargs):
        query = super(ScheduleH4View, self).build_query(**kwargs)
        query = query.options(sa.orm.joinedload(models.ScheduleH4.committee))
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


@doc(
    tags=['disbursements'],
    description=docs.EFILING_TAG,
)
class ScheduleH4EfileView(views.ApiResource):
    model = models.ScheduleH4Efile
    schema = schemas.ItemizedScheduleH4filingsSchema
    page_schema = schemas.ScheduleH4EfilePageSchema

    filter_multi_fields = [
        ('image_number', models.ScheduleH4Efile.image_number),
        ('committee_id', models.ScheduleH4Efile.committee_id),
        ('payee_city', models.ScheduleH4Efile.payee_city),
        ('payee_state', models.ScheduleH4Efile.payee_state),
        ('payee_zip', models.ScheduleH4Efile.payee_zip),
    ]

    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleH4Efile.event_purpose_date),
        (('min_amount', 'max_amount'),
         models.ScheduleH4Efile.disbursement_amount),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_h4_efile,
            args.make_sort_args(
                default='-event_purpose_date',
                validator=args.OptionValidator(
                    ['event_purpose_date', 'disbursement_amount']),
            ),
        )
