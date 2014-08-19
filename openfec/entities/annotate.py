"""
Tools for annotating records
"""

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