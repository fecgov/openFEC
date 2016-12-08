with recursive oldest_filing as (
  (
    SELECT cmte_id, rpt_yr, rpt_tp, amndt_ind, receipt_dt, file_num, prev_file_num, mst_rct_file_num, array[file_num]::numeric[] as amendment_chain, 1 as depth, file_num as last
    FROM disclosure.nml_form_3p
    WHERE file_num = prev_file_num AND file_num = mst_rct_file_num and file_num > 0
  )
  union
  select f3p.cmte_id, f3p.rpt_yr, f3p.rpt_tp, f3p.amndt_ind, f3p.receipt_dt, f3p.file_num, f3p.prev_file_num, f3p.mst_rct_file_num, (oldest.amendment_chain || f3p.file_num)::numeric(7,0)[], oldest.depth + 1, oldest.amendment_chain[1]
  from oldest_filing oldest, disclosure.nml_form_3p f3p
  where f3p.prev_file_num = oldest.file_num and f3p.rpt_tp = oldest.rpt_tp and f3p.file_num <> f3p.prev_file_num and f3p.file_num > 0
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
)
SELECT old_f.cmte_id,
  old_f.rpt_yr,
  old_f.rpt_tp,
  old_f.amndt_ind,
  old_f.receipt_dt,
  old_f.file_num,
  old_f.prev_file_num,
  mrf.file_num as mst_rct_file_num,
  old_f.amendment_chain
from oldest_filing old_f inner join most_recent_filing mrf on old_f.cmte_id = mrf.cmte_id and old_f.last = mrf.last;


with recursive oldest_filing as (
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
    FROM disclosure.nml_form_3p
    WHERE amndt_ind = 'N' and file_num < 0
  )
  union
  select
    f3p.cmte_id,
    f3p.rpt_yr,
    f3p.rpt_tp,
    f3p.amndt_ind,
    f3p.receipt_dt,
    f3p.file_num,
    f3p.prev_file_num,
    f3p.mst_rct_file_num,
    (oldest.amendment_chain || f3p.file_num)::numeric(7,0)[],
    (oldest.date_chain || f3p.receipt_dt)::timestamp[],
    oldest.depth + 1,
    oldest.amendment_chain[1]
  from oldest_filing oldest, disclosure.nml_form_3p f3p
  where f3p.amndt_ind = 'A' and f3p.rpt_tp = oldest.rpt_tp and f3p.rpt_yr = oldest.rpt_yr and f3p.cmte_id = oldest.cmte_id and f3p.file_num < 0 and f3p.receipt_dt > date_chain[array_length(date_chain, 1)]
), longest_path as
 --select distinct on (file_num, depth) * from oldest_filing
 --where file_num = -8442913 or file_num = -8393823 or file_num = -8397828
 --order by depth desc;
(SELECT b.*
 FROM oldest_filing a LEFT OUTER JOIN oldest_filing b ON a.file_num = b.file_num
 WHERE a.depth < b.depth AND (b.file_num = -8442913 OR b.file_num = -8393823 OR b.file_num = -8397828)
) select old_f.* from oldest_filing old_f, longest_path lp where old_f.date_chain <= lp.date_chain
 and (old_f.file_num = -8442913 OR old_f.file_num = -8393823 OR old_f.file_num = -8397828);