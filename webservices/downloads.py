from webservices.rest import app

adapter = app.url_map.bind('')

def call_resource(path, query):
    endpoint, arguments = adapter.match(path)
    resource = app.view_functions[endpoint].view_class
    with app.test_request_context(query):
        query = resource().build_query(**arguments)
    return fetch_seek_paginator(query, kwargs, resource.index_column)

def iter_query(paginator):
    last_index, sort_index = (None, None)
    while True:
        page = paginator.get_page(last_index=last_index, sort_index=sort_index, eager=False)
        for result in page.results:
            yield result
        last_indexes = paginator._get_index_values(result)
        last_index = last_indexes['last_index']
        if paginator.sort_column:
            sort_index = last_indexes['last_{}'.format(paginator.sort_column[0].key)]
