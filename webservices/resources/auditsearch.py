from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


@doc(tags=['audit'], description=doc.AUDIT_FINDING)
class AuditFindingsView(ApiResource):

    model = models.AuditFindingsView
    schema = schemas.AuditFindingsViewSchema
    page_schema = schemas.AuditFindingsViewPageSchema


    filter_multi_fields = [
        ('tier', model.tier),
        ('tier_one_id', model.tier_one_id),
        ('tier_one_finding', model.tier_one_finding),
        ('tier_two_id', model.tier_two_id),
        ('tier_two_finding', model.tier_two_finding),

    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.AuditFindingsView,
            args.make_sort_args(
                validator=args.IndexValidator(models.AuditFindingsView),
            ),
        )

    @property
    def index_column(self):
        return self.model.idx

@doc(tags=['audit'], description=doc.AUDIT_FINDING,)
class AuditSearchView(ApiResource):

    model = models.AuditSearchView
    schema = schemas.AuditSearchViewSchema
    page_schema = schemas.AuditSearchViewPageSchema

    filter_fulltext_fields = [
       ('candidate_name', model.candidate_name),
       ('committee_name', model.committee_name),
    ]
    filter_multi_fields = [
        ('finding_id', model.finding_id),
        ('finding', model.finding),
        ('issue_id', model.issue_id),
        ('issue', model.issue),
        ('election_cycle', model.election_cycle),
        ('committee_id', model.committee_id),
        ('committee_designation', model.committee_designation),
        ('committee_type', model.committee_type),
        ('committee_description', model.committee_description),
        ('candidate_id', model.candidate_id),
     ]
    filter_range_fields = [
       (('min_election_cycle', 'max_election_cycle'), model.election_cycle),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.AuditSearchView,
            args.make_sort_args(
                validator=args.IndexValidator(models.AuditSearchView),
            ),
        )

    @property
    def index_column(self):
        return self.model.finding_id
