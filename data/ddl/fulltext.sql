
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

