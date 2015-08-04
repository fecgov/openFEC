-- Create simple indices on filtered columns
create index on sched_e (cmte_id);
create index on sched_e (s_o_cand_id);
create index on sched_e (entity_tp);
create index on sched_e (image_num);

-- Create composite indices on sortable columns
create index on sched_e (exp_dt, sched_e_sk);
create index on sched_e (exp_amt, sched_e_sk);
create index on sched_e (cal_ytd_ofc_sought, sched_e_sk);

-- Create Schedule E fulltext table
drop table if exists ofec_sched_e_fulltext;
create table ofec_sched_e_fulltext as
select
    sched_e_sk,
    to_tsvector(pye_nm) as payee_name_text
from sched_e
;

-- Create indices on filtered fulltext columns
alter table ofec_sched_e_fulltext add primary key (sched_e_sk);
create index on ofec_sched_e_fulltext using gin (payee_name_text);

-- Create queue tables to hold changes to Schedule E
drop table if exists ofec_sched_e_queue_new;
drop table if exists ofec_sched_e_queue_old;
create table ofec_sched_e_queue_new as select * from sched_e limit 0;
create table ofec_sched_e_queue_old as select * from sched_e limit 0;

-- Create trigger to maintain Schedule E queues
create or replace function ofec_sched_e_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
begin
    if tg_op = 'INSERT' then
        insert into ofec_sched_e_queue_new
        values (new.*)
        ;
        return new;
    elsif tg_op = 'UPDATE' then
        insert into ofec_sched_e_queue_new
        values (new.*)
        ;
        insert into ofec_sched_e_queue_old
        values (old.*)
        ;
        return new;
    elsif tg_op = 'DELETE' then
        insert into ofec_sched_e_queue_old
        values (old.*)
        ;
        return old;
    end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_e_queue_trigger on sched_e;
create trigger ofec_sched_e_queue_trigger before insert or update or delete
    on sched_e for each row execute procedure ofec_sched_e_update_queues(:START_YEAR_ITEMIZED)
;
