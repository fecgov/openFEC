import string
import htsql
from datetime import datetime

from webservices.db import htsql_conn, as_dicts


class Total(object):

    table_name_stem = 'cmte'
    viewable_table_name = (
        "dimcmte?exists(facthousesenate_f3)|exists(factpresidential_f3p)|"
        "exists(factpacsandparties_f3x)")

    default_fields = {
        'dimcmte_fields': '*,',
        'house_senate_fields': '*,',
        'house_senate_totals': (
            'ttl_disb_per_ii,ttl_receipts_per_i,'
        ),
        'presidential_fields': '*,',
        'presidential_totals': (
            'ttl_disb_per,ttl_receipts_per,'
        ),
        'pac_party_fields': '*,',
        'pac_party_totals': (
            'ttl_receipts_per,ttl_disb_sum_page_per,'
        ),
        'report_fields': '*',
    }

    # This is just string formatting the query we need to run additional
    # layers are added in the search class
    def query_text(self, show_fields):
        # Creating the summing part of the query
        house_senate_totals = show_fields['house_senate_totals'].split(',')
        presidential_totals = show_fields['presidential_totals'].split(',')
        pac_party_totals = show_fields['pac_party_totals'].split(',')

        # limiting to an election cycle
        args = self.parser.parse_args(strict=True)
        if args.get('election_cycle') is not None:
            cycle = '?two_yr_period_sk={%s}' % (args['election_cycle'])
        else:
            cycle = ''

        #checking what table to look at
        if args.get('committee_id') is not None:
            ids = args['committee_id'].split(',')
            pre_qry = "/dimcmte{/dimcmtetpdsgn{cmte_tp}}\
                    ?cmte_id={'%s'}"%(
                        "','".join(ids)
                )
            data = htsql_conn().produce(pre_qry)
            types = []
            # looking for the codes in the htsql string
            for d in str(data):
                if d.isalpha() == True:
                    if d not in types:
                        types.append(d)
            print types
            table_list = []

            # create the base table name
            for t in types:
                if t =='P':
                    if 'exists(factpresidential_f3p)' not in table_list:
                        table_list.append('exists(factpresidential_f3p)')
                elif t =='H'  or  t == 'S':
                    if 'exists(facthousesenate_f3)' not in table_list:
                        table_list.append('exists(facthousesenate_f3)')
                else:
                    if 'exists(factpacsandparties_f3x)' not in table_list:
                        table_list.append('exists(factpacsandparties_f3x)')

            tables = 'dimcmte?' + '|'.join(table_list)

        else:
            tables = self.viewable_table_name
            use_table = ['P', 'H', 'O']


        # this part creates the election cycle totals
        if house_senate_totals != [''] and 'H' in use_table:
            hs_sums = ['sum(^.%s) :as %s, ' % (t, t)
                       for t in house_senate_totals if t != '']
            hs_totals = (
                ' /facthousesenate_f3^{two_yr_period_sk, '
                'dimcmte.cmte_id}%s{*, %s} :as hs_sums,') % (
                    cycle, string.join(hs_sums))
        else:
            hs_totals = ''

        if presidential_totals != [''] and 'P' in use_table:
            p_sums = ['sum(^.%s) :as %s, ' % (t, t)
                      for t in presidential_totals if t != '']
            pres_totals = (
                ' /factpresidential_f3p^{two_yr_period_sk, dimcmte.cmte_id}'
                '%s{*, %s} :as p_sums,') % (cycle, string.join(p_sums))
        else:
            pres_totals = ''

        if pac_party_totals != [''] and 'O' in use_table:
            pp_sums = ['sum(^.%s) :as %s, ' % (t, t)
                       for t in pac_party_totals if t != '']
            pp_totals = (
                ' /factpacsandparties_f3x^{two_yr_period_sk, '
                'dimcmte.cmte_id}%s{*, %s} :as pp_sums,') % (
                    cycle, string.join(pp_sums))
        else:
            pp_totals = ''

        # don't want to add reports if not needed
        if show_fields['report_fields'] != '':
            reports = '/dimreporttype{%s}' % show_fields['report_fields']
        else:
            reports = ''

        year = ''
        if (show_fields['house_senate_fields'] != ''
                and show_fields['presidential_fields'] != ''
                and show_fields['pac_party_fields']):
            year = 'rpt_yr,'

        # adds the sums formatted above and inserts the default or user
        # defined fields.

        if 'H' in types:
            house_qry = '/facthousesenate_f3{%s %s}%s,%s ' % (
                year + show_fields['house_senate_fields'],
                reports,
                cycle,
                hs_totals
            )
        else:
            house_qry = ''

        if 'O' in types:
            party_qry = '/factpacsandparties_f3x{%s %s}%s,%s ' % (
                year + show_fields['pac_party_fields'],
                reports,
                cycle,
                pp_totals
            )
        else:
            party_qry = ''

        if 'P' in types:
            prez_qry = '/factpresidential_f3p{%s %s}%s,%s '  % (
                year + show_fields['presidential_fields'],
                reports,
                cycle,
                pres_totals
            )
        else:
            prez_qry = ''

        qry =  '((%s){cmte_id, %s%s%s%s})' % (
            tables,
            show_fields['dimcmte_fields'],
            house_qry,
            prez_qry,
            party_qry
        )
        return qry

    # need to add
        # "cvg_end_dt_sk"
        # "cvg_start_dt_sk"
    # presidential
    presidential_mapping = (
        ('beginning_image_number', 'begin_image_num'),
        ('candidate_contribution_period', 'cand_contb_per'),
        ('candidate_contribution_year', 'cand_contb_ytd'),
        ('cash_on_hand_beginning_period', 'coh_bop'),
        ('cash_on_hand_end_period', 'coh_cop'),
        ('debts_owed_by_committee', 'debts_owed_by_cmte'),
        ('debts_owed_to_committee', 'debts_owed_to_cmte'),
        ('end_image_number', 'end_image_num'),
        ('expentiture_subject_to_limits', 'exp_subject_limits'),
        ('exempt_legal_accounting_disbursement_period',
            'exempt_legal_acctg_disb_per'),
        ('exempt_legal_accounting_disbursement_year',
            'exempt_legal_acctg_disb_ytd'),
        ('expire_date', 'expire_date'),
        ('federal_funds_period', 'fed_funds_per'),
        ('federal_funds_year', 'fed_funds_ytd'),
        ('fundraising_disbursements_period', 'fndrsg_disb_per'),
        ('fundraising_disbursements_year', 'fndrsg_disb_ytd'),
        ('individual_contributions_period', 'indv_contb_per'),
        ('individual_contributions_year', 'indv_contb_ytd'),
        ('items_on_hand_liquidated', 'items_on_hand_liquidated'),
        ('load_date', 'load_date'),
        ('loans_received_from_candidate_period',
            'loans_received_from_cand_per'),
        ('loans_received_from_candidate_year',
            'loans_received_from_cand_ytd'),
        ('net_contribution_summary_period', 'net_contb_sum_page_per'),
        ('net_operating_expenses_summary_period', 'net_op_exp_sum_page_per'),
        ('offsets_to_fundraising_expenses_period',
            'offsets_to_fndrsg_exp_per'),
        ('offsets_to_fundraising_exp_year', 'offsets_to_fndrsg_exp_ytd'),
        ('offsets_to_legal_accounting_period', 'offsets_to_legal_acctg_per'),
        ('offsets_to_legal_accounting_year', 'offsets_to_legal_acctg_ytd'),
        ('offsets_to_operating_expenditures_period', 'offsets_to_op_exp_per'),
        ('offsets_to_operating_expenditures_year', 'offsets_to_op_exp_ytd'),
        ('operating_expenditures_period', 'op_exp_per'),
        ('operating_expenditures_year', 'op_exp_ytd'),
        ('other_disbursements_period', 'other_disb_per'),
        ('other_disbursements_year', 'other_disb_ytd'),
        ('other_loans_received_period', 'other_loans_received_per'),
        ('other_loans_received_year', 'other_loans_received_ytd'),
        ('other_political_committee_contributions_period',
            'other_pol_cmte_contb_per'),
        ('other_political_committee_contributions_year',
            'other_pol_cmte_contb_ytd'),
        ('other_receipts_period', 'other_receipts_per'),
        ('other_receipts_year', 'other_receipts_ytd'),
        ('political_party_committee_contributions_period',
            'pol_pty_cmte_contb_per'),
        ('political_party_committee_contributions_year',
            'pol_pty_cmte_contb_ytd'),
        ('refunds_individual_contributions_period', 'ref_indv_contb_per'),
        ('refunded_individual_contributions_year', 'ref_indv_contb_ytd'),
        ('refunded_other_political_committee_contributions_period',
            'ref_other_pol_cmte_contb_per'),
        ('refunded_other_political_committee_contributions_year',
            'ref_other_pol_cmte_contb_ytd'),
        ('refunded_political_party_committee_contributions_period',
            'ref_pol_pty_cmte_contb_per'),
        ('refunded_political_party_committee_contributions_year',
            'ref_pol_pty_cmte_contb_ytd'),
        ('repayments_loans_made_by_candidate_period',
            'repymts_loans_made_by_cand_per'),
        ('repayments_loans_made_candidate_year',
            'repymts_loans_made_cand_ytd'),
        ('repayments_other_loans_period', 'repymts_other_loans_per'),
        ('repayments_other_loans_year', 'repymts_other_loans_ytd'),
        ('report_year', 'rpt_yr'),

        ('subtotal_summary_period', 'subttl_sum_page_per'),

        ('transfer_from_affiliated_committee_period',
            'tranf_from_affilated_cmte_per'),
        ('transfer_from_affiliated_committee_year',
            'tranf_from_affilated_cmte_ytd'),
        ('transfer_to_other_authorized_committee_period',
            'tranf_to_other_auth_cmte_per'),
        ('transfer_to_other_authorized_committee_year',
            'tranf_to_other_auth_cmte_ytd'),
        ('total_contributions_period', 'ttl_contb_per'),
        ('total_contribution_refunds_period', 'ttl_contb_ref_per'),
        ('total_contribution_refunds_year', 'ttl_contb_ref_ytd'),
        ('total_contributions_year', 'ttl_contb_ytd'),
        ('total_disbursements_period', 'ttl_disb_per'),
        ('total_disbursements_summary_period', 'ttl_disb_sum_page_per'),
        ('total_disbursements_year', 'ttl_disb_ytd'),
        ('total_loan_repayments_made_period', 'ttl_loan_repymts_made_per'),
        ('total_loan_repayments_made_year', 'ttl_loan_repymts_made_ytd'),
        ('total_loans_received_period', 'ttl_loans_received_per'),
        ('total_loans_received_year', 'ttl_loans_received_ytd'),
        ('total_offsets_to_operating_expenditures_period',
            'ttl_offsets_to_op_exp_per'),
        ('total_offsets_to_operating_expenditures_year',
            'ttl_offsets_to_op_exp_ytd'),
        ('total_period', 'ttl_per'),
        ('total_receipts_period', 'ttl_receipts_per'),
        ('total_receipts_summary_period', 'ttl_receipts_sum_page_per'),
        ('total_receipts_year', 'ttl_receipts_ytd'),
        ('total_year', 'ttl_ytd'),
        ('election_cycle', 'two_yr_period_sk'),
        ('*', '*'),
    )

    # These are used for making the election cycle totals.
    presidential_totals = (
        ('cycle', 'two_yr_period_sk'),
        ('candidate_contribution', 'cand_contb_per'),
        ('exempt_legal_accounting_disbursement',
            'exempt_legal_acctg_disb_per'),
        ('federal_funds', 'fed_funds_per'),
        ('fundraising_disbursements', 'fndrsg_disb_per'),
        ('individual_contributions', 'indv_contb_per'),
        ('loans_received_from_candidate', 'loans_received_from_cand_per'),
        ('offsets_to_fundraising_expenses', 'offsets_to_fndrsg_exp_per'),
        ('offsets_to_legal_accounting', 'offsets_to_legal_acctg_per'),
        ('offsets_to_operating_expenditures', 'offsets_to_op_exp_per'),
        ('operating_expenditures', 'op_exp_per'),
        ('other_disbursements', 'other_disb_per'),
        ('other_loans_received', 'other_loans_received_per'),
        ('other_political_committee_contributions',
            'other_pol_cmte_contb_per'),
        ('other_receipts', 'other_receipts_per'),
        ('political_party_committee_contributions', 'pol_pty_cmte_contb_per'),
        ('refunds_individual_contributions', 'ref_indv_contb_per'),
        ('refunded_other_political_committee_contributions',
            'ref_other_pol_cmte_contb_per'),
        ('refunded_political_party_committee_contributions',
            'ref_pol_pty_cmte_contb_per'),
        ('repayments_loans_made_by_candidate',
            'repymts_loans_made_by_cand_per'),
        ('repayments_other_loans', 'repymts_other_loans_per'),
        ('transfer_from_affiliated_committee',
            'tranf_from_affilated_cmte_per'),
        ('transfer_to_other_authorized_committee',
            'tranf_to_other_auth_cmte_per'),
        ('contributions', 'ttl_contb_per'),
        ('contribution_refunds', 'ttl_contb_ref_per'),
        ('disbursements', 'ttl_disb_per'),
        ('loan_repayments_made', 'ttl_loan_repymts_made_per'),
        ('loans_received', 'ttl_loans_received_per'),
        ('offsets_to_operating_expenditures', 'ttl_offsets_to_op_exp_per'),
        ('receipts', 'ttl_receipts_per'),
        # all
        ('*', (
            'cand_contb_per,exempt_legal_acctg_disb_per,fed_funds_per,'
            'fndrsg_disb_per,indv_contb_per,loans_received_from_cand_per,'
            'offsets_to_fndrsg_exp_per,offsets_to_legal_acctg_per,'
            'offsets_to_op_exp_per,op_exp_per,other_disb_per,'
            'other_loans_received_per,other_pol_cmte_contb_per,'
            'other_receipts_per,pol_pty_cmte_contb_per,ref_indv_contb_per,'
            'ref_other_pol_cmte_contb_per,ref_pol_pty_cmte_contb_per,'
            'repymts_loans_made_by_cand_per,repymts_other_loans_per,'
            'tranf_from_affilated_cmte_per,tranf_to_other_auth_cmte_per,'
            'ttl_contb_per,ttl_contb_ref_per,ttl_disb_per,'
            'ttl_loan_repymts_made_per,ttl_loans_received_per,'
            'ttl_offsets_to_op_exp_per,ttl_receipts_per,')),
    )

    pac_party_mapping = (
        ('end_image_number', 'end_image_num'),
        ('individual_contribution_refunds_year', 'indv_contb_ref_ytd'),
        ('total_contribution_refunds_period', 'ttl_contb_ref_per_i'),
        ('shared_nonfed_operating_expenditures_period',
            'shared_nonfed_op_exp_per'),
        ('shared_fed_activity_nonfed_year', 'shared_fed_actvy_nonfed_ytd'),
        ('other_political_committee_contributions_year',
            'other_pol_cmte_contb_ytd_i'),
        ('subtotal_summary_page_period', 'subttl_sum_page_per'),
        ('total_fed_receipts_period', 'ttl_fed_receipts_per'),
        ('net_operating_expenditures_period', 'net_op_exp_per'),
        ('shared_fed_activity_year', 'shared_fed_actvy_fed_shr_ytd'),
        ('loan_repayments_received_period', 'loan_repymts_received_per'),
        ('cash_on_hand_close_year', 'coh_coy'),
        ('offsets_to_operating_expendituresenditures_period',
            'offsets_to_op_exp_per_i'),
        ('cash_on_hand_end_period', 'coh_cop'),
        ('independent_expenditures_period', 'indt_exp_per'),
        ('other_fed_operating_expenditures_period', 'other_fed_op_exp_per'),
        ('loan_repayments_made_period', 'loan_repymts_made_per'),
        ('total_fed_elect_activity_period', 'ttl_fed_elect_actvy_per'),
        ('total_receipts_period', 'ttl_receipts_per'),
        ('total_nonfed_transfers_period', 'ttl_nonfed_tranf_per'),
        ('political_party_committee_contributions_period',
            'pol_pty_cmte_contb_per_ii'),
        ('total_nonfed_transfers_year', 'ttl_nonfed_tranf_ytd'),
        ('total_fed_disbursements_period', 'ttl_fed_disb_per'),
        ('offsets_to_operating_expendituresenditures_year',
            'offsets_to_op_exp_ytd_i'),
        ('total_disbursements_period', 'ttl_disb_per'),
        ('non_allocated_fed_election_activity_year',
            'non_alloc_fed_elect_actvy_ytd'),
        ('subtotal_summary_year', 'subttl_sum_ytd'),
        ('political_party_committee_contributions_period',
            'pol_pty_cmte_contb_per_i'),
        ('all_loans_received_year', 'all_loans_received_ytd'),
        ('load_date', 'load_date'),
        ('total_fed_election_activity_year', 'ttl_fed_elect_actvy_ytd'),
        ('total_operating_expenditures_year', 'ttl_op_exp_ytd'),
        ('non_allocated_fed_election_activity_period',
            'non_alloc_fed_elect_actvy_per'),
        ('fed_candidate_committee_contribution_refunds_year',
            'fed_cand_cmte_contb_ref_ytd'),
        ('debts_owed_by_committee', 'debts_owed_by_cmte'),
        ('loan_repayments_received_year', 'loan_repymts_received_ytd'),
        ('cash_on_hand_beginning_period', 'coh_bop'),
        ('total_receipts_summary_page_year', 'ttl_receipts_sum_page_ytd'),
        ('coordinated_expenditures_by_party_committee_year',
            'coord_exp_by_pty_cmte_ytd'),
        ('loan_repayments_made_year', 'loan_repymts_made_ytd'),
        ('coordinated_expenditures_by_party_committee_period',
            'coord_exp_by_pty_cmte_per'),
        ('shared_fed_activity_nonfed_period', 'shared_fed_actvy_nonfed_per'),
        ('transfers_to_affilitated_committees_year',
            'tranf_to_affilitated_cmte_ytd'),
        ('individual_itemized_contributions_year', 'indv_item_contb_ytd'),
        ('other_disbursements_period', 'other_disb_per'),
        ('fed_candidate_committee_contributions_year',
            'fed_cand_cmte_contb_ytd'),
        ('other_disbursements_year', 'other_disb_ytd'),
        ('loans_made_year', 'loans_made_ytd'),
        ('total_disbursements_summary_page_year', 'ttl_disb_sum_page_ytd'),
        ('fed_candidate_committee_contributions_period',
            'fed_cand_cmte_contb_per'),
        ('offsets_to_operating_expendituresenditures_period',
            'offsets_to_op_exp_per_ii'),
        ('net_contributions_period', 'net_contb_per'),
        ('net_contributions_year', 'net_contb_ytd'),
        ('individual_unitemized_contributions_period',
            'indv_unitem_contb_per'),
        ('total_receipts_summary_page_period', 'ttl_receipts_sum_page_per'),
        ('political_party_committee_contributions_year',
            'pol_pty_cmte_contb_ytd_i'),
        ('all_loans_received_period', 'all_loans_received_per'),
        ('cash_on_hand_beginning_calendar_year', 'coh_begin_calendar_yr'),
        ('total_individual_contributions', 'ttl_indv_contb'),
        ('total_contributions_period', 'ttl_contb_per'),
        ('offsets_to_operating_expenditures_year', 'offsets_to_op_exp_ytd_ii'),
        ('transfers_from_nonfed_levin_period', 'tranf_from_nonfed_levin_per'),
        ('total_disbursements_year', 'ttl_disb_ytd'),
        ('political_party_committee_contributions_year',
            'pol_pty_cmte_contb_ytd_ii'),
        ('debts_owed_to_committee', 'debts_owed_to_cmte'),
        ('shared_fed_operating_expenditures_period', 'shared_fed_op_exp_per'),
        ('transfers_from_nonfed_levin_year', 'tranf_from_nonfed_levin_ytd'),
        ('loans_made_period', 'loans_made_per'),
        ('transfers_from_affiliated_party_year',
            'tranf_from_affiliated_pty_ytd'),
        ('transfers_to_affiliated_committee_period',
            'tranf_to_affliliated_cmte_per'),
        ('independent_expenditures_year', 'indt_exp_ytd'),
        ('other_fed_receipts_year', 'other_fed_receipts_ytd'),
        ('total_contribution_refunds_year', 'ttl_contb_ref_ytd_i'),
        ('report_year', 'rpt_yr'),
        ('other_political_committee_contributions_period',
            'other_pol_cmte_contb_per_ii'),
        ('total_contributions_year', 'ttl_contb_ytd'),
        ('other_fed_receipts_period', 'other_fed_receipts_per'),
        ('transfers_from_affiliated_party_period',
            'tranf_from_affiliated_pty_per'),
        ('individual_unitemized_contributions_year', 'indv_unitem_contb_ytd'),
        ('total_fed_disbursements_year', 'ttl_fed_disb_ytd'),
        ('total_fed_operating_expenditures_year', 'ttl_fed_op_exp_ytd'),
        ('total_individual_contributions_year', 'ttl_indv_contb_ytd'),
        ('other_fed_operating_expenditures_year', 'other_fed_op_exp_ytd'),
        ('total_contribution_refunds_period', 'ttl_contb_ref_per_ii'),
        ('beginning_image_number', 'begin_image_num'),
        ('expire_date', 'expire_date'),
        ('individual_contribution_refunds_period', 'indv_contb_ref_per'),
        ('total_contribution_refunds_year', 'ttl_contb_ref_ytd_ii'),
        ('transfers_from_nonfed_account_period', 'tranf_from_nonfed_acct_per'),
        ('total_fed_operating_expenditures_period', 'ttl_fed_op_exp_per'),
        ('shared_fed_operating_expenditures_year', 'shared_fed_op_exp_ytd'),
        ('total_fed_receipts_year', 'ttl_fed_receipts_ytd'),
        ('shared_fed_activity_period', 'shared_fed_actvy_fed_shr_per'),
        ('shared_nonfed_operating_expenditures_year',
            'shared_nonfed_op_exp_ytd'),
        ('fed_candidate_contribution_refunds_period',
            'fed_cand_contb_ref_per'),
        ('net_operating_expenditures_year', 'net_op_exp_ytd'),
        ('total_operating_expenditures_period', 'ttl_op_exp_per'),
        ('transfers_from_nonfed_account_year', 'tranf_from_nonfed_acct_ytd'),
        ('other_political_committee_contributions_period',
            'other_pol_cmte_contb_per_i'),
        ('total_disbursements_summary_page_period', 'ttl_disb_sum_page_per'),
        ('other_political_committee_contributions_year',
            'other_pol_cmte_contb_ytd_ii'),
        ('total_receipts_year', 'ttl_receipts_ytd'),
        ('individual_itemized_contributions_period', 'indv_item_contb_per'),
        ('calendar_year', 'calendar_yr'),
        ('election_cycle', 'two_yr_period_sk'),
        ('*', '*'),
    )

    # These are used for making the election cycle totals.
    pac_party_totals = (
        ('cycle', 'two_yr_period_sk'),
        ('contribution_refunds', 'ttl_contb_ref_per_i'),
        ('shared_nonfed_operating_expenditures', 'shared_nonfed_op_exp_per'),
        ('fed_receipts', 'ttl_fed_receipts_per'),
        ('loan_repayments_received', 'loan_repymts_received_per'),
        ('offsets_to_operating_expendituresenditures',
            'offsets_to_op_exp_per_i'),
        ('independent_expenditures', 'indt_exp_per'),
        ('other_fed_operating_expenditures', 'other_fed_op_exp_per'),
        ('loan_repayments_made', 'loan_repymts_made_per'),
        ('fed_elect_activity', 'ttl_fed_elect_actvy_per'),
        ('receipts', 'ttl_receipts_per'),
        ('nonfed_transfers', 'ttl_nonfed_tranf_per'),
        ('political_party_committee_contributions',
            'pol_pty_cmte_contb_per_ii'),
        ('fed_disbursements', 'ttl_fed_disb_per'),
        ('disbursements', 'ttl_disb_per'),
        ('political_party_committee_contributions',
            'pol_pty_cmte_contb_per_i'),
        ('non_allocated_fed_election_activity',
            'non_alloc_fed_elect_actvy_per'),
        ('debts_owed_by_committee', 'debts_owed_by_cmte'),
        ('coordinated_expenditures_by_party_committee',
            'coord_exp_by_pty_cmte_per'),
        ('shared_fed_activity_nonfed', 'shared_fed_actvy_nonfed_per'),
        ('other_disbursements', 'other_disb_per'),
        ('fed_candidate_committee_contributions', 'fed_cand_cmte_contb_per'),
        ('offsets_to_operating_expendituresenditures',
            'offsets_to_op_exp_per_ii'),
        ('net_contributions', 'net_contb_per'),
        ('individual_unitemized_contributions', 'indv_unitem_contb_per'),
        ('all_loans_received', 'all_loans_received_per'),
        ('contributions', 'ttl_contb_per'),
        ('transfers_from_nonfed_levin', 'tranf_from_nonfed_levin_per'),
        ('debts_owed_to_committee', 'debts_owed_to_cmte'),
        ('shared_fed_operating_expenditures', 'shared_fed_op_exp_per'),
        ('loans_made', 'loans_made_per'),
        ('transfers_to_affiliated_committee', 'tranf_to_affliliated_cmte_per'),
        ('other_political_committee_contributions',
            'other_pol_cmte_contb_per_ii'),
        ('other_fed_receipts', 'other_fed_receipts_per'),
        ('transfers_from_affiliated_party', 'tranf_from_affiliated_pty_per'),
        ('contribution_refunds', 'ttl_contb_ref_per_ii'),
        ('individual_contribution_refunds', 'indv_contb_ref_per'),
        ('transfers_from_nonfed_account', 'tranf_from_nonfed_acct_per'),
        ('fed_operating_expenditures', 'ttl_fed_op_exp_per'),
        ('shared_fed_activity', 'shared_fed_actvy_fed_shr_per'),
        ('fed_candidate_contribution_refunds', 'fed_cand_contb_ref_per'),
        ('operating_expenditures', 'ttl_op_exp_per'),
        ('other_political_committee_contributions',
            'other_pol_cmte_contb_per_i'),
        ('individual_itemized_contributions', 'indv_item_contb_per'),
        ('*', (
            'ttl_contb_ref_per_i,shared_nonfed_op_exp_per,'
            'ttl_fed_receipts_per,loan_repymts_received_per,'
            'offsets_to_op_exp_per_i,indt_exp_per,other_fed_op_exp_per,'
            'loan_repymts_made_per,ttl_fed_elect_actvy_per,ttl_receipts_per,'
            'ttl_nonfed_tranf_per,pol_pty_cmte_contb_per_ii,ttl_fed_disb_per,'
            'ttl_disb_per,pol_pty_cmte_contb_per_i,'
            'non_alloc_fed_elect_actvy_per,coord_exp_by_pty_cmte_per,'
            'shared_fed_actvy_nonfed_per,other_disb_per,'
            'fed_cand_cmte_contb_per,offsets_to_op_exp_per_ii,net_contb_per,'
            'indv_unitem_contb_per,all_loans_received_per,ttl_contb_per,'
            'tranf_from_nonfed_levin_per,shared_fed_op_exp_per,loans_made_per,'
            'tranf_to_affliliated_cmte_per,other_pol_cmte_contb_per_ii,'
            'other_fed_receipts_per,tranf_from_affiliated_pty_per,'
            'ttl_contb_ref_per_ii,indv_contb_ref_per,'
            'tranf_from_nonfed_acct_per,ttl_fed_op_exp_per,'
            'shared_fed_actvy_fed_shr_per,fed_cand_contb_ref_per,'
            'ttl_op_exp_per,other_pol_cmte_contb_per_i,indv_item_contb_per,')),
    )

    house_senate_mapping = (
        # ('cvg_end_dt_sk', 'cvg_end_dt_sk'),
        ('aggregate_amount_personal_contributions_general',
            'agr_amt_pers_contrib_gen'),
        ('refunds_individual_contributions_period', 'ref_indv_contb_per'),
        ('refunds_other_political_committee_contributions_year',
            'ref_other_pol_cmte_contb_ytd'),
        ('end_image_number', 'end_image_num'),
        ('total_offsets_to_operating_expenditures_period',
            'ttl_offsets_to_op_exp_per'),
        ('total_loan_repayments_year', 'ttl_loan_repymts_ytd'),
        ('transfers_from_other_authorized_committee_period',
            'tranf_from_other_auth_cmte_per'),
        ('refunds_political_party_committee_contributions_period',
            'ref_pol_pty_cmte_contb_per'),
        ('candidate_contribution_period', 'cand_contb_per'),
        ('total_contributions_column_total_period',
            'ttl_contb_column_ttl_per'),
        ('transfers_to_other_authorized_committee_period',
            'tranf_to_other_auth_cmte_per'),
        ('net_operating_expenditures_period', 'net_op_exp_per'),
        ('gross_receipt_minus_personal_contribution_general',
            'grs_rcpt_min_pers_contrib_gen'),
        ('gross_receipt_authorized_committee_general',
            'grs_rcpt_auth_cmte_gen'),
        ('transfers_to_other_authorized_committee_year',
            'tranf_to_other_auth_cmte_ytd'),
        ('operating_expenditures_period', 'op_exp_per'),
        ('gross_receipt_minus_personal_contributions_primary',
            'grs_rcpt_min_pers_contrib_prim'),
        ('refunds_other_political_committee_contributions_period',
            'ref_other_pol_cmte_contb_per'),
        ('offsets_to_operating_expenditures_year', 'offsets_to_op_exp_ytd'),
        ('total_individual_itemized_contributions_year',
            'ttl_indv_item_contb_ytd'),
        ('total_loan_repayments_period', 'ttl_loan_repymts_per'),
        ('load_date', 'load_date'),
        ('loan_repayments_candidate_loans_period',
            'loan_repymts_cand_loans_per'),
        ('debts_owed_by_committee', 'debts_owed_by_cmte'),
        ('total_disbursements_period', 'ttl_disb_per_ii'),
        ('candidate_contribution_year', 'cand_contb_ytd'),
        ('transfers_from_other_authorized_committee_year',
            'tranf_from_other_auth_cmte_ytd'),
        ('cash_on_hand_beginning_period', 'coh_bop'),
        ('offsets_to_operating_expenditures_period', 'offsets_to_op_exp_per'),
        ('all_other_loans_year', 'all_other_loans_ytd'),
        # ('cvg_start_dt_sk', 'cvg_start_dt_sk'),
        ('all_other_loans_period', 'all_other_loans_per'),
        ('other_disbursements_period', 'other_disb_per'),
        ('refunds_total_contributions_col_total_year',
            'ref_ttl_contb_col_ttl_ytd'),
        ('other_disbursements_year', 'other_disb_ytd'),
        ('refunds_individual_contributions_year', 'ref_indv_contb_ytd'),
        ('individual_itemized_contributions_period', 'indv_item_contb_per'),
        ('total_loans_year', 'ttl_loans_ytd'),
        ('cash_on_hand_end_period', 'coh_cop_i'),
        ('net_contributions_period', 'net_contb_per'),
        ('net_contributions_year', 'net_contb_ytd'),
        ('individual_unitemized_contributions_period',
            'indv_unitem_contb_per'),
        ('other_political_committee_contributions_year',
            'other_pol_cmte_contb_ytd'),
        ('total_receipts_period', 'ttl_receipts_per_i'),
        ('cash_on_hand_end_period', 'coh_cop_ii'),
        ('total_contribution_refunds_year', 'ttl_contb_ref_ytd'),
        ('other_political_committee_contributions_period',
            'other_pol_cmte_contb_per'),
        ('total_contributions_period', 'ttl_contb_per'),
        ('loan_repayments_candidate_loans_year',
            'loan_repymts_cand_loans_ytd'),
        ('total_disbursements_year', 'ttl_disb_ytd'),
        ('total_offsets_to_operating_expenditures_year',
            'ttl_offsets_to_op_exp_ytd'),
        ('debts_owed_to_committee', 'debts_owed_to_cmte'),
        ('total_operating_expenditures_year', 'ttl_op_exp_ytd'),
        ('report_year', 'rpt_yr'),
        ('gross_receipt_authorized_committee_primary',
            'grs_rcpt_auth_cmte_prim'),
        ('political_party_committee_contributions_period',
            'pol_pty_cmte_contb_per'),
        ('total_contributions_year', 'ttl_contb_ytd'),
        ('loan_repayments_other_loans_period', 'loan_repymts_other_loans_per'),
        ('operating_expenditures_year', 'op_exp_ytd'),
        ('total_loans_period', 'ttl_loans_per'),
        ('total_individual_contributions_year', 'ttl_indv_contb_ytd'),
        ('total_receipts', 'ttl_receipts_ii'),
        ('loan_repayments_other_loans_year', 'loan_repymts_other_loans_ytd'),
        ('refunds_political_party_committee_contributions_year',
            'ref_pol_pty_cmte_contb_ytd'),
        ('beginning_image_number', 'begin_image_num'),
        ('expire_date', 'expire_date'),
        ('political_party_committee_contributions_year',
            'pol_pty_cmte_contb_ytd'),
        ('loans_made_by_candidate_year', 'loans_made_by_cand_ytd'),
        ('total_receipts_year', 'ttl_receipts_ytd'),
        ('total_disbursements_period', 'ttl_disb_per_i'),
        ('other_receipts_period', 'other_receipts_per'),
        ('total_contribution_refunds_col_total_period',
            'ttl_contb_ref_col_ttl_per'),
        ('total_individual_contributions_period', 'ttl_indv_contb_per'),
        ('net_operating_expenditures_year', 'net_op_exp_ytd'),
        ('total_operating_expenditures_period', 'ttl_op_exp_per'),
        ('loans_made_by_candidate_period', 'loans_made_by_cand_per'),
        ('aggregate_contributions_personal_funds_primary',
            'agr_amt_contrib_pers_fund_prim'),
        ('total_contribution_refunds_period', 'ttl_contb_ref_per'),
        ('subtotal_period', 'subttl_per'),
        ('total_individual_unitemized_contributions_year',
            'ttl_indv_unitem_contb_ytd'),
        ('other_receipts_year', 'other_receipts_ytd'),
        ('election_cycle', 'two_yr_period_sk'),
        ('*', '*'),
    )

    # These are used for making the election cycle totals.
    house_senate_totals = (
        ('cycle', 'two_yr_period_sk'),
        ('refunds_individual_contributions', 'ref_indv_contb_per'),
        ('offsets_to_operating_expenditures', 'ttl_offsets_to_op_exp_per'),
        ('transfers_from_other_authorized_committee',
            'tranf_from_other_auth_cmte_per'),
        ('refunds_political_party_committee_contributions',
            'ref_pol_pty_cmte_contb_per'),
        ('transfers_to_other_authorized_committee',
            'tranf_to_other_auth_cmte_per'),
        ('candidate_contribution', 'cand_contb_per'),
        ('operating_expenditures', 'op_exp_per'),
        ('refunds_other_political_committee_contributions',
            'ref_other_pol_cmte_contb_per'),
        ('loan_repayments', 'ttl_loan_repymts_per'),
        ('loan_repayments_candidate_loans', 'loan_repymts_cand_loans_per'),
        ('disbursements', 'ttl_disb_per_ii'),
        ('offsets_to_operating_expenditures', 'offsets_to_op_exp_per'),
        ('all_other_loans', 'all_other_loans_per'),
        ('other_disbursements', 'other_disb_per'),
        ('individual_itemized_contributions', 'indv_item_contb_per'),
        ('individual_unitemized_contributions', 'indv_unitem_contb_per'),
        ('receipts', 'ttl_receipts_per_i'),
        ('other_political_committee_contributions',
            'other_pol_cmte_contb_per'),
        ('contributions', 'ttl_contb_per'),
        ('political_party_committee_contributions', 'pol_pty_cmte_contb_per'),
        ('loan_repayments_other_loans', 'loan_repymts_other_loans_per'),
        ('other_receipts', 'other_receipts_per'),
        ('loans', 'ttl_loans_per'),
        ('disbursements', 'ttl_disb_per_i'),
        ('other_receipts', 'other_receipts_per'),
        ('individual_contributions', 'ttl_indv_contb_per'),
        ('operating_expenditures', 'ttl_op_exp_per'),
        ('loans_made_by_candidate', 'loans_made_by_cand_per'),
        ('contribution_refunds', 'ttl_contb_ref_per'),
        ('*', (
            'ref_indv_contb_per,ttl_offsets_to_op_exp_per,'
            'tranf_from_other_auth_cmte_per,ref_pol_pty_cmte_contb_per,'
            'tranf_to_other_auth_cmte_per,cand_contb_per,op_exp_per,'
            'ref_other_pol_cmte_contb_per,ttl_loan_repymts_per,'
            'loan_repymts_cand_loans_per,ttl_disb_per_ii,'
            'offsets_to_op_exp_per,all_other_loans_per,other_disb_per,'
            'indv_item_contb_per,indv_unitem_contb_per,ttl_receipts_per_i,'
            'other_pol_cmte_contb_per,ttl_contb_per,pol_pty_cmte_contb_per,'
            'loan_repymts_other_loans_per,other_receipts_per,ttl_loans_per,'
            'ttl_disb_per_i,other_receipts_per,ttl_indv_contb_per,'
            'ttl_op_exp_per,loans_made_by_cand_per,ttl_contb_ref_per,')),
    )

    report_mapping = (
        ('expire_date', 'expire_date'),
        ('load_date', 'load_date'),
        ('report_type', 'rpt_tp'),
        ('report_type_full', 'rpt_tp_desc'),
        ('*', '*'),
    )

    dim_mapping = (
        ('load_date', 'load_date'),
        ('committee_id', 'cmte_id'),
        ('expire_date', 'expire_date'),
        ('*', '*'),
    )

    maps_fields = (
        (presidential_mapping, 'presidential_fields'),
        (pac_party_mapping, 'pac_party_fields'),
        (house_senate_mapping, 'house_senate_fields'),
        (report_mapping, 'report_fields'),
        (dim_mapping, 'dimcmte_fields'),
        (house_senate_totals, 'house_senate_totals'),
        (presidential_totals, 'presidential_totals'),
        (pac_party_totals, 'pac_party_totals'),
    )
