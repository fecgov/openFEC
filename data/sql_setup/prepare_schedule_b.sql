-- Create index for join on electioneering costs
drop index if exists disclosure.nml_sched_b_link_id_idx;
create index nml_sched_b_link_id_idx on disclosure.nml_sched_b (link_id);

-- Drop the old nightly refresh retry table and function if they still exist.
drop table if exists ofec_sched_b_nightly_retries;
drop function if exists retry_processing_schedule_b_records(start_year integer);


-- Create queue tables to hold changes to Schedule B
drop table if exists ofec_sched_b_queue_new;
drop table if exists ofec_sched_b_queue_old;
create table ofec_sched_b_queue_new as select * from fec_fitem_sched_b_vw limit 0;
create table ofec_sched_b_queue_old as select * from fec_fitem_sched_b_vw limit 0;
alter table ofec_sched_b_queue_new add column timestamp timestamp;
alter table ofec_sched_b_queue_old add column timestamp timestamp;
alter table ofec_sched_b_queue_new add column two_year_transaction_period smallint;
alter table ofec_sched_b_queue_old add column two_year_transaction_period smallint;
create index on ofec_sched_b_queue_new (sub_id);
create index on ofec_sched_b_queue_old (sub_id);
create index on ofec_sched_b_queue_new (timestamp);
create index on ofec_sched_b_queue_old (timestamp);
create index on ofec_sched_b_queue_new (two_year_transaction_period);
create index on ofec_sched_b_queue_old (two_year_transaction_period);



-- Drop old triggers
drop trigger if exists nml_sched_b_after_trigger on disclosure.nml_sched_b;

drop trigger if exists nml_sched_b_before_trigger on disclosure.nml_sched_b;

drop trigger if exists f_item_sched_b_after_trigger on disclosure.f_item_receipt_or_exp;

drop trigger if exists f_item_sched_b_before_trigger on disclosure.f_item_receipt_or_exp;

-- These happen after a row is inserted/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_b_insert_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row fec_fitem_sched_b_vw%ROWTYPE;
    child_table_name text;
