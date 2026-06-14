import os

workers = int(os.getenv("GUNICORN_WORKERS", 9))
worker_class = os.getenv("GUNICORN_WORKER_CLASS", "gevent")
timeout = int(os.getenv("GUNICORN_TIMEOUT", 300))
accesslog = os.getenv("GUNICORN_ACCESS_LOG", "-")
errorlog = os.getenv("GUNICORN_ERROR_LOG", "-")
loglevel = os.getenv("GUNICORN_LOG_LEVEL", "info")
max_requests = int(os.getenv("GUNICORN_MAX_REQUESTS", 1000))
max_requests_jitter = int(os.getenv("GUNICORN_MAX_REQUESTS_JITTER", 200))
