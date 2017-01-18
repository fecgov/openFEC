drop materialized view if exists ofec_house_senate_paper_amendments_mv_tmp cascade;
create materialized view ofec_house_senate_paper_amendments_mv_tmp as
with recursive oldest_filing_paper as (
  (
    SELECT cmte_id,
      rpt_yr,
      rpt_tp,
      amndt_ind,
      receipt_dt,
      file_num,
      prev_file_num,
      mst_rct_file_num,
      array[file_num]::numeric[] as amendment_chain,
      array[receipt_dt]::timestamp[] as date_chain,
      1 as depth,
      file_num as last
    FROM disclosure.nml_form_3
    WHERE amndt_ind = 'N' and file_num < 0
  )
  union
  select
    f3.cmte_id,
    f3.rpt_yr,
    f3.rpt_tp,
    f3.amndt_ind,
    f3.receipt_dt,
    f3.file_num,
    f3.prev_file_num,
    f3.mst_rct_file_num,
    (oldest.amendment_chain || f3.file_num)::numeric(7,0)[],
    (oldest.date_chain || f3.receipt_dt)::timestamp[],
    oldest.depth + 1,
    oldest.amendment_chain[1]
  from oldest_filing_paper oldest, disclosure.nml_form_3 f3
  where f3.amndt_ind = 'A' and f3.rpt_tp = oldest.rpt_tp and f3.rpt_yr = oldest.rpt_yr and f3.cmte_id = oldest.cmte_id and f3.file_num < 0 and f3.receipt_dt > date_chain[array_length(date_chain, 1)]
), longest_path as
 --here we find the longest paths
  (SELECT b.*
   FROM oldest_filing_paper a LEFT OUTER JOIN oldest_filing_paper b ON a.file_num = b.file_num
   WHERE a.depth < b.depth
), filtered_longest_path as
  --filtering out erroneous paths that skip intermediate dates
  (select distinct old_f.*
    from oldest_filing_paper old_f inner join longest_path lp
    on  old_f.last = lp.last
    where old_f.file_num <> lp.file_num
   union all
   select * from longest_path
   union all
   select distinct * from oldest_filing_paper ofp where ofp.last not in (select last from longest_path)
   ORDER BY depth desc
)
select
    row_number() over () as idx,
    cmte_id,
    rpt_yr,
    rpt_tp,
    amndt_ind,
    receipt_dt,
    file_num,
    prev_file_num,
    mst_rct_file_num,
    amendment_chain
from filtered_longest_path;

create unique index on ofec_house_senate_paper_amendments_mv_tmp(idx);
