python cli.py cf_startup
gunicorn --access-logfile - --error-logfile - --log-level info --timeout 300 -k gthread --threads 9 -w 9 webservices.rest:app
