# FEC API Documentation
## Total

Provides key information about committee's finance reports and provides 2-year election totals for key numbers.

## Supported parameters for candidate

| Parameter | Description |
|-----|-----|
| /<committee_id>  | Single committee's record |
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

### end_image_number

image number of the last page of the filing.

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

What kind of report was filed. It can be quarterly, monthy, pre-general, etc.

### report_type_full

The written out description of the report type.

    dim_mapping = (
        ('load_date', 'load_date'),
        ('committee_id', 'cmte_id'),
        ('expire_date', 'expire_date'),
    )


Totals:

### election_cycle

The four-digit year for the two-year election cycle.

### total_contributions

The sum of all total_contributions_period reported for the election cycle.

### total_disbursements

The sum of all total_disbursements_period reported for the election cycle.

### total_receipts

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

---------------------------------------------------



