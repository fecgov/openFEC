select
-- do we need this if we are doing the group by later
-- confirm that this is as-amended
extract(month from to_date(cast(vs.cvg_end_dt as text), 'YYYYMMDD')) as month,
extract(year from to_date(cast(vs.cvg_end_dt as text), 'YYYYMMDD')) as year,
sum(coalesce(vs.ttl_receipts,0) - (coalesce(vs.pty_cmte_contb ,0) + coalesce(vs.oth_cmte_contb ,0) + coalesce(vs.offsets_to_op_exp,0) + coalesce(vs.ttl_loan_repymts,0) + coalesce(vs.ttl_contb_ref,0))) as adj_tr,
sum(coalesce(vs.ttl_disb, 0) - (coalesce(vs.tranf_to_other_auth_cmte,0) + coalesce(vs.ttl_loan_repymts,0) + coalesce(vs.ttl_contb_ref,0) + coalesce(vs.other_disb_per,0))) as adj_td
from disclosure.v_sum_and_det_sum_report vs, disclosure.cand_cmte_linkage ccl, disclosure.candidate_summary cs
where vs.cmte_id = ccl.cmte_id
and ccl.cand_id = cs.cand_id
and ccl.cmte_tp = substr(ccl.cand_id, 1,1)
and ccl.cmte_dsgn in ('P', 'A')
and ccl.cand_election_yr in (2015, 2016)
and ccl.fec_election_yr = 2016
and cs.cand_election_yr in (2015, 2016)
and cs.fec_election_yr = 2016
and ccl.cand_id not in (select cand_id from disclosure.cand_inactive where election_yr = 2016)
and (vs.ttl_receipts > 0 or vs.ttl_disb > 0)
and vs.cvg_end_dt between 20150101 and 20160831
-- group by month
group by vs.cvg_end_dt
-- shouldn't this be reciept date ?? check with Paul
order by vs.cvg_end_dt;



select
-- do we need this if we are doing the group by later
-- confirm that this is as-amended
-- extract(month from to_date(cast(vs.cvg_end_dt as text), 'YYYYMMDD')) month_order,
vs.cvg_end_dt as original,
extract(month from to_date(cast(vs.cvg_end_dt as text), 'YYYYMMDD')) as month,
extract(year from to_date(cast(vs.cvg_end_dt as text), 'YYYYMMDD')) as year,
sum(coalesce(vs.ttl_receipts,0) - (coalesce(vs.pty_cmte_contb ,0) + coalesce(vs.oth_cmte_contb ,0) + coalesce(vs.offsets_to_op_exp,0) + coalesce(vs.ttl_loan_repymts,0) + coalesce(vs.ttl_contb_ref,0))) as adj_tr

from disclosure.v_sum_and_det_sum_report vs--, disclosure.cand_cmte_linkage ccl, disclosure.candidate_summary cs
group by vs.cvg_end_dt
-- shouldn't this be reciept date ?? check with Paul
order by vs.cvg_end_dt
limit 2
;
