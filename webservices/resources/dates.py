from flask.ext.restful import Resource

from webservices import args
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.util import filter_query

filter_fields ={
    'due_date',
    'report_year',
    'report_type',
    'create_date',
    'update_date',
}

@spec.doc(
    tags=['dates'],
    description='FEC reporting dates since 1995.',
)
class ReportingDatesView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.reporting_dates)
    @args.register_kwargs(
        args.make_sort_args(
            default=['-due_date'],
        )
    )
    @schemas.marshal_with(schemas.ReportingDatesPageSchema())
    def get(self, **kwargs):
        reporting_dates = models.ReportingDates.query
        reporting_dates = filter_query(models.ReportingDates, reporting_dates, filter_fields, kwargs)
        return utils.fetch_page(reporting_dates, kwargs, model=models.ReportingDates)

