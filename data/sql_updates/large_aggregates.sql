drop table if exists large_aggregates_tmp;
create table large_aggregates_tmp as
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
    where most_recent_filing_flag like 'Y'
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
    where most_recent_filing_flag like 'Y'
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
        ) as adjusted_total_receipts,
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
pac_totals as (
    select
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
        ) as adjusted_total_receipts,
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
                coalesce(ttl_op_exp_per,0) +
                coalesce(fed_cand_contb_ref_per,0) +
                coalesce(tranf_from_nonfed_acct_per,0) +
                coalesce(loan_repymts_received_per,0) +
                coalesce(ttl_contb_refund,0)
            )
        ) as adjusted_total_receipts,
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
        ofec_committee_detail_mv_tmp on committee_id = cmte_id
    where
        most_recent_filing_flag like 'Y'
        and ofec_committee_detail_mv_tmp.committee_type in ('X', 'Y')
        and ofec_committee_detail_mv_tmp.designation <> 'J'
        -- do we have this ?
        -- and cm.cmte_id not in (select cmte_id from pclark.ref_pty_host_convention)
    group by
        month,
        year
),
-- other
-- Independent expenditure only
ie as (
    select
        extract(month from to_date(cast(coverage_end_date as text), 'YYYY-MM-DD')) as month,
        extract(year from to_date(cast(coverage_end_date as text), 'YYYY-MM-DD')) as year,
        sum(independent_expenditures_period) as receipts,
        sum(independent_contributions_period) as disbursements
    from ofec_reports_ie_only_mv_tmp
    group by
        month,
        year
),
-- communication cost
communicaiton as (
    select
        extract(month from to_date(cast(communication_dt as text), 'YYYY-MM-DD')) as month,
        extract(year from to_date(cast(communication_dt as text), 'YYYY-MM-DD')) as year,
        null::float as receipts,
        sum(communication_cost) as disbursements
    from ofec_communication_cost_mv_tmp
    group by
        month,
        year
),
-- electioneering
electioneering as (
    select
        extract(month from to_date(cast(disb_dt as text), 'YYYY-MM-DD')) as month,
        extract(year from to_date(cast(disb_dt as text), 'YYYY-MM-DD')) as year,
        null::float as receipts,
        sum(calculated_cand_share) as adjusted_total_disbursements
    from electioneering_com_vw
    group by
        month,
        year
),
-- (why not delegate?)
other as(
    select
        'other'::text as type,
        month,
        year,
        sum(receipts),
        sum(disbursements)
    from (
        select * from ie
        union all
        select * from communicaiton
        union all
        select * from electioneering
    ) conglomerate
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
    union all
    select * from other
)
select
    row_number() over () as idx,
    year::numeric + (year::numeric % 2) as cycle,
    combined.*
from combined
;

-- creates cumulative table per cycle from the data receipts in the large aggregates
drop table if exists entity_receipts_chart;
create table entity_receipts_chart as (select idx, type, month, year, cycle, adjusted_total_receipts, sum(adjusted_total_receipts) OVER (PARTITION BY cycle, type order by year, month, type desc) from large_aggregates_tmp);

-- creates cumulative table per cycle from the data disbursements in the large aggregates
drop table if exists entity_disbursements_chart;
create table entity_disbursements_chart as (select idx, type, month, year, cycle, adjusted_total_disbursements, sum(adjusted_total_disbursements) OVER (PARTITION BY cycle, type order by year, month, type desc) from large_aggregates_tmp);

-- don't need this after making the charts
drop table if exists large_aggregates_tmp;

create unique index on entity_receipts_chart (idx);
create index on entity_receipts_chart (cycle);

create unique index on entity_disbursements_chart (idx);
create index on entity_disbursements_chart (cycle);
