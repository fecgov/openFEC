-- Run against test dataset to obscure donor data:
--   - Replace all digits in addresses with 9
--   - Replace last names with a different randomly selected last name 
--     from the dataset

CREATE LANGUAGE plpython3u;

DROP FUNCTION swap_words (name1 TEXT, name2 TEXT, word_index INTEGER);
CREATE FUNCTION swap_words (name1 TEXT, name2 TEXT, word_index INTEGER)
RETURNS TEXT
AS $$
    words1 = name1.split()
    words2 = name2.split()
    try:
        words1[word_index] = words2[word_index] 
    except IndexError:
        return name1 
    return ' '.join(words1)
$$ LANGUAGE plpython3u;

UPDATE sched_a 
SET    contbr_st1 = regexp_replace(contbr_st1, '\d', '9', 'g'),
       contbr_st2 = regexp_replace(contbr_st2, '\d', '9', 'g'),
       contbr_zip = regexp_replace(contbr_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   sched_a_sk,
             contbr_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM sched_a WHERE contbr_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   sched_a_sk,
             contbr_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM sched_a WHERE contbr_nm IS NOT NULL) s )
  SELECT t1.sched_a_sk,
         t1.contbr_nm AS name1,
         t2.contbr_nm AS name2,
         swap_words(t1.contbr_nm, t2.contbr_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE sched_a a
SET    contbr_nm = r.name3
FROM   random_swapper r
WHERE  r.sched_a_sk = a.sched_a_sk;

UPDATE sched_c 
SET    loan_src_st1 = regexp_replace(loan_src_st1, '\d', '9', 'g'),
       loan_src_st2 = regexp_replace(loan_src_st2, '\d', '9', 'g'),
       loan_src_zip = regexp_replace(loan_src_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   sched_c_sk,
             loan_src_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM sched_c WHERE loan_src_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   sched_c_sk,
             loan_src_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM sched_c WHERE loan_src_nm IS NOT NULL) s )
  SELECT t1.sched_c_sk,
         t1.loan_src_nm AS name1,
         t2.loan_src_nm AS name2,
         swap_words(t1.loan_src_nm, t2.loan_src_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE sched_c a
SET    loan_src_nm = r.name3
FROM   random_swapper r
WHERE  r.sched_c_sk = a.sched_c_sk;

UPDATE sched_c1 
SET    loan_src_st1 = regexp_replace(loan_src_st1, '\d', '9', 'g'),
       loan_src_st2 = regexp_replace(loan_src_st2, '\d', '9', 'g'),
       loan_src_zip = regexp_replace(loan_src_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   sched_c1_sk,
             loan_src_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM sched_c1 WHERE loan_src_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   sched_c1_sk,
             loan_src_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM sched_c1 WHERE loan_src_nm IS NOT NULL) s )
  SELECT t1.sched_c1_sk,
         t1.loan_src_nm AS name1,
         t2.loan_src_nm AS name2,
         swap_words(t1.loan_src_nm, t2.loan_src_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE sched_c1 a
SET    loan_src_nm = r.name3
FROM   random_swapper r
WHERE  r.sched_c1_sk = a.sched_c1_sk;

UPDATE sched_c2 
SET    guar_endr_st1 = regexp_replace(guar_endr_st1, '\d', '9', 'g'),
       guar_endr_st2 = regexp_replace(guar_endr_st2, '\d', '9', 'g'),
       guar_endr_zip = regexp_replace(guar_endr_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   sched_c2_sk,
             guar_endr_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM sched_c2 WHERE guar_endr_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   sched_c2_sk,
             guar_endr_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM sched_c2 WHERE guar_endr_nm IS NOT NULL) s )
  SELECT t1.sched_c2_sk,
         t1.guar_endr_nm AS name1,
         t2.guar_endr_nm AS name2,
         swap_words(t1.guar_endr_nm, t2.guar_endr_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE sched_c2 a
SET    guar_endr_nm = r.name3
FROM   random_swapper r
WHERE  r.sched_c2_sk = a.sched_c2_sk;
 
UPDATE sched_d 
SET    cred_dbtr_st1 = regexp_replace(cred_dbtr_st1, '\d', '9', 'g'),
       cred_dbtr_st2 = regexp_replace(cred_dbtr_st2, '\d', '9', 'g'),
       cred_dbtr_zip = regexp_replace(cred_dbtr_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   sched_d_sk,
             cred_dbtr_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM sched_d WHERE cred_dbtr_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   sched_d_sk,
             cred_dbtr_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM sched_d WHERE cred_dbtr_nm IS NOT NULL) s )
  SELECT t1.sched_d_sk,
         t1.cred_dbtr_nm AS name1,
         t2.cred_dbtr_nm AS name2,
         swap_words(t1.cred_dbtr_nm, t2.cred_dbtr_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE sched_d a
SET    cred_dbtr_nm = r.name3
FROM   random_swapper r
WHERE  r.sched_d_sk = a.sched_d_sk;
   
UPDATE sched_e 
SET    pye_st1 = regexp_replace(pye_st1, '\d', '9', 'g'),
       pye_st2 = regexp_replace(pye_st2, '\d', '9', 'g'),
       pye_zip = regexp_replace(pye_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   sched_e_sk,
             pye_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM sched_e WHERE pye_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   sched_e_sk,
             pye_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM sched_e WHERE pye_nm IS NOT NULL) s )
  SELECT t1.sched_e_sk,
         t1.pye_nm AS name1,
         t2.pye_nm AS name2,
         swap_words(t1.pye_nm, t2.pye_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE sched_e a
SET    pye_nm = r.name3
FROM   random_swapper r
WHERE  r.sched_e_sk = a.sched_e_sk;

UPDATE sched_f 
SET    pye_st1 = regexp_replace(pye_st1, '\d', '9', 'g'),
       pye_st2 = regexp_replace(pye_st2, '\d', '9', 'g'),
       pye_zip = regexp_replace(pye_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   sched_f_sk,
             pye_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM sched_f WHERE pye_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   sched_f_sk,
             pye_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM sched_f WHERE pye_nm IS NOT NULL) s )
  SELECT t1.sched_f_sk,
         t1.pye_nm AS name1,
         t2.pye_nm AS name2,
         swap_words(t1.pye_nm, t2.pye_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE sched_f a
SET    pye_nm = r.name3
FROM   random_swapper r
WHERE  r.sched_f_sk = a.sched_f_sk;

UPDATE sched_h4 
SET    pye_st1 = regexp_replace(pye_st1, '\d', '9', 'g'),
       pye_st2 = regexp_replace(pye_st2, '\d', '9', 'g'),
       pye_zip = regexp_replace(pye_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   sched_h4_sk,
             pye_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM sched_h4 WHERE pye_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   sched_h4_sk,
             pye_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM sched_h4 WHERE pye_nm IS NOT NULL) s )
  SELECT t1.sched_h4_sk,
         t1.pye_nm AS name1,
         t2.pye_nm AS name2,
         swap_words(t1.pye_nm, t2.pye_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE sched_h4 a
SET    pye_nm = r.name3
FROM   random_swapper r
WHERE  r.sched_h4_sk = a.sched_h4_sk;

UPDATE sched_h6 
SET    pye_st1 = regexp_replace(pye_st1, '\d', '9', 'g'),
       pye_st2 = regexp_replace(pye_st2, '\d', '9', 'g'),
       pye_zip = regexp_replace(pye_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   sched_h6_sk,
             pye_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM sched_h6 WHERE pye_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   sched_h6_sk,
             pye_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM sched_h6 WHERE pye_nm IS NOT NULL) s )
  SELECT t1.sched_h6_sk,
         t1.pye_nm AS name1,
         t2.pye_nm AS name2,
         swap_words(t1.pye_nm, t2.pye_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE sched_h6 a
SET    pye_nm = r.name3
FROM   random_swapper r
WHERE  r.sched_h6_sk = a.sched_h6_sk;


UPDATE form_56 
SET    contbr_st1 = regexp_replace(contbr_st1, '\d', '9', 'g'),
       contbr_st2 = regexp_replace(contbr_st2, '\d', '9', 'g'),
       contbr_zip = regexp_replace(contbr_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   form_56_sk,
             contbr_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM form_56 WHERE contbr_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   form_56_sk,
             contbr_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM form_56 WHERE contbr_nm IS NOT NULL) s )
  SELECT t1.form_56_sk,
         t1.contbr_nm AS name1,
         t2.contbr_nm AS name2,
         swap_words(t1.contbr_nm, t2.contbr_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE form_56 a
SET    contbr_nm = r.name3
FROM   random_swapper r
WHERE  r.form_56_sk = a.form_56_sk;
  
UPDATE form_57 
SET    pye_st1 = regexp_replace(pye_st1, '\d', '9', 'g'),
       pye_st2 = regexp_replace(pye_st2, '\d', '9', 'g'),
       pye_zip = regexp_replace(pye_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   form_57_sk,
             pye_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM form_57 WHERE pye_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   form_57_sk,
             pye_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM form_57 WHERE pye_nm IS NOT NULL) s )
  SELECT t1.form_57_sk,
         t1.pye_nm AS name1,
         t2.pye_nm AS name2,
         swap_words(t1.pye_nm, t2.pye_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE form_57 a
SET    pye_nm = r.name3
FROM   random_swapper r
WHERE  r.form_57_sk = a.form_57_sk;
  
UPDATE form_65 
SET    contbr_lender_st1 = regexp_replace(contbr_lender_st1, '\d', '9', 'g'),
       contbr_lender_st2 = regexp_replace(contbr_lender_st2, '\d', '9', 'g'),
       contbr_lender_zip = regexp_replace(contbr_lender_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   form_65_sk,
             contbr_lender_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM form_65 WHERE contbr_lender_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   form_65_sk,
             contbr_lender_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM form_65 WHERE contbr_lender_nm IS NOT NULL) s )
  SELECT t1.form_65_sk,
         t1.contbr_lender_nm AS name1,
         t2.contbr_lender_nm AS name2,
         swap_words(t1.contbr_lender_nm, t2.contbr_lender_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE form_65 a
SET    contbr_lender_nm = r.name3
FROM   random_swapper r
WHERE  r.form_65_sk = a.form_65_sk;
  
UPDATE form_82 
SET    cred_st1 = regexp_replace(cred_st1, '\d', '9', 'g'),
       cred_st2 = regexp_replace(cred_st2, '\d', '9', 'g'),
       cred_zip = regexp_replace(cred_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   form_82_sk,
             cred_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM form_82 WHERE cred_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   form_82_sk,
             cred_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM form_82 WHERE cred_nm IS NOT NULL) s )
  SELECT t1.form_82_sk,
         t1.cred_nm AS name1,
         t2.cred_nm AS name2,
         swap_words(t1.cred_nm, t2.cred_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE form_82 a
SET    cred_nm = r.name3
FROM   random_swapper r
WHERE  r.form_82_sk = a.form_82_sk;
  
UPDATE form_83 
SET    cred_st1 = regexp_replace(cred_st1, '\d', '9', 'g'),
       cred_st2 = regexp_replace(cred_st2, '\d', '9', 'g'),
       cred_zip = regexp_replace(cred_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   form_83_sk,
             cred_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM form_83 WHERE cred_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   form_83_sk,
             cred_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM form_83 WHERE cred_nm IS NOT NULL) s )
  SELECT t1.form_83_sk,
         t1.cred_nm AS name1,
         t2.cred_nm AS name2,
         swap_words(t1.cred_nm, t2.cred_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE form_83 a
SET    cred_nm = r.name3
FROM   random_swapper r
WHERE  r.form_83_sk = a.form_83_sk;
 
UPDATE form_91 
SET    shr_ex_ctl_street1 = regexp_replace(shr_ex_ctl_street1, '\d', '9', 'g'),
       shr_ex_ctl_street2 = regexp_replace(shr_ex_ctl_street2, '\d', '9', 'g'),
       shr_ex_ctl_zip = regexp_replace(shr_ex_ctl_zip, '\d', '9', 'g');

WITH random_swapper AS (
  WITH t1 AS (
    SELECT   form_91_sk,
             shr_ex_ctl_ind_nm, 
             row_number() over () rn
    FROM     (SELECT * FROM form_91 WHERE shr_ex_ctl_ind_nm IS NOT NULL) s ),
  t2 AS (
    SELECT   form_91_sk,
             shr_ex_ctl_ind_nm,
             row_number() over (ORDER BY random()) rn
    FROM     (SELECT * FROM form_91 WHERE shr_ex_ctl_ind_nm IS NOT NULL) s )
  SELECT t1.form_91_sk,
         t1.shr_ex_ctl_ind_nm AS name1,
         t2.shr_ex_ctl_ind_nm AS name2,
         swap_words(t1.shr_ex_ctl_ind_nm, t2.shr_ex_ctl_ind_nm, 1) AS name3
  FROM   t1 
  JOIN   t2 ON (t1.rn = t2.rn)
)   
UPDATE form_91 a
SET    shr_ex_ctl_ind_nm = r.name3
FROM   random_swapper r
WHERE  r.form_91_sk = a.form_91_sk;
 