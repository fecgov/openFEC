import sqlalchemy as sa

from webservices import utils
from webservices import exceptions
from webservices import sorting
from webservices.common import models


def is_exclude_arg(arg):
    # Handle string and int excludes
    return str(arg).startswith('-')


def parse_exclude_arg(arg):
    # Integers will come in as negative and strings will start with "-""
    if isinstance(arg, int):
        return abs(arg)
    else:
        return arg[1:]


def build_exclude_list(value_list):
    exclude_list = [parse_exclude_arg(value) for value in value_list if is_exclude_arg(value)]
    return exclude_list


def build_include_list(value_list):
    include_list = [value for value in value_list if not is_exclude_arg(value)]
    return include_list


def filter_match(query, kwargs, fields):
    for key, column in fields:
        if kwargs.get(key) is not None:
            if is_exclude_arg(kwargs[key]):
                query = query.filter(sa.or_(column != parse_exclude_arg(kwargs[key]),
                                            column == None))  # noqa
            else:
                query = query.filter(column == kwargs[key])
    return query


def filter_multi(query, kwargs, fields):
    for key, column in fields:
        if kwargs.get(key):
            # handle combination exclude/include lists
            exclude_list = build_exclude_list(kwargs.get(key))
            include_list = build_include_list(kwargs.get(key))
            if exclude_list:
                query = query.filter(sa.or_(column.notin_(exclude_list),
                                            column == None))  # noqa
            if include_list:
                query = query.filter(column.in_(include_list))
    return query


def filter_range(query, kwargs, fields):
    for (min_key, max_key), column in fields:
        if kwargs.get(min_key) is not None:
            query = query.filter(column >= kwargs[min_key])
        if kwargs.get(max_key) is not None:
            query = query.filter(column <= kwargs[max_key])
    return query


def filter_fulltext(query, kwargs, fields):
    for key, column in fields:
        if kwargs.get(key):
            exclude_list = build_exclude_list(kwargs.get(key))
            include_list = build_include_list(kwargs.get(key))
            if exclude_list:
                filters = [
                    sa.not_(column.match(utils.parse_fulltext(value)))
                    for value in exclude_list
                ]
                query = query.filter(sa.and_(*filters))
            if include_list:
                filters = [
                    column.match(utils.parse_fulltext(value))
                    for value in include_list
                ]
                query = query.filter(sa.or_(*filters))
    return query


def filter_union(query, kwargs, fields, model):
    # TODO: No support for exclude fields, probably ok
    for key, column in fields:
        if kwargs.get(key):
            filters = [
                column.match(utils.parse_fulltext(value))
                for value in kwargs.get(key)
            ]
            # First filter is an AND
            query = query.filter(sa.and_(filters[0]))
            query, _ = sorting.sort(query, kwargs['sort'], model=model, hide_null=kwargs['sort_hide_null'])
            from sqlalchemy.dialects import postgresql
            # print("temp_query 1\n")
            # print(str(temp_query.statement.compile(
            #     dialect=postgresql.dialect(),
            #     compile_kwargs={"literal_binds": True})))
            # Additional filters are UNION
            if len(filters) > 1:
                # don't actually filter the query or it just builds up
                sub_queries = []
                for query_filter in filters[1:]:
                    temp_query = query  # save this for multi below
                    print("temp_query 2\n")
                    print(str(temp_query.statement.compile(
                        dialect=postgresql.dialect(),
                        compile_kwargs={"literal_binds": True})))
                    temp_query = temp_query.filter(sa.and_(query_filter))
                    temp_query, _ = sorting.sort(temp_query, kwargs['sort'], model=model, hide_null=kwargs['sort_hide_null'])
                    temp_query = temp_query.limit(kwargs.get('per_page'))
                    sub_queries.append(temp_query)
                query = query.limit(kwargs.get('per_page'))
                query = query.union_all(*sub_queries)
                print("dir(query)")
                print(dir(query))
                print("vars(query)")
                print(vars(query))
            from sqlalchemy.dialects import postgresql

            print(str(query.statement.compile(
                dialect=postgresql.dialect(),
                compile_kwargs={"literal_binds": True})))
    return query


def filter_multi_start_with(query, kwargs, fields):
    for key, column in fields:
        if kwargs.get(key):
            exclude_list = build_exclude_list(kwargs.get(key))
            include_list = build_include_list(kwargs.get(key))
            if exclude_list:
                filters = [
                    sa.not_(column.startswith(value))
                    for value in exclude_list
                ]
                query = query.filter(sa.and_(*filters))
            if include_list:
                filters = [
                    column.startswith(value)
                    for value in include_list
                ]
                query = query.filter(sa.or_(*filters))
    return query


def filter_contributor_type(query, column, kwargs):
    if kwargs.get('contributor_type') == ['individual']:
        return query.filter(column == 'IND')
    if kwargs.get('contributor_type') == ['committee']:
        return query.filter(sa.or_(column != 'IND', column == None))  # noqa
    return query


def filter_election(query, kwargs, candidate_column, cycle_column=None, year_column=None):
    if not kwargs.get('office'):
        return query
    utils.check_election_arguments(kwargs)
    cycle = get_cycle(kwargs)
    query = query.join(
        models.CandidateHistory,
        candidate_column == models.CandidateHistory.candidate_id,
    ).filter(
        models.CandidateHistory.two_year_period == cycle,
        models.CandidateHistory.office == kwargs['office'][0].upper(),
    )
    if kwargs.get('state'):
        query = query.filter(models.CandidateHistory.state == kwargs['state'])
    if kwargs.get('district'):
        query = query.filter(models.CandidateHistory.district == kwargs['district'])
    return query


def get_cycle(kwargs):
    if isinstance(kwargs['cycle'], list):
        if len(kwargs['cycle']) != 1:
            raise exceptions.ApiError(
                'Must include exactly one argument "cycle"',
                status_code=422,
            )
        return kwargs['cycle'][0]
    return kwargs['cycle']
