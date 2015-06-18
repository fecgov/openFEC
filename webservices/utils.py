import sqlalchemy as sa

from webservices import paging
from webservices import sorting


def fetch_page(query, kwargs, model=None, clear=False, count=None):
    query = sorting.sort(query, kwargs['sort'], model=model, clear=clear)
    paginator = paging.SqlalchemyOffsetPaginator(query, kwargs['per_page'], count=count)
    return paginator.get_page(kwargs['page'])


def fetch_seek_page(query, kwargs, index_column, clear=False, count=None):
    model = index_column.class_
    query = sorting.sort(query, kwargs['sort'], model=model, clear=clear)
    paginator = paging.SqlalchemySeekPaginator(query, kwargs['per_page'], index_column, count=count)
    return paginator.get_page(kwargs['last_index'])


def extend(*dicts):
    ret = {}
    for each in dicts:
        ret.update(each)
    return ret


def search_text(query, column, text):
    vector = ' & '.join(text.split())
    vector = sa.func.concat(vector, ':*')
    return query.filter(
        column.match(vector)
    ).order_by(
        sa.desc(
            sa.func.ts_rank_cd(
                column,
                sa.func.to_tsquery(vector)
            )
        )
    )


def filter_multi(query, fields, kwargs):
    for key, column in fields:
        if kwargs[key]:
            query = query.filter(column.in_(kwargs[key]))
    return query


def make_pdf_url(image_number):
    return 'http://docquery.fec.gov/pdf/{0}/{1}/{1}.pdf'.format(
        str(image_number)[-3:],
        image_number,
    )
