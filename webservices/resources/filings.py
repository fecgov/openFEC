import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import views
from webservices.common import counts
from webservices.common import models
from webservices.utils import use_kwargs


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

    query_options = [sa.orm.joinedload(models.Filings.committee)]

    def get(self, **kwargs):
        query = self.build_query(**kwargs)
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_page(query, kwargs, model=models.Filings, count=count)


class FilingsView(BaseFilings):

    @use_kwargs(args.paging)
    @use_kwargs(args.filings)
    @use_kwargs(
        args.make_sort_args(
            default=['-receipt_date'],
            validator=args.IndexValidator(models.Filings),
        )
    )
    @marshal_with(schemas.FilingsPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)

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

    @use_kwargs(args.paging)
    @use_kwargs(args.filings)
    @use_kwargs(args.entities)
    @use_kwargs(
        args.make_sort_args(
            default=['-receipt_date'],
            validator=args.IndexValidator(models.Filings),
        )
    )
    @marshal_with(schemas.FilingsPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)
