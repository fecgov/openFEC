

"""Narrative API documentation."""
API_DESCRIPTION = '''
This application programming interface (API) allows you to explore the way \
candidates and committees fund their campaigns.

The Federal Election Commission (FEC) API is a RESTful web service supporting full-text and field-specific searches on
FEC data. [Bulk downloads](https://www.fec.gov/data/advanced/?tab=bulk-data) are available on the current
site. Information is tied to the underlying forms by file ID and image ID. Data are updated
nightly.

There are a lot of data, and a good place to start is to use search to find
interesting candidates and committees. Then, you can use their IDs to find report or line
item details with the other endpoints. If you are interested in individual donors, check
out contributor information in the `/schedule_a/` endpoints.

<b class="body" id="getting_started_head">Getting started with the openFEC API</b><br>

If you would like to use the FEC's API programmatically, you can sign up for your own API \
key using our form. Alternatively, you can still try out our API without an API key by using \
the web interface and using DEMO_KEY. Note that when you use the openFEC API you are \
subject to the [Terms of Service](https://github.com/fecgov/FEC/blob/master/TERMS-OF-SERVICE.md) \
and [Acceptable Use policy](https://github.com/fecgov/FEC/blob/master/ACCEPTABLE-USE-POLICY.md).

Signing up for an API key will enable you to place up to 1,000 calls an hour. Each call \
is limited to 100 results per page. You can email questions, comments or a request to get \
a key for 7,200 calls an hour (120 calls per minute) to <a href="mailto:APIinfo@fec.gov">APIinfo@fec.gov</a>. You \
can also ask questions and discuss the data in a community led \
[group](https://groups.google.com/forum/#!forum/fec-data).

The model definitions and schema are available at [/swagger](/swagger/). This is useful for
making wrappers and exploring the data.

A few restrictions limit the way you can use FEC data. For example, you can’t use contributor
lists for commercial purposes or to solicit donations.
[Learn more here](https://www.fec.gov/updates/sale-or-use-contributor-information/).

[Inspect our source code](https://github.com/fecgov/openFEC). We welcome issues and pull requests!

<p><br></p>
<h2 class="title" id="signup_head">Sign up for an API key</h2>
<div id="apidatagov_signup">Loading signup form...</div>
'''


PAGES = '''
Number of pages in the document
'''

SORT = '''
Provide a field to sort by. Use `-` for descending order. \
ex: `-case_no`
'''

# ======== candidate start ===========
CANDIDATE_TAG = '''
Candidate endpoints give you access to information about the people running for office.
This information is organized by `candidate_id`. If you're unfamiliar with candidate IDs,
using `/candidates/search/` will help you locate a particular candidate.

Officially, a candidate is an individual seeking nomination for election to a federal
office. People become candidates when they (or agents working on their behalf)
raise contributions or make expenditures that exceed $5,000.

The candidate endpoints primarily use data from FEC registration
[Form 1](https://www.fec.gov/resources/cms-content/documents/fecfrm1.pdf) for committee information and
[Form 2](https://www.fec.gov/resources/cms-content/documents/fecfrm2.pdf) for candidate information.
'''

CANDIDATE_ID = '''
A unique identifier assigned to each candidate registered with the FEC.
If a person runs for several offices, that person will have separate candidate IDs for each office.
First character indicates office - [P]residential, [H]ouse, [S]enate].
Second character is the last digit of the two-year period the ID was created.
Third and fourth is the candidate state. Presidential IDs don't have state.
Fifth and sixth is the district when the candidate first ran. This does not change if the
candidate/member's district changes during re-districting. Presidential IDs don't have districts.
The rest is sequence.
'''

CANDIDATE_INACTIVE = '''
True indicates that a candidate is inactive.
'''

CANDIDATE_CYCLE = '''
Two-year election cycle in which a candidate runs for office.
Calculated from Form 2. The cycle begins with
an odd year and is named for its ending, even year. This cycle follows
the traditional house election cycle and subdivides the presidential
and Senate elections into comparable two-year blocks. To retrieve data for
the entire four years of a presidential term or six years of a senatorial term,
you will need the `election_full` flag.
'''

# committee uses a different definition for cycle because it is less straight forward
CYCLE = '''
Filter records to only those that are applicable to a given two-year
period. This cycle follows the traditional House election cycle and
subdivides the presidential and Senate elections into comparable
two-year blocks. The cycle begins with an odd year and is named for its
ending, even year.
'''

NAME_SEARCH = '''
Search for candidates or committees by name. If you're looking for information on a
particular person or group, using a name to find the `candidate_id` or `committee_id` on
this endpoint can be a helpful first step.
'''

CANDIDATE_LIST = '''
Fetch basic information about candidates, and use parameters to filter results to the
candidates you're looking for.

Each result reflects a unique FEC candidate ID. That ID is particular to the candidate for a
particular office sought. If a candidate runs for the same office multiple times, the ID
stays the same. If the same person runs for another office — for example, a House
candidate runs for a Senate office — that candidate will get a unique ID for each office.
'''

CANDIDATE_HISTORY = '''
Find out a candidate's characteristics over time. This is particularly useful if the
candidate runs for the same office in different districts or you want to know more about a candidate's
previous races.

This information is organized by `candidate_id`, so it won't help you find a candidate
who ran for different offices over time; candidates get a new ID for each office.
'''

CANDIDATE_SEARCH = '''
Fetch basic information about candidates and their principal committees.

Each result reflects a unique FEC candidate ID. That ID is assigned to the candidate for a
particular office sought. If a candidate runs for the same office over time, that ID
stays the same. If the same person runs for multiple offices — for example, a House
candidate runs for a Senate office — that candidate will get a unique ID for each office.

The candidate endpoints primarily use data from FEC registration
[Form 1](https://www.fec.gov/pdf/forms/fecfrm1.pdf) for committee information and
[Form 2](https://www.fec.gov/pdf/forms/fecfrm2.pdf) for candidate information.
'''

CANDIDATE_DETAIL = '''
This endpoint is useful for finding detailed information about a particular candidate. Use the
`candidate_id` to find the most recent information about that candidate.
'''

CANDIDATE_NAME = 'Name of candidate running for office'

OFFICE_FULL = 'Federal office candidate runs for: House, Senate or presidential'

OFFICE = 'Federal office candidate runs for: H, S or P'

STATE = 'US state or territory where a candidate runs for office'

YEAR = 'Retrieve records pertaining to a particular election year. The list of election years \
is based on a candidate filing a statement of candidacy (F2) for that year.'

DISTRICT = 'Two-digit US House distirict of the office the candidate is running for. \
Presidential, Senate and House at-large candidates will have District 00.'

CANDIDATE_STATUS = 'One-letter code explaining if the candidate is:\n\
        - C present candidate\n\
        - F future candidate\n\
        - N not yet a candidate\n\
        - P prior candidate\n\
'

LAST_F2_DATE = 'The day the FEC received the candidate\'s most recent Form 2'

FIRST_CANDIDATE_FILE_DATE = 'The day the FEC received the candidate\'s first filing. \
This is a F2 candidate registration.'

LAST_CANDIDATE_FILE_DATE = 'The day the FEC received the candidate\'s most recent filing'

INCUMBENT_CHALLENGE = "One-letter code ('I', 'C', 'O') explaining if the candidate is an incumbent, a challenger, \
or if the seat is open."

INCUMBENT_CHALLENGE_FULL = 'Explains if the candidate is an incumbent, a challenger, or if the seat is open.'

ACTIVE_THROUGH = 'Last year a candidate was active. This field is specific to the candidate_id so \
if the same person runs for another office, there may be a different record for them.'

HAS_RAISED_FUNDS = 'A boolean that describes if a candidate\'s committee has ever received any receipts \
for their campaign for this particular office. (Candidates have separate candidate IDs for each office.)'

FEDERAL_FUNDS_FLAG = 'A boolean the describes if a presidential candidate has accepted federal funds. \
The flag will be false for House and Senate candidates.'

CANDIDATE_ELECTION_YEARS = 'Years in which a candidate ran for office.'

CANDIDATE_ELECTION_YEAR = 'Year a candidate runs for federal office.'

ROUNDED_ELECTION_YEARS = 'Rounded election years in which a candidate ran for office'

FEC_CYCLES_IN_ELECTION = 'FEC cycles are included in candidate election years.'

LAST_CANDIDATE_ELECTION_YEAR = 'The last year of the cycle for this election.'

F2_CANDIDATE_CITY = 'City of candidate\'s address, as reported on their Form 2.'

F2_CANDIDATE_STATE = 'State of candidate\'s address, as reported on their Form 2.'

F2_CANDIDATE_STREET_1 = 'Street of candidate\'s address, as reported on their Form 2.'

F2_CANDIDATE_STREET_2 = 'Additional street information of candidate\'s address, as reported on their Form 2.'

F2_CANDIDATE_ZIP = 'Zip code of candidate\'s address, as reported on their Form 2.'

AGGREGATE_BY = 'Candidate totals aggregate_by (Chose one of dropdown options):\n\
        - \' \' grouped by election year\n\
        - office grouped by election year, by office\n\
        - office-state grouped by election year, by office, by state\n\
        - office-state-district grouped by election year, by office, by state, by district\n\
        - office-party grouped by election year, by office, by party\n\
'
# ======== candidate end ===========

# ======== committee start ===========
COMMITTEE_TAG = '''
Committees are entities that spend and raise money in an election. Their characteristics and
relationships with candidates can change over time.

You might want to use filters or search endpoints to find the committee you're looking
for. Then you can use other committee endpoints to explore information about the committee
that interests you.

Financial information is organized by `committee_id`, so finding the committee you're interested in
will lead you to more granular financial information.

The committee endpoints include all FEC filers, even if they aren't registered as a committee.

Officially, committees include the committees and organizations that file with the FEC.
Several different types of organizations file financial reports with the FEC:

*Campaign committees authorized by particular candidates to raise and spend funds in
their campaigns. Non-party committees (e.g., PACs), some of which may be sponsored by corporations,
unions, trade or membership groups, etc. Political party committees at the national, state, and local levels.
Groups and individuals making only independent expenditures
Corporations, unions, and other organizations making internal communications*

The committee endpoints primarily use data from FEC registration Form 1 and Form 2.
'''

COMMITTEE_ID = '''
A unique identifier assigned to each committee or filer registered with the FEC. In general \
committee id's begin with the letter C which is followed by eight digits.
'''

COMMITTEE_NAME = 'The name of the committee. If a committee changes its name, \
    the most recent name will be shown. Committee names are not unique. Use committee_id \
    for looking up records.'

