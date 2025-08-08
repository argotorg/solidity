import dataclasses
import enum

import sphinx.application
import sphinx.environment

from typing import *


T = TypeVar('T')


class Converter:
    """
    Converters are used to parse and validate directive and global options.
    They are used as a more powerful substitute for helper functions declared
    in `rst.directives`.

    """

    def from_str(self, value: str):
        """
        Parses string and returns a value.

        Invoked when parsing directive arguments.

        """
        raise NotImplementedError

    def from_any(self, value: Any):
        """
        Validate (and probably convert) object of any type.

        Intended to validate values loaded from conf.py,
        but currently not in use.

        """
        raise NotImplementedError

    def __call__(self, value: str):
        """
        Calls `from_str()`.

        With this method present, converters can be used in ``option_spec``.

        """
        return self.from_str(value)

    def __str__(self):
        """
        String representation used as a value description in rst autodoc.

        """

        return '...'


class StrConverter(Converter):
    """
    Generic converter for stings.

    """

    def __init__(self, min_len=0, max_len=None, regex=None):
        """
        :param min_len: if given, checks that string is at least this long.
        :param max_len: if given, checks that string is at most this long.
        :param regex: if given, string will be matched against this regular
            expression via `re.match`.

        """
        self.min_len = min_len
        self.max_len = max_len
        self.regex = regex

    def from_str(self, value: str):
        value = value.strip()
        return self.from_any(value)

    def from_any(self, value: Any):
        if not isinstance(value, str):
            raise ValueError(f'expected string, got {type(value)}')
        if self.min_len is not None and len(value) < self.min_len:
            raise ValueError(f'should be at least {self.min_len} symbols long')
        if self.max_len is not None and len(value) > self.max_len:
            raise ValueError(f'should be at most {self.min_len} symbols long')
        if self.regex is not None:
            import re
            if re.match(self.regex, value) is None:
                raise ValueError(f'should match regex "{self.regex}"')
        return value

    def __str__(self):
        return '<str>'


class IntConverter(Converter):
    """
    Generic converter for ints.

    """

    def __init__(self, min_val=None, max_val=None):
        """
        :param min_val: if given, checks that int is no less than this value.
        :param max_val: if given, checks that int is no greater than this value.

        """
        self.min_val = min_val
        self.max_val = max_val

    def from_str(self, value: str):
        try:
            value = int(value)
        except ValueError:
            raise ValueError('should be an integer')
        return self.from_any(value)

    def from_any(self, value: Any):
        if not isinstance(value, int):
            raise ValueError(f'expected int, got {type(value)}')
        if self.min_val is not None and value < self.min_val:
            if self.min_val == 1:
                raise ValueError(f'should be positive')
            if self.min_val == 0:
                raise ValueError(f'should not be negative')
            raise ValueError(f'should be no less than {self.min_val}')
        if self.max_val is not None and value > self.max_val:
            if self.max_val == -1:
                raise ValueError(f'should be negative')
            if self.max_val == 0:
                raise ValueError(f'should not be positive')
            raise ValueError(f'should be no greater than {self.min_val}')
        return value

    def __str__(self):
        return '<int>'


class FloatConverter(Converter):
    """
    Generic converter for floats.

    """

    def __init__(self, min_val=None, max_val=None):
        """
        :param min_val: if given, checks that int is no less than this value.
        :param max_val: if given, checks that int is no greater than this value.

        """

        self.min_val = min_val
        self.max_val = max_val

    def from_str(self, value: str):
        try:
            value = float(value)
        except ValueError:
            raise ValueError('should be a float')
        return self.from_any(value)

    def from_any(self, value: Any):
        if not isinstance(value, (float, int)):
            raise ValueError(f'expected float, got {type(value)}')
        value = float(value)
        if self.min_val is not None and value < self.min_val:
            if self.min_val == 0:
                raise ValueError(f'should not be negative')
            raise ValueError(f'should be no less than {self.min_val}')
        if self.max_val is not None and value > self.max_val:
            if self.max_val == 0:
                raise ValueError(f'should not be positive')
            raise ValueError(f'should be no greater than {self.min_val}')
        return value

    def __str__(self):
        return '<float>'


