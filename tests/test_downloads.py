import base64
import datetime
import hashlib
import json
import logging
import unittest.mock as mock

import psycopg2
import pytest
from botocore.exceptions import ClientError
from celery.backends.base import DisabledBackend
from celery.exceptions import SoftTimeLimitExceeded
from sqlalchemy import exc as sa_exc, text

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
        # Regression (#6704): the generic failure path must re-raise so Celery marks the task FAILURE
        with pytest.raises(Exception, match='S3 error'):
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


QS = base64.b64encode(b'office=H&q=secret-term').decode()
PATH = '/v1/candidates/'


def _raw_db_error(sql, setup=None):
    """Run SQL on a raw DBAPI connection (like copy_to) and return the psycopg2 error it raises."""
    conn = db.engine.raw_connection()
    try:
        with conn.cursor() as cursor:
            if setup:
                cursor.execute(setup)
            cursor.execute(sql)
    except psycopg2.Error as error:
        return error
    finally:
        conn.rollback()
        conn.close()
    raise AssertionError('expected a database error')


def _sqlalchemy_db_error(sql, setup=None):
    """Run SQL through SQLAlchemy (like the count query) and return the wrapped error it raises."""
    try:
        with db.engine.connect() as conn:
            if setup:
                conn.execute(text(setup))
            conn.execute(text(sql))
    except sa_exc.DBAPIError as error:
        return error
    raise AssertionError('expected a database error')


def _statement_timeout_raw():
    return _raw_db_error('SELECT pg_sleep(1)', setup='SET LOCAL statement_timeout = 1')


def _statement_timeout_sqlalchemy():
    return _sqlalchemy_db_error('SELECT pg_sleep(1)', setup='SET LOCAL statement_timeout = 1')


def _user_cancel_raw():
    return _raw_db_error('SELECT pg_cancel_backend(pg_backend_pid()), pg_sleep(1)')


def _undefined_table_sqlalchemy():
    return _sqlalchemy_db_error('SELECT * FROM no_such_table_6704')


class FakeRedis:
    """In-memory stand-in for webservices.tasks.utils Redis helpers (CI has no Redis)."""

    def __init__(self):
        self.store = {}

    def set(self, key, value, age):
        self.store[key] = value

    def get(self, key, fallback=None):
        return self.store.get(key) or fallback

    def delete(self, key):
        self.store.pop(key, None)

    def patches(self):
        return [
            mock.patch('webservices.tasks.utils.set_redis_value', side_effect=self.set),
            mock.patch('webservices.tasks.utils.get_redis_value', side_effect=self.get),
            mock.patch('webservices.tasks.utils.delete_redis_value', side_effect=self.delete),
            mock.patch('webservices.resources.download.delete_redis_value', side_effect=self.delete),
        ]


