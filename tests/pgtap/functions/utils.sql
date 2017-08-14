\i ../../data/functions/utils.sql 

SELECT plan(6);   -- Number of tests

-- Run the tests.
SELECT is(get_cycle(input), expected,
          format('get_cycle(%s) == %s', input, expected))
FROM (VALUES
  (0, 0), (1, 2), (2, 2),
  (1998, 1998), (1999, 2000), (2000, 2000)
) as test_data (input, expected);
