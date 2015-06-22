import sqlalchemy as sa

from webservices.exceptions import ApiError


def parse_option(option, model=None):
    """Parse sort option to SQLAlchemy order expression.

    :param str option: Column name, possibly prefixed with "-"
    :param model: Optional SQLAlchemy model to sort on
    :raises: ApiError if column not found on model
    """
    order = sa.desc if option.startswith('-') else sa.asc
    column = option.lstrip('-')
    if model:
        try:
            column = getattr(model, column)
        except AttributeError:
            raise ApiError('Field "{0}" not found'.format(column))
    return order(column)


def ensure_list(value):
    if isinstance(value, list):
        return value
    if value:
        return [value]
    return []


def sort(query, options, model=None, clear=False):
    if clear:
        query = query.order_by(False)
    options = ensure_list(options)
    for option in options:
        order = parse_option(option, model=model)
        query = query.order_by(order)
    return query
