
from flask_apispec import doc
from sqlalchemy.orm import aliased, contains_eager
from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common import views
from webservices.common.views import ItemizedResource
from webservices import exceptions

# maybe refractor to use database table later.
FILER_COMMITTEE_TYPES = {
    2018: ['D', 'E', 'H', 'I', 'N', 'O', 'P', 'Q', 'S', 'U', 'V', 'W', 'X', 'Y'],
    2016: ['D', 'E', 'H', 'N', 'O', 'P', 'Q', 'S', 'U', 'V', 'W', 'X', 'Y'],
    2014: ['D', 'E', 'H', 'N', 'O', 'P', 'Q', 'S', 'U', 'V', 'W', 'X', 'Y'],
    2012: ['D', 'E', 'H', 'N', 'O', 'P', 'Q', 'S', 'U', 'V', 'W', 'X', 'Y'],
    2010: ['E', 'H', 'N', 'O', 'P', 'Q', 'S', 'U', 'X', 'Y'],
    2008: ['D', 'E', 'H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y'],
    2006: ['C', 'E', 'H', 'I', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y'],
    2004: ['C', 'D', 'E', 'H', 'I', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y', 'Z'],
    2002: ['C', 'D', 'H', 'I', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y', 'Z'],
    2000: ['D', 'H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y', 'Z'],
    1998: ['H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y', 'Z'],
    1996: ['D', 'H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y', 'Z'],
    1994: ['H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y', 'Z'],
    1992: ['H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y', 'Z'],
    1990: ['H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y'],
    1988: ['D', 'H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y'],
    1986: ['D', 'H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y'],
    1984: ['D', 'H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y'],
    1982: ['C', 'D', 'H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y'],
    1980: ['C', 'D', 'H', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y'],
    1978: ['H', 'I', 'N', 'P', 'Q', 'S', 'U', 'X', 'Y'],
    1976: ['H', 'N', 'P', 'Q', 'S', 'X', 'Y']
}

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
        ('disbursement_purpose_category', models.ScheduleB.disbursement_purpose_category),
    ]
    filter_match_fields = [
        ('two_year_transaction_period', models.ScheduleB.two_year_transaction_period),
    ]
    filter_fulltext_fields = [
        ('recipient_name', models.ScheduleB.recipient_name_text),
        ('disbursement_description', models.ScheduleB.disbursement_description_text),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleB.disbursement_date),
        (('min_amount', 'max_amount'), models.ScheduleB.disbursement_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleB.image_number),
    ]

    @property
    def args(self):
        return utils.extend(
            args.itemized,
            args.schedule_b,
            args.make_seek_args(),
            args.make_sort_args(
                default='-disbursement_date',
                validator=args.OptionValidator(['disbursement_date', 'disbursement_amount']),
            )
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)

        filer_committee_history_alias = aliased(models.CommitteeHistory)
        recipient_committee_history_alias = aliased(models.CommitteeHistory)

        query = query.outerjoin(filer_committee_history_alias, self.model.committee)
        query = query.options(contains_eager(self.model.committee, alias=filer_committee_history_alias))

        query = query.outerjoin(recipient_committee_history_alias, self.model.recipient_committee)
        query = query.options(contains_eager(self.model.recipient_committee, alias=recipient_committee_history_alias))

        if kwargs.get('committee_type') and kwargs.get('committee_type') != 'null':
            committee_type_list = []
            committee_type_list = FILER_COMMITTEE_TYPES.get(kwargs.get('two_year_transaction_period'))
            if kwargs.get('committee_type') in committee_type_list:
                query = query.filter(filer_committee_history_alias.committee_type == kwargs.get('committee_type'))
            else:
                raise exceptions.ApiError(
                    'No result for this committee type.',
                    status_code=400,
                )

        #might be worth looking to factoring these out into the filter script
        if kwargs.get('sub_id'):
            query = query.filter(self.model.sub_id == int(kwargs.get('sub_id')))

        if kwargs.get('line_number'):
            if len(kwargs.get('line_number').split('-')) == 2:
                form, line_no = kwargs.get('line_number').split('-')
                query = query.filter(self.model.filing_form == form.upper())
                query = query.filter(self.model.line_number == line_no)

        return query


@doc(
    tags=['disbursements'],
    description=docs.EFILING_TAG
)
class ScheduleBEfileView(views.ApiResource):
    model = models.ScheduleBEfile
    schema = schemas.ItemizedScheduleBfilingsSchema
    page_schema = schemas.ScheduleBEfilePageSchema

    filter_multi_fields = [
        ('image_number', models.ScheduleBEfile.image_number),
        ('committee_id', models.ScheduleBEfile.committee_id),
        ('recipient_city', models.ScheduleBEfile.recipient_city),
        ('recipient_state', models.ScheduleBEfile.recipient_state),
        #('recipient_committee_id', models.ScheduleBEfile.recipient_committee_id),
        #('disbursement_purpose_category', models.ScheduleB.disbursement_purpose_category),
    ]

    filter_fulltext_fields = [
        #('recipient_name', models.ScheduleB.recipient_name_text),
        ('disbursement_description', models.ScheduleBEfile.disbursement_description),
    ]

    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleBEfile.disbursement_date),
        (('min_amount', 'max_amount'), models.ScheduleBEfile.disbursement_amount),
        #(('min_image_number', 'max_image_number'), models.ScheduleBE.image_number),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.schedule_b_efile,
            args.make_sort_args(
                default='-disbursement_date',
                validator=args.OptionValidator(['disbursement_date', 'disbursement_amount']),
            ),
        )
