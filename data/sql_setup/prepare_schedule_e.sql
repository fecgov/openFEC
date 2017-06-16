-- Create Schedule E table
drop table if exists ofec_sched_e_tmp;
create table ofec_sched_e_tmp as
select
    *,
    cast(null as timestamp) as timestamp,
    image_pdf_url(image_num) as pdf_url,
    coalesce(rpt_tp, '') in ('24', '48') as is_notice,
    to_tsvector(pye_nm) as payee_name_text,
    now() as pg_date
from fec_fitem_sched_e_vw;

alter table ofec_sched_e_tmp add primary key (sub_id);

create unique index idx_ofec_sched_e_sub_id_tmp on ofec_sched_e_tmp (sub_id);

-- Create simple indices on filtered columns
create index idx_ofec_sched_e_cmte_id_tmp on ofec_sched_e_tmp (cmte_id);
create index idx_ofec_sched_e_s_o_cand_id_tmp on ofec_sched_e_tmp (s_o_cand_id);
create index idx_ofec_sched_e_entity_tp_tmp on ofec_sched_e_tmp (entity_tp);
create index idx_ofec_sched_e_image_num_tmp on ofec_sched_e_tmp (image_num);
create index idx_ofec_sched_e_rpt_yr_tmp on ofec_sched_e_tmp (rpt_yr);
create index idx_ofec_sched_e_filing_form_tmp on ofec_sched_e_tmp (filing_form);
create index idx_ofec_sched_e_cycle_rpt_yr_tmp on ofec_sched_e_tmp (get_cycle(rpt_yr));
create index idx_ofec_sched_e_is_notice_tmp on ofec_sched_e_tmp (is_notice);
create index idx_ofec_sched_e_pg_date_tmp on ofec_sched_e_tmp (pg_date);

-- Create composite indices on sortable columns
create index idx_ofec_sched_e_exp_dt_sub_id_tmp on ofec_sched_e_tmp (exp_dt, sub_id);
create index idx_ofec_sched_e_exp_amt_sub_id_tmp on ofec_sched_e_tmp (exp_amt, sub_id);
create index idx_ofec_sched_e_cal_ytd_ofc_sought_sub_id_tmp on ofec_sched_e_tmp (cal_ytd_ofc_sought, sub_id);

-- Create indices on filtered fulltext columns
create index idx_ofec_sched_e_payee_name_text_tmp on ofec_sched_e_tmp using gin (payee_name_text);

-- Analyze tables
analyze ofec_sched_e_tmp;

-- Create table to hold sub_ids of records that fail during the nightly
-- processing so that they can be tried at a later time.
-- The "action" column denotes what should happen with the record:
--    insert, update, or delete
drop table if exists ofec_sched_e_nightly_retries;
create table ofec_sched_e_nightly_retries (
    sub_id numeric(19,0) not null primary key,
    action varchar(6) not null
);
create index on ofec_sched_e_nightly_retries (sub_id);

-- Create queue tables to hold changes to Schedule E
drop table if exists ofec_sched_e_queue_new;
drop table if exists ofec_sched_e_queue_old;

create table ofec_sched_e_queue_new as select * from fec_fitem_sched_e_vw limit 0;
create table ofec_sched_e_queue_old as select * from fec_fitem_sched_e_vw limit 0;

alter table ofec_sched_e_queue_new add column timestamp timestamp;
alter table ofec_sched_e_queue_old add column timestamp timestamp;
create index on ofec_sched_e_queue_new (sub_id);
create index on ofec_sched_e_queue_old (sub_id);
create index on ofec_sched_e_queue_new (timestamp);
create index on ofec_sched_e_queue_old (timestamp);


-- Support for processing of schedule A itemized records that need to be
-- retried.
create or replace function retry_processing_schedule_e_records(start_year integer) returns void as $$
declare
    timestamp timestamp = current_timestamp;
    view_row fec_fitem_sched_e_vw%ROWTYPE;
    schedule_e_record record;
