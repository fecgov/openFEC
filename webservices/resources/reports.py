from flask.ext.restful import Resource, reqparse, fields, marshal, inputs
from math import ceil
from webservices.common.models import db
from webservices.common.util import default_year, merge_dicts
from webservices.resources.committees import Committee
from sqlalchemy import desc


# output format for flask-restful marshaling
common_fields = {
    'beginning_image_number': fields.Integer,
    'cash_on_hand_beginning_period': fields.Integer,
    'cash_on_hand_end_period': fields.Integer,
    'committee_id': fields.String,
    'coverage_end_date': fields.DateTime,
    'coverage_start_date': fields.DateTime,
    'cycle': fields.Integer,
    'debts_owed_by_committee': fields.Integer,
    'debts_owed_to_committee': fields.Integer,
    'end_image_number': fields.Integer,
    'expire_date': fields.DateTime,
    'other_disbursements_period': fields.Integer,
    'other_disbursements_ytd': fields.Integer,
    'other_political_committee_contributions_period': fields.Integer,
    'other_political_committee_contributions_ytd': fields.Integer,
    'political_party_committee_contributions_period': fields.Integer,
    'political_party_committee_contributions_ytd': fields.Integer,
    'report_type': fields.String,
    'report_type_full': fields.String,
    'report_year': fields.Integer,
    'total_contribution_refunds_period': fields.Integer,
    'total_contribution_refunds_ytd': fields.Integer,
    'total_contributions_period': fields.Integer,
    'total_contributions_ytd': fields.Integer,
    'total_disbursements_period': fields.Integer,
    'total_disbursements_ytd': fields.Integer,
    'total_receipts_period': fields.Integer,
    'total_receipts_ytd': fields.Integer,
}
pac_party_fields = {
    'all_loans_received_period': fields.Integer,
    'all_loans_received_ytd': fields.Integer,
    'allocated_federal_election_levin_share_period': fields.Integer,
    'calendar_ytd': fields.Integer,
    'cash_on_hand_beginning_calendar_ytd': fields.Integer,
    'cash_on_hand_close_ytd': fields.Integer,
    'coordinated_expenditures_by_party_committee_period': fields.Integer,
    'coordinated_expenditures_by_party_committee_ytd': fields.Integer,
    'fed_candidate_committee_contribution_refunds_ytd': fields.Integer,
    'fed_candidate_committee_contributions_period': fields.Integer,
    'fed_candidate_committee_contributions_ytd': fields.Integer,
    'fed_candidate_contribution_refunds_period': fields.Integer,
    'independent_expenditures_period': fields.Integer,
    'independent_expenditures_ytd': fields.Integer,
    'individual_contribution_refunds_period': fields.Integer,
    'individual_contribution_refunds_ytd': fields.Integer,
    'individual_itemized_contributions_period': fields.Integer,
    'individual_itemized_contributions_ytd': fields.Integer,
    'individual_unitemized_contributions_period': fields.Integer,
    'individual_unitemized_contributions_ytd': fields.Integer,
    'loan_repayments_made_period': fields.Integer,
    'loan_repayments_made_ytd': fields.Integer,
    'loan_repayments_received_period': fields.Integer,
    'loan_repayments_received_ytd': fields.Integer,
    'loans_made_period': fields.Integer,
    'loans_made_ytd': fields.Integer,
    'net_contributions_period': fields.Integer,
    'net_contributions_ytd': fields.Integer,
    'net_operating_expenditures_period': fields.Integer,
    'net_operating_expenditures_ytd': fields.Integer,
    'non_allocated_fed_election_activity_period': fields.Integer,
    'non_allocated_fed_election_activity_ytd': fields.Integer,
    'nonfed_share_allocated_disbursements_period': fields.Integer,
    'offsets_to_operating_expenditures_period': fields.Integer,
    'offsets_to_operating_expenditures_ytd': fields.Integer,
    'other_fed_operating_expenditures_period': fields.Integer,
    'other_fed_operating_expenditures_ytd': fields.Integer,
    'other_fed_receipts_period': fields.Integer,
    'other_fed_receipts_ytd': fields.Integer,
    'other_political_committee_contribution_refunds_period': fields.Integer,
    'other_political_committee_contribution_refunds_ytd': fields.Integer,
    'political_party_committee_contribution_refunds_period': fields.Integer,
    'political_party_committee_contribution_refunds_ytd': fields.Integer,
    'shared_fed_activity_nonfed_ytd': fields.Integer,
    'shared_fed_activity_period': fields.Integer,
    'shared_fed_activity_ytd': fields.Integer,
    'shared_fed_operating_expenditures_period': fields.Integer,
    'shared_fed_operating_expenditures_ytd': fields.Integer,
    'shared_nonfed_operating_expenditures_ytd': fields.Integer,
    'subtotal_summary_page_period': fields.Integer,
    'subtotal_summary_ytd': fields.Integer,
    'total_disbursements_summary_page_period': fields.Integer,
    'total_disbursements_summary_page_ytd': fields.Integer,
    'total_fed_disbursements_period': fields.Integer,
    'total_fed_disbursements_ytd': fields.Integer,
    'total_fed_elect_activity_period': fields.Integer,
    'total_fed_election_activity_ytd': fields.Integer,
    'total_fed_operating_expenditures_period': fields.Integer,
    'total_fed_operating_expenditures_ytd': fields.Integer,
    'total_fed_receipts_period': fields.Integer,
    'total_fed_receipts_ytd': fields.Integer,
    'total_individual_contributions': fields.Integer,
    'total_individual_contributions_ytd': fields.Integer,
    'total_nonfed_transfers_period': fields.Integer,
    'total_nonfed_transfers_ytd': fields.Integer,
    'total_operating_expenditures_period': fields.Integer,
    'total_operating_expenditures_ytd': fields.Integer,
    'total_receipts_summary_page_period': fields.Integer,
    'total_receipts_summary_page_ytd': fields.Integer,
    'transfers_from_affiliated_party_period': fields.Integer,
    'transfers_from_affiliated_party_ytd': fields.Integer,
    'transfers_from_nonfed_account_period': fields.Integer,
    'transfers_from_nonfed_account_ytd': fields.Integer,
    'transfers_from_nonfed_levin_period': fields.Integer,
    'transfers_from_nonfed_levin_ytd': fields.Integer,
    'transfers_to_affiliated_committee_period': fields.Integer,
    'transfers_to_affilitated_committees_ytd': fields.Integer,
}
house_senate_fields = {
    'aggregate_amount_personal_contributions_general': fields.Integer,
    'aggregate_contributions_personal_funds_primary': fields.Integer,
    'all_other_loans_period': fields.Integer,
    'all_other_loans_ytd': fields.Integer,
    'candidate_contribution_period': fields.Integer,
    'candidate_contribution_ytd': fields.Integer,
    'gross_receipt_authorized_committee_general': fields.Integer,
    'gross_receipt_authorized_committee_primary': fields.Integer,
    'gross_receipt_minus_personal_contribution_general': fields.Integer,
    'gross_receipt_minus_personal_contributions_primary': fields.Integer,
    'individual_itemized_contributions_period': fields.Integer,
    'individual_unitemized_contributions_period': fields.Integer,
    'loan_repayments_candidate_loans_period': fields.Integer,
    'loan_repayments_candidate_loans_ytd': fields.Integer,
    'loan_repayments_other_loans_period': fields.Integer,
    'loan_repayments_other_loans_ytd': fields.Integer,
    'loans_made_by_candidate_period': fields.Integer,
    'loans_made_by_candidate_ytd': fields.Integer,
    'net_contributions_period': fields.Integer,
    'net_contributions_ytd': fields.Integer,
    'net_operating_expenditures_period': fields.Integer,
    'net_operating_expenditures_ytd': fields.Integer,
    'offsets_to_operating_expenditures_period': fields.Integer,
    'offsets_to_operating_expenditures_ytd': fields.Integer,
    'operating_expenditures_period': fields.Integer,
    'operating_expenditures_ytd': fields.Integer,
    'other_receipts_period': fields.Integer,
    'other_receipts_ytd': fields.Integer,
    'refunds_individual_contributions_period': fields.Integer,
    'refunds_individual_contributions_ytd': fields.Integer,
    'refunds_other_political_committee_contributions_period': fields.Integer,
    'refunds_other_political_committee_contributions_ytd': fields.Integer,
    'refunds_political_party_committee_contributions_period': fields.Integer,
    'refunds_political_party_committee_contributions_ytd': fields.Integer,
    'refunds_total_contributions_col_total_ytd': fields.Integer,
    'subtotal_period': fields.Integer,
    'total_contribution_refunds_col_total_period': fields.Integer,
    'total_contributions_column_total_period': fields.Integer,
    'total_individual_contributions_period': fields.Integer,
    'total_individual_contributions_ytd': fields.Integer,
    'total_individual_itemized_contributions_ytd': fields.Integer,
    'total_individual_unitemized_contributions_ytd': fields.Integer,
    'total_loan_repayments_period': fields.Integer,
    'total_loan_repayments_ytd': fields.Integer,
    'total_loans_period': fields.Integer,
    'total_loans_ytd': fields.Integer,
    'total_offsets_to_operating_expenditures_period': fields.Integer,
    'total_offsets_to_operating_expenditures_ytd': fields.Integer,
    'total_operating_expenditures_period': fields.Integer,
    'total_operating_expenditures_ytd': fields.Integer,
    'total_receipts': fields.Integer,
    'transfers_from_other_authorized_committee_period': fields.Integer,
    'transfers_from_other_authorized_committee_ytd': fields.Integer,
    'transfers_to_other_authorized_committee_period': fields.Integer,
    'transfers_to_other_authorized_committee_ytd': fields.Integer,
}
presidential_fields = {
    'candidate_contribution_period': fields.Integer,
    'candidate_contribution_ytd': fields.Integer,
    'exempt_legal_accounting_disbursement_period': fields.Integer,
    'exempt_legal_accounting_disbursement_ytd': fields.Integer,
    'expentiture_subject_to_limits': fields.Integer,
    'federal_funds_period': fields.Integer,
    'federal_funds_ytd': fields.Integer,
    'fundraising_disbursements_period': fields.Integer,
    'fundraising_disbursements_ytd': fields.Integer,
    'individual_contributions_period': fields.Integer,
    'individual_contributions_ytd': fields.Integer,
    'items_on_hand_liquidated': fields.Integer,
    'loans_received_from_candidate_period': fields.Integer,
    'loans_received_from_candidate_ytd': fields.Integer,
    'net_contribution_summary_period': fields.Integer,
    'net_operating_expenses_summary_period': fields.Integer,
    'offsets_to_fundraising_exp_ytd': fields.Integer,
    'offsets_to_fundraising_expenses_period': fields.Integer,
    'offsets_to_legal_accounting_period': fields.Integer,
    'offsets_to_legal_accounting_ytd': fields.Integer,
    'offsets_to_operating_expenditures_period': fields.Integer,
    'offsets_to_operating_expenditures_ytd': fields.Integer,
    'operating_expenditures_period': fields.Integer,
    'operating_expenditures_ytd': fields.Integer,
    'other_loans_received_period': fields.Integer,
    'other_loans_received_ytd': fields.Integer,
    'other_receipts_period': fields.Integer,
    'other_receipts_ytd': fields.Integer,
    'refunded_individual_contributions_ytd': fields.Integer,
    'refunded_other_political_committee_contributions_period': fields.Integer,
    'refunded_other_political_committee_contributions_ytd': fields.Integer,
    'refunded_political_party_committee_contributions_period': fields.Integer,
    'refunded_political_party_committee_contributions_ytd': fields.Integer,
    'refunds_individual_contributions_period': fields.Integer,
    'repayments_loans_made_by_candidate_period': fields.Integer,
    'repayments_loans_made_candidate_ytd': fields.Integer,
    'repayments_other_loans_period': fields.Integer,
    'repayments_other_loans_ytd': fields.Integer,
    'subtotal_summary_period': fields.Integer,
    'total_disbursements_summary_period': fields.Integer,
    'total_loan_repayments_made_period': fields.Integer,
    'total_loan_repayments_made_ytd': fields.Integer,
    'total_loans_received_period': fields.Integer,
    'total_loans_received_ytd': fields.Integer,
    'total_offsets_to_operating_expenditures_period': fields.Integer,
    'total_offsets_to_operating_expenditures_ytd': fields.Integer,
    'total_period': fields.Integer,
    'total_receipts_summary_period': fields.Integer,
    'total_ytd': fields.Integer,
    'transfer_from_affiliated_committee_period': fields.Integer,
    'transfer_from_affiliated_committee_ytd': fields.Integer,
    'transfer_to_other_authorized_committee_period': fields.Integer,
    'transfer_to_other_authorized_committee_ytd': fields.Integer,
}
pagination_fields = {
    'per_page': fields.Integer,
    'page': fields.Integer,
    'count': fields.Integer,
    'pages': fields.Integer,
}


