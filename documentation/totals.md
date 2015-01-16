# FEC API Documentation
## Total

Provides key information about committee's finance reports and provides 2-year election totals for key numbers.

As part of each financial report, committees must provide a summary of their financial activity in each filing, and these summaries for each reporting period are included in these files. Generally, committees file reports on a quarterly or monthly basis, but some must also submit a report 12 days before primary elections. During the primary election season, therefore, the period covered by this file may be different for different committees. These totals also incorporate any changes made by committees if any report covering the period is amended.

There are several different reporting structures, depending on what type of organization is submitting financial information. To see an example of these reporting requirements you can look at the summary and detailed summary pages of the FEC form 3, form 3X and form 3P.

## Supported parameters for candidate

| Parameter | Description |
|-----|-----|
| /<committee_id>  | A single committee's reports and cycle totals. This will be slightly faster that using committee_id as a filter but, only one committee_id is accepted per call. |
| committeee_id=    | Synonym for /<committee_id> |
| fields =    | Comma separated list of fields to display or `*` for all |


---

The numbers in the financial summaries come from form 3 for House and Senate committees, form 3p for presidential committees and form 3x for parties and PACs.

## Supported fields for total

## Supported fields for all types:

### beginning_image_number

Image number of the first page of the filing.

### cash_on_hand_beginning_period

Total liquid assets at the beginning of the reporting period

### debts_owed_by_committee

Total of all the debts owed by a committee.

### debts_owed_to_committee

Total of all the debts owed to a committee.

### election_cycle
The two-year election cycle of the report.

### end_image_number

The image number of the last page of the filing.

### expire_date

If the treasurer, custodian of records, etc., changes, then the current record is expired and the new record is loaded. This is the date the record was updated and no longer up to date.

### load_date

Date the filing was loaded into the system.

### report_year

The year of the report.

### total_contributions_period

The sum of all contributions during the period.

### total_contributions_year

The sum of all contributions for the year to date.

### total_disbursements_period

The sum of all disbursements during the period.

### total_disbursements_year

The sum of all disbursements for the year to date.

### total_receipts_period

The sum of all receipts during the period.

### total_receipts_year

The sum of all receipts for the year to date.

### type

This will be presidential, pac party or House Senate. It corresponds to the form type.

### expire_date



### load_date

The date the report was recorded in the database.

### report_type

What kind of report was filed. It can be quarterly, monthly, pre-general, etc.

### report_type_full

The written-out description of the report type


Totals:

### election_cycle

The four-digit year for the two-year election cycle.

### contributions

The sum of all total_contributions_period reported for the election cycle.

### disbursements

The sum of all total_disbursements_period reported for the election cycle.

### receipts

The sum of all total_receipts_period reported for the election cycle.

----------------------------------------------

## Presidential committee fields

### beginning_image_number

Beginning image number.

### candidate_contribution_period

Candidate contribution during the period.

### candidate_contribution_year

Candidate contribution for the year to date.

### cash_on_hand_beginning_period

Cash on hand beginning during the period.

### cash_on_hand_end_period

Cash on hand end during the period.

### debts_owed_by_committee

Debts owed by committee.

### debts_owed_to_committee

Debts owed to committee.

### end_image_number

End image number.

### exempt_legal_accounting_disbursement_period

Exempt legal accounting disbursement during the period.

### exempt_legal_accounting_disbursement_year

Exempt legal accounting disbursement for the year to date.

### expire_date

Expire date.

### federal_funds_period

Federal funds during the period.

### federal_funds_year

Federal funds for the year to date.

### fundraising_disbursements_period

Fundraising disbursements during the period.

### fundraising_disbursements_year

Fundraising disbursements for the year to date.

### individual_contributions_period

Individual contributions during the period.

### individual_contributions_year

Individual contributions for the year to date.

### items_on_hand_liquidated

Items on hand liquidated.

### load_date

Load date.

### loans_received_from_candidate_period

Loans received from candidate during the period.

### loans_received_from_candidate_year

Loans received from candidate for the year to date.

### net_contribution_summary_period

Net contribution summary during the period.

### net_operating_expenses_summary_period

Net operating expenses summary during the period.

### offsets_to_fundraising_expenses_period

