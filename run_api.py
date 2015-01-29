import doctest
import os
import sys


from webservices.rest import app


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1].lower().startswith('test'):
        doctest.testmod()
    else:
        debug = not os.getenv('PRODUCTION')
        app.run(debug=debug)
