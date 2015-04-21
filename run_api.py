#!/usr/bin/env python

import ast
import os
import sys
import doctest
import subprocess

import manage
from webservices.rest import app


if __name__ == '__main__':

    port = os.getenv('VCAP_APP_PORT', '5000')
    instance_id = os.getenv('CF_INSTANCE_INDEX')

    # If running on Cloud Foundry and using 0th instance, start celery beat
    # worker and run schema update in subprocess
    if instance_id == '0':
        manage.start_beat()
        subprocess.Popen(['python', 'manage.py', 'update_schemas'])

    if len(sys.argv) > 1 and sys.argv[1].lower().startswith('test'):
        doctest.testmod()
    else:
        debug = not ast.literal_eval(os.getenv('PRODUCTION', False))
        app.run(debug=debug, port=int(port), host='0.0.0.0')
