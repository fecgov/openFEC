"""
A RESTful web service supporting fulltext and field-specific searches on FEC candidate data.

Supported parameters across all objects::

    q=         (fulltext search)

Supported for /candidate ::

    /<cand_id>   Single candidate's record
    cand_id=     Synonym for /<cand_id>
    fec_id=      Synonym for /<cand_id>
    office=      (governmental office run for)
    state=       (two-letter code)
    district=
    name=        (candidate's name)
    page=        Page number
    party=       (3-letter abbreviation)
    per_page=    Number of records per page
    year=        (any year in which candidate ran)

Supported for /committee ::

    /<cmte_id>   Single candidate's record
    cmte_id=     Synonym for /<cmte_id>
    fec_id=      Synonym for /<cmte_id>
    name=        (committee's name)
    state=       (two-letter code)
    candidate=   (associated candidate's name)

"""
import os
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

flask.ext.restful.representations.json.settings["cls"] = TolerantJSONEncoder

sqla_conn_string = os.getenv('SQLA_CONN')
engine = sa.create_engine(sqla_conn_string)
conn = engine.connect()

htsql_conn_string = sqla_conn_string.replace('postgresql', 'pgsql')
htsql_conn = HTSQL(htsql_conn_string)

app = Flask(__name__)
api = restful.Api(app)


def as_dicts(data):
    """
    Because HTSQL results render as though they were lists (field info lost)
    without intervention.
    """
    if isinstance(data, htsql.core.domain.Record):
        return dict(zip(data.__fields__, [as_dicts(d) for d in data]))
    elif isinstance(data, htsql.core.domain.Product) or \
         isinstance(data, list):
        return [as_dicts(d) for d in data]
    else:
        return data


# returns a list of election cycles that pertain to an item, like a committee
### The load date seems to be wrong, if we can't fix that, we should look for the committee's first filing and their last non-amendment filing(you have an infinite amount of time to file corrections)
def election_cycles(start, end):
  years = []

  if end == None or start == None:
    print "\n\n\n", "no start or end", "\n\n\n"
    return None

  end_year = int(datetime.strftime(end, '%Y'))
  # add some check for December? I don't think this will happen much but it is feasible
  start_year = int(datetime.strftime(start, '%Y'))

  print "start year: ", start_year
  print "end year: ", end_year

  ### this shouldn't happen
  if start_year > end_year:
    print "\n\nWHAT????\n\n"
    print "start: ", start_year
    print "end: ", end_year, "\n\n"
    return None


  while start_year <= end_year:
    # eleciton cycles are on even-numbered years
    if start_year % 2 == 0:
      years.append(start_year)
      print "adding ", start_year
    start_year += 1
    print start_year

  # for new committees formed in the beginning of the election cycle
  if len(years) == 0:
    year = start_year + 1
    years.append(year)

  print years
  return years

def find_com_info(com_id):
  qry =
  data = htsql_conn.produce(qry)
  data_dict = as_dicts(data)

