from sqlalchemy import desc
from flask.ext.restful import Resource

from webservices import args
from webservices import spec
from webservices import paging
from webservices import schemas
from webservices.common import models


reports_schema_map = {
    'P': (models.CommitteeReportsPresidential, schemas.ReportsPresidentialPageSchema),
    'H': (models.CommitteeReportsHouseOrSenate, schemas.ReportsHouseSenatePageSchema),
    'S': (models.CommitteeReportsHouseOrSenate, schemas.ReportsHouseSenatePageSchema),
}
default_schemas = (models.CommitteeReportsPacOrParty, schemas.ReportsPacPartyPageSchema)


@spec.doc(path_params=[
    {'name': 'id', 'in': 'path', 'type': 'string'},
])
class ReportsView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.reports)
    def get(self, committee_id, **kwargs):
        committee = models.Committee.query.filter_by(committee_id=committee_id).one()
        reports_class, reports_schema = reports_schema_map.get(committee.committee_type, default_schemas)
        reports = self.get_reports(committee_id, reports_class, kwargs)
        paginator = paging.SqlalchemyPaginator(reports, kwargs['per_page'])
        return reports_schema().dump(paginator.get_page(kwargs['page'])).data

    def get_reports(self, committee_id, reports_class, kwargs):
        reports = reports_class.query.filter_by(committee_id=committee_id)
        if kwargs['cycle'] != '*':
            reports = reports.filter(reports_class.cycle.in_(kwargs['cycle'].split(',')))
        return reports.order_by(desc(reports_class.coverage_end_date))
