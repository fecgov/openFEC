import os


dirname = os.path.dirname
MAIN_DIRECTORY = dirname(dirname(dirname(__file__)))


def get_full_path(*path):
    return os.path.join(MAIN_DIRECTORY, *path)


def filter_query(model, query, fields, kwargs):
    for field, value in kwargs.items():
        if field not in fields or not value:
            continue
        column = getattr(model, field)
        query = query.filter(column.in_(value))
    return query

def make_pdf_url(imagenumber):
    return 'http://docquery.fec.gov/pdf/{0}/{1}/{1}.pdf'.format(
                str(self.beginning_image_number)[-3:],
                self.beginning_image_number,
            )