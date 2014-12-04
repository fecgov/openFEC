# FEC API Documentation
## Committee

Endpoint:
`/committee`

## Supported parameters for committee
| Parameter |description |
|-----|-----|
| q=          | full-text search |
| /<cmte_id>  | Single candidate's record |
| cmte_id=    | Synonym for /<cmte_id> |
| name=       | Committee's name |
| state=      | Two-letter state abbreviation |
| type_code=   |one-letter code of committee type  |
| designation_code=  |one-letter code of committee designation  |
| organization_type_code= |one-letter code of organization type |
| candidate_id=  | Associated candidate's id number |

## Fields


#### committee_id

Unique id of the committee.

#### designation_full

Designation of the committee. See full list of designations and designation codes [here](designations). The committee's designation can affect what rules the committee must follow.

#### designation

Designation code of the committee. See full list of designations and designation codes [here](designations).

#### organization_type

The orgnizational structure of the committee. Such as: Corporation, Labor Organization, Membership Organization, rade Association, Cooperative, Corporation Without Capital Stock.

#### organization_type_type

Code for organization type

C = Corporation,
L = Labor Organization,
M = Membership Organization,
T = Trade Association,
V = Cooperative,
W = Corporation Without Capital Stock,

#### type_full

The type of the committee. See full list of types and type codes [here](committee_type).The committee's type can affect what rules the committee must follow.

#### type

The type of the committee code. See full list of types and type codes [here](committee_type).


#### committee_id

Unique id of the committee.

#### designation

Designation of the committee. See full list of designations and designation codes [here](designations). The committee's designation can affect what rules the committee must follow.

#### designation_code

Designation code of the committee. See full list of designations and designation codes [here](designations).

#### election_year

Year of the election. Elections are in two-year election cycles.

#### type

The type of the committee. See full list of types and type codes [here](committee_type).The committee's type can affect what rules the committee must follow.

#### organization_type

The kind of organization,

{add codes here }

#### type_codes

The type of the committee code. See full list of types and type codes [here](committee_type).

#### website

The url to the committee's webpage, if provided.

#### filing_frequency

How often a committee is scheduled to file.
M = monthly
Q = quarterly

#### lobbyist_registrant_pac

#### leadership_pac

#### original_registration_date

#### qualifying_date
