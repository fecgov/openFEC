from webargs import flaskparser
from flask_apispec.utils import resolve_annotations

from webservices import utils
from webservices.rest import app
from webservices.common import counts
from webservices.common.models import db

adapter = app.url_map.bind('')

def call_resource(path, qs, per_page=5000):
    endpoint, arguments = adapter.match(path)
    resource = app.view_functions[endpoint].view_class()
    kwargs = parse_kwargs(resource, qs)
    kwargs['per_page'] = per_page
    query = resource.build_query(**utils.extend(arguments, kwargs))
    count = counts.count_estimate(query, db.session, threshold=5000)
    paginator = utils.fetch_seek_paginator(query, kwargs, resource.index_column, count=count)
    return paginator, resource.schema

def parse_kwargs(resource, qs):
    annotation = resolve_annotations(resource.get, 'args', parent=resource)
    with app.test_request_context(qs):
        kwargs = {}
        for option in annotation.options:
            kwargs.update(flaskparser.parser.parse(option['args']))
    return kwargs

def iter_paginator(paginator):
    last_index, sort_index = (None, None)
    while True:
        page = paginator.get_page(last_index=last_index, sort_index=sort_index)
        if not page.results:
            return
        for result in page.results:
            yield result
        last_indexes = paginator._get_index_values(result)
        last_index = last_indexes['last_index']
        if paginator.sort_column:
            sort_index = last_indexes['last_{}'.format(paginator.sort_column[0].key)]
