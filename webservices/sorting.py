import sqlalchemy as sa

from webservices.exceptions import ApiError
from webservices.common.util import get_class_by_tablename


def parse_option(option, model=None, aliases=None, join_columns=None, query=None):
    """Parse sort option to SQLAlchemy order expression.

    :param str option: Column name, possibly prefixed with "-"
    :param model: Optional SQLAlchemy model to sort on
    :param join_columns: Mapping of column names to sort and join rules; used
        for sorting on related columns
    :raises: ApiError if column not found on model
    """
    aliases = aliases or {}
    join_columns = join_columns or {}
    order = sa.desc if option.startswith('-') else sa.asc
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
    else:
        for entity in query._entities:
            if entity._label_name == column:
                single_model = get_class_by_tablename(entity.namespace)
                if not single_model:
                    column = entity.column
                    break
                column = getattr(single_model, column)
                break
        return column, order, relationship
    return column, order, relationship


def multi_sort(query, keys, model, aliases=None, join_columns=None, clear=False,
               hide_null=False, index_column=None, nulls_last=False):
    for key in keys:
        query, _ = sort(query, key, model, aliases, join_columns, clear, hide_null, index_column, nulls_last)
    return query, _


def sort(query, key, model, aliases=None, join_columns=None, clear=False,
         hide_null=False, index_column=None, nulls_last=False):
    """Sort query using string-formatted columns.

    :param query: Original query
    :param options: Sort column name; prepend with "-" for descending sort
    :param model: SQLAlchemy model
    :param join_columns: Mapping of column names to sort and join rules; used
        for sorting on related columns
    :param clear: Clear existing sort conditions
    :param hide_null: Exclude null values on sorted column(s)
    :param index_column:
    :param nulls_last: Sort null values on sorted column(s) last in results;
        Ignored if hide_null is True
    """

    # Start off assuming we are dealing with a sort column, not a sort
    # expression.
    is_expression = False
    expression_field = None
    expression_type = None
    null_sort = None

    if clear:
        query = query.order_by(False)
    # If the query contains multiple entities (i.e., isn't a simple query on a
    # model), looking up the sort key on the model may lead to invalid queries.
    # In this case, use the string name of the sort key.
    sort_model = (
        model
        # if len(query._entities) == 1 and hasattr(query._entities[0], 'mapper')
        # else None
    )
    column, order, relationship = parse_option(
        key,
        model=sort_model,
        aliases=aliases,
        join_columns=join_columns,
        query=query
    )

    # Store the text representation (name) of the sorting column in case we
    # swap it for an expression instead.
    if hasattr(column, 'key'):
        column_name = column.key
    else:
        column_name = column

    sort_column = order(column)
    if nulls_last and not hide_null:
        query = query.order_by(sa.nullslast(sort_column))
    else:
        query = query.order_by(sort_column)

    if relationship:
        query = query.join(relationship)
    if hide_null:
        query = query.filter(column != None)  # noqa

    return query, (
        column,
        order,
        column_name,
        is_expression,
        expression_field,
        expression_type,
        null_sort,
    )
