from processors.normalization import normalize_datetime, normalize_boolean

class Documents(object):

    def __init__(self, naive_datetime_fields=None, boolean_fields=None):
        super().__init__()
        self.naive_datetime_fields = naive_datetime_fields
        self.boolean_fields = boolean_fields

    def _populate_naive_datetime_fields(self, doc):
        self.naive_datetime_fields = []
        for key in doc:
            if key.endswith("_date") or key.endswith("_timestamp") or key.endswith("_dt"):
                self.naive_datetime_fields.append(key)

    def _populate_boolean_fields(self, doc):
        self.boolean_fields = []
        for key in doc:
            print('current key:'+key)
            if key.startswith("is_"):
                self.boolean_fields.append(key)

    def normalize_datetime(self, doc):
        if self.naive_datetime_fields is None:
            self._populate_naive_datetime_fields(doc)
        normalize_datetime(doc, fields=self.naive_datetime_fields)

    def normalize_boolean(self, doc):
        if self.boolean_fields is None:
            self._populate_boolean_fields(doc)
        normalize_boolean(doc, fields=self.boolean_fields)

    def normalize(self, doc):
        self.normalize_datetime(doc)
        self.normalize_boolean(doc)

    def remove_hidden_fields(self, doc, hidden_fields):
        return { k:v for k,v in doc.items() if k not in hidden_fields}


    # An Documents object is an iterable object
    def __iter__(self):
        return self.get_document()

    def get_document(self):
        raise NotImplementedError("Please Implement this method")