COMMITTEE_LIST = '''
Fetch basic information about committees and filers. Use parameters to filter for
particular characteristics.

'''

COMMITTEE_DETAIL = '''
This endpoint is useful for finding detailed information about a particular committee or
filer. Use the `committee_id` to find the most recent information about the committee.
'''

COMMITTEE_HISTORY = '''
Explore a filer's characteristics over time. This can \
be particularly useful if the committees change \
treasurers, designation, or `committee_type`.
'''

COMMITTEE_CYCLE = '''
A two year election cycle that the committee was active- (after original registration
date but before expiration date in Form 1s) The cycle begins with
an odd year and is named for its ending, even year.
'''

COMMITTEE_CYCLES_HAS_FINANCIAL = '''
A two year election cycle that the committee was active- (after original registration
date but before expiration date in Form 1s), and the committee files the financial reports
('F3', 'F3X', 'F3P', 'F3L', 'F4', 'F5', 'F7', 'F13') during this cycle.
'''

COMMITTEE_LAST_CYCLE_HAS_FINANCIAL = '''
The latest two year election cycle that the committee files the financial reports
('F3', 'F3X', 'F3P', 'F3L', 'F4', 'F5', 'F7', 'F13').
'''

COMMITTEE_CYCLES_HAS_ACTIVITY = '''
A two year election cycle that the committee was active- (after original registration
date but before expiration date in Form 1), and the committee has filling activity during the cycle
'''

COMMITTEE_LAST_CYCLE_HAS_ACTIVITY = '''
The latest two year election cycle that the committee has filings
'''

RECORD_CYCLE = '''
Filter records to only those that were applicable to a given
two-year period.The cycle begins with an odd year and is named
for its ending, even year.
'''

RECORD_YEAR = '''
Filter records to only those that were applicable to a given year.
'''

ELECTION_FULL = '''`True` indicates that full election period of a candidate.
`False` indicates that two year election cycle.'''


COMMITTEE_STREET_1 = '''
Street address of committee as reported on the Form 1
'''

COMMITTEE_STREET_2 = '''
Second line of street address of committee as reported on the Form 1
'''

COMMITTEE_CITY = '''
City of committee as reported on the Form 1
'''

COMMITTEE_STATE = '''
State of the committee\'s address as filed on the Form 1
'''

COMMITTEE_STATE_FULL = '''
State of committee as reported on the Form 1
'''

COMMITTEE_ZIP = '''
Zip code of committee as reported on the Form 1
'''

COMMITTEE_EMAIL = '''
Email as reported on the Form 1
'''
COMMITTEE_FAX = '''
Fax as reported on the Form 1
'''
COMMITTEE_WEBSITE = '''
Website url as reported on the Form 1
'''

COMMITTEE_YEAR = 'A year that the committee was active— (after original registration date \
    or filing but before expiration date)'

CONVERT_TO_PAC_FLAG = 'True indicates that a candidate committee had been converted to a PAC'

FILING_FREQUENCY = 'The one-letter \n\
    code of the filing frequency:\n\
         - A Administratively terminated\n\
         - D Debt\n\
         - M Monthly filer\n\
         - Q Quarterly filer\n\
         - T Terminated\n\
         - W Waived\n\
'
DESIGNATION = 'The one-letter designation code of the organization:\n\
         - A authorized by a candidate\n\
         - J joint fundraising committee\n\
         - P principal campaign committee of a candidate\n\
         - U unauthorized\n\
         - B lobbyist/registrant PAC\n\
         - D leadership PAC\n\
'
ORGANIZATION_TYPE = 'The one-letter code for the kind for organization:\n\
        - C corporation\n\
        - L labor organization\n\
        - M membership organization\n\
        - T trade association\n\
        - V cooperative\n\
        - W corporation without capital stock\n\
'
COMMITTEE_TYPE = 'The one-letter type code of the organization:\n\
        - C communication cost\n\
        - D delegate\n\
        - E electioneering communication\n\
        - H House\n\
        - I independent expenditure filer (not a committee)\n\
        - N PAC - nonqualified\n\
        - O independent expenditure-only (super PACs)\n\
        - P presidential\n\
        - Q PAC - qualified\n\
        - S Senate\n\
        - U single candidate independent expenditure\n\
        - V PAC with non-contribution account, nonqualified\n\
        - W PAC with non-contribution account, qualified\n\
        - X party, nonqualified\n\
        - Y party, qualified\n\
        - Z national party non-federal account\n\
'
COMMITTEE_TYPE_STATE_AGGREGATE_TOTALS = COMMITTEE_TYPE + '\
        - all All Committee Types\n\
        - all_candidates All Candidate Committee Types (H, S, P)\n\
        - all_pacs All PAC Committee Types (N, O, Q, V, W)\n\
'
PAC_PARTY_TYPE = 'The one-letter type code of a PAC/Party organization:\n\
        - N PAC - nonqualified\n\
        - O independent expenditure-only (super PACs)\n\
        - Q PAC - qualified\n\
        - V PAC with non-contribution account, nonqualified account, qualified\n\
        - X party, nonqualified\n\
        - Y party, qualified\n\
'
COMMITTEE_LABEL = '''
Display the label of committee based on committee type, designation and organization type
'''

LEADERSHIP_PAC_INDICATE = '''
Indicates if the committee is a leadership PAC
'''

LOBBIST_REGISTRANT_PAC_INDICATE = '''
Indicates if the committee is a lobbyist registrant PAC
'''

PARTY_TYPE = '''
Code for the type of party the committee is, only if applicable
'''

PARTY_TYPE_FULL = '''
Description of the type of party the committee is, only if applicable
'''

HOUSE_PERSONAL_FUNDS = 'House personal funds'

SENATE_PERSONAL_FUNDS = 'Senate personal funds'

OPPOSITION_PERSONAL_FUNDS = 'Opposition personal funds'

TREASURER_NAME = 'Name of the Committee\'s treasurer. If multiple treasurers for the \
committee, the most recent treasurer will be shown.'

TREASURER_CITY = '''
City of committee treasurer as reported on the Form 1
'''

TREASURER_NAME_1 = '''
Name 1 of committee treasurer as reported on the Form 1
'''

TREASURER_NAME_2 = '''
Name 2 of committee treasurer as reported on the Form 1
'''

TREASURER_NAME_MIDDLE = '''
Middle name of committee treasurer as reported on the Form 1
'''

TREASURER_NAME_PREFIX = '''
Name Prefix of committee treasurer as reported on the Form 1
'''

TREASURER_NAME_SUFFIX = '''
Name suffix of committee treasurer as reported on the Form 1
'''

TREASURER_PHONE = '''
Phone of committee treasurer as reported on the Form 1
'''

TREASURER_STATE = '''
State of committee treasurer as reported on the Form 1
'''

TREASURER_STREET_1 = '''
Street of committee treasurer as reported on the Form 1
'''

TREASURER_STREET_2 = '''
Second line of the street of committee treasurer as reported on the Form 1
'''

TREASURER_NAME_TITLE = '''
Name title of committee treasurer as reported on the Form 1
'''

TREASURER_ZIP = '''
Zip code of committee treasurer as reported on the Form 1
'''

CUSTODIAN_CITY = '''
City of committee custodian as reported on the Form 1
'''

CUSTODIAN_NAME1 = '''
Name 1 of committee custodian as reported on the Form 1
'''

CUSTODIAN_NAME2 = '''
Name 2 of committee custodian as reported on the Form 1
'''

CUSTODIAN_MIDDLE_NAME = '''
Middle name of committee custodian as reported on the Form 1
'''

CUSTODIAN_NAME_FULL = '''
Full name of committee custodian as reported on the Form 1
'''

CUSTODIAN_PHONE = '''
Phone number of committee custodian as reported on the Form 1
'''

CUSTODIAN_NAME_PREFIX = '''
Name prefix of committee custodian as reported on the Form 1
'''

CUSTODIAN_STATE = '''
State of committee custodian as reported on the Form 1
'''

CUSTODIAN_STREET_1 = '''
Street address of the committee custodian as reported on the Form 1
'''

CUSTODIAN_STREET_2 = '''
Second line of the street address of the committee custodian as reported on the Form 1
'''

CUSTODIAN_NAME_SUFFIX = '''
Suffix name of the committee custodian as reported on the Form 1
'''

CUSTODIAN_NAME_TITLE = '''
Name title of the committee custodian as reported on the Form 1
'''

CUSTODIAN_ZIP = '''
Zip code of the committee custodian as reported on the Form 1
'''

FIRST_FILE_DATE = 'The day the FEC received the committee\'s first filing. \
This is usually a Form 1 committee registration.'

LAST_FILE_DATE = 'The day the FEC received the committee\'s most recent filing'

FIRST_F1_DATE = 'The day the FEC received the committee\'s first Form 1'

LAST_F1_DATE = 'The day the FEC received the committee\'s most recent Form 1'

MEANS_FILED = 'The method used to file with the FEC, either electronic or on paper.'

MIN_FIRST_FILE_DATE = 'Filter for committees whose first filing was received on or after this date.'

MAX_FIRST_FILE_DATE = 'Filter for committees whose first filing was received on or before this date.'

MIN_FIRST_F1_DATE = 'Filter for committees whose first Form 1 was received on or after this date.'

MAX_FIRST_F1_DATE = 'Filter for committees whose first Form 1 was received on or before this date.'

MIN_LAST_F1_DATE = 'Filter for committees whose latest Form 1 was received on or after this date.'

MAX_LAST_F1_DATE = 'Filter for committees whose latest Form 1 was received on or before this date.'

AFFILIATED_COMMITTEE_NAME = '''
Affiliated committee or connected organization
'''

IS_COMMITTEE_ACTIVE = '''
True indicates that a committee is active.
'''

SPONSOR_CANDIDATE_ID = '''
A unique identifier assigned to each candidate registered with the FEC. \
If a person runs for several offices, that person will have separate \
candidate IDs for each office. This is a filter for Leadership PAC sponsor.
'''

PREVIOUS_FILE_NUMBER = '''
Previous filing ID number
'''

AMENDMENT_VERSION = '''
Amendment version
'''

BANK_DEPOSITORY_NM = '''
Primary bank or depository in which the committee deposits funds,\
holds accounts, rents safety deposit boxes or maintains funds.
'''

BANK_DEPOSITORY_ST1 = '''
Street of bank or depository as reported on their Form 1.
'''

BANK_DEPOSITORY_ST2 = '''
Second line of the street of bank or depository as reported on the Form 1
'''

BANK_DEPOSITORY_CITY = '''
City of bank or depository as reported on the Form 1
'''

BANK_DEPOSITORY_ST = '''
State of bank or depository as reported on the Form 1
'''

