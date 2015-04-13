# -*- coding: utf-8 -*-

import abc
import math
import collections

import six
import marshmallow as ma


@six.add_metaclass(abc.ABCMeta)
class Paginator(object):

    def __init__(self, cursor, per_page):
        self.cursor = cursor
        self.per_page = per_page
        self.count = self._count()

    def slice(self, page, per_page):
        return self._slice(per_page * (page - 1), per_page)

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
        return Page(page, self.slice(page, self.per_page), self)


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
        try:
            self.results_schema_class = getattr(meta, 'results_schema_class')
        except AttributeError:
            raise ma.exceptions.MarshmallowError(
                'Must specify `results_schema_class` option '
                'in class `Meta` of `PaginationSchema`.'
            )
        self.results_field_name = getattr(meta, 'results_field_name', 'results')
        self.results_schema_options = getattr(meta, 'results_schema_options', {})


class PaginationSchema(ma.Schema):
    page = ma.fields.Integer()
    count = ma.fields.Integer()
    pages = ma.fields.Integer()
    per_page = ma.fields.Integer()


class PageSchema(ma.Schema):

    OPTIONS_CLASS = PageSchemaOpts

    pagination = ma.fields.Nested(PaginationSchema)

    def __init__(self, nested_options=None, *args, **kwargs):
        super(PageSchema, self).__init__(*args, **kwargs)
        options = {}
        options.update(self.opts.results_schema_options)
        options.update(nested_options or {})
        field = ma.fields.Nested(
            self.opts.results_schema_class,
            attribute='results',
            many=True,
            **options
        )
        # TODO: Move to ``SchemaMeta`` @jmcarp
        self.__class__._declared_fields[self.opts.results_field_name] = field


class SqlalchemyPaginator(Paginator):

    def _count(self):
        return self.cursor.count()

    def _slice(self, offset, limit):
        return self.cursor.offset(offset).limit(limit).all()