class TestDownloadTaskFailures(ApiBaseTest):
    """#6704: failures are re-raised so the worker reports the task as failed, and are logged searchably."""

    def setUp(self):
        super().setUp()
        self.redis = FakeRedis()
        # Keep a handle on the real task: some tests patch the module attribute.
        self.task = tasks.export_query._get_current_object()
        for patcher in self.redis.patches():
            patcher.start()
            self.addCleanup(patcher.stop)

    def _run(self, task_id='task-6704', exc=None, where='make_bundle'):
        """Run the task body as a worker does, with self.request.id set, using Celery's public
        push_request/pop_request. Returns (raised exception or None, captured log lines)."""
        self.redis.set('download-queued:{}'.format(task_id), True, age=7200)
        raised = None
        with mock.patch('webservices.tasks.download.call_resource') as call_resource, \
                mock.patch('webservices.tasks.download.make_bundle') as make_bundle, \
                self.assertLogs('webservices.tasks.download', level='INFO') as logs:
            if exc is not None:
                {'make_bundle': make_bundle, 'call_resource': call_resource}[where].side_effect = exc
            self.task.push_request(id=task_id)
            try:
                self.task.run(PATH, QS)
            except Exception as error:
                raised = error
            finally:
                self.task.pop_request()
        return raised, logs.output

    def _run_failing(self, exc, where='make_bundle', task_id='task-6704'):
        """Assert the original exception propagates and failure state is recorded; return the
        download_failed lines and all captured log lines."""
        raised, output = self._run(task_id=task_id, exc=exc, where=where)
        assert raised is exc  # the original exception object, not a wrapper or a Redis error
        assert self.redis.get('download-failed:{}'.format(task_id)) is True
        assert self.redis.get('download-queued:{}'.format(task_id)) is None
        failed = [line for line in output if 'download_failed' in line]
        assert len(failed) == 1
        return failed[0], output

    def test_celery_tracer_marks_failure_and_success(self):
        """Eager apply() runs Celery's tracer: a raised exception is a FAILURE (the worker's
        task_failure path); a normal return is SUCCESS. Nothing is persisted: task_ignore_result."""
        task = self.task
        instance_state = dict(vars(task))
        # Never touch a real result backend. Patched on this task's own class and removed on exit,
        # so neither the task instance nor any other task is left modified.
        backend_patch = mock.patch.object(type(task), 'backend', DisabledBackend(task.app))
        # Celery 5.2/billiard 3.6 tracebacks can't be formatted on Python 3.11 (co_positions);
        # silence the tracer's own failure log so test log capture doesn't trip on it.
        trace_logger = logging.getLogger('celery.app.trace')
        with backend_patch, \
                mock.patch.object(trace_logger, 'disabled', True), \
                mock.patch('webservices.tasks.download.call_resource'), \
                mock.patch('webservices.tasks.download.make_bundle') as make_bundle:
            assert task.apply(args=(PATH, QS)).state == 'SUCCESS'
            exc = RuntimeError('boom')
            make_bundle.side_effect = exc
            result = task.apply(args=(PATH, QS))
        assert result.state == 'FAILURE'
        assert result.result is exc
        # original task state is restored
        assert vars(task) == instance_state
        assert 'backend' not in type(task).__dict__

    def test_success_writes_no_failure_state(self):
        raised, output = self._run(task_id='ok-task')
        assert raised is None
        assert self.redis.get('download-failed:ok-task') is None
        # cleared later by the API when it finds the cached file, not by the task
        assert self.redis.get('download-queued:ok-task') is True
        assert not any('download_failed' in line for line in output)

    def test_generic_exception_reraises_and_logs(self):
        line, output = self._run_failing(RuntimeError('S3 upload failed'))
        assert 'task_id=task-6704' in line
        assert 'category=unexpected_error' in line
        assert 'exception_class=builtins.RuntimeError' in line
        assert 'path=/v1/candidates/' in line
        # structured line must not carry the query string or the exception message
        assert 'secret-term' not in line
        assert 'S3 upload failed' not in line

    def test_generic_exception_does_not_log_its_own_traceback(self):
        """The re-raised exception's traceback (which may hold SQL and parameters) is logged by
        Celery; the task's own 'Download failed' line must not duplicate it."""
        with self.assertLogs('webservices.tasks.download', level='ERROR') as logs, \
                mock.patch('webservices.tasks.download.call_resource'), \
                mock.patch('webservices.tasks.download.make_bundle', side_effect=RuntimeError('boom')):
            self.task.push_request(id='tb-task')
            try:
                with pytest.raises(RuntimeError):
                    self.task.run(PATH, QS)
            finally:
                self.task.pop_request()
        assert all(record.exc_info is None for record in logs.records)
        assert any(record.getMessage().startswith('Download failed:') for record in logs.records)

    def test_statement_timeout_from_copy_raw_psycopg2(self):
        line, _ = self._run_failing(_statement_timeout_raw(), where='make_bundle')
        assert 'category=db_statement_timeout' in line
        assert 'exception_class=psycopg2.errors.QueryCanceled' in line
        assert 'pgcode=57014' in line

    def test_statement_timeout_from_count_sqlalchemy_wrapped(self):
        exc = _statement_timeout_sqlalchemy()
        assert isinstance(exc, sa_exc.OperationalError)
        line, _ = self._run_failing(exc, where='call_resource')
        assert 'category=db_statement_timeout' in line
        assert 'exception_class=sqlalchemy.exc.OperationalError' in line
        assert 'pgcode=57014' in line
        assert 'pg_sleep' not in line  # SQL text from the wrapped error is not logged

    def test_statement_timeout_chained_through_other_exception(self):
        inner = _statement_timeout_raw()
        try:
            try:
                raise inner
            except psycopg2.Error as error:
                raise RuntimeError('wrapped') from error
        except RuntimeError as outer:
            exc = outer
        line, _ = self._run_failing(exc)
        assert 'category=db_statement_timeout' in line

    def test_other_cancellation_is_not_a_statement_timeout(self):
        exc = _user_cancel_raw()
        assert exc.pgcode == '57014'
        line, _ = self._run_failing(exc)
        assert 'category=db_query_canceled' in line
        assert 'db_statement_timeout' not in line

    def test_non_timeout_db_failure(self):
        line, _ = self._run_failing(_undefined_table_sqlalchemy(), where='call_resource')
        assert 'category=db_error' in line
        assert 'pgcode=42P01' in line

    def test_sqlalchemy_error_without_dbapi_error(self):
        line, _ = self._run_failing(sa_exc.InvalidRequestError('bad query construction'), where='call_resource')
        assert 'category=db_error' in line
        assert 'pgcode=None' in line

    def test_soft_time_limit_still_records_failure_and_reraises(self):
        line, output = self._run_failing(SoftTimeLimitExceeded())
        assert 'category=soft_time_limit' in line
        assert any('Download soft time limit exceeded' in entry for entry in output)

    def test_redis_set_failure_keeps_queued_and_does_not_mask_original(self):
        exc = RuntimeError('original failure')
        with mock.patch('webservices.tasks.utils.set_redis_value', side_effect=ConnectionError('redis down')):
            raised, output = self._run(task_id='redis-down', exc=exc)
        assert raised is exc
        # queued is left in place: removing it without a failed key would let the API requeue
        assert self.redis.get('download-queued:redis-down') is True
        assert any('download_failure_state_not_recorded task_id=redis-down exception_class=builtins.ConnectionError'
                   in line for line in output)
        assert not any('download_queued_state_not_cleared' in line for line in output)
        assert any('download_failed task_id=redis-down' in line for line in output)

    def test_redis_delete_failure_still_records_failed_state(self):
        exc = RuntimeError('original failure')
        with mock.patch('webservices.tasks.utils.delete_redis_value', side_effect=ConnectionError('redis down')):
            raised, output = self._run(task_id='delete-down', exc=exc)
        assert raised is exc
        # the API checks download-failed before download-queued, so this poll still returns 500
        assert self.redis.get('download-failed:delete-down') is True
        assert any('download_queued_state_not_cleared task_id=delete-down exception_class=builtins.ConnectionError'
                   in line for line in output)
        # the failure state was recorded, so the log must not claim otherwise
        assert not any('download_failure_state_not_recorded' in line for line in output)

    def test_failure_is_not_retried_or_requeued(self):
        task = self.task
        assert not getattr(task, 'autoretry_for', ())
        assert not task.acks_late
        with mock.patch.object(task, 'retry') as retry, \
                mock.patch.object(task, 'apply_async') as apply_async:
            self._run_failing(RuntimeError('boom'))
        assert not retry.called
        assert not apply_async.called

    @mock.patch('webservices.resources.download.get_cached_file', return_value=None)
    @mock.patch('webservices.resources.download.download.call_resource', return_value={'count': 1})
    @mock.patch('webservices.resources.download.download.export_query')
    def test_api_polling_queued_then_failed(self, export, call_resource, get_cached):
        """End to end with shared state: queue -> poll queued -> task fails -> poll 500 once."""
        export.delay.return_value = mock.Mock(id='flow-task')
        url = api.url_for(resource.DownloadView, path='candidates', office='S')

        res = self.client.post(url)
        assert res.status_code == 202
        assert res.get_json() == {'status': 'queued', 'task_id': 'flow-task'}

        poll = dict(data=json.dumps({'task_id': 'flow-task'}), content_type='application/json')
        res = self.client.post(url, **poll)
        assert res.status_code == 202
        assert res.get_json() == {'status': 'queued', 'task_id': 'flow-task'}

        self._run_failing(RuntimeError('boom'), task_id='flow-task')

        res = self.client.post(url, **poll)
        assert res.status_code == 500
        assert export.delay.call_count == 1  # failed poll does not requeue
        assert self.redis.get('download-failed:flow-task') is None  # consumed by the failed poll


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
