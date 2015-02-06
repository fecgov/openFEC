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
import os
from flask import Flask
from flask.ext.restful import reqparse
from flask.ext import restful
import flask.ext.restful.representations.json
from json_encoding import TolerantJSONEncoder
import logging
from datetime import datetime

from candidates.resources import CandidateResource, CandidateSearch
import decoders
from resources import Searchable, SingleResource
from totals.resources import TotalResource, TotalSearch
from webservices.common.models import db
from webservices.resources.candidates import CandidateList

speedlogger = logging.getLogger('speed')
speedlogger.setLevel(logging.CRITICAL)
speedlogger.addHandler(logging.FileHandler(('rest_speed.log')))

flask.ext.restful.representations.json.settings["cls"] = TolerantJSONEncoder


def sqla_conn_string():
    sqla_conn_string = os.getenv('SQLA_CONN')
    if not sqla_conn_string:
        print("Environment variable SQLA_CONN is empty; running against "
              + "local `cfdm_test`")
        sqla_conn_string = 'postgresql://:@/cfdm_test'
    return sqla_conn_string

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = sqla_conn_string()
api = restful.Api(app)
db.init_app(app)


# still need to implement year
def format_committees(self, data, page, fields, year):
    #return data

    results = []
    for cmte in data:
        committee = {}
        # Keeps track of previous info
        record = {}

        for api_name, fec_name in self.dimcmte_mapping:
                if cmte['dimcmte'].has_key(fec_name):
                    committee[api_name] = cmte['dimcmte'][fec_name]

        # addresses, description,
        addresses = {}
        for item in cmte['dimcmteproperties']:
            # shortcut for formatting
            if item['expire_date'] is not None:
                if item['expire_date'] > datetime.now():
                    expired = False
                else:
                    expired = True
            else:
                expired = False

            if item.has_key('load_date') and item['load_date'] is not None:
                committee['load_date'] = item['load_date']

            # address
            address = {}
            for api_name, fec_name in self.committee_address_field_mappings:
                if item.has_key(fec_name) and item[fec_name] is not None and fec_name != 'expire_date':
                    address[api_name] = item[fec_name]

            if 'expire_date' in fields or '*' in fields or fields == []:
                address['expire_date'] = item['expire_date']

            if address.has_key('state_full'):
                address['state_full'] = item['cmte_st_desc'].strip()

            if len(address) > 0:
                if item['expire_date'] == None:
                    committee['address'] = address
                else:
                    if not record.has_key('address'):
                        record['address'] = {}
                    record['address'][item['expire_date']] = address

            # properties table called description in api
            description = {}
            for api_name, fec_name in self.properties_field_mapping:
                if item.has_key(fec_name) and item[fec_name] is not None and fec_name != 'expire_date':
                    description[api_name] = item[fec_name]

            if item.has_key('cand_pty_affiliation') and item['cand_pty_affiliation'] in decoders.party:
                description['party_full'] = decoders.party[item['cand_pty_affiliation']]

            if len(description) > 0:
                if 'expire_date' in fields or '*' in fields:
                    description['expire_date'] = item['expire_date']
                if expired == False and len(description) > 0:
                    committee['description'] = description
                else:
                    if not record.has_key('description'):
                         record['description'] = {}
                    record['description'][item['expire_date']] = description

            # treasurer
            treasurer = {}
            for api_name, fec_name in self.treasurer_field_mapping:
                if item.has_key(fec_name) and item[fec_name] is not None:
                    treasurer[api_name] = item[fec_name]

            if len(treasurer) > 0:
                if 'expire_date' in fields or '*' in fields:
                    treasurer['expire_date'] = item['expire_date']
                if expired == False:
                    committee['treasurer'] = treasurer
                else:
                    if not record.has_key('treasurer'):
                        record['treasurer'] = {}
                    record['treasurer'][item['expire_date']] = treasurer

            # custodian
            custodian = {}
            for api_name, fec_name in self.custodian_field_mapping:
                if item.has_key(fec_name) and item[fec_name] is not None:
                    custodian[api_name] = item[fec_name]

            if len(custodian) > 0:
                if 'expire_date' in fields or '*' in fields:
                    custodian['expire_date'] = item['expire_date']
                if expired == False:
                    committee['custodian'] = custodian
                else:
                    if not record.has_key('custodian'):
                        record['custodian'] = {}
                    record['custodian'][item['expire_date']] = custodian

            #designation
            for designation in cmte['dimcmtetpdsgn']:
                status = {}
                for api_name, fec_name in self.designation_mapping:
                    if designation.has_key(fec_name) and fec_name != 'expire_date':
                        status[api_name] = designation[fec_name]

                if 'expire_date' in fields or '*' in fields or fields == []:
                    status['expire_date'] = designation['expire_date']

                if designation.has_key('cmte_dsgn') and  decoders.designation.has_key(designation['cmte_dsgn']):
                    status['designation_full'] = decoders.designation[designation['cmte_dsgn']]

                if designation.has_key('cmte_tp') and decoders.cmte.has_key(designation['cmte_tp']):
                    status['type_full'] = decoders.cmte[designation['cmte_tp']]

                if len(status) > 0:
                    if designation['expire_date'] == None:
                        committee['status'] = status
                    else:
                        if not record.has_key('status'):
                            record['status'] = {}
                        record['status'][designation['expire_date']] = status

            # candidates associated with committees
            candidate_dict = {}
            for cand in cmte['dimlinkages']:
                candidate ={}
                if cmte['dimlinkages'] != []:
                    if cmte['dimlinkages'][0].has_key('dimcand'):
                        if cmte['dimlinkages'][0]['dimcand'][0]['dimcandproperties'] != []:
                            # this assumes the most recent is last, which seems to be the case
                            candidate['candidate_name'] = cmte['dimlinkages'][0]['dimcand'][0]['dimcandproperties'][-1]['cand_nm']
                        if cmte['dimlinkages'][0]['dimcand'][0]['dimcandoffice'] != []:
                            # not worried about this changing because they would get a new id if it did
                            candidate['office_sought'] = cmte['dimlinkages'][0]['dimcand'][0]['dimcandoffice'][0]['dimoffice'][0]['office_tp']
                            candidate['office_sought_full'] = cmte['dimlinkages'][0]['dimcand'][0]['dimcandoffice'][0]['dimoffice'][0]['office_tp_desc']


                for api_name, fec_name in self.linkages_field_mapping:
                    if cand.has_key(fec_name) and fec_name != 'expire_date' and fec_name != 'cand_id':
                        candidate[api_name] = cand[fec_name]
                if candidate.has_key('election_years'):
                    candidate['election_years']= [int(candidate['election_years'])]
                if 'expire_date' in fields or '*' in fields or fields == []:
                    candidate['expire_date'] = cand['expire_date']
                if 'candidate_id' in fields or 'fec_id' in fields or '*' in fields or fields == []:
                    candidate['candidate_id'] = cand['cand_id']
                if candidate.has_key('type'):
                    candidate['type_full'] = decoders.cmte[candidate['type']]
                if candidate.has_key('designation'):
                    candidate['designation_full'] = decoders.designation[candidate['designation']]
                # add all expire dates and save to committee
                if len(candidate) > 0:
                    if not candidate_dict.has_key(cand['cand_id']):
                        candidate_dict[cand['cand_id']] = candidate
                    elif candidate.has_key('election_years'):
                        candidate_dict[cand['cand_id']]['election_years'].append(candidate['election_years'][0])

        # one entry per candidate
        for cand_id in sorted(candidate_dict):
            if not committee.has_key('candidates'):
                committee['candidates'] = []
            committee['candidates'].append(candidate_dict[cand_id])

        # if there are no current records, add the most recent record to the top level committee information
        for record_type in record:
            if not committee.has_key(record_type):
                key = sorted(record[record_type], key=record[record_type].get, reverse=True)[0]
                committee[record_type] = record[record_type][key]
                # removing from archive so it is not double posted
                del record[record_type][key]
                # adding additional records to archive newest to oldest

            if len(record[record_type]) > 0 and ('archive' in fields or '*' in fields):
                if not committee.has_key('archive'):
                    committee['archive'] = {}
                for key in sorted(record[record_type], key=record[record_type].get, reverse=True):
                    if not committee['archive'].has_key(record_type):
                        committee['archive'][record_type] = []
                    committee['archive'][record_type].append(record[record_type][key])
        #name short cut
        if committee.has_key('description') and committee['description'].has_key('name'):
            committee['name'] = committee['description']['name']
        results.append(committee)

    return {'api_version':"0.2", 'pagination':page, 'results': results}
    #return data


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
api.add_resource(CandidateList, '/candidate')
api.add_resource(CommitteeResource, '/committee/<string:id>')
api.add_resource(CommitteeSearch, '/committee')
api.add_resource(TotalResource, '/total/<string:id>')
api.add_resource(TotalSearch, '/total')
api.add_resource(NameSearch, '/name')
