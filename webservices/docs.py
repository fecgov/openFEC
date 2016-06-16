"""Narrative API documentation."""

BEGINNING_IMAGE_NUMBER = '''
Unique identifier for the electronic or paper report. This number is used to construct
PDF URLs to the original document.
'''

CANDIDATE_ID = '''
A unique identifier assigned to each candidate registered with the FEC.
If a person runs for several offices, that person will have separate candidate IDs for each office.
'''

COMMITTEE_ID = '''
A unique identifier assigned to each committee or filer registered with the FEC. In general \
committee id's begin with the letter C which is followed by eight digits.
'''

CANDIDATE_CYCLE = '''
Two-year election cycle in which a candidate runs for office.
Calculated from FEC Form 2. The cycle begins with
an odd year and is named for its ending, even year. This cycle follows
the traditional house election cycle and subdivides the presidential
and Senate elections into comparable two-year blocks. To see data for
the entire four years of a presidential term or six years of a senatorial term,
you will need the `election_full` flag.
'''

COMMITTEE_CYCLE = '''
A two year election cycle that the committee was active- (after original registration
date but before expiration date in FEC Form 1s) The cycle begins with
an odd year and is named for its ending, even year.
'''

RECORD_CYCLE = '''
Filter records to only those that were applicable to a given
two-year period.The cycle begins with an odd year and is named
for its ending, even year.
'''

RECORD_YEAR = '''
Filter records to only those that were applicable to a given year.
'''

# committee uses a different definition for cycle because it is less straight forward
CYCLE = '''
Filter records to only those that are applicable to a given two-year
period. This cycle follows the traditional House election cycle and
subdivides the presidential and Senate elections into comparable
two-year blocks. The cycle begins with an odd year and is named for its
ending, even year.
'''

API_DESCRIPTION = '''
This API allows you to explore the way candidates and committees fund their campaigns.

This site is in [beta](https://18f.gsa.gov/dashboard/stages/#beta), which means
we’re actively working on it and adding new features. The official site for Federal
Election Commission (FEC) data is still the
[Campaign Finance Disclosure Portal](http://fec.gov/pindex.shtml). While we plan to
version big changes that are not backwards compatible, expect things to change as the API
develops.

The FEC API is a RESTful web service supporting full-text and field-specific searches on
FEC data. [Bulk downloads](http://fec.gov/data/DataCatalog.do) are available on the current
site. Information is tied to the underlying forms by file ID and image ID. Data is updated
nightly.

There is a lot of data, but a good place to start is to use search to find
interesting candidates and committees. Then, you can use their IDs to find report or line
item details with the other endpoints. If you are interested in individual donors, check
out contributor information in schedule_a.

Get an [API key here](https://api.data.gov/signup/). That will enable you to place up to 1,000
calls an hour. Each call is limited to 100 results per page. You can also discuss the data in the
[FEC data google group](https://groups.google.com/forum/#!forum/fec-data) or post questions
to the [Open Data Stack Exchange](https://opendata.stackexchange.com/questions/ask?tags=fec). The model definitions and schema are available at [/swagger](/swagger/). This is useful for making wrappers and exploring the data.

A few restrictions limit the way you can use FEC data. For example, you can’t use contributor
lists for commercial purposes or to solicit donations.
[Learn more here](http://www.fec.gov/pages/brochures/saleuse.shtml).

[View our source code](https://github.com/18F/openFEC). We welcome issues and pull requests!
'''

CANDIDATE_TAG = '''
Candidate endpoints give you access to information about the people running for office.
This information is organized by candidate_id. If you're unfamiliar with candidate IDs,
using `/candidates/search` will help you locate a particular candidate.

Officially, a candidate is an individual seeking nomination for election to a federal
office. People become candidates when they (or agents working on their behalf)
raise contributions or make expenditures that exceed $5,000.

The candidate endpoints primarily use data from FEC registration
[Form 1](http://www.fec.gov/pdf/forms/fecfrm1.pdf), for candidate information, and
[Form 2](http://www.fec.gov/pdf/forms/fecfrm2.pdf), for committee information.
'''

NAME_SEARCH = '''
Search for candidates or committees by name. If you're looking for information on a
particular person or group, using a name to find the `candidate_id` or `committee_id` on
this endpoint can be a helpful first step.
'''

