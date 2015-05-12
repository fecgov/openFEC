from math import ceil

from sqlalchemy import desc
from sqlalchemy.orm.exc import NoResultFound
from flask.ext.restful import Resource, reqparse, fields, marshal, inputs

from webservices.common.models import db, BaseModel
from webservices.common.util import merge_dicts, Pagination
from webservices.resources.committees import Committee


class CommitteeTotals(BaseModel):
    __abstract__ = True

    committee_id = db.Column(db.String(10))
    cycle = db.Column(db.Integer)
    committee_type = db.Column(db.String(1))

    offsets_to_operating_expenditures = db.Column(db.Integer)
    political_party_committee_contributions = db.Column(db.Integer)
    other_disbursements = db.Column(db.Integer)
    other_political_committee_contributions = db.Column(db.Integer)
    operating_expenditures = db.Column(db.Integer)
    disbursements = db.Column(db.Integer)
    contributions = db.Column(db.Integer)
    contribution_refunds = db.Column(db.Integer)
    receipts = db.Column(db.Integer)
    coverage_start_date = db.Column(db.DateTime())
    coverage_end_date = db.Column(db.DateTime())
    net_contributions = db.Column(db.Integer)
    net_operating_expenditures = db.Column(db.Integer)


class CommitteeTotalsPacOrParty(CommitteeTotals):
    __tablename__ = 'ofec_totals_pacs_parties_mv'

    all_loans_received = db.Column(db.Integer)
    coordinated_expenditures_by_party_committee = db.Column(db.Integer)
    fed_candidate_committee_contributions = db.Column(db.Integer)
    fed_candidate_contribution_refunds = db.Column(db.Integer)
    fed_disbursements = db.Column(db.Integer)
    fed_election_activity = db.Column(db.Integer)
    fed_operating_expenditures = db.Column(db.Integer)
    fed_receipts = db.Column(db.Integer)
    independent_expenditures = db.Column(db.Integer)
    individual_contribution_refunds = db.Column(db.Integer)
    individual_itemized_contributions = db.Column(db.Integer)
    individual_unitemized_contributions = db.Column(db.Integer)
    loan_repayments_made = db.Column(db.Integer)
    loan_repayments_received = db.Column(db.Integer)
    loans_made = db.Column(db.Integer)
    non_allocated_fed_election_activity = db.Column(db.Integer)
    nonfed_transfers = db.Column(db.Integer)
    other_fed_operating_expenditures = db.Column(db.Integer)
    other_fed_receipts = db.Column(db.Integer)
    other_political_committee_contribution_refunds = db.Column(db.Integer)
    political_party_committee_contribution_refunds = db.Column(db.Integer)
    shared_fed_activity = db.Column(db.Integer)
    shared_fed_activity_nonfed = db.Column(db.Integer)
    shared_fed_operating_expenditures = db.Column(db.Integer)
    shared_nonfed_operating_expenditures = db.Column(db.Integer)
    transfers_from_affiliated_party = db.Column(db.Integer)
    transfers_from_nonfed_account = db.Column(db.Integer)
    transfers_from_nonfed_levin = db.Column(db.Integer)
    transfers_to_affiliated_committee = db.Column(db.Integer)


class CommitteeTotalsPresidential(CommitteeTotals):
    __tablename__ = 'ofec_totals_presidential_mv'

    candidate_contribution = db.Column(db.Integer)
    exempt_legal_accounting_disbursement = db.Column(db.Integer)
    federal_funds = db.Column(db.Integer)
    fundraising_disbursements = db.Column(db.Integer)
    individual_contributions = db.Column(db.Integer)
    loan_repayments_made = db.Column(db.Integer)
    loans_received = db.Column(db.Integer)
    loans_received_from_candidate = db.Column(db.Integer)
    offsets_to_fundraising_expenditures = db.Column(db.Integer)
    offsets_to_legal_accounting = db.Column(db.Integer)
    other_loans_received = db.Column(db.Integer)
    other_receipts = db.Column(db.Integer)
    refunded_other_political_committee_contributions = db.Column(db.Integer)
    refunded_political_party_committee_contributions = db.Column(db.Integer)
    refunded_individual_contributions = db.Column(db.Integer)
    repayments_loans_made_by_candidate = db.Column(db.Integer)
    repayments_other_loans = db.Column(db.Integer)
    transfers_from_affiliated_committee = db.Column(db.Integer)
    transfers_to_other_authorized_committee = db.Column(db.Integer)


