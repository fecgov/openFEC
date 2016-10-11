with cand as (
    select
        extract(month from to_date(cast(cvg_end_dt as text), 'YYYYMMDD')) as month,
        extract(year from to_date(cast(cvg_end_dt as text), 'YYYYMMDD')) as year,
        ttl_receipts_per as ttl_receipts,
        pol_pty_cmte_contb_per as pty_cmte_contb,
        other_pol_cmte_contb_per as oth_cmte_contb,
        ttl_disb_per as ttl_disb,
        -- double check
        tranf_to_other_auth_cmte_per as tranf_to_other_auth_cmte,
        offsets_to_op_exp_per as offsets_to_op_exp,
        ttl_loans_received_per as ttl_loan_repymts,
        ttl_contb_ref_per as ttl_contb_ref,
        other_disb_per
    from fec_vsum_f3p
    where
        rpt_yr = 2016 or rpt_yr = 2015
    union all
    select
        extract(month from to_date(cast(cvg_end_dt as text), 'YYYYMMDD')) as month,
        extract(year from to_date(cast(cvg_end_dt as text), 'YYYYMMDD')) as year,
        ttl_receipts_per as ttl_receipts,
        pol_pty_cmte_contb_per as pty_cmte_contb,
        other_pol_cmte_contb_per as oth_cmte_contb,
        ttl_disb_per as ttl_disb,
        tranf_to_other_auth_cmte_per as tranf_to_other_auth_cmte,
        offsets_to_op_exp_per as offsets_to_op_exp,
        ttl_loan_repymts_per as ttl_loan_repymts,
        ttl_contb_ref_col_ttl_per as ttl_contb_ref,
        other_disb_per
    from fec_vsum_f3
    where
        rpt_yr = 2016 or rpt_yr = 2015
)
select
    'candidate' as type,
    month,
    year,
    sum(coalesce(cand.ttl_receipts,0) - (coalesce(cand.pty_cmte_contb ,0) + coalesce(cand.oth_cmte_contb ,0) + coalesce(cand.offsets_to_op_exp,0) + coalesce(cand.ttl_loan_repymts,0) + coalesce(cand.ttl_contb_ref,0))) as adjusted_total_reciepts,
    sum(coalesce(cand.ttl_disb, 0) - (coalesce(cand.tranf_to_other_auth_cmte,0) + coalesce(cand.ttl_loan_repymts,0) + coalesce(cand.ttl_contb_ref,0) + coalesce(cand.other_disb_per,0))) as adjusted_total_disbursements
from cand
group by
    month,
    year
;
