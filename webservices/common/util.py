from datetime import datetime
from flask.ext.restful import reqparse


def default_year():
    year = datetime.now().year
    years = [str(y) for y in range(year, year-4, -1)]
    return ','.join(years)

def natural_number(n):
    result = int(n)
    if result < 1:
        raise reqparse.ArgumentTypeError('Must be a number greater than or equal to 1')
    return result