Offsets to fundraising expenses during the period.

### offsets_to_fundraising_exp_year

Offsets to fundraising expenditures for the year to date.

### offsets_to_legal_accounting_period

Offsets to legal accounting during the period.

### offsets_to_legal_accounting_year

Offsets to legal accounting for the year to date.

### offsets_to_operating_expenditures_period

Offsets to operating expenditures during the period.

### offsets_to_operating_expenditures_year

Offsets to operating expenditures for the year to date.

### operating_expenditures_period

Operating expenditures during the period.

### operating_expenditures_year

Operating expenditures for the year to date.

### other_disbursements_period

Other disbursements during the period.

### other_disbursements_year

Other disbursements for the year to date.

### other_loans_received_period

Other loans received during the period.

### other_loans_received_year

Other loans received for the year to date.

### other_political_committee_contributions_period

Other political committee contributions during the period.

### other_political_committee_contributions_year

Other political committee contributions for the year to date.

### other_receipts_period

Other receipts during the period.

### other_receipts_year

Other receipts for the year to date.

### political_party_committee_contributions_period

Political party committee contributions during the period.

### political_party_committee_contributions_year

Political party committee contributions for the year to date.

### refunds_individual_contributions_period

Refunds individual contributions during the period.

### refunded_individual_contributions_year

Refunded individual contributions for the year to date.

### refunded_other_political_committee_contributions_period

Refunded other political committee contributions during the period.

### refunded_other_political_committee_contributions_year

Refunded other political committee contributions for the year to date.

### refunded_political_party_committee_contributions_period

Refunded political party committee contributions during the period.

### refunded_political_party_committee_contributions_year

Refunded political party committee contributions for the year to date.

### repayments_loans_made_by_candidate_period

Repayments loans made by candidate during the period.

### repayments_loans_made_candidate_year

Repayments loans made candidate for the year to date.

### repayments_other_loans_period

Repayments other loans during the period.

### repayments_other_loans_year

Repayments other loans for the year to date.

### report_year

Report for the year to date.

### subtotal_summary_period

Subtotal summary during the period.

### transfer_from_affiliated_committee_period

Transfer from affiliated committee during the period.

### transfer_from_affiliated_committee_year

Transfer from affiliated committee for the year to date.

### transfer_to_other_authorized_committee_period

Transfer to other authorized committee during the period.

### transfer_to_other_authorized_committe_year

transfer to other authorized committee for the year to date.

### total_contributions_period

Total contributions during the period.

### total_contribution_refunds_period

Total contribution refunds during the period.

### total_contribution_refunds_year

Total contribution refunds for the year to date.

### total_contributions_year

Total contributions for the year to date.

### total_disbursements_period

Total disbursements during the period.

### total_disbursements_summary_period

Total disbursements summary during the period.

### total_disbursements_year

Total disbursements for the year to date.

### total_loan_repayments_made_period

Total loan repayments made during the period.

### total_loan_repayments_made_year

Total loan repayments made for the year to date.

### total_loans_received_period

Total loans received during the period.

### total_loans_received_year

Total loans received for the year to date.

### total_offsets_to_operating_expenditures_period

Total offsets to operating expenditures during the period.

### total_offsets_to_operating_expenditures_year

Total offsets to operating expenditures for the year to date.

### total_period

Total during the period.

### total_receipts_period

Total receipts during the period.

### total_receipts_summary_period

Total receipts from the summary page during the period.

### total_receipts_year

Total receipts for the year to date.

### total_year

Total for the year to date.


## Presidential committee total fields

All total fields sum the period reports for the two-year election cycles to create totals. for example, 'receipts' in totals is the sum of total_receipts_period during the election cycle. All totals are grouped by election cycle

### cycle

A four-digit number for the two-year election cycle.

### candidate_contribution

Total candidate contribution for the two-year election cycle.

### exempt_legal_accounting_disbursement

Total exempt legal accounting disbursement for the two-year election cycle.

### federal_funds

Total federal funds for the two-year election cycle.

### fundraising_disbursements

Total fundraising disbursements for the two-year election cycle.

### individual_contributions

Total individual contributions for the two-year election cycle.

### loans_received_from_candidate

