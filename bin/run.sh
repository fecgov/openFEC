# invoke notify
python manage.py cf_startup
gunicorn webservices.rest:app
