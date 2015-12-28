-- Create Schedule E table
drop table if exists ofec_sched_e_tmp;
create table ofec_sched_e_tmp as
select
    *,
    cast(null as timestamp) as timestamp,
    to_tsvector(pye_nm) as payee_name_text
from sched_e
;

alter table ofec_sched_e_tmp add primary key (sched_e_sk);

-- Create simple indices on filtered columns
create index on ofec_sched_e_tmp (cmte_id);
create index on ofec_sched_e_tmp (s_o_cand_id);
create index on ofec_sched_e_tmp (entity_tp);
create index on ofec_sched_e_tmp (image_num);
create index on ofec_sched_e_tmp (rpt_yr);

-- Create composite indices on sortable columns
create index on ofec_sched_e_tmp (exp_dt, sched_e_sk);
create index on ofec_sched_e_tmp (exp_amt, sched_e_sk);
create index on ofec_sched_e_tmp (cal_ytd_ofc_sought, sched_e_sk);

-- Create indices on filtered fulltext columns
create index on ofec_sched_e_tmp using gin (payee_name_text);

-- Analyze tables
analyze ofec_sched_e_tmp;

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

drop table if exists ofec_sched_e;
alter table ofec_sched_e_tmp rename to ofec_sched_e;