# I am not sure if this will scale but it should make it prettier
def format_candids(data, page_data):
  results = []
  # stripping outer list
  for cands in data:
    for cand in data:
      cand_data = {'name':{}}
      cand_data['candate_id'] = cand['cand_id']
      # I am guessing this might need to be flexible, and might work well as a dictionary.
      # I am going by most recent name on this but I would like to loops through all the names and have all the name variations, or perhaps former names. Though, there is also going to be names with different prefixes etc. Perhaps we can add filtering later. It will be convenient for search to pick up as many nicknames as we can.
      # Using most recent name as full name
      cand_data['name']['full_name'] = cand['dimcandproperties'][-1]['cand_nm']

      #I am making this into a dictionary so we can aggregate data for each election across the tables
      elections = {}

      # would rather have this with election year
      # would like to add committee type
      primary_committees = []
      for cmte in cand['primary_committee']:
  ##
        primary_committees.append(cmte['cmte_id'])
      cand_data['primary_committee_ids'] = primary_committees

      affiliated_committees = []

      for cmte in cand['affiliated_committees']:
        affiliated_committees.append(cmte['cmte_id'])
      cand_data['affiliated_committee_ids'] = affiliated_committees


      for office in cand['dimcandoffice']:
        year = office['cand_election_yr']
        elections[year] = {'election_year': year}
        elections[year]['office_sought'] = office['dimoffice']['office_tp_desc']
        elections[year]['district'] = office['dimoffice']['office_district']
        elections[year]['state'] = office['dimoffice']['office_state']
        # these are temporary I want to see if the different table load dates match up
        #elections[year]['dim_office_load_date'] = office['dimoffice']['load_date']
        #elections[year]['dimparty_load_date'] = office['dimparty']['load_date']
        elections[year]['party_affiliation'] = office['dimparty']['party_affiliation_desc']

      for status in cand['dimcandstatusici']:
        year = status['election_yr']
        elections[year]['candidate_inactive'] = status['cand_inactive_flg']

        status_decoder = {'C': 'candidate', 'F': 'future_candidate', 'N': 'not_yet_candidate', 'P': 'prior_candidate'}
        if status['cand_status'] != None:
          elections[year]['candidate_status'] = status_decoder[status['cand_status']]
        else:
          elections[year]['candidate_status'] = None

        ici_decoder = {'C': 'challenger', 'I': 'incumbent', 'O': 'open_seat'}
        if status['ici_code'] != None:
          elections[year]['incumbent_challenge'] = ici_decoder[status['ici_code']]
        else:
          elections[year]['incumbent_challenger'] = None

        #elections[year]['dimcandstatusici_load_date'] = status['load_date']

            # would rather have these with the election year
      addresses = []
      for prop in cand['dimcandproperties']:
        print prop
        mailing_address = {}
        mailing_address['street_1'] = prop['cand_st1']
        mailing_address['street_2'] = prop['cand_st2']
        mailing_address['city'] = prop['cand_city']
        mailing_address['state'] = prop['cand_st']
        mailing_address['zip'] = prop['cand_zip']
        mailing_address['expire_date'] = prop['expire_date']

        election_years = election_cycles(prop['begin_date'], prop['expire_date'])

        # check for sane output
        if election_years != None:
          for year in election_years:
            print year
            #elections[str(year)]['mailing_address'] = mailing_address
        else:
          #data quality check, if there is only one property result, we can safely apply it to all the elections
          if len(cand['dimcandproperties']) == 1:
            print "it is ok"
          else:
            print "\n\n     WHY ARE THESE DATES MISSING?????? There should be %s \n\n" % (len(cand['dimcandproperties']))

          for year in elections:
            elections[year]['mailing_address']= mailing_address


        # Names
        other_names = []
        # perhaps add formatting for white space?
        if (cand_data['name']['full_name'] != prop['cand_nm']) and (prop['cand_nm'] not in other_names):
          other_names.append(prop['cand_nm'])
          cand_data['name']['additional_names'] = other_names

        #form type
        # form id?

      cand_data['elections'] = elections

      results.append(cand_data)

  return [{'api_version':0.1},{'pagination':page_data},{'results': results}]


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
                    fts_result = conn.execute(qry, findme = args['q']).fetchall()
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
                else:
                    element = self.field_name_map[arg].substitute(arg=args[arg])
                    elements.append(element)

        qry = self.htsql_qry
        if elements:
            qry += "?" + "&".join(elements)

        offset = per_page * (page_num-1)
        qry = "/(%s).limit(%d,%d)" % (qry, per_page, offset)

        print(qry)
        data = htsql_conn.produce(qry)
        data_dict = as_dicts(data)
        page_data = {'per_page': per_page, 'page':page_num, 'count': len(data_dict)}
        return format_candids(data_dict, page_data)


class Candidate(object):

    table_name_stem = 'cand'
    htsql_qry = """dimcand{*,/dimcandproperties,/dimcandoffice{cand_election_yr-,dimoffice,dimparty},
                           /dimlinkages{cmte_id}?cmte_tp={'H','S','P'} :as primary_committee,
                           /dimlinkages{cmte_id}?cmte_tp='U' :as affiliated_committees,
                           /dimcandstatusici}
                           """


class CandidateResource(SingleResource, Candidate):

    pass

class CandidateSearch(Searchable, Candidate):

    parser = reqparse.RequestParser()
    parser.add_argument('q', type=str, help='Text to search all fields for')
    parser.add_argument('cand_id', type=str, help="Candidate's FEC ID")
    parser.add_argument('fec_id', type=str, help="Candidate's FEC ID")
    parser.add_argument('page', type=int, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=int, default=20, help='The number of results returned per page. Defaults to 20.')
    parser.add_argument('name', type=str, help="Candidate's name (full or partial)")
    parser.add_argument('office', type=str, help='Governmental office candidate runs for')
    parser.add_argument('state', type=str, help='U. S. State candidate is registered in')
    parser.add_argument('party', type=str, help="Party under which a candidate ran for office")
    parser.add_argument('year', type=int, help="Year in which a candidate runs for office")

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
    htsql_qry = 'dimcmte{*,/dimcmteproperties}'


class CommitteeResource(SingleResource, Committee):

    pass


class CommitteeSearch(Searchable, Committee):

    field_name_map = {"cmte_id": string.Template("cmte_id='$arg'"),
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
    parser.add_argument('cmte_id', type=str, help="Committee's FEC ID")
    parser.add_argument('fec_id', type=str, help="Committee's FEC ID")
    parser.add_argument('state', type=str, help='U. S. State committee is registered in')
    parser.add_argument('name', type=str, help="Committee's name (full or partial)")
    parser.add_argument('candidate', type=str, help="Associated candidate's name (full or partial)")
    parser.add_argument('page', type=int, default=1, help='For paginating through results, starting at page 1')
    parser.add_argument('per_page', type=int, default=20, help='The number of results returned per page. Defaults to 20.')


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
