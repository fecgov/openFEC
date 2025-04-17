from celery.schedules import crontab
from webservices.env import env


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
        # Task 7: This task is launched at 1am(EST) on the first day of the
        # month
        # Deletes snapshots older than 30 days
        "delete_elasticsearch_backups_monthly": {
            "task": "webservices.tasks.legal_docs.delete_es_backup_monthly",
            "schedule": crontab(minute=0, hour=5, day_of_month=1),
        },
        # Task 8: This task is launched every 30 seconds
        # Checks that redis, celery-beat, and celery-worker are running
        "essential-services-status-check": {
            "task": "webservices.tasks.service_status_checks.heartbeat",
            "schedule": 30.0,
        },
    }
