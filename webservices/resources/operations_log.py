import sqlalchemy as sa
from sqlalchemy import cast, Integer
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices.utils import use_kwargs
from webservices.common import models
from webservices.common.models import db, OperationsLog

from webservices.common.views import ApiResource

@doc(
    tags=['filer resources'],
    description=docs.STATE_ELECTION_OFFICES,
)
class OperationsLogView(ApiResource):
    model = models.OperationsLog
    schema = schemas.OperationsLogSchema
    page_schema = schemas.OperationsLogPageSchema

    @use_kwargs(args.paging)
    @use_kwargs(args.operations_log)
    @use_kwargs(args.make_multi_sort_args(default='-rpt_yr'))
    @marshal_with(schemas.OperationsLogPageSchema())
    def get(self, **kwargs):
        query = self._get_results(kwargs)
        return utils.fetch_page(query, kwargs, model=OperationsLog, multi=True)

    def _get_results(self, kwargs):
        query = db.session.query(models.OperationsLog)
        # query the operations_log table and get the transaction records 
        # whose status is verified (i.e status_num == 1)
        if kwargs.get('cand_cmte_id'):
            query = query.filter(
                sa.and_(
                    OperationsLog.cand_cmte_id.in_([kwargs['cand_cmte_id']]),
                    OperationsLog.status_num == '1',
                )
            )

        if kwargs.get('cand_cmte_id') and kwargs.get('rpt_yr'):
            query = query.filter(
                sa.and_(
                    OperationsLog.cand_cmte_id.in_([kwargs['cand_cmte_id']]),
                    OperationsLog.rpt_yr == kwargs['rpt_yr'],
                    OperationsLog.status_num == '1',
                )
            )
        return query