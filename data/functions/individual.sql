create or replace function is_individual(amount numeric, receipt_type text, line_number text, memo_code text, memo_text text) returns bool as $$
begin
    return (
        is_coded_individual(receipt_type) or
        is_inferred_individual(amount, line_number, memo_code, memo_text)
    );
end
$$ language plpgsql immutable;


-- checks line numbers to determine if a transactions is from an individual
create or replace function is_coded_individual(receipt_type text) returns bool as $$
begin
    return coalesce(receipt_type, '') in ('10', '15', '15E', '15J', '30', '30T', '31', '31T', '32');
end
$$ language plpgsql immutable;


-- looking for individual donations by line number, or if it is under $200 looking at memo text and memo code in is_earmark()
create or replace function is_inferred_individual(amount numeric, line_number text, memo_code text, memo_text text) returns bool as $$
begin
    return (
        amount < 200 and
        coalesce(line_number, '') in ('11AI', '12', '17', '17A', '18') and
        not is_earmark(memo_code, memo_text)
    );
end
$$ language plpgsql immutable;


-- tests if a small transaction is an earmark, these are then excluded in is_inferred_individual()
create or replace function is_earmark(memo_code text, memo_text text) returns bool as $$
begin
  return (
      coalesce(memo_code, '') = 'X' and
      coalesce(memo_text, '') ~* 'earmark|earmk|ermk'
  );
end
$$ language plpgsql immutable;


-- unitemized contributions should not be included in the state breakdowns
create or replace function is_unitemized(memo_text text)
    returns bool as $$
begin
  return (coalesce(memo_text, '') ~* 'UNITEM');
end
$$ language plpgsql immutable;