LEGAL_SEARCH = '''
Search for legal documents.
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
[Form 1](http://www.fec.gov/pdf/forms/fecfrm1.pdf), for candidate information, and
[Form 2](http://www.fec.gov/pdf/forms/fecfrm2.pdf), for committees information, with additional information
to provide context.
'''

CANDIDATE_DETAIL = '''
This endpoint is useful for finding detailed information about a particular candidate. Use the
`candidate_id` to find the most recent information about that candidate.

'''

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

* Campaign committees authorized by particular candidates to raise and spend funds in
their campaigns
* Non-party committees (e.g., PACs), some of which may be sponsored by corporations,
unions, trade or membership groups, etc.
* Political party committees at the national, state, and local levels
* Groups and individuals making only independent expenditures
* Corporations, unions, and other organizations making internal communications

The committee endpoints primarily use data from FEC registration Form 1 and Form 2.
'''

COMMITTEE_LIST = '''
Fetch basic information about committees and filers. Use parameters to filter for
particular characteristics.

'''

COMMITTEE_DETAIL = '''
This endpoint is useful for finding detailed information about a particular committee or
filer. Use the `committee_id` to find the most recent information about the committee.
'''

COMMITTEE_HISTORY = '''
Explore a filer's characteristics over time. This can be particularly useful if the
committees change treasurers, designation, or `committee_type`.
'''

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
financial reporting forms. Query the `/candidates` endpoint to see an up to date list of all the
candidates that filed to run for a particular seat.
'''


FINANCIAL_TAG = '''
Fetch key information about a committee's Form 3, Form 3X, or Form 3P financial reports.

Most committees are required to summarize their financial activity in each filing; those summaries
are included in these files. Generally, committees file reports on a quarterly or monthly basis, but
some must also submit a report 12 days before primary elections. Therefore, during the primary
season, the period covered by this file may be different for different committees. These totals
also incorporate any changes made by committees, if any report covering the period is amended.

Information is made available on the API as soon as it's processed. Keep in mind, complex
paper filings take longer to process.

The financial endpoints use data from FEC [form 5](http://www.fec.gov/pdf/forms/fecfrm5.pdf),
for independent expenditors; or the summary and detailed summary pages of the FEC
[Form 3](http://www.fec.gov/pdf/forms/fecfrm3.pdf), for House and Senate committees;
[Form 3X](http://www.fec.gov/pdf/forms/fecfrm3x.pdf), for PACs and parties;
and [Form 3P](http://www.fec.gov/pdf/forms/fecfrm3p.pdf), for presidential committees.
'''

REPORTS = '''
Each report represents the summary information from FEC Form 3, Form 3X and Form 3P.
These reports have key statistics that illuminate the financial status of a given committee.
Things like cash on hand, debts owed by committee, total receipts, and total disbursements
are especially helpful for understanding a committee's financial dealings.

By default, this endpoint includes both amended and final versions of each report. To restrict
to only the final versions of each report, use `is_amended=false`; to view only reports that
have been amended, use `is_amended=true`.

Several different reporting structures exist, depending on the type of organization that
submits financial information. To see an example of these reporting requirements,
look at the summary and detailed summary pages of FEC Form 3, Form 3X, and Form 3P.
'''
REPORT_YEAR = '''
Year that the record applies to. Sometimes records are amended in subsequent
years so this can differ from underlying form's receipt date.
'''

TRANSACTION_YEAR = '''
This is a two-year period that is derived from the year a transaction took place in the
Itemized Schedule A and Schedule B tables. In cases where we have the date of the transaction 
(contribution_receipt_date in schedules/schedule_a, disbursement_date in schedules/schedule_b) 
the transaction_year is named after the ending, even-numbered year. If we do not have the date 
of the transation, we fall back to using the report year (report_year in both tables) instead, 
making the same cycle adjustment as necessary. If no transaction year is specified, the results 
default to the most current cycle.
'''

TOTALS = '''
This endpoint provides information about a committee's Form 3, Form 3X, or Form 3P financial reports,
which are aggregated by two-year period. We refer to two-year periods as a `cycle`.

The cycle is named after the even-numbered year and includes the year before it. To see
totals from 2013 and 2014, you would use 2014. In odd-numbered years, the current cycle
is the next year — for example, in 2015, the current cycle is 2016.

For presidential and Senate candidates, multiple two-year cycles exist between elections.
'''

