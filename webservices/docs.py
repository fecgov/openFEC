"""Narrative API documentation."""

DESCRIPTION = '''
This API allows you to explore the way candidates and committees fund their campaigns.
The FEC API is a RESTful web service supporting full-text and field-specific searches on
Federal Election Commission (FEC) data.

This API allows you to explore the vast array of campaign finance data that the FEC
collects. Each endpoint focuses on a different aspect of disclosure.

Information can tied to the underlying forms by file ID and image ID.
'''

CANDIDATE_TAG = '''
Candidate endpoints give you access to information about the people running for office.
The information is organized by candidate_id. If you are not familiar with canidate_ids
using  `/candidates/search` will help you locate a particular candidate.

Officially, a candidate is an individual seeking nomination for election to a federal
office. Someone becomes a candidate when he or she (or agents working on his or her behalf)
raises contributions or makes expenditures that exceed $5,000.
'''

NAME_SEARCH = '''
Search for candidates or committees by name. If you are looking for information on a
particular person or group, using a name to find the `candidate_id` or `committee_id` on
this endpoint can be a helpful first step.
'''

# I am not sure this is being used
CANDIDATE_LIST = '''
You can fetch basic information about candidates and use parameters to filter for the
candidates you are looking for.

Each result reflects a unique FEC candidate ID. That ID is unique to the candidate for a
particular office sought. So, if a candidate runs for the same office over time, that id
will stay the same. If the same person runs for another office, for example, a House
candidate runs for a Senate office, that candidate will get an additional id that will be
unique to him or her for that office.

The candidate endpoint uses data from FEC forms 1 and 2 with additional forms to provide
context.
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
This endpoint is useful for finding detailed information about a candidate. Use the
`candidate_id` to find the most recent information about the candidate.

'''

COMMITTEE_LIST = '''
Fetch basic information about committees.

Committees include the committees and organizations that file with the FEC. There are a
number of different types of organizations who file financial reports with the FEC:

* Campaign committees authorized by particular candidates to raise and spend funds in
their campaigns
* Non-party committees (i.e. PACs), some of which may be sponsored by corporations,
unions, trade or membership groups, etc.
* Political party committees at the national, state, and local levels
* Groups and individuals making only independent expenditures
* Corporations, unions and other organizations making internal communications

The committee endpoint returns FEC forms 1 and 2 with additional forms to provide context.
'''

COMMITTEE_DETAIL = '''
Fetch detailed information about a committee.

For further description, see `/v1/committees`.
'''

REPORTS = '''
Fetch key information about a committee's form 3, 3x or 3p financial reports.

As part of each financial report, most committees must provide a summary of their financial
activity in each filing, and these summaries for each reporting period are included in
these files. Generally, committees file reports on a quarterly or monthly basis, but some
must also submit a report 12 days before primary elections. During the primary election
season, therefore, the period covered by this file may be different for different
committees. These totals also incorporate any changes made by committees if any report
covering the period is amended.

There are several different reporting structures, depending on what type of organization
is submitting financial information. To see an example of these reporting requirements you
can look at the summary and detailed summary pages of the FEC form 3, form 3X and form 3P.
'''

TOTALS = '''
Fetch key information about a committee's form 3, 3x or 3p financial reports, aggregated by two-year
election cycle period.

For further description, see `/v1/committee/{committee_id}/reports`.
'''

API_KEY_DESCRIPTION = '''
API key for https://api.data.gov. Get one at http://api.data.gov/signup.
'''
