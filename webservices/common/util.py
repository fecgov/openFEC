import os

import flask
import ujson

from datetime import datetime

dirname = os.path.dirname
MAIN_DIRECTORY = dirname(dirname(dirname(__file__)))
CURRENT_CYCLE = datetime.now().year + datetime.now().year % 2


def get_full_path(*path):
    return os.path.join(MAIN_DIRECTORY, *path)


def filter_query(model, query, fields, kwargs):
    for field, value in kwargs.items():
        if field not in fields or not value:
            continue
        column = getattr(model, field)
        query = query.filter(column.in_(value))
    return query


def output_json(data, code, headers=None):
    """Makes a Flask response with a JSON encoded body"""

    settings = flask.current_app.config.get('RESTFUL_JSON', {})

    # always end the json dumps with a new line
    # see https://github.com/mitsuhiko/flask/pull/1262
    dumped = ujson.dumps(data, **settings) + '\n'

    resp = flask.make_response(dumped, code)
    resp.headers.extend(headers or {})
    return resp


def get_class_by_tablename(tablename):
    """Return class reference mapped to table.

    :param tablename: String with name of table.
    :return: Class reference or None.
    """
    from webservices.common.models import db
    for c in db.Model._decl_class_registry.values():
        if hasattr(c, '_sa_class_manager') and c._sa_class_manager.mapper.mapped_table == tablename:
            return c



def year_defaults(**kwargs):
    """ We have two ways of picking time and both are now optional.

    It would be nice to deprecate cycle for itemized endpoints that
    have receipt date in the future, but we can keep it going now for
    a smoother customer experience and try infer the most consistent
    defaults.
f
    Here are the conditions:
        - replace empty min_date with first day of the cycle, if cycle is supplied
        - replace empty min_date with the first day of the cycle, if cycle is supplied
        - check to make sure there isn't more than a 6 year period
        - if only a min date, end in the 2-year period for max_date
        - if only a max date, end in the 2-year period for min_date
        - if no date information is passed search for the current cycle
    """
    min_date = kwargs.get('min_date')
    max_date = kwargs.get('max_date')
    cycle = kwargs.get('two_year_transaction_period')

    if cycle and cycle is not None and not min_date:
        begin_cycle = cycle - 1
        kwargs['min_date'] = datetime(begin_cycle, 1, 1)
    if cycle and not max_date:
        kwargs['max_date'] = datetime(cycle, 12, 31)
    # We plan on rolling this back in the future but wanted to confirm performance
    if min_date and max_date:
        if (max_date - min_date).days > 2190:
            raise ValidationError(
                'Cannot search for more that a 6 year period. Adjust max_date and min_date',
                status_code=422
            )
    if min_date is not None:
        cycle = min_date.year + min_date.year % 2
        kwargs['max_date'] = datetime(cycle, 12, 31)
    if max_date is not None:
        cycle_begin = max_date.year - max_date.year % 2
        kwargs['min_date'] = datetime(cycle_begin, 12, 31)
    else:
        kwargs['two_year_transaction_period'] = CURRENT_CYCLE

    return kwargs