import sqlalchemy as sa
from flask.ext.restful import Resource

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import schemas
from webservices.common import models


reports_schema_map = {
    'P': (models.CommitteeReportsPresidential, schemas.CommitteeReportsPresidentialPageSchema),
    'H': (models.CommitteeReportsHouseSenate, schemas.CommitteeReportsHouseSenatePageSchema),
    'S': (models.CommitteeReportsHouseSenate, schemas.CommitteeReportsHouseSenatePageSchema),
}
default_schemas = (models.CommitteeReportsPacParty, schemas.CommitteeReportsPacPartyPageSchema)


reports_type_map = {
    'house-senate': 'H',
    'presidential': 'P',
    'pac-party': None,
}


def parse_types(types):
    include, exclude = [], []
    for each in types:
        target = exclude if each.startswith('-') else include
        each = each.lstrip('-')
        target.append(each)
    if include and exclude:
        include = [each for each in include if each not in exclude]
    return include, exclude


@spec.doc(
    tags=['financial'],
    description=docs.REPORTS,
    path_params=[
        {
         'name': 'committee_id',
         'in': 'path',
         'description': 'A unique identifier assigned to each committee or filer registered with the FEC.',
         'type': 'string',
        },
        {
         'name': 'committee_type',
         'in': 'path',
         'type': 'string',
         'description': 'House, Senate or presidential',
         'enum': ['presidential', 'pac-party', 'house-senate'],
        },
    ],
)
class ReportsView(Resource):

    @args.register_kwargs(args.paging)
    @args.register_kwargs(args.reports)
    @args.register_kwargs(args.make_sort_args(default=['-coverage_end_date']))
    @schemas.marshal_with(schemas.CommitteeReportsPageSchema(), wrap=False)
    def get(self, committee_id=None, committee_type=None, **kwargs):
        reports = self.get_reports(committee_id, committee_type, kwargs)
        reports, reports_schema = self.get_reports(committee_id, committee_type, kwargs)
        page = utils.fetch_page(reports, kwargs)
        return reports_schema().dump(page).data

    def get_reports(self, committee_id, committee_type, kwargs):
        reports_class, reports_schema = reports_schema_map.get(
            self._resolve_committee_type(committee_id, committee_type, kwargs),
            default_schemas,
        )

        reports = reports_class.query

        if committee_id is not None:
            reports = reports.filter_by(committee_id=committee_id)

        if kwargs['year']:
            reports = reports.filter(reports_class.report_year.in_(kwargs['year']))
        if kwargs['cycle']:
            reports = reports.filter(reports_class.cycle.in_(kwargs['cycle']))
        if kwargs['beginning_image_number']:
            reports = reports.filter(reports_class.beginning_image_number.in_(kwargs['beginning_image_number']))

        if kwargs['report_type']:
            include, exclude = parse_types(kwargs['report_type'])
            if include:
                reports = reports.filter(reports_class.report_type.in_(include))
            elif exclude:
                reports = reports.filter(sa.not_(reports_class.report_type.in_(exclude)))

        return reports, reports_schema

    def _resolve_committee_type(self, committee_id, committee_type, kwargs):
        if committee_id is not None:
            query = models.CommitteeHistory.query.filter_by(committee_id=committee_id)
            if kwargs['cycle']:
                query = query.filter(models.CommitteeHistory.cycle.in_(kwargs['cycle']))
            query = query.order_by(sa.desc(models.CommitteeHistory.cycle))
            committee = query.first_or_404()
            return committee.committee_type
        elif committee_type is not None:
            return reports_type_map.get(committee_type)