class ListConverter(Converter):
    """
    Parses space- or comma-separated lists, similar to `positive_int_list`.

    """

    def __init__(self, u: Converter, min_len=0, max_len=None):
        """
        :param u: nested converter which will be used to parse list elements.
        :param min_len: if given, checks that list is at least this long.
        :param max_len: if given, checks that list is at most this long.

        """
        self.u = u
        self.min_len = min_len
        self.max_len = max_len

    def from_str(self, value: str):
        if ',' in value:
            value = value.split(',')
        else:
            value = value.split()
        self.check_len(value)
        result = []
        for i, v in enumerate(value):
            result.append(self.u.from_str(v))
        return result

    def from_any(self, value: Any):
        if not isinstance(value, (list, tuple)):
            raise ValueError(f'expected list, got {type(value)}')
        self.check_len(value)
        result = []
        for i, v in enumerate(value):
            result.append(self.u.from_any(v))
        return result

    def check_len(self, value):
        if self.min_len is not None and len(value) < self.min_len:
            raise ValueError(f'should be at least {self.min_len} elements long')
        if self.max_len is not None and len(value) > self.max_len:
            raise ValueError(f'should be at most {self.min_len} elements long')

    def __str__(self):
        return f'{self.u}[, {self.u}[, ...]]'


class TupleConverter(Converter):
    """
    Parses space- or comma-separated tuples.

    """

    def __init__(self, *u: Converter):
        """
        :param u: nested converters. Each tuple element will be parsed with the
            corresponding converter.

        """
        self.u = u

    def from_str(self, value: str):
        if ',' in value:
            value = value.split(',')
        else:
            value = value.split()
        self.check_len(value)
        result = []
        for i, (v, u) in enumerate(zip(value, self.u)):
            result.append(u.from_str(v))
        return result

    def from_any(self, value: Any):
        if not isinstance(value, (list, tuple)):
            raise ValueError(f'expected tuple, got {type(value)}')
        self.check_len(value)
        result = []
        for i, (v, u) in enumerate(zip(value, self.u)):
            result.append(u.from_any(v))
        return result

    def check_len(self, value):
        if len(value) != len(self.u):
            raise ValueError(f'should contain exactly {len(self.u)} items')

    def __str__(self):
        return ', '.join(map(str, self.u))


class EnumConverter(Converter):
    """
    Parses enums.

    """

    def __init__(self, cls: Type[enum.Enum]):
        """
        :param cls: enum class (from the standard python `enum` module).

        """

        self.cls = cls

    def from_str(self, value: str):
        value_orig = value
        value = value.strip().upper().replace('-', '_')
        try:
            return self.cls[value]
        except KeyError:
            items = ', '.join([repr(x.name) for x in self.cls])
            raise ValueError(f'expected one of [{items}], got {value_orig!r} instead')

    def from_any(self, value: Any):
        if not isinstance(value, self.cls):
            raise ValueError(f'expected {self.cls.__name__}, got {type(value)}')
        return value

    def __str__(self):
        return '|'.join(map(lambda x: x.name.lower().replace('_', '-'), self.cls))


class BoolConverter(Converter):
    """
    Converts ``'on'``, ``'off'``, ``'true'``, ``'false'`` strings.

    """

    def from_str(self, value: str):
        value = value.strip().lower()
        if value in ['on', 'yes', 'true']:
            return True
        elif value in ['off', 'no', 'false']:
            return False
        else:
            raise ValueError(f'expected one of [\'on\', \'yes\', \'true\', '
                             f'\'off\', \'no\', \'false\'], '
                             f'got {value!r} instead')

    def from_any(self, value: Any):
        if not isinstance(value, bool):
            raise ValueError(f'expected bool, got {type(value)}')
        return value

    def __str__(self):
        return 'True|False'


class FlagConverter(Converter):
    """
    Converts empty strings to ``True``.

    """

    def from_str(self, value: str):
        if value:
            raise ValueError('value is not expected')
        return True

    def from_any(self, value: Any):
        if not isinstance(value, bool):
            raise ValueError(f'expected bool, got {type(value)}')
        return value

    def __str__(self):
        return ''


