"""Narrative API documentation."""

CANDIDATE_ID = '''
A unique identifier assigned to each candidate registered with the FEC.
If a person runs for several offices, that person will have separate candidate IDs for each office.
'''

COMMITTEE_ID = '''
A unique identifier assigned to each committee or filer registered with the FEC.
'''

DESCRIPTION = '''
This API allows you to explore the way candidates and committees fund their campaigns.

This site is in [beta](https://18f.gsa.gov/dashboard/stages/#beta), which means
we’re actively working on it and adding new features. The official site for Federal Election Commission (FEC)
data is still the [Campaign Finance Disclosure Portal](http://fec.gov/pindex.shtml).
While we plan on versioning any changes that aren't backwards compatible, expect things to change as the
API develops.

The FEC API is a RESTful web service supporting full-text and field-specific searches on
FEC data.

This API allows you to explore the vast array of campaign finance data that the FEC
collects. Each endpoint focuses on a different aspect of disclosure.

Information is tied to the underlying forms by file ID and image ID.

[View our source code](https://github.com/18F/openFEC). We welcome issues and pull requests!
'''

CANDIDATE_TAG = '''
Candidate endpoints give you access to information about the people running for office.
This information is organized by candidate_id. If you're unfamiliar with candidate IDs,
using `/candidates/search` will help you locate a particular candidate.

Officially, a candidate is an individual seeking nomination for election to a federal
office. People become candidates when they (or agents working on their behalf)
raise contributions or make expenditures that exceed $5,000.

The candidate endpoints primarily use data from FEC registration Form 1 and Form 2.
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

The candidate endpoint uses data from FEC Form 1 and Form 2, with additional forms to provide
context.
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

FINANCIAL_TAG = '''
Fetch key information about a committee's Form 3, Form 3X, or Form 3P financial reports.

Most committees are required to summarize their financial activity in each filing; those summaries 
are included in these files. Generally, committees file reports on a quarterly or monthly basis, but 
some must also submit a report 12 days before primary elections. Therefore, during the primary 
season, the period covered by this file may be different for different committees. These totals 
also incorporate any changes made by committees, if any report covering the period is amended.

Information is made available on the API as soon as it's processed. Keep in mind, complex
paper filings take longer to process.

The financial endpoints use data from FEC Form 3, Form 3X and Form 3P.
'''

REPORTS='''
Each report represents the summary information from FEC Form 3, Form 3X and Form 3P.
These reports have key statistics that illuminate the financial status of a given committee.
Things like cash on hand, debts owed by committee, total receipts, and total disbursements
are especially helpful for understanding a committee's financial dealings.

If a report is amended, this endpoint shows only the final, amended version.

Several different reporting structures exist, depending on the type of organization that
submits financial information. To see an example of these reporting requirements, 
look at the summary and detailed summary pages of the FEC Form 3, Form 3X, and Form 3P.
'''

TOTALS = '''
This endpoint provides information about a committee's Form 3, Form 3X, or Form 3P financial reports,
which are aggregated by two-year period. We refer to two-year periods as a `cycle`.

The cycle is named after the even-numbered year and includes the year before it. To see
totals from 2013 and 2014, you would use 2014. In odd-numbered years, the current cycle 
is the next year — for example, in 2015, the current cycle is 2016.

For presidential and Senate candidates, multiple two-year cycles exist between elections.
'''

API_KEY_DESCRIPTION = '''
API key for https://api.data.gov. Get one at http://api.data.gov/signup.
'''
SEARCH_TAG = '''
Search for candidates or committees by name.
'''
