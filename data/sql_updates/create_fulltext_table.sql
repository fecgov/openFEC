-- Creates and populates the _fulltext tables.

DROP TABLE if exists dimcand_fulltext;
CREATE TABLE dimcand_fulltext AS
  SELECT cand_sk,
         NULL::tsvector AS fulltxt
  FROM   dimcand;

WITH cnd AS (
  SELECT c.cand_sk,
         setweight(to_tsvector(string_agg(coalesce(p.cand_nm, ''), ' ')), 'A') ||
         setweight(to_tsvector(string_agg(coalesce(c.cand_id, ''), ' ')), 'B')
         AS weights
  FROM   dimcand c
  JOIN   dimcandproperties p ON (c.cand_sk = p.cand_sk)
  GROUP BY c.cand_sk)
UPDATE dimcand_fulltext
SET    fulltxt = (SELECT weights FROM cnd
                  WHERE  dimcand_fulltext.cand_sk = cnd.cand_sk);

CREATE INDEX cand_fts_idx ON dimcand_fulltext USING gin(fulltxt);


DROP TABLE if exists dimcmte_fulltext;
CREATE TABLE dimcmte_fulltext AS
  SELECT cmte_sk,
         NULL::tsvector AS fulltxt
  FROM   dimcmte;

WITH cmte AS (
  SELECT c.cmte_sk,
         setweight(to_tsvector(string_agg(coalesce(p.cmte_nm, ''), ' ')), 'A') ||
         setweight(to_tsvector(string_agg(coalesce(p.cmte_id, ''), ' ')), 'B')
         AS weights
  FROM   dimcmte c
  JOIN   dimcmteproperties p ON (c.cmte_sk = p.cmte_sk)
  GROUP BY c.cmte_sk)
UPDATE dimcmte_fulltext
SET    fulltxt = (SELECT weights FROM cmte
                  WHERE  dimcmte_fulltext.cmte_sk = cmte.cmte_sk);

CREATE INDEX cmte_fts_idx ON dimcmte_fulltext USING gin(fulltxt);


DROP TABLE if exists name_search_fulltext;
CREATE TABLE name_search_fulltext AS
WITH ranked AS (
SELECT
       p.cand_nm AS name,
       to_tsvector(p.cand_nm) as name_vec,
       c.cand_id,
       row_number() OVER (partition by c.cand_id
                          order by p.load_date desc) AS load_order,
       NULL::text AS cmte_id,
       o.office_tp AS office_sought
FROM   dimcand c
JOIN   dimcandproperties p ON (p.cand_sk = c.cand_sk)
JOIN   dimcandoffice co ON (co.cand_sk = c.cand_sk)
JOIN   dimoffice o ON (co.office_sk = o.office_sk)
)
SELECT DISTINCT
       name,
       name_vec,
       cand_id,
       cmte_id,
       office_sought
FROM   ranked
WHERE  load_order = 1;

INSERT INTO name_search_fulltext
WITH ranked AS (
SELECT
       p.cmte_nm AS name,
       to_tsvector(p.cmte_nm) AS name_vec,
       c.cmte_id,
       row_number() OVER (partition by c.cmte_id
                          order by p.load_date desc) AS load_order
FROM   dimcmte c
JOIN   dimcmteproperties p ON (p.cmte_sk = c.cmte_sk)
)
SELECT DISTINCT
       name,
       name_vec,
       NULL AS cand_id,
       cmte_id,
       NULL AS office_sought
FROM   ranked
WHERE  load_order = 1;

CREATE INDEX name_search_fts_idx ON name_search_fulltext USING gin(name_vec);


