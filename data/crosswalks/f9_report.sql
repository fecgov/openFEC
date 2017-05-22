-- vsum is as amended and has fewer columns
-- this takes the name from sum_and_det_sum_report to vsum
 select vs.cmte_id as cmte_id,
  vs.rpt_tp,
  vs.cvg_start_dt,
  vs.cvg_end_dt,
  vs.rpt_yr,
  vs.receipt_dt,
  vs.rpt_yr + mod(vs.rpt_yr, 2::numeric) as election_cycle,
  vs.ttl_receipts as ttl_dons_this_stmt,
  vs.ttl_disb as ttl_disb_this_stmt,
  'F5' as form_tp,
  vs.file_num,
  vs.orig_sub_id as sub_id,
  'Y' as most_recent_filing_flag
from  disclosure.v_sum_and_det_sum_report vs
where form_tp_cd='F9';
