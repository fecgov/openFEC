-- Create simple indices on filtered columns
create index on sched_b (cmte_id) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b (recipient_st) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b (recipient_city) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b (recipient_cmte_id) where rpt_yr >= :START_YEAR_ITEMIZED;

-- Create bidirectional composite indices on sortable columns
create index on sched_b(rpt_yr, sched_b_sk) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b(rpt_yr desc, sched_b_sk) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b(disb_amt, sched_b_sk) where rpt_yr >= :START_YEAR_ITEMIZED;
create index on sched_b(disb_amt desc, sched_b_sk) where rpt_yr >= :START_YEAR_ITEMIZED;

-- Create Schedule B fulltext table
drop table if exists ofec_sched_b_fulltext;
create table ofec_sched_b_fulltext as
select
    sched_b_sk,
    to_tsvector(recipient_nm) as recipient_name_text
from sched_b
where rpt_yr >= :START_YEAR_ITEMIZED
;

-- Create indices on filtered fulltext columns
alter table ofec_sched_b_fulltext add primary key (sched_b_sk);
create index on ofec_sched_b_fulltext using gin (recipient_name_text);

-- Create trigger to maintain Schedule B fulltext table
create or replace function ofec_sched_b_update() returns trigger as $$
begin
    if tg_op = 'INSERT' then
        if new.rpt_yr >= :START_YEAR_ITEMIZED then
            insert into ofec_sched_b_fulltext
                (sched_b_sk, recipient_name_text) =
                values (new.sched_b_sk, to_tsvector(new.recipient_cmte_nm))
            ;
        end if;
        return new;
    elsif tg_op = 'UPDATE' then
        if new.rpt_yr >= :START_YEAR_ITEMIZED then
            update ofec_sched_b_fulltext
                set (sched_b_sk, recipient_name_text) =
                (new.sched_b_sk, to_tsvector(new.recipient_name))
            where sched_b_sk = new.sched_b_sk
            ;
        end if;
        return new;
    elsif tg_op = 'DELETE' then
        if old.rpt_yr >= :START_YEAR_ITEMIZED then
            delete from ofec_sched_b_fulltext where sched_b_sk = old.sched_b_sk;
        end if;
        return old;
    end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_b_trigger on sched_b;
create trigger ofec_sched_b_trigger before insert or update or delete
    on sched_b for each row execute procedure ofec_sched_b_update()
;
