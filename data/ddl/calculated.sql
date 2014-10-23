DROP TABLE IF EXISTS candproperties_to_candoffice CASCADE;
CREATE TABLE candproperties_to_candoffice
  ( candproperties_sk INTEGER NOT NULL 
      REFERENCES dimcandproperties (candproperties_sk), 
    candoffice_sk INTEGER NOT NULL
      REFERENCES dimcandoffice (candoffice_sk), 
    PRIMARY KEY (candproperties_sk, candoffice_sk)
  );

GRANT SELECT ON candproperties_to_candoffice TO webro;
  
ALTER TABLE dimcandproperties ADD COLUMN effective tsrange;

WITH s AS (
  SELECT cand_sk,
         candproperties_sk,
         lag(expire_date) over 
           (partition by cand_sk
            order by expire_date, candproperties_sk) beg,
         expire_date
  FROM   dimcandproperties)  
UPDATE dimcandproperties p 
SET    effective = tsrange(s.beg, s.expire_date, '[)')
FROM   s
WHERE  p.candproperties_sk = s.candproperties_sk;

ALTER TABLE dimcandoffice ADD COLUMN effective tsrange;

WITH s AS (
  SELECT cand_sk,
         candoffice_sk,
         lag(cand_election_yr) over 
           (partition by cand_sk
            order by cand_election_yr, candoffice_sk) prev,
         cand_election_yr
  FROM   dimcandproperties)  
UPDATE dimcandproperties p 
SET    effective = tsrange(s.beg, s.expire_date, '[)')
FROM   s
WHERE  p.candproperties_sk = s.candproperties_sk;


