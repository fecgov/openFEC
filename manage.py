#!/usr/bin/env python

import glob
import subprocess
import urllib.parse
import multiprocessing

from flask import url_for
from flask.ext.script import Manager

from webservices.rest import app, db
from webservices.common.util import get_full_path


manager = Manager(app)


@manager.command
def list_routes():
    output = []
    for rule in app.url_map.iter_rules():

        options = {}
        for arg in rule.arguments:
            options[arg] = "[{0}]".format(arg)

        methods = ','.join(rule.methods)
        url = url_for(rule.endpoint, **options)
        line = urllib.parse.unquote(
            '{:50s} {:20s} {}'.format(rule.endpoint, methods, url)
        )
        output.append(line)

    for line in sorted(output):
        print(line)


def execute_sql_file(path):
    print(('Running {}'.format(path)))
    with open(path) as fp:
        cmd = '\n'.join([
            line.replace('%', '%%') for line in fp.readlines()
            if not line.startswith('--')
        ])
        db.engine.execute(cmd)


@manager.command
def update_schemas(processes=2):
    """Delete and recreate all tables and views."""
    print('Starting DB refresh...')
    sql_dir = get_full_path('data/sql_updates/')
    files = glob.glob(sql_dir + 'create*.sql')

    pool = multiprocessing.Pool(processes=int(processes))
    pool.map(execute_sql_file, files)

    execute_sql_file('data/rename_temporary_views.sql')

    print('Finished DB refresh.')


@manager.command
def refresh_materialized():
    """Refresh materialized views."""
    print('Refreshing materialized views...')
    execute_sql_file('data/refresh_materialized_views.sql')
    print('Finished refreshing materialized views.')


@manager.command
def stop_beat():
    """Kill all celery beat workers.
    Note: In the future, it would be more elegant to use a process manager like
    supervisor or forever.
    """
    return subprocess.Popen(
        "ps aux | grep 'cron.py' | awk '{print $2}' | xargs kill -9",
        shell=True,
    )


@manager.command
def start_beat():
    """Start celery beat workers in the background using subprocess.
    """
    # Stop beat workers synchronously
    stop_beat().wait()
    return subprocess.Popen(['python', 'cron.py'])


if __name__ == "__main__":
    manager.run()
