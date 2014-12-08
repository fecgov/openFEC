"""
A RESTful web service supporting fulltext and field-specific searches on FEC candidate data.

SEE DOCUMENTATION FOLDER
(We can leave this here for now but this is all covered in the documentation and changes should be reflected there)

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
    type=   one-letter code see cmte_decoder
    designation=  one-letter code see designation_decoder
    year=        The four-digit election year

"""
from collections import defaultdict
import os
import re
import string
import sys
import sqlalchemy as sa
from flask import Flask
from flask.ext.restful import reqparse
from flask.ext import restful
import flask.ext.restful.representations.json
from htsql import HTSQL
import htsql.core.domain
from json_encoding import TolerantJSONEncoder
import logging
import pprint
import time
import copy
from datetime import datetime
from psycopg2._range import DateTimeRange

speedlogger = logging.getLogger('speed')
speedlogger.setLevel(logging.INFO)
speedlogger.addHandler(logging.FileHandler(('rest_speed.log')))

flask.ext.restful.representations.json.settings["cls"] = TolerantJSONEncoder

sqla_conn_string = os.getenv('SQLA_CONN')
if not sqla_conn_string:
    print("Environment variable SQLA_CONN is empty; running against local `cfdm_test`")
    sqla_conn_string = 'postgresql://:@/cfdm_test'
engine = sa.create_engine(sqla_conn_string)
conn = engine.connect()

htsql_conn_string = sqla_conn_string.replace('postgresql', 'pgsql')
htsql_conn = HTSQL(htsql_conn_string)

app = Flask(__name__)
api = restful.Api(app)


cmte_decoder = {'P': 'Presidential',
                'H': 'House',
                'S': 'Senate',
                'C': 'Communication Cost',
                'D': 'Delegate Committee',
                'E': 'Electioneering Communication',
                'I': 'Independent Expenditor (Person or Group)',
                'N': 'PAC - Nonqualified',
                'O': 'Independent Expenditure-Only (Super PACs)',
                'Q': 'PAC - Qualified',
                'U': 'Single Candidate Independent Expenditure',
                'V': 'PAC with Non-Contribution Account - Nonqualified',
                'W': 'PAC with Non-Contribution Account - Qualified',
                'X': 'Party - Nonqualified',
                'Y': 'Party - Qualified',
                'Z': 'National Party Nonfederal Account'
}
designation_decoder = {'A': 'Authorized by a candidate',
                'J': 'Joint fundraising committee',
                'P': 'Principal campaign committee',
                'U': 'Unauthorized',
                'B': 'Lobbyist/Registrant PAC',
                'D': 'Leadership PAC',
}



# DEFAULTING TO 2012 FOR THE DEMO
def default_year():
    # year = str(datetime.now().strftime("%Y"))
    year = '2012'
    return year

def natural_number(n):
    result = int(n)
    if result < 1:
        raise reqparse.ArgumentTypeError('Must be a number greater than or equal to 1')
    return result


def as_dicts(data):
    """
    Because HTSQL results render as though they were lists (field info lost)
    without intervention.
    """
    if isinstance(data, htsql.core.domain.Record):
        return dict(zip(data.__fields__, [as_dicts(d) for d in data]))
    elif isinstance(data, DateTimeRange):
        return {'begin': data.upper, 'end': data.lower}
    elif isinstance(data, htsql.core.domain.Product) or \
         isinstance(data, list):
        return [as_dicts(d) for d in data]
    else:
        return data

def cleantext(text):
    if type(text) is str:
        text = re.sub(' +',' ', text)
        text = re.sub('\\r|\\n','', text)
        text = text.strip()
        return text
    else:
        return text

# this is shared by search and single resource
def find_fields(self, args):
    if args['fields'] == None and self.table_name_stem == 'cand':
        return []
    elif args['fields'] == None and self.table_name_stem == 'cmte':
        # I always need expire date to sort the information, don't want to show it when it is not asked for in a custom query.
        return ['expire_date']
    elif ',' in args['fields']:
        return args['fields'].split(',')
    else:
        return [args['fields']]


def assign_formatting(self, data_dict, page_data, year):
    args = self.parser.parse_args()
    fields = find_fields(self, args)

    if self.table_name_stem == 'cand':
        return format_candids(self, data_dict, page_data, fields, year)
    elif self.table_name_stem == 'cmte':
        return format_committees(self, data_dict, page_data, fields, year)
    else:
        return data_dict


