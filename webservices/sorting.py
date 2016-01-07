import sqlalchemy as sa
from sqlalchemy.sql.expression import nullsfirst, nullslast

from webservices.exceptions import ApiError


def parse_option(option, model=None, aliases=None, join_columns=None, nulls_large=True):
    """Parse sort option to SQLAlchemy order expression.

    :param str option: Column name, possibly prefixed with "-"
    :param model: Optional SQLAlchemy model to sort on
    :param join_columns: Mapping of column names to sort and join rules; used
        for sorting on related columns
    :param nulls_large: Treat null values as large
    :raises: ApiError if column not found on model
    """
    aliases = aliases or {}
    join_columns = join_columns or {}
    order = sa.desc if option.startswith('-') else sa.asc
    nulls = nullsfirst if (nulls_large ^ (not option.startswith('-'))) else nullslast
    column = option.lstrip('-')
    relationship = None
    if column in aliases:
        column = aliases[column]
    elif column in join_columns:
        column, relationship = join_columns[column]
    elif model:
        try:
            column = getattr(model, column)
        except AttributeError:
            raise ApiError('Field "{0}" not found'.format(column))
    return column, order, nulls, relationship


def ensure_list(value):
    if isinstance(value, list):
        return value
    if value:
        return [value]
    return []


def sort(query, options, model, aliases=None, join_columns=None, clear=False, hide_null=False, nulls_large=True):
    """Sort query using string-formatted columns.

    :param query: Original query
    :param options: String or list of strings of column names; prepend with "-"
        for descending sort
    :param model: SQLAlchemy model
    :param join_columns: Mapping of column names to sort and join rules; used
        for sorting on related columns
    :param clear: Clear existing sort conditions
    :param hide_null: Exclude null values on sorted column(s)
    :param nulls_large: Treat null values as large on sorted column(s)
    """
    if clear:
        query = query.order_by(False)
    options = ensure_list(options)
    columns = []
    # If the query contains multiple entities (i.e., isn't a simple query on a
    # model), looking up the sort key on the model may lead to invalid queries.
    # In this case, use the string name of the sort key.
    sort_model = (
        model
        if len(query._entities) == 1 and hasattr(query._entities[0], 'mapper')
        else None
    )
    for option in options:
        column, order, nulls, relationship = parse_option(
            option,
            model=sort_model,
            aliases=aliases,
            join_columns=join_columns,
            nulls_large=nulls_large,
        )
        query = query.order_by(nulls(order(column)))
        if relationship:
            query = query.join(relationship)
        if hide_null:
            query = query.filter(column != None)  # noqa
        columns.append((column, order))
    return query, columns
