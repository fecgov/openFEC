/*
This migration file is to create a mv 
containing all affiliated committees and jfc's 
*/

-- ---------------
-- ofec_affiliated_committees_mv
-- ---------------

CREATE MATERIALIZED VIEW public.ofec_affiliated_committees_tmp AS 
	with cmte as (
select distinct on (cmte_id, affiliated_cmte_id) cmte_id, affiliated_cmte_id, affiliated_cmte_nm
from fec_vsum_f1_vw
where affiliated_cmte_nm is not null and affiliated_cmte_nm not in ('NONE', 'N/A', '-', '.', 'BLANK')
),
cmte_1s as (
select distinct on (cmte_id, affiliated_cmte_id) cmte_id, affiliated_cmte_id, affiliated_cmte_nm
from fec_form_1s_vw 
where affiliated_cmte_nm is not null and affiliated_cmte_nm not in ('NONE', 'N/A', '-', '.', 'BLANK')
)
select 
cmte.cmte_id,
cmte.affiliated_cmte_id, 
cmte.affiliated_cmte_nm,
aff.filed_cmte_tp, 
aff.filed_cmte_tp_desc,
aff.form_tp,
aff.form_tp_desc, 
aff.receipt_dt 
from cmte
left join fec_vsum_f1_vw aff
on cmte.affiliated_cmte_id = aff.cmte_id
where aff.first_form_1  is null or aff.first_form_1 = 'Y'
union 
select 
cmte_1s.cmte_id,
cmte_1s.affiliated_cmte_id, 
cmte_1s.affiliated_cmte_nm,
aff.filed_cmte_tp, 
aff.filed_cmte_tp_desc,
aff.form_tp,
aff.form_tp_desc, 
aff.receipt_dt 
from cmte_1s
left join fec_vsum_f1_vw aff
on cmte_1s.affiliated_cmte_id = aff.cmte_id
where aff.first_form_1  is null or aff.first_form_1 = 'Y'
WITH DATA;

-- grant correct ownership/permission
ALTER TABLE public.ofec_affiliated_committees_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_affiliated_committees_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_affiliated_committees_tmp TO fec_read;

-- create index on the _tmp MV
CREATE UNIQUE INDEX idx_ofec_affiliated_committees_tmp_aff_cmte_id_cmte_id
  ON public.ofec_affiliated_committees_tmp
  USING btree
  (cmte_id, affiliated_cmte_id);

CREATE INDEX idx_ofec_affiliated_committees_tmp_receipt_dt
  ON public.ofec_affiliated_committees_tmp
  USING btree
  (receipt_dt);

CREATE INDEX idx_ofec_affiliated_committees_tmp_filed_cmte_tp
  ON public.ofec_affiliated_committees_tmp
  USING btree
  (filed_cmte_tp);

CREATE INDEX idx_ofec_affiliated_committees_tmp_cmte_id
  ON public.ofec_affiliated_committees_tmp
  USING btree
  (cmte_id);  

CREATE INDEX idx_ofec_affiliated_committees_tmp_affiliated_cmte_id
  ON public.ofec_affiliated_committees_tmp
  USING btree
  (affiliated_cmte_id);    

CREATE INDEX idx_ofec_affiliated_committees_tmp_affiliated_cmte_nm
  ON public.ofec_affiliated_committees_tmp
  USING btree
  (affiliated_cmte_nm); 

-- update the interface VW to point to the updated _tmp MV
-- ---------------
CREATE OR REPLACE VIEW public.ofec_affiliated_committees_vw AS 
SELECT * FROM public.ofec_affiliated_committees_tmp;

-- grant correct ownership/permission
ALTER TABLE public.ofec_affiliated_committees_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_affiliated_committees_vw TO fec;
GRANT SELECT ON TABLE public.ofec_affiliated_committees_vw TO fec_read;

-- DROP the original MV and rename the ofec_affiliated_committees_tmp to ofec_affiliated_committees_mv
-- ---------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_affiliated_committees_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_affiliated_committees_tmp RENAME TO ofec_affiliated_committees_mv;

-- Alter index name to remove the _tmp
-- ---------------
ALTER INDEX public.idx_ofec_affiliated_committees_tmp_receipt_dt RENAME TO idx_ofec_affiliated_committees_mv_receipt_dt;

ALTER INDEX public.idx_ofec_affiliated_committees_tmp_filed_cmte_tp RENAME TO idx_ofec_affiliated_committees_mv_filed_cmte_tp;

ALTER INDEX public.idx_ofec_affiliated_committees_tmp_cmte_id RENAME TO idx_ofec_affiliated_committees_mv_cmte_id;

ALTER INDEX public.idx_ofec_affiliated_committees_tmp_affiliated_cmte_id RENAME TO idx_ofec_affiliated_committees_mv_affiliated_cmte_id;

ALTER INDEX public.idx_ofec_affiliated_committees_tmp_affiliated_cmte_nm RENAME TO idx_ofec_affiliated_committees_mv_affiliated_cmte_nm;
