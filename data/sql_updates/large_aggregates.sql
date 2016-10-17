drop materialized view if exists big_totals_vw_tmp;
create materialized view big_totals_vw_tmp as
-- candidates
with cand as (
    select
        extract(month from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as month,
        extract(year from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as year,
        ttl_receipts_per as ttl_receipts,
        pol_pty_cmte_contb_per as pty_cmte_contb,
        other_pol_cmte_contb_per as oth_cmte_contb,
        ttl_disb_per as ttl_disb,
        -- double check var
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
        extract(month from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as month,
        extract(year from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as year,
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
),
cand_totals as (
    select
        'candidate'::text as type,
        month,
        year,
        sum(coalesce(cand.ttl_receipts,0) -
            (
                coalesce(cand.pty_cmte_contb ,0) +
                coalesce(cand.oth_cmte_contb ,0) +
                coalesce(cand.offsets_to_op_exp,0) +
                coalesce(cand.ttl_loan_repymts,0) +
                coalesce(cand.ttl_contb_ref,0)
            )
        ) as adjusted_total_reciepts,
        sum(coalesce(cand.ttl_disb, 0) -
            (
                coalesce(cand.tranf_to_other_auth_cmte,0) +
                coalesce(cand.ttl_loan_repymts,0) +
                coalesce(cand.ttl_contb_ref,0) +
                coalesce(cand.other_disb_per,0)
            )
        ) as adjusted_total_disbursements
    from cand
    group by
        month,
        year
),
-- PACs
pac_totals as (select
    'pac'::text as type,
    extract(month from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as month,
    extract(year from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as year,
    sum(coalesce(ttl_receipts, 0) -
        (
            coalesce(pol_pty_cmte_contb_per_i,0) +
            coalesce(other_pol_cmte_contb_per_i,0) +
            coalesce(ttl_op_exp_per,0) +
            coalesce(fed_cand_contb_ref_per,0) +
            coalesce(tranf_from_nonfed_acct_per,0) +
            coalesce(loan_repymts_received_per,0) +
            coalesce(ttl_contb_refund,0)
        )
    ) as adjusted_total_reciepts,
    sum(coalesce(ttl_disb,0) -
        (
            coalesce(shared_nonfed_op_exp_per,0) +
            -- confirm var
            coalesce(tranf_to_affliliated_cmte_per,0) +
            -- coalesce(tranf_to_other_auth_cmte,0) +
            coalesce(fed_cand_cmte_contb_per,0) +
            coalesce(loan_repymts_made_per,0) +
            coalesce(ttl_contb_refund,0) +
            coalesce(other_disb_per,0)
        )
    ) as adjusted_total_disbursements
from fec_vsum_f3x
left join
    -- ofec_committee_detail_mv_tmp using (cmte_id)
    ofec_committee_detail_mv on committee_id = cmte_id
where
    rpt_yr = 2016 or rpt_yr = 2015
    and ofec_committee_detail_mv.committee_type in ('N', 'Q', 'O', 'V', 'W')
    and ofec_committee_detail_mv.designation <> 'J'
    -- see if this might make things quicker
    --and (vs.ttl_receipts > 0 or vs.ttl_disb > 0 or vs.debts_owed_by_cmte > 0 or vs.coh_cop >0)
group by
    month,
    year
),
-- Parties
party_totals as (select
    'party'::text as type,
    extract(month from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as month,
    extract(year from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as year,
    sum(coalesce(ttl_receipts, 0) -
        (
            coalesce(pol_pty_cmte_contb_per_i,0) +
            coalesce(other_pol_cmte_contb_per_i,0) +
            coalesce(ttl_op_exp_per,0) +
            coalesce(fed_cand_contb_ref_per,0) +
            coalesce(tranf_from_nonfed_acct_per,0) +
            coalesce(loan_repymts_received_per,0) +
            coalesce(ttl_contb_refund,0)
        )
    ) as adjusted_total_reciepts,
    sum(coalesce(ttl_disb,0) -
        (
            coalesce(shared_nonfed_op_exp_per,0) +
            -- confirm var
            coalesce(tranf_to_affliliated_cmte_per,0) +
            -- coalesce(tranf_to_other_auth_cmte,0) +
            coalesce(fed_cand_cmte_contb_per,0) +
            coalesce(loan_repymts_made_per,0) +
            coalesce(ttl_contb_refund,0) +
            coalesce(other_disb_per,0)
        )
    ) as adjusted_total_disbursements
from fec_vsum_f3x
left join
    -- ofec_committee_detail_mv_tmp using (cmte_id)
    ofec_committee_detail_mv on committee_id = cmte_id
where
    rpt_yr = 2016 or rpt_yr = 2015
    and ofec_committee_detail_mv.committee_type in ('X', 'Y')
    and ofec_committee_detail_mv.designation <> 'J'
    -- do we have this
    -- and cm.cmte_id not in (select cmte_id from pclark.ref_pty_host_convention)
    -- see if this might make things quicker
    -- and (vs.ttl_receipts > 0 or vs.ttl_disb > 0 or vs.debts_owed_by_cmte > 0 or vs.coh_cop >0)
group by
    month,
    year
),
combined as (
    select * from cand_totals
    union all
    select * from pac_totals
    union all
    select * from party_totals
)

select
    row_number() over () as idx,
    combined.*
from combined
;