SCHEDULE_A_TAG = '''
Schedule A records describe itemized receipts reported by a committee. This is where
you can look for individual contributors. If you are interested in
individual donors, `/schedules/schedule_a` will be the endpoint you use.

Once a person gives more than a total of $200, the donations of that person must be
reported by committees that file F3, F3X and F3P forms.

Contributions $200 and under are not required to be itemized, but you can find the total
amount of these small donations by looking up the "unitemized" field in the `/reports`
or `/totals` endpoints.

When comparing the totals from reports to line items. the totals will not match unless you
only look at items where `"is_individual":true` since the same transaction is in the data
multiple ways to explain the way it may move though different committees as an earmark.

For the Schedule A aggregates, such as by_occupation and by_state, include only unique individual
contributions. See below for full methodology.

### Methodology for determining unique, individual contributions

For receipts over $200 use FEC code line_number to identify individuals.

The line numbers that specify individuals that are automatically included:

Line number with description
    - 10 Contribution to Independent Expenditure-Only Committees (Super PACs), Political Committees with non-contribution accounts (Hybrid PACs) and nonfederal party "soft money" accounts (1991-2002) from a person (individual, partnership, limited liability company, corporation, labor organization, or any other organization or group of persons)
    - 15 Contribution to political committees (other than Super PACs and Hybrid PACs) from an individual, partnership or limited liability company
    - 15E Earmarked contributions to political committees (other than Super PACs and Hybrid PACs) from an individual, partnership or limited liability company
    - 15J Memo - Recipient committee's percentage of contribution from an individual, partnership or limited liability company given to joint fundraising committee
    - 18J | Memo - Recipient committee's percentage of contribution from a registered committee given to joint fundraising committee
    - 30, 30T, 31, 31T, 32 Individual party codes

For receipts under $200:
We check the following codes and see if there is "earmark" (or a variation) in the `memo_text`
description of the contribution.

Line number with description
    -11AI The itemized individual contributions from F3 schedule A
    -12 Nonfederal other receipt - Levin Account (Line 2)
    -17 Itemized individual contributions from Form 3P
    -17A Itemized individual contributions from Form 3P
    -18 Itemized individual contributions from Form 3P

Of those transactions,[under $200, and having "earmark" in the memo text OR transactions having the codes 11A, 12, 17, 17A, or 18], we then want to exclude earmarks.

This is [the sql function](https://github.com/18F/openFEC/blob/develop/data/functions/individual.sql) that defines individual contributions:
'''

SCHEDULE_A = SCHEDULE_A_TAG + '''

The data is divided in two-year periods, called `transaction_year`, which is derived from
the `contribution_receipt_date`. If no value is supplied, the results will default to the 
most recent two-year period that is named after the ending, even-numbered year.

Due to the large quantity of Schedule A filings, this endpoint is not paginated by
page number. Instead, you can request the next page of results by adding the values in
the `last_indexes` object from `pagination` to the URL of your last request. For
example, when sorting by `contribution_receipt_date`, you might receive a page of
results with the following pagination information:

```
pagination: {
    pages: 2152643,
    per_page: 20,
    count: 43052850,
    last_indexes: {
        last_index: 230880619,
        last_contribution_receipt_date: "2014-01-01"
    }
}
```

To fetch the next page of results, append "last_index=230880619&last_contribution_receipt_date=2014-01-01"
to the URL.

Note: because the Schedule A data includes many records, counts for
large result sets are approximate.
'''

SCHEDULE_B_TAG = '''
Schedule B filings describe itemized disbursements. This data
explains how committees and other filers spend their money. These figures are
reported as part of forms F3, F3X and F3P.
'''

SCHEDULE_B = SCHEDULE_B_TAG + '''

The data is divided in two-year periods, called `transaction_year`, which is derived from
the `disbursement_date`. If no value is supplied, the results will default to the 
most recent two-year period that is named after the ending, even-numbered year.


Due to the large quantity of Schedule B filings, this endpoint is not paginated by
page number. Instead, you can request the next page of results by adding the values in
the `last_indexes` object from `pagination` to the URL of your last request. For
example, when sorting by `disbursement_date`, you might receive a page of
results with the following pagination information:

```
pagination: {
    pages: 965191,
    per_page: 20,
    count: 19303814,
    last_indexes: {
        last_index: 230906248,
        last_disbursement_date: "2014-07-04"
    }
}
```

To fetch the next page of results, append "last_index=230906248&amp;last_disbursement_date=2014-07-04"
to the URL.

Note: because the Schedule B data includes many records, counts for
large result sets are approximate.
'''

