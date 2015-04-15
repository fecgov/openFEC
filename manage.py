from webservices.common.util import get_full_path
from flask.ext.script import Manager
from flask import url_for

from webservices.rest import app, db
import glob
import urllib.parse
from sqlalchemy import text as sqla_text


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
        line = urllib.parse.unquote("{:50s} {:20s} {}".format(rule.endpoint, methods, url))
        output.append(line)

    for line in sorted(output):
        print(line)


@manager.command
def refresh_db():
    print("Starting DB refresh...")
    sql_dir = get_full_path('data/sql_updates/')
    files = glob.glob(sql_dir + '*.sql')

    for sql_file in files:
        print(("Running {}".format(sql_file)))
        with open(sql_file, 'r') as sql_fh:
            sql = '\n'.join(sql_fh.readlines())
            db.engine.execute(sqla_text(sql))

    print("Finished DB refresh.")


if __name__ == "__main__":
    manager.run()
