#!/usr/bin/env python

from flask import url_for
from flask.ext.script import Manager

import glob
import subprocess
import urllib.parse
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
    with open(path) as fp:
        db.engine.execute(fp.read().replace('%', '%%'))


@manager.command
def update_schemas():
    """Delete and recreate all tables and views."""
    print('Starting DB refresh...')
    sql_dir = get_full_path('data/sql_updates/')
    files = glob.glob(sql_dir + '*.sql')

    for sql_file in files:
        print(("Running {}".format(sql_file)))
        with open(sql_file, 'r') as sql_fh:
            sql = '\n'.join(sql_fh.readlines())
            db.engine.execute(sql)

    execute_sql_file('data/rename_temporary_views.sql')

    print('Finished DB refresh.')


@manager.command
def refresh_materialized():
    """Refresh materialized views."""
    print('Refreshing materialized views...')
    with open('data/refresh/refresh.sql') as fp:
        db.engine.execute(fp.read().replace('%', '%%'))
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
