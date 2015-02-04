"""
A RESTful web service supporting fulltext and field-specific searches on FEC
candidate data.

SEE DOCUMENTATION FOLDER
(We can leave this here for now but this is all covered in the documentation
and changes should be reflected there)

Supported parameters across all objects::

    q=         (fulltext search)

Supported for /candidate ::

    /<cand_id>   Single candidate's record
    cand_id=     Synonym for /<cand_id>
    fec_id=      Synonym for /<cand_id>
    office=      (governmental office run for)
    state=       (two-letter code)
    district=    two-digit number
    name=        (candidate's name)
    page=        Page number
    party=       (3-letter abbreviation)
    per_page=    Number of records per page
    year=        (any year in which candidate ran)
    fields=      specify the fields returned

Supported for /committee ::

    /<cmte_id>   Single candidate's record
    cmte_id=     Synonym for /<cmte_id>
    fec_id=      Synonym for /<cmte_id>
    name=        (committee's name)
    state=       (two-letter code)
    candidate=   (associated candidate's name)
    type=   one-letter code see decoders.cmte
    designation=  one-letter code see decoders.designation
    year=        The four-digit election year

"""
import string
import sys
import sqlalchemy as sa
from flask import Flask
from flask.ext.restful import reqparse
from flask.ext import restful
import flask.ext.restful.representations.json
from json_encoding import TolerantJSONEncoder
import logging

from candidates.resources import CandidateResource, CandidateSearch
from committees.format import format_committees
from db import db_conn
from resources import Searchable, SingleResource
from totals.resources import TotalResource, TotalSearch

speedlogger = logging.getLogger('speed')
speedlogger.setLevel(logging.CRITICAL)
speedlogger.addHandler(logging.FileHandler(('rest_speed.log')))

flask.ext.restful.representations.json.settings["cls"] = TolerantJSONEncoder

app = Flask(__name__)
api = restful.Api(app)


class NameSearch(Searchable):
    """
    A quick name search (candidate or committee) optimized for response time for typeahead
    """

    fulltext_qry = """SELECT cand_id AS candidate_id,
                             cmte_id AS committee_id,
                             name,
                             office_sought
                      FROM   name_search_fulltext
                      WHERE  name_vec @@ to_tsquery(:findme || ':*')
                      ORDER BY ts_rank_cd(name_vec, to_tsquery(:findme || ':*')) desc
                      LIMIT  20"""

    parser = reqparse.RequestParser()
    parser.add_argument(
        'q',
        type=str,
        help='Name (candidate or committee) to search for',
    )

    def get(self):
        args = self.parser.parse_args(strict=True)

        qry = sa.sql.text(self.fulltext_qry)
        findme = ' & '.join(args['q'].split())
        data = db_conn().execute(qry, findme = findme).fetchall()

        return {"api_version": "0.2",
                "pagination": {'per_page': 20, 'page': 1, 'pages': 1, 'count': len(data)},
                "results": [dict(d) for d in data]}

    def format(self, data_dict, page_data, year):
        args = self.parser.parse_args()
        fields = self.find_fields(args)
        return format_committees(self, data_dict, page_data, fields, year)


