import sqlalchemy as sa


def parse_option(option):
    order = sa.desc if option.startswith('-') else sa.asc
    column = option.lstrip('-')
    return order, column

def sort(query, options, clear=False):
    if clear:
        query = query.order_by(False)
    for option in options:
        order, column = parse_option(option)
        query = query.order_by(order(column))
    return query
