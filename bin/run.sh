invoke notify || echo 'failed to start slack'
python manage.py cf_startup
gunicorn webservices.rest:app
