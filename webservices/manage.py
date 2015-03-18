from common.util import get_full_path
from flask.ext.script import Manager
from flask import url_for

from rest import app
import glob

manager = Manager(app)

@manager.command
def list_routes():
    import urllib
    output = []
    for rule in app.url_map.iter_rules():

        options = {}
        for arg in rule.arguments:
            options[arg] = "[{0}]".format(arg)

        methods = ','.join(rule.methods)
        url = url_for(rule.endpoint, **options)
        line = urllib.unquote("{:50s} {:20s} {}".format(rule.endpoint, methods, url))
        output.append(line)

    for line in sorted(output):
        print line


@manager.command
def refresh_db():
    sql_dir = get_full_path('data/sql_updates/')
    files = glob.glob(sql_dir + '*.sql')

    for sql_file in files:
        with open(sql_file, 'r') as sql_fh:
            sql = '\n'.join(sql_fh.readlines())
            db.engine.execute(sql)


if __name__ == "__main__":
    manager.run()
