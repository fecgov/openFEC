-- Create Schedule E table
drop table if exists ofec_sched_e;
create table ofec_sched_e as
select
    *,
    cast(null as timestamp) as timestamp,
    to_tsvector(pye_nm) as payee_name_text
from sched_e
;

-- Create simple indices on filtered columns
create index on ofec_sched_e (cmte_id);
create index on ofec_sched_e (s_o_cand_id);
create index on ofec_sched_e (entity_tp);
create index on ofec_sched_e (image_num);
create index on ofec_sched_e (rpt_yr);

-- Create composite indices on sortable columns
create index on ofec_sched_e (exp_dt, sched_e_sk);
create index on ofec_sched_e (exp_amt, sched_e_sk);
create index on ofec_sched_e (cal_ytd_ofc_sought, sched_e_sk);

-- Create indices on filtered fulltext columns
create index on ofec_sched_e using gin (payee_name_text);

-- Create queue tables to hold changes to Schedule E
drop table if exists ofec_sched_e_queue_new;
drop table if exists ofec_sched_e_queue_old;
create table ofec_sched_e_queue_new as select * from sched_e limit 0;
create table ofec_sched_e_queue_old as select * from sched_e limit 0;
alter table ofec_sched_e_queue_new add column timestamp timestamp;
alter table ofec_sched_e_queue_old add column timestamp timestamp;
create index on ofec_sched_e_queue_new (sched_e_sk);
create index on ofec_sched_e_queue_old (sched_e_sk);
create index on ofec_sched_e_queue_new (timestamp);
create index on ofec_sched_e_queue_old (timestamp);

-- Create trigger to maintain Schedule E queues
create or replace function ofec_sched_e_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
begin
    if tg_op = 'INSERT' then
        delete from ofec_sched_e_queue_new where sched_e_sk = new.sched_e_sk;
        insert into ofec_sched_e_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from ofec_sched_e_queue_new where sched_e_sk = new.sched_e_sk;
        delete from ofec_sched_e_queue_old where sched_e_sk = old.sched_e_sk;
        insert into ofec_sched_e_queue_new values (new.*);
        insert into ofec_sched_e_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from ofec_sched_e_queue_old where sched_e_sk = old.sched_e_sk;
        insert into ofec_sched_e_queue_old values (old.*);
        return old;
    end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_e_queue_trigger on sched_e;
create trigger ofec_sched_e_queue_trigger before insert or update or delete
    on sched_e for each row execute procedure ofec_sched_e_update_queues(:START_YEAR_AGGREGATE)
;
