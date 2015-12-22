from icalendar import Calendar, Event
from marshmallow import Schema, fields, post_dump

def format_start_date(row):
    return (
        row.start_date.date()
        if row.start_date and not row.end_date
        else row.start_date
    )

class EventSchema(Schema):

    dtstart = fields.Function(format_start_date)
    dtend = fields.Raw(attribute='end_date')

    summary = fields.String()
    description = fields.String()

    location = fields.String()
    categories = fields.String(attribute='category')

    @post_dump
    def to_event(self, data):
        event = Event()
        for key, value in data.items():
            if value:
                event.add(key, value)
        return event

class CalendarSchema(Schema):

    events = fields.Nested(EventSchema, many=True)

    @post_dump
    def to_calendar(self, data):
        calendar = Calendar()
        for event in data.get('events', []):
            calendar.add_component(event)
        return calendar.to_ical()