SCHEDULE_B_BY_PURPOSE = '''
Schedule B receipts aggregated by disbursement purpose category. To avoid double counting, memoed items are not included.
Purpose is a combination of transaction codes, category codes and disbursement description.  See [the sql function](https://github.com/18F/openFEC/blob/7d2c058706f1b385b2cc18d75eb3ad0a1fba9d52/data/functions/purpose.sql)
'''

SCHEDULE_E_TAG = '''
Schedule E covers the line item expenditures for independent expenditures. For example, if a super PAC
bought ads on TV to oppose a federal candidate, each ad purchase would be recorded here with
the expenditure amount, name and id of the candidate, and whether the ad supported or opposed the candidate.

An independent expenditure is an expenditure for a communication "expressly advocating the election or
defeat of a clearly identified candidate that is not made in cooperation, consultation, or concert with,
or at the request or suggestion of, a candidate, a candidate’s authorized committee, or their agents, or
a political party or its agents.

Aggregates by candidate do not include 24 and 48 hour reports. This ensures we don't double count expenditures
and the totals are more accurate. You can still find the information from 24 and 48 hour reports in
`/schedule/schedule_e/`.
"

'''

SCHEDULE_E = SCHEDULE_E_TAG + '''

Due to the large quantity of Schedule E filings, this endpoint is not paginated by
page number. Instead, you can request the next page of results by adding the values in
the `last_indexes` object from `pagination` to the URL of your last request. For
example, when sorting by `expenditure_amount`, you might receive a page of
results with the following pagination information:

```
 "pagination": {
    "count": 152623,
    "last_indexes": {
      "last_index": 3023037,
      "last_expenditure_amount": -17348.5
    },
    "per_page": 20,
    "pages": 7632
  }
}
```

To fetch the next page of results, append
"&last_index=3023037&last_expenditure_amount=-17348.5" to the URL.

Note: because the Schedule E data includes many records, counts for
large result sets are approximate.
'''

SIZE_DESCRIPTION = '''
This endpoint aggregates Schedule A donations based on size:

 - $200 and under
 - $200.01 - $499.99
 - $500 - $999.99
 - $1000 - $1999.99
 - $2000 +

In cases where the donations are $200 or less, the results include small donations
that are reported on Schedule A, but filers are not required to itemize those small
donations, so we also add unitemized contributions. Unitemized contributions come
from the summary section of the forms. It represents the total money brought in from
donors that are not reported on Schedule A and have given $200 or less.
'''

SIZE = '''
The total all contributions in the following ranges:
```
  -0    $200 and under
  -200  $200.01 - $499.99
  -500  $500 - $999.99
  -1000 $1000 - $1999.99
  -2000 $2000 +
```
Unitemized contributions are included in the `0` category.
'''

API_KEY_DESCRIPTION = '''
API key for https://api.data.gov. Get one at https://api.data.gov/signup.
'''
SEARCH_TAG = '''
Search for candidates or committees by name.
'''

FILINGS_TAG = '''
Search for financial reports and other FEC documents.
'''

FILINGS = '''
All official records and reports filed by or delivered to the FEC.

Note: because the filings data includes many records, counts for large
result sets are approximate.
'''

DOC_TYPE = '''
The type of document, for documents other than reports:
    - 2 24 Hour Contribution Notice
    - 4 48 Hour Contribution Notice
    - A Debt Settlement Statement
    - B Acknowledgment of Receipt of Debt Settlement Statement
    - C RFAI: Debt Settlement First Notice
    - D Commission Debt Settlement Review
    - E Commission Response TO Debt Settlement Request
    - F Administrative Termination
    - G Debt Settlement Plan Amendment
    - H Disavowal Notice
    - I Disavowal Response
    - J Conduit Report
    - K Termination Approval
    - L Repeat Non-Filer Notice
    - M Filing Frequency Change Notice
    - N Paper Amendment to Electronic Report
    - O Acknowledgment of Filing Frequency Change
    - S RFAI: Debt Settlement Second
    - T Miscellaneous Report TO FEC
    - V Repeat Violation Notice (441A OR 441B)
    - P Notice of Paper Filing
    - R F3L Filing Frequency Change Notice
    - Q Acknowledgment of F3L Filing Frequency Change
    - U Unregistered Committee Notice
'''
DATES_TAG = '''
Reporting deadlines, election dates FEC meetings, events etc.
'''

