import json
import logging
import boto
import boto3
import redis

from boto.s3.key import Key
from webservices.env import env


logging.getLogger("boto3").setLevel(logging.CRITICAL)
logging.getLogger("smart_open").setLevel(logging.CRITICAL)


def get_bucket():
    try:
        session = boto3.Session()
        s3 = session.resource("s3")
        bucket = s3.Bucket(env.get_credential("AWS_PUBLIC_BUCKET"))
    except Exception as err:
        logging.error("An error occurred trying to connect to s3. Please disregard if running locally.{0}".format(err))
        return
    return bucket


def get_object(key):
    return get_bucket().Object(key=key)


def get_s3_key(name):
    connection = boto.s3.connect_to_region(
        env.get_credential("AWS_DEFAULT_REGION"),
    )
    bucket = connection.get_bucket(env.get_credential("AWS_PUBLIC_BUCKET"))
    key = Key(bucket=bucket, name=name)
    return key


def get_json_data(response):
    # convert the response bytes data to a string
    python_str = json.dumps(response.data.decode("utf-8"))
    return python_str


def get_app_name():
    return env.get_credential("APP_NAME") if env.get_credential("APP_NAME") is not None else "fec | api | local"


def redis_url():
    return env.get_credential("FEC_REDIS_URL", "redis://localhost:6379/0")


def set_redis_value(key, value, age):
    """
    Serialize the value to json and set it in redis with the given age
    """
    redis_instance = get_redis_instance()
    redis_instance.set(key, json.dumps(value), ex=age)


def get_redis_value(key, fallback=None):
    """
    Get value from redis and parse the json.
    If they value is falsy ("", None), return None
    """
    redis_instance = get_redis_instance()
    value = redis_instance.get(key)
    return json.loads(value) if value else fallback


def get_redis_instance():
    return redis.Redis.from_url(redis_url())
