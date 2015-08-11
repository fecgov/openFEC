import re

import sqlalchemy as sa

from webservices import docs
from webservices import paging
from webservices import sorting
from webservices import exceptions


def check_cap(kwargs, cap):
    if cap:
        if not kwargs['per_page']:
            raise exceptions.ApiError(
                'Parameter "per_page" must be > 0'.format(cap),
                status_code=422,
            )


def fetch_page(query, kwargs, model=None, clear=False, count=None, cap=100):
    check_cap(kwargs, cap)
    sort, hide_null, nulls_large = kwargs['sort'], kwargs['sort_hide_null'], kwargs['sort_nulls_large']
    query, _ = sorting.sort(query, sort, model=model, clear=clear, hide_null=hide_null, nulls_large=nulls_large)
    paginator = paging.SqlalchemyOffsetPaginator(query, kwargs['per_page'], count=count)
    return paginator.get_page(kwargs['page'])


def fetch_seek_page(query, kwargs, index_column, clear=False, count=None, cap=100):
    check_cap(kwargs, cap)
    model = index_column.class_
    sort, hide_null, nulls_large = kwargs['sort'], kwargs['sort_hide_null'], kwargs['sort_nulls_large']
    query, sort_columns = sorting.sort(query, sort, model=model, clear=clear, hide_null=hide_null, nulls_large=nulls_large)
    sort_column = sort_columns[0] if sort_columns else None
    paginator = paging.SqlalchemySeekPaginator(
        query,
        kwargs['per_page'],
        index_column,
        sort_column=sort_column,
        count=count,
    )
    if sort_column is not None:
        sort_index = kwargs['last_{0}'.format(sort_column[0].key)]
    else:
        sort_index = None
    return paginator.get_page(last_index=kwargs['last_index'], sort_index=sort_index)


def extend(*dicts):
    ret = {}
    for each in dicts:
        ret.update(each)
    return ret


def search_text(query, column, text, order=True):
    """

    :param order: Order results by text similarity, descending; prohibitively
        slow for large collections
    """
    vector = ' & '.join(text.split())
    vector = sa.func.concat(vector, ':*')
    query = query.filter(column.match(vector))
    if order:
        query = query.order_by(
            sa.desc(
                sa.func.ts_rank_cd(
                    column,
                    sa.func.to_tsquery(vector)
                )
            )
        )
    return query


office_args_required = ['office', 'cycle']
office_args_map = {
    'house': ['state', 'district'],
    'senate': ['state'],
}
def check_election_arguments(kwargs):
    for arg in office_args_required:
        if kwargs[arg] is None:
            raise exceptions.ApiError(
                'Required parameter "{0}" not found.'.format(arg),
                status_code=422,
            )
    conditional_args = office_args_map.get(kwargs['office'], [])
    for arg in conditional_args:
        if kwargs[arg] is None:
            raise exceptions.ApiError(
                'Must include argument "{0}" with office type "{1}"'.format(
                    arg,
                    kwargs['office'],
                ),
                status_code=422,
            )


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


def document_description(report_year, report_type=None, document_type=None):
    if report_type:
        clean = re.sub(r'\{[^)]*\}', '', report_type)
    elif document_type:
        clean = document_type
    else:
        clean = 'Document '
    return '{0}{1}'.format(clean, report_year)


def report_pdf_url(report_year, beginning_image_number, form_type=None, committee_type=None):
    if report_year and report_year >= 2000:
        return make_report_pdf_url(beginning_image_number)
    if form_type in ['F3X', 'F3P'] and report_year > 1993:
        return make_report_pdf_url(beginning_image_number)
    if form_type == 'F3' and committee_type == 'H' and report_year > 1996:
        return make_report_pdf_url(beginning_image_number)
    return None


def make_report_pdf_url(image_number):
    return 'http://docquery.fec.gov/pdf/{0}/{1}/{1}.pdf'.format(
        str(image_number)[-3:],
        image_number,
    )


def make_image_pdf_url(image_number):
    return 'http://docquery.fec.gov/cgi-bin/fecimg/?{0}'.format(image_number)


committee_param = {
    'name': 'committee_id',
    'type': 'string',
    'in': 'path',
    'description': docs.COMMITTEE_ID,
}
candidate_param = {
    'name': 'candidate_id',
    'type': 'string',
    'in': 'path',
    'description': docs.CANDIDATE_ID,
}
def cycle_param(**kwargs):
    ret = {
        'name': 'cycle',
        'type': 'integer',
        'in': 'path',
    }
    ret.update(kwargs)
    return ret
