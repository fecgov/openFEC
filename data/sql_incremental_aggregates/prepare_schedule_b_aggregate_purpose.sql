create or replace function disbursement_purpose(code varchar, description varchar) returns varchar as $$
declare
    cleaned varchar = regexp_replace(description, '[^a-zA-Z0-9]+', ' ');
begin
    return case
        when code in ('24G') then 'TRANSFERS'
        when code in ('24K') then 'CONTRIBUTIONS'
        when code in ('20C', '20F', '20G', '20R', '22J', '22K', '22L', '22U') then 'LOAN-REPAYMENTS'
        when code in ('17R', '20Y', '21Y', '22R', '22Y', '22Z', '23Y', '28L', '40T', '40Y', '40Z', '41T', '41Y', '41Z', '42T', '42Y', '42Z') then 'REFUNDS'
        when cleaned ~* 'salary|overhead|rent|postage|office supplies|office equipment|furniture|ballot access fees|petition drive|party fee|legal fee|accounting fee' then 'ADMINISTRATIVE'
        when cleaned ~* 'travel reimbursement|commercial carrier ticket|reimbursement for use of private vehicle|advance payments? for corporate aircraft|lodging|meal' then 'TRAVEL'
        when cleaned ~* 'direct mail|fundraising event|mailing list|consultant fee|call list|invitations including printing|catering|event space rental' then 'FUNDRAISING'
        when cleaned ~* 'general public advertising|radio|television|print|related production costs|media' then 'ADVERTISING'
        when cleaned ~* 'opinion poll' then 'POLLING'
        when cleaned ~* 'button|bumper sticker|brochure|mass mailing|pen|poster|balloon' then 'MATERIALS'
        when cleaned ~* 'candidate appearance|campaign rall(y|ies)|town meeting|phone bank|catering|get out the vote|canvassing|driving voters to polls' then 'EVENTS'
        when cleaned ~* 'contributions? to federal candidate|contributions? to federal political committee|donations? to nonfederal candidate|donations? to nonfederal committee' then 'CONTRIBUTIONS'
        else 'OTHER'
    end;
end
$$ language plpgsql;

drop table if exists ofec_sched_b_aggregate_purpose;
create table ofec_sched_b_aggregate_purpose as
select
    cmte_id,
    rpt_yr + rpt_yr % 2 as cycle,
    disbursement_purpose(disb_tp, disb_desc) as purpose,
    sum(disb_amt) as total,
    count(disb_amt) as count
from sched_b
where rpt_yr >= :START_YEAR_ITEMIZED
and disb_amt is not null
and (memo_cd != 'X' or memo_cd is null)
group by cmte_id, cycle, purpose
;

create index on ofec_sched_b_aggregate_purpose (cmte_id);
create index on ofec_sched_b_aggregate_purpose (cycle);
create index on ofec_sched_b_aggregate_purpose (purpose);
create index on ofec_sched_b_aggregate_purpose (total);
create index on ofec_sched_b_aggregate_purpose (count);

-- Create update function
create or replace function ofec_sched_b_update_aggregate_purpose() returns void as $$
begin
    with new as (
        select 1 as multiplier, *
        from ofec_sched_b_queue_new
    ),
    old as (
        select -1 as multiplier, *
        from ofec_sched_b_queue_old
    ),
    patch as (
        select
            cmte_id,
            rpt_yr + rpt_yr % 2 as cycle,
            disbursement_purpose(disb_tp, disb_desc) as purpose,
            sum(disb_amt * multiplier) as total,
            sum(multiplier) as count
        from (
            select * from new
            union all
            select * from old
        ) t
        where disb_amt is not null
        and (memo_cd != 'X' or memo_cd is null)
        group by cmte_id, cycle, purpose
    ),
    inc as (
        update ofec_sched_b_aggregate_purpose ag
        set
            total = ag.total + patch.total,
            count = ag.count + patch.count
        from patch
        where (ag.cmte_id, ag.cycle, ag.purpose) = (patch.cmte_id, patch.cycle, patch.purpose)
    )
    insert into ofec_sched_b_aggregate_purpose (
        select patch.* from patch
        left join ofec_sched_b_aggregate_purpose ag using (cmte_id, cycle, purpose)
        where ag.cmte_id is null
    )
    ;
end
$$ language plpgsql;
