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
        ('candidate_history', 'candidate_flags'),
        ('candidate_aggregates', 'candidate_flags'),
    ])

    graph.add_edges_from([
        ('totals_house_senate', 'totals_combined'),
        ('totals_presidential', 'totals_combined'),
        ('totals_pac_party', 'totals_combined'),
    ])

    graph.add_edges_from([
        ('committee_detail', 'committee_fulltext'),
        ('totals_combined', 'committee_fulltext'),
    ])

    graph.add_edges_from([
        ('candidate_detail', 'candidate_fulltext'),
        ('totals_combined', 'candidate_fulltext'),
    ])

    graph.add_edge('totals_combined', 'sched_a_by_size_merged')

    graph.add_edges_from([
        ('totals_house_senate', 'candidate_aggregates'),
        ('totals_presidential', 'candidate_aggregates'),
        ('candidate_election', 'candidate_aggregates'),
    ])

    return graph
