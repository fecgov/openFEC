from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.util import filter_query

filter_fields = {
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
    @args.register_kwargs(args.make_sort_args(default=['-receipt_date']))
    @schemas.marshal_with(schemas.FilingsPageSchema())
    def get(self, committee_id=None, begin_image_numeric=None, **kwargs):
            query = models.Filings.query.filter_by(recipt_date>=1980)
        if committee_id:
            query = query(committee_id=committee_id)

        return utils.fetch_page(query, kwargs, model=models.Filings)