# Candidate formatting
def format_candids(self, data, page_data, fields, default_year):
    #return data
    results = []

    for cand in data:
        #aggregating data for each election across the tables
        elections = {}
        cand_data = {}

        for api_name, fec_name in self.dimcand_mapping:
            if cand['dimcand'].has_key(fec_name):
                cand_data[api_name] = cand['dimcand'][fec_name]

        # Committee information
        if cand.has_key('affiliated_committees'):
            for cmte in cand['affiliated_committees']:
                year = str(cmte['cand_election_yr'])
                if len(cmte) > 0 and not elections.has_key(year):
                    elections[year] = {}

                committee = {}
                # not looking at the fields used for name matching
                for api_name, fec_name in self.cand_committee_format_mapping:
                    if cmte.has_key(fec_name):
                        committee[api_name] = cmte[fec_name]

                if cmte['cmte_dsgn']:
                    committee['designation_full'] = designation_decoder[cmte['cmte_dsgn']]
                if cmte['cmte_tp']:
                    committee['type_full'] = cmte_decoder[cmte['cmte_tp']]

                if cmte['cmte_dsgn'] == 'P':
                    elections[year]['primary_committee'] = committee
                elif not elections[year].has_key('affiliated_committees'):
                    elections[year]['affiliated_committees']  = [committee]
                else:
                    elections[year]['affiliated_committees'].append(committee)


        for office in cand['dimcandoffice']:
            year = str(office['cand_election_yr'])
            if len(office) > 0 and not elections.has_key(year):
                elections[year] = {}

            # Office information
            for api_name, fec_name in self.office_mapping:
                if office['dimoffice'].has_key(fec_name):
                    elections[year][api_name] = office['dimoffice'][fec_name]
            # Party information
            for api_name, fec_name in self.party_mapping:
                if office['dimparty'].has_key(fec_name):
                    elections[year][api_name] = office['dimparty'][fec_name]

        # status information
        for status in cand['dimcandstatusici']:
            if status.has_key('election_yr') and not elections.has_key(year):
                year = str(status['election_yr'])
                elections[year] = {}

            for api_name, fec_name in self.status_mapping:
                if status.has_key(fec_name):
                    elections[year][api_name] = status[fec_name]

            status_decoder = {'C': 'candidate', 'F': 'future_candidate', 'N': 'not_yet_candidate', 'P': 'prior_candidate'}

            if status.has_key('cand_status') and status['cand_status'] is not None:
                elections[year]['candidate_status_full'] = status_decoder[status['cand_status']]

            ici_decoder = {'C': 'challenger', 'I': 'incumbent', 'O': 'open_seat'}
            if status.has_key('ici_code') and status['ici_code'] is not None:
                elections[year]['incumbent_challenge_full'] = ici_decoder[status['ici_code']]

        # Using most recent name as full name
        if cand['dimcandproperties'][0].has_key('cand_nm'):
            name = cand['dimcandproperties'][0]['cand_nm']
            cand_data['name'] = {}
            cand_data['name']['full_name'] = cand['dimcandproperties'][-1]['cand_nm']

            # let's do this for now, we could look for improvements in the future
            if len(name.split(',')) == 2 and len(name.split(',')[0].strip()) > 0 and len(name.split(',')[1].strip()) > 0:
                cand_data['name']['name_1'] = name.split(',')[1].strip()
                cand_data['name']['name_2'] = name.split(',')[0].strip()

        # properties has names and addresses
        addresses = []
        other_names = []
        for prop in cand['dimcandproperties']:
            if prop.has_key('election_yr') and not elections.has_key(year):
                elections[year] = {}

            # Addresses
            one_address = {}
            for api_name, fec_name in self.property_fields_mapping:
                if prop.has_key(fec_name) and fec_name != "cand_nm" and fec_name != "expire_date":
                    one_address[api_name] = cleantext(prop[fec_name])
                if prop.has_key('expire_date') and prop['expire_date'] is not None:
                    one_address['expire_date'] = datetime.strftime(prop['expire_date'], '%Y-%m-%d')
            if one_address not in addresses and one_address != {}:
                addresses.append(one_address)

            # Names (picking up name variations)
            if prop.has_key('cand_nm') and other_names in fields and (cand_data['name']['full_name'] != prop['cand_nm']) and (prop['cand_nm'] not in other_names):
                name = cleantext(prop['cand_nm'])
                other_names.append(name)

        if len(addresses) > 0:
            cand_data['mailing_addresses'] = addresses
        if len(other_names) > 0:
            cand_data['name']['other_names'] = other_names

        # Order eleciton data so the most recent is first and just show years requested
        years = []
        for year in elections:
            if default_year is not None and str(default_year) == year:
                    years.append(year)

        years.sort(reverse=True)
        for year in years:
            if len(elections[year]) > 0:
                if not cand_data.has_key('elections'):
                    cand_data['elections'] = []

                cand_data['elections'].append(elections[year])

        results.append(cand_data)

    return {'api_version':"0.2", 'pagination':page_data, 'results': results}


