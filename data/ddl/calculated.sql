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

CREATE INDEX ON dimcandproperties (cand_sk, expire_date);

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

CREATE INDEX ON dimcandoffice (cand_sk, expire_date);

ALTER TABLE dimcandoffice ADD COLUMN effective tsrange;

WITH s AS (
  SELECT cand_sk,
         candoffice_sk,
         lag(expire_date) over 
           (partition by cand_sk
            order by expire_date, candoffice_sk) beg,
         expire_date
  FROM   dimcandoffice)  
UPDATE dimcandoffice p 
SET    effective = tsrange(s.beg, s.expire_date, '[)')
FROM   s
WHERE  p.candoffice_sk = s.candoffice_sk;

DELETE FROM candproperties_to_candoffice;
INSERT INTO candproperties_to_candoffice (candproperties_sk, candoffice_sk)
SELECT p.candproperties_sk,
       o.candoffice_sk
FROM   dimcandproperties p
JOIN   dimcandoffice o ON (p.cand_sk = o.cand_sk
                           AND p.effective && o.effective);