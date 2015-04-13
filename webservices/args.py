from webargs import Arg

from flask.ext.restful import inputs


paging = {
    'page': Arg(inputs.natural, default=1, description='For paginating through results, starting at page 1'),
    'per_page': Arg(inputs.natural, default=20, description='The number of results returned per page. Defaults to 20.'),
}

candidate_detail = {
    'office': Arg(str, description='Governmental office candidate runs for'),
    'state': Arg(str, description='U.S. State candidate is registered in'),
    'party': Arg(str, description='Three letter code for the party under which a candidate ran for office'),
    'year': Arg(str, description='See records pertaining to a particular year.'),
    'district': Arg(str, description='Two digit district number'),
    'candidate_status': Arg(str, description='One letter code explaining if the candidate is a present, future or past candidate'),
    'incumbent_challenge': Arg(str, description='One letter code explaining if the candidate is an incumbent, a challenger, or if the seat is open.'),
}

candidate_list = {
    'q': Arg(str, help='Text to search all fields for'),
    'candidate_id': Arg(str, description="Candidate's FEC ID"),
    'fec_id': Arg(str, description="Candidate's FEC ID"),
    'name': Arg(str, description="Candidate's name (full or partial)"),
}