BANK_DEPOSITORY_ZIP = '''
Zip code of bank or depository as reported on the Form 1
'''

ADDITIONAL_BANK_NAMES = '''
Additional banks or depositories in which the committee deposits funds,\
 holds accounts, rents safety deposit boxes or maintains funds.
'''

FILER_NAME_TEXT = '''
Keyword search for filer name or ID
'''

SPENDER_NAME_TEXT = '''
Keyword search for spender name or ID
'''

PRIMARY_GENERAL_INDICATOR = '''
Primary general indicator
'''

# ======== committee end ===========


# ======== election start ===========
ELECTION_SEARCH = '''
List elections by cycle, office, state, and district.
'''

ELECTIONS = '''
Look at the top-level financial information for all candidates running for the same
office.

Choose a 2-year cycle, and `house`, `senate` or `presidential`.

If you are looking for a Senate seat, you will need to select the state using a two-letter
abbreviation.

House races require state and a two-digit district number.

Since this endpoint reflects financial information, it will only have candidates once they file
financial reporting forms. Query the `/candidates` endpoint to retrieve an-up-to-date list of all the
candidates that filed to run for a particular seat.
'''
STATE_ELECTION_OFFICES = '''
State laws and procedures govern elections for state or local offices as well as
how candidates appear on election ballots.
Contact the appropriate state election office for more information.
'''
STATE_ELECTION_OFFICES_ADDRESS = '''
Enter a state (Ex: AK, TX, VA etc..) to find the local election offices contact
information.

'''

ELECTION_DATES = '''
FEC election dates since 1995.
'''

ELECTION_STATE = '''
State or territory of the office sought.
'''

ELECTION_DISTRICT = '''
House district of the office sought, if applicable.
'''

ELECTION_PARTY = '''
Party, if applicable.
'''

OFFICE_SOUGHT = '''
House, Senate or presidential office.
'''

MIN_ELECTION_DATE = '''
The minimum date of election.
'''

MAX_ELECTION_DATE = '''
The maximum date of election.
'''

ELECTION_TYPE_ID = '''
Election type id
'''

MIN_CREATE_DATE = '''
The minimum date this record was added to the system.(MM/DD/YYYY or YYYY-MM-DD)
'''

MAX_CREATE_DATE = '''
The maximum date this record was added to the system.(MM/DD/YYYY or YYYY-MM-DD)
'''

MIN_UPDATE_DATE = '''
The minimum date this record was last updated.(MM/DD/YYYY or YYYY-MM-DD)
'''

MAX_UPDATE_DATE = '''
The maximum date this record was last updated.(MM/DD/YYYY or YYYY-MM-DD)
'''
# ======== election end ===========


# ======== financial start ===========
FINANCIAL_TAG = '''
Fetch key information about a committee's Form 3, Form 3X, Form 13, or Form 3P financial reports.

Most committees are required to summarize their financial activity in each filing; those summaries
are included in these files. Generally, committees file reports on a quarterly or monthly basis, but
some must also submit a report 12 days before primary elections. Therefore, during the primary
season, the period covered by this file may be different for different committees. These totals
also incorporate any changes made by committees, if any report covering the period is amended.

Information is made available on the API as soon as it's processed. Keep in mind, complex
paper filings take longer to process.

The financial endpoints use data from FEC [form 5](https://www.fec.gov/pdf/forms/fecfrm5.pdf),
for independent expenditors; or the summary and detailed summary pages of the FEC
[Form 3](https://www.fec.gov/pdf/forms/fecfrm3.pdf), for House and Senate committees;
[Form 3X](https://www.fec.gov/pdf/forms/fecfrm3x.pdf), for PACs and parties;
[Form 13](https://www.fec.gov/pdf/forms/fecfrm13.pdf) for inaugural committees;
and [Form 3P](https://www.fec.gov/pdf/forms/fecfrm3p.pdf), for presidential committees.
'''

WIP_TAG = '''
DISCLAIMER: The field labels contained within this resource are subject to change.  We are attempting to succinctly
label these fields while conveying clear meaning to ensure accessibility for all users.
'''

REPORTS = '''
Each report represents the summary information from Form 3, Form 3X and Form 3P.
These reports have key statistics that illuminate the financial status of a given committee.
Things like cash on hand, debts owed by committee, total receipts, and total disbursements
are especially helpful for understanding a committee's financial dealings.

By default, this endpoint includes both amended and final versions of each report. To restrict
to only the final versions of each report, use `is_amended=false`; to retrieve only reports that
have been amended, use `is_amended=true`.

Several different reporting structures exist, depending on the type of organization that
submits financial information. To see an example of these reporting requirements,
look at the summary and detailed summary pages of Form 3, Form 3X, and Form 3P.
'''

REPORTS += WIP_TAG

BEGINNING_IMAGE_NUMBER = '''
Unique identifier for the electronic or paper report. This number is used to construct
PDF URLs to the original document.
'''

REPORT_YEAR = '''
Year that the record applies to. Sometimes records are amended in subsequent
years so this can differ from underlying form's receipt date.
'''

IS_AMENDED = '''
False indicates that a report is the most recent. True indicates that the report has been superseded by an amendment.
'''

MOST_RECENT = '''
Report is either new or is the most-recently filed amendment
'''

MOST_RECENT_IE = '''
The report associated with the transaction is either new or is the most-recently \
filed amendment. Undetermined version (`null`) is always included.
'''

HTML_URL = '''
HTML link to the filing.
'''

FEC_URL = '''
fec link to the filing.
'''

PDF_URL = '''
pdf link to the filing
'''

TWO_YEAR_TRANSACTION_PERIOD = '''
This is a two-year period that is derived from the year a transaction took place in the
Itemized Schedule A and Schedule B tables. In cases where we have the date of the transaction
(contribution_receipt_date in schedules/schedule_a, disbursement_date in schedules/schedule_b)
the two_year_transaction_period is named after the ending, even-numbered year. If we do not
have the date  of the transaction, we fall back to using the report year (report_year in both
tables) instead,  making the same cycle adjustment as necessary. If no transaction year is
specified, the results default to the most current cycle.
'''

TOTALS = '''
This endpoint provides information about a committee's Form 3, Form 3X, or Form 3P financial reports,
which are aggregated by two-year period. We refer to two-year periods as a `cycle`.

The cycle is named after the even-numbered year and includes the year before it. To obtain
totals from 2013 and 2014, you would use 2014. In odd-numbered years, the current cycle
is the next year — for example, in 2015, the current cycle is 2016.

For presidential and Senate candidates, multiple two-year cycles exist between elections.

'''

SCHEDULE_A_TAG = '''
This collection of endpoints includes Schedule A records reported by a committee. \
Schedule A records describe itemized receipts, including contributions from individuals. \
If you are interested in contributions from individuals, use the /schedules/schedule_a/ endpoint. \
For a more complete description of all Schedule A records visit \
[About receipts data](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/about-receipts-data/). \
If you are interested in our "is_individual" methodology visit \
our [methodology page](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/methodology/).\n


Schedule A is also available as a database dump file that is updated weekly on Sunday.
The database dump files are \
here: https://www.fec.gov/files/bulk-downloads/index.html?prefix=bulk-downloads/data-dump/schedules/. \
The instructions are here: https://www.fec.gov/files//bulk-downloads/data-dump/schedules/README.txt. \
We cannot provide help with restoring the database dump files, but you can refer to \
this community led [group](https://groups.google.com/forum/#!forum/fec-data) for discussion.
'''

SCHEDULE_A = '''
This description is for both ​`/schedules​/schedule_a​/` and ​ `/schedules​/schedule_a​/{sub_id}​/`.

This endpoint provides itemized receipts. Schedule A records describe itemized receipts, \
including contributions from individuals. If you are interested in contributions from an \
individual, use the `/schedules/schedule_a/` endpoint. For a more complete description of all \
Schedule A records visit \
[About receipts data](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/about-receipts-data/). \
If you are interested in our "is_individual" methodology visit our \
[methodology page](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/methodology/). \

​The `/schedules​/schedule_a​/` endpoint is not paginated by page number. This endpoint uses keyset \
pagination to improve query performance and these indices are required to properly page through \
this large dataset. To request the next page, you should append the values found in the \
`last_indexes` object from pagination to the URL of your last request as additional parameters. \

For example, when sorting by `contribution_receipt_date`, you might receive a page of results \
with the two scenarios of following pagination information:

case #1:
```
pagination: {\n\
    pages: 2152643,\n\
    per_page: 20,\n\
    count: 43052850,\n\
    last_indexes: {\n\
        last_index: "230880619",\n\
        last_contribution_receipt_date: "2014-01-01"\n\
    }\n\
}\n\
```
<br/>
case #2 (results which include contribution_receipt_date = NULL):

```
pagination: {\n\
    pages: 2152644,\n\
    per_page: 20,\n\
    count: 43052850,\n\
    last_indexes: {\n\
        last_index: "230880639",\n\
        sort_null_only: True\n\
    }\n\
}\n\
```
To fetch the next page of sorted results, append `last_index=230880619` and \
`last_contribution_receipt_date=2014-01-01` to the URL and \
when reaching `contribution_receipt_date=NULL`, append `last_index=230880639` \
and `sort_null_only=True`. We strongly advise paging through these results \
using sort indices. The default sort is acending by `contribution_receipt_date` \
(`deprecated`, will be descending). \
If you do not page using sort indices, some transactions may be unintentionally filtered out.

Calls to ​`/schedules​/schedule_a​/` may return many records. For large result sets, the record \
counts found in the pagination object are approximate; you will need to page through the records \
until no records are returned.

To avoid throwing the "out of range" exception on the last page, one recommandation is \
to use total count and `per_page` to control the traverse loop of results.

​The `/schedules​/schedule_a​/{sub_id}​/` endpoint returns a single transaction, but it does \
include a pagination object class. Please ignore the information in that object class.

'''

SUB_ID = '''
A unique database identifier for itemized receipts or disbursements.
'''

SCHEDULE_B_TAG = '''
Schedule B filings describe itemized disbursements. This data
explains how committees and other filers spend their money. These figures are
reported as part of forms F3, F3X and F3P.
'''

