from flask.ext.restful import Resource, reqparse, fields, marshal, inputs
from math import ceil
from webservices.common.models import db
from webservices.common.util import default_year, merge_dicts
from webservices.resources.committees import Committee
from sqlalchemy.orm.exc import NoResultFound


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
}
pac_party_fields = {
    'committee_id': fields.String,
    'cycle': fields.Integer,
    'all_loans_received': fields.Integer,
    'coordinated_expenditures_by_party_committee': fields.Integer,
    'fed_candidate_committee_contributions': fields.Integer,
    'fed_candidate_contribution_refunds': fields.Integer,
    'fed_disbursements': fields.Integer,
    'fed_elect_activity': fields.Integer,
    'fed_operating_expenditures': fields.Integer,
    'fed_receipts': fields.Integer,
    'independent_expenditures': fields.Integer,
    'individual_contribution_refunds': fields.Integer,
    'individual_itemized_contributions': fields.Integer,
    'individual_unitemized_contributions': fields.Integer,
    'loan_repayments_made': fields.Integer,
    'loan_repayments_received': fields.Integer,
    'loans_made': fields.Integer,
    'net_contributions': fields.Integer,
    'non_allocated_fed_election_activity': fields.Integer,
    'nonfed_transfers': fields.Integer,
    'other_fed_operating_expenditures': fields.Integer,
    'other_fed_receipts': fields.Integer,
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
    'refunds_individual_contributions': fields.Integer,
    'refunds_other_political_committee_contributions': fields.Integer,
    'refunds_political_party_committee_contributions': fields.Integer,
    'transfers_from_other_authorized_committee': fields.Integer,
    'transfers_to_other_authorized_committee': fields.Integer,
}
presidential_fields = {
    'candidate_contribution': fields.Integer,
    'exempt_legal_accounting_disbursement': fields.Integer,
    'individual_contributions': fields.Integer,
    'loan_repayments_made': fields.Integer,
    'loans_received_from_candidate': fields.Integer,
    'offsets_to_fundraising_expenses': fields.Integer,
    'offsets_to_legal_accounting': fields.Integer,
    'other_loans_received': fields.Integer,
    'other_receipts': fields.Integer,
    'refunded_individual_contributions': fields.Integer,
    'refunded_other_political_committee_contributions': fields.Integer,
    'refunded_political_party_committee_contributions': fields.Integer,
    'transfer_from_affiliated_committee': fields.Integer,
    'transfer_to_other_authorized_committee': fields.Integer,
}
pagination_fields = {
    'per_page': fields.Integer,
    'page': fields.Integer,
    'count': fields.Integer,
    'pages': fields.Integer,
}


