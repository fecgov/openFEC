import io
import csv
import datetime
import functools

import pytz
from icalendar import Event, Calendar
from marshmallow import Schema, fields

timezone = pytz.timezone('US/Eastern')

def render_date(value, fmt=True):
    return (
        value.isoformat()
        if value and fmt
        else value
    )

def localize(value):
    return (
        timezone.localize(value)
        if isinstance(value, datetime.datetime)
        else value
    )

def format_start_date(row, context=None, fmt=True):
    """Cast start date to appropriate type. If no end date is present, the start
    date must be an ical `DATE` and not a `DATE-TIME`.

    See http://www.kanzaki.com/docs/ical/vevent.html for details.
    """
    return render_date(
        localize(
            row.start_date.date()
            if row.start_date and row.all_day
            else row.start_date
        ),
        fmt=fmt,
    )

def format_end_date(row, context=None, fmt=True):
    """Round end date to start of next day for all-day events.
    """
    return render_date(
        localize(
            row.end_date.date() + datetime.timedelta(days=1)
            if row.end_date and row.all_day
            else row.end_date
        ),
        fmt=fmt,
    )

def render_ical(rows, schema):
    calendar = Calendar()
    for row in rows:
        event = Event()
        for key, value in row.items():
            if value:
                event.add(key, value)
        calendar.add_component(event)
    return calendar.to_ical()

def render_csv(rows, schema):
    sio = io.StringIO()
    writer = csv.DictWriter(sio, fieldnames=schema.fields.keys())
    writer.writeheader()
    for row in rows:
        writer.writerow(row)
    return sio.getvalue()

class BaseEventSchema(Schema):
    summary = fields.String()
    description = fields.String()
    location = fields.String()

class ICalEventSchema(BaseEventSchema):
    dtstart = fields.Function(functools.partial(format_start_date, fmt=False))
    dtend = fields.Function(functools.partial(format_end_date, fmt=False))
    categories = fields.String(attribute='category')

class EventSchema(BaseEventSchema):
    start_date = fields.Function(format_start_date)
    end_date = fields.Function(format_end_date)
    category = fields.String()