# still need to implement year
def format_committees(self, data, page, fields, year):
    print data
    results = []
    for cmte in data:
        committee = {}
        # Most recent information
        properties = {}
        # Keeps track of previous info
        record = {}

        for api_name, fec_name in self.dimcmte_mapping:
                if cmte['dimcmte'].has_key(fec_name):
                    committee[api_name] = cmte['dimcmte'][fec_name]

        for item in cmte['dimcmteproperties']:
            # shortcut for formatting
            if item['expire_date'] is not None:
                if item['expire_date'] > datetime.now():
                    expired = False
                    if 'expire_date' in fields or '*' in fields or fields == []:
                        properties['expire_date'] = item['expire_date']
                else:
                    expired = True
            else:
                expired = True
                if 'expire_date' in fields or '*' in fields:
                    record['expire_date'] = item['expire_date']

            if properties.has_key('load_date') and properties['load_date'] is not None:
                if expired == False:
                    properties['load_date'] = item['load_date']
                else:
                    record['load_date'] = item['load_date']

            # address
            address = {}
            for api_name, fec_name in self.committee_address_field_mappings:
                if item.has_key(fec_name) and item[fec_name] is not None:
                    address[api_name] = item[fec_name]

            if address.has_key('state_full'):
                address['state_full'] = item['cmte_st_desc'].strip()

            if len(address) > 0:
                if expired == False:
                    properties['address'] = address
                else:
                    if not record.has_key('address'):
                        record['address'] = []
                    record['address'].append(address)

            # properties table called description in api
            description = {}
            for api_name, fec_name in self.properties_field_mapping:
                if item.has_key(fec_name) and item[fec_name] is not None:
                    description[api_name] = item[fec_name]

            if len(description) > 0:
                if expired == False and len(description) > 0:
                    properties['description'] = description
                else:
                    if not record.has_key('description'):
                        record['description'] = []
                    record['description'].append(description)

            # treasurer
            treasurer = {}
            for api_name, fec_name in self.treasurer_field_mapping:
                if item.has_key(fec_name) and item[fec_name] is not None:
                    treasurer[api_name] = item[fec_name]

            if len(treasurer) > 0:
                if expired == False:
                    properties['treasurer'] = treasurer
                else:
                    if not record.has_key('treasurer'):
                        record['treasurer'] = []
                    record['treasurer'].append(treasurer)

            # custodian
            custodian = {}
            for api_name, fec_name in self.custodian_field_mapping:
                if item.has_key(fec_name) and item[fec_name] is not None:
                    custodian[api_name] = item[fec_name]

            if len(custodian) > 0:
                if expired == False:
                    properties['custodian'] = custodian
                else:
                    if not record.has_key('custodian'):
                        record['custodian'] = []
                    record['custodian'].append(custodian)

            # candidates associated with committees
            candidate_list = []
            candidate_arcive_list = []
            for cand in cmte['dimlinkages']:
                candidate ={}
                for api_name, fec_name in self.linkages_field_mapping:
                    if cand.has_key(fec_name) and fec_name != 'expire_date':
                        candidate[api_name] = cand[fec_name]

                if 'expire_date' in fields or '*' in fields or fields == []:
                    candidate['expire_date'] = cand['expire_date']
                if candidate.has_key('type'):
                    candidate['type_full'] = cmte_decoder[candidate['type']]
                if candidate.has_key('designation'):
                    candidate['designation_full'] = designation_decoder[candidate['designation']]

                # add to properties or archive based on expire date
                if len(candidate) > 0:
                    if cand.has_key('expire_date') and cand['expire_date'] == None:
                        candidate_list.append(candidate)
                    else:
                        candidate_arcive_list.append(candidate)

            if len(candidate_list) > 0:
                properties['candidates'] = candidate_list

            if len(candidate_arcive_list) > 0:
                record['candidates'] = candidate_arcive_list

            # designation/discription
            designations = []
            archive_designations = []
            for designation in cmte['dimcmtetpdsgn']:
                status = {}
                for api_name, fec_name in self.designation_mapping:
                    if designation.has_key(fec_name):
                        status[api_name] = designation[fec_name]

                    if designation.has_key('cmte_dsgn') and  designation_decoder.has_key(designation['cmte_dsgn']):
                        status['designation_full'] = designation_decoder[designation['cmte_dsgn']]
                    if designation.has_key('cmte_tp') and cmte_decoder.has_key(designation['cmte_tp']):
                        status['type_full'] = cmte_decoder[designation['cmte_tp']]

                if designation.has_key('expire_date') and designation['expire_date'] == None:
                    designations.append(status)
                else:
                    archive_designations.append(status)

            # Setting up some messaging to see if there is a problem I will get rid of this if it looks OK
            if len(designations) > 1:
                properties['status'] = designations[0]
                print "THIS SHOULD'NT HAPPEN- THERE SHOULD BE ONE UNEXPIRED DOC"

            if len(designations) > 0:
                properties['status'] = designations[0]

            if len(archive_designations) > 0:
                record['status'] = designations#sorted(archive_designations, key=lambda k: k['_date'], reverse=True)

        if ('archive' in fields or '*' in fields) and len(record) > 0:
            if not committee.has_key('archive'):
                committee['archive'] = []
            committee['archive'].append(record)

        if len(properties) > 0:
            committee['properties'] = properties

        results.append(committee)

    return {'api_version':"0.2", 'pagination':page, 'results': results}
    #return data


