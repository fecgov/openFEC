import abc
import math
import collections

import marshmallow as ma

from webservices.spec import spec


class BasePage(collections.Sequence):

    def __init__(self, results, paginator):
        self.results = results
        self.paginator = paginator

    def __len__(self):
        return len(self.results)

    def __getitem__(self, index):
        return self.results[index]

    @abc.abstractproperty
    def info(self):
        pass


class OffsetPage(BasePage):

    def __init__(self, page, results, paginator):
        self.page = page
        super(OffsetPage, self).__init__(results, paginator)

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

    @property
    def info(self):
        return {
            'page': self.page,
            'count': self.paginator.count,
            'pages': self.paginator.pages,
            'per_page': self.paginator.per_page,
        }


class SeekPage(BasePage):

    @property
    def last_index(self):
        if self.results:
            return self.paginator._get_index_value(self.results[-1])
        return None

    @property
    def info(self):
        return {
            'count': self.paginator.count,
            'pages': self.paginator.pages,
            'per_page': self.paginator.per_page,
            'last_index': self.last_index,
        }


class BasePaginator(object):

    def __init__(self, cursor, per_page, count=None):
        self.cursor = cursor
        self.per_page = per_page
        self.count = count or self._count()

    @property
    def pages(self):
        return int(math.ceil(self.count / self.per_page))

    @abc.abstractmethod
    def _count(self):
        pass

    @abc.abstractmethod
    def get_page(self, *args, **kwargs):
        pass


class OffsetPaginator(BasePaginator):

    def get_page(self, page):
        return OffsetPage(page, self._fetch(page), self)

    def _get_offset(self, page):
        return self.per_page * (page - 1)


class SeekPaginator(BasePaginator):

    def __init__(self, cursor, per_page, index_column, count=None):
        self.index_column = index_column
        super(SeekPaginator, self).__init__(cursor, per_page, count=count)

    def get_page(self, last_index=None):
        return SeekPage(self._fetch(last_index), self)

    @abc.abstractmethod
    def _fetch(self, last_index, limit):
        pass

    @abc.abstractmethod
    def _get_index_value(self, result):
        pass


class SqlalchemyMixin(object):

    def _count(self):
        return self.cursor.count()


class SqlalchemyOffsetPaginator(SqlalchemyMixin, OffsetPaginator):

    def _fetch(self, page):
        offset, limit = self._get_offset(page), self.per_page
        offset += (self.cursor._offset or 0)
        if self.cursor._limit:
            limit = min(limit, self.cursor._limit - offset)
        return self.cursor.offset(offset).limit(limit).all()


class SqlalchemySeekPaginator(SqlalchemyMixin, SeekPaginator):

    def _fetch(self, last_index):
        cursor, limit = self.cursor, self.per_page
        if last_index is not None:
            cursor = cursor.filter(self.index_column > last_index)
        return cursor.order_by(self.index_column).limit(limit).all()

    def _get_index_value(self, result):
        return getattr(result, self.index_column.key)


class PageSchemaOpts(ma.schema.SchemaOpts):
    def __init__(self, meta):
        super(PageSchemaOpts, self).__init__(meta)
        self.results_schema_class = getattr(meta, 'results_schema_class', None)
        self.results_field_name = getattr(meta, 'results_field_name', 'results')
        self.results_schema_options = getattr(meta, 'results_schema_options', {})


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


class BaseInfoSchema(ma.Schema):
    count = ma.fields.Integer()
    pages = ma.fields.Integer()
    per_page = ma.fields.Integer()


class OffsetInfoSchema(BaseInfoSchema):
    page = ma.fields.Integer()


class SeekInfoSchema(BaseInfoSchema):
    last_index = ma.fields.Integer()


class OffsetPageSchema(ma.Schema, metaclass=PageMeta):
    OPTIONS_CLASS = PageSchemaOpts
    pagination = ma.fields.Nested(OffsetInfoSchema, ref='#/definitions/OffsetInfo', attribute='info')


class SeekPageSchema(ma.Schema, metaclass=PageMeta):
    OPTIONS_CLASS = PageSchemaOpts
    pagination = ma.fields.Nested(SeekInfoSchema, ref='#/definitions/SeekInfo', attribute='info')


spec.definition('OffsetInfo', schema=OffsetInfoSchema)
spec.definition('SeekInfo', schema=SeekInfoSchema)
