import datetime

import sqlalchemy as sa

from flask import Response
from flask_apispec import doc
from webargs import fields, validate
from dateutil.relativedelta import relativedelta

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.utils import use_kwargs
from webservices.common.views import ApiResource
from webservices import calendar


# used for endpoint:'/calendar-dates/'
# under tag: dates
# Ex: http://127.0.0.1:5000/v1/calendar-dates/
@doc(
    tags=['dates'],
    description=docs.CALENDAR_DATES,
)
class CalendarDatesView(ApiResource):
    model = models.CalendarDate
    schema = schemas.CalendarDateSchema
    page_schema = schemas.CalendarDatePageSchema
    cap = 500

    filter_match_fields = [
        ('event_id', models.CalendarDate.event_id),
    ]
    filter_multi_fields = [
        ('calendar_category_id', models.CalendarDate.calendar_category_id),
    ]
    filter_fulltext_fields = [
        ('description', models.CalendarDate.description_text),
        ('summary', models.CalendarDate.summary_text),
    ]
    filter_range_fields = [
        (('min_start_date', 'max_start_date'), models.CalendarDate.start_date),
        (('min_end_date', 'max_end_date'), models.CalendarDate.end_date),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.calendar_dates,
            args.make_sort_args(
                default='-start_date',
            ),
        )

    def build_query(self, *args, **kwargs):
        query = super().build_query(*args, **kwargs)
        return query

    @property
    def index_column(self):
        return self.model.event_id


# used for endpoint:'/calendar-dates/export/'
# under tag: dates
# Ex: http://127.0.0.1:5000/v1/calendar-dates/export/?renderer=ics
@doc(
    tags=['dates'],
    description=docs.CALENDAR_EXPORT,
)
class CalendarDatesExport(CalendarDatesView):
    renderers = {
        'csv': (calendar.EventSchema, calendar.render_csv, 'text/csv'),
        'ics': (calendar.ICalEventSchema, calendar.render_ical, 'text/calendar'),
    }

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
            renderer(
                schema.dump(
                    models.db.session.execute(query).scalars().all()), schema),
            mimetype=mimetype,
        )


# used for endpoint:'/election-dates/'
# under tag: dates
# Ex: http://127.0.0.1:5000/v1/election-dates/
@doc(
    tags=['dates'],
    description=docs.ELECTION_DATES,
)
class ElectionDatesView(ApiResource):
    model = models.ElectionDate
    schema = schemas.ElectionDatesSchema
    page_schema = schemas.ElectionDatesPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.election_dates,
            args.make_sort_args(
                default='-election_date',
                validator=args.IndexValidator(self.model),
            ),
        )

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

    def build_query(self, *args, **kwargs):
        query = super().build_query(*args, **kwargs)
        return query.filter_by(election_status_id=1)


# used for endpoint:'/reporting-dates/'
# under tag: dates
# Ex: http://127.0.0.1:5000/v1/reporting-dates/
@doc(
    tags=['dates'],
    description=docs.ELECTION_DATES,
)
class ReportingDatesView(ApiResource):
    model = models.ReportDate
    schema = schemas.ReportingDatesSchema
    page_schema = schemas.ReportingDatesPageSchema
    contains_joined_load = True

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.reporting_dates,
            args.make_sort_args(
                default='-due_date',
                validator=args.IndexValidator(self.model),
            ),
        )

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
