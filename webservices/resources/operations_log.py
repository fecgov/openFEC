import sqlalchemy as sa
import logging
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.utils import use_kwargs
from webservices.common import models, counts
from webservices.common.models import db, OperationsLog
from webservices.exceptions import ApiError

from webservices.common.views import ApiResource

logger = logging.getLogger(__name__)

@doc(
    tags=['filings'],
    description=docs.OPERATIONS_LOG,
)
class OperationsLogView(ApiResource):
    model = models.OperationsLog
    schema = schemas.OperationsLogSchema
    page_schema = schemas.OperationsLogPageSchema

    @use_kwargs(args.paging)
    @use_kwargs(args.operations_log)
    @use_kwargs(args.make_multi_sort_args(default=['-report_year']))
    @marshal_with(schemas.OperationsLogPageSchema())
    def get(self, **kwargs):
        query = self._get_results(kwargs)
        return utils.fetch_page(query, kwargs, model=OperationsLog, multi=True)

    def _get_results(self, kwargs):
        query = db.session.query(models.OperationsLog)

        # query the operations_log table and get the transaction records 
        # whose status is verified (i.e status_num == 1)
        try:

            if kwargs.get('candidate_committee_id'):
                query = query.filter(
                    sa.and_(
                        OperationsLog.candidate_committee_id.in_([kwargs['candidate_committee_id']]),
                        OperationsLog.status_num == '1',
                    )
                )
            if kwargs.get('candidate_committee_id') and kwargs.get('report_year'):
                query = query.filter(
                    sa.and_(
                        OperationsLog.candidate_committee_id.in_([kwargs['candidate_committee_id']]),
                        OperationsLog.report_year == kwargs['report_year'],
                        OperationsLog.status_num == '1',
                    )
                )
        except:
            logger.error("Unexpected Server Error while fetching the records from the DB")
            raise ApiError("Unexpected Server Error", 500)
        return query