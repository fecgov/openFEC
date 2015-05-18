import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
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


reports_type_map = {
    'house-senate': 'H',
    'presidential': 'P',
    'pac-party': None,
}


@spec.doc(
    tags=['financial'],
    description=docs.REPORTS,
    path_params=[
        {'name': 'id', 'in': 'path', 'type': 'string'},
    ],
)
class ReportsView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.reports)
    def get(self, committee_id=None, committee_type=None, **kwargs):
        reports = self.get_reports(committee_id, committee_type, kwargs)
        reports, reports_schema = self.get_reports(committee_id, committee_type, kwargs)
        paginator = paging.SqlalchemyPaginator(reports, kwargs['per_page'])
        return reports_schema().dump(paginator.get_page(kwargs['page'])).data

    def get_reports(self, committee_id, committee_type, kwargs):
        reports_class, reports_schema = reports_schema_map.get(
            self._resolve_committee_type(committee_id, committee_type),
            default_schemas,
        )

        reports = reports_class.query

        if committee_id is not None:
            reports = reports.filter_by(committee_id=committee_id)

        if kwargs['year']:
            reports = reports.filter(reports_class.report_year.in_(kwargs['year']))
        if kwargs['cycle']:
            reports = reports.filter(reports_class.cycle.in_(kwargs['cycle']))

        return reports.order_by(sa.desc(reports_class.coverage_end_date)), reports_schema

    def _resolve_committee_type(self, committee_id, committee_type):
        if committee_id is not None:
            committee = models.Committee.query.filter_by(committee_id=committee_id).first_or_404()
            return committee.committee_type
        elif committee_type is not None:
            return reports_type_map.get(committee_type)
