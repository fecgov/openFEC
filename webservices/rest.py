"""
A RESTful web service supporting fulltext and field-specific searches on FEC candidate data.

Supported parameters across all objects::

    q=         (fulltext search)
    
Supported for /candidate ::

    office=    (governmental office run for)
    state=     (two-letter code)
    name=      (candidate's name)
    
Supported for /committee ::

    name=      (committee's name)
    state=     (two-letter code)
    candidate= (associated candidate's name)
    
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
    

class Searchable(restful.Resource):
    fulltext_qry = """SELECT %s_sk 
                      FROM   dim%s_fulltext
                      WHERE  :findme @@ fulltxt
                      ORDER BY ts_rank_cd(fulltxt, :findme) desc"""
    
    def get(self):
        args = self.parser.parse_args()
        elements = []
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
                else:
                    element = self.field_name_map[arg].substitute(arg=args[arg])
                    elements.append(element)
            
        qry = '/dimcand{*,/dimcandproperties,/dimcandoffice{dimoffice,dimparty}}'
        if elements:
            qry = self.htsql_qry + "?" + "&".join(elements)
        else:
            qry = self.htsql_qry + '.limit(1000)'
        
        print(qry)
        data = htsql_conn.produce(qry)
        return as_dicts(data)

    
class Candidate(Searchable):
    
    table_name_stem = 'cand'
    htsql_qry = '/dimcand{*,/dimcandproperties,/dimcandoffice{dimoffice,dimparty}}'
    field_name_map = {"office": 
                      string.Template("exists(dimcandoffice?dimoffice.office_tp~'$arg')"),
                      "state": string.Template("exists(dimcandproperties?cand_st~'$arg')"),
                      "name": string.Template("exists(dimcandproperties?cand_nm~'$arg')"),
                      }
    parser = reqparse.RequestParser()
    parser.add_argument('q', type=str, help='Text to search all fields for')
    parser.add_argument('office', type=str, help='Governmental office candidate runs for')
    parser.add_argument('state', type=str, help='U. S. State candidate is registered in')
    parser.add_argument('name', type=str, help="Candidate's name (full or partial)")
 

class Committee( Searchable):
    
    table_name_stem = 'cmte'
    htsql_qry = '/dimcmte{*,/dimcmteproperties}'
    field_name_map = {"candidate": 
                      string.Template("exists(dimcmteproperties?fst_cand_nm~'$arg')"
                                      "|exists(dimcmteproperties?sec_cand_nm~'$arg')"
                                      "|exists(dimcmteproperties?trd_cand_nm~'$arg')"
                                      "|exists(dimcmteproperties?frth_cand_nm~'$arg')"
                                      "|exists(dimcmteproperties?fith_cand_nm~'$arg')")
                      ,
                      "state": string.Template("exists(dimcmteproperties?cmte_st~'$arg')"),
                      "name": string.Template("exists(dimcmteproperties?cmte_nm~'$arg')"),
                      }
    parser = reqparse.RequestParser()
    parser.add_argument('q', type=str, help='Text to search all fields for')
    parser.add_argument('state', type=str, help='U. S. State committee is registered in')
    parser.add_argument('name', type=str, help="Committee's name (full or partial)")
    parser.add_argument('candidate', type=str, help="Associated candidate's name (full or partial)")
   
    
class Help(restful.Resource):
    def get(self):
        return sys.modules[__name__].__doc__
        
    
api.add_resource(Help, '/')
api.add_resource(Candidate, '/candidate')
api.add_resource(Committee, '/committee')

if __name__ == '__main__':
    app.run(debug=True)
    
