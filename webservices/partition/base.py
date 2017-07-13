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

            insert_select = sa.select(
                cls.recast_columns(queue_new) + cls.column_factory(queue_new)
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
