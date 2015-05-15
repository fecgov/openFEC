"""Narrative API documentation."""

DESCRIPTION = '''
This API allows you to explore the way candidates and committees fund their campaigns.
The FEC API is a RESTful web service supporting full-text and field-specific searches on
Federal Election Commission (FEC) data.

This API allows you to explore the vast array of campaign finance data that the FEC
collects. Each endpoint focuses on a different aspect of disclosure.

Information can tied to the underlying forms by file ID and image ID.
'''

CANDIDATE_LIST = '''
Fetch basic information about candidates.

Each result reflects a unique FEC candidate ID. That ID is unique to the candidate for a
particular office sought. So, if a candidate runs for the same office over time, that id
will stay the same. If the same person runs for another office, for example, a House
candidate runs for a Senate office, that candidate will get an additional id that will be
unique to him or her for that office.

The candidate endpoint uses data from FEC forms 1 and 2 with additional forms to provide
context.
'''

CANDIDATE_SEARCH = '''
Fetch basic information about a condidate, including the candidate's principal committees.

Identical to `/v1/candidates`, modulo the addition of nested principal committees.
'''

CANDIDATE_DETAIL = '''
Fetch detailed information about a candidate.

For further description, see `/v1/candidates`.
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
