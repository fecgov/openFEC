import sqlalchemy as sa
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
    'beginning_image_number',
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
    @schemas.marshal_with(schemas.FilingsPageSchema(), wrap=False)
    def get(self, **kwargs):
        query = self.get_filings(kwargs)
        return utils.fetch_page(query, kwargs, model=models.Filings)

    def get_filings(self, kwargs, committee_id=None):
        filings = filter_query(models.Filings, models.Filings.query, filter_fields, kwargs)
        return filings




