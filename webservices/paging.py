import abc
import math
import collections

import marshmallow as ma

from webservices.spec import spec


class Paginator(metaclass=abc.ABCMeta):

    def __init__(self, cursor, per_page):
        self.cursor = cursor
        self.per_page = per_page
        self.count = self._count()

    def slice(self, page):
        return self._slice(self.per_page * (page - 1), self.per_page)

    @abc.abstractmethod
    def _count(self):
        pass

    @abc.abstractmethod
    def _slice(self, offset, limit):
        pass

    @property
    def pages(self):
        return int(math.ceil(self.count / self.per_page))

    def has_page(self, index):
        return index > 0 and index <= self.pages

    def get_page(self, page):
        return Page(page, self.slice(page), self)


class PaginationInfo(object):

    def __init__(self, page, count, pages, per_page):
        self.page = page
        self.count = count
        self.pages = pages
        self.per_page = per_page

    @classmethod
    def from_page(cls, page):
        return cls(
            page.page,
            page.paginator.count,
            page.paginator.pages,
            page.paginator.per_page,
        )


class Page(collections.Sequence):

    def __init__(self, page, results, paginator):
        self.page = page
        self.results = results
        self.paginator = paginator
        self.pagination = PaginationInfo.from_page(self)

    def __len__(self):
        return len(self.results)

    def __getitem__(self, index):
        return self.results[index]

    @property
    def prev(self):
        page = self.index - 1
        if self.paginator.has_page(page):
            return page
        return None

    @property
    def next(self):
        page = self.index + 1
        if self.paginator.has_page(page):
            return page
        return None


class PageSchemaOpts(ma.schema.SchemaOpts):
    def __init__(self, meta):
        super(PageSchemaOpts, self).__init__(meta)
        self.results_schema_class = getattr(meta, 'results_schema_class', None)
        self.results_field_name = getattr(meta, 'results_field_name', 'results')
        self.results_schema_options = getattr(meta, 'results_schema_options', {})


class PaginationSchema(ma.Schema):
    page = ma.fields.Integer()
    count = ma.fields.Integer()
    pages = ma.fields.Integer()
    per_page = ma.fields.Integer()


class PageMeta(ma.schema.SchemaMeta):
    """Metaclass for `PageSchema` that creates a `Nested` field based on the
    options configured in `OPTIONS_CLASS`.
    """
    def __new__(mcs, name, bases, attrs):
        klass = super().__new__(mcs, name, bases, attrs)
        opts = klass.OPTIONS_CLASS(klass.Meta)
        klass._declared_fields[opts.results_field_name] = ma.fields.Nested(
            opts.results_schema_class,
            attribute='results',
            many=True,
            **opts.results_schema_options
        )
        return klass


class PageSchema(ma.Schema, metaclass=PageMeta):
    OPTIONS_CLASS = PageSchemaOpts
    pagination = ma.fields.Nested(PaginationSchema, ref='#/definitions/Pagination')


class SqlalchemyPaginator(Paginator):

    def _count(self):
        return self.cursor.order_by(None).count()

    def _slice(self, offset, limit):
        offset += (self.cursor._offset or 0)
        if self.cursor._limit:
            limit = min(limit, self.cursor._limit - offset)
        return self.cursor.offset(offset).limit(limit).all()


spec.definition('Pagination', schema=PaginationSchema)
