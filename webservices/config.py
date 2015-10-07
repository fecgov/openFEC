def get_cycle_start(year):
    """Round year down to the first year of the two-year election cycle. Used
    when filtering original data for election cycle.
    """
    return year if year % 2 == 1 else year - 1


SQL_CONFIG = {
    'START_YEAR': get_cycle_start(1980),
    'START_YEAR_AGGREGATE': get_cycle_start(2008),
    'START_YEAR_ITEMIZED': get_cycle_start(2012),
}
