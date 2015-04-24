import os
import datetime


dirname = os.path.dirname
MAIN_DIRECTORY = dirname(dirname(dirname(__file__)))


def get_full_path(*path):
    return os.path.join(MAIN_DIRECTORY, *path)


def default_year():
    year = datetime.datetime.now().year
    years = [str(y) for y in range(year + 1, year - 4, -1)]
    return ','.join(years)


def filter_query(model, query, fields, kwargs):
    for field, value in kwargs.items():
        if field not in fields or not value:
            continue
        column = getattr(model, field)
        predicate = (
            column.in_(value.split(','))
            if ',' in value
            else column == value
        )
        query = query.filter(predicate)
    return query
