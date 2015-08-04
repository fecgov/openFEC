from datetime import date

from flask.ext.restful import Resource

from webservices import args
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.util import filter_query

reporring_filter_fields = {
    'due_date',
    'report_year',
    'report_type',
    'create_date',
    'update_date',
}

election_filter_fields = {
    'election_state',
    'election_district',
    'election_party',
    'office_sought',
    'election_date',
    'election_notes',
    'trc_election_type_id',
    'trc_election_status_id',
    'update_date',
    'create_date',
    'election_yr',
    'pg_date',
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
        reporting_date_query = models.ReportingDates.query
        reporting_date_query = filter_query(models.ReportingDates, reporting_date_query, reporting_filter_fields, kwargs)

        if kwargs.get('upcoming'):
            # choose reporting dates in the future, unique to report type, order by due date
            reporting_date_query = reporting_date_query.filter(models.ReportingDates.due_date >= date.today())

        return utils.fetch_page(reporting_date_query, kwargs, model=models.ReportingDates)


class ElectionDatesView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.reporting_dates)
    @args.register_kwargs(
        args.make_sort_args(
            default=['-election_date'],
        )
    )
    @schemas.marshal_with(schemas.ElectionDatesPageSchema())
    def get(self, **kwargs):
        election_date_query = models.ElectionDates.query
        election_date_query = filter_query(models.ElectionDates, election_date_query, election_filter_fields, kwargs)

        if kwargs.get('upcoming'):
            # choose Election dates in the future, unique to report type, order by due date
            election_date_query = election_date_query.filter(models.ElectionDates.election_date >= date.today())

        return utils.fetch_page(election_date_query, kwargs, model=models.ElectionDates)