class Committee(object):

    default_fields = {
        'dimcmte_fields': 'cmte_id,form_tp,load_date,expire_date,',
        'properties_fields': '*,',
        'linkages_fields': 'cand_id,cmte_tp,cmte_dsgn,cand_election_yr,expire_date,link_date, /dimcand{/dimcandproperties{cand_nm,}, /dimcandoffice{/dimoffice{office_tp,office_tp_desc}}}',
        'designation_fields': '*,',
    }

    table_name_stem = 'cmte'
    viewable_table_name = "(dimcmte?exists(dimcmteproperties))"
    def query_text(self, show_fields):
        # We always need expire date and cand_id to sort the information
        return '(%s{{%s max(dimcmteproperties.cmte_nm)},/dimcmteproperties{expire_date,%s}, /dimlinkages{cand_id,expire_date,%s}, /dimcmtetpdsgn{expire_date,%s}}).sort(max(dimcmteproperties.cmte_nm)+)' % (
            self.viewable_table_name,
            show_fields['dimcmte_fields'],
            show_fields['properties_fields'],
            show_fields['linkages_fields'],
            show_fields['designation_fields']
        )

    dimcmte_mapping = (
        ('committee_id', 'cmte_id'),
        ('form_type', 'form_tp'),
        ('load_date', 'load_date'),
        ('expire_date', 'expire_date'),
        ('*', '*'),
    )
    linkages_field_mapping = (
        ('candidate_id', 'cand_id'),
        ('type', 'cmte_tp'),
        ('designation', 'cmte_dsgn'),
        ('election_years', 'cand_election_yr'),
        ('expire_date', 'expire_date'),
        ('link_date', 'link_date'),
    )
    linkages_mapping = (
        ('committees', 'cand_id,cmte_tp,cmte_dsgn,cand_election_yr,\
            expire_date,link_date'),
        ('candidate_name', '/dimcand{/dimcandproperties{cand_nm}}'),
        ('office_sought', '/dimcandoffice{/dimoffice{office_tp}}}'),
        ('office_sought_full', '/dimcandoffice{/dimoffice{office_tp_desc}}}'),
        ('candidate_name', '/dimcand{/dimcandproperties{cand_nm,}'),
        ('*', '*, /dimcand{/dimcandproperties{cand_nm,}, /dimcandoffice{/dimoffice{office_tp,office_tp_desc}}}'),
    ) + linkages_field_mapping

    designation_mapping = (
        ('designation', 'cmte_dsgn'),
        ('type', 'cmte_tp'),
        ('expire_date', 'expire_date'),
        ('load_date', 'load_date'),
        ('receipt_date', 'receipt_date'),
        ('*', '*'),
    )

    # Beginning of the dimcmteproperties mapping, making subdivisions for easier formatting
    committee_address_field_mappings = (
        ('street_1', 'cmte_st1'),
        ('street_2', 'cmte_st2'),
        ('city', 'cmte_city'),
        ('state', 'cmte_st'),
        ('state_full', 'cmte_st_desc'),
        ('zip', 'cmte_zip'),
    )
    committee_address = ('address', 'street_1,cmte_st1,street_2,cmte_st2,cmte_city,cmte_st,cmte_zip')

    treasurer_field_mapping = (
        ('city', 'cmte_treasurer_city'),
        ('name_1', 'cmte_treasurer_f_nm'),
        ('name_2', 'cmte_treasurer_l_nm'),
        ('name_middle', 'cmte_treasurer_m_nm'),
        ('name_full', 'cmte_treasurer_nm'),
        ('phone', 'cmte_treasurer_ph_num'),
        ('name_prefix', 'cmte_treasurer_prefix'),
        ('state', 'cmte_treasurer_st'),
        ('street_1', 'cmte_treasurer_st1'),
        ('street_2', 'cmte_treasurer_st2'),
        ('name_suffix', 'cmte_treasurer_suffix'),
        ('name_title', 'cmte_treasurer_title'),
        ('zip', 'cmte_treasurer_zip'),
    )
    treasurer = (
        ('treasurer', 'cmte_treasurer_city,cmte_treasurer_f_nm,\
            cmte_treasurer_l_nm,cmte_treasurer_m_nm,cmte_treasurer_nm,\
            cmte_treasurer_ph_num,cmte_treasurer_prefix,cmte_treasurer_st,\
            cmte_treasurer_st1,cmte_treasurer_st2,cmte_treasurer_suffix,\
            cmte_treasurer_title,cmte_treasurer_zip'),
    )
    custodian_field_mapping = (
        ('city', 'cmte_custodian_city'),
        ('name_1', 'cmte_custodian_f_nm'),
        ('name_2', 'cmte_custodian_l_nm'),
        ('name_middle', 'cmte_custodian_m_nm'),
        ('name_full', 'cmte_custodian_nm'),
        ('phone', 'cmte_custodian_ph_num'),
        ('name_prefix', 'cmte_custodian_prefix'),
        ('state', 'cmte_custodian_st'),
        ('street_1', 'cmte_custodian_st1'),
        ('street_2', 'cmte_custodian_st2'),
        ('name_suffix', 'cmte_custodian_suffix'),
        ('name_title', 'cmte_custodian_title'),
        ('zip', 'cmte_custodian_zip'),
    )
    custodian = (
        ('custodian', 'cmte_custodian_city,cmte_custodian_f_nm\
            ,cmte_custodian_l_nm,cmte_custodian_m_nm,cmte_custodian_nm,\
            cmte_custodian_ph_num,cmte_custodian_prefix,cmte_custodian_st,\
            cmte_custodian_st1,cmte_custodian_st2,cmte_custodian_suffix,\
            cmte_custodian_title,cmte_custodian_zip'),
    )
    properties_field_mapping = (
        ('email', 'cmte_email'),
        ('fax', 'cmte_fax'),
        ('name', 'cmte_nm'),
        ('website', 'cmte_web_url'),
        ('expire_date', 'expire_date'),
        ('filing_frequency', 'filing_freq'),
        ('form_type', 'form_tp'),
        ('leadership_pac', 'leadership_pac'),
        ('load_date', 'load_date'),
        ('lobbyist_registrant_pac', 'lobbyist_registrant_pac_flg'),
        ('organization_type', 'org_tp'),
        ('organization_type_full', 'org_tp_desc'),
        ('original_registration_date', 'orig_registration_dt'),
        ('party', 'cand_pty_affiliation'),
        ('party_type', 'party_cmte_type'),
        ('party_type_full', 'party_cmte_type_desc'),
        ('qualifying_date', 'qual_dt'),
    )

    properties_mapping = properties_field_mapping + committee_address_field_mappings + committee_address + treasurer + treasurer_field_mapping + custodian_field_mapping + custodian + (('*', '*'),)

    # connects mappings to field names
    maps_fields = (
        (dimcmte_mapping, 'dimcmte_fields'),
        (properties_mapping, 'properties_fields'),
        (linkages_mapping, 'linkages_fields'),
        (designation_mapping, 'designation_fields'),
    )


