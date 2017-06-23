import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import TSVECTOR

from webservices.partition.base import TableGroup

class SchedAGroup(TableGroup):

    parent = 'fec_fitem_sched_a_vw'
    base_name = 'ofec_sched_a'
    queue_new = 'ofec_sched_a_queue_new'
    queue_old = 'ofec_sched_a_queue_old'
    primary = 'sub_id'
    transaction_date_column = 'contb_receipt_dt'

    columns = [
        sa.Column('timestamp', sa.DateTime),
        sa.Column('pg_date', sa.DateTime),
        sa.Column('pdf_url', sa.Text),
        sa.Column('contributor_name_text', TSVECTOR),
        sa.Column('contributor_employer_text', TSVECTOR),
        sa.Column('contributor_occupation_text', TSVECTOR),
        sa.Column('is_individual', sa.Boolean),
        sa.Column('clean_contbr_id', sa.String),
        sa.Column('two_year_transaction_period', sa.SmallInteger),
        sa.Column('line_number_label', sa.Text),
    ]

    column_mappings = {
        'schedule_type': sa.VARCHAR(length=2)
    }

    @classmethod
    def column_factory(cls, parent):
        return [
            sa.cast(sa.func.current_timestamp(), sa.DateTime).label('pg_date'),
            sa.func.image_pdf_url(parent.c.image_num).label('pdf_url'),
            sa.func.to_tsvector(
                sa.func.concat(parent.c.contbr_nm, ' ', parent.c.contbr_id),
            ).label('contributor_name_text'),
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
