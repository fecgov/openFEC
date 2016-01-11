import sqlalchemy as sa
from flask_apispec import doc

from webservices import args
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


@doc(tags=['dates'], description='FEC reporting dates since 1995.')
class ReportingDatesView(ApiResource):

    model = models.ReportDate
    schema = schemas.ReportingDatesSchema
    page_schema = schemas.ReportingDatesPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.reporting_dates,
            args.make_sort_args(
                default='-due_date',
                validator=args.IndexValidator(self.model),
            ),
        )

    filter_multi_fields = [
        ('report_year', models.ReportDate.report_year),
        ('report_type', models.ReportDate.report_type)
    ]
    filter_range_fields = [
        (('min_due_date', 'max_due_date'), models.ReportDate.due_date),
        (('min_create_date', 'max_create_date'), models.ReportDate.create_date),
        (('min_update_date', 'max_update_date'), models.ReportDate.update_date),
    ]

    query_options = [sa.orm.joinedload(models.ReportDate.report)]


@doc(tags=['dates'], description='FEC election dates since 1995.')
class ElectionDatesView(ApiResource):

    model = models.ElectionDate
    schema = schemas.ElectionDatesSchema
    page_schema = schemas.ElectionDatesPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.election_dates,
            args.make_sort_args(
                default='-election_date',
                validator=args.IndexValidator(self.model),
            ),
        )

    filter_multi_fields = [
        ('election_state', models.ElectionDate.election_state),
        ('election_district', models.ElectionDate.election_district),
        ('election_party', models.ElectionDate.election_party),
        ('office_sought', models.ElectionDate.office_sought),
        ('election_type_id', models.ElectionDate.election_type_id),
        ('election_year', models.ElectionDate.election_year),
    ]
    filter_range_fields = [
        (('min_election_date', 'max_election_date'), models.ElectionDate.election_date),
        (('min_update_date', 'max_update_date'), models.ElectionDate.update_date),
        (('min_create_date', 'max_create_date'), models.ElectionDate.create_date),
        (('min_primary_general_date', 'max_primary_general_date'), models.ElectionDate.primary_general_date),
    ]

    def build_query(self, *args, **kwargs):
        query = super().build_query(*args, **kwargs)
        return query.filter_by(election_status_id=1)
