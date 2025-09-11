from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices.utils import extend, validate_and_filter_zip_codes
from webservices import filters
from webservices import schemas
from webservices.common import models
from webservices.common.views import ItemizedResource


# Used for '/schedules/schedule_a_form5/'
# under tag:'receipts'
@doc(
    tags=['receipts'], description=docs.FORM_56,
)
class Form56View(ItemizedResource):

    model = models.Form56
    schema = schemas.Form56Schema
    page_schema = schemas.Form56PageSchema

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
        ('report_year', models.Form56.report_year),
        ('report_type', models.Form56.report_type),
        ('two_year_transaction_period', models.Form56.two_year_transaction_period)
    ]
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

    @property
    def args(self):
        return extend(
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
        query = filters.filter_contributor_type(query, self.model.contributor_type, kwargs)
        query = validate_and_filter_zip_codes(
                query, kwargs, 'contributor_zip', filters, self.filter_multi_start_with_fields
            )
        if kwargs.get('sub_id'):
            query = query.filter_by(sub_id=int(kwargs.get('sub_id')))
        return query
