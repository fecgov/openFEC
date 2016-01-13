import sqlalchemy as sa
from flask_apispec import doc, marshal_with

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.utils import use_kwargs


reports_schema_map = {
    'P': (models.CommitteeReportsPresidential, schemas.CommitteeReportsPresidentialPageSchema),
    'H': (models.CommitteeReportsHouseSenate, schemas.CommitteeReportsHouseSenatePageSchema),
    'S': (models.CommitteeReportsHouseSenate, schemas.CommitteeReportsHouseSenatePageSchema),
    'I': (models.CommitteeReportsIEOnly, schemas.CommitteeReportsIEOnlyPageSchema),
}
# We don't have report data for C and E yet
default_schemas = (models.CommitteeReportsPacParty, schemas.CommitteeReportsPacPartyPageSchema)


reports_type_map = {
    'house-senate': 'H',
    'presidential': 'P',
    'ie-only': 'I',
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


@doc(
    tags=['financial'],
    description=docs.REPORTS,
    params={
        'committee_id': {'description': docs.COMMITTEE_ID},
        'committee_type': {
            'description': 'House, Senate, presidential, independent expenditure only',
            'enum': ['presidential', 'pac-party', 'house-senate', 'ie-only'],
        },
    },
)
class ReportsView(utils.Resource):

    @use_kwargs(args.paging)
    @use_kwargs(args.reports)
    @use_kwargs(args.make_sort_args(default='-coverage_end_date'))
    @marshal_with(schemas.CommitteeReportsPageSchema(), apply=False)
    def get(self, committee_id=None, committee_type=None, **kwargs):
        query, reports_class, reports_schema = self.build_query(
            committee_id=committee_id,
            committee_type=committee_type,
            **kwargs
        )
        if kwargs['sort']:
            validator = args.IndexValidator(reports_class)
            validator(kwargs['sort'])
        page = utils.fetch_page(query, kwargs, model=reports_class)
        return reports_schema().dump(page).data

    def build_query(self, committee_id=None, committee_type=None, **kwargs):
        reports_class, reports_schema = reports_schema_map.get(
            self._resolve_committee_type(
                committee_id=committee_id,
                committee_type=committee_type,
                **kwargs
            ),
            default_schemas,
        )

        query = reports_class.query

        # Eagerly load committees if applicable
        if hasattr(reports_class, 'committee'):
            query = reports_class.query.options(sa.orm.joinedload(reports_class.committee))

        if committee_id is not None:
            query = query.filter_by(committee_id=committee_id)

        if kwargs.get('year'):
            query = query.filter(reports_class.report_year.in_(kwargs['year']))
        if kwargs.get('cycle'):
            query = query.filter(reports_class.cycle.in_(kwargs['cycle']))
        if kwargs.get('beginning_image_number'):
            query = query.filter(reports_class.beginning_image_number.in_(kwargs['beginning_image_number']))

        if kwargs.get('report_type'):
            include, exclude = parse_types(kwargs['report_type'])
            if include:
                query = query.filter(reports_class.report_type.in_(include))
            elif exclude:
                query = query.filter(sa.not_(reports_class.report_type.in_(exclude)))

        if kwargs.get('is_amended') is not None:
            column = reports_class.expire_date
            query = query.filter(column != None if kwargs['is_amended'] else column == None)  # noqa

        return query, reports_class, reports_schema

    def _resolve_committee_type(self, committee_id=None, committee_type=None, **kwargs):
        if committee_id is not None:
            query = models.CommitteeHistory.query.filter_by(committee_id=committee_id)
            if kwargs.get('cycle'):
                query = query.filter(models.CommitteeHistory.cycle.in_(kwargs['cycle']))
            query = query.order_by(sa.desc(models.CommitteeHistory.cycle))
            committee = query.first_or_404()
            return committee.committee_type
        elif committee_type is not None:
            return reports_type_map.get(committee_type)
