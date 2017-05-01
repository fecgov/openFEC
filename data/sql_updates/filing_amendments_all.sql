drop materialized view if exists ofec_amendments_mv_tmp cascade;
create materialized view ofec_amendments_mv_tmp as
with recursive oldest_filing as (
  (
    SELECT cand_cmte_id, rpt_yr, rpt_tp, amndt_ind, cast(cast(receipt_dt as text) as date) as receipt_date, file_num, prev_file_num, array[file_num]::numeric[] as amendment_chain, 1 as depth, file_num as last
    FROM disclosure.f_rpt_or_form_sub
    WHERE (file_num = prev_file_num or prev_file_num is null) and file_num > 0
  )
  union
  select f3.cand_cmte_id, f3.rpt_yr, f3.rpt_tp, f3.amndt_ind, cast(cast(f3.receipt_dt as text) as date) as receipt_date, f3.file_num, f3.prev_file_num, (oldest.amendment_chain || f3.file_num)::numeric(7,0)[], oldest.depth + 1, oldest.amendment_chain[1]
  from oldest_filing oldest, disclosure.f_rpt_or_form_sub f3
  where f3.prev_file_num = oldest.file_num and f3.file_num <> f3.prev_file_num and f3.file_num > 0
), most_recent_filing as (
    select a.*
    from oldest_filing a
      left outer join oldest_filing b
        on a.cand_cmte_id = b.cand_cmte_id and a.last = b.last and a.depth < b.depth
    where b.cand_cmte_id is null
), electronic_filer_chain as (
SELECT old_f.cand_cmte_id,
  old_f.rpt_yr,
  old_f.rpt_tp,
  old_f.amndt_ind,
  old_f.receipt_date,
  old_f.file_num,
  old_f.prev_file_num,
  mrf.file_num as mst_rct_file_num,
  old_f.amendment_chain
from oldest_filing old_f inner join most_recent_filing mrf on old_f.cand_cmte_id = mrf.cand_cmte_id and old_f.last = mrf.last
) select row_number() over () as idx, * from electronic_filer_chain;

create unique index on ofec_amendments_mv_tmp(idx);
