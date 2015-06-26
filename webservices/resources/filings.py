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
    'recipt_date',
    'form_type',
    'report_pgi',
    'amendment_indicator',
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
    @args.register_kwargs(args.filings)
    @args.register_kwargs(args.make_sort_args(default=['-receipt_date']))
    @schemas.marshal_with(schemas.FilingsPageSchema())
    def get(self, committee_id=None, **kwargs):
        filings = models.Filings.query
        if committee_id:
            filings = filings.filter(committee_id=committee_id)
        else:
            filings = filter_query(models.Filings, filings, filter_fields, kwargs)

        return utils.fetch_page(filings, kwargs, model=models.Filings)


