python cli.py cf_startup
gunicorn --access-logfile - --error-logfile - --log-level info --timeout 300 -w 9 'webservices.rest:create_app()'
