# All files in the `data/sql_updates` folder are automatically added to the
# graph as nodes.

# If you need to add a dependency, note that the dependency must be listed on
# the left first.

import os

import networkx as nx

here, _ = os.path.split(__file__)
home = os.path.join(here, os.pardir)
script_path = os.path.join(home, 'data', 'sql_updates')

def get_graph():
    """Build a `DiGraph` that captures dependencies between database migration
    tasks. Each node represents a migration script, and each edge represents
    a dependency between tasks. Tasks can be ordered using topological sort.
    """
    graph = nx.DiGraph()
    for path in os.listdir(script_path):
        name, ext = os.path.splitext(path)
        if ext == '.sql':
            graph.add_node(name)

    graph.add_edge('candidate_history', 'candidate_detail')
    graph.add_edge('candidate_detail', 'candidate_election')

    graph.add_edges_from([
        ('candidate_history', 'candidate_history_latest'),
        ('candidate_election', 'candidate_history_latest')
    ])

    graph.add_edge('committee_history', 'committee_detail')

    graph.add_edges_from([
        ('candidate_history', 'filings'),
        ('committee_history', 'filings'),
    ])

    graph.add_edges_from([
        ('filing_amendments_presidential', 'filings'),
        ('filing_amendments_house_senate', 'filings'),
        ('filing_amendments_pac_party','filings'),
        ('filing_amendments_all', 'filings'),
    ])

    graph.add_edges_from([
        ('candidate_history', 'candidate_flags'),
        ('candidate_aggregates', 'candidate_flags'),
    ])

    graph.add_edges_from([
        ('filing_amendments_presidential', 'reports_presidential'),
        ('filing_amendments_house_senate', 'reports_house_senate'),
        ('filing_amendments_pac_party', 'reports_pac_party'),
        ('filing_amendments_all', 'reports_presidential'),
        ('filing_amendments_all', 'reports_house_senate'),
        ('filing_amendments_all', 'reports_pac_party'),
    ])

    graph.add_edges_from([
        ('totals_combined', 'totals_house_senate'),
        ('totals_combined', 'totals_presidential'),
        ('totals_combined', 'totals_pac_party'),
        ('totals_combined', 'totals_ie'),
    ])

    graph.add_edges_from([
        ('committee_detail', 'committee_fulltext'),
        ('totals_combined', 'committee_fulltext'),
    ])

    graph.add_edge('committee_detail', 'totals_pac_party')

    graph.add_edges_from([
        ('candidate_detail', 'candidate_fulltext'),
        ('totals_combined', 'candidate_fulltext'),
    ])

    graph.add_edges_from([
        ('totals_house_senate', 'candidate_aggregates'),
        ('totals_presidential', 'candidate_aggregates'),
        ('candidate_election', 'candidate_aggregates'),
        ('cand_cmte_linkage', 'candidate_aggregates'),
    ])

    graph.add_edges_from([
        ('filings', 'totals_combined'),
    ])

    graph.add_edges_from([
        ('totals_pac_party', 'large_aggregates'),
        ('totals_house_senate', 'large_aggregates'),
        ('totals_combined', 'large_aggregates'),
    ])

    graph.add_edges_from([
        ('candidate_election', 'totals_candidate_committee'),
        ('filings', 'totals_candidate_committee'),
        ('cand_cmte_linkage', 'totals_candidate_committee'),
    ])

    graph.add_edge('committee_history', 'communication_cost')
    graph.add_edge('committee_detail', 'sched_a_by_state_recipient_totals')

    return graph
