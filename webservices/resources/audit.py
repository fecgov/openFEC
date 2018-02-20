from flask_apispec import doc, marshal_with

import sqlalchemy as sa

from webservices import args
from webservices import docs
from webservices import schemas
from webservices import utils
from webservices.common import models
from webservices.common.views import ApiResource
from webservices import filters
from webservices.utils import use_kwargs


# endpoint: audit-primary-category
@doc(
    tags=['audit'],
    description=docs.AUDIT_PRIMARY_CATEGORY,
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
    description=docs.AUDIT_CATEGORY,
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
        ('primary_category_id', model.primary_category_id),
        ('sub_category_id', model.sub_category_id),
        ('audit_case_id', model.audit_case_id),
        ('cycle', model.cycle),
        ('committee_designation', model.committee_designation),
        ('committee_type', model.committee_type),
        ('committee_description', model.committee_description),
        ('far_release_date', model.far_release_date),
        ('link_to_report', model.link_to_report),
        ('audit_id', model.audit_id),
    ]

    filter_range_fields = [
        (('min_election_cycle', 'max_election_cycle'), model.cycle),
    ]

    filter_fulltext_fields = [
        ('committee_name', model.committee_name),
        ('committee_id', model.committee_id),
        ('candidate_name', model.candidate_name),
        ('candidate_id', model.candidate_id),
    ]

    # @use_kwargs(
    #     args.make_multi_sort_args(default=['-cycle', 'committee_name'])
    # )
    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.AuditCase,
            args.make_multi_sort_args(
                default=['-cycle', 'committee_name', ]
            ),
        )

    @property
    def index_column(self):
        return self.model.idx


# endpoint audit/search/name/candidates
@doc(
    tags=['audit'],
    description=docs.NAME_SEARCH,
)
class AuditCandidateNameSearch(utils.Resource):

    filter_fulltext_fields = [
        ('q', models.AuditCandidateSearch.fulltxt),
    ]

    @use_kwargs(args.names)
    @marshal_with(schemas.AuditCandidateSearchListSchema())
    def get(self, **kwargs):
        query = filters.filter_fulltext(models.AuditCandidateSearch.query, kwargs, self.filter_fulltext_fields)
        query = query.order_by(
            sa.desc(models.AuditCandidateSearch.id)
        ).limit(20)
        return {'results': query.all()}

# endpoint audit/search/name/committees
@doc(
    tags=['audit'],
    description=docs.NAME_SEARCH,
)
class AuditCommitteeNameSearch(utils.Resource):

    filter_fulltext_fields = [
        ('q', models.AuditCommitteeSearch.fulltxt),
    ]

    @use_kwargs(args.names)
    @marshal_with(schemas.AuditCommitteeSearchListSchema())
    def get(self, **kwargs):
        query = filters.filter_fulltext(models.AuditCommitteeSearch.query, kwargs, self.filter_fulltext_fields)
        query = query.order_by(
            sa.desc(models.AuditCommitteeSearch.id)
        ).limit(20)
        return {'results': query.all()}
