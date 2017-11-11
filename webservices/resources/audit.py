from flask_apispec import doc

import sqlalchemy as sa

from webservices import args
from webservices import docs
from webservices import schemas
from webservices import utils
from webservices.common import models
from webservices.common.views import ApiResource

# endpoint: audit-primary-category
@doc(
    tags=['audit'],
    description=docs.AUDIT_PRIMARY_CATEGORIES,
)
class PrimaryCategory(ApiResource):
    model = models.PrimaryCategory
    schema = schemas.PrimaryCategorySchema
    page_schema = schemas.PrimaryCategoryPageSchema

    filter_multi_fields = [
        ('primary_category_id', model.primary_category_id),
        ('tier', model.tier),
    ]
    filter_fulltext_fields = [
        ('primary_category_name', model.primary_category_name),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.PrimaryCategory,
            args.make_sort_args(
                default='primary_category_name',
            ),
        )

    @property
    def index_column(self):
        return self.model.primary_category_id


# endpoint: audit-category
@doc(
    tags=['audit'],
    description=docs.AUDIT_CATEGORIES,
)
class Category(ApiResource):
    model = models.Category
    schema = schemas.CategorySchema
    page_schema = schemas.CategoryPageSchema

    filter_multi_fields = [
        ('primary_category_id', model.primary_category_id),
        ('tier', model.tier),
    ]
    filter_fulltext_fields = [
        ('primary_category_name', model.primary_category_name),
    ]
    query_options = [
        sa.orm.joinedload(models.Category.sub_category_list),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.Category,
            args.make_sort_args(
                default='primary_category_name',
                # validator=args.IndexValidator(
                #     models.FindingIssueCategory),
            ),
        )

    @property
    def index_column(self):
        return self.model.primary_category_id


# endpoint: audit-case
@doc(
    tags=['audit'],
    description=docs.AUDIT_CASE,
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


# endpoint: audit-case/search/<primary_category_id>/<sub_category_id>
@doc(
    tags=['audit'],
    description=docs.AUDIT_CASE_SEARCH,
    params={
        'primary_category_id': {'description': docs.PRIMARY_CATEGORY_ID},
        'sub_category_id': {'description': docs.SUB_CATEGORY_ID},
    },
)
class AuditCaseSearchByCategoryId(ApiResource):
    model = models.AuditCaseSearchByCategoryId
    schema = schemas.AuditCaseSearchByCategoryIdSchema
    page_schema = schemas.AuditCaseSearchByCategoryIdPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.AuditCaseSearchByCategoryId,
            args.make_sort_args(
                default='-cycle',
            ),
        )

    @property
    def index_column(self):
        return self.model.audit_case_id

    def build_query(self, primary_category_id=None, sub_category_id=None, **kwargs):
        query = super().build_query(**kwargs)

        if primary_category_id:
            query = query.filter(models.AuditCaseSearchByCategoryId.primary_category_id == primary_category_id)
        if sub_category_id:
            query = query.filter(models.AuditCaseSearchByCategoryId.sub_category_id == sub_category_id)

        return query
