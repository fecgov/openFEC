from boto3 import client
import tempfile
import logging

from webservices.env import env
from webservices.tasks import app

logger = logging.getLogger(__name__)

@app.task
def build_sitemap():
    s3 = client(
        's3',
        aws_access_key_id=env.get_credential('CMS_AWS_ACCESS_KEY_ID', ''),
        aws_secret_access_key=env.get_credential('CMS_AWS_SECRET_ACCESS_KEY', '')
    )
    print('bucket: ', env.get_credential('CMS_AWS_STORAGE_BUCKET_NAME', ''))
    paginator = s3.get_paginator('list_objects_v2')
    operation_parameters = {
        'Bucket': env.get_credential('CMS_AWS_STORAGE_BUCKET_NAME', ''),
        'Prefix': 'cms-content/documents'
    }
    page_iterator = paginator.paginate(**operation_parameters)
    sitemap_data = []

    for page in page_iterator:
        sitemap_data.extend(
            [{'loc': 'https://' + operation_parameters['Bucket'] + '.s3-us-gov-west-1.amazonaws.com/' + d['Key'],
              'lastmod': d['LastModified'].strftime("%Y-%m-%dT%H:%M:%S+00:00")}
             for d in page['Contents'] if 'zzz' in d['Key']]
        )

    tf = tempfile.NamedTemporaryFile(mode='w+t')
    tf.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    tf.write('<urlset>\n')
    for d in sitemap_data:
        tf.write('<url>\n')
        tf.write('<loc>' + d['loc'] + '</loc>\n')
        tf.write('<lastmod>' + d['lastmod'] + '</lastmod>\n')
        tf.write('</url>\n')
    tf.write('</urlset>\n')
    tf.seek(0)

    s3.upload_file(
        Filename=tf.name,
        Bucket=operation_parameters['Bucket'],
        Key=operation_parameters['Prefix'] + '/sitemap_test.xml')
