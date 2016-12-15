drop materialized view if exists ofec_house_senate_electronic_amendments_mv_tmp cascade;
create materialized view ofec_house_senate_electronic_amendments_mv_tmp as
with recursive oldest_filing as (
  (
    SELECT cmte_id, rpt_yr, rpt_tp, amndt_ind, receipt_dt, file_num, prev_file_num, mst_rct_file_num, array[file_num]::numeric[] as amendment_chain, 1 as depth, file_num as last
    FROM disclosure.nml_form_3
    WHERE file_num = prev_file_num AND file_num = mst_rct_file_num and file_num > 0
  )
  union
  select f3.cmte_id, f3.rpt_yr, f3.rpt_tp, f3.amndt_ind, f3.receipt_dt, f3.file_num, f3.prev_file_num, f3.mst_rct_file_num, (oldest.amendment_chain || f3.file_num)::numeric(7,0)[], oldest.depth + 1, oldest.amendment_chain[1]
  from oldest_filing oldest, disclosure.nml_form_3 f3
  where f3.prev_file_num = oldest.file_num and f3.rpt_tp = oldest.rpt_tp and f3.file_num <> f3.prev_file_num and f3.file_num > 0
),
--this joins the right sight to left having the effect that the max depth row will be null,
--the where statement then filters down to those rows.
--  Ref: http://stackoverflow.com/questions/7745609/sql-select-only-rows-with-max-value-on-a-column
 most_recent_filing as (
    select a.*
    from oldest_filing a
      left outer join oldest_filing b
        on a.cmte_id = b.cmte_id and a.last = b.last and a.depth < b.depth
    where b.cmte_id is null
), electronic_filer_chain as (
SELECT old_f.cmte_id,
  old_f.rpt_yr,
  old_f.rpt_tp,
  old_f.amndt_ind,
  old_f.receipt_dt,
  old_f.file_num,
  old_f.prev_file_num,
  mrf.file_num as mst_rct_file_num,
  old_f.amendment_chain
from oldest_filing old_f inner join most_recent_filing mrf on old_f.cmte_id = mrf.cmte_id and old_f.last = mrf.last
) select row_number() over () as idx, * from electronic_filer_chain;

drop index if exists file_number_house_senate_electronic_index;
create unique index file_number_house_senate_electronic_index on ofec_house_senate_electronic_amendments_mv_tmp(idx);

drop materialized view if exists ofec_house_senate_paper_amendments_mv_tmp;
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
  --filterng out erroneuou paths that skip intermediate dates
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

drop index if exists file_number_house_senate_paper_index;
create unique index file_number_house_senate_paper_index on ofec_house_senate_paper_amendments_mv_tmp(idx);
