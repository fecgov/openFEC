import base64
import datetime
import hashlib
import json
import unittest.mock as mock

import pytest
from botocore.exceptions import ClientError

from webservices.exceptions import ApiError
from webservices.common.models import db
from webservices.api_setup import api
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
    sched_h4,
    totals
)

from tests import factories
from tests.common import ApiBaseTest


class TestDownloadTask(ApiBaseTest):
    def test_get_filename(self):
        path = '/v1/candidates/'
        qs = '?office=H&sort=name'
        prefix = 'user-downloads/'
        expected = prefix + hashlib.sha224((path + qs).encode('utf-8')).hexdigest() + '.csv'
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

    @mock.patch('webservices.tasks.download.task_utils.delete_redis_value')
    @mock.patch('webservices.tasks.download.task_utils.set_redis_value')
    @mock.patch('webservices.tasks.download.make_bundle')
    @mock.patch('webservices.tasks.download.call_resource')
    def test_export_query_writes_failure_on_exception(self, call_resource,
                                                      make_bundle, set_redis_value, delete_redis_value):
        make_bundle.side_effect = Exception('S3 error')
        tasks.export_query('/v1/candidates/', base64.b64encode(b'office=H').decode())
        assert set_redis_value.called
        key = set_redis_value.call_args[0][0]
        assert key.startswith('download-failed:')
        assert set_redis_value.call_args[0][1] is True
        assert delete_redis_value.called

    @mock.patch('webservices.tasks.download.task_utils.delete_redis_value')
    @mock.patch('webservices.tasks.download.task_utils.set_redis_value')
    @mock.patch('webservices.tasks.download.make_bundle')
    @mock.patch('webservices.tasks.download.call_resource')
    def test_export_query_no_failure_redis_on_success(self, call_resource,
                                                      make_bundle, set_redis_value, delete_redis_value):
        tasks.export_query('/v1/candidates/', base64.b64encode(b'office=H').decode())
        assert not set_redis_value.called
        assert not delete_redis_value.called

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

        db.session.refresh(committee)

        # these are the major downloadable resources, we may want to add more later
        DOWNLOADABLE_RESOURCES = {
            aggregates.ScheduleABySizeView,
            aggregates.ScheduleAByStateView,
            aggregates.ScheduleAByZipView,
            aggregates.ScheduleAByEmployerView,
            aggregates.ScheduleAByOccupationView,
            aggregates.ScheduleBByRecipientView,
            aggregates.ScheduleBByRecipientIDView,
            aggregates.ScheduleBByPurposeView,
            candidate_aggregates.TotalsCandidateView,
            candidate_aggregates.CandidateTotalAggregateView,
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
            sched_h4.ScheduleH4View,
            sched_h4.ScheduleH4EfileView,
            totals.TotalsByEntityTypeView
        }

        for view in DOWNLOADABLE_RESOURCES:
            if view.endpoint in [
                'reportsview',
                'totalsbyentitytypeview',
            ]:
                url = api.url_for(view, entity_type=committee.committee_type)
            elif view.endpoint in [
                'filingsview',
                'committeereportsview',
            ]:
                url = api.url_for(view, committee_id=committee.committee_id)
            else:
                url = api.url_for(view)
            tasks.export_query(url, base64.b64encode(b'').decode('UTF-8'))


class TestDownloadResource(ApiBaseTest):
    @mock.patch('webservices.resources.download.task_utils.set_redis_value')
    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    def test_download(self, export, get_cached, set_redis_value):
        get_cached.return_value = None
        export.delay.return_value = mock.Mock(id='test-task-id')
        res = self.client.post(
            api.url_for(resource.DownloadView, path='candidates', office='S', q='joh', sort='receipts')
        )
        assert res.get_json() == {'status': 'queued', 'task_id': 'test-task-id'}
        get_cached.assert_called_once_with(
            '/v1/candidates/', b'office=S&q=joh&sort=receipts', filename=None
        )
        export.delay.assert_called_once_with(
            '/v1/candidates/', base64.b64encode(b'office=S&q=joh&sort=receipts').decode('UTF-8')
        )
        set_redis_value.assert_called_once_with('download-queued:test-task-id', True, age=7200)

    @mock.patch('webservices.resources.download.task_utils.set_redis_value')
    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    @mock.patch('webservices.resources.download.task_utils.get_redis_value')
    def test_download_with_task_id_no_failure_not_queued(self, get_redis_value, export, get_cached, set_redis_value):
        # task_id is stale — neither failed nor queued in Redis — so a new task is queued
        get_cached.return_value = None
        get_redis_value.return_value = None
        export.delay.return_value = mock.Mock(id='new-task-id')
        res = self.client.post(
            api.url_for(resource.DownloadView, path='candidates', office='S'),
            data=json.dumps({'task_id': 'old-task-id'}),
            content_type='application/json',
        )
        assert res.get_json() == {'status': 'queued', 'task_id': 'new-task-id'}
        get_redis_value.assert_any_call('download-failed:old-task-id')
        get_redis_value.assert_any_call('download-queued:old-task-id')
        assert export.delay.called

    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    @mock.patch('webservices.resources.download.task_utils.get_redis_value')
    def test_download_with_task_id_still_queued(self, get_redis_value, export, get_cached):
        # task_id is valid and still running — return same task_id without queuing new task
        get_cached.return_value = None
        get_redis_value.side_effect = lambda key: key == 'download-queued:running-task-id'
        res = self.client.post(
            api.url_for(resource.DownloadView, path='candidates', office='S'),
            data=json.dumps({'task_id': 'running-task-id'}),
            content_type='application/json',
        )
        assert res.get_json() == {'status': 'queued', 'task_id': 'running-task-id'}
        assert not export.delay.called

    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    @mock.patch('webservices.resources.download.delete_redis_value')
    @mock.patch('webservices.resources.download.task_utils.get_redis_value')
    def test_download_with_task_id_failed(self, get_redis_value, delete_redis_value, export, get_cached):
        get_cached.return_value = None
        get_redis_value.return_value = True
        res = self.client.post(
            api.url_for(resource.DownloadView, path='candidates', office='S'),
            data=json.dumps({'task_id': 'failed-task-id'}),
            content_type='application/json',
        )
        assert res.status_code == 500
        delete_redis_value.assert_called_once_with('download-failed:failed-task-id')
        assert not export.delay.called

    @mock.patch('webservices.resources.download.get_cached_file')
    @mock.patch('webservices.resources.download.download.export_query')
    def test_download_cached(self, export, get_cached):
        get_cached.return_value = '/download'
        res = self.client.post(
            api.url_for(resource.DownloadView, path='candidates', office='S')
        )
        assert res.get_json() == {'status': 'complete', 'url': '/download'}
        assert not export.delay.called

    def test_download_forbidden(self):
        with pytest.raises(ApiError):
            self.client.post(
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
        res = self.client.post(
            api.url_for(resource.DownloadView, path='/candidates', expect_errors=True)
        )
        assert res.status_code == 308
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
