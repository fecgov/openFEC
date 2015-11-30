python manage.py cf_startup && \
    (pkill gunicorn || true) && \
    gunicorn webservices.rest:app --bind 127.0.0.1:8000 --daemon && \
    bash ./boot.sh
