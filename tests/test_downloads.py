import io
import csv
import hashlib

from webservices import schemas
from webservices.common import models
from webservices.tasks import download

from tests import factories
from tests.common import ApiBaseTest

class TestDownload(ApiBaseTest):

    def test_get_filename(self):
        path = '/v1/candidates/'
        qs = '?office=H&sort=name'
        expected = hashlib.sha224((path + qs).encode('utf-8')).hexdigest() + '.csv'
        assert download.get_s3_name(path, qs) == expected

    def test_write_csv(self):
        records = [
            factories.CandidateHistoryFactory()
            for _ in range(5)
        ]
        query = models.CandidateHistory.query
        schema = schemas.CandidateHistorySchema
        sio = io.StringIO()
        download.rows_to_csv(query, schema, sio)
        sio.seek(0)
        reader = csv.DictReader(sio)
        assert reader.fieldnames == download.create_headers(schema)
        for record, row in zip(records, reader):
            assert record.candidate_id == row['candidate_id']
