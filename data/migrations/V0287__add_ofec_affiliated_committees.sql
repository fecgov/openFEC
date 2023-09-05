/*
This migration file is to create a mv 
containing all affiliated committees
*/

-- ---------------
-- ofec_affiliated_committees_mv
-- ---------------

CREATE MATERIALIZED VIEW public.ofec_affiliated_committees_mv_tmp AS 
with aff_list as
(SELECT fec_vsum_f1_vw.cmte_id,fec_vsum_f1_vw.affiliated_cmte_id
           FROM fec_vsum_f1_vw
          WHERE fec_vsum_f1_vw.affiliated_cmte_id IS NOT NULL AND fec_vsum_f1_vw.most_recent = 'Y'
union        
         SELECT fec_form_1s_vw.cmte_id, fec_form_1s_vw.affiliated_cmte_id
           FROM fec_form_1s_vw
          WHERE fec_form_1s_vw.affiliated_cmte_id IS NOT NULL AND fec_form_1s_vw.most_recent_filing_flag = 'Y'
        UNION
         SELECT fec_vsum_f1z_vw.cmte_id,
            fec_vsum_f1z_vw.affiliated_cmte_id
           FROM public.fec_vsum_f1z_vw
          WHERE fec_vsum_f1z_vw.affiliated_cmte_id IS NOT null AND fec_vsum_f1z_vw.most_recent = 'Y'
 )
 select 
    aff_list.cmte_id, 
    aff_list.affiliated_cmte_id,
    f1b.cmte_nm as affiliated_cmte_nm,
    f1b.receipt_dt
from aff_list
left join fec_vsum_f1_vw f1b on aff_list.affiliated_cmte_id = f1b.cmte_id
where f1b.most_recent = 'Y'
order by aff_list.cmte_id, aff_list.affiliated_cmte_id
WITH DATA;

-- grant correct ownership/permission
ALTER TABLE public.ofec_affiliated_committees_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_affiliated_committees_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_affiliated_committees_mv_tmp TO fec_read;

-- create index on the _tmp MV
CREATE UNIQUE INDEX idx_ofec_affiliated_committees_tmp_cmte_id_affiliated_cmte_id
  ON public.ofec_affiliated_committees_mv_tmp
  USING btree
  (cmte_id, affiliated_cmte_id);

CREATE INDEX idx_ofec_affiliated_committees_tmp_cmte_id
  ON public.ofec_affiliated_committees_mv_tmp
  USING btree
  (cmte_id);  

CREATE INDEX idx_ofec_affiliated_committees_tmp_affiliated_cmte_id
  ON public.ofec_affiliated_committees_mv_tmp
  USING btree
  (affiliated_cmte_id);    

-- update the interface VW to point to the updated _tmp MV
-- ---------------
CREATE OR REPLACE VIEW public.ofec_affiliated_committees_vw AS 
SELECT * FROM public.ofec_affiliated_committees_mv_tmp;

-- grant correct ownership/permission
ALTER TABLE public.ofec_affiliated_committees_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_affiliated_committees_vw TO fec;
GRANT SELECT ON TABLE public.ofec_affiliated_committees_vw TO fec_read;

-- DROP the original MV and rename the ofec_affiliated_committees_mv_tmp to ofec_affiliated_committees_mv
-- ---------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_affiliated_committees_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_affiliated_committees_mv_tmp RENAME TO ofec_affiliated_committees_mv;

-- Alter index name to remove the _tmp
------------------

ALTER INDEX public.idx_ofec_affiliated_committees_tmp_cmte_id RENAME TO idx_ofec_affiliated_committees_mv_cmte_id;

ALTER INDEX public.idx_ofec_affiliated_committees_tmp_affiliated_cmte_id RENAME TO idx_ofec_affiliated_committees_mv_affiliated_cmte_id;
