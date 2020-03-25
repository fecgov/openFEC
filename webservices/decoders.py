import json

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

def dumper(f3p_col_a, f3p_col_b, f3p_description, dumped):
    for row in dumped:
        description, col_a, col_b = row
        f3p_col_a.append(col_a)
        f3p_col_b.append(col_b)
        f3p_description.append(description)


fp = open("data/" + "efile_guide_f3p.json", 'r')
dumped = json.load(fp)
f3p_col_a = []
f3p_col_b = []
f3p_description = []
dumper(f3p_col_a, f3p_col_b, f3p_description, dumped)

f3_col_a = []
f3_col_b = []
f3_description = []
fp = open("data/" + "efile_guide_f3.json", 'r')
dumped = json.load(fp)
dumper(f3_col_a, f3_col_b, f3_description, dumped)

fp = open("data/" + "efile_guide_f3x.json", 'r')
dumped = json.load(fp)
f3x_col_a = []
f3x_col_b = []
f3x_description = []
dumper(f3x_col_a, f3x_col_b, f3x_description, dumped)
