"""
A RESTful web service supporting fulltext and field-specific searches.

Supported parameters::

    q=        (fulltext search)
    office=   (governmental office run for)
    state=    (exact search)
    name=     (candidate's name - inexact search)
    
"""
import os
import sqlalchemy as sa
from flask import Flask
from flask.ext.restful import reqparse
from flask.ext import restful
import flask.ext.restful.representations.json
from htsql import HTSQL
import htsql.core.domain
from json_encoding import TolerantJSONEncoder

flask.ext.restful.representations.json.settings["cls"] = TolerantJSONEncoder
        
(uname, passwd) = (os.getenv('RDS_USERNAME'), os.getenv('RDS_PASSWORD'))
htsql_conn = HTSQL("pgsql://%s:%s@localhost:63336/cfdm" % (uname, passwd))

engine = sa.create_engine("postgresql://%s:%s@127.0.0.1:63336/cfdm" % 
                          (uname, passwd))
conn = engine.connect()
metadata = sa.MetaData(bind=engine)
metadata.reflect()

app = Flask(__name__)
api = restful.Api(app)
parser = reqparse.RequestParser()
parser.add_argument('q', type=str, help='Text to search all fields for')

class Searchable(object):
    fulltext_qry = """SELECT %s_sk 
                      FROM   dim%s_fulltext
                      WHERE  :findme @@ fulltxt
                      ORDER BY ts_rank_cd(fulltxt, :findme) desc"""

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
    
    
class Candidate(restful.Resource, Searchable):
    
    table_name_stem = 'cand'
    fulltext_qry = sa.sql.text(Searchable.fulltext_qry % ('cand', 'cand'))
    field_name_map = {"office": 
                      "exists(offices?head(office.office_tp_desc,1)~'%s')",
                      "state": "cand_st='%s'",
                      "name": "cand_nm~'%s'"
                      }
        
    def get(self):
        args = parser.parse_args()
        elements = []
        for arg in args:
            if arg == 'q':    
                fts_result = conn.execute(self.fulltext_qry, 
                                          findme = args['q']).fetchall()
                elements.append("%s_sk={%s}" % 
                                (self.table_name_stem, 
                                 ",".join(str(id[0]) 
                                for id in fts_result)))
            else:
                elements.append(self.field_name_map[arg] % args[arg])
            
        qry = '/dimcand{*,/dimcandproperties,/dimcandoffice{dimoffice,dimparty}}'
        if elements:
            qry += "?" + "&".join(elements)
        else:
            qry += '.limit(1000)'
        
        data = htsql_conn.produce(qry)
        return as_dicts(data)

api.add_resource(Candidate, '/candidate')

if __name__ == '__main__':
    app.run(debug=True)
    
