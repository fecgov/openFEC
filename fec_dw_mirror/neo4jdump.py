"""
Move data from PostgreSQL to Node4js
"""
import os
from py2neo import neo4j
import py2neo
import sqlalchemy as sa
import sqlalchemy.orm as orm
from sqlalchemy.ext.declarative import declarative_base

graph_db = neo4j.GraphDatabaseService("http://localhost:7474/db/data/")
(pg_host, pg_password) = ( os.getenv('RDS_HOST'), os.getenv('RDS_PASSWORD') )
if not pg_host or not pg_password:
    raise EnvironmentError("Please set environment variables RDS_HOST and RDS_PASSWORD")
connection_string = "postgresql://openfec:%s@%s/cfdm" % (pg_password, pg_host)
engine = sa.create_engine(connection_string)

meta = sa.MetaData(bind=engine, schema='mirror')
meta.reflect()
Session = orm.sessionmaker(bind=engine)
session = Session()

Base = declarative_base()
Base.metadata.reflect(engine)

class Committee(Base):
    __table__ = meta.tables['mirror.dimcmte']
    
class CommitteeProperties(Base):
    __table__ = meta.tables['mirror.dimcmteproperties']
    committee = orm.relationship(Committee, backref='properties')
    
class Sched_a(Base):
    __table__ = meta.tables['mirror.sched_a']
    committee = orm.relationship(Committee, backref='sched_a')

class Candidate(Base):
    __table__ = meta.tables['mirror.dimcand']
           
class CandidateProperties(Base):
    __table__ = meta.tables['mirror.dimcandproperties']
    candidate = orm.relationship(Candidate, backref='properties',
                                 primaryjoin="CandidateProperties.cand_sk == Candidate.cand_sk"
                                 )  
    
class Sched_b(Base):
    __table__ = meta.tables['mirror.sched_b']
    to_committee = orm.relationship(Committee, backref='sched_b_contributions')
    candidate = orm.relationship(Candidate, backref='sched_b_contributions')


def scalar_attributes_only(obj):
    return {k: v for (k, v) in obj.__dict__.items() 
                      if (not isinstance(v, list))
                      and (not k.startswith('_'))
                      }

def current(lst):
    all_current = [itm for itm in lst if itm.expire_date == None]
    if len(all_current) > 1:
        raise IndexError('%d non-expired records' % len(all_current))
    elif len(all_current) == 0:
        return None
    else:
        return all_current[0]

graph_db.clear()

for contribution in session.query(Sched_a):
    existing = list(graph_db.find('sched_a', property_key='sched_a_sk', property_value=contribution.sched_a_sk))
    if not existing:

        existing_committees = list(graph_db.find('Committee', property_key='cmte_id', property_value=contribution.cmte_id))
        if existing_committees:
            committee = existing_committees[0]
        else:
            committee_attributes = scalar_attributes_only(contribution.committee)
            committee, = graph_db.create(py2neo.node(**committee_attributes))
            committee.set_labels('Committee',)
            
        qry_text = """MATCH (ct:Contributor) 
                      WHERE ct.contbr_id = { contbr_id }
                      AND   ct.contbr_nm = { contbr_nm }
                      RETURN ct"""
        query = neo4j.CypherQuery(graph_db, qry_text)
        existing_contributors = list(query.execute(contbr_id=contribution.contbr_id, contbr_nm=contribution.contbr_nm))
        if existing_contributors:
            contributor = existing_contributors[0].ct
        else:
            contributor_attributes = {'contbr_id': contribution.contbr_id,
                                      'contbr_nm': contribution.contbr_nm,
                                      'contbr_st1': contribution.contbr_st1,
                                      'contbr_st1': contribution.contbr_st1,
                                      'contbr_st2': contribution.contbr_st2,
                                      'contbr_city': contribution.contbr_city,
                                      'contbr_st': contribution.contbr_st,
                                      'contbr_zip': contribution.contbr_zip,
                                      'contbr_employer': contribution.contbr_employer,
                                      'contbr_occupation': contribution.contbr_occupation,
                                      }
            contributor, = graph_db.create(py2neo.node(**contributor_attributes))
            contributor.set_labels('Contributor',)
            
        contribution_details = dict(sched_a_sk=contribution.sched_a_sk,
                                    receipt_tp=contribution.receipt_tp,
                                    contb_receipt_dt=contribution.contb_receipt_dt,
                                    contb_receipt_amt=contribution.contb_receipt_amt)            
        relationship = py2neo.rel((contributor, "CONTRIBUTED", committee, contribution_details))
        relationship = graph_db.create(relationship)
        
