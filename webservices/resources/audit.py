from flask_apispec import doc

import sqlalchemy as sa

from webservices import args
from webservices import docs
from webservices import schemas
from webservices import utils
from webservices.common import models
from webservices.common.views import ApiResource


@doc(
    tags=['audit'],
    description=docs.AUDIT_SEARCH,
)
class Category(ApiResource):
    model = models.Category
    schema = schemas.CategorySchema
    page_schema = schemas.CategoryPageSchema

    filter_multi_fields = [
        ('category_id', model.category_id),
        # ('tier', model.tier),
    ]
    filter_fulltext_fields = [
        ('category_name', model.category_name),
    ]
    query_options = [
        sa.orm.joinedload(models.Category.sub_category),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.Category,
            args.make_sort_args(
                default='category_name',
                # validator=args.IndexValidator(
                #     models.FindingIssueCategory),
            ),
        )

    @property
    def index_column(self):
        return self.model.category_id

@doc(
    tags=['audit'],
    description=docs.AUDIT_SEARCH,
)
class AuditCaseView(ApiResource):
    model = models.AuditCase
    schema = schemas.AuditCaseSchema
    page_schema = schemas.AuditCasePageSchema

    filter_multi_fields = [
        ('audit_case_id', model.audit_case_id),
        ('cycle', model.cycle),
        ('committee_id', model.committee_id),
        # ('committee_name', model.committee_name),
        ('committee_designation', model.committee_designation),
        ('committee_type', model.committee_type),
        ('committee_description', model.committee_description),
        ('far_release_date', model.far_release_date),
        ('link_to_report', model.link_to_report),
        ('audit_id', model.audit_id),
        ('candidate_id', model.candidate_id),
        # ('candidate_name', model.candidate_name),
    ]

    filter_range_fields = [
        (('min_election_cycle', 'max_election_cycle'), model.cycle),
    ]

    filter_fulltext_fields = [
        ('committee_name', model.committee_name),
        ('candidate_name', model.candidate_name),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.AuditCase,
            args.make_sort_args(
                default='-cycle',
                # validator=args.IndexValidator(models.AuditCase),
            ),
        )

    @property
    def index_column(self):
        return self.model.audit_case_id
