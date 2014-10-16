from json import JSONEncoder
from datetime import datetime, timedelta
from decimal import Decimal

class TolerantJSONEncoder(JSONEncoder):
    """ 
    Converts a python object, where datetime and timedelta objects are converted
    into strings that can be decoded using the DateTimeAwareJSONDecoder.
    
    Thanks to Mark Hildreth
    http://taketwoprogramming.blogspot.com/2009/06/subclassing-jsonencoder-and-jsondecoder.html
    """
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        elif isinstance(obj, datetime):
            return str(obj)
        elif isinstance(obj, timedelta):
            days = obj.days
            seconds = obj.seconds
            milliseconds = obj.microseconds / 1000
            milliseconds += obj.seconds * 1000
            milliseconds += obj.days * 24 * 60 * 60 * 1000

            return 'td(%d)' % (milliseconds)
        else:
            return JSONEncoder.default(self, obj)

