import sqlalchemy as sa

from webservices.rest import db
from webservices.config import SQL_CONFIG

from . import utils

class TableGroup:

    parent = None
    base_name = None
    primary = None

    columns = []

    @classmethod
    def column_factory(cls, parent):
        return []

    @classmethod
    def index_factory(cls, child):
        return []

    @classmethod
    def update_child(cls, child):
        pass

    @classmethod
    def run(cls):
        parent = utils.load_table(cls.parent)
        cls.create_master(parent)
        cycles = range(
            SQL_CONFIG['START_YEAR_ITEMIZED'] - 1,
            SQL_CONFIG['END_YEAR_ITEMIZED'] + 3,
            2,
        )
        for cycle in cycles:
            cls.create_child(parent, cycle)

    @classmethod
    def create_master(cls, parent):
        name = '{0}_master'.format(cls.base_name)
        table = sa.Table(
            name,
            db.metadata,
            *([column.copy() for column in parent.columns] + cls.columns)
        )
        db.engine.execute('drop table if exists {0} cascade'.format(name))
        table.create(db.engine)

    @classmethod
    def create_child(cls, parent, cycle):
        start, stop = cycle - 1, cycle
        select = sa.select(
            parent.columns + cls.column_factory(parent)
        ).where(
            parent.c.rpt_yr.in_([start, stop]),
        )
        name = '{base}_{start}_{stop}'.format(base=cls.base_name, start=start, stop=stop)

        child = utils.load_table(name)
        if child is not None:
            child.drop(db.engine)
        create = utils.TableAs(name, select)
        db.engine.execute(create)
        child = utils.load_table(name)
        cls.create_constraints(child, cycle)
        cls.create_indexes(child)
        cls.update_child(child)
        return child

    @classmethod
    def create_constraints(cls, child, cycle):
        start, stop = cycle - 1, cycle
        cmds = [
            'alter table {child} alter column {primary} set not null',
            'alter table {child} alter column load_date set not null',
            'alter table {child} add constraint check_rpt_yr check (rpt_yr in ({start}, {stop}))',
            'alter table {child} inherit {master}'
        ]
        params = {
            'start': start,
            'stop': stop,
            'child': child.name,
            'master': '{0}_master'.format(cls.base_name),
            'primary': cls.primary,
        }
        for cmd in cmds:
            db.engine.execute(cmd.format(**params))

    @classmethod
    def create_indexes(cls, child):
        for index in cls.index_factory(child):
            try:
                index.drop(db.engine)
            except sa.exc.ProgrammingError:
                pass
            index.create(db.engine)

    @classmethod
    def update_children(cls):
        pass
