import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import TSVECTOR

from webservices.partition.base import TableGroup

class SchedBGroup(TableGroup):

    parent = 'fec_fitem_sched_b_vw'
    base_name = 'ofec_sched_b'
    queue_new = 'ofec_sched_b_queue_new'
    queue_old = 'ofec_sched_b_queue_old'
    primary = 'sub_id'
    transaction_date_column = 'disb_dt'

    columns = [
        sa.Column('timestamp', sa.DateTime),
        sa.Column('pg_date', sa.DateTime),
        sa.Column('pdf_url', sa.Text),
        sa.Column('recipient_name_text', TSVECTOR),
        sa.Column('disbursement_description_text', TSVECTOR),
        sa.Column('disbursement_purpose_category', sa.String),
        sa.Column('clean_recipient_cmte_id', sa.String),
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
                sa.func.concat(parent.c.recipient_nm, ' ', parent.c.recipient_cmte_id),
            ).label('recipient_name_text'),
            sa.func.to_tsvector(parent.c.disb_desc).label('disbursement_description_text'),
            sa.func.disbursement_purpose(
                parent.c.disb_tp,
                parent.c.disb_desc,
            ).label('disbursement_purpose_category'),
            sa.func.clean_repeated(
                parent.c.recipient_cmte_id,
                parent.c.cmte_id,
            ).label('clean_recipient_cmte_id'),
        ]
