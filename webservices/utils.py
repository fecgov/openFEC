from webservices import paging
from webservices import sorting


def fetch_page(query, kwargs, clear=False):
    query = sorting.sort(query, kwargs['sort'], clear=clear)
    paginator = paging.SqlalchemyPaginator(query, kwargs['per_page'])
    return paginator.get_page(kwargs['page'])


def extend(*dicts):
    ret = {}
    for each in dicts:
        ret.update(each)
    return ret
