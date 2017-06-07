import logging

import sqlalchemy as sa

from webservices.rest import db
from webservices.config import SQL_CONFIG

from . import utils

logger = logging.getLogger('partitioner')
logging.basicConfig(level=logging.INFO)

def get_cycles():
    return range(
        SQL_CONFIG['START_YEAR'] - 1,
        SQL_CONFIG['END_YEAR_ITEMIZED'] + 3,
        2,
    )
    #return range(1978, 1980, 2)

class TableGroup:

    parent = None
    base_name = None
    queue_new = None
    queue_old = None
    primary = None
    transaction_date_column = None

    columns = []
    column_mappings = {}

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
    def redefine_columns(cls, parent):
        """Redefines columns in a table definition that are not the type that
        we expect in the parent table/view.

        This is intended to be used when creating the master table of a
        partition, which is when the structure of the table is derived
        directly and solely from the parent/source table/view.
        """

        for column_name, cast_type in cls.column_mappings.items():
            parent.c[column_name].type = cast_type

        return parent

    @classmethod
    def recast_columns(cls, parent):
        """Recasts columns in a table definition that are not the type that
        we expect in the parent table/view.

        This is intended to be used when creating the child tables that
        inherit from the master table in a partition, which is when the
        structure of the table is partially derived from the parent/source
        table/view but also modified to represent the actual data that will
        live within the child table.

        This is also used for accessing the data found in the queue tables for
        a refresh due to the fact that they also may have unknown/incorrect
        column types.
        """

        columns = [
            column for column in parent.columns
            if column.name not in cls.column_mappings.keys()
        ]

        for column_name, cast_type in cls.column_mappings.items():
            columns.append(
                sa.cast(parent.c[column_name], cast_type).label(column_name)
            )

        return columns

    @classmethod
    def run(cls):
        parent = utils.load_table(cls.parent)
        cls.create_master(parent)
        cycles = get_cycles()

        for cycle in cycles:
            cls.create_child(parent, cycle)

        cls.rename()
        cls.create_trigger()

    @classmethod
    def add_cycles(cls, cycle, amount):
        """Adds new child tables to an existing partition.
        Note:  Will not override existing tables.
        """

        parent = utils.load_table(cls.parent)

        # Calculate all of the cycles to be added at once.
        cycles = [cycle + i for i in range(0, amount * 2, 2)]

        for cycle in cycles:
            child_name = cls.get_child_name(cycle)

            if utils.load_table(child_name) is None:
                cls.create_child(parent, cycle, False)
                cls.rename_child(cycle)
                logger.info(
                    'Successfully added cycle {cycle} as {name}.'.format(
                        cycle=cycle,
                        name=child_name
                    )
                )
            else:
                logger.warn(
                    'Cycle {cycle} already exists as {name}; skipping.'.format(
                        cycle=cycle,
                        name=child_name
                    )
                )

    @classmethod
    def get_child_name(cls, cycle):
        return '{base}_{start}_{stop}'.format(
            base=cls.base_name,
            start=cycle - 1,
            stop=cycle,
        )

    @classmethod
    def create_master(cls, parent):
        parent = cls.redefine_columns(parent)
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
    def create_child(cls, parent, cycle, temp=True):
        start, stop = cycle - 1, cycle
        name = '{base}_{start}_{stop}_tmp'.format(
            base=cls.base_name,
            start=start,
            stop=stop
        )

        select = sa.select(
            cls.recast_columns(parent) + cls.timestamp_factory(parent) + cls.column_factory(parent)
        ).where(
            sa.func.cast(
                sa.func.get_cycle(parent.c.rpt_yr), sa.SmallInteger
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

        cls.create_constraints(child, cycle, temp)
        cls.create_indexes(child)
        cls.update_child(child)
        db.engine.execute(utils.Analyze(child))
        logger.info(
            'Successfully created child table {base}_{start}_{stop}.'.format(
                base=cls.base_name,
                start=start,
                stop=stop
            )
        )
        return child

    @classmethod
    def create_constraints(cls, child, cycle, temp=True):
        start, stop = cycle - 1, cycle
        master_name = '_tmp' if temp else ''
        cmds = [
            'alter table {child} alter column {primary} set not null',
            'alter table {child} add primary key ({primary})',
            'alter table {child} alter column filing_form set not null',
            'alter table {child} add constraint check_two_year_transaction_period check (two_year_transaction_period in ({start}, {stop}))',  # noqa
            'alter table {child} inherit {master}'
        ]
        params = {
            'start': start,
            'stop': stop,
            'child': child.name,
            'master': '{0}_master{1}'.format(cls.base_name, master_name),
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
        # Rename master table
        cls.rename_master()

        # Rename child tables
        for cycle in get_cycles():
            cls.rename_child(cycle)

    @classmethod
    def rename_master(cls):
        cmds = [
            'drop table if exists {0}_master cascade',
            'alter table {0}_master_tmp rename to {0}_master',
        ]

        for cmd in cmds:
            db.engine.execute(cmd.format(cls.base_name))

    @classmethod
    def rename_child(cls, cycle):
        child_name = cls.get_child_name(cycle)
        cmd = 'alter table {0}_tmp rename to {0}'.format(child_name)
        db.engine.execute(cmd)
        child = utils.load_table(child_name)

        # Rename child table primary key
        cmd = 'alter index {0} rename to {1}'.format(
            child.primary_key.name,
            child.primary_key.name.replace('_tmp', '')
        )
        db.engine.execute(cmd)

        # Rename child table indexes
        for index in child.indexes:
            cmd = 'alter index {0} rename to {1}'.format(
                index.name, index.name.replace('_tmp', '')
            )
            db.engine.execute(cmd)

    @classmethod
    def process_queues(cls):
        queue_old = utils.load_table(cls.queue_old)
        queue_new = utils.load_table(cls.queue_new)

        output_message = (0, '')
        name = '{base}_master'.format(base=cls.base_name)
        master_table = utils.load_table(name)
        connection = db.engine.connect()
        transaction = connection.begin()

        try:
            delete_select = sa.select([queue_old.c.get(cls.primary)])
            delete = sa.delete(master_table).where(
                master_table.c.get(cls.primary).in_(delete_select)
            )
            connection.execute(delete)

            # The queue tables already have the two_year_transaction_period
            # column set in them so that we can insert the records into the
            # proper child table. Because of this, we need to exclude the
            # function call in the column factory normally used when
            # populating the child tables during normal partitioning.
            # Otherwise, an error is thrown due more values being specified
            # than there are columns to accept them.
            # VM TODO - Is this still needed?
            columns = [
                column for column in cls.column_factory(queue_new)
                if column.name != 'two_year_transaction_period'
            ]

            insert_select = sa.select(
                cls.recast_columns(queue_new) + columns
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
                queue_old.c.get(cls.primary) == None  # noqa
            ).distinct(
                queue_new.c.get(cls.primary)
            )
            insert = sa.insert(master_table).from_select(
                insert_select.columns,
                insert_select
            )
            connection.execute(insert)

            # Clear the processed records out of the queues.
            cls.clear_queue(queue_old, delete_select, connection)
            cls.clear_queue(queue_new, insert_select.with_only_columns(
                [queue_new.c.get(cls.primary)]
            ), connection)

            transaction.commit()
            output_message = (
                0,
                'Successfully refreshed {name}.'.format(name=name),
            )
            logger.info(output_message[1])
        except Exception as e:
            transaction.rollback()

            output_message = (
                1,
                'Refreshing {name} failed: {error}'.format(
                    name=name,
                    error=e
                ),
            )
            logger.error(output_message[1])

        connection.close()
        return output_message

    @classmethod
    def clear_queue(cls, queue, record_ids, connection):
        delete = sa.delete(queue).where(
            queue.c.get(cls.primary).in_(record_ids)
        )
        connection.execute(delete)