class SingleResource(restful.Resource):
    # add fields and year to this
    def get(self, id):
        show_fields = copy.copy(self.default_fields)
        overall_start_time = time.time()
        args = self.parser.parse_args()
        fields = find_fields(self, args)

        if args.has_key('fields') and args['fields'] is not None:
            if ',' in str(args['fields']):
                fields = args['fields'].split(',')
            else:
                fields = [str(args['fields'])]

            for maps, field_name in self.maps_fields:
                show_fields[field_name] = ''
                #looking at each field the user requested
                for field in fields:
                    # for each mapping, see if there is a field match. If so, add it to the field list
                    for m in maps:
                        if m[0] == field:
                            show_fields[field_name] = show_fields[field_name] + m[1] + ','
        else: fields = []

        # not working
        if args.has_key('year'):
            year = int(args['year'])
        else:
            year = default_year()

        qry = "/%s?%s_id='%s'" % (self.query_text(show_fields), self.table_name_stem, id)
        print(qry)

        speedlogger.info('--------------------------------------------------')
        speedlogger.info('\nHTSQL query: \n%s' % qry)
        start_time = time.time()

        data = htsql_conn.produce(qry)

        speedlogger.info('HTSQL query time: %f' % (time.time() - start_time))

        data_dict = as_dicts(data)
        page_data = {'per_page': 1, 'page':1, 'pages':1, 'count': 1}

        speedlogger.info('\noverall time: %f' % (time.time() - overall_start_time))

        if self.table_name_stem == 'cand':
            return format_candids(self, data_dict, page_data, fields, year)
        elif self.table_name_stem == 'cmte':
            return format_committees(self, data_dict, page_data, fields, year)
        else:
            return data_dict

_child_table_pattern = re.compile("^exists\((\w+)\?(.*?)\)\s*$")
def combine_filters(elements):
    """
    For HTSQL filter elements like "exists(tablename?...)",
    collapse multiple filters on a single table into
    one filter with all conditions combined into an AND.
    """
    conditions = defaultdict(list)
    results = []
    for element in elements:
        match = _child_table_pattern.search(element)
        if match:
            (tablename, condition) = match.groups()
            conditions[tablename].append(condition)
        else:
            results.append(element)
    for (tablename, table_conditions) in conditions.items():
        condition = "&".join("(%s)" % c for c in table_conditions)
        results.append("exists(%s?%s)" % (tablename, condition))
    return results


