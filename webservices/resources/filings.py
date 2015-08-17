import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import counts
from webservices.common import models


@spec.doc(
    tags=['filings'],
    description=docs.FILINGS,
    path_params=[
        utils.extend(utils.committee_param, {'name': 'committee_id'}),
        utils.extend(utils.candidate_param, {'name': 'candidate_id'}),
    ],
)
class BaseFilings(Resource):

    range_fields = [
        (('min_receipt_date', 'max_receipt_date'), models.Filings.receipt_date),
    ]

    multi_fields = [
        ('beginning_image_number', models.Filings.beginning_image_number),
        ('report_type', models.Filings.report_type),
        ('document_type', models.Filings.document_type),
        ('report_year', models.Filings.report_year),
        ('form_type', models.Filings.form_type),
        ('primary_general_indicator', models.Filings.primary_general_indicator),
        ('amendment_indicator', models.Filings.amendment_indicator),
    ]

    def get(self, **kwargs):
        query = self._build_query(**kwargs)
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_page(query, kwargs, model=models.Filings, count=count)

    def _build_query(self, **kwargs):
        query = models.Filings.query
        query = query.options(sa.orm.joinedload(models.Filings.committee))
        query = utils.filter_multi(query, kwargs, self.multi_fields)
        query = utils.filter_range(query, kwargs, self.range_fields)
        return query


class FilingsView(BaseFilings):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.filings)
    @args.register_kwargs(
        args.make_sort_args(
            default=['-receipt_date'],
            validator=args.IndexValidator(models.Filings),
        )
    )
    @schemas.marshal_with(schemas.FilingsPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)

    def _build_query(self, committee_id=None, candidate_id=None, **kwargs):
        query = super()._build_query(**kwargs)
        if committee_id:
            query = query.filter(models.Filings.committee_id == committee_id)
        if candidate_id:
            query = query.filter(models.Filings.candidate_id == candidate_id)
        return query


class FilingsList(BaseFilings):

    multi_fields = BaseFilings.multi_fields + [
        ('committee_id', models.Filings.committee_id),
        ('candidate_id', models.Filings.candidate_id),
    ]

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.filings)
    @args.register_kwargs(args.entities)
    @args.register_kwargs(
        args.make_sort_args(
            default=['-receipt_date'],
            validator=args.IndexValidator(models.Filings),
        )
    )
    @schemas.marshal_with(schemas.FilingsPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)
