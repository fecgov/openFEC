import logging

from flask_apispec import doc
from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.exceptions import ApiError
from webservices.common.views import ApiResource

logger = logging.getLogger(__name__)


@doc(tags=['filings'], description=docs.OPERATIONS_LOG)
class OperationsLogView(ApiResource):
    model = models.OperationsLog
    schema = schemas.OperationsLogSchema
    page_schema = schemas.OperationsLogPageSchema

    filter_multi_fields = [
        ('candidate_committee_id', models.OperationsLog.candidate_committee_id),
        ('ending_image_number', models.OperationsLog.ending_image_number),
        ('report_type', models.OperationsLog.report_type),
        ('report_year', models.OperationsLog.report_year),
        ('form_type', models.OperationsLog.form_type),
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
        try:
            query = super().build_query(*args, **kwargs)
            # get the records whose status is verified
            results = query.filter_by(status_num=1)
        except:
            raise ApiError("Unexpected Server Error", 500)

        return results