class ReportsView(Resource):
    parser = reqparse.RequestParser()
    parser.add_argument('page', type=inputs.natural, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=inputs.natural, default=20, help='The number of results returned per page. Defaults to 20.')
    # TODO: change to filter on report_year and add a separate filter for cycle
    parser.add_argument('year', type=str, default=default_year(), dest='cycle', help="Year in which a candidate runs for office")
    parser.add_argument('fields', type=str, help='Choose the fields that are displayed')

    def get(self, **kwargs):
        committee_id = kwargs['id']
        args = self.parser.parse_args(strict=True)

        # pagination
        page_num = args.get('page', 1)
        per_page = args.get('per_page', 20)

        committee = Committee.query.filter_by(committee_id=committee_id).one()

        if committee.committee_type == 'P':
            reports_class = CommitteeReportsPresidential
            results_fields = merge_dicts(common_fields, presidential_fields)
        elif committee.committee_type in ['H', 'S']:
            reports_class = CommitteeReportsHouseOrSenate
            results_fields = merge_dicts(common_fields, house_senate_fields)
        else:
            reports_class = CommitteeReportsPacOrParty
            results_fields = merge_dicts(common_fields, pac_party_fields)

        count, reports = self.get_reports(committee_id, reports_class, args, page_num, per_page)

        data = {
            'api_version': '0.2',
            'pagination': {
                'page': page_num,
                'per_page': per_page,
                'count': count,
                'pages': int(ceil(count / per_page)),
            },
            'results': reports
        }

        reports_view_fields = {
            'api_version': fields.Fixed(1),
            'pagination': fields.Nested(pagination_fields),
            'results': fields.Nested(results_fields),
        }

        return marshal(data, reports_view_fields)

    def get_reports(self, committee_id, reports_class, args, page_num, per_page):

        reports = reports_class.query.filter_by(committee_id=committee_id)

        if args['cycle'] != '*':
            reports = reports.filter(reports_class.cycle.in_(args['cycle'].split(',')))

        count = reports.count()
        return count, reports.order_by(desc(reports_class.coverage_end_date)).paginate(page_num, per_page, True).items


