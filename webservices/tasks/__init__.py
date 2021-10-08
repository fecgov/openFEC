import celery
from celery import signals
from celery.schedules import crontab

from webservices.env import env
from webservices.tasks import utils
import ssl

# Feature and dev are sharing the same RDS box so we only want dev to update
schedule = {}
if env.app.get("space_name", "unknown-space").lower() != "feature":
    schedule = {
        # Task 1: This task is launched every 5 minutes during 6am-7pm(EST).
        # When found any modified AO within 8 hours, reload all AOs.
        # When found modified case(s)(MUR/AF/ADR) within 8 hours, reload/delete the modified case(s).
        "refresh_legal_docs": {
            "task": "webservices.tasks.legal_docs.refresh_most_recent_legal_doc",
            "schedule": crontab(minute="*/5", hour="10-23"),
        },
        # Task 2: This task is launched at 9pm(EST) everyday except Sunday.
        # When found any modified AO in past 24 hours, reload all AOs.
        "reload_all_aos_daily_except_sunday": {
            "task": "webservices.tasks.legal_docs.daily_reload_all_aos_when_change",
            "schedule": crontab(minute=0, hour=1, day_of_week="mon,tue,wed,thu,fri,sat"),
        },
        # Task 3: This task is launched at 9pm(EST) only on Sunday.
        # Reload all AOs.
        "reload_all_aos_every_sunday": {
            "task": "webservices.tasks.legal_docs.weekly_reload_all_aos",
            "schedule": crontab(minute=0, hour=1, day_of_week="sun"),
        },
        # Task 4: This task is launched at 6pm(EST) everyday.
        # When found modified AO(s) in past 24 hours, send AO detail information to Slack.
        "send_alert_ao": {
            "task": "webservices.tasks.legal_docs.send_alert_daily_modified_ao",
            "schedule": crontab(minute=0, hour=22),
        },
        # Task 5: This task is launched at 7pm(EST) everyday.
        # When found modified case(s)(MUR/AF/ADR) during 6am-7pm(EST), send case detail information to Slack.
        "send_alert_legal_case": {
            "task": "webservices.tasks.legal_docs.send_alert_daily_modified_legal_case",
            "schedule": crontab(minute=0, hour=23),
        },
        # Task 6: This task is launched at 12am(EST) only on Sunday.
        # Take Elasticsearch 'docs' index snapshot.
        "backup_elasticsearch_every_sunday": {
            "task": "webservices.tasks.legal_docs.create_es_backup",
            "schedule": crontab(minute=0, hour=4, day_of_week="sun"),
        },
        # Task 7: This task is launched at 5am(EST) everyday.
        # Refresh public materialized views.
        "refresh_materialized_views": {
            "task": "webservices.tasks.refresh_db.refresh_materialized_views",
            "schedule": crontab(minute=0, hour=9),
        },
    }


def redis_url():
    """
    Retrieve the URL needed to connect to a Redis instance, depending on environment.
    When running in a cloud.gov environment, retrieve the uri credential for the 'aws-elasticache-redis' service.
    """

    # Is the app running in a cloud.gov environment
    if env.space is not None:
        redis_env = env.get_service(label="aws-elasticache-redis")
        redis_url = redis_env.credentials.get("uri")

        return redis_url

    return env.get_credential("FEC_REDIS_URL", "redis://localhost:6379/0")


app = celery.Celery("openfec")
app.conf.update(
    broker_url=redis_url(),
    broker_use_ssl={
        "ssl_cert_reqs": ssl.CERT_NONE,
    },
    redis_backend_use_ssl={
        "ssl_cert_reqs": ssl.CERT_NONE,
    },
    imports=(
        "webservices.tasks.refresh_db",
        "webservices.tasks.download",
        "webservices.tasks.legal_docs",
    ),
    beat_schedule=schedule,
    broker_connection_timeout=30,  # in seconds
    broker_connection_max_retries=0,  # for unlimited retries
    task_acks_late=False
)

app.conf.ONCE = {
    "backend": "celery_once.backends.Redis",
    "settings": {
        "url": redis_url() + "?ssl=true",
        "default_timeout": 60 * 60
    }
}

context = {}


@signals.task_prerun.connect
def push_context(task_id, task, *args, **kwargs):
    context[task_id] = utils.get_app().app_context()
    context[task_id].push()


@signals.task_postrun.connect
def pop_context(task_id, task, *args, **kwargs):
    if task_id in context:
        context[task_id].pop()
        context.pop(task_id)
