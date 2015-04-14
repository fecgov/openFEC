from datetime import datetime
from flask.ext.restful import reqparse
from os.path import dirname
from os.path import join as join_path

MAIN_DIRECTORY = dirname(dirname(dirname(__file__)))


def get_full_path(*path):
    return join_path(MAIN_DIRECTORY, *path)


def merge_dicts(x, y):
    z = x.copy()
    z.update(y)
    return z


def default_year():
    year = datetime.now().year
    years = [str(y) for y in range(year+1, year-4, -1)]
    return ','.join(years)


def natural_number(n):
    result = int(n)
    if result < 1:
        raise reqparse.ArgumentTypeError('Must be a number greater than or equal to 1')
    return result


class Pagination:
    def __init__(self, page_num, per_page, count):
        self.page_num = page_num
        self.per_page = per_page
        self.count = count

    def as_json(self):
        return {
            'page': self.page_num,
            'per_page': self.per_page,
            'count': self.count,
            'pages': int(self.count / self.per_page) + (self.count % self.per_page > 0),
        }


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
