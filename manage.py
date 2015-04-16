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


@manager.command
def refresh_db():
    print('Starting DB refresh...')
    sql_dir = get_full_path('data/sql_updates/')
    files = glob.glob(sql_dir + '*.sql')

    for sql_file in files:
        print(("Running {}".format(sql_file)))
        with open(sql_file, 'r') as sql_fh:
            sql = '\n'.join(sql_fh.readlines())
            db.engine.execute(sql)

    print('Finished DB refresh.')


@manager.command
def refresh_materialized():
    print('Refreshing materialized views...')
    with open('data/refresh/refresh.sql') as fp:
        db.engine.execute(fp.read().replace('%', '%%'))
    print('Finished refreshing materialized views.')


@manager.command
def start_beat():
    subprocess.Popen(['python', 'cron.py'])


@manager.command
def stop_beat():
    """See http://celery.readthedocs.org/en/latest/userguide/workers.html#stopping-the-worker"""
    subprocess.Popen(
        "ps aux | grep 'cron.py' | awk '{print $2}' | xargs kill -9",
        shell=True,
    )


if __name__ == "__main__":
    manager.run()