class Searchable(restful.Resource):
    fulltext_qry = """SELECT %s_sk
                      FROM   dim%s_fulltext
                      WHERE  fulltxt @@ to_tsquery(:findme)
                      ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc"""

    def get(self):
        overall_start_time = time.time()
        speedlogger.info('--------------------------------------------------')
        args = self.parser.parse_args()
        elements = []
        page_num = 1
        show_fields = copy.copy(self.default_fields)

        for arg in args:
            if args[arg]:
                if arg == 'q':
                    qry = self.fulltext_qry % (self.table_name_stem, self.table_name_stem)
                    qry = sa.sql.text(qry)
                    speedlogger.info('\nfulltext query: \n%s' % qry)
                    start_time = time.time()
                    findme = ' & '.join(args['q'].split())
                    fts_result = conn.execute(qry, findme = findme).fetchall()
                    speedlogger.info('fulltext query time: %f' % (time.time() - start_time))
                    if not fts_result:
                        return []
                    elements.append("%s_sk={%s}" %
                                    (self.table_name_stem,
                                     ",".join(str(id[0])
                                    for id in fts_result)))
                elif arg == 'page':
                    page_num = args[arg]
                elif arg == 'per_page':
                    per_page = args[arg]
                elif arg == 'fields':
                    # queries need year to link the data
                    if ',' in str(args[arg]):
                        field_list = args[arg].split(',')
                    else:
                        field_list = [str(args[arg])]

                    #going through the different kinds of mappings and fields
                    for maps, field_name in self.maps_fields:
                        show_fields[field_name] = ''
                        #looking at each field the user requested
                        for field in field_list:
                            # for each mapping, see if there is a field match. If so, add it to the field list
                            for m in maps:
                                if m[0] == field:
                                    show_fields[field_name] = show_fields[field_name] + m[1] + ','
                else:
                    element = self.field_name_map[arg].substitute(arg=args[arg])
                    elements.append(element)

        qry = self.query_text(show_fields)

        if elements:
            elements = combine_filters(elements)
            qry += "?" + "&".join(elements)
            count_qry = "/count(%s?%s)" % (self.viewable_table_name,
                                           "&".join(elements))
        else:
            count_qry = "/count(%s)" % self.viewable_table_name

        offset = per_page * (page_num-1)
        qry = "/(%s).limit(%d,%d)" % (qry, per_page, offset)

        print("\n%s\n" % (qry))

        speedlogger.info('\n\nHTSQL query: \n%s' % qry)
        start_time = time.time()
        data = htsql_conn.produce(qry)
        speedlogger.info('HTSQL query time: %f' % (time.time() - start_time))

        count = htsql_conn.produce(count_qry)

        data_dict = as_dicts(data)

        # page info
        data_count = int(count[0])
        pages = data_count/per_page
        if data_count % per_page != 0:
          pages += 1
        if data_count < per_page:
          per_page = data_count

        page_data = {'per_page': per_page, 'page':page_num, 'pages':pages, 'count': data_count}

        # make this better later
        if not args.has_key("year"):
            args['year'] = None

        speedlogger.info('\noverall time: %f' % (time.time() - overall_start_time))
        return assign_formatting(self, data_dict, page_data, args['year'])


