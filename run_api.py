import os
import sys
import doctest
import subprocess

from webservices.rest import app


if __name__ == '__main__':

    port = os.getenv('VCAP_APP_PORT', '5000')
    instance_id = os.getenv('CF_INSTANCE_INDEX')

    # Run database migration in separate process to avoid Cloud Foundry timeout
    # Note: Only run if first application process
    if instance_id == '0':
        subprocess.Popen(['python', 'manage.py', 'refresh_db'])

    if len(sys.argv) > 1 and sys.argv[1].lower().startswith('test'):
        doctest.testmod()
    else:
        debug = not os.getenv('PRODUCTION')
        app.run(debug=debug, port=int(port), host='0.0.0.0')
