# FEC API Documentation
## Overview

A RESTful web service supporting full-text and field-specific searches on Federal Election Commission(FEC) data.


## Methods
| Path | Description |
|-----|-----|
| [/candidate](candidates) | Basic information about candidates |
| [/committee](committees) | Basic information about committees |
| [/total](total) | Summary information about reports with totals by election cycle |

## Paramaters

<!-- this won't work for totals so we might want to list things out by endpoint -->
Supported parameters across all objects::
    q=         (fulltext search)

## Filtering