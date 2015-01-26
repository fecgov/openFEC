class Candidate(object):

    # default fields for search
    default_fields = {
        'dimcand_fields': 'cand_id',
        'cand_committee_link_fields': 'cmte_id,cmte_dsgn,cmte_tp,cand_election_yr',
        'office_fields': 'office_district,office_state,office_tp',
        'party_fields': 'party_affiliation_desc,party_affiliation',
        'status_fields': 'election_yr,cand_status,ici_code',
        'properties_fields': 'cand_nm',
        'cmte_fields': 'P',
    }

    # Query
    table_name_stem = 'cand'
    viewable_table_name = "(dimcand?exists(dimcandproperties)&exists(dimcandoffice))"

    def query_text(self, show_fields):
        if show_fields['cmte_fields'] != '':
            cmte = show_fields['cmte_fields']
            if cmte == 'P':
                cmte_des_qry = "?cmte_dsgn={'P'}"
            elif cmte == '!P':
                cmte_des_qry = "?cmte_dsgn!={'P'}"
            else:
                cmte_des_qry = ''

            com_query = "/dimlinkages%s{*, /dimcmte{*,/dimcmteproperties{cmte_nm}}}  :as affiliated_committees," % (cmte_des_qry)

            show_fields['status_fields'] = 'election_yr,' + show_fields['status_fields']

        else:
            com_query = ''


        return """
            %s{{%s},/dimcandproperties{%s},/dimcandoffice{cand_election_yr-,dimoffice{%s},dimparty{%s}},
                              %s
                              /dimcandstatusici{%s}}
        """ % (
                self.viewable_table_name,
                show_fields['dimcand_fields'],
                show_fields['properties_fields'],
                show_fields['office_fields'],
                show_fields['party_fields'],
                com_query,
                show_fields['status_fields'],
        )


    # Field mappings (API_output, FEC_input)
    # basic candidate information
    dimcand_mapping = (
        ('candidate_id', 'cand_id'),
        ('form_type', 'form_tp'),
        ## we don't have this data yet
        ('expire_date','expire_date'),
        ('load_date','load_date'),
        ('*', '*'),
    )

    #affiliated committees
    cand_committee_format_mapping = (
        ('committee_id', 'cmte_id'),
        ('designation', 'cmte_dsgn'),
        ('type', 'cmte_tp'),
        ('election_year', 'cand_election_yr'),
    )
    # I want to take additional formatting from the user but don't want to use it for matching during formatting
    cand_committee_link_mapping = (
        # fields if primary committee is requested
        ('primary_committee', 'cmte_id'),
        ('primary_committee', 'cmte_dsgn'),
        ('primary_committee', 'cmte_tp'),
        ('primary_committee', 'cand_election_yr'),
        # fields if associated committee is requested
        ('associated_committee', 'cmte_id'),
        ('associated_committee', 'cmte_dsgn'),
        ('associated_committee', 'cmte_tp'),
        ('associated_committee', 'cand_election_yr'),
        ('year', 'cand_election_yr'),
        ('*', '*'),
        # regular mapping
    ) + cand_committee_format_mapping
    # dimoffice
    office_mapping = (
        ('office', 'office_tp'),
        ('district', 'office_district'),
        ('state', 'office_state'),
        ('office_sought_full', 'office_tp_desc'),
        ('office_sought', 'office_tp'),
        ('*', '*'),
    )
    #dimparty
    party_mapping = (
        ('party', 'party_affiliation'),
        ('party_affiliation', 'party_affiliation_desc'),
        ('*', '*'),
    )
    # dimcandstatus
    status_mapping = (
        ('election_year', 'election_yr'),
        ('candidate_inactive', 'cand_inactive_flg'),
        ('candidate_status', 'cand_status'),
        ('incumbent_challenge', 'ici_code'),
        ('*', '*'),
    )
    # dimcandproperties
    property_fields_mapping = (
        ('name', 'cand_nm'),
        ('street_1', 'cand_st1'),
        ('street_2','cand_st2'),
        ('city', 'cand_city'),
        ('state', 'cand_st'),
        ('zip', 'cand_zip'),
        ('expire_date', 'expire_date'),
    )
    # I want to take additional formatting from the user but don't want to use it for matching during formatting
    properties_mapping = (
        ('mailing_addresses', 'cand_st1,cand_st2,cand_city,cand_st,\
            cand_zip,expire_date'),
        ('*', '*'),

    ) + property_fields_mapping
    # to filter primary from affiliated committees
    cmte_mapping = (
        ('primary_committee', 'P'),
        ('affiliated_committees', '!P'),
        ('*', '*'),
    )

    # connects mappings to field names
    maps_fields = (
        (dimcand_mapping, 'dimcand_fields'),
        (cand_committee_link_mapping, 'cand_committee_link_fields'),
        (office_mapping, 'office_fields'),
        (party_mapping, 'party_fields'),
        (status_mapping,'status_fields'),
        (properties_mapping, 'properties_fields'),
        (cmte_mapping, 'cmte_fields'),
    )
