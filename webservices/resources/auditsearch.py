from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


@doc(tags=['audit-finding'], description='Search Audit Findings and Issues can be associated with a committe',)
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

@doc(tags=['audit-search'], 
   description='This is a search tool for Final Audit Reports approved by the Commission since inception. The search can be based on information about the audited committee (Name, FEC ID Number, Type, Election Cycle) or the issues covered in the report.',
   )
class AuditSearchView(ApiResource):

    model = models.AuditSearchView
    schema = schemas.AuditSearchViewSchema
    page_schema = schemas.AuditSearchViewPageSchema


    filter_multi_fields = [
        ('finding_id', model.finding_id),
        ('finding', model.finding),
        ('issue_id', model.issue_id),
        ('issue', model.issue),
        ('election_cycle', model.election_cycle),
        ('committee_id', model.committee_id),
        ('committee_name', model.committee_name),
        ('committee_designation', model.committee_designation),
        ('committee_type', model.committee_type),
        ('committee_discription', model.committee_description),
        ('candidate_id', model.candidate_id),
        ('candidate_name', model.candidate_name),
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


