
from flask_apispec import doc
from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource

@doc(tags=['filings'], description=docs.OPERATIONS_LOG)
class OperationsLogView(ApiResource):
    model = models.OperationsLog
    schema = schemas.OperationsLogSchema
    page_schema = schemas.OperationsLogPageSchema

    filter_multi_fields = [
        ('candidate_committee_id', models.OperationsLog.candidate_committee_id),
        ('beginning_image_number', models.OperationsLog.beginning_image_number),
        ('report_type', models.OperationsLog.report_type),
        ('report_year', models.OperationsLog.report_year),
        ('form_type', models.OperationsLog.form_type),
        ('amendment_indicator', models.OperationsLog.amendment_indicator),
        ('status_num', models.OperationsLog.status_num),
    ]

    filter_range_fields = [
        (('min_receipt_date', 'max_receipt_date'), models.OperationsLog.receipt_date),
        (('min_coverage_end_date', 'max_coverage_end_date'), models.OperationsLog.coverage_end_date),
        (('min_transaction_data_complete_date', 'max_transaction_data_complete_date'), models.OperationsLog.transaction_data_complete_date),
    ]

    @property
    def args(self):
        default_sort = ['-report_year']
        return utils.extend(
            args.paging,
            args.operations_log,
            args.make_multi_sort_args(
                default=default_sort,
            ),
        )

    def build_query(self, *args, **kwargs):
        query = super().build_query(*args, **kwargs)
        return query
