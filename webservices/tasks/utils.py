import json
import logging
import boto
import boto3

from boto.s3.key import Key
from webservices.env import env


logging.getLogger("boto3").setLevel(logging.CRITICAL)
logging.getLogger("smart_open").setLevel(logging.CRITICAL)


def get_app():
    from webservices.rest import app
    return app


def get_bucket():
    try:
        session = boto3.Session()
        s3 = session.resource("s3")
        bucket = s3.Bucket(env.get_credential("bucket"))
    except Exception as err:
        logging.error("An error occurred trying to connect to s3. Please disregard if running locally.{0}".format(err))
        return
    return bucket


def get_object(key):
    return get_bucket().Object(key=key)


def get_s3_key(name):
    connection = boto.s3.connect_to_region(
        env.get_credential("region"),
    )
    bucket = connection.get_bucket(env.get_credential("bucket"))
    key = Key(bucket=bucket, name=name)
    return key


def get_json_data(response):
    # convert the response bytes data to a string
    python_str = json.dumps(response.data.decode("utf-8"))
    return python_str


def get_app_name():
    return env.get_credential("APP_NAME")
