import sqlalchemy as sa
from sqlalchemy.ext.compiler import compiles
from sqlalchemy.sql.expression import ClauseElement, Executable

from webservices.rest import db


# Adapted from http://stackoverflow.com/a/30577608/1222326

class TempTableAs(Executable, ClauseElement):

    def __init__(cls, name, query):
        cls.name = name
        cls.query = query


@compiles(TempTableAs, 'postgresql')
def _create_table_as(element, compiler, **kwargs):
    return 'create temporary table {0} as {1}'.format(
        element.name,
        compiler.process(element.query),
    )


def load_table(name, autoload_with=None):
    return sa.Table(name, db.metadata, autoload=True, autoload_with=autoload_with or db.engine)


class IncrementalAggregate(object):

    @classmethod
    def run(cls, conn=None):
        conn = conn or db.engine.connect()
        queues = cls.queues()
        queued = cls.queued(queues).alias()
        group_column = cls.group_column_factory(queued)
        aggregate_table = load_table(cls.aggregate_table)
        patch = cls.patch(group_column, queued, conn)
        conn.execute(cls.update(group_column, aggregate_table, patch))
        conn.execute(cls.create(group_column, aggregate_table, patch))
        patch.drop(conn)

    @classmethod
    def queued(cls, queues):
        new = sa.select(
            [sa.sql.literal(-1).label('multiplier')] +
            list(queues['old'].columns)
        )
        old = sa.select(
            [sa.sql.literal(1).label('multiplier')] +
            list(queues['new'].columns)
        )
        return sa.union(new, old)

    @classmethod
    def patch(cls, group_column, queued, conn):
        select = sa.select([
            queued.c.cmte_id,
            (queued.c.rpt_yr + queued.c.rpt_yr % 2).label('cycle'),
            sa.func.sum(queued.c.multiplier * getattr(queued.c, cls.total_column)).label('total'),
            sa.func.sum(queued.c.multiplier).label('count'),
            group_column,
        ] + cls.extra_columns_factory(queued)).where(
            getattr(queued.c, cls.total_column) != None,  # noqa
        ).where(
            sa.or_(
                queued.c.memo_cd != 'X',
                queued.c.memo_cd == None,
            ),
        ).group_by(
            queued.c.cmte_id,
            'cycle',
            group_column.name,
        )
        where = cls.where_factory(queued)
        if where is not None:
            select = select.where(where)
        temp_name = 'temp_{0}'.format(cls.aggregate_table)
        create_temp = TempTableAs(temp_name, select)
        conn.execute(create_temp)
        return load_table(temp_name, autoload_with=conn)

    @classmethod
    def create(cls, group_column, aggregate_table, patch):
        select = sa.select(patch.c).select_from(
            patch.outerjoin(
                aggregate_table,
                sa.and_(
                    patch.c.cmte_id == aggregate_table.c.cmte_id,
                    patch.c.cycle == aggregate_table.c.cycle,
                    getattr(patch.c, group_column.name) == getattr(aggregate_table.c, group_column.name),
                )
            )
        ).where(
            aggregate_table.c.cmte_id == None  # noqa
        )
        return aggregate_table.insert().from_select(patch.c, select)

    @classmethod
    def update(cls, group_column, aggregate_table, patch):
        return sa.sql.update(
            aggregate_table
        ).where(
            aggregate_table.c.cmte_id == patch.c.cmte_id
        ).where(
            aggregate_table.c.cycle == patch.c.cycle
        ).where(
            getattr(aggregate_table.c, group_column.name) == getattr(patch.c, group_column.name)
        ).values(
            total=aggregate_table.c.total + patch.c.total,
            count=aggregate_table.c.count + patch.c.count,
        )

    @classmethod
    def group_column_factory(cls, queued):
        pass

    @classmethod
    def extra_columns_factory(cls, queued):
        return []

    @classmethod
    def where_factory(cls, queued):
        pass


class ScheduleAAggregate(IncrementalAggregate):

    total_column = 'contb_receipt_amt'

    @classmethod
    def queues(cls):
        return {
            'old': load_table('ofec_sched_a_queue_old'),
            'new': load_table('ofec_sched_a_queue_new'),
        }


class ScheduleBAggregate(IncrementalAggregate):

    total_column = 'disb_amt'

    @classmethod
    def queues(cls):
        return {
            'old': load_table('ofec_sched_b_queue_old'),
            'new': load_table('ofec_sched_b_queue_new'),
        }


class ScheduleAStateAggregate(ScheduleAAggregate):

    aggregate_table = 'ofec_sched_a_aggregate_state'

    @classmethod
    def group_column_factory(cls, queued):
        return queued.c.contbr_st.label('state')

    @classmethod
    def extra_columns_factory(cls, queued):
        return [sa.func.expand_state(queued.c.contbr_st).label('state_full')]


class ScheduleAZipAggregate(ScheduleAAggregate):

    aggregate_table = 'ofec_sched_a_aggregate_zip'

    @classmethod
    def group_column_factory(cls, queued):
        return queued.c.contbr_zip.label('zip')

    @classmethod
    def extra_columns_factory(cls, queued):
        return [
            sa.func.max(queued.c.contbr_st).label('state'),
            sa.func.expand_state(sa.func.max(queued.c.contbr_st)).label('state_full'),
        ]


class ScheduleAEmployerAggregate(ScheduleAAggregate):

    aggregate_table = 'ofec_sched_a_aggregate_employer'

    @classmethod
    def group_column_factory(cls, queued):
        return queued.c.contbr_employer.label('employer')


class ScheduleAOccupationAggregate(ScheduleAAggregate):

    aggregate_table = 'ofec_sched_a_aggregate_occupation'

    @classmethod
    def group_column_factory(cls, queued):
        return queued.c.contbr_occupation.label('occupation')


class ScheduleASizeAggregate(ScheduleAAggregate):

    aggregate_table = 'ofec_sched_a_aggregate_size'

    @classmethod
    def group_column_factory(cls, queued):
        return sa.func.contribution_size(queued.c.contb_receipt_amt).label('size')


class ScheduleBRecipientAggregate(ScheduleBAggregate):

    aggregate_table = 'ofec_sched_b_aggregate_recipient'

    @classmethod
    def group_column_factory(cls, queued):
        return queued.c.recipient_nm.label('recipient_nm')


class ScheduleBRecipientIDAggregate(ScheduleBAggregate):

    aggregate_table = 'ofec_sched_b_aggregate_recipient_id'

    @classmethod
    def group_column_factory(cls, queued):
        return queued.c.recipient_cmte_id

    @classmethod
    def extra_columns_factory(cls, queued):
        return [sa.func.max(queued.c.recipient_nm).label('recipient_nm')]

    @classmethod
    def where_factory(cls, queued):
        return queued.c.recipient_cmte_id != None  # noqa


aggregates = [
    ScheduleASizeAggregate,
    ScheduleAStateAggregate,
    ScheduleAZipAggregate,
    ScheduleAEmployerAggregate,
    ScheduleAOccupationAggregate,
    ScheduleBRecipientAggregate,
    ScheduleBRecipientIDAggregate,
]


def update_all(conn=None):
    for aggregate in aggregates:
        aggregate.run(conn=conn)
