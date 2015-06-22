-- Create simple indices on filtered columns
create index on sched_a(cmte_id);
create index on sched_a(contbr_id);
create index on sched_a(contbr_st);
create index on sched_a(contbr_city);

-- Create bidirectional composite indices on sortable columns
create index on sched_a(rpt_yr, sched_a_sk);
create index on sched_a(rpt_yr desc, sched_a_sk);
create index on sched_a(contb_receipt_amt, sched_a_sk);
create index on sched_a(contb_receipt_amt desc, sched_a_sk);

-- Create Schedule A fulltext table
create table ofec_sched_a_fulltext as
select
    sched_a_sk,
    to_tsvector(contbr_nm) as contributor_name_text,
    to_tsvector(contbr_employer) as contributor_employer_text
from sched_a
;

-- Create indices on filtered fulltext columns
alter table ofec_sched_a_fulltext add primary key (sched_a_sk);
create index on ofec_sched_a_fulltext using gin (contributor_name_text);
create index on ofec_sched_a_fulltext using gin (contributor_employer_text);

-- Create trigger to maintain Schedule A fulltext table
create function ofec_sched_a_trigger() returns trigger as $$
begin
    if tg_op = 'INSERT' then
        insert into ofec_sched_a_trigger
            (sched_a_sk, contributor_name_text, contributor_employer_text, contributor_occupation_text)
            values (new.sched_a_sk, to_tsvector(contbr_nm), to_tsvector(contbr_employer), to_tsvector(contbr_occupation))
        ;
    elsif tp_op = 'UPDATE' then
        update ofec_sched_a_fulltext
            set (sched_a_sk, contributor_name_text, contributor_employer_text, contributor_occupation_text) =
            (new.sched_a_sk, to_tsvector(new.contbr_nm), to_tsvector(new.contbr_employer), to_tsvector(contbr_occupation))
        where sched_a_sk = new.sched_a_sk
        ;
    elsif tp_op = 'DELETE' then
        delete from ofec_sched_a_fulltext where sched_a_sk = old.sched_a_sk;
    end if;
    return new;
end
$$ language plpgsql;

create trigger tsvectorupdate before insert or update or delete
    on sched_a for each row execute procedure ofec_sched_a_trigger()
;
