import pandas as pd



def parse_f3psummary_column_a(dataframe=None):
    return list(dataframe['fecp column name (column a value)'])


def parse_f3psummary_column_b(dataframe=None):
    return list(dataframe['fecp column name (column b value)'])

def parse_f3psummary_column_description(dataframe=None):
    return list(dataframe['description'])

def get_dataframe(sheetname=None):
    dataframe = pd.read_excel(
        # /Users/jonathancarmack/Documents/repos/openFEC
        io="data/real_efile_to_form_line_numbers.xlsx",
        index_col="summary line number",
        sheetname=sheetname,
        skiprows=7,

    )
    return dataframe