class TotalsView(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument('page', type=inputs.natural, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=inputs.natural, default=20, help='The number of results returned per page. Defaults to 20.')
    parser.add_argument('year', type=str, default=default_year(), dest='cycle', help="Year in which a candidate runs for office")
    parser.add_argument('fields', type=str, help='Choose the fields that are displayed')

    def get(self, **kwargs):
        committee_id = kwargs['id']
        args = self.parser.parse_args(strict=True)

        # pagination
        page_num = args.get('page', 1)
        per_page = args.get('per_page', 20)
        count = 1

        committee = Committee.query.filter_by(committee_id=committee_id).one()

        if committee.committee_type == 'P':
            totals_class = CommitteeTotalsPresidential
            results_fields = merge_dicts(common_fields, presidential_fields)
        elif committee.committee_type in ['H', 'S']:
            totals_class = CommitteeTotalsHouseOrSenate
            results_fields = merge_dicts(common_fields, house_senate_fields)
        else:
            totals_class = CommitteeTotalsPacOrParty
            results_fields = merge_dicts(common_fields, pac_party_fields)

        totals = self.get_totals(committee_id, totals_class, args, page_num, per_page)

        data = {
            'api_version': '0.2',
            'pagination': {
                'page': page_num,
                'per_page': per_page,
                'count': count,
                'pages': ceil(count / per_page),
            },
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

        if args['cycle'] != '*':
            totals = totals.filter(totals_class.cycle.in_(args['cycle'].split(',')))

        totals = totals.order_by(totals_class.cycle)
        return totals.paginate(page_num, per_page, True).items


class CommitteeTotalsPacOrParty(db.Model):
    committee_id = db.Column(db.String(10), primary_key=True)
    cycle = db.Column(db.Integer, primary_key=True)
    committee_type = db.Column(db.String(1))
    coverage_start_date = db.Column(db.DateTime())
    coverage_end_date = db.Column(db.DateTime())
    all_loans_received = db.Column(db.Integer)
    contribution_refunds = db.Column(db.Integer)
    contributions = db.Column(db.Integer)
    coordinated_expenditures_by_party_committee = db.Column(db.Integer)
    disbursements = db.Column(db.Integer)
    fed_candidate_committee_contributions = db.Column(db.Integer)
    fed_candidate_contribution_refunds = db.Column(db.Integer)
    fed_disbursements = db.Column(db.Integer)
    fed_elect_activity = db.Column(db.Integer)
    fed_operating_expenditures = db.Column(db.Integer)
    fed_receipts = db.Column(db.Integer)
    independent_expenditures = db.Column(db.Integer)
    individual_contribution_refunds = db.Column(db.Integer)
    individual_itemized_contributions = db.Column(db.Integer)
    individual_unitemized_contributions = db.Column(db.Integer)
    loan_repayments_made = db.Column(db.Integer)
    loan_repayments_received = db.Column(db.Integer)
    loans_made = db.Column(db.Integer)
    net_contributions = db.Column(db.Integer)
    non_allocated_fed_election_activity = db.Column(db.Integer)
    nonfed_transfers = db.Column(db.Integer)
    offsets_to_operating_expenditures = db.Column(db.Integer)
    operating_expenditures = db.Column(db.Integer)
    other_disbursements = db.Column(db.Integer)
    other_fed_operating_expenditures = db.Column(db.Integer)
    other_fed_receipts = db.Column(db.Integer)
    other_political_committee_contributions = db.Column(db.Integer)
    political_party_committee_contributions = db.Column(db.Integer)
    receipts = db.Column(db.Integer)
    shared_fed_activity = db.Column(db.Integer)
    shared_fed_activity_nonfed = db.Column(db.Integer)
    shared_fed_operating_expenditures = db.Column(db.Integer)
    shared_nonfed_operating_expenditures = db.Column(db.Integer)
    transfers_from_affiliated_party = db.Column(db.Integer)
    transfers_from_nonfed_account = db.Column(db.Integer)
    transfers_from_nonfed_levin = db.Column(db.Integer)
    transfers_to_affiliated_committee = db.Column(db.Integer)

    __tablename__ = 'ofec_totals_pacs_parties_mv'


class CommitteeTotalsPresidential(db.Model):
    committee_id = db.Column(db.String(10), primary_key=True)
    cycle = db.Column(db.Integer, primary_key=True)
    committee_type = db.Column(db.String(1))
    coverage_start_date = db.Column(db.DateTime())
    coverage_end_date = db.Column(db.DateTime())
    candidate_contribution = db.Column(db.Integer)
    contribution_refunds = db.Column(db.Integer)
    contributions = db.Column(db.Integer)
    disbursements = db.Column(db.Integer)
    exempt_legal_accounting_disbursement = db.Column(db.Integer)
    federal_funds = db.Column(db.Integer)
    fundraising_disbursements = db.Column(db.Integer)
    individual_contributions = db.Column(db.Integer)
    loan_repayments_made = db.Column(db.Integer)
    loans_received = db.Column(db.Integer)
    loans_received_from_candidate = db.Column(db.Integer)
    offsets_to_fundraising_expenses = db.Column(db.Integer)
    offsets_to_legal_accounting = db.Column(db.Integer)
    offsets_to_operating_expenditures = db.Column(db.Integer)
    operating_expenditures = db.Column(db.Integer)
    other_disbursements = db.Column(db.Integer)
    other_loans_received = db.Column(db.Integer)
    other_political_committee_contributions = db.Column(db.Integer)
    other_receipts = db.Column(db.Integer)
    political_party_committee_contributions = db.Column(db.Integer)
    receipts = db.Column(db.Integer)
    refunded_other_political_committee_contributions = db.Column(db.Integer)
    refunded_political_party_committee_contributions = db.Column(db.Integer)
    refunded_individual_contributions = db.Column(db.Integer)
    repayments_loans_made_by_candidate = db.Column(db.Integer)
    repayments_other_loans = db.Column(db.Integer)
    transfer_from_affiliated_committee = db.Column(db.Integer)
    transfer_to_other_authorized_committee = db.Column(db.Integer)

    __tablename__ = 'ofec_totals_presidential_mv'


class CommitteeTotalsHouseOrSenate(db.Model):
    committee_id = db.Column(db.String(10), primary_key=True)
    cycle = db.Column(db.Integer, primary_key=True)
    committee_type = db.Column(db.String(1))
    coverage_start_date = db.Column(db.DateTime())
    coverage_end_date = db.Column(db.DateTime())
    all_other_loans = db.Column(db.Integer)
    candidate_contribution = db.Column(db.Integer)
    contribution_refunds = db.Column(db.Integer)
    contributions = db.Column(db.Integer)
    disbursements = db.Column(db.Integer)
    individual_contributions = db.Column(db.Integer)
    individual_itemized_contributions = db.Column(db.Integer)
    individual_unitemized_contributions = db.Column(db.Integer)
    loan_repayments = db.Column(db.Integer)
    loan_repayments_candidate_loans = db.Column(db.Integer)
    loan_repayments_other_loans = db.Column(db.Integer)
    loans = db.Column(db.Integer)
    loans_made_by_candidate = db.Column(db.Integer)
    offsets_to_operating_expenditures = db.Column(db.Integer)
    operating_expenditures = db.Column(db.Integer)
    other_disbursements = db.Column(db.Integer)
    other_political_committee_contributions = db.Column(db.Integer)
    other_receipts = db.Column(db.Integer)
    political_party_committee_contributions = db.Column(db.Integer)
    receipts = db.Column(db.Integer)
    refunds_individual_contributions = db.Column(db.Integer)
    refunds_other_political_committee_contributions = db.Column(db.Integer)
    refunds_political_party_committee_contributions = db.Column(db.Integer)
    transfers_from_other_authorized_committee = db.Column(db.Integer)
    transfers_to_other_authorized_committee = db.Column(db.Integer)

    __tablename__ = 'ofec_totals_house_senate_mv'
