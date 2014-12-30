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
import doctest
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
speedlogger.setLevel(logging.CRITICAL)
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

party_decoder = {'ACE': 'Ace Party', 'AKI': 'Alaskan Independence Party', 'AIC': 'American Independent Conservative', 'AIP': 'American Independent Party', 'AMP': 'American Party', 'APF': "American People's Freedom Party", 'AE': 'Americans Elect', 'CIT': "Citizens' Party", 'CMD': 'Commandments Party', 'CMP': 'Commonwealth Party of the U.S.', 'COM': 'Communist Party', 'CNC': 'Concerned Citizens Party Of Connecticut', 'CRV': 'Conservative Party', 'CON': 'Constitution Party', 'CST': 'Constitutional', 'COU': 'Country', 'DCG': 'D.C. Statehood Green Party', 'DNL': 'Democratic -Nonpartisan League', 'DEM': 'Democratic Party', 'D/C': 'Democratic/Conservative', 'DFL': 'Democratic-Farmer-Labor', 'DGR': 'Desert Green Party', 'FED': 'Federalist', 'FLP': 'Freedom Labor Party', 'FRE': 'Freedom Party', 'GWP': 'George Wallace Party', 'GRT': 'Grassroots', 'GRE': 'Green Party', 'GR': 'Green-Rainbow', 'HRP': 'Human Rights Party', 'IDP': 'Independence Party', 'IND': 'Independent', 'IAP': 'Independent American Party', 'ICD': 'Independent Conservative Democratic', 'IGR': 'Independent Green', 'IP': 'Independent Party', 'IDE': 'Independent Party of Delaware', 'IGD': 'Industrial Government Party', 'JCN': 'Jewish/Christian National', 'JUS': 'Justice Party', 'LRU': 'La Raza Unida', 'LBR': 'Labor Party', 'LFT': 'Less Federal Taxes', 'LBL': 'Liberal Party', 'LIB': 'Libertarian Party', 'LBU': 'Liberty Union Party', 'MTP': 'Mountain Party', 'NDP': 'National Democratic Party', 'NLP': 'Natural Law Party', 'NA': 'New Alliance', 'NJC': 'New Jersey Conservative Party', 'NPP': 'New Progressive Party', 'NPA': 'No Party Affiliation', 'NOP': 'No Party Preference', 'NNE': 'None', 'N': 'Nonpartisan', 'NON': 'Non-Party', 'OE': 'One Earth Party', 'OTH': 'Other', 'PG': 'Pacific Green', 'PSL': 'Party for Socialism and Liberation', 'PAF': 'Peace And Freedom', 'PFP': 'Peace And Freedom Party', 'PFD': 'Peace Freedom Party', 'POP': 'People Over Politics', 'PPY': "People's Party", 'PCH': 'Personal Choice Party', 'PPD': 'Popular Democratic Party', 'PRO': 'Progressive Party', 'NAP': 'Prohibition Party', 'PRI': 'Puerto Rican Independence Party', 'RUP': 'Raza Unida Party', 'REF': 'Reform Party', 'REP': 'Republican Party', 'RES': 'Resource Party', 'RTL': 'Right To Life', 'SEP': 'Socialist Equality Party', 'SLP': 'Socialist Labor Party', 'SUS': 'Socialist Party', 'SOC': 'Socialist Party U.S.A.', 'SWP': 'Socialist Workers Party', 'TX': 'Taxpayers', 'TWR': 'Taxpayers Without Representation', 'TEA': 'Tea Party', 'THD': 'Theo-Democratic', 'LAB': 'U.S. Labor Party', 'USP': "U.S. People's Party", 'UST': 'U.S. Taxpayers Party', 'UN': 'Unaffiliated', 'UC': 'United Citizen', 'UNI': 'United Party', 'UNK': 'Unknown', 'VET': 'Veterans Party', 'WTP': 'We the People', 'W': 'Write-In'}

# defaulting to the last 4 years so there is always the last presidential, we could make this 6 to ensure coverage of sitting senators.
def default_year():
    year = datetime.now().year
    years = [str(y) for y in range(year, year-4, -1)]
    return ','.join(years)

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
def find_fields(args):
    if args['fields'] == None:
            return []
    elif ',' in args['fields']:
        return args['fields'].split(',')
    else:
        return [args['fields']]