class CommitteeTotalsHouseOrSenate(CommitteeTotals):
    __tablename__ = 'ofec_totals_house_senate_mv'

    all_other_loans = db.Column(db.Integer)
    candidate_contribution = db.Column(db.Integer)
    individual_contributions = db.Column(db.Integer)
    individual_itemized_contributions = db.Column(db.Integer)
    individual_unitemized_contributions = db.Column(db.Integer)
    loan_repayments = db.Column(db.Integer)
    loan_repayments_candidate_loans = db.Column(db.Integer)
    loan_repayments_other_loans = db.Column(db.Integer)
    loans = db.Column(db.Integer)
    loans_made_by_candidate = db.Column(db.Integer)
    other_receipts = db.Column(db.Integer)
    refunded_individual_contributions = db.Column(db.Integer)
    refunded_other_political_committee_contributions = db.Column(db.Integer)
    refunded_political_party_committee_contributions = db.Column(db.Integer)
    transfers_from_other_authorized_committee = db.Column(db.Integer)
    transfers_to_other_authorized_committee = db.Column(db.Integer)


# output format for flask-restful marshaling
common_fields = {
    'committee_id': fields.String,
    'cycle': fields.Integer,
    'offsets_to_operating_expenditures': fields.Integer,
    'political_party_committee_contributions': fields.Integer,
    'other_disbursements': fields.Integer,
    'other_political_committee_contributions': fields.Integer,
    'operating_expenditures': fields.Integer,
    'disbursements': fields.Integer,
    'contributions': fields.Integer,
    'contribution_refunds': fields.Integer,
    'receipts': fields.Integer,
    'coverage_start_date': fields.DateTime,
    'coverage_end_date': fields.DateTime,
    'net_contributions': fields.Integer,
    'net_operating_expenditures': fields.Integer,
}
pac_party_fields = {
    'all_loans_received': fields.Integer,
    'coordinated_expenditures_by_party_committee': fields.Integer,
    'fed_candidate_committee_contributions': fields.Integer,
    'fed_candidate_contribution_refunds': fields.Integer,
    'fed_disbursements': fields.Integer,
    'fed_election_activity': fields.Integer,
    'fed_operating_expenditures': fields.Integer,
    'fed_receipts': fields.Integer,
    'independent_expenditures': fields.Integer,
    'individual_contribution_refunds': fields.Integer,
    'individual_itemized_contributions': fields.Integer,
    'individual_unitemized_contributions': fields.Integer,
    'loan_repayments_made': fields.Integer,
    'loan_repayments_received': fields.Integer,
    'loans_made': fields.Integer,
    'non_allocated_fed_election_activity': fields.Integer,
    'nonfed_transfers': fields.Integer,
    'other_fed_operating_expenditures': fields.Integer,
    'other_fed_receipts': fields.Integer,
    'other_political_committee_contribution_refunds': fields.Integer,
    'political_party_committee_contribution_refunds': fields.Integer,
    'shared_fed_activity': fields.Integer,
    'shared_fed_activity_nonfed': fields.Integer,
    'shared_fed_operating_expenditures': fields.Integer,
    'shared_nonfed_operating_expenditures': fields.Integer,
    'transfers_from_affiliated_party': fields.Integer,
    'transfers_from_nonfed_account': fields.Integer,
    'transfers_from_nonfed_levin': fields.Integer,
    'transfers_to_affiliated_committee': fields.Integer,
}
house_senate_fields = {
    'all_other_loans': fields.Integer,
    'candidate_contribution': fields.Integer,
    'individual_contributions': fields.Integer,
    'individual_itemized_contributions': fields.Integer,
    'individual_unitemized_contributions': fields.Integer,
    'loan_repayments': fields.Integer,
    'loan_repayments_candidate_loans': fields.Integer,
    'loan_repayments_other_loans': fields.Integer,
    'loans': fields.Integer,
    'loans_made_by_candidate': fields.Integer,
    'other_receipts': fields.Integer,
    'refunded_individual_contributions': fields.Integer,
    'refunded_other_political_committee_contributions': fields.Integer,
    'refunded_political_party_committee_contributions': fields.Integer,
    'transfers_from_other_authorized_committee': fields.Integer,
    'transfers_to_other_authorized_committee': fields.Integer,
}
presidential_fields = {
    'candidate_contribution': fields.Integer,
    'exempt_legal_accounting_disbursement': fields.Integer,
    'individual_contributions': fields.Integer,
    'loan_repayments_made': fields.Integer,
    'loans_received_from_candidate': fields.Integer,
    'offsets_to_fundraising_expenditures': fields.Integer,
    'offsets_to_legal_accounting': fields.Integer,
    'other_loans_received': fields.Integer,
    'other_receipts': fields.Integer,
    'repayments_loans_made_by_candidate': fields.Integer,
    'refunded_individual_contributions': fields.Integer,
    'refunded_other_political_committee_contributions': fields.Integer,
    'refunded_political_party_committee_contributions': fields.Integer,
    'transfers_from_affiliated_committee': fields.Integer,
    'transfers_to_other_authorized_committee': fields.Integer,
}
pagination_fields = {
    'per_page': fields.Integer,
    'page': fields.Integer,
    'count': fields.Integer,
    'pages': fields.Integer,
}


