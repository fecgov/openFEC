import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.common import counts
from webservices.common import models
from webservices.common.util import filter_query


fields = {
    'committee_id',
    'candidate_id',
    'beginning_image_number',
    'report_type',
    'document_type',
    'report_year',
    'receipt_date',
    'form_type',
    'primary_general_indicator',
    'amendment_indicator',
}

range_fields = [
    (('min_receipt_date', 'max_receipt_date'), models.Filings.receipt_date),
]


@spec.doc(
    tags=['filings'],
    description=docs.FILINGS,
    path_params=[utils.committee_param, utils.candidate_param],
)
class FilingsView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(
        args.make_sort_args(
            default=['-receipt_date'],
            validator=args.IndexValidator(models.Filings),
        )
    )
    @schemas.marshal_with(schemas.FilingsPageSchema())
    def get(self, committee_id=None, candidate_id=None, **kwargs):
        query = models.Filings.query
        if committee_id:
            query = query.filter(models.Filings.committee_id == committee_id)
        if candidate_id:
            query = query.filter(models.Filings.candidate_id == candidate_id)
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_page(query, kwargs, model=models.Filings, count=count)


@spec.doc(
    tags=['filings'],
    description=docs.FILINGS,
)
class FilingsList(Resource):

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
        query = models.Filings.query
        query = query.options(sa.orm.joinedload(models.Filings.committee))
        query = filter_query(models.Filings, query, fields, kwargs)
        query = filters.filter_range(query, kwargs, range_fields)
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return utils.fetch_page(query, kwargs, model=models.Filings, count=count)
