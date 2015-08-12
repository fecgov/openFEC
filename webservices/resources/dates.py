from datetime import date

from flask.ext.restful import Resource

from webservices import args
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.util import filter_query


def filter_upcoming(query, column, kwargs):
    if kwargs['upcoming']:
        return query.filter(column >= date.today())
    return query


@spec.doc(tags=['dates'])
class DatesResource(Resource):

    def get(self, **kwargs):
        query = self.model.query
        query = filter_query(self.model, query, self.filter_fields, kwargs)
        query = filter_upcoming(query, self.date_column, kwargs)
        return utils.fetch_page(query, kwargs, model=self.model)


@spec.doc(description='FEC reporting dates since 1995.')
class ReportingDatesView(DatesResource):

    model = models.ReportingDates
    @property
    def date_column(self):
        return self.model.due_date

    filter_fields = {
        'due_date',
        'report_year',
        'report_type',
        'create_date',
        'update_date',
    }

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.reporting_dates)
    @args.register_kwargs(
        args.make_sort_args(
            default=['-due_date'],
        )
    )
    @schemas.marshal_with(schemas.ReportingDatesPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)


@spec.doc(description='FEC election dates since 1995.')
class ElectionDatesView(DatesResource):

    model = models.ElectionDates
    @property
    def date_column(self):
        return self.model.election_date

    filter_fields = {
        'election_state',
        'election_district',
        'election_party',
        'office_sought',
        'election_date',
        'trc_election_type_id',
        'trc_election_status_id',
        'update_date',
        'create_date',
        'election_yr',
        'pg_date',
    }

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.reporting_dates)
    @args.register_kwargs(
        args.make_sort_args(
            default=['-election_date'],
        )
    )
    @schemas.marshal_with(schemas.ElectionDatesPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)
