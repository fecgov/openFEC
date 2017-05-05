CREATE OR REPLACE VIEW public.fec_vsumcolumns_f5_vw AS 
 SELECT VS.CMTE_ID AS indv_org_id,
    VS.rpt_tp,
    VS.cvg_start_dt,
    VS.cvg_end_dt,
    VS.rpt_yr,
    VS.receipt_dt,
    VS.rpt_yr + mod(VS.rpt_yr, 2::numeric) AS election_cycle,
    VS.TTL_CONTB AS ttl_indt_contb,
    VS.INDT_EXP_PER AS ttl_indt_exp,
    'F5' AS form_tp,
    VS.file_num,
    VS.ORIG_SUB_ID AS sub_id,
       'Y' AS most_recent_filing_flag
   FROM  disclosure.v_sum_and_det_sum_report vs 
  WHERE  (VS.rpt_tp::text <> ALL (ARRAY['24'::character varying, '48'::character varying]::text[]));
