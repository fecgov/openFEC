-- for development only - because expire_date unset 
UPDATE dimcandoffice
SET    expire_date = (cand_election_yr || '-11-04' )::timestamp
                     + (candoffice_sk || ' seconds')::interval;

WITH s AS (
  SELECT candoffice_sk,
         row_number() OVER (PARTITION BY cand_sk ORDER BY candoffice_sk DESC)
         AS rank_from_present
  FROM   dimcandoffice)
UPDATE dimcandoffice o
SET    expire_date = NULL
FROM   s
WHERE  o.candoffice_sk = s.candoffice_sk
AND    s.rank_from_present = 1;

UPDATE dimcandproperties SET expire_date = NULL;

WITH s AS (
  SELECT candproperties_sk,
         row_number() OVER (PARTITION BY cand_sk ORDER BY candproperties_sk DESC)
         AS rank_from_present
  FROM   dimcandproperties)
UPDATE dimcandproperties p
SET    expire_date = current_timestamp - (s.rank_from_present || ' years')::interval
FROM   s
WHERE  p.candproperties_sk = s.candproperties_sk
AND    s.rank_from_present > 1;