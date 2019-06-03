
LINE_NUMBER_ERROR = """Invalid line_number detected. A valid line_number is using the following format:
'FORM-LINENUMBER'.  For example an argument such as 'F3X-16' would filter down to all schedule a entries
from form F3X line number 16.
"""

class ApiError(Exception):
    status_code = 400

    def __init__(self, message, status_code=None, payload=None):
        super(ApiError, self).__init__()
        self.message = message
        self.status_code = status_code or self.status_code
        self.payload = payload

    def to_dict(self):
        ret = self.payload or {}
        ret['status'] = self.status_code
        ret['message'] = self.message
        return ret
