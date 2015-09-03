from webservices import utils
from webservices import exceptions
from webservices.common import models


def filter_match(query, kwargs, fields):
    for key, column in fields:
        if kwargs[key] is not None:
            query = query.filter(column == kwargs[key])
    return query


def filter_multi(query, kwargs, fields):
    for key, column in fields:
        if kwargs[key]:
            query = query.filter(column.in_(kwargs[key]))
    return query


def filter_range(query, kwargs, fields):
    for (min_key, max_key), column in fields:
        if kwargs[min_key] is not None:
            query = query.filter(column >= kwargs[min_key])
        if kwargs[max_key] is not None:
            query = query.filter(column <= kwargs[max_key])
    return query


def filter_contributor_type(query, column, kwargs):
    if kwargs['contributor_type'] == ['individual']:
        return query.filter(column == 'IND')
    if kwargs['contributor_type'] == ['committee']:
        return query.filter(column != 'IND')
    return query


def filter_election(query, kwargs, candidate_column, cycle_column=None, year_column=None):
    if not kwargs['office']:
        return query
    if isinstance(kwargs['cycle'], list):
        if len(kwargs['cycle']) != 1:
            raise exceptions.ApiError(
                'Must include exactly one argument "cycle"',
                status_code=422,
            )
        kwargs['cycle'] = kwargs['cycle'][0]
    utils.check_election_arguments(kwargs)
    query = query.join(
        models.CandidateHistory,
        candidate_column == models.CandidateHistory.candidate_id,
    ).filter(
        models.CandidateHistory.two_year_period == kwargs['cycle'],
        models.CandidateHistory.office == kwargs['office'][0].upper(),
    )
    if cycle_column:
        query = query.filter(cycle_column == kwargs['cycle'])
    elif year_column:
        query = query.filter(year_column.in_(kwargs['cycle'], kwargs['cycle'] - 1))
    else:
        raise ValueError('Must provide `cycle_column` or `year_column`')
    if kwargs['state']:
        query = query.filter(models.CandidateHistory.state == kwargs['state'])
    if kwargs['district']:
        query = query.filter(models.CandidateHistory.district == kwargs['district'])
    return query
