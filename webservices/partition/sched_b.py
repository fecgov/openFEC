import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import TSVECTOR

from webservices.rest import db
from webservices.partition.base import TableGroup

class SchedBGroup(TableGroup):

    parent = 'sched_b'
    base_name = 'ofec_sched_b'
    queue_new = 'ofec_sched_b_queue_new'
    queue_old = 'ofec_sched_b_queue_old'
    primary = 'sched_b_sk'
    transaction_date_column = 'disb_dt'

    columns = [
        sa.Column('timestamp', sa.DateTime),
        sa.Column('pdf_url', sa.Text),
        sa.Column('recipient_name_text', TSVECTOR),
        sa.Column('disbursement_description_text', TSVECTOR),
        sa.Column('disbursement_purpose_category', sa.String),
        sa.Column('clean_recipient_cmte_id', sa.String),
        sa.Column('transaction_year', sa.SmallInteger),
    ]

    @classmethod
    def column_factory(cls, parent):
        return [
            sa.func.image_pdf_url(parent.c.image_num).label('pdf_url'),
            sa.func.to_tsvector(parent.c.recipient_nm).label('recipient_name_text'),
            sa.func.to_tsvector(parent.c.disb_desc).label('disbursement_description_text'),
            sa.func.disbursement_purpose(
                parent.c.disb_tp,
                parent.c.disb_desc,
            ).label('disbursement_purpose_category'),
            sa.func.clean_repeated(
                parent.c.recipient_cmte_id,
                parent.c.cmte_id,
            ).label('clean_recipient_cmte_id'),
            sa.func.get_transaction_year(
                parent.c[cls.transaction_date_column],
                parent.c.rpt_yr
            ).label('transaction_year'),
        ]

    @classmethod
    def index_factory(cls, child):
        c = child.c
        return [
            sa.Index(None, c.rpt_yr),
            sa.Index(None, c.image_num),
            sa.Index(None, c.sched_b_sk),
            sa.Index(None, c.recipient_st),
            sa.Index(None, c.recipient_city),
            sa.Index(None, c.clean_recipient_cmte_id),
            sa.Index(None, c.transaction_year),

            sa.Index(None, c.disb_dt, c[cls.primary]),
            sa.Index(None, c.disb_amt, c[cls.primary]),

            sa.Index(None, c.cmte_id, c[cls.primary]),
            sa.Index(None, c.cmte_id, c.disb_dt, c[cls.primary]),
            sa.Index(None, c.cmte_id, c.disb_amt, c[cls.primary]),

            sa.Index(None, c.recipient_name_text, postgresql_using='gin'),
            sa.Index(None, c.disbursement_description_text, postgresql_using='gin'),
        ]

    @classmethod
    def update_child(cls, child):
        cmd = 'alter table {0} alter column recipient_st set statistics 1000'.format(child.name)
        db.engine.execute(cmd)
