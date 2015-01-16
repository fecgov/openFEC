# FEC API Documentation
## Overview

This API allows you to explore the way candidates and committees fund their campaigns.The FEC API is a RESTful web service supporting full-text and field-specific searches on Federal Election Commission(FEC) data.

This API allows you to explore the vast array of campaign finance data that the FEC collects. Each endpoint focuses on a different aspect of disclosure.

Information can tied to the underlying forms by file id and image id.


## Methods
| Path | Description |
|-----|-----|
| [/candidate](candidates) | Candidates are search-able by name, id and other properties. Years may be provided to see the activity of a candidate over time. The endpoint also returns basic information about committees that file regarding the candidate. This endpoint uses data from FEC forms 1 and 2 with additional forms to provide context. |
| [/committee](committees) | Committees are search-able by name, id and other properties. There is a description about the type of committee, where the committee is, treasure information and This endpoint returns  FEC forms 1 and 2 with additional forms to provide context. |
|[/name](name)| This endpoint quickly searches through candidate and committee name providing results with some context. This is perfect for a type-ahead search.|
| [/total](total) | This endpoint returns financial reports and give totals for committees by two-year election cycles. You can filter by committee id and election cycle. Reports include FEC F3, F3X and F3P forms, referencing additional filings for context. |

## Parameters


### Full text
Full text search is available for /candidate and /committee endpoints. It searches the candidate and committee names for matches.
    q=                      (fulltext search)

### Field filtering
Customize your query by field. Ask for one field, multiple fields or all fields. Asking for fewer fields will speed up your queries.
    field=name              (returns only the name field)
    field=name,address      (returns only the name and address fields)
    field=*                 (returns all available fields)

### Pagination
Results default to 20 per page. You can request a different pagination using per_page. Per page can not exceed TKTKTK.
    per_page=5
    per_page=30


## Results
Results are returned as a json object. That object will contain the api_version; pagination, which includes count, per_page, page and pages; and results, the information requested by the api call.

Error messages will also be re turned in json and contain an error message and status code.



