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
    description=docs.PRESIDENTIAL_BY_SUMMERY,
)
class PresidentialSummaryView(ApiResource):

    model = models.PresidentialSummary
    schema = schemas.PresidentialSummarySchema
    page_schema = schemas.PresidentialSummaryPageSchema

    filter_multi_fields = [
        ('election_year', model.election_year),
        ('candidate_id', model.candidate_id),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.presidential,
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
    description=docs.PRESIDENTIAL_BY_SIZE,
)
class PresidentialBySizeView(ApiResource):

    model = models.PresidentialBySize
    schema = schemas.PresidentialBySizeSchema
    page_schema = schemas.PresidentialBySizePageSchema

    filter_multi_fields = [
        ('election_year', model.election_year),
        ('candidate_id', model.candidate_id),
        ('size', model.size),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.presidential_by_size,
            args.make_sort_args(
                default='size',
                validator=args.OptionValidator(['size'])
            ),
        )

    @property
    def index_column(self):
        return self.model.idx


@doc(
    tags=['presidential'],
    description=docs.PRESIDENTIAL_BY_STATE,
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
            args.make_sort_args(
                default='-contribution_receipt_amount',
                validator=args.OptionValidator(['contribution_receipt_amount'])
            ),
        )

    @property
    def index_column(self):
        return self.model.idx


@doc(
    tags=['presidential'],
    description=docs.PRESIDENTIAL_BY_COVERAGE,
)
class PresidentialCoverageView(ApiResource):

    model = models.PresidentialCoverage
    schema = schemas.PresidentialCoverageSchema
    page_schema = schemas.PresidentialCoveragePageSchema

    filter_multi_fields = [
        ('election_year', model.election_year),
        ('candidate_id', model.candidate_id),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.presidential,
            args.make_sort_args(
                default='candidate_id',
                validator=args.OptionValidator(['candidate_id'])
            ),
        )

    @property
    def index_column(self):
        return self.model.idx
