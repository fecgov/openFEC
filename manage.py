#!/usr/bin/env python

import os
import glob
import subprocess
import urllib.parse
import multiprocessing

from flask import url_for
from flask.ext.script import Server
from flask.ext.script import Manager
from sqlalchemy import text as sqla_text

from webservices.rest import app, db
from webservices.common.util import get_full_path


manager = Manager(app)

# The Flask app server should only be used for local testing, so we default to
# using debug mode and auto-reload. To disable debug mode locally, pass the
# --no-debug flag to `runserver`.
manager.add_command('runserver', Server(use_debugger=True, use_reloader=True))


def execute_sql_file(path):
    print(('Running {}'.format(path)))
    with open(path) as fp:
        cmd = '\n'.join([
            line for line in fp.readlines()
            if not line.startswith('--')
        ])
        db.engine.execute(sqla_text(cmd))


def execute_sql_folder(path, processes):
    sql_dir = get_full_path(path)
    paths = glob.glob(sql_dir + '*.sql')
    pool = multiprocessing.Pool(processes=processes)
    pool.map(execute_sql_file, paths)


@manager.command
def update_schemas(processes=2):
    print("Starting DB refresh...")
    processes = int(processes)
    execute_sql_folder('data/sql_prep/', processes=processes)
    execute_sql_folder('data/sql_updates/', processes=processes)
    execute_sql_file('data/rename_temporary_views.sql')
    print("Finished DB refresh.")


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


@manager.command
def cf_startup():
    """Start celery beat and schema migration on `cf-push`. Services are only
    started if running on 0th instance.
    """
    instance_id = os.getenv('CF_INSTANCE_INDEX')
    if instance_id == '0':
        start_beat()
        subprocess.Popen(['python', 'manage.py', 'update_schemas'])


if __name__ == "__main__":
    manager.run()