class CommitteeResource(SingleResource, Committee):

    parser = reqparse.RequestParser()
    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
    )

    def format(self, data_dict, page_data, year):
        args = self.parser.parse_args()
        fields = self.find_fields(args)
        return format_committees(self, data_dict, page_data, fields, year)


class CommitteeSearch(Searchable, Committee):

    field_name_map = {"committee_id": string.Template("cmte_id={'$arg'}"),
                        "fec_id": string.Template("cmte_id='$arg'"),
                        "candidate_id":string.Template(
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
                            "top(dimcmteproperties.sort(expire_date-)).cand_pty_affiliation={'$arg'}"
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

    def format(self, data_dict, page_data, year):
        args = self.parser.parse_args()
        fields = self.find_fields(args)
        return format_committees(self, data_dict, page_data, fields, year)


class Help(restful.Resource):
    def get(self):
        result = {'doc': sys.modules[__name__].__doc__,
                  'endpoints': {}}
        for cls in (CandidateSearch, CommitteeSearch):
            name = cls.__name__[:-6].lower()
            result['endpoints'][name] = {'arguments supported':
                                         {a.name: a.help for a in sorted(cls.parser.args)}}
        return result


api.add_resource(Help, '/')
api.add_resource(CandidateResource, '/candidate/<string:id>')
api.add_resource(CandidateSearch, '/candidate')
api.add_resource(CommitteeResource, '/committee/<string:id>')
api.add_resource(CommitteeSearch, '/committee')
api.add_resource(TotalResource, '/total/<string:id>')
api.add_resource(TotalSearch, '/total')
api.add_resource(NameSearch, '/name')
