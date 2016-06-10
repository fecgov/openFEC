import sqlalchemy as sa

from webservices.rest import db
from webservices.config import SQL_CONFIG

from . import utils

def get_cycles():
    return range(
        SQL_CONFIG['START_YEAR'] - 1,
        SQL_CONFIG['END_YEAR_ITEMIZED'] + 3,
        2,
    )

class TableGroup:

    parent = None
    base_name = None
    queue_new = None
    queue_old = None
    primary = None
    transaction_date_column = None

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
    def timestamp_factory(cls, parent):
        return [
            sa.cast(None, sa.DateTime).label('timestamp'),
        ]

    @classmethod
    def run(cls):
        parent = utils.load_table(cls.parent)
        cls.create_master(parent)
        cycles = get_cycles()
        for cycle in cycles:
            cls.create_child(parent, cycle)
        cls.rename()

    @classmethod
    def get_child_name(cls, cycle):
        return '{base}_{start}_{stop}'.format(
            base=cls.base_name,
            start=cycle - 1,
            stop=cycle,
        )

    @classmethod
    def create_master(cls, parent):
        name = '{0}_master_tmp'.format(cls.base_name)
        table = sa.Table(
            name,
            db.metadata,
            extend_existing=True,
            *([column.copy() for column in parent.columns] + cls.columns)
        )
        db.engine.execute('drop table if exists {0} cascade'.format(name))
        table.create(db.engine)

    @classmethod
    def create_child(cls, parent, cycle):
        start, stop = cycle - 1, cycle
        name = '{base}_{start}_{stop}_tmp'.format(base=cls.base_name, start=start, stop=stop)

        select = sa.select(
            parent.columns + cls.timestamp_factory(parent) + cls.column_factory(parent)
        ).where(
            sa.func.get_transaction_year(
                parent.c[cls.transaction_date_column],
                parent.c.rpt_yr
            ).in_([start, stop]),
        )

        child = utils.load_table(name)
        if child is not None:
            try:
                child.drop(db.engine)
            except sa.exc.ProgrammingError:
                pass
        create = utils.TableAs(name, select)
        db.engine.execute(create)
        child = utils.load_table(name)

        cls.create_constraints(child, cycle)
        cls.create_indexes(child)
        cls.update_child(child)
        db.engine.execute(utils.Analyze(child))
        return child

    @classmethod
    def create_constraints(cls, child, cycle):
        start, stop = cycle - 1, cycle
        cmds = [
            'alter table {child} alter column {primary} set not null',
            'alter table {child} alter column load_date set not null',
            'alter table {child} add constraint check_transaction_year check (transaction_year in ({start}, {stop}))',
            'alter table {child} inherit {master}'
        ]
        params = {
            'start': start,
            'stop': stop,
            'child': child.name,
            'master': '{0}_master_tmp'.format(cls.base_name),
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
    def rename(cls):
        cmds = [
            'drop table if exists {0}_master cascade',
            'alter table {0}_master_tmp rename to {0}_master',
        ]
        for cmd in cmds:
            db.engine.execute(cmd.format(cls.base_name))
        for cycle in get_cycles():
            cmd = 'alter table {0}_tmp rename to {0}'.format(cls.get_child_name(cycle))
            db.engine.execute(cmd)

    @classmethod
    def refresh_children(cls):
        queue_old = utils.load_table(cls.queue_old)
        queue_new = utils.load_table(cls.queue_new)
        cycles = get_cycles()
        for cycle in cycles:
            cls.refresh_child(cycle, queue_old, queue_new)

    @classmethod
    def refresh_child(cls, cycle, queue_old, queue_new):
        start, stop = cycle - 1, cycle
        name = '{base}_{start}_{stop}'.format(base=cls.base_name, start=start, stop=stop)
        child = utils.load_table(name)

        select = sa.select([queue_old.c.get(cls.primary)])
        delete = sa.delete(child).where(child.c.get(cls.primary).in_(select))
        db.engine.execute(delete)

        select = sa.select(
            queue_new.columns + cls.column_factory(queue_new)
        ).select_from(
            queue_new.join(
                queue_old,
                sa.and_(
                    queue_new.c.get(cls.primary) == queue_old.c.get(cls.primary),
                    queue_old.c.timestamp > queue_new.c.timestamp,
                ),
                isouter=True,
            )
        ).where(
            queue_new.c.rpt_yr.in_([start, stop])
        ).where(
            queue_old.c.get(cls.primary) == None  # noqa
        ).distinct(
            queue_new.c.get(cls.primary)
        )
        insert = sa.insert(child).from_select(select.columns, select)
        db.engine.execute(insert)
