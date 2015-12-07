import io
import csv
import mock
import hashlib

from webservices import schemas
from webservices.rest import db, api
from webservices.common import models
from webservices.tasks import download as tasks
from webservices.resources import download as resource

from tests import factories
from tests.common import ApiBaseTest

class TestDownloadTask(ApiBaseTest):

    def test_get_filename(self):
        path = '/v1/candidates/'
        qs = '?office=H&sort=name'
        expected = hashlib.sha224((path + qs).encode('utf-8')).hexdigest() + '.zip'
        assert tasks.get_s3_name(path, qs) == expected

    def test_download_url(self):
        obj = mock.Mock()
        obj.key = 'key'
        obj.bucket = 'bucket'
        obj.meta.client.generate_presigned_url.return_value = '/download'
        url = resource.get_download_url(obj)
        assert url == '/download'
        assert obj.meta.client.generate_presigned_url.called_once_with(
            'get_object',
            Params={'Key': 'key', 'Bucket': 'bucket'},
            ExpiresIn=resource.URL_EXPIRY,
        )

    def test_download_url_filename(self):
        obj = mock.Mock()
        obj.key = 'key'
        obj.bucket = 'bucket'
        resource.get_download_url(obj, filename='data.zip')
        assert obj.meta.client.generate_presigned_url.called_once_with(
            'get_object',
            Params={
                'Key': 'key',
                'Bucket': 'bucket',
                'ResponseContentDisposition': 'filename=data.zip',
            },
            ExpiresIn=resource.URL_EXPIRY,
        )

    def test_write_csv(self):
        records = [
            factories.CandidateHistoryFactory()
            for _ in range(5)
        ]
        query = models.CandidateHistory.query
        schema = schemas.CandidateHistorySchema
        sio = io.StringIO()
        tasks.rows_to_csv(query, schema, sio)
        sio.seek(0)
        reader = csv.DictReader(sio)
        assert reader.fieldnames == tasks.create_headers(schema)
        for record, row in zip(records, reader):
            assert record.candidate_id == row['candidate_id']

class TestDownloadResource(ApiBaseTest):

    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    def test_download(self, export, get_cached):
        get_cached.return_value = None
        res = self.client.post_json(api.url_for(resource.DownloadView, path='candidates', office='S'))
        assert res.json == {'status': 'queued'}
        get_cached.assert_called_once_with('/v1/candidates/', b'office=S', filename=None)
        export.delay.assert_called_once_with('/v1/candidates/', b'office=S')

    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    def test_download_cached(self, export, get_cached):
        get_cached.return_value = '/download'
        res = self.client.post_json(api.url_for(resource.DownloadView, path='candidates', office='S'))
        assert res.json == {'status': 'complete', 'url': '/download'}
        assert not export.delay.called

    @mock.patch('webservices.resources.download.MAX_RECORDS', 2)
    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    def test_download_too_big(self, export, get_cached):
        get_cached.return_value = None
        [factories.CandidateFactory() for _ in range(5)]
        db.session.commit()
        res = self.client.post_json(
            api.url_for(resource.DownloadView, path='candidates'),
            expect_errors=True,
        )
        assert res.status_code == 422
        assert not export.delay.called
