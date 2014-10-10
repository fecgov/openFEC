CREATE OR REPLACE VIEW candidate AS
SELECT cand_sk,
       cand_id,
       load_date,
       expire_date,
       row_to_json(s) AS candidate
FROM (
  SELECT *
  FROM   dimcand
  ) s;

SELECT '      ' || table_name || '.' || column_name || ','
FROM   information_schema.columns
WHERE  table_name = 'dimcandoffice'
AND    table_schema = 'public'
ORDER BY ordinal_position;

DROP VIEW IF EXISTS candidate1;
CREATE OR REPLACE VIEW candidate1 AS
SELECT dimcand.*,
       dimcandproperties.candproperties_sk,
       dimcandproperties.form_sk AS properties_form_sk,
       dimcandproperties.form_tp AS properties_form_tp,
       dimcandproperties.cand_nm,
       dimcandproperties.cand_l_nm,
       dimcandproperties.cand_f_nm,
       dimcandproperties.cand_m_nm,
       dimcandproperties.cand_prefix,
       dimcandproperties.cand_suffix,
       dimcandproperties.cand_st1,
       dimcandproperties.cand_st2,
       dimcandproperties.cand_city,
       dimcandproperties.cand_st,
       dimcandproperties.cand_zip,
       dimcandproperties.cand_status_cd,
       dimcandproperties.cand_status_desc,
       dimcandproperties.cand_ici_cd,
       dimcandproperties.cand_ici_desc,
       dimcandproperties.prim_pers_funds_decl,
       dimcandproperties.gen_pers_funds_decl,
       dimcandproperties.load_date AS property_load_date,
       dimcandproperties.expire_date AS property_expire_date,
       dimcandoffice.candoffice_sk,
       dimcandoffice.office_sk,
       dimcandoffice.party_sk,
       dimcandoffice.form_sk AS office_form_sk,
       dimcandoffice.form_tp AS office_form_tp,
       dimcandoffice.cand_election_yr,
       dimcandoffice.load_date AS office_load_dt,
       dimcandoffice.expire_date AS office_expire_dt       
FROM   dimcand
JOIN   dimcandproperties ON (dimcand.cand_sk = dimcandproperties.cand_sk)
JOIN   dimcandoffice ON (dimcand.cand_sk = dimcandproperties.cand_sk);
       
CREATE OR REPLACE VIEW candidate AS
SELECT cand_sk,
       cand_id,
       load_date,
       expire_date,
       row_to_json(s) AS candidate
FROM (
  SELECT dimcand.*,
    ( select array_to_json(array_agg(row_to_json(s1, true)), true)
      from (
        select dimcandproperties.*
        from   dimcandproperties
        where  dimcandproperties.cand_sk = dimcand.cand_sk
        order by expire_date desc nulls first
           ) s1
    ) as properties,  
    ( select array_to_json(array_agg(row_to_json(s2, true)), true)
      from (
        select dimcandoffice.*
        from   dimcandoffice
        where  dimcandoffice.cand_sk = dimcand.cand_sk
        order by expire_date desc nulls first
           ) s2
    ) as offices,
    ( select array_to_json(array_agg(row_to_json(s3, true)), true)
      from (
        select dimcandstatusici.*
        from   dimcandstatusici
        where  dimcandstatusici.cand_sk = dimcand.cand_sk
        order by expire_date desc nulls first
           ) s3
    ) as status    
  FROM dimcand
  ) s;

-- need to lump up unique cand_ids with a series of cand_sks
-- then the offices under that?

:w


