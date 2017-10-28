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

    Here are the conditions:
        - if a cycle is selected, that will provide sufficient date filtering
        - if no date supplied default to the current 2-year period
        - if there is a min and max date check to make sure there isn't more than a 6 year period
        - if cycle and only one min date or max-date, it adds the restriction with in the 2-year period
    """
    min_date = kwargs.get('min_date')
    max_date = kwargs.get('max_date')
    cycle = kwargs.get('two_year_transaction_period')

    if cycle is not None:
        return kwargs
    if min_date is None and max_date is None:
        kwargs['two_year_transaction_period'] = CURRENT_CYCLE
        return kwargs
    # this is for cases where only one date (min_date or max_date) is present
    if not min_date:
        begin_cycle = max_date.year - max_date.year % 2
        kwargs['min_date'] = datetime(begin_cycle, 1, 1)
        return kwargs
    if not max_date:
        cycle = min_date.year + min_date.year % 2
        kwargs['max_date'] = datetime(cycle, 12, 31)
        return kwargs
    # We plan on rolling this back the 6 year restriction in the future
    # but wanted to confirm performance on 6 years first.
    if min_date and max_date:
        if (max_date - min_date).days > 2190:
            raise ValidationError(
                'Cannot search for more that a 6 year period. Adjust max_date and min_date or pick a two_year_period.',
                status_code=422
            )
    return kwargs
