import datetime
import pendulum

from functools import lru_cache

DEFAULT_TZ = pendulum.timezone('US/Eastern')


def normalize_datetime(doc, fields=None, tz=DEFAULT_TZ):
    '''
    If doc contains naive datetime objects, make them timezone aware
    '''
    if fields is not None:
        # better performance
        for k in fields:
            v = doc.get(k)
            if isinstance(v, datetime.datetime) and \
               (v.tzinfo is None or v.tzinfo.utcoffset(v) is None):
                    # naive datetime, use default timezone
                    doc[k] = convert_naive_datetime(v, tz)

    else:
        for k, v in doc.items():
            if isinstance(v, datetime.datetime) and \
               (v.tzinfo is None or v.tzinfo.utcoffset(v) is None):
                    # naive datetime, use default timezone
                    doc[k] = convert_naive_datetime(v, tz)


@lru_cache(maxsize=1024)
def convert_naive_datetime(dt, tz):
    return tz.convert(dt)


def normalize_boolean(doc, fields):
    '''
    convert int value to boolean
    '''
    for k in fields:
        doc[k] = int2bool(doc[k])


def int2bool(i):
    if i == 1 or i == b'\x01':
        return True
    elif i == 0 or i == b'\x00':
        return False
    return i
