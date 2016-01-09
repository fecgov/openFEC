drop materialized view if exists ofec_electioneering_mv_tmp;
create materialized view ofec_electioneering_mv_tmp as
-- there is no unique identifier
select
    electioneering_com_vw.*,
    row_number() over () as idx,
    -- double check with FEC, but they all say F94 in the current site, not sure we need this
    'F9'::text as form_tp
from electioneering_com_vw
where rpt_yr >= :START_YEAR
;

create unique index on ofec_electioneering_mv_tmp (idx);

-- These are all from F9 Schedule B, I guess we can keep this for consistency
create index on ofec_electioneering_mv_tmp (form_tp);
create index on ofec_electioneering_mv_tmp (cmte_id);
create index on ofec_electioneering_mv_tmp (cand_id);
create index on ofec_electioneering_mv_tmp (cand_office);
create index on ofec_electioneering_mv_tmp (cand_office_st);
create index on ofec_electioneering_mv_tmp (cand_office_district);
-- not in this table
-- create index on ofec_electioneering_mv_tmp (election_tp);
-- not in this table, confirm all amendment info has been applied
-- create index on ofec_electioneering_mv_tmp (amndt_ind);
-- Need this to match other tables
-- create index on ofec_electioneering_mv_tmp (receipt_dt);
-- It is either E or P. I am not sure what that stands for, it is not in the new table
-- create index on ofec_electioneering_mv_tmp (filing_type);
-- not disb_amt in this table
create index on ofec_electioneering_mv_tmp (reported_disb_amt);
-- this is want we want to use for per candidate calculations
create index on ofec_electioneering_mv_tmp (calculated_cand_share);
create index on ofec_electioneering_mv_tmp (rpt_yr);
