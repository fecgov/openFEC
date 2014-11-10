"""
A RESTful web service supporting fulltext and field-specific searches on FEC candidate data.

SEE DOCUMENTATION FOLDER
(We can leave this here for now but this is all covered in the documentaion and changes should be reflected there)

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

"""
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
from datetime import datetime
from psycopg2._range import DateTimeRange

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


def format_candids(data, page_data, fields):
  results = []

  if 'elections' in fields:
    fields = fields + ['district', 'party_affiliation', 'primary_cmte', 'affiliated_cmtes', 'state', 'incumbent_challenge', 'cand_status', 'cand_inactive', 'office_sought']
  elif fields == ['*']:
    fields = ['name', 'cand_id', 'mailing_addresses', 'district', 'party_affiliation', 'primary_cmte', 'affiliated_cmtes', 'state', 'incumbent_challenge', 'cand_status', 'cand_inactive', 'office_sought']

  for cand in data:
    #aggregating data for each election across the tables
    elections = {}
    cand_data = {}
    if 'name' in fields or 'full_name' in fields or 'other_names' in fields:
      cand_data = {'name':{}}
    if 'cand_id' in fields:
      cand_data['cand_id'] = cand['cand_id']

    #It will be convenient for search to pick up as many nicknames as we can.
    # Using most recent name as full name
    if 'name' in fields or 'full_name' in fields:
      name = cand['dimcandproperties'][-1]['cand_nm']
      cand_data['name']['full_name'] = name
      # let's do this for now, we could look for improvements in the future
      if len(name.split(',')) == 2 and len(name.split(',')[0].strip()) > 0 and len(name.split(',')[1].strip()) > 0:
        cand_data['name']['name_1'] = name.split(',')[1].strip()
        cand_data['name']['name_2'] = name.split(',')[0].strip()


    # Committee information
    if 'primary_cmte' or 'affiliated_committees' in fields:
      for cmte in cand['affiliated_committees']:
        year = str(cmte['cand_election_yr'])
        if not elections.has_key(year):
          elections[year] = {}
        prmary_cmte = {}
        prmary_cmte['cmte_id'] = cmte['cmte_id']

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

        if cmte['cmte_dsgn'] == 'P' and "primary_cmte" in fields:
          prmary_cmte['designation_code'] = cmte['cmte_dsgn']
          prmary_cmte['designation'] = designation_decoder[cmte['cmte_dsgn']]
          prmary_cmte['type_code'] = cmte['cmte_tp']
          prmary_cmte['type'] = cmte_decoder[cmte['cmte_tp']]
          # if they are running as house and president they will have a different candidate id records
          elections[year]['primary_cmte'] = prmary_cmte

        elif 'affiliated_cmtes' in fields:
          # add a decoder here too
          if not elections[year].has_key('affiliated_cmtes'):
            elections[year]['affiliated_cmtes'] =[{
                  'cmte_id': cmte['cmte_id'],
                  'type_code': cmte['cmte_tp'],
                  'type': cmte_decoder[cmte['cmte_tp']],
                  'designation_code': cmte['cmte_dsgn'],
                  'designation': designation_decoder[cmte['cmte_dsgn']],
            }]
          else:
            elections[year]['affiliated_cmtes'].append({
                  'cmte_id': cmte['cmte_id'],
                  'type_code': cmte['cmte_tp'],
                  'type': cmte_decoder[cmte['cmte_tp']],
                  'designation_code': cmte['cmte_dsgn'],
                  'designation': designation_decoder[cmte['cmte_dsgn']],
            })

    # Office information
    for office in cand['dimcandoffice']:
      year = str(office['cand_election_yr'])

      if not elections.has_key(year):
        elections[year] = {}
      if 'office_sought' in fields:
        elections[year]['office_sought'] = office['dimoffice']['office_tp_desc']
      if 'district'in fields:
        elections[year]['district'] = office['dimoffice']['office_district']
      if 'state' in fields:
        elections[year]['state'] = office['dimoffice']['office_state']
      if 'party_affiliation'in fields:
        elections[year]['party_affiliation'] = office['dimparty']['party_affiliation_desc']

    # status information

    for status in cand['dimcandstatusici']:
      year = str(status['election_yr'])

      if 'cand_inactive' in fields:
        if elections.has_key(year):
          elections[year]['cand_inactive'] = status['cand_inactive_flg']
        else:
          elections[year] = {}
          elections[year]['cand_inactive'] = status['cand_inactive_flg']

      if 'cand_status' in fields:
        status_decoder = {'C': 'candidate', 'F': 'future_candidate', 'N': 'not_yet_candidate', 'P': 'prior_candidate'}
        if status['cand_status'] != None:
          elections[year]['cand_status'] = status_decoder[status['cand_status']]
        else:
          elections[year]['cand_status'] = None

      if 'incumbent_challenge' in fields:
        ici_decoder = {'C': 'challenger', 'I': 'incumbent', 'O': 'open_seat'}
        if status['ici_code'] != None:
          elections[year]['incumbent_challenge'] = ici_decoder[status['ici_code']]
        else:
          elections[year]['incumbent_challenger'] = None

    addresses = []
    other_names = []

    if 'name' or 'mailing_address' in fields:
      for prop in cand['dimcandproperties']:
        mailing_address = {}
        mailing_address['street_1'] = cleantext(prop['cand_st1'])
        mailing_address['street_2'] = cleantext(prop['cand_st2'])
        mailing_address['city'] = cleantext(prop['cand_city'])
        mailing_address['state'] = cleantext(prop['cand_st'])
        mailing_address['zip'] = cleantext(prop['cand_zip'])
        if prop['expire_date'] != None:
          mailing_address['expire_date'] = datetime.strftime(prop['expire_date'], '%Y-%m-%d')
        if mailing_address not in addresses:
          addresses.append(mailing_address)

        if 'name' in fields or 'other_names' in fields:
          # other_names will help improve search based on nick names
          name = cleantext(prop['cand_nm'])
          if (cand_data['name']['full_name'] != name) and (name not in other_names):
            other_names.append(name)

    if "mailing_addresses" in fields:
      cand_data['mailing_addresses'] = addresses

    if len(other_names) > 0 and ('name' in fields):
      cand_data['name']['other_names'] = other_names

    if 'district'in fields or 'party_affiliation'in fields or 'primary_cmte'in fields or 'affiliated_cmtes'in fields or 'state'in fields or 'incumbent_challenge'in fields or 'cand_status'in fields or 'cand_inactive'in fields or 'office_sought' in fields:
      print fields
      cand_data['elections'] = elections

    results.append(cand_data)
  return [{'api_version':0.1},{'pagination':page_data},{'results': results}]


