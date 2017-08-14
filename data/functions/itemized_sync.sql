-- Data syncing scripts
-- adding a redundant processes to make sure there isn't missing data

-- Receipts

-- looks to see if there are any missing records compared to canonical table
create or replace function check_schedule_a() returns int as $$
begin
    select count(fec_vsum_sched_a.sub_id)
    from fec_vsum_sched_a
    left join ofec_sched_a_master using (sub_id)
end
$$ language plpgsql immutable;

-- adds any records not in the
create or replace function supplement_schedule_a() returns void as $$
begin
    with missing as(
        select
            * --count(fec_vsum_sched_a.sub_id)
        from fec_vsum_sched_a
        left join ofec_sched_a_master using (sub_id)
        where fec_vsum_sched_a.rpt_yr >= 1979
        )
    insert into ofec_sched_a_queue_new
    select * from missing;  -- replace hard coded year with start_year
end
$$ language plpgsql immutable;

-- -- sched b
-- select
--     count(fec_vsum_sched_b.sub_id)
-- from fec_vsum_sched_b
-- left join ofec_sched_b_master using (sub_id)

--     count(fec_vsum_sched_a.sub_id)
-- from fec_vsum_sched_a
--     left join ofec_sched_a_master using (sub_id)
-- where fec_vsum_sched_a.rpt_yr <= 1979;  --start_year


-- -- sched e
--     ofec_sched_e using (sub_id)
--     fec_vsum_f57_vw
--     fec_vsum_sched_e_vw
--     fec_sched_e_notice_vw

