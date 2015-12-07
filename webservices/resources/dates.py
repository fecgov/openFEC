from datetime import date

import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import schemas
from webservices.common import models
from webservices.utils import use_kwargs
from webservices.common.views import ApiResource


def filter_upcoming(query, column, kwargs):
    if kwargs['upcoming']:
        return query.filter(column >= date.today())
    return query


@doc(tags=['dates'])
class DatesResource(ApiResource):

    def build_query(self, *args, **kwargs):
        query = super().build_query(*args, **kwargs)
        return filter_upcoming(query, self.date_column, kwargs)


@doc(description='FEC reporting dates since 1995.')
class ReportingDatesView(DatesResource):

    model = models.ReportingDates

    @property
    def date_column(self):
        return self.model.due_date

    filter_multi_fields = [
        ('due_date', models.ReportingDates.due_date),
        ('report_year', models.ReportingDates.report_year),
        ('report_type', models.ReportingDates.report_type),
        ('create_date', models.ReportingDates.create_date),
        ('update_date', models.ReportingDates.update_date),
    ]

    query_options = [sa.orm.joinedload(models.ReportingDates.report)]

    @use_kwargs(args.paging)
    @use_kwargs(args.reporting_dates)
    @use_kwargs(
        args.make_sort_args(
            default=['-due_date'],
        )
    )
    @marshal_with(schemas.ReportingDatesPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)


@doc(description='FEC election dates since 1995.')
class ElectionDatesView(DatesResource):

    model = models.ElectionDates

    @property
    def date_column(self):
        return self.model.election_date

    filter_multi_fields = [
        ('election_state', models.ElectionDates.election_state),
        ('election_district', models.ElectionDates.election_district),
        ('election_party', models.ElectionDates.election_party),
        ('office_sought', models.ElectionDates.office_sought),
        ('election_date', models.ElectionDates.election_date),
        ('trc_election_type_id', models.ElectionDates.trc_election_type_id),
        ('trc_election_status_id', models.ElectionDates.trc_election_status_id),
        ('update_date', models.ElectionDates.update_date),
        ('create_date', models.ElectionDates.create_date),
        ('election_year', models.ElectionDates.election_year),
        ('pg_date', models.ElectionDates.pg_date),
    ]

    @use_kwargs(args.paging)
    @use_kwargs(args.reporting_dates)
    @use_kwargs(
        args.make_sort_args(
            default=['-election_date'],
        )
    )
    @marshal_with(schemas.ElectionDatesPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)
