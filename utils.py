"""Utilities for getting the number of Congressional districts per state.
"""
import json

import sqlalchemy as sa

from webservices.rest import db

fips_states = sa.Table('ofec_fips_states', db.metadata, autoload_with=db.engine)
zips_districts = sa.Table('ofec_zips_districts', db.metadata, autoload_with=db.engine)

def get_district_counts():
    aggregates = db.session.query(
        zips_districts.c['State'],
        sa.func.max(zips_districts.c['Congressional District']).label('districts'),
    ).group_by(
        zips_districts.c['State'],
    ).subquery()
    return db.session.query(
        aggregates.c.districts,
        fips_states.c['Official USPS Code'].label('state'),
        fips_states.c['Name'].label('state_full'),
    ).join(
        fips_states,
        aggregates.c['State'] == fips_states.c['FIPS State Numeric Code'],
    )

def write_district_counts(outname):
    counts = get_district_counts()
    output = {
        row.state: {
            'fullname': row.state_full,
            'districts': row.districts,
        }
        for row in counts
    }
    with open(outname, 'w') as fp:
        json.dump(output, fp, indent=2)