SCHEDULE_B = SCHEDULE_B_TAG + '''
The data are divided in two-year periods, called `two_year_transaction_period`, which
is derived from the `report_year` submitted of the corresponding form. If no value is supplied, the results will
default to the most recent two-year period that is named after the ending,
even-numbered year.

Due to the large quantity of Schedule B filings, this endpoint is not paginated by
page number. Instead, you can request the next page of results by adding the values in
the `last_indexes` object from `pagination` to the URL of your last request. For
example, when sorting by `disbursement_date`, you might receive a page of
results with the following pagination information:

```
pagination: {\n\
    pages: 965191,\n\
    per_page: 20,\n\
    count: 19303814,\n\
    last_indexes: {\n\
        last_index: "230906248",\n\
        last_disbursement_date: "2014-07-04"\n\
    }\n\
}\n\
```

To fetch the next page of sorted results, append `last_index=230906248` and
`last_disbursement_date=2014-07-04` to the URL.  We strongly advise paging through
these results by using the sort indices (defaults to sort by disbursement date, e.g.
`last_disbursement_date`), otherwise some resources may be unintentionally filtered out.
This resource uses keyset pagination to improve query performance
and these indices are required to properly page through this large dataset.

Note: because the Schedule B data includes many records, counts for
large result sets are approximate; you will want to page through the records until no records are returned.
'''

SCHEDULE_B_BY_PURPOSE = '''
Schedule B disbursements aggregated by disbursement purpose category. To avoid double counting,
memoed items are not included.
Purpose is a combination of transaction codes, category codes and disbursement description.
Inspect the `disbursement_purpose` sql function within the migrations for more details.
'''

SCHEDULE_B_BY_RECIPIENT = '''
Schedule B disbursements aggregated by recipient name. To avoid double counting,
memoed items are not included.
'''

SCHEDULE_B_BY_RECIPIENT_ID = '''
Schedule B disbursements aggregated by recipient committee ID, if applicable.
To avoid double counting, memoed items are not included.
'''

MEMO_TOTAL = '''
Schedule B disbursements aggregated by memoed items only
'''

NON_MEMO_TOTAL = '''
Schedule B disbursements aggregated by non-memoed items only
'''

SCHEDULE_C_TAG = '''
Schedule C shows all loans, endorsements and loan guarantees a committee
receives or makes.
'''

SCHEDULE_C = SCHEDULE_C_TAG + '''
The committee continues to report the loan until it is repaid.
'''

SCHEDULE_D_TAG = '''
Schedule D, it shows debts and obligations owed to or by the committee that are
required to be disclosed.
'''

SCHEDULE_D = SCHEDULE_D_TAG + '''

'''

SCHEDULE_E_TAG = '''
Schedule E covers the line item expenditures for independent expenditures. For example, if a super PAC
bought ads on TV to oppose a federal candidate, each ad purchase would be recorded here with
the expenditure amount, name and id of the candidate, and whether the ad supported or opposed the candidate.

An independent expenditure is an expenditure for a communication "expressly advocating the election or
defeat of a clearly identified candidate that is not made in cooperation, consultation, or concert with,
or at the request or suggestion of, a candidate, a candidate’s authorized committee, or their agents, or
a political party or its agents."

Aggregates by candidate do not include 24 and 48 hour reports. This ensures we don't double count expenditures
and the totals are more accurate. You can still find the information from 24 and 48 hour reports in
`/schedule/schedule_e/`.
'''

SCHEDULE_E = SCHEDULE_E_TAG + '''
Due to the large quantity of Schedule E filings, this endpoint is not paginated by
page number. Instead, you can request the next page of results by adding the values in
the `last_indexes` object from `pagination` to the URL of your last request. For
example, when sorting by `expenditure_amount`, you might receive a page of
results with the following pagination information:

```
 "pagination": {\n\
    "count": 152623,\n\
    "last_indexes": {\n\
      "last_index": "3023037",\n\
      "last_expenditure_amount": -17348.5\n\
    },\n\
    "per_page": 20,\n\
    "pages": 7632\n\
  }\n\
}\n\
```

To fetch the next page of sorted results, append `last_index=3023037` and
`last_expenditure_amount=` to the URL.  We strongly advise paging through
these results by using the sort indices (defaults to sort by disbursement date,
e.g. `last_disbursement_date`), otherwise some resources may be unintentionally
filtered out.  This resource uses keyset pagination to improve query performance
and these indices are required to properly page through this large dataset.

Note: because the Schedule E data includes many records, counts for
large result sets are approximate; you will want to page through the records until no records are returned.
'''

SCHEDULE_E_BY_CANDIDATE = '''
Schedule E receipts aggregated by recipient candidate. To avoid double
counting, memoed items are not included.
'''

SCHEDULE_E_INDEPENDENT_EXPENDITURES_TOTALS_BY_CANDIDATE = '''
Total independent expenditure on supported or opposed candidates by cycle or candidate election year.
'''

COMMUNICATIONS_COSTS_TOTALS_BY_CANDIDATE = '''
Total communications costs aggregated across committees on supported or opposed candidates \
by cycle or candidate election year.
'''

SCHEDULE_F_TAG = '''
Schedule F, it shows all special expenditures a national or state party committee
makes in connection with the general election campaigns of federal candidates.
'''

SCHEDULE_F = SCHEDULE_F_TAG + '''
These coordinated party expenditures do not count against the contribution limits but are subject to other limits,
these limits are detailed in Chapter 7 of the FEC Campaign Guide for Political Party Committees.
'''

SCHEDULE_A_BY_SIZE = '''
This endpoint provides individual contributions received by a committee, aggregated by size:

```
 - $200 and under\n\
 - $200.01 - $499.99\n\
 - $500 - $999.99\n\
 - $1000 - $1999.99\n\
 - $2000 +\n\
```

The $200.00 and under category includes contributions of $200 or less combined with unitemized individual contributions.
'''

SCHEDULE_A_BY_STATE = '''
This endpoint provides itemized individual contributions received by a committee, aggregated by \
the contributor’s state. If you are interested in our “is_individual” methodology, review the \
[methodology page](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/methodology). \
Unitemized individual contributions are not included.
'''

SCHEDULE_A_BY_ZIP = '''
This endpoint provides itemized individual contributions received by a committee, aggregated by \
the contributor’s ZIP code. If you are interested in our “is_individual” methodology, review the \
[methodology page](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/methodology). \
Unitemized individual contributions are not included.
'''

SCHEDULE_A_BY_EMPLOYER = '''
This endpoint provides itemized individual contributions received by a committee, aggregated by \
the contributor’s employer name. If you are interested in our “is_individual” methodology, review the \
[methodology page](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/methodology). \
Unitemized individual contributions are not included.
'''

SCHEDULE_A_BY_OCCUPATION = '''
This endpoint provides itemized individual contributions received by a committee, aggregated by \
the contributor’s occupation. If you are interested in our “is_individual” methodology, review the \
[methodology page](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/methodology). \
Unitemized individual contributions are not included.
'''

CONTRIBUTION_RECEIPTS = '''
Contributions received
'''

SIZE_RANGE_ID = '''
The total all contributions range id.
'''

SIZE = '''
The total all contributions in the following ranges:
```
  -0    $200 and under\n\
  -200  $200.01 - $499.99\n\
  -500  $500 - $999.99\n\
  -1000 $1000 - $1999.99\n\
  -2000 $2000 +\n\
```
Unitemized contributions are included in the `0` category.
'''

COUNT = '''
Number of records making up the total.
'''

SCHEDULE_A_SIZE_CANDIDATE_TAG = '''
This endpoint provides itemized individual contributions received by a committee, aggregated by \
size of contribution and candidate. If you are interested in our “is_individual” methodology, review the \
[methodology page](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/methodology). \
Unitemized individual contributions are not included.
'''

SCHEDULE_A_STATE_CANDIDATE_TAG = '''
This endpoint provides itemized individual contributions received by a committee, aggregated \
by contributor’s state and candidate. If you are interested in our “is_individual” methodology, review the \
[methodology page](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/methodology). \
Unitemized individual contributions are not included.
'''

SCHEDULE_A_STATE_CANDIDATE_TOTAL_TAG = '''
Itemized individual contributions aggregated by contributor’s state, candidate, committee type \
and cycle. If you are interested in our “is_individual” methodology, review the \
[methodology page](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/methodology). \
Unitemized individual contributions are not included.

'''

SCHEDULE_H4 = '''
Schedule H4 filings describe disbursements for allocated federal/nonfederal activity. This data
demonstrates how separate segregated funds, party committees and nonconnected committees that are active
in both federal and nonfederal elections, and have established separate federal and nonfederal accounts,
allocate their activity. These figures are reported on Form 3X.

The data are divided in two-year periods, called `two_year_transaction_period`, which are derived from the
`report_year` submitted on Form 3X. If no value is supplied, the results will default to the most recent
two-year period.
'''

TOTAL_CANDIDATE_TAG = '''
Aggregated candidate receipts and disbursements grouped by cycle.
'''

STATE_AGGREGATE_RECIPIENT_TOTALS = '''
This endpoint provides itemized individual contributions received by a committee, aggregated by \
contributor’s state, committee type and cycle. If you are interested in our “is_individual” methodology, review the \
[methodology page](https://www.fec.gov/campaign-finance-data/about-campaign-finance-data/methodology). \
Unitemized individual contributions are not included.
'''

API_KEY_DESCRIPTION = '''
API key for https://api.data.gov. Get one at https://api.data.gov/signup.
'''

SEARCH_TAG = '''
Search for candidates, committees by name.
'''

FILINGS_TAG = '''
Search for financial reports and other FEC documents.
'''

FILINGS = '''
All official records and reports filed by or delivered to the FEC.

Note: because the filings data includes many records, counts for large
result sets are approximate; you will want to page through the records until no records are returned.
'''

FORM_CATEGORY = '''
The forms filed are categorized based on the nature of the filing:\n\
    - REPORT F3, F3X, F3P, F3L, F4, F5, F7, F13\n\
    - NOTICE F5, F24, F6, F9, F10, F11\n\
    - STATEMENT F1, F2\n\
    - OTHER F1M, F8, F99, F12, FRQ\n\
'''

PRIMARY_GENERAL_INDICTOR = '''
Primary, general or special election indicator.
'''

DOC_TYPE = '''
The type of document for documents other than reports:\n\
    - 2 24 Hour Contribution Notice\n\
    - 4 48 Hour Contribution Notice\n\
    - A Debt Settlement Statement\n\
    - B Acknowledgment of Receipt of Debt Settlement Statement\n\
    - C RFAI: Debt Settlement First Notice\n\
    - D Commission Debt Settlement Review\n\
    - E Commission Response TO Debt Settlement Request\n\
    - F Administrative Termination\n\
    - G Debt Settlement Plan Amendment\n\
    - H Disavowal Notice\n\
    - I Disavowal Response\n\
    - J Conduit Report\n\
    - K Termination Approval\n\
    - L Repeat Non-Filer Notice\n\
    - M Filing Frequency Change Notice\n\
    - N Paper Amendment to Electronic Report\n\
    - O Acknowledgment of Filing Frequency Change\n\
    - S RFAI: Debt Settlement Second\n\
    - T Miscellaneous Report TO FEC\n\
    - V Repeat Violation Notice (441A OR 441B)\n\
    - P Notice of Paper Filing\n\
    - R F3L Filing Frequency Change Notice\n\
    - Q Acknowledgment of F3L Filing Frequency Change\n\
    - U Unregistered Committee Notice\n\
'''
DATES_TAG = '''
Reporting deadlines, election dates FEC meetings, events etc.
'''

