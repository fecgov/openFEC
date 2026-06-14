python cli.py cf_startup
gunicorn -c gunicorn.conf.py 'webservices.rest:create_app()'
