from functools import wraps
from time import time
import logging

LOGGER = logging.getLogger(__name__)


def timing(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        LOGGER.info(
            '*' * 10 + 'STEP {} starts to work'.format(func.__name__) + '*' * 10 + '\n')  # be compatible to Python2
        ts = time()
        res = func(*args, **kwargs)
        te = time()
        LOGGER.info('STEP {} took {} seconds'.format(func.__name__, round(te - ts, 2)) + '\n')
        return res
    return wrapper


def print_query(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        res = func(*args, **kwargs)
        # for k,v in kwargs:
        #     LOGGER.info(k,v)
        LOGGER.info(res)
        return res
    return wrapper