CALENDAR_DATES = '''
Combines the election and reporting dates with commission meetings, conferences, outreach, AOs, Rules, Litigation dates and other
event into one calendar.

State filtering now applies to elections, reports and reporting periods.

Presidential pre-primary report due dates are not shown on even years.
Filers generally opt to file monthly rather than submit over 50 pre-primary election
reports. All reporting deadlines are available at /reporting-dates/ for reference.

This is [the sql function](https://github.com/18F/openFEC/blob/develop/data/sql_updates/omnibus_dates.sql)
that creates the calendar.
'''

COMMUNICATION_TAG = '''
Reports of communication costs by corporations and membership organizations
from the FEC [F7 forms](http://www.fec.gov/pdf/forms/fecform7.pdf).
'''
ELECTIONEERING = '''
An electioneering communication is any broadcast, cable or satellite communication that fulfills each of the following conditions:

- The communication refers to a clearly identified federal candidate;
- The communication is publicly distributed by a television station, radio station, cable television system or satellite system for a fee; and
- The communication is distributed within 60 days prior to a general election or 30 days prior to a primary election to federal office.
'''

COMMUNICATION_COST = '''
52 U.S.C. 30118 allows "communications by a corporation to its stockholders and
executive or administrative personnel and their families or by a labor organization
to its members and their families on any subject," including the express advocacy of
the election or defeat of any Federal candidate.  The costs of such communications
must be reported to the Federal Election Commission under certain circumstances.
'''


# fields and filters

# shared
LOAD_DATE = 'Date the information was loaded into the FEC systems. This can be affected by \
reseting systems and other factors, refer to receipt_date for the day that the FEC received \
the paper or electronic document. Keep in mind that paper filings take more time to process \
and there can be a lag between load_date and receipt_date. This field can be helpful to \
identify paper records that have been processed recently.'
PARTY = 'Three-letter code for the party affiliated with a candidate or committee. For example, DEM for Democratic Party and REP for Republican Party.'
PARTY_FULL = 'Party affiliated with a candidate or committee'
FORM_TYPE = 'The form where the underlying data comes from, for example, Form 1 would appear as F1'
REPORT_TYPE = 'Name of report where the underlying data comes from'
RECEIPT_DATE = 'Date the FEC received the electronic or paper record'
STATE_GENERIC = 'US state or territory'
ZIP_CODE = 'Zip code'

#candidates
CANDIDATE_NAME = 'Name of candidate running for office'
OFFICE_FULL = 'Federal office candidate runs for: House, Senate or presidential'
OFFICE = 'Federal office candidate runs for: H, S or P'
STATE = 'US state or territory where a candidate runs for office'
YEAR = 'See records pertaining to a particular election year. The list of election years \
is based on a candidate filing a statement of candidacy (F2) for that year.'
DISTRICT = 'Two-digit US House distirict of the office the candidate is running for. \
Presidential, Senate and House at-large candidates will have District 00.'
CANDIDATE_STATUS = 'One-letter code explaining if the candidate is:\n\
        - C present candidate\n\
        - F future candidate\n\
        - N not yet a candidate\n\
        - P prior candidate\n\
'
INCUMBENT_CHALLENGE = "One-letter code ('I', 'C', 'O') explaining if the candidate is an incumbent, a challenger, or if the seat is open."
INCUMBENT_CHALLENGE_FULL = 'Explains if the candidate is an incumbent, a challenger, or if the seat is open.'
ACTIVE_THROUGH = 'Last year a candidate was active. This field is specific to the candidate_id so if the same person runs for another office, there may be a different record for them.'
HAS_RAISED_FUNDS = 'A boolean that describes if a candidate\'s committee has ever received any receipts for their campaign for this particular office. (Candidates have separate candidate IDs for each office.)'
FEDERAL_FUNDS_FLAG = 'A boolean the describes if a presidential candidate has accepted federal funds. The flag will be false for House and Senate candidates.'

# committees
COMMITTEE_NAME = 'The name of the committee. If a committee changes its name, \
    the most recent name will be shown.'
