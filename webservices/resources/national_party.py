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
    tags=['national party'],
    description=docs.NATIONAL_PARTY,
)
class NationalParty_ScheduleAView(ApiResource):

    model = models.NationalParty_ScheduleA
    schema = schemas.NationalPartyScheduleASchema
    page_schema = schemas.NationalPartyScheduleAPageSchema

    filter_match_fields = [
        ('is_individual', models.NationalParty_ScheduleA.is_individual),
    ]

    filter_fulltext_fields = [
        ('contributor_name', models.NationalParty_ScheduleA.contributor_name_text),
        ('contributor_employer', models.NationalParty_ScheduleA.contributor_employer_text),
        ('contributor_occupation', models.NationalParty_ScheduleA.contributor_occupation_text),
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
        ('committee_contributor_type', models.NationalParty_ScheduleA.committee_contributor_type),
        ('committee_contributor_organization', models.NationalParty_ScheduleA.committee_contributor_organization),
        ('committee_contributor_designation', models.NationalParty_ScheduleA.committee_contributor_designation),
        ('two_year_transaction_period', models.NationalParty_ScheduleA.two_year_transaction_period),
        ('party_account_type', models.NationalParty_ScheduleA.party_account_type),
        ('party_account_receipt_type', models.NationalParty_ScheduleA.party_account_receipt_type),
    ]

    sort_options = [
        'contribution_receipt_date',
        'contribution_receipt_amount',
    ]

    filter_range_fields = [
        (('min_date', 'max_date'), models.NationalParty_ScheduleA.contribution_receipt_date),
        (('min_amount', 'max_amount'), models.NationalParty_ScheduleA.contribution_receipt_amount),
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


# used for endpoint: '/national_party/schedule_b/'
# under tag: national party
# Ex: http://127.0.0.1:5000/v1/national_party/schedule_b/
# @doc(
#     tags=['national party'],
#     description=docs.NATIONAL_PARTY,
# )
# class NationalParty_ScheduleBView(ApiResource):

#     model = models.NationalParty_ScheduleB
#     schema = schemas.NationalPartyScheduleBSchema
#     page_schema = schemas.NationalPartyScheduleBPageSchema

#     filter_match_fields = [
#         ('is_individual', models.NationalParty_ScheduleA.is_individual),
#     ]

#     filter_fulltext_fields = [
#         ('contributor_name', models.NationalParty_ScheduleA.contributor_name_text),
#         ('contributor_employer', models.NationalParty_ScheduleA.contributor_employer_text),
#         ('contributor_occupation', models.NationalParty_ScheduleA.contributor_occupation_text),
#     ]

#     filter_multi_start_with_fields = [
#         ('contributor_zip', models.NationalParty_ScheduleA.contributor_zip),
#     ]

#     filter_multi_fields = [
#         ('image_number', models.NationalParty_ScheduleA.image_number),
#         ('committee_id', models.NationalParty_ScheduleA.committee_id),
#         ('contributor_id', models.NationalParty_ScheduleA.contributor_id),
#         ('contributor_city', models.NationalParty_ScheduleA.contributor_city),
#         ('contributor_state', models.NationalParty_ScheduleA.contributor_state),
#         ('committee_contributor_type', models.NationalParty_ScheduleA.committee_contributor_type),
#         ('committee_contributor_organization', models.NationalParty_ScheduleA.committee_contributor_organization),
#         ('committee_contributor_designation', models.NationalParty_ScheduleA.committee_contributor_designation),
#         ('two_year_transaction_period', models.NationalParty_ScheduleA.two_year_transaction_period),
#         ('party_account_type', models.NationalParty_ScheduleA.party_account),
#         ('party_account_receipt_type', models.NationalParty_ScheduleA.receipt_type),
#     ]

#     sort_options = [
#         'contribution_receipt_date',
#         'contribution_receipt_amount',
#     ]

#     filter_range_fields = [
#         (('min_date', 'max_date'), models.NationalParty_ScheduleA.contribution_receipt_date),
#         (('min_amount', 'max_amount'), models.NationalParty_ScheduleA.contribution_receipt_amount),
#     ]

#     @property
#     def args(self):
#         return utils.extend(
#             args.paging,
#             args.national_party_schedule_a,
#             args.make_sort_args(
#                 default='-contribution_receipt_date',
#                 validator=args.OptionValidator(self.sort_options),
#                 show_nulls_last_arg=False,
#             ),
#         )

#     def build_query(self, **kwargs):
#         query = super().build_query(**kwargs)
#         query = filters.filter_contributor_type(query, self.model.entity_type, kwargs)
#         zip_list = []
#         if kwargs.get('contributor_zip'):
#             for value in kwargs['contributor_zip']:
#                 if re.search('[^a-zA-Z0-9-\s]', value):  # noqa
#                     raise exceptions.ApiError(
#                         'Invalid zip code. It can not have special character',
#                         status_code=422,
#                     )
#                 else:
#                     zip_list.append(value[:5])
#             contributor_zip_list = {'contributor_zip': zip_list}
#             query = filters.filter_multi_start_with(
#                 query, contributor_zip_list, self.filter_multi_start_with_fields
#             )

#         if kwargs.get('line_number'):
#             # line_number is a composite value of 'filing_form-line_number'
#             if len(kwargs.get('line_number').split('-')) == 2:
#                 form, line_no = kwargs.get('line_number').split('-')
#                 query = query.filter_by(filing_form=form.upper())
#                 query = query.filter_by(line_number=line_no)
#             else:
#                 raise exceptions.ApiError(
#                     exceptions.LINE_NUMBER_ERROR, status_code=400,
#                 )
#         return query