class CommitteeReportsHouseOrSenate(db.Model):
    __tablename__ = 'ofec_reports_house_senate_mv'

    report_key = db.Column(db.BigInteger, primary_key=True)
    committee_id = db.Column(db.String(10))
    cycle = db.Column(db.Integer)

    # common fields
    beginning_image_number = db.Column(db.Integer)
    cash_on_hand_beginning_period = db.Column(db.Integer)
    cash_on_hand_end_period = db.Column(db.Integer)
    coverage_end_date = db.Column(db.DateTime)
    coverage_start_date = db.Column(db.DateTime)
    debts_owed_by_committee = db.Column(db.Integer)
    debts_owed_to_committee = db.Column(db.Integer)
    end_image_number = db.Column(db.Integer)
    expire_date = db.Column(db.DateTime)
    other_disbursements_period = db.Column(db.Integer)
    other_disbursements_ytd = db.Column(db.Integer)
    other_political_committee_contributions_period = db.Column(db.Integer)
    other_political_committee_contributions_ytd = db.Column(db.Integer)
    political_party_committee_contributions_period = db.Column(db.Integer)
    political_party_committee_contributions_ytd = db.Column(db.Integer)
    report_type = db.Column(db.String)
    report_type_full = db.Column(db.String)
    report_year = db.Column(db.Integer)
    total_contribution_refunds_period = db.Column(db.Integer)
    total_contribution_refunds_ytd = db.Column(db.Integer)
    total_contributions_period = db.Column(db.Integer)
    total_contributions_ytd = db.Column(db.Integer)
    total_disbursements_period = db.Column(db.Integer)
    total_disbursements_ytd = db.Column(db.Integer)
    total_receipts_period = db.Column(db.Integer)
    total_receipts_ytd = db.Column(db.Integer)

    # house-senate specific fields
    aggregate_amount_personal_contributions_general = db.Column(db.Integer)
    aggregate_contributions_personal_funds_primary = db.Column(db.Integer)
    all_other_loans_period = db.Column(db.Integer)
    all_other_loans_ytd = db.Column(db.Integer)
    candidate_contribution_period = db.Column(db.Integer)
    candidate_contribution_ytd = db.Column(db.Integer)
    gross_receipt_authorized_committee_general = db.Column(db.Integer)
    gross_receipt_authorized_committee_primary = db.Column(db.Integer)
    gross_receipt_minus_personal_contribution_general = db.Column(db.Integer)
    gross_receipt_minus_personal_contributions_primary = db.Column(db.Integer)
    individual_itemized_contributions_period = db.Column(db.Integer)
    individual_unitemized_contributions_period = db.Column(db.Integer)
    loan_repayments_candidate_loans_period = db.Column(db.Integer)
    loan_repayments_candidate_loans_ytd = db.Column(db.Integer)
    loan_repayments_other_loans_period = db.Column(db.Integer)
    loan_repayments_other_loans_ytd = db.Column(db.Integer)
    loans_made_by_candidate_period = db.Column(db.Integer)
    loans_made_by_candidate_ytd = db.Column(db.Integer)
    net_contributions_period = db.Column(db.Integer)
    net_contributions_ytd = db.Column(db.Integer)
    net_operating_expenditures_period = db.Column(db.Integer)
    net_operating_expenditures_ytd = db.Column(db.Integer)
    offsets_to_operating_expenditures_period = db.Column(db.Integer)
    offsets_to_operating_expenditures_ytd = db.Column(db.Integer)
    operating_expenditures_period = db.Column(db.Integer)
    operating_expenditures_ytd = db.Column(db.Integer)
    other_receipts_period = db.Column(db.Integer)
    other_receipts_ytd = db.Column(db.Integer)
    refunds_individual_contributions_period = db.Column(db.Integer)
    refunds_individual_contributions_ytd = db.Column(db.Integer)
    refunds_other_political_committee_contributions_period = db.Column(db.Integer)
    refunds_other_political_committee_contributions_ytd = db.Column(db.Integer)
    refunds_political_party_committee_contributions_period = db.Column(db.Integer)
    refunds_political_party_committee_contributions_ytd = db.Column(db.Integer)
    refunds_total_contributions_col_total_ytd = db.Column(db.Integer)
    subtotal_period = db.Column(db.Integer)
    total_contribution_refunds_col_total_period = db.Column(db.Integer)
    total_contributions_column_total_period = db.Column(db.Integer)
    total_individual_contributions_period = db.Column(db.Integer)
    total_individual_contributions_ytd = db.Column(db.Integer)
    total_individual_itemized_contributions_ytd = db.Column(db.Integer)
    total_individual_unitemized_contributions_ytd = db.Column(db.Integer)
    total_loan_repayments_period = db.Column(db.Integer)
    total_loan_repayments_ytd = db.Column(db.Integer)
    total_loans_period = db.Column(db.Integer)
    total_loans_ytd = db.Column(db.Integer)
    total_offsets_to_operating_expenditures_period = db.Column(db.Integer)
    total_offsets_to_operating_expenditures_ytd = db.Column(db.Integer)
    total_operating_expenditures_period = db.Column(db.Integer)
    total_operating_expenditures_ytd = db.Column(db.Integer)
    total_receipts = db.Column(db.Integer)
    transfers_from_other_authorized_committee_period = db.Column(db.Integer)
    transfers_from_other_authorized_committee_ytd = db.Column(db.Integer)
    transfers_to_other_authorized_committee_period = db.Column(db.Integer)
    transfers_to_other_authorized_committee_ytd = db.Column(db.Integer)


