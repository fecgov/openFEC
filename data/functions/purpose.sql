create or replace function disbursement_purpose(code text, description text) returns varchar as $$
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
$$ language plpgsql immutable;