begin
    for schedule_e_record in select * from ofec_sched_e_nightly_retries loop
        select into view_row * from fec_fitem_sched_e_vw where sub_id = schedule_e_record.sub_id;

        if FOUND then
            -- Determine which queue(s) the found record should go into.
            case schedule_e_record.action
                when 'insert' then
                    delete from ofec_sched_e_queue_new where sub_id = view_row.sub_id;
                    insert into ofec_sched_e_queue_new values (view_row.*, timestamp, two_year_transaction_period);

                    delete from ofec_sched_e_nightly_retries where sub_id = schedule_e_record.sub_id;
                when 'delete' then
                    delete from ofec_sched_e_queue_old where sub_id = view_row.sub_id;
                    insert into ofec_sched_e_queue_old values (view_row.*, timestamp);

                    delete from ofec_sched_e_nightly_retries where sub_id = schedule_e_record.sub_id;
                when 'update' then
                    delete from ofec_sched_e_queue_new where sub_id = view_row.sub_id;
                    delete from ofec_sched_e_queue_old where sub_id = view_row.sub_id;
                    insert into ofec_sched_e_queue_new values (view_row.*, timestamp);
                    insert into ofec_sched_e_queue_old values (view_row.*, timestamp);

                    delete from ofec_sched_e_nightly_retries where sub_id = schedule_e_record.sub_id;
                else
                    raise warning 'Invalid action supplied: %', schedule_e_record.action;
            end case;
        else
            raise notice 'sub_id % still not found', schedule_e_record.sub_id;
        end if;
    end loop;
end
$$ language plpgsql;


-- Create trigger to maintain Schedule E queues for inserts and updates
-- These happen after a row is inserted/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_e_insert_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
    view_row fec_fitem_sched_e_vw%ROWTYPE;
begin
    if tg_op = 'INSERT' then
        select into view_row * from fec_fitem_sched_e_vw where sub_id = new.sub_id;

        -- Check to see if the resultset returned anything from the view.  If
        -- it did not, skip the processing of the record, otherwise we'll end
        -- up with a record full of NULL values.
        -- "FOUND" is a PL/pgSQL boolean variable set to false initially in
        -- any PL/pgSQL function and reset whenever certain statements are
        -- run, e.g., a "SELECT INTO..." statement.  For more information,
        -- visit here:
        -- https://www.postgresql.org/docs/current/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS
        if FOUND then
            delete from ofec_sched_e_queue_new where sub_id = view_row.sub_id;
            insert into ofec_sched_e_queue_new values (view_row.*, timestamp);
        else
            -- We weren't able to successfully retrieve a row from the view,
            -- so keep track of this sub_id if we haven't already so we can
            -- try processing it again each night until we're able to
            -- successfully process it.
            delete from ofec_sched_e_nightly_retries where sub_id = new.sub_id;
            insert into ofec_sched_e_nightly_retries values (new.sub_id, 'insert');
        end if;

        return new;
    elsif tg_op = 'UPDATE' then
        select into view_row * from fec_fitem_sched_e_vw where sub_id = new.sub_id;

        if FOUND then
            delete from ofec_sched_e_queue_new where sub_id = view_row.sub_id;
            insert into ofec_sched_e_queue_new values (view_row.*, timestamp);
        else
            -- We weren't able to successfully retrieve a row from the view,
            -- so keep track of this sub_id if we haven't already so we can
            -- try processing it again each night until we're able to
            -- successfully process it.
            delete from ofec_sched_e_nightly_retries where sub_id = new.sub_id;
            insert into ofec_sched_e_nightly_retries values (new.sub_id, 'update');
        end if;

        return new;
    end if;
end
$$ language plpgsql;


-- Create trigger to maintain Schedule E queues deletes and updates
-- These happen before a row is removed/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_e_delete_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    timestamp timestamp = current_timestamp;
    view_row fec_fitem_sched_e_vw%ROWTYPE;
