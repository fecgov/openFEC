from celery import shared_task
from celery_once import QueueOnce
from webservices.resources.sched_a import ScheduleAView
from webservices.tasks.utils import set_redis_value
from flask import current_app
import json


@shared_task(base=QueueOnce, once={"graceful": True}, time_limit=60)
def run_schedule_a_query(params, cache_key):
    try:
        set_redis_value(cache_key, {'status': 'processing'}, 3600)
        view = ScheduleAView()
        with current_app.test_request_context(
            path='/v1/schedules/schedule_a/',
            method='GET',
            query_string=params
        ):
            results = view.get(**params)
        json_results = json.dumps(results.get_json())
        set_redis_value(cache_key, {'status': 'complete', 'data': json_results}, 3600)
    except Exception as e:
        set_redis_value(cache_key, json.dumps({"status": "failed", "error": str(e)}), ex=3600)
        raise