Total loans received from candidate for the two-year election cycle.

### offsets_to_fundraising_expenses

Total offsets to fundraising expenses for the two-year election cycle.

### offsets_to_legal_accounting

Total offsets to legal accounting for the two-year election cycle.

### offsets_to_operating_expenditures

Total offsets to operating expenditures for the two-year election cycle.

### operating_expenditures

Total operating expenditures for the two-year election cycle.

### other_disbursements

Total other disbursements for the two-year election cycle.

### other_loans_received

Total other loans received for the two-year election cycle.

### other_political_committee_contributions

Total other political committee contributions for the two-year election cycle.

### other_receipts

Total other receipts for the two-year election cycle.

### political_party_committee_contributions

Total political party committee contributions for the two-year election cycle.

### refunds_individual_contributions

Total refunds individual contributions for the two-year election cycle.

### refunded_other_political_committee_contributions

Total refunded other political committee contributions for the two-year election cycle.

### refunded_political_party_committee_contributions

Total refunded political party committee contributions for the two-year election cycle.

### repayments_loans_made_by_candidate

Total repayments loans made by candidate for the two-year election cycle.

### repayments_other_loans

Total repayments other loans for the two-year election cycle.

### transfer_from_affiliated_committee

Total transfer from affiliated committee for the two-year election cycle.

### transfer_to_other_authorized_committee

Total transfer to other authorized committee for the two-year election cycle.

### contributions

Total contributions for the two-year election cycle.

### contribution_refunds

Total contribution refunds for the two-year election cycle.

### disbursements

Total disbursements for the two-year election cycle.

### loan_repayments_made

Total loan repayments made for the two-year election cycle.

### loans_received

Total loans received for the two-year election cycle.

### offsets_to_operating_expenditures

Total offsets to operating expenditures for the two-year election cycle.

### receipts

Total receipts for the two-year election cycle.


---------------------------------------------------


## House and Senate committee fields

### refunds_individual_contributions_period

Refunds individual contributions during the period.

### refunds_other_political_committee_contributions_year

Refunds other political committee contributions for the year to date.

### end_image_number

End image number.

### total_offsets_to_operating_expenditures_period

Total offsets to operating expenditures during the period.

### total_loan_repayments_year

Total loan repayments for the year to date.

### transfers_from_other_authorized_committee_period

Transfers from other authorized committee during the period.

### refunds_political_party_committee_contributions_period

Refunds political party committee contributions during the period.

### candidate_contributions_period

Candidate contributions during the period.

### total_contributions_column_total_period

Total contributions column total during the period.

### transfers_to_other_authorized_committee_period

Transfers to other authorized committee during the period.

### net_operating_expenditures_period

Net operating expenditures during the period.

### gross_receipt_minus_personal_contributions_primary