begin
    if tg_op = 'DELETE' then
        select into view_row * from fec_fitem_sched_e_vw where sub_id = old.sub_id;

        -- Check to see if the resultset returned anything from the view.  If
        -- it did not, skip the processing of the record, otherwise we'll end
        -- up with a record full of NULL values.
        -- "FOUND" is a PL/pgSQL boolean variable set to false initially in
        -- any PL/pgSQL function and reset whenever certain statements are
        -- run, e.g., a "SELECT INTO..." statement.  For more information,
        -- visit here:
        -- https://www.postgresql.org/docs/current/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS
        if FOUND then
            delete from ofec_sched_e_queue_old where sub_id = view_row.sub_id;
            insert into ofec_sched_e_queue_old values (view_row.*, timestamp);
        else
            -- We weren't able to successfully retrieve a row from the view,
            -- so keep track of this sub_id if we haven't already so we can
            -- try processing it again each night until we're able to
            -- successfully process it.
            delete from ofec_sched_e_nightly_retries where sub_id = old.sub_id;
            insert into ofec_sched_e_nightly_retries values (old.sub_id, 'delete');
        end if;

        return old;
    elsif tg_op = 'UPDATE' then
        select into view_row * from fec_fitem_sched_e_vw where sub_id = old.sub_id;

        if FOUND then
            delete from ofec_sched_e_queue_old where sub_id = view_row.sub_id;
            insert into ofec_sched_e_queue_old values (view_row.*, timestamp);
        else
            -- We weren't able to successfully retrieve a row from the view,
            -- so keep track of this sub_id if we haven't already so we can
            -- try processing it again each night until we're able to
            -- successfully process it.
            delete from ofec_sched_e_nightly_retries where sub_id = old.sub_id;
            insert into ofec_sched_e_nightly_retries values (old.sub_id, 'update');
        end if;

        -- We have to return new here because this record is intended to change
        -- with an update.
        return new;
    end if;
end
$$ language plpgsql;

-- Create new triggers
drop trigger if exists nml_sched_e_after_trigger on disclosure.nml_sched_e;
create trigger nml_sched_e_after_trigger after insert or update
    on disclosure.nml_sched_e for each row execute procedure ofec_sched_e_insert_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists nml_sched_e_before_trigger on disclosure.nml_sched_e;
create trigger nml_sched_e_before_trigger before delete or update
    on disclosure.nml_sched_e for each row execute procedure ofec_sched_e_delete_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists f_item_sched_e_after_trigger on disclosure.f_item_receipt_or_exp;
create trigger f_item_sched_e_after_trigger after insert or update
    on disclosure.f_item_receipt_or_exp for each row execute procedure ofec_sched_e_insert_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists f_item_sched_e_before_trigger on disclosure.f_item_receipt_or_exp;
create trigger f_item_sched_e_before_trigger before delete or update
    on disclosure.f_item_receipt_or_exp for each row execute procedure ofec_sched_e_delete_update_queues(:START_YEAR_AGGREGATE);


-- Replace the existing table
drop table if exists ofec_sched_e;
alter table ofec_sched_e_tmp rename to ofec_sched_e;

-- Rename indexes
alter index idx_ofec_sched_e_sub_id_tmp rename to idx_ofec_sched_e_sub_id;
alter index idx_ofec_sched_e_cmte_id_tmp rename to idx_ofec_sched_e_cmte_id;
alter index idx_ofec_sched_e_s_o_cand_id_tmp rename to idx_ofec_sched_e_s_o_cand_id;
alter index idx_ofec_sched_e_entity_tp_tmp rename to idx_ofec_sched_e_entity_tp;
alter index idx_ofec_sched_e_image_num_tmp rename to idx_ofec_sched_e_image_num;
alter index idx_ofec_sched_e_rpt_yr_tmp rename to idx_ofec_sched_e_rpt_yr;
alter index idx_ofec_sched_e_filing_form_tmp rename to idx_ofec_sched_e_filing_form;
alter index idx_ofec_sched_e_cycle_rpt_yr_tmp rename to idx_ofec_sched_e_cycle_rpt_yr;
alter index idx_ofec_sched_e_is_notice_tmp rename to idx_ofec_sched_e_is_notice;
alter index idx_ofec_sched_e_pg_date_tmp rename to idx_ofec_sched_e_pg_date;
alter index idx_ofec_sched_e_exp_dt_sub_id_tmp rename to idx_ofec_sched_e_exp_dt_sub_id;
alter index idx_ofec_sched_e_exp_amt_sub_id_tmp rename to idx_ofec_sched_e_exp_amt_sub_id;
alter index idx_ofec_sched_e_cal_ytd_ofc_sought_sub_id_tmp rename to idx_ofec_sched_e_cal_ytd_ofc_sought_sub_id;
alter index idx_ofec_sched_e_payee_name_text_tmp rename to idx_ofec_sched_e_payee_name_text;