def format_committees(data, page, fields):
  results = []
  for cmte in data:
    committee = {}
    committee['committee_id'] = cmte['cmte_id']
    committee['expire_date'] = cmte['expire_date']
    committee['form_type'] = cmte['form_tp']
    for item in cmte['dimcmteproperties']:
      address = {}
      address['street_1'] = item['cmte_st1']
      address['street_2'] = item['cmte_st2']
      address['city'] = item['cmte_city']
      address['state'] = item['cmte_st']
      address['zip'] = item['cmte_zip']
      address['state_long'] = item['cmte_st_desc'].strip()
      committee['address'] = address


    org_decoder = {'C': 'Corporation', 'L': 'Labor Organization', 'M': 'Membership Organization', 'T': 'Trade Association', 'V': 'Cooperative', 'W': 'Corporation Without Capital Stock'}

    results.append(committee)


  return {'api_version':"0.2", 'pagination':page, 'results': results}
  return data

class SingleResource(restful.Resource):

    def get(self, id):
        qry = "/%s?%s_id='%s'" % (self.htsql_qry, self.table_name_stem, id)
        data = htsql_conn.produce(qry) or [None, ]
        return as_dicts(data)[0]


class Searchable(restful.Resource):
    fulltext_qry = """SELECT %s_sk
                      FROM   dim%s_fulltext
                      WHERE  fulltxt @@ to_tsquery(:findme)
                      ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc"""

    def get(self):
        args = self.parser.parse_args()
        elements = []
        page_num = 1

        for arg in args:
            if args[arg]:
                if arg == 'q':
                    qry = self.fulltext_qry % (self.table_name_stem, self.table_name_stem)
                    qry = sa.sql.text(qry)
                    findme = ' & '.join(args['q'].split())
                    fts_result = conn.execute(qry, findme = findme).fetchall()
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
                    fields = args[arg]
                else:
                    element = self.field_name_map[arg].substitute(arg=args[arg])
                    elements.append(element)

        qry = self.htsql_qry

        if elements:
            qry += "?" + "&".join(elements)
            count_qry = "/count(%s?%s)" % (self.viewable_table_name,
                                           "&".join(elements))
        else:
            count_qry = "/count(%s)" % self.viewable_table_name

        offset = per_page * (page_num-1)
        qry = "/(%s).limit(%d,%d)" % (qry, per_page, offset)

        print("\n%s\n" % (qry))
        data = htsql_conn.produce(qry)

        count = htsql_conn.produce(count_qry)
        print count

        data_dict = as_dicts(data)
        data_count = int(count[0])
        pages = data_count/per_page
        if data_count % per_page != 0:
          pages += 1
        if data_count < per_page:
          per_page = data_count

        page_data = {'per_page': per_page, 'page':page_num, 'pages':pages, 'count': data_count}

        if args['fields'] == None:
          fields = ['cand_id', 'district', 'office_sought', 'party_affiliation', 'primary_cmte', 'state', 'name', 'incumbent_challenge', 'cand_status', 'cand_inactive']
        else:
          fields =  args['fields'].split(',')

