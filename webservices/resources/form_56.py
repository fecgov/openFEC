from flask_apispec import doc
import re

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.common import models
from webservices.common.views import ItemizedResource
from webservices import exceptions


# Used for '/schedules/form5a/'
# under tag:'receipts'
# Ex:
# http://127.0.0.1:5000/v1/schedules/schedule_a/?two_year_transaction_period=2020
# http://127.0.0.1:5000/v1/schedules/schedule_a/2071120191659332613/?two_year_transaction_period=2020
@doc(
    tags=['receipts'], description=docs.FORM_56,
)
class Form5View(ItemizedResource):

    model = models.Form56
    schema = schemas.Form5Schema
    page_schema = schemas.Form5PageSchema

    @property
    def year_column(self):
        return self.model.election_cycle

    @property
    def index_column(self):
        return self.model.sub_id

    @property
    def amount_column(self):
        return self.model.contribution_amount

    filter_multi_fields = [
        ('image_number', models.Form56.image_number),
        ('contributor_city', models.Form56.contributor_city),
        ('contributor_state', models.Form56.contributor_state),
        # ('election_cycle', models.Form56.election_cycle),
        ('contributor_zip', models.Form56.contributor_zip),
        ('report_year', models.Form56.report_year),
        ('report_type', models.Form56.report_type),
    ]
    """ filter_match_fields = [
        ('is_individual', models.Form56.is_individual),
    ] """
    filter_range_fields = [
        (('min_date', 'max_date'), models.Form56.contribution_receipt_date),
        (('min_amount', 'max_amount'), models.Form56.contribution_amount),
        (('min_image_number', 'max_image_number'), models.Form56.image_number),
        (('min_load_date', 'max_load_date'), models.Form56.load_date),
    ]
    filter_fulltext_fields_NA = [
        ('contributor_name',
         models.Form56.contributor_name_text,
         models.Form56.contributor_name),
        ('contributor_employer',
         models.Form56.contributor_employer_text,
         models.Form56.contributor_employer),
        ('contributor_occupation',
         models.Form56.contributor_occupation_text,
         models.Form56.contributor_occupation),
    ]
    filter_multi_start_with_fields = [
        ('contributor_zip', models.Form56.contributor_zip),
    ]
    sort_options = [
        'contribution_receipt_date',
        'contribution_amount',
    ]

    # use_pk_for_count = True

    @property
    def args(self):
        return utils.extend(
            args.itemized,
            args.form_56,
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
        return query
