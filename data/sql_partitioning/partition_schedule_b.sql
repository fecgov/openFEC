-- Trigger for the Schedule B master table
create or replace function ofec_sched_b_master_trigger()
returns trigger as $$
begin
    case new.two_year_transaction_period
        when 1977, 1978 then
            insert into ofec_sched_b_1977_1978 values (new.*);
        when 1979, 1980 then
            insert into ofec_sched_b_1979_1980 values (new.*);
        when 1981, 1982 then
            insert into ofec_sched_b_1981_1982 values (new.*);
        when 1983, 1984 then
            insert into ofec_sched_b_1983_1984 values (new.*);
        when 1985, 1986 then
            insert into ofec_sched_b_1985_1986 values (new.*);
        when 1987, 1988 then
            insert into ofec_sched_b_1987_1988 values (new.*);
        when 1989, 1990 then
            insert into ofec_sched_b_1989_1990 values (new.*);
        when 1991, 1992 then
            insert into ofec_sched_b_1991_1992 values (new.*);
        when 1993, 1994 then
            insert into ofec_sched_b_1993_1994 values (new.*);
        when 1995, 1996 then
            insert into ofec_sched_b_1995_1996 values (new.*);
        when 1997, 1998 then
            insert into ofec_sched_b_1997_1998 values (new.*);
        when 1999, 2000 then
            insert into ofec_sched_b_1999_2000 values (new.*);
        when 2001, 2002 then
            insert into ofec_sched_b_2001_2002 values (new.*);
        when 2003, 2004 then
            insert into ofec_sched_b_2003_2004 values (new.*);
        when 2005, 2006 then
            insert into ofec_sched_b_2005_2006 values (new.*);
        when 2007, 2008 then
            insert into ofec_sched_b_2007_2008 values (new.*);
        when 2009, 2010 then
            insert into ofec_sched_b_2009_2010 values (new.*);
        when 2011, 2012 then
            insert into ofec_sched_b_2011_2012 values (new.*);
        when 2013, 2014 then
            insert into ofec_sched_b_2013_2014 values (new.*);
        when 2015, 2016 then
            insert into ofec_sched_b_2015_2016 values (new.*);
        when 2017, 2018 then
            insert into ofec_sched_b_2017_2018 values (new.*);
        else:
            -- Throw an exception if the cycle wasn't found - we do not want
            -- there to be silent errors/data loss.
            raise exception 'Cycle year % was not found; the ofec_sched_b_master_insert_trigger may need an update.', new.two_year_transaction_period;
    end case;

    return null;
end
$$ language plpgsql


-- Set the trigger
drop trigger if exists ofec_sched_b_insert_trigger on ofec_sched_b_master;
create trigger ofec_sched_b_insert_trigger before insert
    on ofec_sched_b_master for each row execute procedure ofec_sched_b_master_trigger();
