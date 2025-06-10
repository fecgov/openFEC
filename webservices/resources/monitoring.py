import redis

from flask import jsonify
from webservices.utils import Resource
from webservices.tasks.utils import get_redis_value


class celery_check(Resource):

    def get(self, **kwargs):
        try:

            celery_status = get_redis_value("CELERY_STATUS", {})

            if celery_status.get("celery-is-running"):
                return jsonify(status='ok', message='Celery workers are processing tasks'), 200
            else:
                return jsonify(status='down', message='No Celery workers responding'), 503

        except redis.ConnectionError:
            return jsonify(status='down', message='Redis connection error'), 503
