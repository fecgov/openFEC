from utils.metareporter import MetaReporter

#meta = MetaReporter(reporting_meta_index_name="reporting_meta")


class Reporting(object):

    #@meta.configure
    def __init__(self, data_loader):
        self.data_loader = data_loader

    def index(self, index, mappings, documents, key_field):
        '''
        Parameters
        ----------
        index : string
            index or alias name
        mappings
            if provided, will be used as mappings during index creation.
        documents
            iterable object that represents the complete set of documents for this index. Each document is a dictionary.
        key_field: string
            if provided, it identify the name of key field in the dictionary.
        '''
        self.data_loader.data = documents
        self.data_loader.index = index
        self.data_loader.key = key_field
        self.data_loader.mappings = mappings
        self.data_loader.run_data_loading_pipeline()
        try:
            return self.data_loader.document_count
        except AttributeError:
            raise IOError("The connection toward the QA database has issues. Check if it is still under updating.")
