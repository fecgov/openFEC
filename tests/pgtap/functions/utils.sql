CREATE OR REPLACE FUNCTION test_functions.get_cycle(
) RETURNS SETOF TEXT AS $$
BEGIN
  RETURN NEXT is(get_cycle(0), 0, 'get_cycle(0) == 0');
  RETURN NEXT is(get_cycle(1), 2, 'get_cycle(1) == 2');
  RETURN NEXT is(get_cycle(2), 2, 'get_cycle(2) == 2');
  RETURN NEXT is(get_cycle(1998), 1998, 'get_cycle(1998) == 1998');
  RETURN NEXT is(get_cycle(1999), 2000, 'get_cycle(1999) == 2000');
  RETURN NEXT is(get_cycle(2000), 2000, 'get_cycle(2000) == 2000');
END;
$$ LANGUAGE plpgsql;
