import hashlib
from flask import request
from webservices.tasks.utils import get_redis_value
from flask import jsonify
from webservices.tasks.run_schedule_a_query import run_schedule_a_query
from webservices import utils


def get_cache_key(path, query_params):
    sorted_items = sorted(query_params.items())
    query_string = '&'.join(f"{k}={v}" for k, v in sorted_items)

    raw_key = f"{path}{query_string}"

    hashed_key = hashlib.sha256(raw_key.encode('utf-8')).hexdigest()
    return hashed_key


class async_schedule_a(utils.Resource):

    def get(self, **kwargs):
        path = request.path.replace('/async', '')
        query_params = request.args.to_dict(flat=True)

        hashed_key = get_cache_key(path, query_params)
        cached = get_redis_value(hashed_key)

        if cached:
            return jsonify({'status': 'complete', 'data': cached})

        task = run_schedule_a_query.delay(query_params, hashed_key)
        return jsonify({'status': 'queued', 'task_id': task.id, 'poll_url': f'http://127.0.0.1:5000/v1/async/status/{hashed_key}'}), 202


class async_status(utils.Resource):
    def get(self, task_id, **kwargs):
        result = get_redis_value(task_id)
        response = jsonify(result)

        response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "0"

        if result is None:
            response.status_code = 404
            return response

        return response
