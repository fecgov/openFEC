import string

from flask.ext.restful import reqparse

from webservices.resources import Searchable, SingleResource
from .formatter import BaseCommitteeResource


class CommitteeResource(BaseCommitteeResource, SingleResource):

    parser = reqparse.RequestParser()
    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
    )


class CommitteeSearch(BaseCommitteeResource, Searchable):

    field_name_map = {
        "committee_id": string.Template("cmte_id={'$arg'}"),
        "fec_id": string.Template("cmte_id='$arg'"),
        "candidate_id": string.Template(
            "exists(dimlinkages?cand_id={'$arg'})"
        ),
        "state": string.Template(
            "top(dimcmteproperties.sort(expire_date-)).cmte_st={'$arg'}"
        ),
        "name": string.Template(
            "top(dimcmteproperties.sort(expire_date-)).cmte_nm~'$arg'"
        ),
        "type": string.Template(
            "top(dimcmtetpdsgn.sort(expire_date-)).cmte_tp={'$arg'}"
        ),
        "designation": string.Template(
            "top(dimcmtetpdsgn.sort(expire_date-)).cmte_dsgn={'$arg'}"
        ),
        "organization_type": string.Template(
            "top(dimcmteproperties.sort(expire_date-)).org_tp={'$arg'}"
        ),
        "party": string.Template(
            "top(dimcmteproperties.sort(expire_date-))"
            ".cand_pty_affiliation={'$arg'}"
        ),
    }

    parser = reqparse.RequestParser()
    parser.add_argument(
        'q',
        type=str,
        help='Text to search all fields for'
    )
    parser.add_argument(
        'committee_id',
        type=str,
        help="Committee's FEC ID"
    )
    parser.add_argument(
        'fec_id',
        type=str,
        help="Committee's FEC ID"
    )
    parser.add_argument(
        'state',
        type=str,
        help='U. S. State committee is registered in'
    )
    parser.add_argument(
        'name',
        type=str,
        help="Committee's name (full or partial)"
    )
    parser.add_argument(
        'candidate_id',
        type=str,
        help="Associated candidate's name (full or partial)"
    )
    parser.add_argument(
        'page',
        type=int,
        default=1,
        help='For paginating through results, starting at page 1'
    )
    parser.add_argument(
        'per_page',
        type=int,
        default=20,
        help='The number of results returned per page. Defaults to 20.'
    )
    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
    )
    parser.add_argument(
        'type',
        type=str,
        help='The one-letter type code of the organization'
    )
    parser.add_argument(
        'designation',
        type=str,
        help='The one-letter designation code of the organization'
    )
    parser.add_argument(
        'organization_type',
        type=str,
        help='The one-letter code for the kind for organization'
    )
    parser.add_argument(
        'party',
        type=str,
        help='Three letter code for party'
    )
