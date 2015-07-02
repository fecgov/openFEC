import sqlalchemy as sa

from webservices import paging
from webservices import sorting


def fetch_page(query, kwargs, model=None, clear=False, count=None):
    query, _ = sorting.sort(query, kwargs['sort'], model=model, clear=clear)
    paginator = paging.SqlalchemyOffsetPaginator(query, kwargs['per_page'], count=count)
    return paginator.get_page(kwargs['page'])


def fetch_seek_page(query, kwargs, index_column, clear=False, count=None):
    model = index_column.class_
    query, sort_columns = sorting.sort(query, kwargs['sort'], model=model, clear=clear)
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


def filter_multi(query, kwargs, fields):
    for key, column in fields:
        if kwargs[key]:
            query = query.filter(column.in_(kwargs[key]))
    return query


def make_report_pdf_url(image_number):
    return 'http://docquery.fec.gov/pdf/{0}/{1}/{1}.pdf'.format(
        str(image_number)[-3:],
        image_number,
    )


def make_image_pdf_url(image_number):
    return 'http://docquery.fec.gov/cgi-bin/fecimg/?{0}'.format(image_number)