class Candidate(object):
    # default fields for search
    default_fields = {
        'dimcand_fields': 'cand_id',
        'cand_committee_link_fields': 'cmte_id,cmte_dsgn,cmte_tp,cand_election_yr',
        'office_fields': 'office_district,office_state,office_tp',
        'party_fields': 'party_affiliation_desc,party_affiliation',
        'status_fields': 'election_yr,cand_status,ici_code',
        'properties_fields': 'cand_nm',
        'cmte_fields': "'P'",
    }

    # Query
    table_name_stem = 'cand'
    viewable_table_name = "(dimcand?exists(dimcandproperties)&exists(dimcandoffice))"

    def query_text(self, show_fields):
        if show_fields['cmte_fields'] != '':
            com_query = "/dimlinkages?cmte_dsgn={%s}  :as affiliated_committees," % (show_fields['cmte_fields'])
            show_fields['status_fields'] = 'election_yr,' + show_fields['status_fields']
        else:
            com_query = ''

        return """
            %s{{%s},/dimcandproperties{%s},/dimcandoffice{cand_election_yr-,dimoffice{%s},dimparty{%s}},
                              %s
                              /dimcandstatusici{%s}}
        """ % (
                self.viewable_table_name,
                show_fields['dimcand_fields'],
                show_fields['properties_fields'],
                show_fields['office_fields'],
                show_fields['party_fields'],
                com_query,
                #show_fields['cand_committee_link_fields'],
                show_fields['status_fields'],
        )

    # Field mappings (API_output, FEC_input)
    # basic candidate information
    dimcand_mapping = (
        ('candidate_id', 'cand_id'),
        ('form_type', 'form_tp'),
        ## we don't have this data yet
        ('expire_date','expire_date'),
        ('load_date','load_date'),
        ('*', '*'),
    )

    #affiliated committees
    cand_committee_format_mapping = (
        ('committee_id', 'cmte_id'),
        ('designation', 'cmte_dsgn'),
        ('type', 'cmte_tp'),
        ('election_year', 'cand_election_yr'),
    )
    # I want to take additional formatting from the user but don't want to use it for matching during formatting
    cand_committee_link_mapping = (
        # fields if primary committee is requested
        ('primary_committee', 'cmte_id'),
        ('primary_committee', 'cmte_dsgn'),
        ('primary_committee', 'cmte_tp'),
        ('primary_committee', 'cand_election_yr'),
        # fields if associated committee is requested
        ('associated_committee', 'cmte_id'),
        ('associated_committee', 'cmte_dsgn'),
        ('associated_committee', 'cmte_tp'),
        ('associated_committee', 'cand_election_yr'),
        ('year', 'cand_election_yr'),
        ('*', '*'),
        # regular mapping
    ) + cand_committee_format_mapping
    # dimoffice
    office_mapping = (
        ('office', 'office_tp'),
        ('district', 'office_district'),
        ('state', 'office_state'),
        ('office_sought_full', 'office_tp_desc'),
        ('office_sought', 'office_tp'),
        ('*', '*'),
    )
    #dimparty
    party_mapping = (
        ('party', 'party_affiliation'),
        ('party_affiliation', 'party_affiliation_desc'),
        ('*', '*'),
    )
    # dimcandstatus
    status_mapping = (
        ('election_year', 'election_yr'),
        ('candidate_inactive', 'cand_inactive_flg'),
        ('candidate_status', 'cand_status'),
        ('incumbent_challenge', 'ici_code'),
        ('*', '*'),
    )
    # dimcandproperties
    property_fields_mapping = (
        ('name', 'cand_nm'),
        ('street_1', 'cand_st1'),
        ('street_2','cand_st2'),
        ('city', 'cand_city'),
        ('state', 'cand_st'),
        ('zip', 'cand_zip'),
        ('expire_date', 'expire_date'),
    )
    # I want to take additional formatting from the user but don't want to use it for matching during formatting
    properties_mapping = (
        ('mailing_addresses', 'cand_st1,cand_st2,cand_city,cand_st,\
            cand_zip,expire_date'),
        ('*', '*'),

    ) + property_fields_mapping
    # to filter primary from affiliated committees
    cmte_mapping = (
        ('primary_committee', "'P'"),
        ('affiliated_committees', "'U'"),
        ('*', "'P', 'U'")
    )

    # connects mappings to field names
    maps_fields = (
        (dimcand_mapping, 'dimcand_fields'),
        (cand_committee_link_mapping, 'cand_committee_link_fields'),
        (office_mapping, 'office_fields'),
        (party_mapping, 'party_fields'),
        (status_mapping,'status_fields'),
        (properties_mapping, 'properties_fields'),
        (cmte_mapping, 'cmte_fields'),
    )


class CandidateResource(SingleResource, Candidate):

    parser = reqparse.RequestParser()
    parser.add_argument('fields', type=str, help='Choose the fields that are displayed')


