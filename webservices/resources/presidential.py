from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common import models
from webservices.common.views import ApiResource


@doc(
    tags=['presidential'],
    description=docs.PRESIDENTIAL_BY_CANDIDATE,
)
class PresidentialByCandidateView(ApiResource):

    model = models.PresidentialByCandidate
    schema = schemas.PresidentialByCandidateSchema
    page_schema = schemas.PresidentialByCandidatePageSchema

    filter_multi_fields = [
        ('contributor_state', model.contributor_state),
        ('election_year', model.election_year),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.presidential_by_candidate,
            args.make_sort_args(
                default='-net_receipts',
                validator=args.OptionValidator(['net_receipts'])
            ),
        )

    @property
    def index_column(self):
        return self.model.idx

@doc(
    tags=['presidential'],
    description=docs.PRESIDENTIAL,
)
class PresidentialSummaryView(ApiResource):

    model = models.PresidentialSummary
    schema = schemas.PresidentialSummarySchema
    page_schema = schemas.PresidentialSummaryPageSchema

    filter_fulltext_fields = [
        ('name', model.name_txt),
        ('title', model.title),
    ]

    filter_multi_fields = [
        ('analyst_id', model.analyst_id),
        ('analyst_short_id', model.analyst_short_id),
        ('email', model.email),
        ('telephone_ext', model.telephone_ext),
        ('committee_id', model.committee_id),
    ]

    filter_range_fields = [
        (('min_assignment_update_date', 'max_assignment_update_date'), model.assignment_update_date),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.presidential,
            args.make_sort_args(),
        )

    @property
    def index_column(self):
        return self.model.idx

@doc(
    tags=['presidential'],
    description=docs.PRESIDENTIAL,
)
class PresidentialBySizeView(ApiResource):

    model = models.PresidentialBySize
    schema = schemas.PresidentialBySizeSchema
    page_schema = schemas.PresidentialBySizePageSchema

    filter_fulltext_fields = [
        ('name', model.name_txt),
        ('title', model.title),
    ]

    filter_multi_fields = [
        ('analyst_id', model.analyst_id),
        ('analyst_short_id', model.analyst_short_id),
        ('email', model.email),
        ('telephone_ext', model.telephone_ext),
        ('committee_id', model.committee_id),
    ]

    filter_range_fields = [
        (('min_assignment_update_date', 'max_assignment_update_date'), model.assignment_update_date),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.presidential,
            args.make_sort_args(),
        )

    @property
    def index_column(self):
        return self.model.idx

@doc(
    tags=['presidential'],
    description=docs.PRESIDENTIAL,
)
class PresidentialByStateView(ApiResource):

    model = models.PresidentialByState
    schema = schemas.PresidentialByStateSchema
    page_schema = schemas.PresidentialByStatePageSchema

    filter_multi_fields = [
        ('election_year', model.election_year),
        ('candidate_id', model.candidate_id),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.presidential,
            args.make_sort_args(),
        )

    @property
    def index_column(self):
        return self.model.idx

@doc(
    tags=['presidential'],
    description=docs.PRESIDENTIAL,
)
class PresidentialCoverageView(ApiResource):

    model = models.PresidentialCoverage
    schema = schemas.PresidentialCoverageSchema
    page_schema = schemas.PresidentialCoveragePageSchema

    filter_fulltext_fields = [
        ('name', model.name_txt),
        ('title', model.title),
    ]

    filter_multi_fields = [
        ('analyst_id', model.analyst_id),
        ('analyst_short_id', model.analyst_short_id),
        ('email', model.email),
        ('telephone_ext', model.telephone_ext),
        ('committee_id', model.committee_id),
    ]

    filter_range_fields = [
        (('min_assignment_update_date', 'max_assignment_update_date'), model.assignment_update_date),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.presidential,
            args.make_sort_args(),
        )

    @property
    def index_column(self):
        return self.model.idx
