web: eval $(python webservices/setenv.py) && python manage.py cf_startup && newrelic-admin run-program gunicorn webservices.rest:app