begin
    select into view_row * from fec_fitem_sched_b_vw where sub_id = new.sub_id;

    -- Check to see if the resultset returned anything from the view.  If
    -- it did not, skip the processing of the record, otherwise we'll end
    -- up with a record full of NULL values.
    -- "FOUND" is a PL/pgSQL boolean variable set to false initially in
    -- any PL/pgSQL function and reset whenever certain statements are
    -- run, e.g., a "SELECT INTO..." statement.  For more information,
    -- visit here:
    -- https://www.postgresql.org/docs/current/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS
    if FOUND then
        if view_row.election_cycle >= start_year then
            delete from ofec_sched_b_queue_new where sub_id = view_row.sub_id;
            insert into ofec_sched_b_queue_new values (view_row.*, current_timestamp, view_row.election_cycle);
            child_table_name = 'ofec_sched_b_' || get_partition_suffix(view_row.election_cycle);
            EXECUTE format('
            INSERT INTO %I
            (
                cmte_id,
                recipient_cmte_id,
                recipient_nm,
                payee_l_nm,
                payee_f_nm,
                payee_m_nm,
                payee_prefix,
                payee_suffix,
                payee_employer,
                payee_occupation,
                recipient_st1,
                recipient_st2,
                recipient_city,
                recipient_st,
                recipient_zip,
                disb_desc,
                catg_cd,
                catg_cd_desc,
                entity_tp,
                entity_tp_desc,
                election_tp,
                fec_election_tp_desc,
                fec_election_tp_year,
                election_tp_desc,
                cand_id,
                cand_nm,
                cand_nm_first,
                cand_nm_last,
                cand_m_nm,
                cand_prefix,
                cand_suffix,
                cand_office,
                cand_office_desc,
                cand_office_st,
                cand_office_st_desc,
                cand_office_district,
                disb_dt,
                disb_amt,
                memo_cd,
                memo_cd_desc,
                memo_text,
                disb_tp,
                disb_tp_desc,
                conduit_cmte_nm,
                conduit_cmte_st1,
                conduit_cmte_st2,
                conduit_cmte_city,
                conduit_cmte_st,
                conduit_cmte_zip,
                national_cmte_nonfed_acct,
                ref_disp_excess_flg,
                comm_dt,
                benef_cmte_nm,
                semi_an_bundled_refund,
                action_cd,
                action_cd_desc,
                tran_id,
                back_ref_tran_id,
                back_ref_sched_id,
                schedule_type,
                schedule_type_desc,
                line_num,
                image_num,
                file_num,
                link_id,
                orig_sub_id,
                sub_id,
                filing_form,
                rpt_tp,
                rpt_yr,
                election_cycle,
                timestamp,
                pg_date,
                pdf_url,
                recipient_name_text,
                disbursement_description_text,
                disbursement_purpose_category,
                clean_recipient_cmte_id,
                two_year_transaction_period,
                line_number_label
            )
            SELECT
                $1.cmte_id,
                $1.recipient_cmte_id,
                $1.recipient_nm,
                $1.payee_l_nm,
                $1.payee_f_nm,
                $1.payee_m_nm,
                $1.payee_prefix,
                $1.payee_suffix,
                $1.payee_employer,
                $1.payee_occupation,
                $1.recipient_st1,
                $1.recipient_st2,
                $1.recipient_city,
                $1.recipient_st,
                $1.recipient_zip,
                $1.disb_desc,
                $1.catg_cd,
                $1.catg_cd_desc,
                $1.entity_tp,
                $1.entity_tp_desc,
                $1.election_tp,
                $1.fec_election_tp_desc,
                $1.fec_election_tp_year,
                $1.election_tp_desc,
                $1.cand_id,
                $1.cand_nm,
                $1.cand_nm_first,
                $1.cand_nm_last,
                $1.cand_m_nm,
                $1.cand_prefix,
                $1.cand_suffix,
                $1.cand_office,
                $1.cand_office_desc,
                $1.cand_office_st,
                $1.cand_office_st_desc,
                $1.cand_office_district,
                $1.disb_dt,
                $1.disb_amt,
                $1.memo_cd,
                $1.memo_cd_desc,
                $1.memo_text,
                $1.disb_tp,
                $1.disb_tp_desc,
                $1.conduit_cmte_nm,
                $1.conduit_cmte_st1,
                $1.conduit_cmte_st2,
                $1.conduit_cmte_city,
                $1.conduit_cmte_st,
                $1.conduit_cmte_zip,
                $1.national_cmte_nonfed_acct,
                $1.ref_disp_excess_flg,
                $1.comm_dt,
                $1.benef_cmte_nm,
                $1.semi_an_bundled_refund,
                $1.action_cd,
                $1.action_cd_desc,
                $1.tran_id,
                $1.back_ref_tran_id,
                $1.back_ref_sched_id,
                $1.schedule_type,
                $1.schedule_type_desc,
                $1.line_num,
                $1.image_num,
                $1.file_num,
                $1.link_id,
                $1.orig_sub_id,
                $1.sub_id,
                $1.filing_form,
                $1.rpt_tp,
                $1.rpt_yr,
                $1.election_cycle,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP,
                image_pdf_url($1.image_num),
                to_tsvector(concat($1.recipient_nm, '' '', $1.recipient_cmte_id)),
                to_tsvector($1.disb_desc),
                disbursement_purpose($1.disb_tp, $1.disb_desc),
                clean_repeated($1.recipient_cmte_id, $1.cmte_id),
                get_cycle($1.rpt_yr),
                expand_line_number($1.filing_form, $1.line_num)
            ON CONFLICT (sub_id) DO UPDATE
            SET
                cmte_id = $1.cmte_id,
                recipient_cmte_id = $1.recipient_cmte_id,
                recipient_nm = $1.recipient_nm,
                payee_l_nm = $1.payee_l_nm,
                payee_f_nm = $1.payee_f_nm,
                payee_m_nm = $1.payee_m_nm,
                payee_prefix = $1.payee_prefix,
                payee_suffix = $1.payee_suffix,
                payee_employer = $1.payee_employer,
                payee_occupation = $1.payee_occupation,
                recipient_st1 = $1.recipient_st1,
                recipient_st2 = $1.recipient_st2,
                recipient_city = $1.recipient_city,
                recipient_st = $1.recipient_st,
                recipient_zip = $1.recipient_zip,
                disb_desc = $1.disb_desc,
                catg_cd = $1.catg_cd,
                catg_cd_desc = $1.catg_cd_desc,
                entity_tp = $1.entity_tp,
                entity_tp_desc = $1.entity_tp_desc,
                election_tp = $1.election_tp,
                fec_election_tp_desc = $1.fec_election_tp_desc,
                fec_election_tp_year = $1.fec_election_tp_year,
                election_tp_desc = $1.election_tp_desc,
                cand_id = $1.cand_id,
                cand_nm = $1.cand_nm,
                cand_nm_first = $1.cand_nm_first,
                cand_nm_last = $1.cand_nm_last,
                cand_m_nm = $1.cand_m_nm,
                cand_prefix = $1.cand_prefix,
                cand_suffix = $1.cand_suffix,
                cand_office = $1.cand_office,
                cand_office_desc = $1.cand_office_desc,
                cand_office_st = $1.cand_office_st,
                cand_office_st_desc = $1.cand_office_st_desc,
                cand_office_district = $1.cand_office_district,
                disb_dt = $1.disb_dt,
                disb_amt = $1.disb_amt,
                memo_cd = $1.memo_cd,
                memo_cd_desc = $1.memo_cd_desc,
                memo_text = $1.memo_text,
                disb_tp = $1.disb_tp,
                disb_tp_desc = $1.disb_tp_desc,
                conduit_cmte_nm = $1.conduit_cmte_nm,
                conduit_cmte_st1 = $1.conduit_cmte_st1,
                conduit_cmte_st2 = $1.conduit_cmte_st2,
                conduit_cmte_city = $1.conduit_cmte_city,
                conduit_cmte_st = $1.conduit_cmte_st,
                conduit_cmte_zip = $1.conduit_cmte_zip,
                national_cmte_nonfed_acct = $1.national_cmte_nonfed_acct,
                ref_disp_excess_flg = $1.ref_disp_excess_flg,
                comm_dt = $1.comm_dt,
                benef_cmte_nm = $1.benef_cmte_nm,
                semi_an_bundled_refund = $1.semi_an_bundled_refund,
                action_cd = $1.action_cd,
                action_cd_desc = $1.action_cd_desc,
                tran_id = $1.tran_id,
                back_ref_tran_id = $1.back_ref_tran_id,
                back_ref_sched_id = $1.back_ref_sched_id,
                schedule_type = $1.schedule_type,
                schedule_type_desc = $1.schedule_type_desc,
                line_num = $1.line_num,
                image_num = $1.image_num,
                file_num = $1.file_num,
                link_id = $1.link_id,
                orig_sub_id = $1.orig_sub_id,
                filing_form = $1.filing_form,
                rpt_tp = $1.rpt_tp,
                rpt_yr = $1.rpt_yr,
                election_cycle = $1.election_cycle,
                timestamp = CURRENT_TIMESTAMP,
                pg_date = CURRENT_TIMESTAMP,
                pdf_url = image_pdf_url($1.image_num),
                recipient_name_text = to_tsvector(concat($1.recipient_nm, '' '', $1.recipient_cmte_id)),
                disbursement_description_text = to_tsvector($1.disb_desc),
                disbursement_purpose_category = disbursement_purpose($1.disb_tp, $1.disb_desc),
                clean_recipient_cmte_id = clean_repeated($1.recipient_cmte_id, $1.cmte_id),
                two_year_transaction_period = get_cycle($1.rpt_yr),
                line_number_label = expand_line_number($1.filing_form, $1.line_num)
            WHERE
                %I.sub_id = $1.sub_id',
                child_table_name, child_table_name) USING view_row;
            PERFORM increment_sched_b_aggregates(view_row);
        end if;
    end if;

    RETURN NULL; -- result is ignored since this is an AFTER trigger
