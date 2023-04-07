import sqlalchemy as sa
from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
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
        ('payee_city', models.ScheduleH4.payee_city),
        ('payee_zip', models.ScheduleH4.payee_zip),
        ('payee_state', models.ScheduleH4.payee_state),
        ('committee_id', models.ScheduleH4.committee_id),
        ('cycle', models.ScheduleH4.cycle),
    ]

    filter_fulltext_fields = [
        ('q_disbursement_purpose', models.ScheduleH4.disbursement_purpose_text),
        ('q_payee_name', models.ScheduleH4.payee_name_text),
    ]

    sort_options = ['event_purpose_date', 'disbursement_amount']

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