def assign_formatting(self, data_dict, page_data, year):
    args = self.parser.parse_args()
    fields = find_fields(args)

    if str(self.endpoint) == 'candidateresource' or str(self.endpoint) == 'candidatesearch':
        return format_candids(self, data_dict, page_data, fields, year)
    elif str(self.endpoint) == 'committeeresource' or str(self.endpoint) == 'committeesearch':
        return format_committees(self, data_dict, page_data, fields, year)
    elif str(self.endpoint) == 'totalresource' or str(self.endpoint) == 'totalsearch':
        return format_totals(self, data_dict, page_data, fields, year)
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

            if fields == [] or 'election_year' in fields or '*' in fields:
                elections[year]['election_year'] = int(year)

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
            if status != {}:
                year = str(status['election_yr'])
                if not elections.has_key(year):
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
        default_years = default_year.split(',')
        for year in elections:
            if year in default_years or default_year == '*':
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
                if expired == False:
                    committee['load_date'] = item['load_date']
                else:
                    record['load_date'] = item['load_date']

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

            if item.has_key('cand_pty_affiliation') and item['cand_pty_affiliation'] in party_decoder:
                description['party_full'] = party_decoder[item['cand_pty_affiliation']]

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

                if designation.has_key('cmte_dsgn') and  designation_decoder.has_key(designation['cmte_dsgn']):
                    status['designation_full'] = designation_decoder[designation['cmte_dsgn']]

                if designation.has_key('cmte_tp') and cmte_decoder.has_key(designation['cmte_tp']):
                    status['type_full'] = cmte_decoder[designation['cmte_tp']]

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
                    candidate['type_full'] = cmte_decoder[candidate['type']]
                if candidate.has_key('designation'):
                    candidate['designation_full'] = designation_decoder[candidate['designation']]
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


def format_totals(self, data, page_data, fields, default_year):
    results = []
    #return data

    for committee in data:
        com = {}
        for api_name, fec_name in self.dim_mapping:
              com[api_name]  = committee[fec_name]
        reports = []

        bucket_map = (
            ('factpresidential_f3p', self.presidential_mapping, 'presidential'),
            ('factpacsandparties_f3x', self.pac_party_mapping, 'pac_party'),
            ('facthousesenate_f3', self.house_senate_mapping, 'house_senate'),
        )

        for bucket, mapping, kind in bucket_map:
            totals = {}
            for record in committee[bucket]:
                if record != []:
                    details = {}
                    details['type'] = kind

                    cycle = int(record['two_yr_period_sk'])
                    if not totals.has_key(cycle):
                        totals[cycle] = {'election_cycle': cycle}

                    for api_name, fec_name in mapping:
                        if record.has_key(fec_name):
                            details[api_name] = record[fec_name]

                        # this is the naming convention for the totals in each period that can be summed by election cycle. I am still going to double check on this to make sure reports don't overlap.
                        if api_name.startswith('total_') and api_name.endswith('_period') and record[fec_name] is not None:
                            new_name = api_name[6:-7]

                            if not totals[cycle].has_key(new_name):
                                totals[cycle][new_name] = float(record[fec_name])
                            else:
                                totals[cycle][new_name] += float(record[fec_name])

                    if record.has_key('dimreporttype'):
                        for api_name, fec_name in self.report_mapping:
                            if record['dimreporttype'][0].has_key(fec_name):
                                details[api_name] = record['dimreporttype'][0][fec_name]

                    reports.append(details)

            if totals != {}:
                com['totals'] = totals

            if reports != []:
                com['reports'] = reports
            results.append(com)

    return {'api_version':"0.2", 'pagination':page_data, 'results': results}


class SingleResource(restful.Resource):

    def get(self, id):
        show_fields = copy.copy(self.default_fields)
        overall_start_time = time.time()
        args = self.parser.parse_args()
        fields = find_fields(args)

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

        if args.has_key('year'):
            year = args['year']
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

        return assign_formatting(self, data_dict, page_data, year)