CALENDAR_DATES = '''
Combines the election and reporting dates with Commission meetings, conferences, outreach, Advisory Opinions, rules, \
litigation dates and other
events into one calendar.

State and report type filtering is no longer available.
'''

MIN_START_DATE = '''
The minimum start date.(MM/DD/YYYY or YYYY-MM-DD)
'''

MIN_END_DATE = '''
The minimum end date.(MM/DD/YYYY or YYYY-MM-DD)
'''

MAX_START_DATE = '''
The maximum start date.(MM/DD/YYYY or YYYY-MM-DD)
'''

MAX_END_DATE = '''
The maximum end date.(MM/DD/YYYY or YYYY-MM-DD)
'''

LOCATION = '''
Can be state address or room.
'''

START_DATE = '''
Date the event starts(MM/DD/YYYY or YYYY-MM-DD)
'''

END_DATE = '''
Date the event ends(MM/DD/YYYY or YYYY-MM-DD)
'''

CALENDAR_EXPORT = '''
Returns CSV or ICS for downloading directly into calendar applications like Google, Outlook or other applications.

Combines the election and reporting dates with Commission meetings, conferences, outreach, Advisory Opinions, rules, \
litigation dates and other
events into one calendar.

State filtering now applies to elections, reports and reporting periods.

Presidential pre-primary report due dates are not shown on even years.
Filers generally opt to file monthly rather than submit over 50 pre-primary election
reports. All reporting deadlines are available at /reporting-dates/ for reference.

This is [the sql function](https://github.com/fecgov/openFEC/blob/develop/data/migrations/V40__omnibus_dates.sql)
that creates the calendar.

'''

MIN_PRIMARY_GENERAL_DATE = '''
The minimum date of primary or general election.(MM/DD/YYYY or YYYY-MM-DD)
'''

MAX_PRIMARY_GENERAL_DATE = '''
The maximum date of primary or general election.(MM/DD/YYYY or YYYY-MM-DD)
'''

ELECTION_STATUS_ID = '''
Records are disregarded if election status is not 1. Those records are erroneous.
'''

OPEN_SEAT_FLAG = '''
Signifies if the contest has no incumbent running.
'''

EVENT_URL = '''
A url for that event
'''

REPORT_YEAR = '''
Year of report
'''

MIN_DUE_DATE = '''
The minimum date the report is due.(MM/DD/YYYY or YYYY-MM-DD)
'''

MAX_DUE_DATE = '''
The maximum date the report is due.(MM/DD/YYYY or YYYY-MM-DD)
'''

COMMUNICATION_TAG = '''
Reports of communication costs by corporations and membership organizations
from the FEC [F7 forms](https://www.fec.gov/pdf/forms/fecform7.pdf).
'''
ELECTIONEERING = '''
An electioneering communication is any broadcast, cable or satellite communication that fulfills \
each of the following conditions:

_The communication refers to a clearly identified federal candidate._

_The communication is publicly distributed by a television station, radio station, cable television system \
or satellite system for a fee._

_The communication is distributed within 60 days prior to a general election or 30 days prior \
to a primary election to federal office._
'''

ELECTIONEERING_AGGREGATE_BY_CANDIDATE = 'Electioneering costs aggregated by candidate'

ELECTIONEERING_AGGREGATE = 'Electioneering communications costs aggregates'

ELECTIONEERING_TOTAL_BY_CANDIDATE = '''
Total electioneering communications spent on candidates by cycle
or candidate election year
'''

COMMUNICATION_COST = '''
52 U.S.C. 30118 allows "communications by a corporation to its stockholders and executive \
or administrative personnel and their families or by a labor organization to its members \
and their families on any subject," including the express advocacy of the election or defeat \
of any Federal candidate.  The costs of such communications must be reported to the Federal Election \
Commission under certain circumstances.
'''

COMMUNICATION_COST_AGGREGATE = 'Communication cost aggregated by candidate ID and committee ID.'

FILER_RESOURCES = '''
Useful tools for those who file with the FEC.

Look up RAD analyst with telephone extension by committee_id.
'''

RAD_ANALYST = '''
Use this endpoint to look up the RAD Analyst for a committee.

The mission of the Reports Analysis Division (RAD) is to ensure that
campaigns and political committees file timely and accurate reports that fully disclose
their financial activities.  RAD is responsible for reviewing statements and financial
reports filed by political committees participating in federal elections, providing
assistance and guidance to the committees to properly file their reports, and for taking
appropriate action to ensure compliance with the Federal Election Campaign Act (FECA).
'''

# fields and filters

# shared
LOAD_DATE = 'Date the information was loaded into the FEC systems. This can be affected by \
reseting systems and other factors, refer to receipt_date for the day that the FEC received \
the paper or electronic document. Keep in mind that paper filings take more time to process \
and there can be a lag between load_date and receipt_date. This field can be helpful to \
identify paper records that have been processed recently.'

PARTY = 'Three-letter code for the party affiliated with a candidate or committee. \
For example, DEM for Democratic Party and REP for Republican Party.'

PARTY_FULL = 'Party affiliated with a candidate or committee'
FORM_TYPE = 'The form where the underlying data comes from, for example, Form 1 would appear as F1:\n\
    - F1   Statement of Organization\n\
    - F1M  Notification of Multicandidate Status\n\
    - F2   Statement of Candidacy\n\
    - F3   Report of Receipts and Disbursements for an Authorized Committee\n\
    - F3P  Report of Receipts and Disbursements by an Authorized Committee of a Candidate for \
    The Office of President or Vice President\n\
    - F3L  Report of Contributions Bundled by Lobbyists/Registrants and Lobbyist/Registrant PACs\n\
    - F3X  Report of Receipts and Disbursements for other than an Authorized Committee\n\
    - F4   Report of Receipts and Disbursements for a Committee or Organization Supporting a Nomination Convention\n\
    - F5   Report of Independent Expenditures Made and Contributions Received\n\
    - F6   48 Hour Notice of Contributions/Loans Received\n\
    - F7   Report of Communication Costs by Corporations and Membership Organizations\n\
    - F8   Debt Settlement Plan\n\
    - F9   24 Hour Notice of Disbursements for Electioneering Communications\n\
    - F13  Report of Donations Accepted for Inaugural Committee\n\
    - F99  Miscellaneous Text\n\
    - FRQ  Request for Additional Information\n\
'
BASE_REPORT_TYPE = 'Name of report where the underlying data comes from:\n\
    - 10D Pre-Election\n\
    - 10G Pre-General\n\
    - 10P Pre-Primary\n\
    - 10R Pre-Run-Off\n\
    - 10S Pre-Special\n\
    - 12C Pre-Convention\n\
    - 12G Pre-General\n\
    - 12P Pre-Primary\n\
    - 12R Pre-Run-Off\n\
    - 12S Pre-Special\n\
    - 30D Post-Election\n\
    - 30G Post-General\n\
    - 30P Post-Primary\n\
    - 30R Post-Run-Off\n\
    - 30S Post-Special\n\
    - 60D Post-Convention\n\
    - M1  January Monthly\n\
    - M10 October Monthly\n\
    - M11 November Monthly\n\
    - M12 December Monthly\n\
    - M2  February Monthly\n\
    - M3  March Monthly\n\
    - M4  April Monthly\n\
    - M5  May Monthly\n\
    - M6  June Monthly\n\
    - M7  July Monthly\n\
    - M8  August Monthly\n\
    - M9  September Monthly\n\
    - MY  Mid-Year Report\n\
    - Q1  April Quarterly\n\
    - Q2  July Quarterly\n\
    - Q3  October Quarterly\n\
    - TER Termination Report\n\
    - YE  Year-End\n\
    - ADJ COMP ADJUST AMEND\n\
    - CA  COMPREHENSIVE AMEND\n\
'

REPORT_TYPE = BASE_REPORT_TYPE + '\
    - 90S Post Inaugural Supplement\n\
    - 90D Post Inaugural\n\
    - 48  48 Hour Notification\n\
    - 24  24 Hour Notification\n\
    - M7S July Monthly/Semi-Annual\n\
    - MSA Monthly Semi-Annual (MY)\n\
    - MYS Monthly Year End/Semi-Annual\n\
    - Q2S July Quarterly/Semi-Annual\n\
    - QSA Quarterly Semi-Annual (MY)\n\
    - QYS Quarterly Year End/Semi-Annual\n\
    - QYE Quarterly Semi-Annual (YE)\n\
    - QMS Quarterly Mid-Year/ Semi-Annual\n\
    - MSY Monthly Semi-Annual (YE)\n\
'

REQUEST_TYPE = '''
Requests for additional information (RFAIs) sent to filers. The request type is based on the type of document filed:\n\
    - 1 Statement of Organization\n\
    - 2 Report of Receipts and Expenditures (Form 3 and 3X)\n\
    - 3 Second Notice - Reports\n\
    - 4 Request for Additional Information\n\
    - 5 Informational - Reports\n\
    - 6 Second Notice - Statement of Organization\n\
    - 7 Failure to File\n\
    - 8 From Public Disclosure\n\
    - 9 From Multi Candidate Status\n\
'''

REPORT_TYPE_W_EXCLUDE = 'Report type; prefix with "-" to exclude. ' + REPORT_TYPE

BASE_REPORT_TYPE_W_EXCLUDE = 'Report type; prefix with "-" to exclude. ' + BASE_REPORT_TYPE

RECEIPT_DATE = 'Date the FEC received the electronic or paper record'

FILED_DATE = 'Timestamp of electronic or paper record that FEC received'

MIN_FILED_DATE = '''
Selects all filings received after this date
'''

MAX_FILED_DATE = '''
Selects all filings received before this date
'''

STATE_GENERIC = 'US state or territory'

ZIP_CODE = 'Zip code'

CANDIDATE_MIN_FIRST_FILE_DATE = 'Selects all candidates whose first filing was received by the FEC after this date.'

CANDIDATE_MAX_FIRST_FILE_DATE = 'Selects all candidates whose first filing was received by the FEC before this date.'

# schedules
MEMO_CODE = "'X' indicates that the amount is NOT to be included in the itemization total."

