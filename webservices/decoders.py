from .efile_parser import get_dataframe
from .efile_parser import parse_f3psummary_column_a
from .efile_parser import parse_f3psummary_column_b

election_types = {
    'GR': 'General runoff',
    'SG': 'Special election general',
    'SGR': 'Special election general runoff',
    'C': 'Convention',
    'SPR': 'Special primary runoff',
    'SC': 'Special convention',
    'PR': 'Primary runoff',
    'G': 'General election',
    'P': 'Primary election',
    'SP': 'Special primary',
    'R': 'Runoff',
    'SR': 'Special runoff',
}

form_types = {
    'F1': 'Statement of organization',
    'F1M': 'Notification of multicandidate status',
    'F2': 'Statement of candidacy',
    'F9': '24-hour notice of disbursements for electioneering communications',
    'F10': '24-hour notice of expenditure of personal funds',
    'F11': '24-hour notice of opposition personal funds amount',
    'F12': '24-hour notice of suspension of increased limits',
    'F99': 'Miscellaneous document',
    'F6': '48-hour notice of contribution/loans received',
}

df = get_dataframe(5)
f3p_col_a = parse_f3psummary_column_a(df)
f3p_col_b = parse_f3psummary_column_b(df)

df = get_dataframe(4)
f3_col_a = parse_f3psummary_column_a(df)
f3_col_b = parse_f3psummary_column_b(df)

df = get_dataframe(6)
f3x_col_a = parse_f3psummary_column_a(df)
f3x_col_b = parse_f3psummary_column_b(df)