class CommitteeReportsPacOrParty(db.Model):
    __tablename__ = 'ofec_reports_pacs_parties_mv'

    report_key = db.Column(db.BigInteger, primary_key=True)
    committee_id = db.Column(db.String(10))
    cycle = db.Column(db.Integer)

    # common fields
    beginning_image_number = db.Column(db.Integer)
    cash_on_hand_beginning_period = db.Column(db.Integer)
    cash_on_hand_end_period = db.Column(db.Integer)
    coverage_end_date = db.Column(db.DateTime)
    coverage_start_date = db.Column(db.DateTime)
    debts_owed_by_committee = db.Column(db.Integer)
    debts_owed_to_committee = db.Column(db.Integer)
    end_image_number = db.Column(db.Integer)
    expire_date = db.Column(db.DateTime)
    other_disbursements_period = db.Column(db.Integer)
    other_disbursements_ytd = db.Column(db.Integer)
    other_political_committee_contributions_period = db.Column(db.Integer)
    other_political_committee_contributions_ytd = db.Column(db.Integer)
    political_party_committee_contributions_period = db.Column(db.Integer)
    political_party_committee_contributions_ytd = db.Column(db.Integer)
    report_type = db.Column(db.String)
    report_type_full = db.Column(db.String)
    report_year = db.Column(db.Integer)
    total_contribution_refunds_period = db.Column(db.Integer)
    total_contribution_refunds_ytd = db.Column(db.Integer)
    total_contributions_period = db.Column(db.Integer)
    total_contributions_ytd = db.Column(db.Integer)
    total_disbursements_period = db.Column(db.Integer)
    total_disbursements_ytd = db.Column(db.Integer)
    total_receipts_period = db.Column(db.Integer)
    total_receipts_ytd = db.Column(db.Integer)

    # pac-party specific fields
    all_loans_received_period = db.Column(db.Integer)
    all_loans_received_ytd = db.Column(db.Integer)
    allocated_federal_election_levin_share_period = db.Column(db.Integer)
    calendar_ytd = db.Column(db.Integer)
    cash_on_hand_beginning_calendar_ytd = db.Column(db.Integer)
    cash_on_hand_close_ytd = db.Column(db.Integer)
    coordinated_expenditures_by_party_committee_period = db.Column(db.Integer)
    coordinated_expenditures_by_party_committee_ytd = db.Column(db.Integer)
    fed_candidate_committee_contribution_refunds_ytd = db.Column(db.Integer)
    fed_candidate_committee_contributions_period = db.Column(db.Integer)
    fed_candidate_committee_contributions_ytd = db.Column(db.Integer)
    fed_candidate_contribution_refunds_period = db.Column(db.Integer)
    independent_expenditures_period = db.Column(db.Integer)
    independent_expenditures_ytd = db.Column(db.Integer)
    individual_contribution_refunds_period = db.Column(db.Integer)
    individual_contribution_refunds_ytd = db.Column(db.Integer)
    individual_itemized_contributions_period = db.Column(db.Integer)
    individual_itemized_contributions_ytd = db.Column(db.Integer)
    individual_unitemized_contributions_period = db.Column(db.Integer)
    individual_unitemized_contributions_ytd = db.Column(db.Integer)
    loan_repayments_made_period = db.Column(db.Integer)
    loan_repayments_made_ytd = db.Column(db.Integer)
    loan_repayments_received_period = db.Column(db.Integer)
    loan_repayments_received_ytd = db.Column(db.Integer)
    loans_made_period = db.Column(db.Integer)
    loans_made_ytd = db.Column(db.Integer)
    net_contributions_period = db.Column(db.Integer)
    net_contributions_ytd = db.Column(db.Integer)
    net_operating_expenditures_period = db.Column(db.Integer)
    net_operating_expenditures_ytd = db.Column(db.Integer)
    non_allocated_fed_election_activity_period = db.Column(db.Integer)
    non_allocated_fed_election_activity_ytd = db.Column(db.Integer)
    nonfed_share_allocated_disbursements_period = db.Column(db.Integer)
    offsets_to_operating_expenditures_period = db.Column(db.Integer)
    offsets_to_operating_expenditures_ytd = db.Column(db.Integer)
    other_fed_operating_expenditures_period = db.Column(db.Integer)
    other_fed_operating_expenditures_ytd = db.Column(db.Integer)
    other_fed_receipts_period = db.Column(db.Integer)
    other_fed_receipts_ytd = db.Column(db.Integer)
    other_political_committee_contribution_refunds_period = db.Column(db.Integer)
    other_political_committee_contribution_refunds_ytd = db.Column(db.Integer)
    political_party_committee_contribution_refunds_period = db.Column(db.Integer)
    political_party_committee_contribution_refunds_ytd = db.Column(db.Integer)
    shared_fed_activity_nonfed_ytd = db.Column(db.Integer)
    shared_fed_activity_period = db.Column(db.Integer)
    shared_fed_activity_ytd = db.Column(db.Integer)
    shared_fed_operating_expenditures_period = db.Column(db.Integer)
    shared_fed_operating_expenditures_ytd = db.Column(db.Integer)
    shared_nonfed_operating_expenditures_ytd = db.Column(db.Integer)
    subtotal_summary_page_period = db.Column(db.Integer)
    subtotal_summary_ytd = db.Column(db.Integer)
    total_disbursements_summary_page_period = db.Column(db.Integer)
    total_disbursements_summary_page_ytd = db.Column(db.Integer)
    total_fed_disbursements_period = db.Column(db.Integer)
    total_fed_disbursements_ytd = db.Column(db.Integer)
    total_fed_elect_activity_period = db.Column(db.Integer)
    total_fed_election_activity_ytd = db.Column(db.Integer)
    total_fed_operating_expenditures_period = db.Column(db.Integer)
    total_fed_operating_expenditures_ytd = db.Column(db.Integer)
    total_fed_receipts_period = db.Column(db.Integer)
    total_fed_receipts_ytd = db.Column(db.Integer)
    total_individual_contributions = db.Column(db.Integer)
    total_individual_contributions_ytd = db.Column(db.Integer)
    total_nonfed_transfers_period = db.Column(db.Integer)
    total_nonfed_transfers_ytd = db.Column(db.Integer)
    total_operating_expenditures_period = db.Column(db.Integer)
    total_operating_expenditures_ytd = db.Column(db.Integer)
    total_receipts_summary_page_period = db.Column(db.Integer)
    total_receipts_summary_page_ytd = db.Column(db.Integer)
    transfers_from_affiliated_party_period = db.Column(db.Integer)
    transfers_from_affiliated_party_ytd = db.Column(db.Integer)
    transfers_from_nonfed_account_period = db.Column(db.Integer)
    transfers_from_nonfed_account_ytd = db.Column(db.Integer)
    transfers_from_nonfed_levin_period = db.Column(db.Integer)
    transfers_from_nonfed_levin_ytd = db.Column(db.Integer)
    transfers_to_affiliated_committee_period = db.Column(db.Integer)
    transfers_to_affilitated_committees_ytd = db.Column(db.Integer)

