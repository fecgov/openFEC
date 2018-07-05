BEGIN;
SELECT plan(7);

-- Run the tests.
SELECT is_empty('SELECT * FROM efiling_amendment_chain_vw', 'No data in real_efile.reps');

INSERT INTO real_efile.reps
    (repid, comid, previd)
VALUES
    (1, 'COMID1', NULL)
;

SELECT results_eq('SELECT * FROM efiling_amendment_chain_vw',
    $$VALUES (1::numeric, 'COMID1'::varchar, NULL::numeric,  ARRAY[1::numeric], 1, 1::numeric, 1::numeric, ARRAY[1::numeric]) $$,
    'Trivial test'
);

INSERT INTO real_efile.reps
    (repid, comid, previd)
VALUES
    (2, 'COMID2', 1)
;

SELECT results_eq('SELECT * FROM efiling_amendment_chain_vw',
    $$VALUES
        (1::numeric, 'COMID1'::varchar, NULL::numeric,  ARRAY[1::numeric], 1, 1::numeric, 2::numeric, ARRAY[1::numeric, 2::numeric]),
        (2::numeric, 'COMID2'::varchar, 1::numeric,  ARRAY[1::numeric, 2::numeric], 2, 1::numeric, 2::numeric, ARRAY[1::numeric, 2::numeric])
    $$,
    'Test single amendment'
);

INSERT INTO real_efile.reps
    (repid, comid, previd)
VALUES
    (3, 'COMID3', 2)
;

SELECT results_eq('SELECT * FROM efiling_amendment_chain_vw',
    $$VALUES
        (1::numeric, 'COMID1'::varchar, NULL::numeric,  ARRAY[1::numeric], 1, 1::numeric, 3::numeric, ARRAY[1::numeric, 2::numeric, 3::numeric]),
        (2::numeric, 'COMID2'::varchar, 1::numeric,  ARRAY[1::numeric, 2::numeric], 2, 1::numeric, 3::numeric, ARRAY[1::numeric, 2::numeric, 3::numeric]),
        (3::numeric, 'COMID3'::varchar, 2::numeric,  ARRAY[1::numeric, 2::numeric, 3::numeric], 3, 1::numeric, 3::numeric, ARRAY[1::numeric, 2::numeric, 3::numeric])
    $$,
    'Test amendment chain'
);

SELECT results_eq('SELECT DISTINCT last FROM efiling_amendment_chain_vw',
    $$VALUES (1::numeric) $$,
    'last should be the same for all the rows in an amendment chain');

SELECT results_eq('SELECT DISTINCT most_recent_filing FROM efiling_amendment_chain_vw',
    $$VALUES (3::numeric) $$,
    'most_recent_filing should be the same for all the rows in an amendment chain');

SELECT results_eq('SELECT DISTINCT longest_chain FROM efiling_amendment_chain_vw',
    $$VALUES (ARRAY[1::numeric, 2::numeric, 3::numeric]) $$,
    'longest_chain should be the same for all the rows in an amendment chain');

SELECT * FROM finish();
ROLLBACK;
