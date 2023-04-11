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
        # Task 1: This task is launched every 5 minutes during 10am-23:55pm UTC (6am-7:55pm EST)
        # (13 hours + 55 minutes).
        # Task 1A: refresh_most_recent_aos(conn):
        # 1) Identify the most recently modified AO(s) within 10 hours and 5 minutes
        # 2) For each modified AO, find the earliest AO referenced by the modified AO
        # 3) Reload all AO(s) starting from the referenced AO to the latest AO.

        # Task 1B: refresh_most_recent_cases(conn):
        # When found modified case(s)(MUR/AF/ADR) within 10 hours and 5 minutes,
        #   if published_flg = true, reload the case(s) on elasticsearch service.
        #   if published_flg = false, delete the case(s) on elasticsearch service.
        "refresh_legal_docs": {
            "task": "webservices.tasks.legal_docs.refresh_most_recent_legal_doc",
            "schedule": crontab(minute="*/5", hour="10-23"),
        },
        # Task 2: This task is launched at 9pm(EST) everyday except Sunday.
        # 1) Identify the daily modified AO(s) in past 24 hours(9pm-9pm EST)
        # 2) For each modified AO, find the earliest AO referenced by the modified AO
        # 3) Reload all AO(s) starting from the referenced AO to the latest AO
        # 4) Send AO detail information to Slack.
        "reload_all_aos_daily_except_sunday": {
            "task": "webservices.tasks.legal_docs.daily_reload_all_aos_when_change",
            "schedule": crontab(minute=0, hour=1, day_of_week="mon,tue,wed,thu,fri,sat"),
        },
        # Task 3: This task is launched at 9pm(EST) weekly only on Sunday.
        # Reload all AOs.
        "reload_all_aos_every_sunday": {
            "task": "webservices.tasks.legal_docs.weekly_reload_all_aos",
            "schedule": crontab(minute=0, hour=1, day_of_week="sun"),
        },
        # Task 4: This task is launched at 19:55pm(EST) everyday.
        # When found modified case(s)(MUR/AF/ADR) in past 24 hours (19:55pm-19:55pm EST),
        # send case detail information to Slack.
        "send_alert_legal_case": {
            "task": "webservices.tasks.legal_docs.send_alert_daily_modified_legal_case",
            "schedule": crontab(minute=55, hour=23),
        },
        # Task 5: This task is launched at 12am(EST) only on Sunday.
        # Take Elasticsearch CASE_INDEX and AO_INDEX snapshot.
        "backup_elasticsearch_every_sunday": {
            "task": "webservices.tasks.legal_docs.create_es_backup",
            "schedule": crontab(minute=0, hour=4, day_of_week="sun"),
        },
        # Task 6: This task is launched at 5am(EST) everyday.
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
