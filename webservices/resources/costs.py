from flask_apispec import doc

from webservices import args
from webservices import docs
from webservices import utils
from webservices import schemas

from webservices.common import models
from webservices.common.views import ApiResource


# used for endpoint:'/communication_costs/'
# under tag: communication cost
# Ex: http://127.0.0.1:5000/v1/communication_costs/
@doc(
    tags=['communication cost'],
    description=docs.COMMUNICATION_COST,
)
class CommunicationCostView(ApiResource):

    model = models.CommunicationCost
    schema = schemas.CommunicationCostSchema
    page_schema = schemas.CommunicationCostPageSchema

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.itemized,
            args.communication_cost,
            args.make_sort_args(
                validator=args.IndexValidator(models.CommunicationCost),
            ),
        )

    @property
    def index_column(self):
        return self.model.sub_id

    filter_multi_fields = [
        ('image_number', models.CommunicationCost.image_number),
        ('committee_id', models.CommunicationCost.committee_id),
        ('candidate_id', models.CommunicationCost.candidate_id),
        ('support_oppose_indicator', models.CommunicationCost.support_oppose_indicator),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.CommunicationCost.transaction_date),
        (('min_amount', 'max_amount'), models.CommunicationCost.transaction_amount),
        (('min_image_number', 'max_image_number'), models.CommunicationCost.image_number),
    ]


# used for endpoint:'/electioneering/'
# under tag: electioneering
# Ex: http://127.0.0.1:5000/v1/electioneering/
@doc(
    tags=['electioneering'],
    description=docs.ELECTIONEERING,
)
class ElectioneeringView(ApiResource):

    model = models.Electioneering
    schema = schemas.ElectioneeringSchema
    page_schema = schemas.ElectioneeringPageSchema

    filter_fulltext_fields = [
        ('disbursement_description', models.Electioneering.purpose_description_text),
    ]

    @property
    def args(self):
        return utils.extend(
            args.paging,
            args.electioneering,
            args.make_seek_args(),
            args.make_sort_args(
                validator=args.IndexValidator(models.Electioneering),
            ),
        )

    @property
    def index_column(self):
        return self.model.idx

    filter_multi_fields = [
        ('report_year', models.Electioneering.report_year),
        ('committee_id', models.Electioneering.committee_id),
        ('candidate_id', models.Electioneering.candidate_id),
        ('beginning_image_number', models.Electioneering.beginning_image_number),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.Electioneering.disbursement_date),
        (('min_amount', 'max_amount'), models.Electioneering.disbursement_amount),
    ]
