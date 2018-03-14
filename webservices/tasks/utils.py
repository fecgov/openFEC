import boto
import boto3
import logging
import re
import json
import requests
from webservices.env import env
from boto.s3.key import Key

logging.getLogger('boto3').setLevel(logging.CRITICAL)
logging.getLogger('smart_open').setLevel(logging.CRITICAL)

def get_app():
    from webservices.rest import app
    return app

def get_bucket():
    session = boto3.Session(
        aws_access_key_id=env.get_credential('access_key_id'),
        aws_secret_access_key=env.get_credential('secret_access_key'),
        region_name=env.get_credential('region')
    )
    s3 = session.resource('s3')
    return s3.Bucket(env.get_credential('bucket'))

def get_object(key):
    return get_bucket().Object(key=key)

def get_s3_key(name):
    connection = boto.s3.connect_to_region(
        env.get_credential('region'),
        aws_access_key_id=env.get_credential('access_key_id'),
        aws_secret_access_key=env.get_credential('secret_access_key'),
    )
    bucket = connection.get_bucket(env.get_credential('bucket'))
    key = Key(bucket=bucket, name=name)
    return key

def get_json_data(response):
    python_str = json.dumps(response.data.decode('utf-8'))
    return python_str

def format_url(url):
    """
    remove the api_key and its value from the URL by using a regex
    """
    # Split the url into parts and get only url after /v1/
    parts = url.split('/v1/')
    url_path = parts[1]
    cleaned_url = re.sub('.api_key=.*?&', '', url_path)

    # Remove other special characters from the URL

    special_characters = [('&', '-'), ('=', '-'), ('?', '')
        (":", ""), ("<", ""), (">", ""), ("\\", ""), (",", ""),
        ("|", ""), ("*", "")]
    cleaned_url = [cleaned_url.replace(x, y) for x, y in special_characters]

    # for x, y in special_characters:
    #     cleaned_url = cleaned_url.replace(x, y)

    return cleaned_url

def get_cached_request(cached_url):
    response = requests.get(cached_url)
    python_obj = json.loads(response.json())
    python_str = json.dumps(python_obj, sort_keys=True, indent=4)

    if response.status_code == 200:
        return python_str
    return None
