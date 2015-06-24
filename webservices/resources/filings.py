from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.util import filter_query

filter_fields = {
    'committee_id',
    'begin_image_numeric',
    'report_type',
    'report_year',
}

@spec.doc(
tags=['filings'],
    description=docs.FILINGS,
    path_params=[
        {
            'name': 'committee_id',
            'in': 'path',
            'description': docs.COMMITTEE_ID,
            'type': 'string',
        },
    ],
)
class FilingsView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.reports)
    @args.register_kwargs(args.make_sort_args(default=['-coverage_end_date']))
    @schemas.marshal_with(schemas.FilingsPageSchema())
    def get(self, **kwargs):
        query = filter_query(models.Filings, models.Filings.query, filter_fields, kwargs)
        return utils.fetch_page(query, kwargs, model=models.Filings)