# schedule A
CONTRIBUTOR_ID = 'The FEC identifier should be represented here if the contributor is registered with the FEC.'
EMPLOYER = 'Employer of contributor as reported on the committee\'s filing'
OCCUPATION = 'Occupation of contributor as reported on the committee\'s filing'
CONTRIBUTOR_NAME = 'Name of contributor'
CONTRIBUTOR_CITY = 'City of contributor'
CONTRIBUTOR_STATE = 'State of contributor'
CONTRIBUTOR_EMPLOYER = 'Employer of contributor, filers need to make an effort to gather this information'
CONTRIBUTOR_OCCUPATION = 'Occupation of contributor, filers need to make an effort to gather this information'
CONTRIBUTOR_ZIP = 'Zip code of contributor'
IS_INDIVIDUAL = 'Restrict to non-earmarked individual contributions where memo code is true. \
Filtering individuals is useful to make sure contributions are not double reported and in creating \
breakdowns of the amount of money coming from individuals.'
MISSING_STATE = 'Exclude values with missing state'
MIN_LOAD_DATE = 'Minimum load date'
MAX_LOAD_DATE = 'Maximum load date'

# schedule B
DISBURSEMENT_DESCRIPTION = 'Description of disbursement'
DISBURSEMENT_PURPOSE_CATEGORY = 'Disbursement purpose category'
LAST_DISBURSEMENT_AMOUNT = 'When sorting by `disbursement_amount`, this is populated with the `disbursement_amount` of \
the last result.  However, you will need to pass the index of that last result to `last_index` to get the next page.'
LAST_DISBURSEMENT_DATE = 'When sorting by `disbursement_date`, this is populated with the `disbursement_date` of \
the last result. However, you will need to pass the index of that last result to `last_index` to get the next page.'
RECIPIENT_CITY = 'City of recipient'
RECIPIENT_COMMITTEE_ID = 'The FEC identifier should be represented here if the contributor is registered with the FEC.'
RECIPIENT_ID = 'The FEC identifier should be represented here if the entity receiving \
the disbursement is registered with the FEC.'
RECIPIENT_NAME = 'Name of the entity receiving the disbursement'
RECIPIENT_STATE = 'State of recipient'

PURPOSE = 'Purpose of the expenditure'

# communication cost and electioneering
SUPPORT_OPPOSE_INDICATOR = 'Explains if the money was spent in order to support or oppose a candidate or candidates. \
(Coded S or O for support or oppose.) This indicator applies to independent expenditures and communication costs.'

# schedule E
EXPENDITURE_MAX_DATE = 'Selects all items expended by this committee before this date'
EXPENDITURE_MIN_DATE = 'Selects all items expended by this committee after this date'
EXPENDITURE_MIN_AMOUNT = 'Selects all items expended by this committee greater than this amount'
EXPENDITURE_MAX_AMOUNT = 'Selects all items expended by this committee less than this amount'
SUPPORT_OPPOSE = 'Support or opposition'

# schedule H4
# PAYEE_NAME = Name of the entity that received the payment (is pulled from above)
PAYEE_CITY = 'City of the entity that received the payment'
PAYEE_STATE = 'State of the entity that received the payment'
PAYEE_ZIP = 'Zip of the entity that received the payment'
DISBURSEMENT_PURPOSE = 'Purpose of the allocated disbursement'

# dates
DUE_DATE = 'Date the report is due'
CREATE_DATE = 'Date the record was created'
UPDATE_DATE = 'Date the record was updated'
ELECTION_DATE = 'Date of election'
ELECTION_YEAR = 'Year of election'
# ? TODO: add more categories
ELECTION_TYPE = 'Election type \n\
Convention, Primary,\n\
General, Special,\n\
Runoff etc.\n\
'

SENATE_CLASS = 'Senators run every six years and each state has two senators. General elections \
are held every 2 years. The Senate elections are staggered so there are three classes of Senators \
In a given state, only one Senate seat is up for election at a time and every six years, there is \
not a senate election in a given state. Thus, the Senate is broken up in to three groups called \
classes. Senators in the same class are up for election at the same time. Sometimes it is a bit \
less straight forward when, because there are situations in which there is a special election to \
fill a vacancy in the Senate. In those cases class refers to the seat groupings and not the time \
of the election.'

# filings
ENDING_IMAGE_NUMBER = 'Image number is an unique identifier for each page the electronic or paper \
report. The last image number corresponds to the image number for the last page of the document.'

# Reports and Totals


def add_period(var):
    return var + ' total for the reporting period'


def add_ytd(var):
    return var + ' total for the year to date'


TOTAL_RECEIPTS = 'Total receipts'
TOTAL_INDIVIDUAL_CONTRIBUTIONS = 'Total individual contributions'
NET_DONATIONS = 'Net donations'
TOTAL_DISBURSEMENTS = 'Total disbursements'
TOTAL_INDEPENDENT_EXPENDITURES = 'Total independent expenditures'
TOTAL_COMMUNICATION_COST = 'Total communications cost'

# shared
CASH_ON_HAND_BEGIN_PERIOD = 'Balance for the committee at the start of the two-year period'
CASH_ON_HAND_END_PERIOD = 'Ending cash balance on the most recent filing'
COVERAGE_START_DATE = 'Beginning date of the reporting period'
COVERAGE_END_DATE = 'Ending date of the reporting period'
DEBTS_OWED_BY_COMMITTEE = 'Debts owed by the committee'
DEBTS_OWED_TO_COMMITTEE = 'Debts owed to the committee'

# shared receipts
RECEIPTS = 'Anything of value (money, goods, services or property) received by a political committee'

# can't tack on period or year without being really confusing
INDIVIDUAL_ITEMIZED_CONTRIBUTIONS = 'Individual itemized contributions are from individuals whose aggregate \
contributions total over $200 per individual per year. Be aware, some filers choose to itemize donations $200 or less.'
INDIVIDUAL_ITEMIZED_CONTRIBUTIONS_PERIOD = 'Individual itemized contributions are from individuals whose aggregate \
contributions total over $200 per individual per year. This amount represents the total of these receipts \
for the reporting period.'
INDIVIDUAL_ITEMIZED_CONTRIBUTIONS_YTD = 'Individual itemized contributions are from individuals whose aggregate \
contributions total over $200 per individual per year. This amount represents the total of these receipts \
for the year to date.'
INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS = 'Unitemized contributions are made individuals whose aggregate contributions \
total $200 or less per individual per year. Be aware, some filers choose to itemize donations $200 or less and \
in that case those donations will appear in the itemized total.'
INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS_PERIOD = 'Unitemized contributions are from individuals whose aggregate \
contributions total $200 or less per individual per year. This amount represents the total of these receipts \
for the reporting period.'
INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS_YTD = 'Itemized contributions are from individuals whose aggregate \
contributions total $200 or less per individual per year. This amount represents the total of these receipts \
for the year to date.'


POLITICAL_PARTY_COMMITTEE_CONTRIBUTIONS = 'Party committees contributions'
INDIVIDUAL_CONTRIBUTIONS = 'Individual contributions'
OTHER_POLITICAL_COMMITTEE_CONTRIBUTIONS = 'Other committees contributions'
OFFSETS_TO_OPERATING_EXPENDITURES = 'Offsets to operating expenditures'
CONTRIBUTIONS = 'Contribution'
# house senate and presidential
CANDIDATE_CONTRIBUTION = 'Candidate contributions'
OTHER_RECEIPTS = 'Other receipts'
# house senate and PAC party
NET_CONTRIBUTIONS = 'Net contributions'

# shared disbursements
DISBURSEMENTS = 'Disbursements'
REFUNDED_INDIVIDUAL_CONTRIBUTIONS = 'Individual refunds'
OPERATING_EXPENDITURES = 'Total operating expenditures'
OTHER_DISBURSEMENTS = 'Other disbursements'
REFUNDED_POLITICAL_PARTY_COMMITTEE_CONTRIBUTIONS = 'Political party refunds'
CONTRIBUTION_REFUNDS = 'Total contribution refunds'
REFUNDED_OTHER_POLITICAL_COMMITTEE_CONTRIBUTIONS = 'Other committee refunds'

# loans
LOAN_SOURCE = 'Source of the loan (i.e., bank loan, brokerage account, credit card, home equity line of credit, \
              other line of credit, or personal funds of the candidate'

# presidential
# receipts
FEDERAL_FUNDS = 'Federal funds: Public funding of presidential elections means that qualified presidential candidates \
                receive federal government funds to pay for the valid expenses of their political campaigns \
                in both the primary and general elections.'

TRANSFERS_FROM_AFFILIATED_COMMITTEE = 'Transfers from affiliated committees'
LOANS_RECEIVED_FROM_CANDIDATE = 'Loans made by candidate'
OTHER_LOANS_RECEIVED = 'Other loans'
LOANS_RECEIVED = 'Total loans received'
OFFSETS_TO_FUNDRAISING_EXPENDITURES = 'Fundraising offsets'
OFFSETS_TO_LEGAL_ACCOUNTING = 'Legal and accounting offsets'
TOTAL_OFFSETS_TO_OPERATING_EXPENDITURES = 'Total offsets'

# disbursements
TRANSFERS_TO_OTHER_AUTHORIZED_COMMITTEE = 'Transfers to authorized committees'
REPAYMENTS_LOANS_MADE_BY_CANDIDATE = 'Candidate loan repayments'
REPAYMENTS_OTHER_LOANS = 'Other loan repayments'
LOAN_REPAYMENTS_MADE = 'Total loan repayments'

# House Senate
# receipts
TRANSFERS_FROM_OTHER_AUTHORIZED_COMMITTEE = 'Transfers from authorized committees'
LOANS_MADE_BY_CANDIDATE = 'Loans made by candidate'
ALL_OTHER_LOANS = 'Other loans'
LOANS = 'Total loans received'

# disbursements
NET_OPERATING_EXPENDITURES = 'Net operating expenditures'
TRANSFERS_TO_OTHER_AUTHORIZED_COMMITTEE = 'Transfers to authorized committees'
LOAN_REPAYMENTS_CANDIDATE_LOANS = 'Candidate loan repayments'
LOAN_REPAYMENTS_OTHER_LOANS = 'Other loan repayments'
OTHER_DISBURSEMENTS = 'Other disbursements'

