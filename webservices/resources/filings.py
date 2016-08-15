from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import views
from webservices.common import counts
from webservices.common import models

reports_schema_map = {
    'P': (models.BaseF3PFiling, schemas.BaseF3PFilingSchema, schemas.BaseF3PFilingPageSchema),
    'H': (models.BaseF3Filing, schemas.BaseF3FilingSchema, schemas.BaseF3FilingPageSchema),
    'S': (models.BaseF3Filing, schemas.BaseF3FilingSchema, schemas.BaseF3FilingPageSchema),
    'X': (models.BaseF3XFiling, schemas.BaseF3XFilingSchema, schemas.BaseF3XFilingPageSchema),
}

form_type_map = {
    'f3p-summary': 'P',
    'f3x-summary': 'X',
    'f3-summary': 'H',
}

@doc(
    tags=['filings'],
    description=docs.FILINGS,
    params={
        'candidate_id': {'description': docs.CANDIDATE_ID},
        'committee_id': {'description': docs.COMMITTEE_ID},
    },
)
class BaseFilings(views.ApiResource):

    model = models.Filings
    schema = schemas.FilingsSchema
    page_schema = schemas.FilingsPageSchema

    filter_multi_fields = [
        ('beginning_image_number', models.Filings.beginning_image_number),
        ('report_type', models.Filings.report_type),
        ('document_type', models.Filings.document_type),
        ('report_year', models.Filings.report_year),
        ('form_type', models.Filings.form_type),
        ('primary_general_indicator', models.Filings.primary_general_indicator),
        ('amendment_indicator', models.Filings.amendment_indicator),
        ('cycle', models.Filings.cycle),
    ]

    filter_range_fields = [
        (('min_receipt_date', 'max_receipt_date'), models.Filings.receipt_date),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.filings,
            args.make_sort_args(
                default='-receipt_date',
                validator=args.IndexValidator(models.Filings),
            ),
        )

    def get(self, **kwargs):
        query = self.build_query(**kwargs)
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_page(query, kwargs, model=models.Filings, count=count)


class FilingsView(BaseFilings):

    def build_query(self, committee_id=None, candidate_id=None, **kwargs):
        query = super().build_query(**kwargs)
        if committee_id:
            query = query.filter(models.Filings.committee_id == committee_id)
        if candidate_id:
            query = query.filter(models.Filings.candidate_id == candidate_id)
        return query


class FilingsList(BaseFilings):

    filter_multi_fields = BaseFilings.filter_multi_fields + [
        ('committee_id', models.Filings.committee_id),
        ('candidate_id', models.Filings.candidate_id),
    ]

    @property
    def args(self):
        return utils.extend(super().args, args.entities)

@doc(
    tags=['efilings'],
    description=docs.FILINGS,
)
class EFilingSummaryView(views.ApiResource):

    model = models.BaseF3PFiling
    schema = schemas.BaseF3FilingSchema
    page_schema = schemas.BaseF3FilingSchema

    filter_multi_fields = [
        ('file_number', models.BaseFiling.file_number),
        ('committee_id', models.BaseFiling.committee_id),
    ]
    filter_range_fields = [
        (('min_create_date', 'max_create_date' ), models.BaseFiling.create_date),
    ]
    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.efilings,
            args.make_sort_args(
                default='-create_date',
                validator=args.IndexValidator(self.model),
            ),
        )


    def get(self, form=None, **kwargs):

        if form:
            self.model, self.schema, self.page_schema = \
                reports_schema_map.get(form_type_map.get(form))
        query = self.build_query(**kwargs)

        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_page(query, kwargs, model=self.model, count=count)

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        return query
