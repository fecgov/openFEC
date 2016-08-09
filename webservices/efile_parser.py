import pandas as pd



def parse_f3psummary_column_a(dataframe=None):
    return dataframe['fecp column name (column a value)'].unique()


def parse_f3psummary_column_b(dataframe=None):
    return dataframe['fecp column name (column b value)'].unique()

def get_dataframe(sheetname=None):
    dataframe = pd.read_excel(
        # /Users/jonathancarmack/Documents/repos/openFEC
        io="/Users/jonathancarmack/Documents/repos/openFEC/data/real_efile_to_form_line_numbers.xlsx",
        index_col="summary line number",
        sheetname=5,
        skiprows=7,

    )
    return dataframe




