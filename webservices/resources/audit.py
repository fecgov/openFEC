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
class AuditPrimaryCategoryView(ApiResource):
    model = models.AuditPrimaryCategory
    schema = schemas.AuditPrimaryCategorySchema
    page_schema = schemas.AuditPrimaryCategoryPageSchema

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
            args.auditPrimaryCategory,
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
class AuditCategoryView(ApiResource):
    model = models.AuditCategory
    schema = schemas.AuditCategorySchema
    page_schema = schemas.AuditCategoryPageSchema
    contains_joined_load = True

    filter_multi_fields = [
        ('primary_category_id', model.primary_category_id),
        ('tier', model.tier),
    ]
    filter_fulltext_fields = [
        ('primary_category_name', model.primary_category_name),
    ]
    query_options = [
        sa.orm.joinedload(models.AuditCategory.sub_category_list),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.auditCategory,
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
    contains_joined_load = True

    filter_multi_fields = [
        ('audit_case_id', model.audit_case_id),
        ('cycle', model.cycle),
        ('committee_designation', model.committee_designation),
        ('committee_type', model.committee_type),
        ('committee_description', model.committee_description),
        ('far_release_date', model.far_release_date),
        ('link_to_report', model.link_to_report),
        ('audit_id', model.audit_id),
        ('committee_id', model.committee_id),
        ('candidate_id', model.candidate_id),
    ]

    filter_match_fields = [
        ('primary_category_id', model.primary_category_id),
        ('sub_category_id', model.sub_category_id),
    ]

    filter_range_fields = [
        (('min_election_cycle', 'max_election_cycle'), model.cycle),
    ]

# q---committee name typeahead
# qq---candidate name typeadead
    filter_fulltext_fields = [
        ('q', models.AuditCommitteeSearch.fulltxt),
        ('qq', models.AuditCandidateSearch.fulltxt),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.auditCase,
            args.make_multi_sort_args(
                default=['-cycle', 'committee_name', ]
            ),
        )

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        if kwargs.get('q'):
            query = query.join(
                models.AuditCommitteeSearch,
                models.AuditCase.committee_id == models.AuditCommitteeSearch.id,
            ).distinct()

        if kwargs.get('qq'):
            query = query.join(
                models.AuditCandidateSearch,
                models.AuditCase.candidate_id == models.AuditCandidateSearch.id,
            ).distinct()

        return query

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
        query = models.db.select(models.AuditCandidateSearch.id, models.AuditCandidateSearch.name)
        query = filters.filter_fulltext(query, kwargs, self.filter_fulltext_fields)
        query = query.order_by(
            sa.desc(models.AuditCandidateSearch.id)
        ).limit(20)
        return {'results': models.db.session.execute(query).all()}


@doc(
    tags=['audit'],
    description=docs.NAME_SEARCH,
)
class AuditCommitteeNameSearch(utils.Resource):
    """endpoint audit/search/name/committees"""

    filter_fulltext_fields = [
        ('q', models.AuditCommitteeSearch.fulltxt),
    ]

    @use_kwargs(args.names)
    @marshal_with(schemas.AuditCommitteeSearchListSchema())
    def get(self, **kwargs):
        query = models.db.select(models.AuditCommitteeSearch.id, models.AuditCommitteeSearch.name)
        query = filters.filter_fulltext(query, kwargs, self.filter_fulltext_fields)
        query = query.order_by(
            sa.desc(models.AuditCommitteeSearch.id)
        ).limit(20)
        return {'results': models.db.session.execute(query).all()}
