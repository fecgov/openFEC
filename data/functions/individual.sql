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
    return receipt_type is not null and receipt_type in ('10', '15', '15E', '15J', '18J');
end
$$ language plpgsql immutable;


create or replace function is_inferred_individual(amount numeric, line_number text, memo_code text, memo_text text) returns bool as $$
begin
    return (
        amount is not null and amount < 200 and
        line_number is not null and line_number in ('11AI', '12', '17', '17A', '18') and
        not is_earmark(memo_code, memo_text)
    );
end
$$ language plpgsql immutable;


create or replace function is_earmark(memo_code text, memo_text text) returns bool as $$
begin
  return (
      memo_code is not null and memo_code = 'X' and
      memo_text is not null and memo_text ~* 'earmark|earmk|ermk'
  );
end
$$ language plpgsql immutable;
