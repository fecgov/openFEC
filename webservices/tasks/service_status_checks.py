from webservices.tasks.utils import set_redis_value
from webservices.env import env
from celery import shared_task
from webservices.tasks.celery import FlaskQueueOnce

SYSTEM_STATUS_CACHE_AGE = env.get_credential("SYSTEM_STATUS_CACHE_AGE") or 40


@shared_task(once={"graceful": True}, base=FlaskQueueOnce, ignore_result=False)
def heartbeat():
    # if this task is running, that means that redis, celery-beat, and celery-worker are up
    set_redis_value("CELERY_STATUS", {"celery-is-running": True}, age=SYSTEM_STATUS_CACHE_AGE)