end
$$ language plpgsql;


-- Create trigger to maintain Schedule A queues deletes and updates
-- These happen before a row is removed/updated so that we can leverage pulling
-- the new record information from the view itself, which contains the data in
-- the structure that our tables expect it to be in.
create or replace function ofec_sched_b_delete_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
    view_row fec_fitem_sched_b_vw%ROWTYPE;
begin
    select into view_row * from fec_fitem_sched_b_vw where sub_id = old.sub_id;

    -- Check to see if the resultset returned anything from the view.  If
    -- it did not, skip the processing of the record, otherwise we'll end
    -- up with a record full of NULL values.
    -- "FOUND" is a PL/pgSQL boolean variable set to false initially in
    -- any PL/pgSQL function and reset whenever certain statements are
    -- run, e.g., a "SELECT INTO..." statement.  For more information,
    -- visit here:
    -- https://www.postgresql.org/docs/current/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS
    if FOUND then
        if view_row.election_cycle >= start_year then
            delete from ofec_sched_b_queue_old where sub_id = view_row.sub_id;
            insert into ofec_sched_b_queue_old values (view_row.*, current_timestamp, view_row.election_cycle);
            IF tg_op = 'DELETE' THEN
                DELETE FROM ofec_sched_b_master WHERE sub_id = view_row.sub_id;
            END IF;
            PERFORM decrement_sched_b_aggregates(view_row);
        end if;
    end if;
    if tg_op = 'DELETE' then
        return old;
    elsif tg_op = 'UPDATE' then
        -- We have to return new here because this record is intended to change
        -- with an update.
        return new;
    end if;
