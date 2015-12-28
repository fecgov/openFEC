import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import TSVECTOR

from webservices.rest import db
from webservices.partition.base import TableGroup

class SchedAGroup(TableGroup):

    parent = 'sched_a'
    base_name = 'ofec_sched_a'
    primary = 'sched_a_sk'

    columns = [
        sa.Column('timestamp', sa.DateTime),
        sa.Column('contributor_name_text', TSVECTOR),
        sa.Column('contributor_employer_text', TSVECTOR),
        sa.Column('contributor_occupation_text', TSVECTOR),
        sa.Column('is_individual', sa.Boolean),
        sa.Column('clean_contbr_id', sa.String),
    ]

    @classmethod
    def column_factory(cls, parent):
        return [
            sa.cast(None, sa.DateTime).label('timestamp'),
            sa.func.to_tsvector(parent.c.contbr_nm).label('contributor_name_text'),
            sa.func.to_tsvector(parent.c.contbr_employer).label('contributor_employer_text'),
            sa.func.to_tsvector(parent.c.contbr_occupation).label('contributor_occupation_text'),
            sa.func.is_individual(
                parent.c.contb_receipt_amt,
                parent.c.receipt_tp,
                parent.c.line_num,
                parent.c.memo_cd,
                parent.c.memo_text,
            ).label('is_individual'),
            sa.func.clean_repeated(
                parent.c.contbr_id,
                parent.c.cmte_id,
            ).label('clean_contbr_id'),
        ]

    @classmethod
    def index_factory(cls, child):
        c = child.c
        return [
            sa.Index(None, c.rpt_yr),
            sa.Index(None, c.entity_tp),
            sa.Index(None, c.image_num),
            sa.Index(None, c.sched_a_sk),
            sa.Index(None, c.contbr_st),
            sa.Index(None, c.contbr_city),
            sa.Index(None, c.is_individual),
            sa.Index(None, c.clean_contbr_id),

            sa.Index(None, c.contb_receipt_amt, child.c.sched_a_sk),
            sa.Index(None, c.contb_receipt_dt, child.c.sched_a_sk),
            sa.Index(None, c.contb_aggregate_ytd, child.c.sched_a_sk),

            sa.Index(None, c.cmte_id, c.sched_a_sk),
            sa.Index(None, c.cmte_id, c.contb_receipt_amt, c.sched_a_sk),
            sa.Index(None, c.cmte_id, c.contb_receipt_dt, c.sched_a_sk),
            sa.Index(None, c.cmte_id, c.contb_aggregate_ytd, c.sched_a_sk),

            sa.Index(None, c.contributor_name_text, postgresql_using='gin'),
            sa.Index(None, c.contributor_employer_text, postgresql_using='gin'),
            sa.Index(None, c.contributor_occupation_text, postgresql_using='gin'),
        ]

    @classmethod
    def update_child(cls, child):
        cmd = 'alter table {0} alter column contbr_st set statistics 1000'.format(child.name)
        db.engine.execute(cmd)
