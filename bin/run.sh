# invoke notify || echo 'failed to start slack'
python manage.py cf_startup
gunicorn -k gevent -w 2 webservices.rest:app
