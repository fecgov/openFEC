"""Narrative API documentation."""

CANDIDATE_ID = '''
A unique identifier assigned to each candidate registered with the FEC.
If a person runs for several offices, they will have separate candidate IDs for each office.
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

DESCRIPTION = '''
This API allows you to explore the way candidates and committees fund their campaigns.

This site is in [beta](https://18f.gsa.gov/dashboard/stages/#beta), which means
we’re actively working on it and adding new features. The official site for FEC
data is still the [Campaign Finance Disclosure Portal](http://fec.gov/pindex.shtml).
While we plan on versioning any changes that are not backwards compatible, expect things
to change as the API develops.

The FEC API is a RESTful web service supporting full-text and field-specific searches on
Federal Election Commission (FEC) data.

This API allows you to explore the vast array of campaign finance data that the FEC
collects. Each endpoint focuses on a different aspect of disclosure.

There is a lot of data, but a good place to start exploring, is using search to find
interesting candidates and committees and then, looking up report or line item details
using IDs on the other endpoints. If you are interested in individual donors, check
out contributor information in schedule_a.

Information can tied to the underlying forms by file ID and image ID.

[View source code](https://github.com/18F/openFEC). Issues and pull requests welcome!
'''

CANDIDATE_TAG = '''
Candidate endpoints give you access to information about the people running for office.
The information is organized by candidate_id. If you are not familiar with candidate_ids
using  `/candidates/search` will help you locate a particular candidate.

Officially, a candidate is an individual seeking nomination for election to a federal
office. Someone becomes a candidate when he or she (or agents working on his or her behalf)
raises contributions or makes expenditures that exceed $5,000.

The candidate endpoints primarily use data from FEC registration forms 1 and 2.
'''

NAME_SEARCH = '''
Search for candidates or committees by name. If you are looking for information on a
particular person or group, using a name to find the `candidate_id` or `committee_id` on
this endpoint can be a helpful first step.
'''

CANDIDATE_LIST = '''
You can fetch basic information about candidates and use parameters to filter for the
candidates you are looking for.

Each result reflects a unique FEC candidate ID. That ID is unique to the candidate for a
particular office sought. So, if a candidate runs for the same office over time, that id
will stay the same. If the same person runs for another office, for example, a House
candidate runs for a Senate office, that candidate will get an additional id that will be
unique to him or her for that office.
'''

CANDIDATE_HISTORY = '''
Find out a candidate's characteristics over time. This can be particularly useful if the
candidate runs for office in different districts over time and finding out when a candidate
first ran.

This information is organized by `candidate_id` so this will not help you find a candidate
that ran for different offices over time, since he or she will get a new id for each office.
'''

CANDIDATE_SEARCH = '''
Fetch basic information about candidates and their principal committees.

Each result reflects a unique FEC candidate ID. That ID is unique to the candidate for a
particular office sought. So, if a candidate runs for the same office over time, that id
will stay the same. If the same person runs for another office, for example, a House
candidate runs for a Senate office, that candidate will get an additional id that will be
unique to him or her for that office.

The candidate endpoint uses data from FEC forms 1 and 2 with additional forms to provide
context.
'''

CANDIDATE_DETAIL = '''
This endpoint is useful for finding detailed information about a particular candidate. Use the
`candidate_id` to find the most recent information about the candidate.

'''

COMMITTEE_TAG = '''
Committees are entities that spend and raise money in election. Their characteristics and
relationships with candidates can change over time.

You might want to use filters or the search endpoints to find a committee you are looking
for, and then use the other committee endpoints to get more information about the committee
you are interested.

Financial information is organized by committee_id, so finding the committee you are interested
will lead you to more granular financial information.

The committee endpoints include all FEC filers, even if they are not registered as a committee.

Officially, committees include the committees and organizations that file with the FEC. There are a
number of different types of organizations who file financial reports with the FEC:

* Campaign committees authorized by particular candidates to raise and spend funds in
their campaigns
* Non-party committees (i.e. PACs), some of which may be sponsored by corporations,
unions, trade or membership groups, etc.
* Political party committees at the national, state, and local levels
* Groups and individuals making only independent expenditures
* Corporations, unions and other organizations making internal communications

The committee endpoints primarily use data from FEC registration forms 1 and 2.
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
Find out a filer's characteristics over time. This can be particularly useful if the
committees change treasurers, designation or committee_type over time.
'''

FINANCIAL_TAG = '''
Fetch key information about a committee's form 3, 3x or 3p financial reports.

As part of each financial report, most committees must provide a summary of their financial
activity in each filing, and these summaries for each reporting period are included in
these files. Generally, committees file reports on a quarterly or monthly basis, but some
must also submit a report 12 days before primary elections. During the primary election
season, therefore, the period covered by this file may be different for different
committees. These totals also incorporate any changes made by committees if any report
covering the period is amended.

Information is made available on the API as soon as it is processed. Keep in mind, complex
paper filings take longer to process.

The financial endpoints use data from FEC form 3, form 3X and form 3P.
'''

REPORTS='''
Each report represents the summary information from FEC form 3, form 3X, form 3P and
form 5 reports.

These reports have key statistics to see the financial status of a given committee.
Things like cash on hand, debts owed by committee, total receipts and total disbursements
are especially helpful for understanding a committee's financial dealings.

If a report is amended, this endpoint just shows the final amended version.

There are several different reporting structures, depending on what type of organization
is submitting financial information. Form 5 only filers are required to disclose the least
amount of information. To see an example of these reporting requirements you can look at
[FEC form 5](http://www.fec.gov/pdf/forms/fecfrm5.pdf), for independent expenditors; or the
summary and detailed summary pages of the FEC
[form 3](http://www.fec.gov/pdf/forms/fecfrm3.pdf), for House and Senate committees;
[form 3X](http://www.fec.gov/pdf/forms/fecfrm3x.pdf), for PACs and parties;
and form [3P](http://www.fec.gov/pdf/forms/fecfrm3p.pdf), for presidential committees.
'''

TOTALS = '''
This endpoint provides information about a committee's form 3, 3x or 3p financial reports,
aggregated by two-year period. We are referring to two year periods as `cycle`.

The cycle is named after the even numbered year and includes the previous year. So, if you
wanted to see the totals from 2013 and 2014, you would use 2014. The current cycle will be
the next year, if the current is an odd-numbered year.

For presidential and senatorial candidates, there are multiple 2-year cycles in-between
their elections.
'''

SCHEDULE_A = '''
Schedule A filings describe itemized receipts reported by a committee. This is where
you can look for individual contributors.

Once a person gives more than a total of $200, the donations of that person must be
reported by committees that file F3, F3X and F3P forms.

Contributions under $200 are not required to be itemized, but you can find the total
amount of these small donations by looking up the "unitemized" field in the `/reports`
endpoint.

When comparing the totals from reports to line items. the totals will not match unless you
take out items where `"memo_code":'X'`. Memoed items are subtotals of receipts that are
already accounted for in another schedule a line item.
'''

SCHEDULE_B = '''
Schedule B filings describe itemized disbursements that committees. This data
explains how committees and other filers spend their money. These figures are
reported on F3, F3X and F3P forms.
'''

# If we add schedules as a grouping
SCHEDULES = '''
Schedules come from particular sections on forms and contain detailed transactional data.

Schedule A explains where contributions come from. If you are interested in
individual donors, this will be the endpoint you use.

Schedule B explains how money is spent.
'''

API_KEY_DESCRIPTION = '''
API key for https://api.data.gov. Get one at http://api.data.gov/signup.
'''
SEARCH_TAG = '''
Search for candidates or committees by name.
'''