# PAC and Party
# Receipts
TRANSFERS_FROM_AFFILIATED_PARTY = 'Transfers from affiliated committees'
ALL_LOANS_RECEIVED = 'Loans received'
LOAN_REPAYMENTS_RECEIVED = 'Loan repayments received'
FED_CANDIDATE_CONTRIBUTION_REFUNDS = 'Candidate refunds'
OTHER_FED_RECEIPTS = 'Other receipts'
TRANSFERS_FROM_NONFED_ACCOUNT = 'Non-federal transfers'
TRANSFERS_FROM_NONFED_LEVIN = 'Levin funds'
TRANSFERS_FROM_NONFED_ACCOUNT = 'Total non-federal transfers'
FED_RECEIPTS = 'Total federal receipts'

# disbursement
SHARED_FED_OPERATING_EXPENDITURES = 'Federal allocated operating expenditures'
SHARED_NONFED_OPERATING_EXPENDITURES = 'Non-federal operating expenditures'
OTHER_FED_OPERATING_EXPENDITURES = 'Other federal operating expenditures'
NET_OPERATING_EXPENDITURES = 'Net operating expenditures'
TRANSFERS_TO_AFFILIATED_COMMITTEE = 'Transfers to affiliated committees'
FED_CANDIDATE_COMMITTEE_CONTRIBUTIONS = 'Contributions to other federal committees'
INDEPENDENT_EXPENDITURES = 'Independent expenditures'
COORDINATED_EXPENDITURES_BY_PARTY_COMMITTEE = 'Coordinated party expenditures'
LOANS_MADE = 'Loans made'
LOAN_REPAYMENTS_MADE = 'Loan repayments made'
SHARED_FED_ACTIVITY = 'Allocated federal election activity - federal share'
ALLOCATED_FEDERAL_ELECTION_LEVIN_SHARE = 'Allocated federal election activity - Levin share'
NON_ALLOCATED_FED_ELECTION_ACTIVITY = 'Federal election activity - federal only'
FED_ELECTION_ACTIVITY = 'Total federal election activity'
FED_DISBURSEMENTS = 'Total federal disbursements'

# calendar
CATEGORY = '''
Each type of event has a calendar category with an integer id. Options are: Open Meetings: 32, Executive Sessions: 39, \
Public Hearings: 40,
Conferences: 33, Roundtables: 34, Election Dates: 36, Federal Holidays: 37, FEA Periods: 38, Commission Meetings: 20,
Reporting Deadlines: 21, Conferences and Outreach: 22, AOs and Rules: 23, Other: 24, Quarterly: 25, Monthly: 26,
Pre and Post-Elections: 27, EC Periods:28, and IE Periods: 29
'''
CAL_STATE = 'The state field only applies to election dates and reporting deadlines, reporting periods and \
all other dates do not have the array of states to filter on'
CAL_DESCRIPTION = 'Brief description of event'
SUMMARY = 'Longer description of event'
EVENT_ID = 'An unique ID for an event. Useful for downloading a single event to your calendar. \
This ID is not a permanent, persistent ID.'

# efiling
EFILING_TAG = '''
Efiling endpoints provide real-time campaign finance data received from electronic filers. \
Efiling endpoints only contain the most recent four months of data and don't contain \
the processed and coded data that you can find on other endpoints.
'''

EFILE_FILES = 'Basic information about electronic files coming into the FEC, posted as they are received.'
FILE_NUMBER = 'Filing ID number'

AMENDMENT_CHAIN = '''
The first value in the chain is the original filing.  The ordering in the chain reflects the order the
amendments were filed up to the amendment being inspected.
'''

AMENDMENT_INDICATOR = 'Amendent types:\n\
    -N   new\n\
    -A   amendment\n\
    -T   terminated\n\
    -C   consolidated\n\
    -M   multi-candidate\n\
    -S   secondary\n\n\
NULL might be new or amendment. If amendment indicator is null and the filings is the first or \
first in a chain treat it as if it was a new. If it is not the first or first in a chain then \
treat the filing as an amendment.\n\
'

AMENDED_BY = '''
If this report has been amended, this field gives the file_number of the report that should be used. For example,
if a report is amended multiple times, the first report and the first amendment will have the file_number \
of the final amended
report in the ameded_by field and the final report will have no id in the amended_by field.
'''
AMENDS_FILE = '''
For amendments, this file_number is the file_number of the previous report that is being amended. \
Refer to the amended_by for the most recent version of the report.
'''
AMENDMENT_NUMBER = '''
Number of times the report has been amended.
'''
EFILE_REPORTS = '''
Key financial data reported periodically by committees as they are reported. This feed includes summary
information from the the House F3 reports, the presidential F3p reports and the PAC and party
F3x reports.

Generally, committees file reports on a quarterly or monthly basis, but
some must also submit a report 12 days before primary elections. Therefore, during the primary
season, the period covered by this file may be different for different committees. These totals
also incorporate any changes made by committees, if any report covering the period is amended.
'''
EFILE_REPORTS += WIP_TAG

LINE_NUMBER = '''
Filter for form and line number using the following format:
`FORM-LINENUMBER`.  For example an argument such as `F3X-16` would filter
down to all entries from form `F3X` line number `16`.
'''

IMAGE_NUMBER = '''
An unique identifier for each page where the electronic or paper filing is reported.
'''

MAX_IMAGE_NUMBER = 'Maxium image number of the page where the schedule item is reported'

MIN_IMAGE_NUMBER = 'Minium image number of the page where the schedule item is reported'

MIN_FILTER = '''
Filter for all amounts greater than a value.
'''

MAX_FILTER = '''
Filter for all amounts less than a value.
'''

MIN_REPORT_RECEIPT_DATE = '''
Selects all items received by FEC after this date(MM/DD/YYYY or YYYY-MM-DD)
'''

MAX_REPORT_RECEIPT_DATE = '''
Selects all items received by FEC before this date(MM/DD/YYYY or YYYY-MM-DD)
'''

MIN_PAYMENT_DATE = '''
Minimum payment to date
'''

MAX_PAYMENT_DATE = '''
Maximum payment to date
'''

MIN_INCURRED_DATE = '''
Minimum incurred date
'''
MAX_INCURRED_DATE = '''
Maximum incurred date
'''

ENTITY_RECEIPTS_TOTLAS = '''
Provides cumulative receipt totals by entity type, over a two year cycle. Totals are adjusted to avoid double counting.

This is [the sql](https://github.com/fecgov/openFEC/blob/develop/data/migrations/V41__large_aggregates.sql) \
that creates these calculations.
'''
ENTITY_DISBURSEMENTS_TOTLAS = '''
Provides cumulative disbursement totals by entity type, over a two year cycle. Totals are adjusted \
to avoid double counting.

This is [the sql](https://github.com/fecgov/openFEC/blob/develop/data/migrations/V41__large_aggregates.sql) \
that creates these calculations.
'''

SUB_ID = '''
A unique identifier of the transactional report.
'''

STATUS_NUM = '''
Status of the transactional report.\n\
    -0- Transaction is entered \n\
          into the system.\n\
          But not verified.\n\
    -1- Transaction is verified.\n\
'''

CAND_CMTE_ID = '''
A unique identifier of the registered filer.
'''

REPORT_YEAR = '''
Forms with coverage date - \n\
    year from the coverage ending date.\n\
Forms without coverage date - \n\
    year from the receipt date.\n\
'''

OPERATIONS_LOG = '''
The Operations log contains details of each report loaded into the database. It is primarily
used as status check to determine when all of the data processes, from initial entry through
review are complete.
'''

MIN_RECEIPT_DATE = '''
Selects all filings received after this date(MM/DD/YYYY or YYYY-MM-DD)
'''

MAX_RECEIPT_DATE = '''
Selects all filings received before this date(MM/DD/YYYY or YYYY-MM-DD)
'''

MIN_COVERAGE_END_DATE = '''
Ending date of the reporting period after this date(MM/DD/YYYY or YYYY-MM-DD)
'''

MAX_COVERAGE_END_DATE = '''
Ending date of the reporting period before this date(MM/DD/YYYY or YYYY-MM-DD)
'''

MIN_TRANSACTION_DATA_COMPLETE_DATE = '''
Select all filings processed completely after this date(MM/DD/YYYY or YYYY-MM-DD)
'''

MAX_TRANSACTION_DATA_COMPLETE_DATE = '''
Select all filings processed completely before this date(MM/DD/YYYY or YYYY-MM-DD)
'''

SUMMERY_DATA_COMPLETE_DATE = '''
Date when the report is entered into the database
'''

SUMMERY_DATA_VERIFICATION_DATE = '''
Same day or a day after the report is loaded in the database
'''

TRANSACTION_DATA_COMPLETE_DATE = '''
Date when the report is processed completely
'''

TRANSACTION_COVERAGE_DATE = '''
Date through which transaction-level data are available
'''

LAST_EXPENDITURE_DATE = '''
When sorting by `expenditure_date`,
this is populated with the `expenditure_date` of the last result.
However, you will need to pass the index of that last result to
`last_index` to get the next page.
'''

LAST_EXPENDITURE_AMOUNT = '''
When sorting by `expenditure_amount`,
this is populated with the `expenditure_amount` of the last result.
However, you will need to pass the index of that last result to
`last_index` to get the next page.
'''
LAST_OFFICE_TOTAL_YTD = '''
When sorting by `office_total_ytd`,
this is populated with the `office_total_ytd` of the last result.
However, you will need to pass the index of that last result to
`last_index` to get the next page.'
'''

LAST_SUPPOSE_OPPOSE_INDICATOR = '''
When sorting by `support_oppose_indicator`,
this is populated with the `support_oppose_indicator` of the last result.
However, you will need to pass the index of that last result to `last_index`
to get the next page.'
'''

PAYEE_NAME = '''
Name of the entity that received the payment.
'''
IS_NOTICE = '''
Record filed as 24- or 48-hour notice.
'''
CALCULATED_CANDIDATE_SHARE = '''
"If an electioneering cost targets several candidates, the total cost is
divided by the number of candidates. If it only mentions one candidate
the full cost of the communication is listed."
'''
COMMUNICATION_DT = '''
It is the airing, broadcast, cablecast or other dissemination of the communication.
'''
PUBLIC_DISTRIBUTION_DT = '''
The pubic distribution date is the date that triggers disclosure of the
electioneering communication (date reported on page 1 of Form 9).
'''
DISBURSEMENT_DT = '''
Disbursement date includes actual disbursements and execution of contracts creating
an obligation to make disbursements (SB date of disbursement).
'''
EC_SUB_ID = '''
The identifier for each electioneering record.
'''

TOTAL_BY_OFFICE_TAG = ''' Aggregated candidate receipts and disbursements grouped by office by cycle.
'''

TOTAL_BY_OFFICE_BY_PARTY_TAG = ''' Aggregated candidate receipts and disbursements grouped by office by party by cycle.
'''

