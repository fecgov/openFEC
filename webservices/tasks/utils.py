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
        cf_s3_service = env.get_service(name="fec-s3-api")
        session = boto3.Session(
            aws_access_key_id=cf_s3_service.credentials["access_key_id"],
            aws_secret_access_key=cf_s3_service.credentials["secret_access_key"],
            region_name="us-gov-west-1"
        )
        s3 = session.resource("s3")
        print("cf_s3_service.credentials['bucket']", cf_s3_service.credentials["bucket"])
        bucket = s3.Bucket(cf_s3_service.credentials["bucket"])
        print("'get_bucket' bucket: {}".format(bucket))
    except Exception as err:
        logging.error("An error occurred trying to connect to s3. Please disregard if running locally.{0}".format(err))
        return
    return bucket


def get_object(key):
    return get_bucket().Object(key=key)


def get_s3_key(name):
    cf_s3_service = env.get_service(name="fec-s3-api")
    connection = boto.s3.connect_to_region(
        "us-gov-west-1",
        aws_access_key_id=cf_s3_service.credentials["access_key_id"],
        aws_secret_access_key=cf_s3_service.credentials["secret_access_key"]
    )
    print("cf_s3_service.credentials['bucket']", cf_s3_service.credentials["bucket"])
    bucket = connection.get_bucket(cf_s3_service.credentials["bucket"])
    print("'get_s3_key' bucket: {}".format(bucket))
    key = Key(bucket=bucket, name=name)
    return key


def get_json_data(response):
    # convert the response bytes data to a string
    python_str = json.dumps(response.data.decode("utf-8"))
    return python_str


def get_app_name():
    return env.get_credential("APP_NAME")
