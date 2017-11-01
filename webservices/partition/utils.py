import sqlalchemy as sa
from sqlalchemy.schema import DDLElement
from sqlalchemy.ext.compiler import compiles
from sqlalchemy.sql.expression import UpdateBase

from webservices.rest import db

# Adapted from http://stackoverflow.com/a/30577608/1222326

class TableAs(UpdateBase):

    def __init__(cls, name, query, temporary=False):
        cls.name = name
        cls.query = query
        cls.temporary = temporary

@compiles(TableAs, 'postgresql')
def _create_table_as(element, compiler, **kwargs):
    return 'create {0} table {1} as {2}'.format(
        'temporary' if element.temporary else '',
        element.name,
        compiler.process(element.query),
    )

class Analyze(DDLElement):

    def __init__(self, table):
        self.table = table

@compiles(Analyze)
def _analyze(element, compiler, **kwargs):
    return 'analyze {0}'.format(element.table.name)

def load_table(name):
    try:
        print(name)
        return sa.Table(name, db.metadata, autoload_with=db.engine)
    except sa.exc.NoSuchTableError:
        return None
