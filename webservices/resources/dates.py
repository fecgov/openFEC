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

    model = models.ReportDate

    @property
    def date_column(self):
        return self.model.due_date

    filter_multi_fields = [
        ('report_year', models.ReportDate.report_year),
        ('report_type', models.ReportDate.report_type)
    ]
    filter_range_fields = [
        (('min_due_date', 'max_due_date'), models.ReportDate.due_date),
        (('min_create_date', 'max_create_date'), models.ReportDate.create_date),
        (('min_update_date', 'max_update_date'), models.ReportDate.update_date),
    ]

    query_options = [sa.orm.joinedload(models.ReportDate.report)]

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

    model = models.ElectionDate

    @property
    def date_column(self):
        return self.model.election_date

    filter_multi_fields = [
        ('election_state', models.ElectionDate.election_state),
        ('election_district', models.ElectionDate.election_district),
        ('election_party', models.ElectionDate.election_party),
        ('office_sought', models.ElectionDate.office_sought),
        ('trc_election_type_id', models.ElectionDate.trc_election_type_id),
        ('trc_election_status_id', models.ElectionDate.trc_election_status_id),
        ('election_year', models.ElectionDate.election_year),
    ]

    filter_range_fields = [
        (('min_election_date','max_election_date'), models.ElectionDate.election_date),
        (('min_update_date','max_update_date'), models.ElectionDate.update_date),
        (('min_create_date','max_create_date'), models.ElectionDate.create_date),
        (('min_primary_general_date','max_primary_general_date'), models.ElectionDate.primary_general_date),
    ]

    @use_kwargs(args.paging)
    @use_kwargs(args.election_dates)
    @use_kwargs(
        args.make_sort_args(
            default=['-election_date'],
        )
    )
    @marshal_with(schemas.ElectionDatesPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)
