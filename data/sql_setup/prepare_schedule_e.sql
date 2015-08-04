-- Create simple indices on filtered columns
create index on sched_e (cmte_id);
create index on sched_e (cand_id);
create index on sched_e (entity_tp);
create index on sched_e (image_num);
create index on sched_e (contbr_id);
create index on sched_e (contbr_st);
create index on sched_e (contbr_city);

-- Create composite indices on sortable columns
create index on sched_e (exp_dt, sched_e_sk);
create index on sched_e (exp_amt, sched_e_sk);
create index on sched_e (ytd_election_office, sched_e_sk);
