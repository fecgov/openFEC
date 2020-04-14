import base64
import datetime
import hashlib
import unittest.mock as mock

import pytest
from botocore.exceptions import ClientError

from webservices.exceptions import ApiError
from webservices.rest import db, api
from webservices.tasks import download as tasks
from webservices.resources import download as resource
from webservices.resources import (
    aggregates,
    candidates,
    candidate_aggregates,
    committees,
    costs,
    filings,
    reports,
    sched_a,
    sched_b,
    sched_d,
    sched_e,
    sched_f,
)

from tests import factories
from tests.common import ApiBaseTest


class TestDownloadTask(ApiBaseTest):
    def test_get_filename(self):
        path = '/v1/candidates/'
        qs = '?office=H&sort=name'
        expected = hashlib.sha224((path + qs).encode('utf-8')).hexdigest() + '.csv'
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

    @mock.patch('webservices.tasks.download.make_bundle')
    def test_views(self, make_bundle):
        committee = factories.CommitteeFactory(committee_type='H')
        committee_id = committee.committee_id
        factories.CommitteeHistoryFactory(committee_id=committee_id, committee_type='H')
        filing = factories.FilingsFactory(committee_id=committee_id)  # noqa
        efiling = factories.EFilingsFactory(  # noqa
            committee_id=committee_id, receipt_date=datetime.datetime(2012, 1, 1)
        )
        basef3pfiling = factories.BaseF3PFilingFactory(  # noqa
            committee_id=committee_id, receipt_date=datetime.date(2012, 1, 1)
        )

        db.session.commit()

        # these are the major downloadable resources, we may want to add more later
        RESOURCE_WHITELIST = {
            aggregates.ScheduleABySizeView,
            aggregates.ScheduleAByStateView,
            aggregates.ScheduleAByZipView,
            aggregates.ScheduleAByEmployerView,
            aggregates.ScheduleAByOccupationView,
            aggregates.ScheduleBByRecipientView,
            aggregates.ScheduleBByRecipientIDView,
            aggregates.ScheduleBByPurposeView,
            candidate_aggregates.TotalsCandidateView,
            candidates.CandidateList,
            committees.CommitteeList,
            costs.CommunicationCostView,
            costs.ElectioneeringView,
            filings.EFilingsView,
            filings.FilingsList,
            filings.FilingsView,
            reports.ReportsView,
            reports.CommitteeReportsView,
            reports.EFilingHouseSenateSummaryView,
            reports.EFilingPresidentialSummaryView,
            reports.EFilingPacPartySummaryView,
            sched_a.ScheduleAView,
            sched_a.ScheduleAEfileView,
            sched_b.ScheduleBView,
            sched_b.ScheduleBEfileView,
            sched_d.ScheduleDView,
            sched_e.ScheduleEView,
            sched_e.ScheduleEEfileView,
            sched_f.ScheduleFView,
        }

        for view in RESOURCE_WHITELIST:
            if view.endpoint in ['reportsview']:
                url = api.url_for(view, committee_type=committee.committee_type)
            elif view.endpoint in [
                'filingsview',
                'committeereportsview',
            ]:
                url = api.url_for(view, committee_id=committee.committee_id)
            else:
                url = api.url_for(view)
            tasks.export_query(url, base64.b64encode(b'').decode('UTF-8'))


class TestDownloadResource(ApiBaseTest):
    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    def test_download(self, export, get_cached):
        get_cached.return_value = None
        res = self.client.post_json(
            api.url_for(resource.DownloadView, path='candidates', office='S')
        )
        assert res.json == {'status': 'queued'}
        get_cached.assert_called_once_with(
            '/v1/candidates/', b'office=S', filename=None
        )
        export.delay.assert_called_once_with(
            '/v1/candidates/', base64.b64encode(b'office=S').decode('UTF-8')
        )

    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    def test_download_cached(self, export, get_cached):
        get_cached.return_value = '/download'
        res = self.client.post_json(
            api.url_for(resource.DownloadView, path='candidates', office='S')
        )
        assert res.json == {'status': 'complete', 'url': '/download'}
        assert not export.delay.called

    def test_download_forbidden(self):
        with pytest.raises(ApiError):
            self.client.post_json(
                api.url_for(
                    resource.DownloadView,
                    path='elections/search',
                    office='house',
                    state='VA',
                    cycle=2018,
                )
            )

    @mock.patch('webservices.resources.download.MAX_RECORDS', 2)
    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    def test_download_too_big(self, export, get_cached):
        get_cached.return_value = None
        [factories.CandidateFactory() for _ in range(5)]
        db.session.commit()
        res = self.client.post_json(
            api.url_for(resource.DownloadView, path='candidates'), expect_errors=True,
        )
        assert res.status_code == 403
        assert not export.delay.called

    @mock.patch('webservices.resources.download.get_download_url')
    @mock.patch('webservices.tasks.utils.get_object')
    def test_get_cached_exists(self, get_object, get_download):
        mock_object = mock.Mock()
        get_object.return_value = mock_object
        get_download.return_value = '/download'
        res = resource.get_cached_file('/candidate', b'', filename='download.csv')
        assert res == '/download'
        get_download.assert_called_once_with(mock_object, filename='download.csv')

    @mock.patch('webservices.tasks.utils.get_object')
    def test_get_cached_not_exists(self, get_object):
        mock_object = mock.Mock()

        def get_metadata():
            raise ClientError({'Error': {}}, 'test')

        mock_metadata = mock.PropertyMock(side_effect=get_metadata)
        type(mock_object).metadata = mock_metadata
        get_object.return_value = mock_object
        res = resource.get_cached_file('/candidate', b'')
        assert res is None
