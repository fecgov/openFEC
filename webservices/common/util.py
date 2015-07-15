import os

import flask
import ujson


dirname = os.path.dirname
MAIN_DIRECTORY = dirname(dirname(dirname(__file__)))


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
