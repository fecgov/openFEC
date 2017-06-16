import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import TSVECTOR

from webservices.rest import db
from webservices.partition.base import TableGroup

class SchedAGroup(TableGroup):

    parent = 'fec_vsum_sched_a_vw'
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
            sa.func.get_transaction_year(
                parent.c[cls.transaction_date_column],
                parent.c.rpt_yr
            ).label('two_year_transaction_period'),
        ]

    @classmethod
    def index_factory(cls, child):
        c = child.c
        return [
            sa.Index(None, c.rpt_yr),
            sa.Index(None, c.pg_date),
            sa.Index(None, c.entity_tp),
            sa.Index(None, c.image_num),
            sa.Index(None, c.contbr_st),
            sa.Index(None, c.contbr_city),
            sa.Index(None, c.is_individual),
            sa.Index(None, c.clean_contbr_id),
            sa.Index(None, c.two_year_transaction_period),

            sa.Index('ix_{0}_sub_id_amount_tmp'.format(child.name[:-4]), c.contb_receipt_amt, child.c[cls.primary]),
            sa.Index('ix_{0}_sub_id_date_tmp'.format(child.name[:-4]), c.contb_receipt_dt, child.c[cls.primary]),

            sa.Index('ix_{0}_cmte_id_tmp'.format(child.name[:-4]), c.cmte_id, c[cls.primary]),
            sa.Index('ix_{0}_cmte_id_amount_tmp'.format(child.name[:-4]), c.cmte_id, c.contb_receipt_amt, c[cls.primary]),
            sa.Index('ix_{0}_cmte_id_date_tmp'.format(child.name[:-4]), c.cmte_id, c.contb_receipt_dt, c[cls.primary]),

            sa.Index(None, c.contributor_name_text, postgresql_using='gin'),
            sa.Index(None, c.contributor_employer_text, postgresql_using='gin'),
            sa.Index(None, c.contributor_occupation_text, postgresql_using='gin'),
        ]

    @classmethod
    def update_child(cls, child):
        cmd = 'alter table {0} alter column contbr_st set statistics 1000'.format(child.name)
        db.engine.execute(cmd)

    @classmethod
    def create_trigger(cls):
        db.engine.execute('DROP TRIGGER IF EXISTS insert_sched_a_trigger ON ofec_sched_a_master')
        db.engine.execute('''
            CREATE trigger insert_sched_a_trigger BEFORE INSERT ON ofec_sched_a_master FOR EACH ROW EXECUTE PROCEDURE insert_sched_master('ofec_sched_a_');
            ''')
