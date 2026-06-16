from webservices.env import env

workers = int(env.get_credential("GUNICORN_WORKERS", 9))
worker_class = env.get_credential("GUNICORN_WORKER_CLASS", "gevent")
timeout = int(env.get_credential("GUNICORN_TIMEOUT", 300))
accesslog = env.get_credential("GUNICORN_ACCESS_LOG", "-")
errorlog = env.get_credential("GUNICORN_ERROR_LOG", "-")
loglevel = env.get_credential("GUNICORN_LOG_LEVEL", "info")
max_requests = int(env.get_credential("GUNICORN_MAX_REQUESTS", 1000))
max_requests_jitter = int(env.get_credential("GUNICORN_MAX_REQUESTS_JITTER", 200))
