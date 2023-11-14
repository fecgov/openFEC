from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas
from webservices.common.views import ApiResource
from webservices.common import models


@doc(
    tags=["filings"],
    description=docs.FILINGS,
    params={
        "candidate_id": {"description": docs.CANDIDATE_ID},
        "committee_id": {"description": docs.COMMITTEE_ID},
    },
)
class BaseFilings(ApiResource):

    model = models.Filings
    schema = schemas.FilingsSchema
    page_schema = schemas.FilingsPageSchema

    filter_multi_fields = [
        ("amendment_indicator", models.Filings.amendment_indicator),
        ("beginning_image_number", models.Filings.beginning_image_number),
        ("committee_type", models.Filings.committee_type),
        ("cycle", models.Filings.cycle),
        ("document_type", models.Filings.document_type),
        ("file_number", models.Filings.file_number),
        ("form_category", models.Filings.form_category),
        ("form_type", models.Filings.form_type),
        ("office", models.Filings.office),
        ("party", models.Filings.party),
        ("primary_general_indicator", models.Filings.primary_general_indicator),
        ("report_type", models.Filings.report_type),
        ("report_year", models.Filings.report_year),
        ("request_type", models.Filings.request_type),
        ("state", models.Filings.state),
    ]

    filter_range_fields = [
        (("min_receipt_date", "max_receipt_date"), models.Filings.receipt_date),
    ]

    filter_match_fields = [
        ("filer_type", models.Filings.means_filed),
        ("is_amended", models.Filings.is_amended),
        ("most_recent", models.Filings.most_recent),
    ]

    @property
    def args(self):
        """
        Place the sort argument in a list.
        The api will return a 422 status code if it's not in a list
        (list is needed because multisort is used)
        """
        default_sort = ["-receipt_date"]
        return utils.extend(
            args.paging,
            args.filings,
            args.make_multi_sort_args(
                default=default_sort,
                validator=args.IndicesValidator(self.model)
            ),
        )

    def build_query(self, **kwargs):
        if "RFAI" in kwargs.get("form_type", []):
            # Add FRQ types if RFAI was requested
            kwargs.get("form_type").append("FRQ")
        query = super().build_query(**kwargs)
        return query


# used for endpoints:
# `/committee/<committee_id>/filings/`
# `/candidate/<candidate_id>/filings/`
#  under tag: filings
# Ex: http://127.0.0.1:5000/v1/committee/C00724070/filings/
# http://127.0.0.1:5000/v1/candidate/H2MN07162/filings/
class FilingsView(BaseFilings):

    def build_query(self, committee_id=None, candidate_id=None, **kwargs):
        query = super().build_query(**kwargs)
        if committee_id:
            committee_id = committee_id.upper()
            utils.check_committee_id(committee_id)
            query = query.filter(models.Filings.committee_id == committee_id)
        if candidate_id:
            candidate_id = candidate_id.upper()
            utils.check_candidate_id(candidate_id)
            query = query.filter(models.Filings.candidate_id == candidate_id)
        return query


# used for endpoint:`/filings/`
# under tag: filing
# Ex1: http://127.0.0.1:5000/v1/filings/?q_filer=san
# Ex2: http://127.0.0.1:5000/v1/filings/?candidate_id=H8TX10094
class FilingsList(BaseFilings):

    filter_multi_fields = BaseFilings.filter_multi_fields + [
        ("committee_id", models.Filings.committee_id),
        ("candidate_id", models.Filings.candidate_id),
    ]
    filter_fulltext_fields = [("q_filer", models.Filings.filer_name_text), ]

    @property
    def args(self):
        return utils.extend(super().args, args.entities)


# used for endpoint:/efile/filings/
# under tag: efiling
# Ex: http://127.0.0.1:5000/v1/efile/filings/?filer_name_text=san
@doc(
    tags=["efiling"],
    description=docs.EFILE_FILES,
)
class EFilingsView(ApiResource):

    model = models.EFilings
    schema = schemas.EFilingsSchema
    page_schema = schemas.EFilingsPageSchema

    filter_multi_fields = [
        ("file_number", models.EFilings.file_number),
        ("committee_id", models.EFilings.committee_id),
        ("form_type", models.EFilings.form_type),
    ]
    filter_range_fields = [
        (("min_receipt_date", "max_receipt_date"), models.EFilings.filed_date),
    ]
    filter_fulltext_fields = [
        ("q_filer", models.CommitteeSearch.fulltxt)
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.efilings,
            args.make_sort_args(
                default="-receipt_date",
                validator=args.IndexValidator(self.model)
            ),
        )

    def build_query(self, **kwargs):
        if kwargs.get("form_type"):
            original_form_type_values = kwargs["form_type"]
            new_form_type_values = []

            for value in original_form_type_values:
                new_form_type_values.extend([f"{value}{suffix}" for suffix in ("", "N", "A", "T")])
                kwargs["form_type"] = new_form_type_values

        query = super().build_query(**kwargs)

        if kwargs.get("q_filer"):
            query = query.join(
                models.CommitteeSearch,
                self.model.committee_id == models.CommitteeSearch.id,
            ).distinct()

        return query

    @property
    def index_column(self):
        return self.model.file_number
