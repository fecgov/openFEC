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
    party=       (3-letter abbreviation)
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
    
 
class SingleResource(restful.Resource):
    
    def get(self, id):
        qry = "/%s?%s_id='%s'" % (self.htsql_qry, self.table_name_stem, id)
        data = htsql_conn.produce(qry) or [None, ]
        return as_dicts(data)[0]
    

class Searchable(restful.Resource):
    fulltext_qry = """SELECT %s_sk 
                      FROM   dim%s_fulltext
                      WHERE  :findme @@ fulltxt
                      ORDER BY ts_rank_cd(fulltxt, :findme) desc"""
    PAGESIZE=20
    
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
                else:
                    element = self.field_name_map[arg].substitute(arg=args[arg])
                    elements.append(element)
           
        qry = self.htsql_qry
        if elements:
            qry += "?" + "&".join(elements)
    
        offset = self.PAGESIZE * (page_num-1)
        qry = "/(%s).limit(%d,%d)" % (qry, self.PAGESIZE, offset)
        
        print(qry)
        data = htsql_conn.produce(qry)
        return as_dicts(data)


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
   
    
class Help(restful.Resource):
    def get(self):
        return sys.modules[__name__].__doc__
        
    
api.add_resource(Help, '/')
api.add_resource(CandidateResource, '/candidate/<string:id>')
api.add_resource(CandidateSearch, '/candidate')
api.add_resource(CommitteeResource, '/committee/<string:id>')
api.add_resource(CommitteeSearch, '/committee')

if __name__ == '__main__':
    app.run(debug=True)
    
