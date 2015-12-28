import datetime

import sqlalchemy as sa
from flask import Response
from webargs import fields, validate
from flask_apispec import doc, marshal_with
from dateutil.relativedelta import relativedelta

from webservices import args
from webservices import schemas
from webservices.common import models
from webservices.utils import use_kwargs
from webservices.common.views import ApiResource
from webservices import calendar


@doc(tags=['dates'], description='FEC reporting dates since 1995.')
class ReportingDatesView(ApiResource):

    model = models.ReportDate

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


@doc(tags=['dates'], description='FEC election dates since 1995.')
class ElectionDatesView(ApiResource):

    model = models.ElectionDate

    filter_multi_fields = [
        ('election_state', models.ElectionDate.election_state),
        ('election_district', models.ElectionDate.election_district),
        ('election_party', models.ElectionDate.election_party),
        ('office_sought', models.ElectionDate.office_sought),
        ('election_type_id', models.ElectionDate.election_type_id),
        ('election_year', models.ElectionDate.election_year),
    ]
    filter_range_fields = [
        (('min_election_date', 'max_election_date'), models.ElectionDate.election_date),
        (('min_update_date', 'max_update_date'), models.ElectionDate.update_date),
        (('min_create_date', 'max_create_date'), models.ElectionDate.create_date),
        (('min_primary_general_date', 'max_primary_general_date'), models.ElectionDate.primary_general_date),
    ]

    @use_kwargs(args.paging)
    @use_kwargs(args.election_dates)
    @use_kwargs(
        args.make_sort_args(
            default=['-election_date'],
        ),
    )
    @marshal_with(schemas.ElectionDatesPageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)

    def build_query(self, *args, **kwargs):
        query = super().build_query(*args, **kwargs)
        return query.filter_by(election_status_id=1)


@doc(tags=['dates'], description='FEC reporting, election and event dates.')
class CalendarDatesView(ApiResource):

    model = models.CalendarDate

    filter_multi_fields = [
        ('category', models.CalendarDate.category),
        ('location', models.CalendarDate.location),
    ]
    filter_fulltext_fields = [
        ('description', models.CalendarDate.description_text),
        ('summary', models.CalendarDate.summary_text),
    ]
    filter_range_fields = [
        (('min_start_date_time', 'max_start_date_time'), models.CalendarDate.start_date),
        (('min_end_date_time', 'max_end_date_time'), models.CalendarDate.end_date),
    ]

    @use_kwargs(args.paging)
    @use_kwargs(args.calendar_dates)
    @use_kwargs(
        args.make_sort_args(
            default=['-start_date'],
        )
    )
    @marshal_with(schemas.CalendarDatePageSchema())
    def get(self, **kwargs):
        return super().get(**kwargs)

    def build_query(self, *args, **kwargs):
        # TODO: Generalize if reused
        query = super().build_query(*args, **kwargs)
        if kwargs.get('state'):
            query = query.filter(
                sa.or_(
                    self.model.states.overlap(kwargs['state']),
                    self.model.states == None  # noqa
                )
            )
        return query


class CalendarDatesExport(CalendarDatesView):

    renderers = {
        'csv': (calendar.EventSchema, calendar.render_csv, 'text/csv'),
        'ics': (calendar.ICalEventSchema, calendar.render_ical, 'text/calendar'),
    }

    @use_kwargs(args.calendar_dates)
    @use_kwargs({
        'renderer': fields.Str(missing='ics', validate=validate.OneOf(['ics', 'csv'])),
    })
    def get(self, **kwargs):
        query = self.build_query(**kwargs)
        today = datetime.date.today()
        query = query.filter(
            self.model.start_date >= today - relativedelta(years=1),
            self.model.start_date < today + relativedelta(years=1),
        )
        schema_type, renderer, mimetype = self.renderers[kwargs['renderer']]
        schema = schema_type(many=True)
        return Response(
            renderer(schema.dump(query).data, schema),
            mimetype=mimetype,
        )
