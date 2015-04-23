drop materialized view if exists ofec_candidate_history_mv;
drop table if exists ofec_two_year_periods;
create table ofec_two_year_periods as
select year from dimyears
    -- only up to the current campaign cycle
    where (year <= EXTRACT(YEAR FROM now()) +1)
    and year % 2 = 0
;