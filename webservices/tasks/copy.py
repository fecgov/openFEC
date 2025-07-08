from sqlalchemy import inspect
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.sql.operators import ColumnOperators


def query_entities(query):
    return sum(
        [desc_entities(desc) for desc in query.column_descriptions],
        []
    )


def desc_entities(desc):
    expr, name = desc['expr'], desc['name']

    # ORM entities have a "_entity_zero" attribute in Sqlalchemy 2.0
    if hasattr(expr, "_entity_zero"):
        mapper = inspect(expr).mapper
        return mapper_entities(mapper)

    elif is_model(expr):
        mapper = inspect(expr)
        return mapper_entities(mapper)

    elif isinstance(expr, ColumnOperators):
        return [expr.label(name)]

    else:
        raise ValueError(f"Unrecognized query entity: {expr!r}")


def mapper_entities(mapper):
    model = mapper.class_
    return [
        getattr(model, prop.key).label(prop.key)
        for prop in mapper.column_attrs
    ]


def is_model(class_):
    try:
        inspect(class_)
        return True
    except SQLAlchemyError:
        return False


def format_flags(flags):
    return ', '.join(
        f"{key.upper()} {format_flag(value)}"
        for key, value in flags.items()
    )


def format_flag(value):
    if isinstance(value, bool):
        return str(value).upper()
    return repr(value)
