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

Totals:

### election_cycle

The four-digit year for the two-year election cycle.

### total_contributions

The sum of all total_contributions_period reported for the election cycle.

### total_disbursements

The sum of all total_disbursements_period reported for the election cycle.

### total_receipts

The sum of all total_receipts_period reported for the election cycle.





