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
A unique identifier assigned to each committee or filer registered with the FEC.
'''

CANDIDATE_CYCLE = '''
Two-year election cycle in which a candidate runs for office. Calculated from FEC form 2.
'''

COMMITTEE_CYCLE = '''
A two year election cycle that the committee was active- (after original registration
date but before expiration date in FEC form 1s)
'''

RECORD_CYCLE = '''
Filter records to only those that were applicable to a given two-year period.
'''

RECORD_YEAR = '''
Filter records to only those that were applicable to a given year.
'''

# committee uses a different definition for cycle because it is less straight forward
CYCLE = '''
Filter records to only those that are applicable to a given two-year period.
'''

DESCRIPTION = '''
This API allows you to explore the way candidates and committees fund their campaigns.

This site is in [beta](https://18f.gsa.gov/dashboard/stages/#beta), which means
we’re actively working on it and adding new features. The official site for Federal
Election Commission (FEC) data is still the
[Campaign Finance Disclosure Portal](http://fec.gov/pindex.shtml). While we plan on
versioning any changes that are not backwards compatible, expect things to change as the API
develops.

The FEC API is a RESTful web service supporting full-text and field-specific searches on
FEC data.This API allows you to explore the vast array of campaign finance data that the FEC
collects. Each endpoint focuses on a different aspect of disclosure. Information is tied to
the underlying forms by file ID and image ID.

There is a lot of data, but a good place to start exploring, is using search to find
interesting candidates and committees and then, looking up report or line item details
using IDs on the other endpoints. If you are interested in individual donors, check
out contributor information in schedule_a.

A few restrictions limit the way you can use FEC data. For example, you can’t use contributor
lists for commercial purposes or to solicit donations.
[Learn more here](http://www.fec.gov/pages/brochures/saleuse.shtml).

[View our source code](https://github.com/18F/openFEC). We welcome issues and pull requests!

Get an [API key here](https://api.data.gov/signup/)!

Base URL: https://api.open.fec.gov/v1
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
[form 3](http://www.fec.gov/pdf/forms/fecfrm3.pdf), for House and Senate committees;
[form 3X](http://www.fec.gov/pdf/forms/fecfrm3x.pdf), for PACs and parties;
and [form 3P](http://www.fec.gov/pdf/forms/fecfrm3p.pdf), for presidential committees.
'''

REPORTS = '''
Each report represents the summary information from FEC Form 3, Form 3X and Form 3P.
These reports have key statistics that illuminate the financial status of a given committee.
Things like cash on hand, debts owed by committee, total receipts, and total disbursements
are especially helpful for understanding a committee's financial dealings.

If a report is amended, this endpoint shows only the final, amended version.

Several different reporting structures exist, depending on the type of organization that
submits financial information. To see an example of these reporting requirements,
look at the summary and detailed summary pages of FEC Form 3, Form 3X, and Form 3P.
'''
REPORT_YEAR = '''
Year that the record applies to. Sometimes records are amended in subsequent
years so this can differ from underlying form's receipt date.
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
take out items where `"memoed_subtotal":true`. Memoed items are subtotals of receipts
that are already accounted for in another schedule a line item.

For the Schedule A aggregates, "memoed" items are not included to avoid double counting.

'''

SCHEDULE_A = SCHEDULE_A_TAG + '''

Due to the large quantity of Schedule A filings, this endpoint is not paginated by
page number. Instead, you can request the next page of results by adding the values in
the `last_indexes` object from `pagination` to the URL of your last request. For
example, when sorting by `contributor_receipt_date`, you might receive a page of
results with the following pagination information:

```
pagination: {
    pages: 2152643,
    per_page: 20,
    count: 43052850,
    last_indexes: {
        last_index: 230880619,
        last_contributor_receipt_date: "2014-01-01"
    }
}
```

To fetch the next page of results, append "last_index=230880619&last_contributor_receipt_date=2014-01-01"
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

Due to the large quantity of Schedule B filings, this endpoint is not paginated by
page number. Instead, you can request the next page of results by adding the values in
the `last_indexes` object from `pagination` to the URL of your last request. For
example, when sorting by `contributor_receipt_date`, you might receive a page of
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

Note: because the Schedule A data includes many records, counts for
large result sets are approximate.
'''

SCHEDULE_E_TAG = '''
Schedule E covers the line item expenditures for independent expenditures. For example, if a super PAC
bought and adds on TV to oppose a federal candidate, each ad purchase would be recorded here with
the expenditure amount, name and id of the candidate, and weather the ad supported or opposed the candidate.

An independent expenditure is an expenditure for a communication "expressly advocating the election or
defeat of a clearly identified candidate that is not made in cooperation, consultation, or concert with,
or at the request or suggestion of, a candidate, a candidate’s authorized committee, or their agents, or
a political party or its agents."

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
API key for https://api.data.gov. Get one at http://api.data.gov/signup.
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
