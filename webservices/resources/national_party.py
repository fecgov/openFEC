import re
from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices import exceptions
from webservices.common import models
from webservices.common.views import ApiResource


# used for endpoint: '/national_party/schedule_a/'
# under tag: national party
# Ex: http://127.0.0.1:5000/v1/national_party/schedule_a/
@doc(
    tags=['national party accounts'],
    description=docs.NATIONAL_PARTY_SCHED_A,
)
class NationalParty_ScheduleAView(ApiResource):

    model = models.NationalParty_ScheduleA
    schema = schemas.NationalPartyScheduleASchema
    page_schema = schemas.NationalPartyScheduleAPageSchema

    filter_match_fields = [
        ('is_individual', models.NationalParty_ScheduleA.is_individual),
    ]

    filter_fulltext_fields_NA = [
        ('contributor_name', models.NationalParty_ScheduleA.contributor_name_text,
            models.NationalParty_ScheduleA.contributor_name),
        ('contributor_employer', models.NationalParty_ScheduleA.contributor_employer_text,
            models.NationalParty_ScheduleA.contributor_employer),
        ('contributor_occupation', models.NationalParty_ScheduleA.contributor_occupation_text,
            models.NationalParty_ScheduleA.contributor_occupation),
    ]

    filter_multi_start_with_fields = [
        ('contributor_zip', models.NationalParty_ScheduleA.contributor_zip),
    ]

    filter_multi_fields = [
        ('image_number', models.NationalParty_ScheduleA.image_number),
        ('committee_id', models.NationalParty_ScheduleA.committee_id),
        ('contributor_id', models.NationalParty_ScheduleA.contributor_id),
        ('contributor_city', models.NationalParty_ScheduleA.contributor_city),
        ('contributor_state', models.NationalParty_ScheduleA.contributor_state),
        ('contributor_committee_type', models.NationalParty_ScheduleA.contributor_committee_type),
        ('contributor_committee_organization', models.NationalParty_ScheduleA.contributor_committee_organization),
        ('contributor_committee_designation', models.NationalParty_ScheduleA.contributor_committee_designation),
        ('two_year_transaction_period', models.NationalParty_ScheduleA.two_year_transaction_period),
        ('party_account_type', models.NationalParty_ScheduleA.party_account_type),
        ('receipt_type', models.NationalParty_ScheduleA.receipt_type),
    ]

    sort_options = [
        'contribution_receipt_date',
        'contribution_receipt_amount',
    ]

    filter_range_fields = [
        (('min_contribution_receipt_date', 'max_contribution_receipt_date'),
            models.NationalParty_ScheduleA.contribution_receipt_date),
        (('min_contribution_receipt_amount', 'max_contribution_receipt_amount'),
            models.NationalParty_ScheduleA.contribution_receipt_amount),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.national_party_schedule_a,
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
        return query


# used for endpoint: '/national_party/schedule_b/'
# under tag: national party
# Ex: http://127.0.0.1:5000/v1/national_party/schedule_b/
@doc(
    tags=['national party accounts'],
    description=docs.NATIONAL_PARTY_SCHED_B,
)
class NationalParty_ScheduleBView(ApiResource):

    model = models.NationalParty_ScheduleB
    schema = schemas.NationalPartyScheduleBSchema
    page_schema = schemas.NationalPartyScheduleBPageSchema

    filter_fulltext_fields_NA = [
        ('disbursement_description', models.NationalParty_ScheduleB.disbursement_description_text,
            models.NationalParty_ScheduleB.disbursement_description),
        ('recipient_name', models.NationalParty_ScheduleB.recipient_name_text,
            models.NationalParty_ScheduleB.recipient_name),
    ]

    filter_multi_start_with_fields = [
        ('recipient_zip', models.NationalParty_ScheduleB.recipient_zip),
    ]

    filter_multi_fields = [
        ('image_number', models.NationalParty_ScheduleB.image_number),
        ('committee_id', models.NationalParty_ScheduleB.committee_id),
        ('recipient_city', models.NationalParty_ScheduleB.recipient_city),
        ('recipient_state', models.NationalParty_ScheduleB.recipient_state),
        ('recipient_committee_id', models.NationalParty_ScheduleB.recipient_committee_id),
        ('disbursement_purpose_category',
         models.NationalParty_ScheduleB.disbursement_purpose_category),
        ('spender_committee_type', models.NationalParty_ScheduleB.spender_committee_type),
        ('spender_committee_designation', models.NationalParty_ScheduleB.spender_committee_designation),
        ('two_year_transaction_period',
         models.NationalParty_ScheduleB.two_year_transaction_period),
        ('party_account_type', models.NationalParty_ScheduleB.party_account),
        ('disbursement_type', models.NationalParty_ScheduleB.disbursement_type),
    ]
    sort_options = [
        'disbursement_amount',
        'disbursement_date',
    ]

    filter_range_fields = [
        (('min_disbursement_amount', 'max_disbursement_amount'), models.NationalParty_ScheduleB.disbursement_amount),
        (('min_disbursement_date', 'max_disbursement_date'), models.NationalParty_ScheduleB.disbursement_date),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.national_party_schedule_b,
            args.make_sort_args(
                default='-disbursement_date',
                validator=args.OptionValidator(self.sort_options),
                show_nulls_last_arg=False,
            ),
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        query = filters.filter_contributor_type(query, self.model.entity_type, kwargs)
        zip_list = []
        if kwargs.get('recipient_zip'):
            for value in kwargs['recipient_zip']:
                if re.search('[^a-zA-Z0-9-\s]', value):  # noqa
                    raise exceptions.ApiError(
                        'Invalid zip code. It can not have special character',
                        status_code=422,
                    )
                else:
                    zip_list.append(value[:5])
            recipient_zip_list = {'recipient_zip': zip_list}
            query = filters.filter_multi_start_with(
                query, recipient_zip_list, self.filter_multi_start_with_fields
            )
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