class CommitteeReportsPresidential(db.Model):
    __tablename__ = 'ofec_reports_presidential_mv'

    report_key = db.Column(db.BigInteger, primary_key=True)
    committee_id = db.Column(db.String(10))
    cycle = db.Column(db.Integer)

    # common fields
    beginning_image_number = db.Column(db.Integer)
    cash_on_hand_beginning_period = db.Column(db.Integer)
    cash_on_hand_end_period = db.Column(db.Integer)
    coverage_end_date = db.Column(db.DateTime)
    coverage_start_date = db.Column(db.DateTime)
    debts_owed_by_committee = db.Column(db.Integer)
    debts_owed_to_committee = db.Column(db.Integer)
    end_image_number = db.Column(db.Integer)
    expire_date = db.Column(db.DateTime)
    operating_expenditures_period = db.Column(db.Integer)
    other_disbursements_period = db.Column(db.Integer)
    other_disbursements_ytd = db.Column(db.Integer)
    other_political_committee_contributions_period = db.Column(db.Integer)
    other_political_committee_contributions_ytd = db.Column(db.Integer)
    political_party_committee_contributions_period = db.Column(db.Integer)
    political_party_committee_contributions_ytd = db.Column(db.Integer)
    report_type = db.Column(db.String)
    report_type_full = db.Column(db.String)
    report_year = db.Column(db.Integer)
    total_contribution_refunds_period = db.Column(db.Integer)
    total_contribution_refunds_ytd = db.Column(db.Integer)
    total_contributions_period = db.Column(db.Integer)
    total_contributions_ytd = db.Column(db.Integer)
    total_disbursements_period = db.Column(db.Integer)
    total_disbursements_ytd = db.Column(db.Integer)
    total_receipts_period = db.Column(db.Integer)
    total_receipts_ytd = db.Column(db.Integer)

    # president-specific fields
    candidate_contribution_period = db.Column(db.Integer)
    candidate_contribution_ytd = db.Column(db.Integer)
    exempt_legal_accounting_disbursement_period = db.Column(db.Integer)
    exempt_legal_accounting_disbursement_ytd = db.Column(db.Integer)
    expentiture_subject_to_limits = db.Column(db.Integer)
    federal_funds_period = db.Column(db.Integer)
    federal_funds_ytd = db.Column(db.Integer)
    fundraising_disbursements_period = db.Column(db.Integer)
    fundraising_disbursements_ytd = db.Column(db.Integer)
    individual_contributions_period = db.Column(db.Integer)
    individual_contributions_ytd = db.Column(db.Integer)
    items_on_hand_liquidated = db.Column(db.Integer)
    loans_received_from_candidate_period = db.Column(db.Integer)
    loans_received_from_candidate_ytd = db.Column(db.Integer)
    net_contribution_summary_period = db.Column(db.Integer)
    net_operating_expenses_summary_period = db.Column(db.Integer)
    offsets_to_fundraising_exp_ytd = db.Column(db.Integer)
    offsets_to_fundraising_expenses_period = db.Column(db.Integer)
    offsets_to_legal_accounting_period = db.Column(db.Integer)
    offsets_to_legal_accounting_ytd = db.Column(db.Integer)
    offsets_to_operating_expenditures_period = db.Column(db.Integer)
    offsets_to_operating_expenditures_ytd = db.Column(db.Integer)
    operating_expenditures_period = db.Column(db.Integer)
    operating_expenditures_ytd = db.Column(db.Integer)
    other_loans_received_period = db.Column(db.Integer)
    other_loans_received_ytd = db.Column(db.Integer)
    other_receipts_period = db.Column(db.Integer)
    other_receipts_ytd = db.Column(db.Integer)
    refunded_individual_contributions_ytd = db.Column(db.Integer)
    refunded_other_political_committee_contributions_period = db.Column(db.Integer)
    refunded_other_political_committee_contributions_ytd = db.Column(db.Integer)
    refunded_political_party_committee_contributions_period = db.Column(db.Integer)
    refunded_political_party_committee_contributions_ytd = db.Column(db.Integer)
    refunds_individual_contributions_period = db.Column(db.Integer)
    repayments_loans_made_by_candidate_period = db.Column(db.Integer)
    repayments_loans_made_candidate_ytd = db.Column(db.Integer)
    repayments_other_loans_period = db.Column(db.Integer)
    repayments_other_loans_ytd = db.Column(db.Integer)
    subtotal_summary_period = db.Column(db.Integer)
    total_disbursements_summary_period = db.Column(db.Integer)
    total_loan_repayments_made_period = db.Column(db.Integer)
    total_loan_repayments_made_ytd = db.Column(db.Integer)
    total_loans_received_period = db.Column(db.Integer)
    total_loans_received_ytd = db.Column(db.Integer)
    total_offsets_to_operating_expenditures_period = db.Column(db.Integer)
    total_offsets_to_operating_expenditures_ytd = db.Column(db.Integer)
    total_period = db.Column(db.Integer)
    total_receipts_summary_period = db.Column(db.Integer)
    total_ytd = db.Column(db.Integer)
    transfer_from_affiliated_committee_period = db.Column(db.Integer)
    transfer_from_affiliated_committee_ytd = db.Column(db.Integer)
    transfer_to_other_authorized_committee_period = db.Column(db.Integer)
    transfer_to_other_authorized_committee_ytd = db.Column(db.Integer)
