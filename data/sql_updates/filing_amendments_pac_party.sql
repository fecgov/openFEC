drop materialized view if exists ofec_pac_party_electronic_amendments_mv_tmp cascade;
create materialized view ofec_pac_party_electronic_amendments_mv_tmp as
with recursive oldest_filing as (
  (
    SELECT cmte_id, rpt_yr, rpt_tp, amndt_ind, receipt_dt, file_num, prev_file_num, mst_rct_file_num, array[file_num]::numeric[] as amendment_chain, 1 as depth, file_num as last
    FROM disclosure.nml_form_3x
    WHERE file_num = prev_file_num AND file_num = mst_rct_file_num and file_num > 0
  )
  union
  select f3x.cmte_id, f3x.rpt_yr, f3x.rpt_tp, f3x.amndt_ind, f3x.receipt_dt, f3x.file_num, f3x.prev_file_num, f3x.mst_rct_file_num, (oldest.amendment_chain || f3x.file_num)::numeric(7,0)[], oldest.depth + 1, oldest.amendment_chain[1]
  from oldest_filing oldest, disclosure.nml_form_3x f3x
  where f3x.prev_file_num = oldest.file_num and f3x.rpt_tp = oldest.rpt_tp and f3x.file_num <> f3x.prev_file_num and f3x.file_num > 0
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
) select * from electronic_filer_chain;

drop materialized view if exists ofec_pac_party_paper_amendments_mv_tmp cascade;
create materialized view ofec_pac_party_paper_amendments_mv_tmp as
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
    FROM disclosure.nml_form_3x
    WHERE amndt_ind = 'N' and file_num < 0
  )
  union
  select
    f3x.cmte_id,
    f3x.rpt_yr,
    f3x.rpt_tp,
    f3x.amndt_ind,
    f3x.receipt_dt,
    f3x.file_num,
    f3x.prev_file_num,
    f3x.mst_rct_file_num,
    (oldest.amendment_chain || f3x.file_num)::numeric(7,0)[],
    (oldest.date_chain || f3x.receipt_dt)::timestamp[],
    oldest.depth + 1,
    oldest.amendment_chain[1]
  from oldest_filing_paper oldest, disclosure.nml_form_3x f3x
  where f3x.amndt_ind = 'A' and f3x.rpt_tp = oldest.rpt_tp and f3x.rpt_yr = oldest.rpt_yr and f3x.cmte_id = oldest.cmte_id and f3x.file_num < 0 and f3x.receipt_dt > date_chain[array_length(date_chain, 1)]
), longest_path as
 --select distinct on (file_num, depth) * from oldest_filing
 --where file_num = -8442913 or file_num = -8393823 or file_num = -8397828
 --order by depth desc;
  (SELECT b.*
   FROM oldest_filing_paper a LEFT OUTER JOIN oldest_filing_paper b ON a.file_num = b.file_num
   WHERE a.depth < b.depth
), filtered_longest_path as
   (select distinct old_f.* from oldest_filing_paper old_f, longest_path lp where old_f.date_chain <= lp.date_chain
  order by depth desc),
  paper_recent_filing as (
      SELECT a.*
      from filtered_longest_path a LEFT OUTER JOIN  filtered_longest_path b
        on a.cmte_id = b.cmte_id and a.last = b.last and a.depth < b.depth
        where b.cmte_id is null
  ),
    paper_filer_chain as(
      select flp.cmte_id,
      flp.rpt_yr,
      flp.rpt_tp,
      flp.amndt_ind,
      flp.receipt_dt,
      flp.file_num,
      flp.prev_file_num,
      prf.file_num as mst_rct_file_num,
      flp.amendment_chain
      from filtered_longest_path flp inner join paper_recent_filing prf on flp.cmte_id = prf.cmte_id
        and flp.last = prf.last)
    select * from paper_filer_chain;


