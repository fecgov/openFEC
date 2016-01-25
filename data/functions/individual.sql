create or replace function is_individual(amount numeric, receipt_type text, line_number text, memo_code text, memo_text text) returns bool as $$
begin
    return (
        is_coded_individual(receipt_type) or
        is_inferred_individual(amount, line_number, memo_code, memo_text)
    );
end
$$ language plpgsql immutable;


create or replace function is_coded_individual(receipt_type text) returns bool as $$
begin
    return coalesce(receipt_type, '') in ('10', '15', '15E', '15J', '18J', '30', '30T', '31', '31T', '32');
end
$$ language plpgsql immutable;


create or replace function is_inferred_individual(amount numeric, line_number text, memo_code text, memo_text text) returns bool as $$
begin
    return (
        amount < 200 and
        coalesce(line_number, '') in ('11AI', '12', '17', '17A', '18') and
        not is_earmark(memo_code, memo_text)
    );
end
$$ language plpgsql immutable;


create or replace function is_earmark(memo_code text, memo_text text) returns bool as $$
begin
  return (
      coalesce(memo_code, '') = 'X' or
      coalesce(memo_text, '') ~* 'earmark|earmk|ermk'
  );
end
$$ language plpgsql immutable;