end
$$ language plpgsql;


-- Create new triggers
drop trigger if exists nml_sched_b_after_trigger on disclosure.nml_sched_b;
create trigger nml_sched_b_after_trigger after insert or update
    on disclosure.nml_sched_b for each row execute procedure ofec_sched_b_insert_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists nml_sched_b_before_trigger on disclosure.nml_sched_b;
create trigger nml_sched_b_before_trigger before delete or update
    on disclosure.nml_sched_b for each row execute procedure ofec_sched_b_delete_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists f_item_sched_b_after_trigger on disclosure.f_item_receipt_or_exp;
create trigger f_item_sched_b_after_trigger after insert or update
    on disclosure.f_item_receipt_or_exp for each row execute procedure ofec_sched_b_insert_update_queues(:START_YEAR_AGGREGATE);

drop trigger if exists f_item_sched_b_before_trigger on disclosure.f_item_receipt_or_exp;
create trigger f_item_sched_b_before_trigger before delete or update
    on disclosure.f_item_receipt_or_exp for each row execute procedure ofec_sched_b_delete_update_queues(:START_YEAR_AGGREGATE);

CREATE OR REPLACE FUNCTION increment_sched_b_aggregates(view_row fec_fitem_sched_b_vw) RETURNS VOID AS $$
BEGIN
    IF view_row.disb_amt IS NOT NULL AND (view_row.memo_cd != 'X' OR view_row.memo_cd IS NULL) THEN
        INSERT INTO ofec_sched_b_aggregate_purpose
            (cmte_id, cycle, purpose, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, disbursement_purpose(view_row.disb_tp, view_row.disb_desc), view_row.disb_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_ofec_sched_b_aggregate_purpose_cmte_id_cycle_purpose DO UPDATE
        SET
            total = ofec_sched_b_aggregate_purpose.total + excluded.total,
            count = ofec_sched_b_aggregate_purpose.count + excluded.count;
        INSERT INTO ofec_sched_b_aggregate_recipient
            (cmte_id, cycle, recipient_nm, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, view_row.recipient_nm, view_row.disb_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_ofec_sched_b_aggregate_recipient_cmte_id_cycle_recipient DO UPDATE
        SET
            total = ofec_sched_b_aggregate_recipient.total + excluded.total,
            count = ofec_sched_b_aggregate_recipient.count + excluded.count;
        INSERT INTO ofec_sched_b_aggregate_recipient_id
            (cmte_id, cycle, recipient_cmte_id, recipient_nm, total, count)
        VALUES
            (view_row.cmte_id, view_row.election_cycle, clean_repeated(view_row.recipient_cmte_id, view_row.cmte_id), view_row.recipient_nm, view_row.disb_amt, 1)
        ON CONFLICT ON CONSTRAINT uq_sched_b_agg_recpnt_id_cmte_id_cycle_recipient_cmte_id DO UPDATE
        SET
            total = ofec_sched_b_aggregate_recipient_id.total + excluded.total,
            count = ofec_sched_b_aggregate_recipient_id.count + excluded.count;
    END IF;
END
$$ language plpgsql;

drop function if exists ofec_sched_b_insert_update();
drop function if exists ofec_sched_b_delete_update();
drop function if exists increment_sched_b_aggregates(view_row fec_fitem_sched_b_vw);
drop function if exists decrement_sched_b_aggregates(view_row fec_fitem_sched_b_vw);

-- Drop the old trigger functions if they still exist.
drop function if exists ofec_sched_b_insert_update_queues();
drop function if exists ofec_sched_b_delete_update_queues();