COMMITTEE_YEAR = 'A year that the committee was active— (after original registration date \
    or filing but before expiration date)'
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
        - I independent expenditor (person or group)\n\
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
TREASURER_NAME = 'Name of the Committee\'s treasurer. If multiple treasurers for the \
committee, the most recent treasurer will be shown.'
COMMITTEE_STATE = 'State of the committee\'s address as filed on the Form 1'
FIRST_FILE_DATE = 'The day the FEC received the committee\'s first filing. \
This is usually a Form 1 committee registration.'
LAST_FILE_DATE = 'The day the FEC received the committee\'s most recent filing'
LAST_F1_DATE = 'The day the FEC received the committee\'s most recent Form 1'

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

# schedule B
RECIPIENT_NAME = 'Name of the entity receiving the disbursement'
RECIPIENT_ID = 'The FEC identifier should be represented here if the entity receiving \
the disbursement is registered with the FEC.'

# communication cost and electioneering
SUPPORT_OPPOSE_INDICATOR = 'Explains if the money was spent in order to support or oppose a candidate or candidates. (Coded S or O for support or oppose.) This indicator applies to independent expenditures and communication costs.'

# schedule B
PURPOSE = 'Purpose of the expenditure'

# dates
DUE_DATE = 'Date the report is due'
CREATE_DATE = 'Date the record was created'
UPDATE_DATE = 'Date the record was updated'
ELECTION_DATE = 'Date of election'
ELECTION_YEAR = 'Year of election'
#? TODO: add more categories
ELECTION_TYPE = 'Election type \n\
Convention, Primary, General, Special, Runoff etc.'
SENATE_CLASS = 'Senators run every six years and each state has two senators. General elections \
are held every 2 years. The Senate elections are staggered so there are three classes of Senators \
In a given state, only one Senate seat is up for election at a time and every six years, there is \
not a senate election in a given state. Thus, the Senate is broken up in to three groups called \
classes. Senators in the same class are up for election at the same time. Sometimes it is a bit \
less straight forward when, because there are situations in which there is a special election to \
fill a vacancy in the Senate. In those cases class refers to the seat groupings and not the time \
of the election.'

# filings
DOCUMENT_TYPE = 'Type of form, report or documents'
ENDING_IMAGE_NUMBER = 'Image number is an unique identifier for each page the electronic or paper \
report. The last image number corresponds to the image number for the last page of the document.'
IMAGE_NUMBER = 'An unique identifier for each page the electronic or paper \
report.'


# Reports and Totals

def add_period(var):
    return var + ' total for the reporting period'


def add_ytd(var):
    return var + ' total for the year to date'

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
INDIVIDUAL_ITEMIZED_CONTRIBUTIONS = 'Individual itemized contributions are from individuals whose aggregate contributions total over $200 per individual per year. Be aware, some filers choose to itemize donations $200 or less.'
INDIVIDUAL_ITEMIZED_CONTRIBUTIONS_PERIOD = 'Individual itemized contributions are from individuals whose aggregate contributions total over $200 per individual per year. This amount represents the total of these receipts for the reporting period.'
INDIVIDUAL_ITEMIZED_CONTRIBUTIONS_YTD = 'Individual itemized contributions are from individuals whose aggregate contributions total over $200 per individual per year. This amount represents the total of these receipts for the year to date.'
INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS = 'Unitemized contributions are made individuals whose aggregate contributions total $200 or less per individual per year. Be aware, some filers choose to itemize donations $200 or less and in that case those donations will appear in the itemized total.'
INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS_PERIOD = 'Unitemized contributions are from individuals whose aggregate contributions total $200 or less per individual per year. This amount represents the total of these receipts for the reporting period.'
INDIVIDUAL_UNITEMIZED_CONTRIBUTIONS_YTD =  'Itemized contributions are from individuals whose aggregate contributions total $200 or less per individual per year. This amount represents the total of these receipts for the year to date.'




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


# presidential
# receipts
FEDERAL_FUNDS = 'Federal funds: Public funding of presidential elections means that qualified presidential candidates receive federal government funds to pay for the valid expenses of their political campaigns in both the primary and general elections.'
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
CATEGORY = 'Type of date reporting date, live event, etc.'
CAL_STATE = 'The state field only applies to election dates and reporting deadlines, reporting periods and all other dates do not have the array of states to filter on'
CAL_DESCRIPTION = 'Brief description of event'
SUMMARY = 'Longer description of event'
EVENT_ID = 'An unique ID for an event. Useful for downloading a single event to your calendar. This ID is not a permanent, persistent ID.'