totals_model_map = {
    'P': (CommitteeTotalsPresidential, presidential_fields),
    'H': (CommitteeTotalsHouseOrSenate, house_senate_fields),
    'S': (CommitteeTotalsHouseOrSenate, house_senate_fields),
    'default': (CommitteeTotalsPacOrParty, pac_party_fields),
}


class TotalsView(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument('page', type=inputs.natural, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=inputs.natural, default=20, help='The number of results returned per page. Defaults to 20.')
    parser.add_argument('cycle', type=int, action='append', help='Two-year election cycle in which a candidate runs for office')
    parser.add_argument('fields', type=str, help='Choose the fields that are displayed')

    def get(self, **kwargs):
        committee_id = kwargs['id']
        args = self.parser.parse_args(strict=True)

        # pagination
        page_num = args.get('page', 1)
        per_page = args.get('per_page', 20)
        page_data = Pagination(page_num, per_page, 1)

        # TODO(jmcarp) Handle multiple results better
        committee = Committee.query.filter_by(committee_id=committee_id).first()

        totals_class, specific_fields = totals_model_map.get(
            committee.committee_type,
            totals_model_map['default'],
        )
        results_fields = merge_dicts(common_fields, specific_fields)

        totals = self.get_totals(committee_id, totals_class, args, page_num, per_page)

        data = {
            'api_version': '0.2',
            'pagination': page_data.as_json(),
            'results': totals
        }

        totals_view_fields = {
            'api_version': fields.Fixed(1),
            'pagination': fields.Nested(pagination_fields),
            'results': fields.Nested(results_fields),
        }

        return marshal(data, totals_view_fields)

    def get_totals(self, committee_id, totals_class, args, page_num, per_page):

        totals = totals_class.query.filter_by(committee_id=committee_id)

        if args['cycle']:
            totals = totals.filter(totals_class.cycle.in_(args['cycle']))

        totals = totals.order_by(desc(totals_class.cycle))
        return totals.paginate(page_num, per_page, True).items
