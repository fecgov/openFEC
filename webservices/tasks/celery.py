import ssl
from celery import Celery, Task
from flask import Flask
from webservices.tasks import schedule
from webservices.tasks.utils import redis_url


def celery_init_app(app: Flask) -> Celery:
    class FlaskTask(Task):
        def __call__(self, *args: object, **kwargs: object) -> object:
            with app.app_context():
                return self.run(*args, **kwargs)

    celery_app = Celery(app.name, task_cls=FlaskTask)  # app.name =openfec
    celery_app.config_from_object(app.config["CELERY"])
    celery_app.conf.update(
        broker_url=redis_url(),
       # broker_use_ssl={
       #     "ssl_cert_reqs": ssl.CERT_NONE,
       # },
       # redis_backend_use_ssl={
       #     "ssl_cert_reqs": ssl.CERT_NONE,
       # },
        imports=(
            "webservices.tasks.refresh_db",
            "webservices.tasks.download",
            "webservices.tasks.legal_docs",
            "webservices.tasks.service_status_checks",
            "webservices.tasks.run_schedule_a_query",
        ),
        beat_schedule=schedule,
        broker_connection_timeout=30,  # in seconds
        broker_connection_max_retries=None,  # for unlimited retries
        task_acks_late=False
    )
    celery_app.conf.ONCE = {
        "backend": "celery_once.backends.Redis",
        "settings": {
            "url": redis_url(),  # + "?ssl=true",
            "default_timeout": 60 * 60
        }

    }
    celery_app.set_default()
    app.extensions["celery"] = celery_app
    return celery_app