class CandidateSearch(Searchable, Candidate):

    parser = reqparse.RequestParser()
    parser.add_argument(
        'q',
        type=str,
        help='Text to search all fields for'
    )
    parser.add_argument(
        'candidate_id',
        type=str,
        help="Candidate's FEC ID"
    )
    parser.add_argument(
        'fec_id',
        type=str,
        help="Candidate's FEC ID"
    )
    parser.add_argument(
        'page',
        type=natural_number,
        default=1,
        help='For paginating through results, starting at page 1'
    )
    parser.add_argument(
        'per_page',
        type=natural_number,
        default=20,
        help='The number of results returned per page. Defaults to 20.'
    )
    parser.add_argument(
        'name',
        type=str,
        help="Candidate's name (full or partial)"
    )
    parser.add_argument(
        'office',
        type=str,
        help='Governmental office candidate runs for'
    )
    parser.add_argument(
        'state',
        type=str,
        help='U. S. State candidate is registered in'
    )
    parser.add_argument(
        'party',
        type=str,
        help="Party under which a candidate ran for office"
    )
    parser.add_argument(
        'year',
        type=int,
        default=2012,
        help="Year in which a candidate runs for office"
    )
    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
    )
    parser.add_argument(
        'district',
        type=int,
        help='Two digit district number'
    )


    field_name_map = {"candidate_id": string.Template("cand_id='$arg'"),
                    "fec_id": string.Template("cand_id='$arg'"),
                    "office": string.Template(
                        "exists(dimcandoffice?dimoffice.office_tp~'$arg')"
                    ),
                    "district":string.Template(
                        "exists(dimcandoffice?dimoffice.office_district~'$arg')"
                    ),
                    "state": string.Template(
                        "exists(dimcandoffice?dimoffice.office_state~'$arg')"
                    ),
                    "name": string.Template(
                        "exists(dimcandproperties?cand_nm~'$arg')"
                    ),
                    "year": string.Template(
                        "exists(dimcandoffice?cand_election_yr='$arg')"
                    ),
                    "party": string.Template(
                        "exists(dimcandoffice?dimparty.party_affiliation~'$arg')"
                    )
    }


class Committee(object):

    default_fields = {
        'dimcmte_fields': 'cmte_id,form_tp,load_date,expire_date',
        'properties_fields': '*',
        'linkages_fields': 'cand_id,cmte_tp,cmte_dsgn,cand_election_yr,expire_date,link_date',
        'designation_fields': '*',
    }

    table_name_stem = 'cmte'
    viewable_table_name = "(dimcmte?exists(dimcmteproperties))"
    def query_text(self, show_fields):
        # We always need expire date to sort the information
        return '(%s{{%s},/dimcmteproperties{expire_date,%s}, /dimlinkages{expire_date,%s}, /dimcmtetpdsgn{%s}})' % (
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
        ('election_year', 'cand_election_yr'),
        ('expire_date', 'expire_date'),
        ('link_date', 'link_date'),
    )

    linkages_mapping = (
        ('committees', 'cand_id,cmte_tp,cmte_dsgn,cand_election_yr,\
            expire_date,link_date'),
        ('*', '*'),

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
        ('name', 'cmte_name'),
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
        ('party', 'party_cmte_type'),
        ('party_full', 'party_cmte_type_desc'),
        ('qualifying_date', 'qual_dt'),
    )

    properties_mapping = (('*', '*'),) + properties_field_mapping + committee_address_field_mappings + committee_address + treasurer_field_mapping + custodian_field_mapping + custodian

    # connects mappings to field names
    maps_fields = (
        (dimcmte_mapping, 'dimcmte_fields'),
        (properties_mapping, 'properties_fields'),
        (linkages_mapping, 'linkages_fields'),
        (designation_mapping, 'designation_fields'),
    )


class CommitteeResource(SingleResource, Committee):

    parser = reqparse.RequestParser()
    parser.add_argument('fields', type=str, help='Choose the fields that are displayed')


class CommitteeSearch(Searchable, Committee):

    field_name_map = {"committee_id": string.Template("cmte_id='$arg'"),
                        "fec_id": string.Template("cmte_id='$arg'"),
                        # I don't think this is going to work because the data is not reliable in the fields and we should query to find the candidate names.
                        "candidate_id":string.Template(
                            "exists(dimlinkages?cand_id~'$arg')"
                        ),
                        "state": string.Template(
                            "exists(dimcmteproperties?cmte_st~'$arg')"
                        ),
                        "name": string.Template(
                            "exists(dimcmteproperties?cmte_nm~'$arg')"
                        ),
                        "type": string.Template(
                            "exists(dimcmtetpdsgn?cmte_tp~'$arg')"
                        ),
                        "designation": string.Template(
                            "exists(dimcmtetpdsgn?cmte_dsgn~'$arg')"
                        ),
                        "organization_type": string.Template(
                            "exists(dimcmteproperties?org_tp~'$arg')"
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

if __name__ == '__main__':
    debug = not os.getenv('PRODUCTION')
    app.run(debug=debug)
