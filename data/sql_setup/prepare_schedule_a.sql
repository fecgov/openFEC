-- Create simple indices on filtered columns
create index on sched_a (rpt_yr) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_a (image_num) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_a (sched_a_sk) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_a (cmte_id) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_a (contbr_id) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_a (contbr_st) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_a (contbr_city) where rpt_yr >= :START_YEAR_ITEMIZED;

-- Create composite indices on sortable columns
create index on sched_a (receipt_dt, sched_a_sk) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_a (contb_receipt_amt, sched_a_sk) where rpt_yr >= :START_YEAR_ITEMIZED;

-- Create Schedule A fulltext table
drop table if exists ofec_sched_a_fulltext;
create table ofec_sched_a_fulltext as
select
    sched_a_sk,
    to_tsvector(contbr_nm) as contributor_name_text,
    to_tsvector(contbr_employer) as contributor_employer_text
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
;

-- Create indices on filtered fulltext columns
alter table ofec_sched_a_fulltext add primary key (sched_a_sk);
create index on ofec_sched_a_fulltext using gin (contributor_name_text);
create index on ofec_sched_a_fulltext using gin (contributor_employer_text);

-- Create trigger to maintain Schedule A fulltext table
create or replace function ofec_sched_a_update() returns trigger as $$
begin
    if tg_op = 'INSERT' then
        if new.rpt_yr >= :START_YEAR_ITEMIZED then
            insert into ofec_sched_a_fulltext
                (sched_a_sk, contributor_name_text, contributor_employer_text)
                values (new.sched_a_sk, to_tsvector(new.contbr_nm), to_tsvector(new.contbr_employer))
            ;
        end if;
        return new;
    elsif tg_op = 'UPDATE' then
        if new.rpt_yr >= :START_YEAR_ITEMIZED then
            update ofec_sched_a_fulltext
                set (sched_a_sk, contributor_name_text, contributor_employer_text) =
                (new.sched_a_sk, to_tsvector(new.contbr_nm), to_tsvector(new.contbr_employer))
            where sched_a_sk = new.sched_a_sk
            ;
        end if;
        return new;
    elsif tg_op = 'DELETE' then
        if old.rpt_yr >= :START_YEAR_ITEMIZED then
            delete from ofec_sched_a_fulltext where sched_a_sk = old.sched_a_sk;
        end if;
        return old;
    end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_a_trigger on sched_a;
create trigger ofec_sched_a_trigger before insert or update or delete
    on sched_a for each row execute procedure ofec_sched_a_update()
;

-- Create queue tables to hold changes to Schedule A
drop table if exists ofec_sched_a_queue_new;
drop table if exists ofec_sched_a_queue_old;
create table ofec_sched_a_queue_new as select * from sched_a limit 0;
create table ofec_sched_a_queue_old as select * from sched_a limit 0;

-- Create trigger to maintain Schedule A queues
create or replace function ofec_sched_a_update_queues() returns trigger as $$
begin
  if tg_op = 'INSERT' then
    if new.rpt_yr >= :START_YEAR_ITEMIZED then
      insert into ofec_sched_a_queue_new
      values (new.*)
      ;
    end if;
    return new;
  elsif tg_op = 'UPDATE' then
    if new.rpt_yr >= :START_YEAR_ITEMIZED then
      insert into ofec_sched_a_queue_new
      values (new.*)
      ;
      insert into ofec_sched_a_queue_old
      values (old.*)
      ;
    end if;
    return new;
  elsif tg_op = 'DELETE' then
    if old.rpt_yr >= :START_YEAR_ITEMIZED then
      insert into ofec_sched_a_queue_old
      values (old.*)
      ;
    end if;
    return old;
  end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_a_queue_trigger on sched_a;
create trigger ofec_sched_a_queue_trigger before insert or update or delete
    on sched_a for each row execute procedure ofec_sched_a_update_queues()
;