CANDIDATE_TOTAL_AGGREGATE_TAG = ''' Candidate total receipts and disbursements aggregated by `aggregate_by`.
'''

ACTIVE_CANDIDATE = ''' Candidates who are actively seeking office. If no value is specified, all candidates
are returned. When True is specified, only active candidates are returned. When False is
specified, only inactive candidates are returned.
'''

DISSEMINATION_DATE = '''
Date when a PAC distrubutes or disseminates an independent expenditure
and pays for it in the same reporting period
'''

DISSEMINATION_MAX_DATE = 'Selects all items distributed by this committee before this date'
DISSEMINATION_MIN_DATE = 'Selects all items distributed by this committee after this date'

CANDIDATE_FULL_SEARCH = '''
Search for candidates by candiate id or candidate first or last name
'''
# ======== financial end =========


# ======== legal start =========
LEGAL = '''
Explore relevant statutes, regulations and Commission actions.
'''

LEGAL_SEARCH = '''
Search legal documents by document type, or across all document types using keywords, parameter values and ranges.
'''

LEGAL_DOC_SEARCH = '''
Search legal documents by type and No
'''

LEGAL_DOC_NO = '''
Document number to fetch
'''

LEGAL_DOC_TYPE = '''
Choose a legal document type
'''

TEXT_SEARCH = '''
Text to search legal documents for
'''

FROM_HIT = '''
Get results starting from this index
'''

HITS_RETURNED = '''
Number of results to return (max 10)
'''

AO_NUMBER = '''
Force advisory opinion number
'''

AO_NAME = '''
Force advisory opinion name
'''

AO_MIN_ISSUE_DATE = '''
Earliest issue date of advisory opinion
'''

AO_MAX_ISSUE_DATE = '''
Latest issue date of advisory opinion
'''

AO_MIN_REQUEST_DATE = '''
Earliest request date of advisory opinion
'''

AO_MAX_REQUEST_DATE = '''
Latest request date of advisory opinion
'''

AO_CATEGORY = '''
Category of the document
'''

AO_IS_PENDING = '''
AO is pending
'''

AO_STATUS = '''
Status of AO (pending, withdrawn, or final)
'''

AO_REQUESTOR = '''
The requestor of the advisory opinion
'''

AO_REQUESTOR_TYPE = '''
Code of the advisory opinion requestor type.
'''

REGULATORY_CITATION = '''
Regulatory citations
'''

STATUTORY_CITATION = '''
Statutory citations
'''

CITATION_REQUIRE_ALL = '''
Require all citations to be in document (default behavior is any)
'''

AO_ENTITY_NAME = '''
Name of commenter or representative
'''

CASE_NO = '''
Enforcement matter case number
'''

CASE_DOCUMENT_CATEGORY = '''
Case category of associated documents
'''

CASE_RESPONDONTS = '''
Cases respondents
'''

CASE_DISPOSTIONS = '''
Cases dispositions
'''

CASE_ELECTION_CYCLES = '''
Cases election cycles
'''

CASE_MIN_OPEN_DATE = '''
The earliest date opened of case
'''

CASE_MAX_OPEN_DATE = '''
The latest date opened of case
'''

CASE_MIN_CLOSE_DATE = '''
The earliest date closed of case
'''

CASE_MAX_CLOSE_DATE = '''
The latest date closed of case
'''

CASE_DOCUMENT_CATEGORY_DESCRIPTION = '''
Select one or more case_doc_category_id to filter by corresponding CASE_DOCUMENT_CATEGORY:\n\
        - 1 - Conciliation and Settlement Agreements\n\
        - 2 - Complaint, Responses, Designation of Counsel and Extensions of Time\n\
        - 3 - General Counsel Reports, Briefs, Notifications and Responses\n\
        - 4 - Certifications\n\
        - 5 - Civil Penalties, Disgorgements, Other Payments and Letters of Compliance\n\
        - 6 - Statement of Reasons \n\
        - 1001 - ADR Settlement Agreements\n\
        - 1002 - Complaint, Responses, Designation of Counsel and Extensions of Time\n\
        - 1003 - ADR Memoranda, Notifications and Responses\n\
        - 1004 - Certifications\n\
        - 1005 - Civil Penalties, Disgorgements, Other Payments and Letters of Compliance\n\
        - 1006 - Statement of Reasons \n\
        - 2001 - Administrative Fine Case\n\
'''

MUR_TYPE = '''
Type of MUR : current or archived
'''

AF_NAME = '''
Admin fine committee name
'''

AF_COMMITTEE_ID = '''
Admin fine committee ID
'''

AF_REPORT_YEAR = '''
Admin fine report year
'''

AF_MIN_RTB_DATE = '''
The earliest Reason to Believe date
'''

AF_MAX_RTB_DATE = '''
The latest Reason to Believe date
'''

AF_RTB_FINE_AMOUNT = '''
Reason to Believe fine amount
'''

AF_MIN_FD_DATE = '''
The earliest Final Determination date
'''

AF_MAX_FD_DATE = '''
The latest Final Determination date
'''

AF_FD_FINE_AMOUNT = '''
Final Determination fine amount
'''
# ======== legal end =========


# ======== audit start =========
AUDIT = '''
The agency’s monitoring process may detect potential violations through a review of a committee’s reports or through a
Commission audit. By law, all enforcement cases must remain confidential until they’re closed.

The Commission is required by law to audit Presidential campaigns that accept public funds. In addition, the Commission
audits a committee when it appears not to have met the threshold requirements for substantial compliance \
with the Federal Election Campaign Act. The audit determines whether the committee complied with limitations, \
prohibitions and disclosure requirements.

These endpoints contain Final Audit Reports approved by the Commission since inception.
'''

AUDIT_CASE = '''
This endpoint contains Final Audit Reports approved by the Commission since inception.
The search can be based on information about the audited committee (Name, FEC ID Number, Type, \n\
Election Cycle) or the issues covered in the report.
'''

AUDIT_PRIMARY_CATEGORY = '''
This lists the options for the primary categories available in the /audit-search/ endpoint.
'''

AUDIT_CATEGORY = '''
This lists the options for the categories and subcategories available in the /audit-search/ endpoint.
'''

AUDIT_ID = '''
The audit issue. Each subcategory has an unique ID
'''

AUDIT_CASE_ID = '''
Primary/foreign key for audit tables
'''

PRIMARY_CATEGORY_ID = '''
Audit category ID (table PK)
'''

PRIMARY_CATEGORY_NAME = 'Primary Audit Category\n\
    - No Findings or Issues/Not a Committee\n\
    - Net Outstanding Campaign/Convention Expenditures/Obligations\n\
    - Payments/Disgorgements\n\
    - Allocation Issues\n\
    - Prohibited Contributions\n\
    - Disclosure\n\
    - Recordkeeping\n\
    - Repayment to US Treasury\n\
    - Other\n\
    - Misstatement of Financial Activity\n\
    - Excessive Contributions\n\
    - Failure to File Reports/Schedules/Notices\n\
    - Loans\n\
    - Referred Findings Not Listed\n\
'

SUB_CATEGORY_ID = '''
The finding id of an audit. Finding are a category of broader issues. Each category has an unique ID.
'''

SUB_CATEGORY_NAME = '''
The audit issue. Each subcategory has an unique ID.
'''

AUDIT_TIER = '''
1 specifies a primary category and 2 specifies a subcategory
'''

COMMITTEE_DESCRIPTION = 'Type of committee:\n\
        - H or S - Congressional\n\
        - P - Presidential\n\
        - X or Y or Z - Party\n\
        - N or Q - PAC\n\
        - I - Independent expenditure\n\
        - O - Super PAC \n\
'

FAR_RELEASE_DATE = '''
Final audit report release date
'''

LINK_TO_REPORT = '''
URL for retrieving the PDF document
'''
# ======== audit end =========

# ======== presidential start =========

PRESIDENTIAL = """
Data supporting fec.gov's presidential map.

For more information about the presidential map data available to download from fec.gov,\n\
please visit: https://www.fec.gov/campaign-finance-data/presidential-map-data/
"""

PRESIDENTIAL_BY_CANDIDATE = """
Net receipts per candidate.

Filter with `contributor_state='US'` for national totals
"""

PRESIDENTIAL_BY_STATE = """
Contribution receipts by state per candidate.

Filter by candidate_id and/or election_year
"""

PRESIDENTIAL_BY_SIZE = """
Contribution receipts by size per candidate.

Filter by candidate_id, election_year and/or size
"""

PRESIDENTIAL_BY_COVERAGE = """
Coverage end date per candidate.

Filter by candidate_id and/or election_year
"""

PRESIDENTIAL_BY_SUMMERY = """
Financial summary per candidate.

Filter by candidate_id and/or election_year
"""

CANDIDATE_ID_PRESIDENTIAL = CANDIDATE_ID + """\
  -P00000001    All candidates\n\
  -P00000002    Democrasts\n\
  -P00000003    Republicans\n\
"""

CANDIDATE_LAST_NAME = """
Candidate last name
"""

ROUND_CONTRIBUTIONS = """
Net receipts, in millions
"""

INDIVIDUAL_CONTRIBUTIONS_LESS_REFUNDS = """
individual contributions less refunds
"""

PAC_CONTRIBUTIONS_LESS_REFUNDS = """
pac contributions less refunds
"""

PARTY_CONTRIBUTIONS_LESS_REFUNDS = """
party contributions less refunds
"""

CANDIDATE_CONTRIBUTION_LESS_REPAYMENTS = """
candidate contributions less repayments
"""

DISBURSEMENTS_LESS_OFFSETS = """
disbursements less offsets
"""

TRANSACTION_TO_OTHER_AUTHORIZED_COMMITTEES = """
transfers to other authorized committees
"""

TRANSACTION_FROM_AFFILIATED_COMMITTEES = """
transfers from affiliated committees
"""

FUNDRAISING_DISBURSEMENTS = """
fundraising disbursements
"""

EXEMPT_LEGAL_ACCOUNTING_DISBURSEMENT = """
exempt legal accounting disbursement
"""

TOTAL_LOAN_REPAYMENTS_MADE = """
total loan repayments made
"""

REPAYMENTS_OTHER_LOANS_MADE_BY_CANDIDATE = """
repayments loans made by candidate
"""

REPAYMENTS_OTHER_LOANS = """
repayments other loans
"""

TOTAL_CONTRIBUTION_REFUNDS = """
total contribution refunds
"""

# ======== presidential end =========

TOTALS_INAUGURAL_DONATIONS = '''
This endpoint provides information about an inaugural committee's Form 13 report of donations accepted.
The data is aggregated by the contributor and the two-year period. We refer to two-year periods as a `cycle`.

'''
