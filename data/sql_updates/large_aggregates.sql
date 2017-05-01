drop materialized view if exists ofec_entity_chart_mv_tmp;
create materialized view ofec_entity_chart_mv_tmp as
-- candidates
with candidates as (
    select
        get_cycle(rpt_yr) as cycle,
        cmte_id,
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
    from fec_vsum_f3p_vw
    where most_recent_filing_flag like 'Y'
    union all
    select
        get_cycle(rpt_yr) as cycle,
        cmte_id,
        extract(month from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as month,
        extract(year from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as year,
        ttl_receipts,
        pty_cmte_contb,
        oth_cmte_contb,
        ttl_disb,
        tranf_to_other_auth_cmte,
        offsets_to_op_exp,
        ttl_loan_repymts,
        ttl_contb_ref,
        other_disb_per
    from v_sum_and_det_sum_report
    where most_recent_filing_flag like 'Y'
),
-- Remove candidate activity that does not apply to the current election
cand as (
    select * from candidates
    inner join
        -- check we don't need to normalize fec_election_yr
        disclosure.cmte_valid_fec_yr cvf on cvf.fec_election_yr = candidates.cycle and cvf.cmte_id = candidates.cmte_id
),
-- Create sums
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
        ) as candidate_adjusted_total_receipts,
        sum(coalesce(cand.ttl_disb, 0) -
            (
                coalesce(cand.tranf_to_other_auth_cmte,0) +
                coalesce(cand.ttl_loan_repymts,0) +
                coalesce(cand.ttl_contb_ref,0) +
                coalesce(cand.other_disb_per,0)
            )
        ) as candidate_adjusted_total_disbursements
    from cand
    group by
        month,
        year
),
-- PACs
pac_totals as (
    select
        'pac'::text as type,
        extract(month from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as month,
        extract(year from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as year,
        sum(coalesce(ttl_receipts, 0) -
            (
                -- contributions from political party committees and other political committees
                coalesce(pol_pty_cmte_contb_per_i,0) +
                -- contributions from political party committees and other political committees
                coalesce(other_pol_cmte_contb_per_i,0) +
                -- offsets to operating expenditures
                coalesce(offests_to_op_exp,0) +
                -- Contribution refunds going out
                coalesce(fed_cand_contb_ref_per,0) +
                -- Transfers from nonfederal accounts for allocated activities
                coalesce(tranf_from_nonfed_acct_per,0) +
                -- loan repayments
                --coalesce(loan_repymts_received_per,0) +
                coalesce(loan_repymts_made_per, 0) +
                -- contribution refunds
                coalesce(ttl_contb_refund,0)
            )
        ) as pac_adjusted_total_receipts,
        sum(coalesce(ttl_disb,0) -
            (
                -- Nonfederal share of allocated disbursements
                coalesce(shared_nonfed_op_exp_per,0) +
                -- Transfers to other authorized committees and affiliated committees
                coalesce(tranf_to_affliliated_cmte_per,0) +
                -- Contributions to candidates and other political committees
                coalesce(fed_cand_cmte_contb_per,0) +
                -- Loan repayments
                coalesce(loan_repymts_made_per,0) +
                -- Contribution refunds
                coalesce(ttl_contb_refund,0) +
                -- Other disbursements
                coalesce(other_disb_per,0)
            )
        ) as pac_adjusted_total_disbursements
    from fec_vsum_f3x_vw
    left join
        ofec_committee_detail_mv_tmp on committee_id = cmte_id
    where
        most_recent_filing_flag like 'Y'
        and ofec_committee_detail_mv_tmp.committee_type in ('N', 'Q', 'O', 'V', 'W')
        and ofec_committee_detail_mv_tmp.designation <> 'J'
    group by
        month,
        year
),
-- Parties
party_totals as (
    select
        'party'::text as type,
        extract(month from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as month,
        extract(year from to_date(cast(cvg_end_dt as text), 'YYYY-MM-DD')) as year,
        sum(coalesce(ttl_receipts, 0) -
            (
                coalesce(pol_pty_cmte_contb_per_i,0) +
                coalesce(other_pol_cmte_contb_per_i,0) +
                coalesce(offests_to_op_exp,0) +
                coalesce(fed_cand_contb_ref_per,0) +
                coalesce(tranf_from_nonfed_acct_per,0) +
                -- coalesce(loan_repymts_received_per,0) +
                coalesce(loan_repymts_made_per, 0) +
                coalesce(ttl_contb_refund,0)
            )
        ) as party_adjusted_total_receipts,
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
        ) as party_adjusted_total_disbursements
    from fec_vsum_f3x_vw
    left join
        ofec_committee_detail_mv_tmp on committee_id = cmte_id
    where
        most_recent_filing_flag like 'Y'
        and ofec_committee_detail_mv_tmp.committee_type in ('X', 'Y')
        and ofec_committee_detail_mv_tmp.designation <> 'J'
        -- excluding host conventions because they have different rules than party committees
        and cmte_id not in ('C00578419', 'C00485110', 'C00422048', 'C00567057', 'C00483586', 'C00431791', 'C00571133',
            'C00500405', 'C00435560', 'C00572958', 'C00493254', 'C00496570', 'C00431593')
    group by
        month,
        year
), -- merge
combined as (
    select
        row_number() over () as idx,
        month,
        year,
        year::numeric + (year::numeric % 2) as cycle,
        case when max(candidate_adjusted_total_receipts) is null
            then 0 else max(candidate_adjusted_total_receipts) end
        as candidate_receipts,
        case when max(cand_totals.candidate_adjusted_total_disbursements) is null
            then 0 else max(cand_totals.candidate_adjusted_total_disbursements) end
        as canidate_disbursements,
        case when max(pac_totals.pac_adjusted_total_receipts) is null
            then 0 else max(pac_totals.pac_adjusted_total_receipts) end
        as pac_receipts,
        case when max(pac_totals.pac_adjusted_total_disbursements) is null
            then 0 else max(pac_totals.pac_adjusted_total_disbursements) end
        as pac_disbursements,
        case when max(party_totals.party_adjusted_total_receipts) is null
            then 0 else max(party_totals.party_adjusted_total_receipts) end
        as party_receipts,
        case when max(party_totals.party_adjusted_total_disbursements) is null
            then 0 else max(party_totals.party_adjusted_total_disbursements) end
        as party_disbursements
    from cand_totals
    full outer join pac_totals using (month, year)
    full outer join party_totals using (month, year)
    group by
        month,
        year
    order by year, month
)
select
    idx,
    month,
    year,
    cycle,
    last_day_of_month(make_timestamp(cast(year as int), cast(month as int), 1, 0, 0, 0.0)) as date,
    sum(candidate_receipts) OVER (PARTITION BY cycle order by year asc, month asc) as cumulative_candidate_receipts,
    candidate_receipts,
    sum(canidate_disbursements) OVER (PARTITION BY cycle order by year asc, month asc) as cumulative_candidate_disbursements,
    canidate_disbursements,
    sum(pac_receipts) OVER (PARTITION BY cycle order by year asc, month asc) as cumulative_pac_receipts,
    pac_receipts,
    sum(pac_disbursements) OVER (PARTITION BY cycle order by year asc, month asc) as cumulative_pac_disbursements,
    pac_disbursements,
    sum(party_receipts) OVER (PARTITION BY cycle order by year asc, month asc) as cumulative_party_receipts,
    party_receipts,
    sum(party_disbursements) OVER (PARTITION BY cycle order by year asc, month asc) as cumulative_party_disbursements,
    party_disbursements
from combined
where cycle >= 2008
;

create unique index on ofec_entity_chart_mv_tmp (idx);
create index on ofec_entity_chart_mv_tmp (cycle);
