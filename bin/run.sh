# TODO: Install dependencies from PyPI once updated
pip install -U git+https://github.com/marshmallow-code/marshmallow-sqlalchemy@dev
pip install marshmallow==2.0.0b4
eval $(python webservices/setenv.py)
python manage.py cf_startup && \
    (pkill gunicorn || true) && \
    newrelic-admin run-program gunicorn webservices.rest:app --bind 127.0.0.1:8000 --daemon && \
    bash ./boot.sh
