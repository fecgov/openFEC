drop materialized view if exists ofec_electioneering_cost_mv_tmp;
create materialized view ofec_electioneering_cost_mv_tmp as
select distinct on (form_94.form_94_sk)
    form_94.*,
    sched_b.rpt_yr,
    sched_b.disb_amt
from form_94
join sched_b using (link_id)
where sched_b.rpt_yr >= :START_YEAR
;

create unique index on ofec_electioneering_cost_mv_tmp (form_94_sk);

create index on ofec_electioneering_cost_mv_tmp (form_tp);
create index on ofec_electioneering_cost_mv_tmp (filer_cmte_id);
create index on ofec_electioneering_cost_mv_tmp (cand_id);
create index on ofec_electioneering_cost_mv_tmp (cand_office);
create index on ofec_electioneering_cost_mv_tmp (cand_office_st);
create index on ofec_electioneering_cost_mv_tmp (cand_office_district);
create index on ofec_electioneering_cost_mv_tmp (election_tp);
create index on ofec_electioneering_cost_mv_tmp (amndt_ind);
create index on ofec_electioneering_cost_mv_tmp (receipt_dt);
create index on ofec_electioneering_cost_mv_tmp (filing_type);
create index on ofec_electioneering_cost_mv_tmp (disb_amt);
create index on ofec_electioneering_cost_mv_tmp (rpt_yr);
