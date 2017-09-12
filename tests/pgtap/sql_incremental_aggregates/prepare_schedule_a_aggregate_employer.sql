CREATE OR REPLACE FUNCTION test_functions.setup_mock_fec_fitem_sched_a_vw() RETURNS void AS $$
BEGIN
    DROP VIEW IF EXISTS fec_fitem_sched_a_vw;
    CREATE TABLE fec_fitem_sched_a_vw (
        -- We only define the columns necessary for our table
        cmte_id character varying(100),   -- longer than the original for labeling
        rpt_yr numeric(4,0),
        contbr_employer character varying(38),
        contb_receipt_amt numeric(14,2),
        receipt_tp character varying(3),
        line_num character varying(12),
        memo_cd character varying(1),
        memo_text character varying(100),
        contbr_id character varying(9)
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_functions.setup_mock_is_individual() RETURNS void AS $outer$
BEGIN
    CREATE OR REPLACE FUNCTION is_individual(
        amount NUMERIC, receipt_type TEXT, line_number TEXT, memo_code TEXT, memo_text TEXT, contbr_id TEXT, cmte_id TEXT
    ) RETURNS BOOLEAN AS $$
        BEGIN
          RETURN memo_text = 'individual';
        END;
    $$ LANGUAGE plpgsql;
END;
$outer$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION test_functions.starts_empty() RETURNS SETOF TEXT AS $$
BEGIN
  PERFORM prepare_schedule_a_aggregate_employer(1987);

  RETURN NEXT is_empty('SELECT * FROM ofec_sched_a_aggregate_employer', 'Initially empty');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test_functions.groups_correctly() RETURNS SETOF TEXT AS $outer$
BEGIN
  INSERT INTO fec_fitem_sched_a_vw VALUES
      ('id-1', 1990, 'emp-a', 0, '_', '_', '_', 'individual', '_'),
      ('id-1', 1990, 'emp-a', 0, '_', '_', '_', 'individual', '_'),
      ('id-1', 1991, 'emp-a', 0, '_', '_', '_', 'individual', '_'),
      ('id-1', 1992, 'emp-a', 0, '_', '_', '_', 'individual', '_'),
      ('id-2', 1992, 'emp-a', 0, '_', '_', '_', 'individual', '_'),
      ('id-2', 1992, 'emp-b', 0, '_', '_', '_', 'individual', '_');
  PERFORM prepare_schedule_a_aggregate_employer(1987);

  RETURN NEXT set_eq(
      'SELECT cmte_id, cycle, employer FROM ofec_sched_a_aggregate_employer',
      $$ VALUES
        ('id-1', 1990, 'emp-a'),
        ('id-1', 1992, 'emp-a'),
        ('id-2', 1992, 'emp-a'),
        ('id-2', 1992, 'emp-b')
      $$);

END;
$outer$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION test_functions.filters_bad_vals() RETURNS SETOF TEXT AS $outer$
BEGIN
  INSERT INTO fec_fitem_sched_a_vw VALUES
      ('all good', 1990, '_', 0, '_', '_', '_', 'individual', '_'),
      ('year too early', 1900, '_', 0, '_', '_', '_', 'individual', '_'),
      ('null amount', 1990, '_', NULL, '_', '_', '_', 'individual', '_'),
      ('not an individual', 1990, '_', 0, '_', '_', '_', 'non-individual', '_');
  PERFORM prepare_schedule_a_aggregate_employer(1987);

  RETURN NEXT results_eq(
      'SELECT cmte_id::text FROM ofec_sched_a_aggregate_employer',
      ARRAY['all good']);

  -- Everything is now too early
  PERFORM prepare_schedule_a_aggregate_employer(2000);
  RETURN NEXT is_empty('SELECT * FROM ofec_sched_a_aggregate_employer');
END;
$outer$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION test_functions.aggregates_correctly() RETURNS SETOF TEXT AS $outer$
BEGIN
  INSERT INTO fec_fitem_sched_a_vw VALUES
      ('id-1', 1990, '_', 1.1, '_', '_', '_', 'individual', '_'),
      ('id-1', 1990, '_', 2.2, '_', '_', '_', 'individual', '_'),
      ('id-1', 1990, '_', 2.2, '_', '_', '_', 'individual', '_'),
      ('id-2', 1990, '_', 3.3, '_', '_', '_', 'individual', '_');
  PERFORM prepare_schedule_a_aggregate_employer(1987);

  RETURN NEXT set_eq(
      'SELECT total, count FROM ofec_sched_a_aggregate_employer',
      $$ VALUES (5.5, 3), (3.3, 1) $$);
END;
$outer$ LANGUAGE plpgsql;
