"""Utilities for creating and dropping (materialized) views using SQLAlchemy.
"""

from sqlalchemy.schema import DDLElement
from sqlalchemy.ext import compiler

class CreateView(DDLElement):
    def __init__(self, name, select, materialized=False):
        self.name = name
        self.select = select
        self.materialized = materialized

class DropView(DDLElement):
    def __init__(self, name, materialized=False, if_exists=False):
        self.name = name
        self.materialized = materialized
        self.if_exists = if_exists

@compiler.compiles(CreateView)
def compile_create(element, compiler, **kw):
    return 'CREATE {} VIEW {} AS {}'.format(
        'MATERIALIZED' if element.materialized else '',
        element.name,
        compiler.sql_compiler.process(element.select, literal_binds=True),
    )

@compiler.compiles(DropView)
def compile_drop(element, compiler, **kw):
    return 'DROP {} VIEW {} {}'.format(
        'MATERIALIZED' if element.materialized else '',
        'IF EXISTS' if element.if_exists else '',
        element.name,
    )
