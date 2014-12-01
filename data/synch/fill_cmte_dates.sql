-- run on cfdm on the bridge machine
UPDATE public.dimcand p
SET    load_date = o.receipt_dt
FROM   frn.form_2 o
WHERE  p.form_sk = o.form_2_sk
AND    p.form_tp IN ('F2', 'F2Z');

UPDATE public.dimcandoffice p
SET    load_date = o.receipt_dt
FROM   frn.form_2 o
WHERE  p.form_sk = o.form_2_sk
AND    p.form_tp IN ('F2', 'F2Z');

UPDATE public.dimcandproperties p
SET    load_date = o.receipt_dt
FROM   frn.form_2 o
WHERE  p.form_sk = o.form_2_sk
AND    p.form_tp IN ('F2', 'F2Z');

-- dimcandstatusici has no form_sk

UPDATE public.dimcmte p
SET    load_date = o.receipt_dt
FROM   frn.form_1 o
WHERE  p.form_sk = o.form_1_sk
AND    p.form_tp IN ('F1', 'F1Z');

UPDATE public.dimcmteproperties p
SET    load_date = o.receipt_dt
FROM   frn.form_1 o
WHERE  p.form_sk = o.form_1_sk
AND    p.form_tp IN ('F1', 'F1Z');

-- no form data for dimlinkages
-- dimcmtetpdsgn (but that has a receipt_date)
-- dimoffice
-- dimparty


UPDATE public.facthousesenate_f3 p
SET    load_date = o.load_date
FROM   frn.form_3 o
WHERE  p.form_3_sk = o.form_3_sk;

UPDATE public.factpacsandparties_f3x p
SET    load_date = o.receipt_dt
FROM   frn.form_3x o
WHERE  p.form_3x_sk = o.form_3x_sk;

UPDATE public.factpresidential_f3p p
SET    load_date = o.receipt_dt
FROM   frn.form_3p o
WHERE  p.form_3p_sk = o.form_3p_sk;

-- this runs but does not actually update anything -
-- cand_ids are unique in dimcand
WITH s AS (
  SELECT cand_sk,
         lead(load_date) over
           (partition by cand_id
            order by load_date, cand_sk) end_date,
         load_date
  FROM   public.dimcand)
UPDATE public.dimcand p
SET    -- effective = tsrange(s.beg, s.expire_date, '[)'),
       expire_date = s.end_date
FROM   s
WHERE  p.cand_sk = s.cand_sk;

WITH s AS (
  SELECT cand_sk,
         candoffice_sk,
         lead(load_date) over
           (partition by cand_sk
            order by load_date, candoffice_sk) end_date,
         load_date
  FROM   public.dimcandoffice)
UPDATE public.dimcandoffice p
SET    -- effective = tsrange(s.beg, s.expire_date, '[)'),
       expire_date = s.end_date
FROM   s
WHERE  p.candoffice_sk = s.candoffice_sk;


WITH s AS (
  SELECT cand_sk,
         candproperties_sk,
         lead(load_date) over
           (partition by cand_sk
            order by load_date, candproperties_sk) end_date,
         load_date
  FROM   public.dimcandproperties)
UPDATE public.dimcandproperties p
SET    -- effective = tsrange(s.beg, s.expire_date, '[)'),
       expire_date = s.end_date
FROM   s
WHERE  p.candproperties_sk = s.candproperties_sk;


WITH s AS (
  SELECT cmte_sk,
         lead(load_date) over
           (partition by cmte_id
            order by load_date, cmte_sk) end_date,
         load_date
  FROM   public.dimcmte)
UPDATE public.dimcmte p
SET    -- effective = tsrange(s.beg, s.expire_date, '[)'),
       expire_date = s.end_date
FROM   s
WHERE  p.cmte_sk = s.cmte_sk;

WITH s AS (
  SELECT cmte_sk,
         cmteproperties_sk,
         lead(load_date) over
           (partition by cmte_sk
            order by load_date, cmteproperties_sk) end_date,
         load_date
  FROM   public.dimcmteproperties)
UPDATE public.dimcmteproperties p
SET    -- effective = tsrange(s.beg, s.expire_date, '[)'),
       expire_date = s.end_date
FROM   s
WHERE  p.cmteproperties_sk = s.cmteproperties_sk;













