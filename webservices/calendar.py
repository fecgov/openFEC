import io
import csv

from icalendar import Event, Calendar
from marshmallow import Schema, fields

def format_start_date(row):
    return (
        row.start_date.date()
        if row.start_date and not row.end_date
        else row.start_date
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
    categories = fields.String(attribute='category')

class ICalEventSchema(BaseEventSchema):

    dtstart = fields.Function(format_start_date)
    dtend = fields.Raw(attribute='end_date')

class EventSchema(BaseEventSchema):

    start_date = fields.DateTime()
    end_date = fields.DateTime()