Gross receipts minus personal contributions primary (Form 3 -- BCRA Millionaire's Amendment ruled unconstitutional Davis v FEC)

### gross_receipts_authorized_committee_general

Gross receipts authorized committee in the general election.

### transfers_to_other_authorized_committee_year

Transfers to other authorized committee for the year to date.

### operating_expenditures_period

Operating expenditures during the period.

### gross_receipt_minus_personal_contributions_primary

Gross receipts minus personal contributions in the primary.

### refunds_other_political_committee_contributions_period

Refunds other political committee contributions during the period.

### offsets_to_operating_expenditures_year

Offsets to operating expenditures for the year to date.

### total_individual_itemized_contributions_year

Total individual itemized contributions for the year to date. Contributions under $200 are not itemized.

### total_loan_repayments_period

Total loan repayments during the period.

### load_date

Load date.

### loan_repayments_candidate_loans_period

Loan repayments candidate loans during the period.

### debts_owed_by_committee

Debts owed by committee.

### total_disbursements_period

Total disbursements during the period.

### candidate_contributions_year

Candidate contributions for the year to date.

### transfers_from_other_authorized_committee_year

Transfers from other authorized committee for the year to date.

### cash_on_hand_beginning_period

Cash on hand beginning during the period.

### offsets_to_operating_expenditures_period

Offsets to operating expenditures during the period.

### all_other_loans_year

All other loans for the year to date.

### all_other_loans_period

All other loans during the period.

### other_disbursements_period

Other disbursements during the period.

### refunds_total_contributions_col_total_year

Refunds total contributions col total for the year to date.

### other_disbursements_year

Other disbursements for the year to date.


### refunds_individual_contributions_year

Refunds individual contributions for the year to date.

### individual_itemized_contributions_period

Individual itemized contributions during the period.

### total_loans_year

Total loans for the year to date.

### cash_on_hand_end_period

Cash on hand end during the period.

### net_contributions_period

Net contributions during the period.

### net_contributions_year

Net contributions for the year to date.

### individual_unitemized_contributions_period

Individual unitemized contributions during the period.

### other_political_committee_contributions_year

Other political committee contributions for the year to date.

### total_receipts_period

Total receipts during the period.

### cash_on_hand_end_period

Cash on hand end during the period.

### total_contribution_refunds_year

Total contributions refunds for the year to date.

### other_political_committee_contributions_period

Other political committee contributions during the period.

### total_contributions_period

Total contributions during the period.

### loan_repayments_candidate_loans_year

Loan repayments candidate loans for the year to date.

### total_disbursements_year

Total disbursements for the year to date.

### total_offsets_to_operating_expenditures_year

Total offsets to operating expenditures for the year to date.

### debts_owed_to_committee

Debts owed to committee.

### total_operating_expenditures_year

Total operating expenditures for the year to date.

### report_year

Report for the year to date.

### gross_receipt_authorized_committee_primary

Gross receipt authorized committee primary.

### political_party_committee_contributions_period

Political party committee contributions during the period.

### total_contributions_year

Total contributions for the year to date.

### loan_repayments_other_loans_period

Loan repayments other loans during the period.

### operating_expenditures_year

Operating expenditures for the year to date.

### total_loans_period

Total loans during the period.

### total_individual_contributions_year

Total individual contributions for the year to date.

### total_receipts

Total receipts.

### loan_repayments_other_loans_year

Loan repayments other loans for the year to date.

### refunds_political_party_committee_contributions_year

Refunds political party committee contributions for the year to date.

### beginning_image_number

Beginning image number.

### expire_date

Expire date.

### political_party_committee_contributions_year

Political party committee contributions for the year to date.

### loans_made_by_candidate_year

Loans made by candidate for the year to date.

### total_receipts_year

Total receipts for the year to date.

### total_disbursements_period

Total disbursements during the period.

### other_receipts_period

Other receipts during the period.

### total_contribution_refunds_col_total_period

Total contribution refunds col total during the period.

### total_individual_contributions_period

Total individual contributions during the period.

### net_operating_expenditures_year

Net operating expenditures for the year to date.

### total_operating_expenditures_period

Total operating expenditures during the period.

### loans_made_by_candidate_period

Loans made by candidate during the period.

### aggregate_contributions_personal_funds_primary

Aggregate amount contributed from personal funds - primary (Form 3 -- BCRA Millionaire's Amendment ruled unconstitutional Davis v FEC)

### total_contribution_refunds_period

Total contribution refunds during the period.

### subtotal_period

Subtotal during the period.

### total_individual_unitemized_contributions_year

Total individual unitemized contributions for the year to date.

### other_receipts_year

Other receipts for the year to date.


## House and Senate total fields

All total fields sum the period reports for the two-year election cycles to create totals. for example, 'receipts' in totals is the sum of total_receipts_period during the election cycle. All totals are grouped by election cycle

### cycle

The four-digit number for the two-year election cycle.

### refunds_individual_contributions

Total refunds individual contributions for the two-year election cycle.

### offsets_to_operating_expenditures

Total offsets to operating expenditures for the two-year election cycle.

### transfers_from_other_authorized_committee

Total transfers from other authorized committee for the two-year election cycle.

### refunds_political_party_committee_contributions

Total refunds political party committee contributions for the two-year election cycle.

### transfers_to_other_authorized_committee

Total transfers to other authorized committee for the two-year election cycle.

### candidate_contribution

Total candidate contribution for the two-year election cycle.

### operating_expenditures

Total operating expenditures for the two-year election cycle.

### refunds_other_political_committee_contributions

Total refunds other political committee contributions for the two-year election cycle.

### loan_repayments

Total loan repayments for the two-year election cycle.

### loan_repayments_candidate_loans

Total loan repayments candidate loans for the two-year election cycle.

### disbursements

Total disbursements for the two-year election cycle.

### offsets_to_operating_expenditures

Total offsets to operating expenditures for the two-year election cycle.

### all_other_loans

Total all other loans for the two-year election cycle.

### other_disbursements

Total other disbursements for the two-year election cycle.

### individual_itemized_contributions

Total individual itemized contributions for the two-year election cycle.

### individual_unitemized_contributions

Total individual unitemized contributions for the two-year election cycle.

### receipts

Total receipts for the two-year election cycle.

### other_political_committee_contributions

Total other political committee contributions for the two-year election cycle.

### contributions

Total contributions for the two-year election cycle.

### political_party_committee_contributions

Total political party committee contributions for the two-year election cycle.

### loan_repayments_other_loans

Total loan repayments other loans for the two-year election cycle.

### other_receipts

Total other receipts for the two-year election cycle.

### loans

Total loans for the two-year election cycle.

### disbursements

Total disbursements for the two-year election cycle.

### other_receipts

Total other receipts for the two-year election cycle.

### individual_contributions

Total individual contributions for the two-year election cycle.

### operating_expenditures

Total operating expenditures for the two-year election cycle.

### loans_made_by_candidate

Total loans made by candidate for the two-year election cycle.

### contribution_refunds

Total contribution refunds for the two-year election cycle.


-----------------------------------------------

## PAC and Party committee fields

### election_type_sk

Election type sk.

### end_image_number

End image number.

### individual_contribution_refunds_year

Individual contributions refunds for the year to date.

### total_contribution_refunds_period_i

Total contributions refunds during the period i.

### shared_nonfed_operating_expenditures_period

Shared nonfed operating expenditures during the period.

### shared_fed_activity_nonfed_year

Shared fed activity nonfed for the year to date.

### other_political_committee_contributions_year

Other political committee contributions for the year to date.

### subtotal_summary_page_period

Subtotal summary page during the period.

### total_fed_receipts_period

Total fed receipts during the period.

### net_operating_expenditures_period

Net operating expenditures during the period.

### shared_fed_activity_year

Shared fed activity for the year to date.

### loan_repymts_received_period

Loan repymts received during the period.

### cash_on_hand_close_year

Cash on hand close for the year to date.

### offsets_to_operating_expendituresenditures_period

Offsets to operating expendituresenditures during the period.

### cash_on_hand_end_period

Cash on hand end during the period.

### independent_expenditures_period

Independent expenditures during the period.

### other_fed_operating_expenditures_period

Other fed operating expenditures during the period.

### loan_repayments_made_period

Loan repayments made during the period.

### total_fed_elect_activity_period

Total fed elect activity during the period.

### total_receipts_period

Total receipts during the period.

### total_nonfed_transfers_period

Total nonfed transfers during the period.

### political_party_committee_contributions_period

Political party committee contributions during the period.

### total_nonfed_transfers_year

Total nonfed transfers for the year to date.

### total_fed_disbursements_period

Total fed disbursements during the period.

### offsets_to_operating_expendituresenditures_year

Offsets to operating expendituresenditures for the year to date.

### total_disbursements_period

Total disbursements during the period.

### non_allocated_fed_election_activity_year

Non allocated fed election activity for the year to date.

### subtotal_summary_year

Subtotal summary for the year to date.

### political_party_committee_contributions_period

Political party committee contributions during the period.

### all_loans_received_year

All loans received for the year to date.

### load_date

Load date.

### total_fed_election_activity_year

Total fed election activity for the year to date.

### total_operating_expenditures_year

Total operating expenditures for the year to date.

### non_allocated_fed_election_activity_period

Non allocated fed election activity during the period.

### fed_candidate_committee_contribution_refunds_year

Fed candidate committee contributions refunds for the year to date.

### debts_owed_by_committee

Debts owed by committee.

### loan_repayments_received_year

Loan repayments received for the year to date.

### cash_on_hand_beginning_period

Cash on hand beginning during the period.

### total_receipts_summary_page_year

Total receipts summary page for the year to date.

### coordinated_expenditures_by_party_committee_year

Coordinated expenditures by party committee for the year to date.

### loan_repayments_made_year

Loan repayments made for the year to date.

### coordinated_expenditures_by_party_committee_period

Coordinated expenditures by party committee during the period.

### shared_fed_activity_nonfed_period

Shared fed activity nonfed during the period.

### transfers_to_affilitated_committees_year

Transfers to affilitated committees for the year to date.

### individual_itemized_contributions_year

Individual itemized contributions for the year to date.

### other_disbursements_period

Other disbursements during the period.

### fed_candidate_committee_contributions_year

Fed candidate committee contributions for the year to date.

### other_disbursements_year

Other disbursements for the year to date.

### loans_made_year

Loans made for the year to date.

### total_disbursements_summary_page_year

Total disbursements summary page for the year to date.

### fed_candidate_committee_contributions_period

Fed candidate committee contributions during the period.

### offsets_to_operating_expendituresenditures_period

Offsets to operating expendituresenditures during the period.

### net_contributions_period

Net contributions during the period.

### net_contributions_year

Net contributions for the year to date.

### individual_unitemized_contributions_period

Individual unitemized contributions during the period.

### total_receipts_summary_page_period

Total receipts summary page during the period.

### political_party_committee_contributions_year

Political party committee contributions for the year to date.

### all_loans_received_period

All loans received during the period.

### cash_on_hand_beginning_calendar_year

Cash on hand at the beginning of the calendar year.

### total_individual_contributions

Total individual contributions.

### total_contributions_period

Total contributions during the period.

### offsets_to_operating_expenditures_year

Offsets to operating expenditures for the year to date.

### transfers_from_nonfed_levin_period

Transfers from non-federal levin funds (state and local party money that can spend on voter registration and get-out-the-vote activities related to federal elections) during the period.

### total_disbursements_year

Total disbursements for the year to date.

### political_party_committee_contributions_year

Political party committee contributions for the year to date.

### debts_owed_to_committee

Debts owed to committee.

### shared_fed_operating_expenditures_period

Shared fed operating expenditures during the period.

### transfers_from_nonfed_levin_year

Transfers from non-federal levin funds (state and local party money that can spend on voter registration and get-out-the-vote activities related to federal elections) for the year to date.

### loans_made_period

Loans made during the period.

### transfers_from_affiliated_party_year

Transfers from affiliated party for the year to date.

### transfers_to_affliliated_committee_period

Transfers to affiliated committee during the period.

### independent_expenditures_year

Independent expenditures for the year to date.

### other_fed_receipts_year

Other fed receipts for the year to date.

### total_contribution_refunds_year

Total contributions refunded for the year to date.

### report_year

Report for the year to date.

### other_political_committee_contributions_period

Other political committee contributions during the period.

### total_contributions_year

Total contributions for the year to date.

### other_fed_receipts_period

Other fed receipts during the period.

### transfers_from_affiliated_party_period

Transfers from affiliated party during the period.

### individual_unitemized_contributions_year

Individual unitemized contributions for the year to date.

### total_fed_disbursements_year

Total fed disbursements for the year to date.

### total_fed_operating_expenditures_year

Total fed operating expenditures for the year to date.

### total_individual_contributions_year

Total individual contributions for the year to date.

### other_fed_operating_expenditures_year

Other fed operating expenditures for the year to date.

### total_contribution_refunds_period

Total contribution refunds during the period.

### beginning_image_number

Beginning image number.

### expire_date

Expire date.

### individual_contribution_refunds_period

Individual contribution refunds during the period.

### total_contribution_refunds_year

Total contribution refunds for the year to date.

### transfers_from_nonfed_account_period

Transfers from non-federal account during the period.

### total_fed_operating_expenditures_period

Total fed operating expenditures during the period.

### shared_fed_operating_expenditures_year

Shared fed operating expenditures for the year to date.

### total_fed_receipts_year

Total fed receipts for the year to date.

### shared_fed_activity_period

Shared fed activity during the period.

### shared_nonfed_operating_expenditures_year

Shared non-federal operating expenditures for the year to date.

### fed_candidate_contribution_refunds_period

Fed candidate contributions refunds during the period.

### net_operating_expenditures_year

Net operating expenditures for the year to date.

### total_operating_expenditures_period

Total operating expenditures during the period.

### transfers_from_nonfed_account_year

Transfers from non-federal account for the year to date.

### other_political_committee_contributions_period

Other political committee contributions during the period.

### total_disbursements_summary_page_period

Total disbursements summary page during the period.

### other_political_committee_contributions_year

Other political committee contributions for the year to date.

### total_receipts_year

Total receipts for the year to date.

### individual_itemized_contributions_period

Individual itemized contributions during the period.

### calendar_year

Calendar year of the report.


## PAC and Party total fields

All total fields sum the period reports for the two-year election cycles to create totals. for example, 'receipts' in totals is the sum of total_receipts_period during the election cycle. All totals are grouped by election cycle.


### cycle

A four-digit number for the two-year election cycle.

### contribution_refunds

Total contribution refunds for the two-year election cycle.

### shared_nonfed_operating_expenditures

Total shared non-federal operating expenditures for the two-year election cycle.

### fed_receipts

Total fed receipts for the two-year election cycle.

### loan_repayments_received

Total loan repayments received for the two-year election cycle.

### offsets_to_operating_expenditures

Total offsets to operating expenditures for the two-year election cycle.

### independent_expenditures

Total independent expenditures for the two-year election cycle.

### other_fed_operating_expenditures

Total other fed operating expenditures for the two-year election cycle.

### loan_repayments_made

Total loan repayments made for the two-year election cycle.

### fed_elect_activity

Total fed elect activity for the two-year election cycle.

### receipts

Total receipts for the two-year election cycle.

### nonfed_transfers

Total non-federal transfers for the two-year election cycle.

### political_party_committee_contributions

Total political party committee contributions for the two-year election cycle.

### fed_disbursements

Total total fed disbursements for the two-year election cycle.

### disbursements

Total total disbursements for the two-year election cycle.

### political_party_committee_contributions

Total political party committee contributions for the two-year election cycle.

### non_allocated_fed_election_activity

Total non allocated fed election activity for the two-year election cycle.

### coordinated_expenditures_by_party_committee

Total coordinated expenditures by party committee for the two-year election cycle.

### shared_fed_activity_nonfed

Total shared fed activity non-federal for the two-year election cycle.

### other_disbursements

Total other disbursements for the two-year election cycle.

### fed_candidate_committee_contributions

Total fed candidate committee contributions for the two-year election cycle.

### offsets_to_operating_expendituresenditures

Total offsets to operating expenditures for the two-year election cycle.

### net_contributions

Total net contributions for the two-year election cycle.

### individual_unitemized_contributions

Total individual unitemized contributions for the two-year election cycle.

### all_loans_received

Total of all loans received for the two-year election cycle.

### contributions

Total contributions for the two-year election cycle.

### transfers_from_nonfed_levin

Total transfers from non-federal levin funds for the two-year election cycle.

### shared_fed_operating_expenditures

Total shared fed operating expenditures for the two-year election cycle.

### loans_made

Total loans made for the two-year election cycle.

### transfers_to_affiliated_committee

Total transfers to affiliated committee for the two-year election cycle.

### other_political_committee_contributions

Total of other political committee contributions for the two-year election cycle.

### other_fed_receipts

Total of other federal receipts for the two-year election cycle.

### transfers_from_affiliated_party

Total transfers from affiliated party for the two-year election cycle.

### contribution_refunds

Total total contribution refunds for the two-year election cycle.

### individual_contribution_refunds

Total individual contribution refunds for the two-year election cycle.

### transfers_from_nonfed_account

Total transfers from non-federal accounts for the two-year election cycle.

### fed_operating_expenditures

Total total fed operating expenditures for the two-year election cycle.

### shared_fed_activity

Total shared fed activity for the two-year election cycle.

### fed_candidate_contribution_refunds

Total fed candidate contribution refunds for the two-year election cycle.

### operating_expenditures

Total total operating expenditures for the two-year election cycle.

### other_political_committee_contributions

Total other political committee contributions for the two-year election cycle.

### individual_itemized_contributions

Total individual itemized contributions for the two-year election cycle.

