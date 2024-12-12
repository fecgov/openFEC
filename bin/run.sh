python cli.py cf_startup
gunicorn --access-logfile - --error-logfile - --log-level info --timeout 300 -k gthread --threads 4 -w 9 webservices.rest:app
