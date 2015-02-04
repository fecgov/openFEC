from datetime import datetime

from webservices import decoders


# still need to implement year
def format_committees(self, data, page, fields, year):
    results = []
    for cmte in data:
        committee = {}
        # Keeps track of previous info
        record = {}

        for api_name, fec_name in self.dimcmte_mapping:
            if fec_name in cmte['dimcmte']:
                committee[api_name] = cmte['dimcmte'][fec_name]

        for item in cmte['dimcmteproperties']:
            # shortcut for formatting
            if item['expire_date'] is not None:
                if item['expire_date'] > datetime.now():
                    expired = False
                else:
                    expired = True
            else:
                expired = False

            if item.get('load_date') is not None:
                committee['load_date'] = item['load_date']

            # address
            address = {}
            for api_name, fec_name in self.committee_address_field_mappings:
                if (item.get(fec_name) is not None
                        and fec_name != 'expire_date'):
                    address[api_name] = item[fec_name]

            if 'expire_date' in fields or '*' in fields or fields == []:
                address['expire_date'] = item['expire_date']

            if 'state_full' in address:
                address['state_full'] = item['cmte_st_desc'].strip()

            if len(address) > 0:
                if item['expire_date'] is None:
                    committee['address'] = address
                else:
                    if 'address' not in record:
                        record['address'] = {}
                    record['address'][item['expire_date']] = address

            # properties table called description in api
            description = {}
            for api_name, fec_name in self.properties_field_mapping:
                if (item.get(fec_name) is not None
                        and fec_name != 'expire_date'):
                    description[api_name] = item[fec_name]

            if ('cand_pty_affiliation' in item
                    and item['cand_pty_affiliation'] in decoders.party):
                description['party_full'] = \
                    decoders.party[item['cand_pty_affiliation']]

            if len(description) > 0:
                if 'expire_date' in fields or '*' in fields:
                    description['expire_date'] = item['expire_date']
                if not expired and len(description) > 0:
                    committee['description'] = description
                else:
                    if 'description' not in record:
                        record['description'] = {}
                    record['description'][item['expire_date']] = description

            # treasurer
            treasurer = {}
            for api_name, fec_name in self.treasurer_field_mapping:
                if item.get(fec_name) is not None:
                    treasurer[api_name] = item[fec_name]

            if len(treasurer) > 0:
                if 'expire_date' in fields or '*' in fields:
                    treasurer['expire_date'] = item['expire_date']
                if not expired:
                    committee['treasurer'] = treasurer
                else:
                    if 'treasurer' not in record:
                        record['treasurer'] = {}
                    record['treasurer'][item['expire_date']] = treasurer

            # custodian
            custodian = {}
            for api_name, fec_name in self.custodian_field_mapping:
                if item.get(fec_name) is not None:
                    custodian[api_name] = item[fec_name]

            if len(custodian) > 0:
                if 'expire_date' in fields or '*' in fields:
                    custodian['expire_date'] = item['expire_date']
                if not expired:
                    committee['custodian'] = custodian
                else:
                    if 'custodian' not in record:
                        record['custodian'] = {}
                    record['custodian'][item['expire_date']] = custodian

            # designation
            for designation in cmte['dimcmtetpdsgn']:
                status = {}
                for api_name, fec_name in self.designation_mapping:
                    if fec_name in designation and fec_name != 'expire_date':
                        status[api_name] = designation[fec_name]

                if 'expire_date' in fields or '*' in fields or fields == []:
                    status['expire_date'] = designation['expire_date']

                if ('cmte_dsgn' in designation
                        and designation['cmte_dsgn'] in decoders.designation):
                    status['designation_full'] = \
                        decoders.designation[designation['cmte_dsgn']]

                if ('cmte_tp' in designation
                        and designation['cmte_tp'] in decoders.cmte):
                    status['type_full'] = decoders.cmte[designation['cmte_tp']]

                if len(status) > 0:
                    if designation['expire_date'] is None:
                        committee['status'] = status
                    else:
                        if 'status' not in record:
                            record['status'] = {}
                        record['status'][designation['expire_date']] = status

            # candidates associated with committees
            candidate_dict = {}
            for cand in cmte['dimlinkages']:
                candidate = {}
                if cmte['dimlinkages'] != []:
                    if 'dimcand' in cmte['dimlinkages'][0]:
                        dimcand = cmte['dimlinkages'][0]['dimcand'][0]
                        if dimcand['dimcandproperties'] != []:
                            # this assumes the most recent is last, which
                            # seems to be the case
                            candidate['candidate_name'] = \
                                dimcand['dimcandproperties'][-1]['cand_nm']
                        if dimcand['dimcandoffice'] != []:
                            # not worried about this changing because they
                            # would get a new id if it did
                            dimoffice = dimcand['dimcandoffice'][0]
                            dimoffice = dimoffice['dimoffice'][0]
                            candidate['office_sought'] = \
                                dimoffice['office_tp']
                            candidate['office_sought_full'] = \
                                dimoffice['office_tp_desc']

                for api_name, fec_name in self.linkages_field_mapping:
                    if (fec_name in cand and fec_name != 'expire_date'
                            and fec_name != 'cand_id'):
                        candidate[api_name] = cand[fec_name]
                if 'election_years' in candidate:
                    candidate['election_years'] = \
                        [int(candidate['election_years'])]
                if 'expire_date' in fields or '*' in fields or fields == []:
                    candidate['expire_date'] = cand['expire_date']
                if ('candidate_id' in fields or 'fec_id' in fields
                        or '*' in fields or fields == []):
                    candidate['candidate_id'] = cand['cand_id']
                if 'type' in candidate:
                    candidate['type_full'] = decoders.cmte[candidate['type']]
                if 'designation' in candidate:
                    candidate['designation_full'] = \
                        decoders.designation[candidate['designation']]
                # add all expire dates and save to committee
                if len(candidate) > 0:
                    if cand['cand_id'] not in candidate_dict:
                        candidate_dict[cand['cand_id']] = candidate
                    elif 'election_year' in candidate:
                        candidate_dict[cand['cand_id']][
                            'election_years'].append(
                                candidate['election_years'][0])

        # one entry per candidate
        for cand_id in sorted(candidate_dict):
            if 'candidates' not in committee:
                committee['candidates'] = []
            committee['candidates'].append(candidate_dict[cand_id])

        # if there are no current records, add the most recent record to the
        # top level committee information
        for record_type in record:
            if record_type not in committee:
                key = sorted(record[record_type], key=record[record_type].get,
                             reverse=True)[0]
                committee[record_type] = record[record_type][key]
                # removing from archive so it is not double posted
                del record[record_type][key]
                # adding additional records to archive newest to oldest

            if len(record[record_type]) > 0 and ('archive' in fields
                                                 or '*' in fields):
                if 'archive' not in committee:
                    committee['archive'] = {}
                for key in sorted(record[record_type],
                                  key=record[record_type].get, reverse=True):
                    if record_type not in committee['archive']:
                        committee['archive'][record_type] = []
                    committee['archive'][record_type].append(
                        record[record_type][key])
        # name short cut
        if 'description' in committee and 'name' in committee['description']:
            committee['name'] = committee['description']['name']
        results.append(committee)

    return {'api_version': "0.2", 'pagination': page, 'results': results}
