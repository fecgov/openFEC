"""
Tools for annotating records
"""

# Third Party Dependences
import simplejson as json

def candidate_status(status_code):
    """ Return a status description for a given candidate status code """
    if status_code == "C":
        return "Statutory Candidate"
    elif status_code == "F":
        return "Statutory Candidate for Future Election"
    elif status_code == "N":
        return "Not Yet a Statutory Candidate"
    elif status_code == "P":
        return "Statutory Candidate in Prior Cycle"

def candidate_ici_status(status_code):
    """ Return a description of if the candidate is a challenger, incumbent, or in an open seat race """
    if status_code == "C":
        return "Challenger"
    elif status_code == "I":
        return "Incumbent"
    elif status_code == "O":
        return "Open Seat"

def create_elections_entry(candidate, combined_db):
    """ Iterate through all the elections a candidate has participated in. This combines DIMCANDOFFICE, DIMCANDSTATUSICI, DIMOFFICE, and DIMPARTY """
    elections = []
    try:
        # We iterate through each office in DIMCANDOFFICE, which represent offices the candidate has run for.
        # TODO (seanherron): check for duplicate entries here. They shouldn't occur but we need to verify.
        for office in candidate['DIMCANDOFFICE']:
            election = {}

            # Transfer over the election year of the candidate
            election['ELECTION_YEAR'] = office['CAND_ELECTION_YR']

            # We can now try and see if we can connect this election to the Incumbent/Challenger Indicator
            # We set up a quick list of all the years we have appended
            appended_ici_entries = []
            try:
                # And now iterate through each ICI entry
                for ici in candidate['DIMCANDSTATUSICI']:
                    if ici['ELECTION_YR'] == election['ELECTION_YEAR']:
                        # First We set the candidate status
                        election['STATUS'] = candidate_status(ici['CAND_STATUS'])

                        # Now set the Incumbent Challenger Status
                        election['INCUMBENT_CHALLENGER_STATUS'] = candidate_ici_status(ici['ICI_CODE'])
                    # Make sure the fact that we wrote this year gets logged
                    appended_ici_entries.append(ici['ELECTION_YR'])
            except KeyError:
                pass

            # We repeat the loop to catch things that weren't appended
            try:
                for ici in candidate['DIMCANDSTATUSICI']:
                    if ici['ELECTION_YR'] not in appended_ici_entries:
                        extra_ici = {}
                        # First We set the candidate status
                        extra_ici['STATUS'] = candidate_status(ici['CAND_STATUS'])

                        # Now set the Incumbent Challenger Status
                        extra_ici['INCUMBENT_CHALLENGER_STATUS'] = candidate_ici_status(ici['ICI_CODE'])
                        elections.append(extra_ici)
            except KeyError:
                pass

            # Grab the actual office information (rather than just the key) from our combined_db db and insert that data directly
            office_meta = json.loads(combined_db.Get('OFFICE!%s' % office['OFFICE_SK']))
            election['OFFICE'] = office_meta['OFFICE_TP_DESC']

            # This is annoying - if the candidate is running for President, the state is listed as "US". We don't need to include that that.
            if election['OFFICE'] is not "President":
                election['STATE'] = office_meta['OFFICE_STATE']

            # We'll also include the district if the candidate is running for the House of Representatives
            if election['OFFICE'] is "House":
                election['DISTRICT'] = office_meta['OFFICE_DISTRICT']

            # Grab the party information
            party_meta = json.loads(combined_db.Get('PARTY!%s' % office['PARTY_SK']))
            election['POLITICAL_PARTY_ABBREVIATION'] = party_meta['PARTY_AFFILIATION']
            election['POLITICAL_PARTY'] = party_meta['PARTY_AFFILIATION_DESC']

            # Finally, append the new dictionary to our elections list
            elections.append(election)
    # Sometimes we get a Key Error because the candidate doesn't have any related campaigns. Not sure why that would happen.   
    except KeyError:
        pass

    return elections


