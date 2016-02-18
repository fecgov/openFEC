import os
import re
import functools

import six
import sqlalchemy as sa
from sqlalchemy.orm import foreign
from sqlalchemy.ext.declarative import declared_attr

from flask.ext import restful
from marshmallow_pagination import paginators

from webargs import fields
from flask_apispec import use_kwargs as use_kwargs_original
from flask_apispec.views import MethodResourceMeta

from webservices import docs
from webservices import sorting
from webservices import decoders
from webservices import exceptions


use_kwargs = functools.partial(use_kwargs_original, locations=('query', ))


class Resource(six.with_metaclass(MethodResourceMeta, restful.Resource)):
    pass

API_KEY_ARG = fields.Str(
    required=True,
    missing='DEMO_KEY',
    description=docs.API_KEY_DESCRIPTION,
)
if os.getenv('PRODUCTION'):
    Resource = use_kwargs({'api_key': API_KEY_ARG})(Resource)


def check_cap(kwargs, cap):
    if cap:
        if not kwargs.get('per_page') or kwargs['per_page'] > cap:
            raise exceptions.ApiError(
                'Parameter "per_page" must be between 1 and {}'.format(cap),
                status_code=422,
            )


def fetch_page(query, kwargs, model=None, aliases=None, join_columns=None, clear=False,
               count=None, cap=100, index_column=None):
    check_cap(kwargs, cap)
    sort, hide_null = kwargs.get('sort'), kwargs.get('sort_hide_null')
    if sort:
        query, _ = sorting.sort(
            query, sort, model=model, aliases=aliases, join_columns=join_columns,
            clear=clear, hide_null=hide_null, index_column=index_column,
        )
    paginator = paginators.OffsetPaginator(query, kwargs['per_page'], count=count)
    return paginator.get_page(kwargs['page'])


def fetch_seek_page(query, kwargs, index_column, clear=False, count=None, cap=100, eager=True):
    paginator = fetch_seek_paginator(query, kwargs, index_column, clear=clear, count=count, cap=cap)
    if paginator.sort_column is not None:
        sort_index = kwargs['last_{0}'.format(paginator.sort_column[0].key)]
    else:
        sort_index = None
    return paginator.get_page(last_index=kwargs['last_index'], sort_index=sort_index, eager=eager)


def fetch_seek_paginator(query, kwargs, index_column, clear=False, count=None, cap=100):
    check_cap(kwargs, cap)
    model = index_column.parent.class_
    sort, hide_null = kwargs.get('sort'), kwargs.get('sort_hide_null')
    if sort:
        query, sort_column = sorting.sort(
            query, sort,
            model=model, clear=clear, hide_null=hide_null,
        )
    else:
        sort_column = None
    return paginators.SeekPaginator(
        query,
        kwargs['per_page'],
        index_column,
        sort_column=sort_column,
        count=count,
    )


def extend(*dicts):
    ret = {}
    for each in dicts:
        ret.update(each)
    return ret


def search_text(query, column, text):
    """

    :param order: Order results by text similarity, descending; prohibitively
        slow for large collections
    """
    vector = ' & '.join([
        part + ':*'
        for part in re.sub(r'\W', ' ', text).split()
    ])
    return query.filter(column.match(vector))


office_args_required = ['office', 'cycle']
office_args_map = {
    'house': ['state', 'district'],
    'senate': ['state'],
}
def check_election_arguments(kwargs):
    for arg in office_args_required:
        if kwargs.get(arg) is None:
            raise exceptions.ApiError(
                'Required parameter "{0}" not found.'.format(arg),
                status_code=422,
            )
    conditional_args = office_args_map.get(kwargs['office'], [])
    for arg in conditional_args:
        if kwargs.get(arg) is None:
            raise exceptions.ApiError(
                'Must include argument "{0}" with office type "{1}"'.format(
                    arg,
                    kwargs['office'],
                ),
                status_code=422,
            )


def get_model(name):
    from webservices.common.models import db
    return db.Model._decl_class_registry.get(name)


def related(related_model, id_label, related_id_label=None, cycle_label=None,
            related_cycle_label=None, use_modulus=True):
    from webservices.common.models import db
    related_model = get_model(related_model)
    related_id_label = related_id_label or id_label
    related_cycle_label = related_cycle_label or cycle_label
    @declared_attr
    def related(cls):
        id_column = getattr(cls, id_label)
        related_id_column = getattr(related_model, related_id_label)
        filters = [foreign(id_column) == related_id_column]
        if cycle_label:
            cycle_column = getattr(cls, cycle_label)
            if use_modulus:
                cycle_column = cycle_column + cycle_column % 2
            related_cycle_column = getattr(related_model, related_cycle_label)
            filters.append(cycle_column == related_cycle_column)
        return db.relationship(
            related_model,
            primaryjoin=sa.and_(*filters),
        )
    return related


related_committee = functools.partial(related, 'CommitteeDetail', 'committee_id')
related_candidate = functools.partial(related, 'CandidateDetail', 'candidate_id')

related_committee_history = functools.partial(
    related,
    'CommitteeHistory',
    'committee_id',
    related_cycle_label='cycle',
)
related_candidate_history = functools.partial(
    related,
    'CandidateHistory',
    'candidate_id',
    related_cycle_label='two_year_period',
)


def document_description(report_year, report_type=None, document_type=None, form_type=None):
    if report_type:
        clean = re.sub(r'\{[^)]*\}', '', report_type)
    elif document_type:
        clean = document_type
    elif form_type and form_type in decoders.form_types:
        clean = decoders.form_types[form_type]
    else:
        clean = 'Document'

    if form_type and form_type == 'RFAI':
        clean = 'RFAI: ' + clean
    return '{0} {1}'.format(clean.strip(), report_year)


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


def get_index_column(model):
    column = model.__mapper__.primary_key[0]
    return getattr(model, column.key)


def cycle_param(**kwargs):
    ret = {
        'name': 'cycle',
        'type': 'integer',
        'in': 'path',
    }
    ret.update(kwargs)
    return ret


def get_election_duration(column):
    return sa.case(
        [
            (column == 'S', 6),
            (column == 'P', 4),
        ],
        else_=2,
    )