def make_converter(tp) -> Converter:
    if tp is str:
        return StrConverter()
    elif tp is bool:
        return BoolConverter()
    elif tp is int:
        return IntConverter()
    elif tp is float:
        return FloatConverter()
    elif tp is list:
        return ListConverter(StrConverter())
    elif getattr(tp, '__origin__', None) is list:
        return ListConverter(make_converter(tp.__args__[0]))
    elif getattr(tp, '__origin__', None) is tuple:
        if ... in tp.__args__:
            raise TypeError('variadic tuples are not supported')
        return TupleConverter(*[make_converter(a) for a in tp.__args__])
    elif getattr(tp, '__origin__', None) is Union:
        if len(tp.__args__) != 2 or type(None) not in tp.__args__:
            raise TypeError('unions are not supported (optionals are, though)')
        if tp.__args__[0] is type(None):
            return make_converter(tp.__args__[1])
        else:
            return make_converter(tp.__args__[0])
    elif isinstance(tp, type) and issubclass(tp, enum.Enum):
        return EnumConverter(tp)
    else:
        raise TypeError(f'unsupported type {tp}')


def make_option_spec(cls):
    options = {}
    for field in dataclasses.fields(cls):  # type: dataclasses.Field
        name = field.name.replace('_', '-')
        if 'converter' in field.metadata:
            converter = field.metadata['converter']
        elif field.type is bool:
            converter = FlagConverter()
            options['no-' + name] = FlagConverter()
        else:
            converter = make_converter(field.type)
        options[name] = converter
    return options


def _parse_options(cls, options, prefix=''):
    result = {}
    if prefix:
        prefix += '-'

    for field in dataclasses.fields(cls):  # type: dataclasses.Field
        name = prefix + field.name.replace('_', '-')
        if name not in options and field.type is not bool:
            continue
        if field.type is bool:
            if name in options:
                result[field.name] = True
            elif 'no-' + name in options:
                result[field.name] = False
        else:
            result[field.name] = options[name]
    return result


class NamespaceHolder:
    def __init__(self, namespace: 'Namespace', prefix: str):
        self.namespace = namespace
        self.prefix = prefix


class Namespace(Generic[T]):
    _cls: Type[T] = None
    _prefix: str = None

    _loaded: Optional[T] = None

    def __init__(self, global_prefix: str, cls: Type[T]):
        """
        :param global_prefix: prefix to be used when adding options
            to ``conf.py`` and to the build environment. The prefix should be
            unique across all namespaces registered in all loaded plugins so
            it's best to use plugin name or domain name as a prefix.
        :param cls: dataclass that contains the settings.

        """

        self._prefix = global_prefix
        self._cls = cls

    def fields(self) -> Iterator[dataclasses.Field]:
        return dataclasses.fields(self._cls)

    def no_global_fields(self) -> Iterator[dataclasses.Field]:
        fields = self.fields()
        return filter(lambda f: not f.metadata.get('no_global', False), fields)

    def get_cls(self):
        return self._cls

    def make_option_spec(self, prefix: str = '') -> Dict[str, Converter]:
        """
        Creates ``option_spec`` for use in rst directives.

        For each boolean options this function will add a corresponding ``no-``
        option.

        :param prefix: if given, each option name will be prefixed. This is
            useful to add settings that are not directly used by the directive
            but instead used to override default settings for nested directives
            via `push_settings()`.
        :return: dict with option names as keys and converters as values.

        """

        option_spec = make_option_spec(self._cls)

        if prefix:
            prefix += '-'
            return {prefix + k: v for k, v in option_spec.items()}
        else:
            return option_spec

    def register_settings(self, app: sphinx.application.Sphinx):
        """
        Registers settings so that they can be loaded from ``conf.py``.

        :param app: current sphinx application.

        """

        prefix = self._prefix
        if prefix:
            prefix += '_'

        for field in self.no_global_fields():
            default = field.default
            if field.default_factory is not dataclasses.MISSING:
                default = self._make_default_factory(field.default_factory)
            if default is dataclasses.MISSING:
                default = None
            rebuild = field.metadata.get('rebuild', False)
            app.add_config_value(prefix + field.name, default, rebuild)

    @staticmethod
    def _make_default_factory(default_factory):
        def factory(_):
            return default_factory()
        return factory

    def load_global_settings(self, env: sphinx.environment.BuildEnvironment) -> T:
        """
        Loads settings from ``conf.py``.

        :param env: current build environment.

        """

        prefix = self._prefix
        if prefix:
            prefix += '_'

        if self._loaded is None:
            options = {}
            for field in self.no_global_fields():
                options[field.name] = env.config[prefix + field.name]
            self._loaded = self._cls(**options)
        return self._loaded

    def load_settings(self, env: sphinx.environment.BuildEnvironment) -> T:
        """
        Loads settings local to the currently processed directive.

        If settings stack is not empty, loads last pushed settings, otherwise
        loads global settings.

        See `push_settings()` and `pop_settings()`.

        :param env: current build environment.

        """

        stack = self._get_stack(env)
        if not stack:
            return self.load_global_settings(env)
        else:
            return stack[-1]

    def push_settings(self, env: sphinx.environment.BuildEnvironment, s: T):
        """
        Pushes settings to the local stack.

        All calls to `load_settings()` will return settings passed to this
        function unless new portion of settings is pushed or this settings
        are popped from the stack.

        This function is intended to be called from `before_content()`
        to redefine default settings for nested directives.

        See `load_settings()` and `pop_settings()`.

        :param env: current build environment.
        :param s: new settings.

        """

        stack = self._get_stack(env)
        stack.append(s)

    def pop_settings(self, env: sphinx.environment.BuildEnvironment):
        """
        Pops settings from the local stack.

        This function is intended to be called from `after_content` to undo
        all changes made by calling `push_settings()` from `before_content()`.

        See `load_settings()` and `push_settings()`.

        :param env: current build environment.

        """

        stack = self._get_stack(env)
        stack.pop()

    def load_from_options(self, options: dict,
                          env: sphinx.environment.BuildEnvironment,
                          prefix: str = '') -> T:
        """
        Load settings from parsed options and merge them with local settings.

        Ignores every option that's not used by this namespace. One can add
        options from multiple namespaces as long as all options have unique
        names.

        Honors ``no-`` options added by `make_option_spec()`.

        :param options: parsed directive options.
        :param env: current build environment.
        :param prefix: prefix that was used in `make_option_spec()`.
        :return: parsed settings.

        """

        options = _parse_options(self._cls, options, prefix)
        local_options = self.load_settings(env)
        return dataclasses.replace(local_options, **options)

    def _get_stack(self, env: sphinx.environment.BuildEnvironment):
        namespaces = env.temp_data.setdefault('configurator_namespaces', {})
        return namespaces.setdefault(self._prefix, [])

    def for_directive(self, prefix='') -> T:
        return NamespaceHolder(self, prefix)


