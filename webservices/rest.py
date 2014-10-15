import os
import sqlalchemy as sa
from flask import Flask, jsonify
from flask.ext.restful import reqparse, fields, marshal, marshal_with
from flask.ext import restful
from htsql import HTSQL
import os
import pprint
from datetime import datetime

(uname, passwd) = (os.getenv('RDS_USERNAME'), os.getenv('RDS_PASSWORD'))
htsql = HTSQL("pgsql://%s:%s@localhost:63336/cfdm" % (uname, passwd))

engine = sa.create_engine("postgresql://%s:%s@127.0.0.1:63336/cfdm" % (uname, passwd))
conn = engine.connect()
metadata = sa.MetaData(bind=engine)
metadata.reflect()

cand_fields = {'cand_sk': fields.Integer,
         'cand_id': fields.String,
         'form_sk': fields.Integer,
         'form_tp': fields.String,
         'load_date': fields.DateTime,
         'expire_date': fields.DateTime,
         }

resource_fields = {
    'data': fields.List(fields.Nested(cand_fields)),
    }

app = Flask(__name__)
api = restful.Api(app)
parser = reqparse.RequestParser()
parser.add_argument('q', type=str, help='Text to search all fields for')


class Searchable(object):
    fulltext_qry = """SELECT %s_sk 
                      FROM   dim%s_fulltext
                      WHERE  :findme @@ fulltxt
                      ORDER BY ts_rank_cd(fulltxt, :findme) desc"""

class Candidate(restful.Resource, Searchable):
    
    table_name_stem = 'cand'
    fulltext_qry = sa.sql.text(Searchable.fulltext_qry % ('cand', 'cand'))
    field_name_map = {"office": "exists(offices?head(office.office_tp_desc,1)~'%s')",
                      "state": "cand_st='%s'",
                      "name": "cand_nm~'%s'"
                      }

    def _serialize(self, v):
        if isinstance(v, datetime):
            return str(v)
        else:
            return v
        
    # @marshal_with(resource_fields)  - why do they turn out blank?    
    def get(self):
        args = parser.parse_args()
        elements = []
        for arg in args:
            if arg == 'q':    
                fts_result = conn.execute(self.fulltext_qry, findme = args['q']).fetchall()
                elements.append("%s_sk={%s}" % (self.table_name_stem, ",".join(str(id[0]) for id in fts_result)))
            else:
                elements.append(self.field_name_map[arg] % args[arg])
            
        qry = '/dimcand{*,/dimcandproperties,/dimcandoffice{dimoffice,dimparty}}'
        qry = '/dimcand'
        if elements:
            qry += "?" + "&".join(elements)
        else:
            qry += '.limit(1000)'
        print(qry)
        data = htsql.produce(qry)
        from encod import DateTimeAwareJSONEncoder as enc
        import pdb; pdb.set_trace()
        data = [{k: self._serialize(r[k]) for k in r} for r in data]
        pprint.pprint(data)
        return flask.jsonify({'data': data})
        # return marshal(resource_fields, {'data': data,})

api.add_resource(Candidate, '/candidate')

if __name__ == '__main__':
    app.run(debug=True)
    