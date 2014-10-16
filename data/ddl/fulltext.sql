
DROP TABLE IF EXISTS dimcand_fulltext;
CREATE TABLE dimcand_fulltext AS
  SELECT cand_sk, 
         NULL::tsvector AS fulltxt
  FROM   dimcand;
                         
WITH cnd AS (
  SELECT c.cand_sk,
         setweight(to_tsvector(string_agg(p.cand_nm, ' ')), 'A') ||
         setweight(to_tsvector(string_agg(p.cand_city, ' ')), 'B  ') ||
         setweight(to_tsvector(string_agg(p.cand_st, ' ')), 'A') || 
         setweight(to_tsvector(string_agg(o.office_tp_desc, ' ')), 'A')
         AS weights
  FROM   dimcand c
  JOIN   dimcandproperties p ON (c.cand_sk = p.cand_sk)
  JOIN   dimcandoffice co ON (co.cand_sk = c.cand_sk)
  JOIN   dimoffice o ON (co.office_sk = o.office_sk)
  GROUP BY c.cand_sk)
UPDATE dimcand_fulltext 
SET    fulltxt = (SELECT weights FROM cnd
                  WHERE  dimcand_fulltext.cand_sk = cnd.cand_sk);                          
             
CREATE INDEX cand_fts_idx ON dimcand_fulltext USING gin(fulltxt);    

select cand_sk from dimcand_fulltext 
where 'obama' @@ fulltxt
order by ts_rank_cd(fulltxt, 'obama') desc;


DROP TABLE IF EXISTS dimcmte_fulltext;
CREATE TABLE dimcmte_fulltext AS
  SELECT cmte_sk, 
         NULL::tsvector AS fulltxt
  FROM   dimcmte;
                         
WITH cmte AS (
  SELECT c.cmte_sk,
         setweight(to_tsvector(string_agg(p.cmte_nm, ' ')), 'A') ||
         setweight(to_tsvector(string_agg(p.cmte_city, ' ')), 'B  ') ||
         setweight(to_tsvector(string_agg(p.cmte_st, ' ')), 'B') || 
         setweight(to_tsvector(string_agg(p.cmte_st_desc, ' ')), 'B') || 
         setweight(to_tsvector(string_agg(p.cmte_web_url, ' ')), 'B') || 
         setweight(to_tsvector(string_agg(p.fst_cand_nm, ' ')), 'A') || 
         setweight(to_tsvector(string_agg(p.sec_cand_nm, ' ')), 'A') || 
         setweight(to_tsvector(string_agg(p.trd_cand_nm, ' ')), 'A') || 
         setweight(to_tsvector(string_agg(p.frth_cand_nm, ' ')), 'A') || 
         setweight(to_tsvector(string_agg(p.fith_cand_nm, ' ')), 'A')  
         AS weights
  FROM   dimcmte c
  JOIN   dimcmteproperties p ON (c.cmte_sk = p.cmte_sk)
  GROUP BY c.cmte_sk)
UPDATE dimcmte_fulltext 
SET    fulltxt = (SELECT weights FROM cmte
                  WHERE  dimcmte_fulltext.cmte_sk = cmte.cmte_sk);                          
             
CREATE INDEX cmte_fts_idx ON dimcmte_fulltext USING gin(fulltxt);    