### do this better
        if 'Candidate' in self.__class__.__name__:
          return format_candids(data_dict, page_data, fields)
        elif 'Committee' in self.__class__.__name__:
          return format_committees(data_dict, page_data, fields)
        else:
          return data_dict


class Candidate(object):

    table_name_stem = 'cand'
    viewable_table_name = "(dimcand?exists(dimcandproperties)&exists(dimcandoffice))"
    htsql_qry = """%s{*,/dimcandproperties,/dimcandoffice{cand_election_yr-,dimoffice,dimparty},
                      /dimlinkages{cmte_id, cand_election_yr, cmte_tp, cmte_dsgn} :as affiliated_committees,
                      /dimcandstatusici} """ % viewable_table_name

class CandidateResource(SingleResource, Candidate):

    pass

class CandidateSearch(Searchable, Candidate):

    parser = reqparse.RequestParser()
    parser.add_argument('q', type=str, help='Text to search all fields for')
    parser.add_argument('cand_id', type=str, help="Candidate's FEC ID")
    parser.add_argument('fec_id', type=str, help="Candidate's FEC ID")
    parser.add_argument('page', type=natural_number, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=natural_number, default=20, help='The number of results returned per page. Defaults to 20.')
    parser.add_argument('name', type=str, help="Candidate's name (full or partial)")
    parser.add_argument('office', type=str, help='Governmental office candidate runs for')
    parser.add_argument('state', type=str, help='U. S. State candidate is registered in')
    parser.add_argument('party', type=str, help="Party under which a candidate ran for office")
    parser.add_argument('year', type=int, help="Year in which a candidate runs for office")
    parser.add_argument('fields', type=str, help='Choose the fields that are displayed')

    # note: each argument is applied separately, so if you ran as REP in 1996 and IND in 1998,
    # you *will* show up under /candidate?year=1998&party=REP

    field_name_map = {"cand_id": string.Template("cand_id='$arg'"),
                      "fec_id": string.Template("cand_id='$arg'"),
                      "office":
                      string.Template("exists(dimcandoffice?dimoffice.office_tp~'$arg')"),
                      "district":
                      string.Template("exists(dimcandoffice?dimoffice.office_district~'$arg')"),
                      "state": string.Template("exists(dimcandproperties?cand_st~'$arg')"),
                      "name": string.Template("exists(dimcandproperties?cand_nm~'$arg')"),
                      "year": string.Template("exists(dimcandoffice?cand_election_yr=$arg)"),
                      "party": string.Template("exists(dimcandoffice?dimparty.party_affiliation~'$arg')")
                      }


class Committee(object):

    table_name_stem = 'cmte'
    viewable_table_name = "(dimcmte?exists(dimcmteproperties))"
    htsql_qry = '(%s{*,/dimcmteproperties})' % viewable_table_name


class CommitteeResource(SingleResource, Committee):

    pass


class CommitteeSearch(Searchable, Committee):

    field_name_map = {"committee_id": string.Template("cmte_id='$arg'"),
                      "fec_id": string.Template("cmte_id='$arg'"),
                      "candidate":
                      string.Template("exists(dimcmteproperties?fst_cand_nm~'$arg')"
                                      "|exists(dimcmteproperties?sec_cand_nm~'$arg')"
                                      "|exists(dimcmteproperties?trd_cand_nm~'$arg')"
                                      "|exists(dimcmteproperties?frth_cand_nm~'$arg')"
                                      "|exists(dimcmteproperties?fith_cand_nm~'$arg')"),
                      "state": string.Template("exists(dimcmteproperties?cmte_st~'$arg')"),
                      "name": string.Template("exists(dimcmteproperties?cmte_nm~'$arg')"),
                      }
    parser = reqparse.RequestParser()
    parser.add_argument('q', type=str, help='Text to search all fields for')
    parser.add_argument('committee_id', type=str, help="Committee's FEC ID")
    parser.add_argument('fec_id', type=str, help="Committee's FEC ID")
    parser.add_argument('state', type=str, help='U. S. State committee is registered in')
    parser.add_argument('name', type=str, help="Committee's name (full or partial)")
    parser.add_argument('candidate', type=str, help="Associated candidate's name (full or partial)")
    parser.add_argument('page', type=int, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=int, default=20, help='The number of results returned per page. Defaults to 20.')
    parser.add_argument('fields', type=str, help='Choose the fields that are displayed')


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
