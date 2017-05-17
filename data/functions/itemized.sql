-- Provides the functions that allow us to retry processing itemized schedule
-- records that failed to process correctly upon initial record changes to the
-- underlying disclosure.nml_sched_a and disclosure.nml_sched_b tables.

-- If the record is successfully processed, it will be added to the main
-- nightly refresh queues to be taken care of with all of the other records
-- that were originally processed successfully.  If it is not, meaning it still
-- couldn't be found in the public.fec_vsum_sched_a_vw or
-- public.fec_vsum_sched_b_vw views, the sub_id will remain in the
-- ofec_sched_a_nightly_retries/ofec_sched_b_nightly_retries table until it is.

-- Convenience function that takes care of all of the processing at once.
create or replace function retry_processing_itemized_records() returns void as $$
begin
    perform retry_processing_schedule_a_records(:START_YEAR_AGGREGATE);
    perform retry_processing_schedule_b_records(:START_YEAR_AGGREGATE);
end
$$ language plpgsql;


-- Retry processing schedule A itemized records
create or replace function retry_processing_schedule_a_records(start_year integer) returns void as $$
declare
    timestamp timestamp = current_timestamp;
    two_year_transaction_period smallint;
    view_row fec_vsum_sched_a_vw%ROWTYPE;
    schedule_a_record record;
begin
    for schedule_a_record in select * from ofec_sched_a_nightly_retries loop
        select into view_row * from fec_vsum_sched_a_vw where sub_id = schedule_a_record.sub_id;

        if found then
            two_year_transaction_period = get_transaction_year(view_row.contb_receipt_dt, view_row.rpt_yr);

            if two_year_transaction_period >= start_year then
                -- Determine which queue(s) the found record should go into.
                case schedule_a_record.action
                    when 'insert' then
                        delete from ofec_sched_a_queue_new where sub_id = view_row.sub_id;
                        insert into ofec_sched_a_queue_new values (view_row.*, timestamp, two_year_transaction_period);

                        delete from ofec_sched_a_nightly_retries where sub_id = schedule_a_record.sub_id;
                    when 'delete' then
                        delete from ofec_sched_a_queue_old where sub_id = view_row.sub_id;
                        insert into ofec_sched_a_queue_old values (view_row.*, timestamp, two_year_transaction_period);

                        delete from ofec_sched_a_nightly_retries where sub_id = schedule_a_record.sub_id;
                    when 'update' then
                        delete from ofec_sched_a_queue_new where sub_id = view_row.sub_id;
                        delete from ofec_sched_a_queue_old where sub_id = view_row.sub_id;
                        insert into ofec_sched_a_queue_new values (view_row.*, timestamp, two_year_transaction_period);
                        insert into ofec_sched_a_queue_old values (view_row.*, timestamp, two_year_transaction_period);

                        delete from ofec_sched_a_nightly_retries where sub_id = schedule_a_record.sub_id;
                    else
                        raise warning 'Invalid action supplied: %', schedule_a_record.action;
                end case;
            end if;
        else
            raise notice 'sub_id % still not found', schedule_a_record.sub_id;
        end if;
    end loop;
end
$$ language plpgsql;


-- Retry processing schedule A itemized records
create or replace function retry_processing_schedule_b_records(start_year integer) returns void as $$
declare
    timestamp timestamp = current_timestamp;
    two_year_transaction_period smallint;
    view_row fec_vsum_sched_b_vw%ROWTYPE;
    schedule_b_record record;
begin
    for schedule_b_record in select * from ofec_sched_b_nightly_retries loop
        select into view_row * from fec_vsum_sched_b_vw where sub_id = schedule_b_record.sub_id;

        if found then
            two_year_transaction_period = get_transaction_year(view_row.disb_dt, view_row.rpt_yr);

            if two_year_transaction_period >= start_year then
                -- Determine which queue(s) the found record should go into.
                case schedule_b_record.action
                    when 'insert' then
                        delete from ofec_sched_b_queue_new where sub_id = view_row.sub_id;
                        insert into ofec_sched_b_queue_new values (view_row.*, timestamp, two_year_transaction_period);

                        delete from ofec_sched_b_nightly_retries where sub_id = schedule_b_record.sub_id;
                    when 'delete' then
                        delete from ofec_sched_b_queue_old where sub_id = view_row.sub_id;
                        insert into ofec_sched_b_queue_old values (view_row.*, timestamp, two_year_transaction_period);

                        delete from ofec_sched_b_nightly_retries where sub_id = schedule_b_record.sub_id;
                    when 'update' then
                        delete from ofec_sched_b_queue_new where sub_id = view_row.sub_id;
                        delete from ofec_sched_b_queue_old where sub_id = view_row.sub_id;
                        insert into ofec_sched_b_queue_new values (view_row.*, timestamp, two_year_transaction_period);
                        insert into ofec_sched_b_queue_old values (view_row.*, timestamp, two_year_transaction_period);

                        delete from ofec_sched_b_nightly_retries where sub_id = schedule_b_record.sub_id;
                    else
                        raise warning 'Invalid action supplied, record not processed: %', schedule_b_record.action;
                end case;
            end if;
        else
            raise notice 'sub_id % still not found', schedule_b_record.sub_id;
        end if;
    end loop;
end
$$ language plpgsql;
