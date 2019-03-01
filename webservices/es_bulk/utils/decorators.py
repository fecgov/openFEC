from functools import wraps
from time import time
import pickle
import logging

from .common import print_json

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


def sampling(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        res = func(*args, **kwargs)
        if not res or len(res) == 0:
            LOGGER.warning('The result did not return any row')
        else:
            LOGGER.info('The resulting data set has {} rows'.format(len(res)))
            if isinstance(res, dict):
                for k, v in res.items():
                    LOGGER.info('The first row is ---- ' + '\n')
                    LOGGER.info('\t' + 'The  key is ' + str(k))
                    LOGGER.info('\t' + 'The  value is below' + '\n')
                    LOGGER.info(print_json(v))
                    break
            elif isinstance(res, list):
                current = res[0]
                LOGGER.info(print_json(current))
            LOGGER.info('*' * 60 + '\n\n')
        return res
    return wrapper


def serializing(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        res = func(*args, **kwargs)
        with open('{}.pickle'.format(func.__name__), 'wb') as handle:
            pickle.dump(res, handle)
            LOGGER.info('{} has been serialized.'.format(func.__name__))
        return res
    return wrapper



