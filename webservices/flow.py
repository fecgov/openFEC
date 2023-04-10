import networkx as nx


def get_graph():
    """Build a `DiGraph` that captures dependencies between database migration
    tasks. Each node represents a migration script, and each edge represents
    a dependency between tasks. Tasks can be ordered using topological sort.
    """
    graph = nx.DiGraph()

    MATERIALIZED_VIEWS = [
        'audit_case',
        'cand_cmte_linkage',
        'candidate_aggregates',
        'candidate_detail',
        'candidate_election',
        'candidate_flags',
        'candidate_fulltext',
        'candidate_history',
        'candidate_history_future',
        'candidate_totals_detail',
        'committee_detail',
        'committee_fulltext',
        'committee_history',
        'communication_cost',
        'communication_cost_by_candidate',
        'electioneering',
        'electioneering_by_candidate',
        'elections_list',
        'filing_amendments_house_senate',
        'filing_amendments_pac_party',
        'filing_amendments_presidential',
        'filings',
        'ofec_agg_coverage_date',
        'ofec_pcc_to_pac',
        'ofec_sched_a_agg_state',
        'ofec_sched_e_mv',
        'reports_house_senate',
        'reports_ie',
        'reports_pac_party',
        'reports_presidential',
        'sched_a_by_size_merged',
        'sched_a_by_state_recipient_totals',
        'sched_e_by_candidate',
        'totals_combined',
        'totals_house_senate',
        'totals_ie',
        'totals_presidential',
        'sched_b_by_recipient',
        'totals_inaugural_donations',
        'sched_h4',
    ]
    graph.add_nodes_from(MATERIALIZED_VIEWS)

    graph.add_edge('candidate_history', 'candidate_detail')
    graph.add_edge('candidate_history', 'candidate_history_future')

    graph.add_edge('candidate_detail', 'candidate_election')
    graph.add_edge('candidate_detail', 'candidate_history_future')

    graph.add_edge('candidate_history_future', 'candidate_aggregates')

    graph.add_edge('committee_history', 'committee_detail')

    graph.add_edges_from([
        ('candidate_history', 'filings'),
        ('committee_history', 'filings'),
    ])

    graph.add_edges_from([
        ('filing_amendments_presidential', 'filings'),
        ('filing_amendments_house_senate', 'filings'),
        ('filing_amendments_pac_party', 'filings'),
    ])

    graph.add_edges_from([
        ('candidate_history', 'candidate_flags'),
        ('candidate_aggregates', 'candidate_flags'),
    ])

    graph.add_edges_from([
        ('totals_combined', 'totals_house_senate'),
        ('totals_combined', 'totals_presidential'),
        ('totals_combined', 'totals_ie'),
    ])

    graph.add_edges_from([
        ('committee_detail', 'committee_fulltext'),
        ('totals_combined', 'committee_fulltext'),
    ])

    graph.add_edges_from([
        ('candidate_detail', 'candidate_fulltext'),
        ('totals_combined', 'candidate_fulltext'),
    ])

    graph.add_edges_from([
        ('totals_combined', 'sched_a_by_size_merged'),
    ])

    graph.add_edges_from([
        ('totals_combined', 'candidate_aggregates'),
        ('cand_cmte_linkage', 'candidate_aggregates'),
        ('cand_cmte_linkage', 'candidate_history'),
    ])

    graph.add_edges_from([
        ('filings', 'totals_combined'),
        ('filings', 'reports_pac_party'),
        ('filings', 'reports_presidential'),
        ('filings', 'reports_house_senate'),
    ])

    graph.add_edges_from([
        ('cand_cmte_linkage', 'candidate_totals_detail'),
        ('totals_combined', 'candidate_totals_detail'),
        ('ofec_agg_coverage_date', 'candidate_totals_detail'),
    ])

    graph.add_edge('committee_history', 'communication_cost')
    graph.add_edge('committee_detail', 'sched_a_by_state_recipient_totals')

    graph.add_edges_from([
        ('cand_cmte_linkage', 'ofec_pcc_to_pac'),
        ('candidate_history', 'ofec_pcc_to_pac'),
    ])

    graph.add_edge('ofec_pcc_to_pac', 'committee_history'),
    graph.add_edge('totals_combined', 'sched_b_by_recipient'),

    return graph