class ManagedDirectiveType(type):
    def __new__(mcs, name, bases, members):
        option_spec = {}
        namespace_attrs: Dict[str, NamespaceHolder] = {}

        for base in bases:
            new_namespace_attrs: Set[NamespaceHolder] = getattr(base, '_namespace_attrs_', {}) or {}

            for new_ns in new_namespace_attrs:
                if new_ns.prefix in namespace_attrs:
                    ns = namespace_attrs[new_ns.prefix]
                    raise TypeError(
                        f'cannot combine namespace '
                        f'{new_ns.namespace.get_cls()} and '
                        f'{ns.namespace.get_cls()}'
                    )
                namespace_attrs[new_ns.prefix] = new_ns

            option_spec.update(getattr(base, 'option_spec', {}) or {})

        option_spec.update(members.get('option_spec', {}))

        for name, member in list(members.items()):
            if isinstance(member, NamespaceHolder):
                new_ns = member.namespace
                if member.prefix in namespace_attrs:
                    ns = namespace_attrs[member.prefix].namespace
                    if not issubclass(new_ns.__class__, ns.__class__):
                        raise TypeError(
                            f'cannot override namespace {ns} with '
                            f'namespace {new_ns}: the later must be a subclass '
                            f'of the former'
                        )
                namespace_attrs[member.prefix] = member

                members[name] = mcs._make_settings_getter(
                    '_configurator_cache_' + name,
                    member.namespace,
                    member.prefix
                )

                option_spec.update(new_ns.make_option_spec(member.prefix))

        members['option_spec'] = option_spec
        members['_namespace_attrs_'] = set(namespace_attrs.values())

        return super(ManagedDirectiveType, mcs).__new__(mcs, name, bases, members)

    @staticmethod
    def _make_settings_getter(name, namespace, prefix):
        @property
        def settings_getter(self):
            if not hasattr(self, name):
                settings = namespace.load_from_options(
                    self.options,
                    self.state.document.settings.env,
                    prefix
                )
                setattr(self, name, settings)
            return getattr(self, name)
        return settings_getter


class ManagedDirective(metaclass=ManagedDirectiveType):
    def push_settings(self, namespace: Namespace[T], value: T):
        namespace.push_settings(self.state.document.settings.env, value)

    def pop_settings(self, namespace: Namespace):
        namespace.pop_settings(self.state.document.settings.env)
