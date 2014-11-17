# FEC API Documentation
## Committee

Endpoint:
`/committee`

## Supported parameters for committee
| Parameter |Discription |
|-----|-----|
| q=          | full-text search |
| /<cmte_id>  | Single candidate's record |
| cmte_id=    | Synonym for /<cmte_id> |
| name=       | Committee's name |
| state=      | Two-letter state abbreviation |
| type_code=   one-letter code see cmte_decoder
| designation_code=  one-letter code see designation_decoder



\# I don't think this one is reliable
| candidate=  | Associated candidate's name |

## Fields


#### committee_id

Unique id of the committee.

#### designation

Designation of the committee. See full list of designations and designation codes [here](designations). The committee's designation can affect what rules the committee must follow.

#### designation_code

Designation code of the committee. See full list of designations and designation codes [here](designations).

#### type

The type of the committee. See full list of types and type codes [here](committee_type).The committee's type can affect what rules the committee must follow.

#### type_code

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

#### type_code

The type of the committee code. See full list of types and type codes [here](committee_type).