class Searchable(restful.Resource):

    fulltext_qry = """SELECT %s_sk
                      FROM   dim%s_fulltext
                      WHERE  fulltxt @@ to_tsquery(:findme)
                      ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc"""

    def get(self):
        overall_start_time = time.time()
        speedlogger.info('--------------------------------------------------')
        args = self.parser.parse_args(strict=True)
        elements = []
        page_num = 1
        show_fields = copy.copy(self.default_fields)

        if 'year' not in args:
            args['year'] = default_year()
        year = args['year']

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
                    fields = args[arg]
                else:
                    if arg in self.field_name_map:
                        element = self.field_name_map[arg].substitute(arg=args[arg])
                        elements.append(element)

        qry = self.query_text(show_fields)

        if elements:
            qry += "?" + "&".join(elements)
            count_qry = "/count(%s?%s)" % (self.viewable_table_name,
                                           "&".join(elements))
            if year != '*':
                qry = qry.replace('dimcandoffice', '(dimcandoffice?cand_election_yr={%s})' % year)
                count_qry = count_qry.replace('dimcandoffice', '(dimcandoffice?cand_election_yr={%s})' % year)
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

        speedlogger.info('\noverall time: %f' % (time.time() - overall_start_time))

        return assign_formatting(self, data_dict, page_data, year)


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
    parser.add_argument('fields',
        type=str,
        help='Choose the fields that are displayed'
    )
    parser.add_argument(
        'year',
        type=str,
        default= default_year(),
        help="Year in which a candidate runs for office"
    )


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
        type=str,
        default= default_year(),
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
                        "top(dimcandoffice.sort(expire_date-)).office_tp~'$arg'"
                    ),
                    "district":string.Template(
                        "top(dimcandoffice.sort(expire_date-)).dimoffice.office_district={'$arg', '0$arg'}"
                    ),
                    "state": string.Template(
                        "top(dimcandoffice.sort(expire_date-)).dimoffice.office_state~'$arg'"
                    ),
                    "name": string.Template(
                        "top(dimcandproperties.sort(expire_date-)).cand_nm~'$arg'"
                    ),
                    "party": string.Template(
                        "top(dimcandoffice.sort(expire_date-)).dimparty.party_affiliation~'$arg'"
                    ),
                    "year": string.Template(
                        "exists(dimcandoffice)"
                    ),
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
        # We always need expire date and cand_id to sort the information
        return '(%s{{%s},/dimcmteproperties{expire_date,%s}, /dimlinkages{cand_id,expire_date,%s}, /dimcmtetpdsgn{expire_date,%s}})' % (
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

    properties_mapping = (('*', '*'),) + properties_field_mapping + committee_address_field_mappings + committee_address + treasurer + treasurer_field_mapping + custodian_field_mapping + custodian

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


class CommitteeSearch(Searchable, Committee):

    field_name_map = {"committee_id": string.Template("cmte_id='$arg'"),
                        "fec_id": string.Template("cmte_id='$arg'"),
                        # I don't think this is going to work because the data is not reliable in the fields and we should query to find the candidate names.
                        "candidate_id":string.Template(
                            "exists(dimlinkages?cand_id~'$arg')"
                        ),
                        "state": string.Template(
                            "top(dimcmteproperties.sort(expire_date-)).cmte_st~'$arg'"
                        ),
                        "name": string.Template(
                            "top(dimcmteproperties.sort(expire_date-)).cmte_nm~'$arg'"
                        ),
                        "type": string.Template(
                            "top(dimcmtetpdsgn.sort(expire_date-)).cmte_tp~'$arg'"
                        ),
                        "designation": string.Template(
                            "top(dimcmtetpdsgn.sort(expire_date-)).cmte_dsgn~'$arg'"
                        ),
                        "organization_type": string.Template(
                            "top(dimcmteproperties.sort(expire_date-)).org_tp~'$arg'"
                        ),
                        "party": string.Template(
                            "top(dimcmteproperties.sort(expire_date-)).cand_pty_affiliation~'$arg'"
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


class Total(object):

    table_name_stem = 'cmte'
    viewable_table_name = "dimcmte?exists(facthousesenate_f3)|exists(factpresidential_f3p)|exists(factpacsandparties_f3x)"

    ### update this
    default_fields = {
        'dimcmte_fields': '*',
        'house_senate_fields': '*',
        'presidential_fields': '*',
        'pac_party_fields': '*',
    }

    def query_text(self, show_fields):

        return '(%s){%s, /facthousesenate_f3{%s, /dimreporttype}, /factpresidential_f3p{%s, /dimreporttype}, /factpacsandparties_f3x{%s, /dimreporttype}}' % (
                self.viewable_table_name,
                show_fields['dimcmte_fields'],
                show_fields['house_senate_fields'],
                show_fields['presidential_fields'],
                show_fields['pac_party_fields'],
            )

    # need to add
        # "cvg_end_dt_sk"
        # "cvg_start_dt_sk"
        # exp_subject_limits
        # 'ttl_contb_col_ttl_per'

        # 'two_yr_period_sk'
        # 'electiontp_sk'
        # 'reporttype_sk'
        # 'transaction_sk'

    # presidential
    presidential_mapping = (
        ('beginning_image_number','begin_image_num'),
        ('candidate_contribution_period','cand_contb_per'),
        ('candidate_contribution_year','cand_contb_ytd'),
        ('cash_on_hand_beginning_period','coh_bop'),
        ('cash_on_hand_end_period','coh_cop'),
        ('debts_owed_by_committee','debts_owed_by_cmte'),
        ('debts_owed_to_committee','debts_owed_to_cmte'),
        ('end_image_number','end_image_num'),
        ('exempt_legal_accounting_disbursement_period','exempt_legal_acctg_disb_per'),
        ('exempt_legal_accounting_disbursement_year','exempt_legal_acctg_disb_ytd'),
        ('expire_date','expire_date'),
        ('federal_funds_period','fed_funds_per'),
        ('federal_funds_year','fed_funds_ytd'),
        ('fundraising_disbursements_period','fndrsg_disb_per'),
        ('fundraising_disbursements_year','fndrsg_disb_ytd'),
        ('individual_contributions_period','indv_contb_per'),
        ('individual_contributions_year','indv_contb_ytd'),
        ('items_on_hand_liquidated','items_on_hand_liquidated'),
        ('load_date','load_date'),
        ('loans_received_from_candidate_period','loans_received_from_cand_per'),
        ('loans_received_from_candidate_year','loans_received_from_cand_ytd'),
        ('net_contribution_summary_period','net_contb_sum_page_per'),
        ('net_operating_expenses_summary_period','net_op_exp_sum_page_per'),
        ('offsets_to_fundraising_expenses_period','offsets_to_fndrsg_exp_per'),
        ('offsets_to_fundraising_exp_year','offsets_to_fndrsg_exp_ytd'),
        ('offsets_to_legal_accounting_period','offsets_to_legal_acctg_per'),
        ('offsets_to_legal_accounting_year','offsets_to_legal_acctg_ytd'),
        ('offsets_to_operating_expenditures_period','offsets_to_op_exp_per'),
        ('offsets_to_operating_expenditures_year','offsets_to_op_exp_ytd'),
        ('operating_expenditures_period','op_exp_per'),
        ('operating_expenditures_year','op_exp_ytd'),
        ('other_disbursements_period','other_disb_per'),
        ('other_disbursements_year','other_disb_ytd'),
        ('other_loans_received_period','other_loans_received_per'),
        ('other_loans_received_year', 'other_loans_received_ytd'),

        ('other_political_committee_contributions_period', 'other_pol_cmte_contb_per'),
        ('other_political_committee_contributions_year', 'other_pol_cmte_contb_ytd'),
        ('other_receipts_period', 'other_receipts_per'),
        ('other_receipts_year', 'other_receipts_ytd'),
        ('political_party_committee_contributions_period', 'pol_pty_cmte_contb_per'),
        ('political_party_committee_contributions_year', 'pol_pty_cmte_contb_ytd'),
        ('refunds_individual_contributions_period', 'ref_indv_contb_per'),
        ('refunded_individual_contributions_year', 'ref_indv_contb_ytd'),
        ('refunded_other_political_committee_contributions_period', 'ref_other_pol_cmte_contb_per'),
        ('refunded_other_political_committee_contributions_year', 'ref_other_pol_cmte_contb_ytd'),
        ('refunded_political_party_committee_contributions_period', 'ref_pol_pty_cmte_contb_per'),
        ('refunded_political_party_committee_contributions_year', 'ref_pol_pty_cmte_contb_ytd'),
        ('repayments_loans_made_by_candidate_period', 'repymts_loans_made_by_cand_per'),
        ('repayments_loans_made_candidate_year', 'repymts_loans_made_cand_ytd'),
        ('repayments_other_loans_period', 'repymts_other_loans_per'),
        ('repayments_other_loans_year', 'repymts_other_loans_ytd'),
        ('report_year', 'rpt_yr'),

        ('subtotal_summary_period', 'subttl_sum_page_per'),

        ('transfer_from_affiliated_committee_period', 'tranf_from_affilated_cmte_per'),
        ('transfer_from_affiliated_committee_year', 'tranf_from_affilated_cmte_ytd'),
        ('transfer_to_other_authorized_committee_period', 'tranf_to_other_auth_cmte_per'),
        ('transfer_to_other_authorized_committee_year', 'tranf_to_other_auth_cmte_ytd'),
        ('total_contributions_period', 'ttl_contb_per'),
        ('total_contribution_refunds_period', 'ttl_contb_ref_per'),
        ('total_contribution_refunds_year', 'ttl_contb_ref_ytd'),
        ('total_contributions_year', 'ttl_contb_ytd'),
        ('total_disbursements_period', 'ttl_disb_per'),
        ('total_disbursements_summary_period', 'ttl_disb_sum_page_per'),
        ('total_disbursements_year', 'ttl_disb_ytd'),
        ('total_loan_repayments_made_period', 'ttl_loan_repymts_made_per'),
        ('total_loan_repayments_made_year', 'ttl_loan_repymts_made_ytd'),
        ('total_loans_received_period', 'ttl_loans_received_per'),
        ('total_loans_received_year', 'ttl_loans_received_ytd'),
        ('total_offsets_to_operating_expenditures_period', 'ttl_offsets_to_op_exp_per'),
        ('total_offsets_to_operating_expenditures_year', 'ttl_offsets_to_op_exp_ytd'),
        ('total_period', 'ttl_per'),
        ('total_receipts_period', 'ttl_receipts_per'),
        ('total_receipts_summary_period', 'ttl_receipts_sum_page_per'),
        ('total_receipts_year', 'ttl_receipts_ytd'),
        ('total_year', 'ttl_ytd'),
    )

    #These are used for making the election cycle totals.
    presidential_totals = (
        ('contributions', 'ttl_contb_per'),
        ('contribution_refunds', 'ttl_contb_ref_per'),
        ('disbursements', 'ttl_disb_per'),
        ('loan_repayments_made', 'ttl_loan_repymts_made_per'),
        ('loans_received', 'ttl_loans_received_per'),
        ('offsets_to_operating_expenditures', 'ttl_offsets_to_op_exp_per'),
        ('total_periods', 'ttl_per'),
        ('receipts', 'ttl_receipts_per'),
        ('receipts_summary', 'ttl_receipts_sum_page_per'),
    )

    pac_party_mapping = (
        #('total_contributions_col_total_year', 'ttl_contb_col_ttl_ytd'),
        ('election_type_sk', 'electiontp_sk'),
        ('end_image_number', 'end_image_num'),
        ('individual_contribution_refunds_year', 'indv_contb_ref_ytd'),
        ('total_contribution_refunds_period', 'ttl_contb_ref_per_i'),
        ('shared_nonfed_operating_expenditures_period', 'shared_nonfed_op_exp_per'),
        ('shared_fed_activity_nonfed_year', 'shared_fed_actvy_nonfed_ytd'),
        ('other_political_committee_contributions_year', 'other_pol_cmte_contb_ytd_i'),
        ('subtotal_summary_page_period', 'subttl_sum_page_per'),
        ('total_fed_receipts_period', 'ttl_fed_receipts_per'),
        ('net_operating_expenditures_period', 'net_op_exp_per'),
        ('shared_fed_activity_year', 'shared_fed_actvy_fed_shr_ytd'),
        ('loan_repymts_received_period', 'loan_repymts_received_per'),
        ('cash_on_hand_close_year', 'coh_coy'),
        ('offsets_to_operating_expendituresenditures_period', 'offsets_to_op_exp_per_i'),
        ('cash_on_hand_end_period', 'coh_cop'),
        ('independent_expenditures_period', 'indt_exp_per'),
        ('other_fed_operating_expenditures_period', 'other_fed_op_exp_per'),
        #('two_year_period_sk', 'two_yr_period_sk'),
        ('loan_repayments_made_period', 'loan_repymts_made_per'),
        ('total_fed_elect_activity_period', 'ttl_fed_elect_actvy_per'),
        ('total_receipts_period', 'ttl_receipts_per'),
        ('total_nonfed_transfers_period', 'ttl_nonfed_tranf_per'),
        ('political_party_committee_contributions_period', 'pol_pty_cmte_contb_per_ii'),
        ('total_nonfed_transfers_year', 'ttl_nonfed_tranf_ytd'),
        ('total_fed_disbursements_period', 'ttl_fed_disb_per'),
        ('offsets_to_operating_expendituresenditures_year', 'offsets_to_op_exp_ytd_i'),
        ('total_disbursements_period', 'ttl_disb_per'),
        ('non_allocated_fed_election_activity_year', 'non_alloc_fed_elect_actvy_ytd'),
        ('subtotal_summary_year', 'subttl_sum_ytd'),
        ('political_party_committee_contributions_period', 'pol_pty_cmte_contb_per_i'),
        ('all_loans_received_year', 'all_loans_received_ytd'),
        ('load_date', 'load_date'),
        ('total_fed_election_activity_year', 'ttl_fed_elect_actvy_ytd'),
        ('total_operating_expenditures_year', 'ttl_op_exp_ytd'),
        ('non_allocated_fed_election_activity_period', 'non_alloc_fed_elect_actvy_per'),
        ('fed_candidate_committee_contribution_refunds_year', 'fed_cand_cmte_contb_ref_ytd'),
        ('debts_owed_by_committee', 'debts_owed_by_cmte'),
        ('loan_repayments_received_year', 'loan_repymts_received_ytd'),
        ('cash_on_hand_beginning_period', 'coh_bop'),
        ('total_receipts_summary_page_year', 'ttl_receipts_sum_page_ytd'),
        ('coordinated_expenditures_by_party_committee_year', 'coord_exp_by_pty_cmte_ytd'),
        ('loan_repayments_made_year', 'loan_repymts_made_ytd'),
        ('coordinated_expenditures_by_party_committee_period', 'coord_exp_by_pty_cmte_per'),
        ('shared_fed_activity_nonfed_period', 'shared_fed_actvy_nonfed_per'),
        ('transfers_to_affilitated_committees_year', 'tranf_to_affilitated_cmte_ytd'),
        ('individual_item_contributions_year', 'indv_item_contb_ytd'),
        ('other_disbursements_period', 'other_disb_per'),
        ('fed_candidate_committee_contributions_year', 'fed_cand_cmte_contb_ytd'),
        ('other_disbursements_year', 'other_disb_ytd'),
        ('loans_made_year', 'loans_made_ytd'),
        ('total_disbursements_summary_page_year', 'ttl_disb_sum_page_ytd'),
        ('fed_candidate_committee_contributions_period', 'fed_cand_cmte_contb_per'),
        ('offsets_to_operating_expendituresenditures_period', 'offsets_to_op_exp_per_ii'),
        ('net_contributions_period', 'net_contb_per'),
        ('net_contributions_year', 'net_contb_ytd'),
        ('individual_unitemized_contributions_period', 'indv_unitem_contb_per'),
        ('total_receipts_summary_page_period', 'ttl_receipts_sum_page_per'),
        ('political_party_committee_contributions_year', 'pol_pty_cmte_contb_ytd_i'),
        ('all_loans_received_period', 'all_loans_received_per'),
        ('cash_on_hand_beginning_calendar_year', 'coh_begin_calendar_yr'),
        ('total_individual_contributions', 'ttl_indv_contb'),
        ('total_contributions_period', 'ttl_contb_per'),
        ('offsets_to_operating_expenditures_year', 'offsets_to_op_exp_ytd_ii'),
        ('transfers_from_nonfed_levin_period', 'tranf_from_nonfed_levin_per'),
        ('total_disbursements_year', 'ttl_disb_ytd'),
        ('political_party_committee_contributions_year', 'pol_pty_cmte_contb_ytd_ii'),
        ('debts_owed_to_committee', 'debts_owed_to_cmte'),
        ('shared_fed_operating_expenditures_period', 'shared_fed_op_exp_per'),
        ('transfers_from_nonfed_levin_year', 'tranf_from_nonfed_levin_ytd'),
        ('loans_made_period', 'loans_made_per'),
        ('transfers_from_affiliated_party_year', 'tranf_from_affiliated_pty_ytd'),
        ('transfers_to_affiliated_committee_period', 'tranf_to_affliliated_cmte_per'),
        ('independent_expenditures_year', 'indt_exp_ytd'),
        ('other_fed_receipts_year', 'other_fed_receipts_ytd'),
        ('total_contribution_refunds_year', 'ttl_contb_ref_ytd_i'),
        ('report_year', 'rpt_yr'),
        ('other_political_committee_contributions_period', 'other_pol_cmte_contb_per_ii'),
        ('total_contributions_year', 'ttl_contb_ytd'),
        ('other_fed_receipts_period', 'other_fed_receipts_per'),
        ('transfers_from_affiliated_party_period', 'tranf_from_affiliated_pty_per'),
        ('individual_unitemized_contributions_year', 'indv_unitem_contb_ytd'),
        ('total_fed_disbursements_year', 'ttl_fed_disb_ytd'),
        ('total_fed_operating_expenditures_year', 'ttl_fed_op_exp_ytd'),
        ('total_individual_contributions_year', 'ttl_indv_contb_ytd'),
        ('other_fed_operating_expenditures_year', 'other_fed_op_exp_ytd'),
        ('total_contribution_refunds_period', 'ttl_contb_ref_per_ii'),
        ('beginning_image_number', 'begin_image_num'),
        ('expire_date', 'expire_date'),
        ('individual_contribution_refunds_period', 'indv_contb_ref_per'),
        ('total_contribution_refunds_year', 'ttl_contb_ref_ytd_ii'),
        ('transfers_from_nonfed_account_period', 'tranf_from_nonfed_acct_per'),
        ('total_fed_operating_expenditures_period', 'ttl_fed_op_exp_per'),
        ('shared_fed_operating_expenditures_year', 'shared_fed_op_exp_ytd'),
        ('total_fed_receipts_year', 'ttl_fed_receipts_ytd'),
        ('shared_fed_activity_period', 'shared_fed_actvy_fed_shr_per'),
        ('shared_nonfed_operating_expenditures_year', 'shared_nonfed_op_exp_ytd'),
        ('fed_candidate_contribution_refunds_period', 'fed_cand_contb_ref_per'),
        ('net_operating_expenditures_year', 'net_op_exp_ytd'),
        ('total_operating_expenditures_period', 'ttl_op_exp_per'),
        ('transfers_from_nonfed_account_year', 'tranf_from_nonfed_acct_ytd'),
        ('other_political_committee_contributions_period', 'other_pol_cmte_contb_per_i'),
        ('total_disbursements_summary_page_period', 'ttl_disb_sum_page_per'),
        ('other_political_committee_contributions_year', 'other_pol_cmte_contb_ytd_ii'),
        ('total_receipts_year', 'ttl_receipts_ytd'),
        ('individual_item_contributions_period', 'indv_item_contb_per'),
        ('calendar_year', 'calendar_yr'),
    )

    #These are used for making the election cycle totals.
    pac_party_totals = (
        ('contribution_refunds', 'ttl_contb_ref_per_i'),
        ('fed_receipts', 'ttl_fed_receipts_per'),
        ('fed_election_activity', 'ttl_fed_elect_actvy_per'),
        ('receipts', 'ttl_receipts_per'),
        ('nonfed_transfers', 'ttl_nonfed_tranf_per'),
        ('fed_disbursements', 'ttl_fed_disb_per'),
        ('disbursements', 'ttl_disb_per'),
        ('receipts_summary_page', 'ttl_receipts_sum_page_per'),
        # I think this one is by period
        ('individual_contributions', 'ttl_indv_contb'),
        ('contributions', 'ttl_contb_per'),
        ('contribution_refunds_period', 'ttl_contb_ref_per_ii'),
        ('fed_operating_expenditures', 'ttl_fed_op_exp_per'),
        ('operating_expenditures', 'ttl_op_exp_per'),
        ('disbursements_summary_page_period', 'ttl_disb_sum_page_per'),
    )

    house_senate_mapping = (
        #('total_contributions_col_total_year', 'ttl_contb_col_ttl_ytd'),
        #('cvg_end_dt_sk', 'cvg_end_dt_sk'),
        #('aggregate_amount_pers_contributions_general', 'agr_amt_pers_contrib_gen'),
        ('refunds_individual_contributions_period', 'ref_indv_contb_per'),
        ('refunds_other_political_committee_contributions_year', 'ref_other_pol_cmte_contb_ytd'),
        ('electiontp_sk', 'electiontp_sk'),
        ('end_image_num', 'end_image_num'),
        ('total_offsets_to_operating_expenditures_period', 'ttl_offsets_to_op_exp_per'),
        ('total_loan_repayments_year', 'ttl_loan_repymts_ytd'),
        ('transfers_from_other_authorized_committee_period', 'tranf_from_other_auth_cmte_per'),
        ('refunds_political_party_committee_contributions_period', 'ref_pol_pty_cmte_contb_per'),
        ('candidate_contribution_period', 'cand_contb_per'),
        ('total_contributions_column_total_period', 'ttl_contb_column_ttl_per'),
        ('transfers_to_other_authorized_committee_period', 'tranf_to_other_auth_cmte_per'),
        ('net_operating_expenditures_period', 'net_op_exp_per'),
        ('gross_receipt_min_pers_contribution_general', 'grs_rcpt_min_pers_contrib_gen'),
        ('gross_receipt_authorized_committee_general', 'grs_rcpt_auth_cmte_gen'),
        ('transfers_to_other_authorized_committee_year', 'tranf_to_other_auth_cmte_ytd'),
        ('operating_expenditures_period', 'op_exp_per'),
        #('two_year_periodiod_sk', 'two_yr_period_sk'),
        ('gross_receipt_min_periods_contrib_primary', 'grs_rcpt_min_pers_contrib_prim'),
        ('refunds_other_political_committee_contributions_period', 'ref_other_pol_cmte_contb_per'),
        ('offsets_to_operating_expenditures_year', 'offsets_to_op_exp_ytd'),
        ('total_individual_item_contributions_year', 'ttl_indv_item_contb_ytd'),
        ('total_loan_repayments_period', 'ttl_loan_repymts_per'),
        ('load_date', 'load_date'),
        ('loan_repayments_candidate_loans_period', 'loan_repymts_cand_loans_per'),
        ('debts_owed_by_committee', 'debts_owed_by_cmte'),
        ('total_disbursements_period', 'ttl_disb_per_ii'),
        ('candidate_contribution_year', 'cand_contb_ytd'),
        ('transfers_from_other_authorized_committee_year', 'tranf_from_other_auth_cmte_ytd'),
        ('cash_on_hand_beginning_period', 'coh_bop'),
        ('offsets_to_operating_expenditures_period', 'offsets_to_op_exp_per'),
        ('all_other_loans_year', 'all_other_loans_ytd'),
        ('cvg_start_dt_sk', 'cvg_start_dt_sk'),
        ('all_other_loans_period', 'all_other_loans_per'),
        ('other_disbursements_period', 'other_disb_per'),
        ('refunds_total_contributions_col_total_year', 'ref_ttl_contb_col_ttl_ytd'),
        ('other_disbursements_year', 'other_disb_ytd'),
        ('transaction_sk', 'transaction_sk'),
        ('refunds_individual_contributions_year', 'ref_indv_contb_ytd'),
        ('individual_item_contributions_period', 'indv_item_contb_per'),
        ('total_loans_year', 'ttl_loans_ytd'),
        ('cash_on_hand_end_period', 'coh_cop_i'),
        ('net_contributions_period', 'net_contb_per'),
        #('reporttype_sk', 'reporttype_sk'),
        ('net_contributions_year', 'net_contb_ytd'),
        ('individual_unitemized_contributions_period', 'indv_unitem_contb_per'),
        ('other_political_committee_contributions_year', 'other_pol_cmte_contb_ytd'),
        ('total_receipts_period', 'ttl_receipts_per_i'),
        ('cash_on_hand_end_period', 'coh_cop_ii'),
        ('total_contribution_refunds_year', 'ttl_contb_ref_ytd'),
        ('other_political_committee_contributions_period', 'other_pol_cmte_contb_per'),
        ('total_contributions_period', 'ttl_contb_per'),
        ('loan_repayments_candidate_loans_year', 'loan_repymts_cand_loans_ytd'),
        #('cmte_sk', 'cmte_sk'),
        #('form_3_sk', 'form_3_sk'),
        ('total_disbursements_year', 'ttl_disb_ytd'),
        ('total_offsets_to_operating_expenditures_year', 'ttl_offsets_to_op_exp_ytd'),
        ('debts_owed_to_committee', 'debts_owed_to_cmte'),
        ('total_operating_expenditures_year', 'ttl_op_exp_ytd'),
        ('report_year', 'rpt_yr'),
        ('gross_receipt_authorized_committee_primary', 'grs_rcpt_auth_cmte_prim'),
        ('political_party_committee_contributions_period', 'pol_pty_cmte_contb_per'),
        ('total_contributions_year', 'ttl_contb_ytd'),
        ('loan_repayments_other_loans_period', 'loan_repymts_other_loans_per'),
        ('operating_expenditures_year', 'op_exp_ytd'),
        ('total_loans_period', 'ttl_loans_per'),
        ('total_individual_contributions_year', 'ttl_indv_contb_ytd'),
        ('total_receipts', 'ttl_receipts_ii'),
        ('facthousesenate_f3_sk', 'facthousesenate_f3_sk'),
        ('loan_repayments_other_loans_year', 'loan_repymts_other_loans_ytd'),
        ('refunds_political_party_committee_contributions_year', 'ref_pol_pty_cmte_contb_ytd'),
        ('beginning_image_number', 'begin_image_num'),
        ('expire_date', 'expire_date'),
        ('political_party_committee_contributions_year', 'pol_pty_cmte_contb_ytd'),
        ('loans_made_by_candidate_year', 'loans_made_by_cand_ytd'),
        ('total_receipts_year', 'ttl_receipts_ytd'),
        ('total_disbursements_period', 'ttl_disb_per_i'),
        ('other_receipts_period', 'other_receipts_per'),
        ('total_contribution_refunds_col_total_period', 'ttl_contb_ref_col_ttl_per'),
        ('total_individual_contributions_period', 'ttl_indv_contb_per'),
        ('net_operating_expenditures_year', 'net_op_exp_ytd'),
        ('total_operating_expenditures_period', 'ttl_op_exp_per'),
        ('loans_made_by_candidate_period', 'loans_made_by_cand_per'),
        ('aggregate_amount_contributions_pers_fund_primary', 'agr_amt_contrib_pers_fund_prim'),
        ('total_contribution_refunds_period', 'ttl_contb_ref_per'),
        ('subtotal_period', 'subttl_per'),
        ('total_individual_unitemized_contributions_year', 'ttl_indv_unitem_contb_ytd'),
        ('other_receipts_year', 'other_receipts_ytd'),
    )

    report_mapping = (
        ('expire_date', 'expire_date'),
        ('load_date', 'load_date'),
        ('report_type', 'rpt_tp'),
        ('report_type_full', 'rpt_tp_desc'),
    )

    dim_mapping = (
        ('load_date', 'load_date'),
        ('committee_id', 'cmte_id'),
        ('expire_date', 'expire_date'),
    )

    maps_fields = (
        (presidential_mapping, 'presidential_fields'),
        (pac_party_mapping, 'pac_party_fields'),
        (house_senate_mapping, 'house_senate_fields'),
        (report_mapping, 'report_fields'),
        (dim_mapping, 'dimcmte_fields'),
    )


class TotalResource(SingleResource, Total):
    parser = reqparse.RequestParser()

    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
    )

class TotalSearch(Searchable, Total):
    parser = reqparse.RequestParser()

    field_name_map = {"committee_id": string.Template("cmte_id='$arg'"),
    }

    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
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
        'committee_id',
        type=str,
        help='Committee ID that starts with a "C"'
    )
    ### not ready for this one yet
    # parser.add_argument(
    #     'election_cycle',
    #     type=str,
    #     help='Limit results to a two-year election cycle'
    # )


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

if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1].lower().startswith('test'):
        doctest.testmod()
    else:
        debug = not os.getenv('PRODUCTION')
        app.run(debug=debug)
