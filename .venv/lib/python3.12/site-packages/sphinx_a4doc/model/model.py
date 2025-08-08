from abc import ABCMeta, abstractmethod
from dataclasses import dataclass, field, replace
from typing import *

try:
    from typing.io import TextIO
except ImportError:
    from typing import TextIO


__all__ = [
    'ModelCache',
    'Model',
    'Position',
    'RuleBase',
    'ParserRule',
    'LexerRule',
]


_global_cache = None


class ModelCache(metaclass=ABCMeta):
    @staticmethod
    def create() -> 'ModelCache':
        """
        Create the default cache implementation.

        """
        from sphinx_a4doc.model.impl import ModelCacheImpl
        return ModelCacheImpl()

    @staticmethod
    def instance() -> 'ModelCache':
        """
        Get a global cache instance.

        """
        global _global_cache
        if _global_cache is None:
            _global_cache = ModelCache.create()
        return _global_cache

    @abstractmethod
    def from_file(self, path: Union[str, Tuple[str, int]]) -> 'Model':
        """
        Load model from file. If file is not found, returns an empty model.
        Models are cached by absolute path.

        """

    @abstractmethod
    def from_text(self, text: str, path: Union[str, Tuple[str, int]] = '<in-memory>', imports: List['Model'] = None) -> 'Model':
        """
        Load model from text.
        Models are not cached; they also cannot have any imports.
        Path parameter is used purely for error reporting.

        """


class Model(metaclass=ABCMeta):
    @abstractmethod
    def has_errors(self) -> bool:
        """
        Returns true if any error occurred while parsing model.

        """

    @abstractmethod
    def get_type(self) -> Optional[str]:
        """
        Get grammar type: lexer or parser. Returns ``None`` for mixed grammars.

        """

    @abstractmethod
    def get_name(self) -> Optional[str]:
        """
        Get grammar name. Can be empty for in-memory models or in case of
        parsing failure.

        """

    @abstractmethod
    def is_in_memory(self) -> bool:
        """
        Indicates that this model was loaded from memory and there is no real
        file associated with it.

        """

    @abstractmethod
    def get_path(self) -> str:
        """
        Get path for the file that this model was loaded from.
        If model is in-memory, returns a placeholder
        suitable for error reporting.

        """

    @abstractmethod
    def get_model_docs(self) -> Optional[List[Tuple[int, str]]]:
        """
        Get documentation that appear on top of the model.
        The returned list contains one item per documentation comment.
        The first element of this item is a line number at which the comment
        started, the second element is the comment itself.

        """

    @abstractmethod
    def lookup_local(self, name: str) -> Optional['RuleBase']:
        """
        Lookup symbol with the given name.
        Imported models are not checked.

        """

    def lookup(self, name: str) -> Optional['RuleBase']:
        """
        Lookup symbol with the given name.

        Check symbols in the model first, than check imported models.
        To lookup literal tokens, pass contents of the literal,
        e.g. `model.lookup("'literal'")`.

        Returns `None` if symbol cannot be found.

        If there are duplicate symbols, it is unspecified which one is returned.

        """

        models = set()
        visited = set()

        models.add(self)

        while models:
            model = models.pop()
            if model in visited:
                continue
            symbol = model.lookup_local(name)
            if symbol is not None:
                return symbol
            models.update(model.get_imports())
            visited.add(model)

        return None

    @abstractmethod
    def get_imports(self) -> Iterable['Model']:
        """
        Get all imported models.

        No order of iteration is specified.

        Note: cyclic imports are allowed in the model.

        """

    @abstractmethod
    def get_terminals(self) -> Iterable['LexerRule']:
        """
        Get all terminals (including fragments) declared in this model.

        Terminals declared in imported models are not included.

        No order of iteration is specified, sort by position
        must be performed manually.

        """

    @abstractmethod
    def get_non_terminals(self) -> Iterable['ParserRule']:
        """
        Get all non-terminals (parser rules) declared in this model.

        Non-terminals declared in imported models are not included.

        No order of iteration is specified, sort by position
        must be performed manually.

        """


@dataclass(order=True, frozen=True)
class Position:
    file: str
    """Absolute path to the file in which this rule is declared"""

    line: int
    """Line at which this rule is declared"""

    def as_tuple(self):
        return self.file, self.line

    def __repr__(self):
        return 'Position({!r}, {!r})'.format(self.file, self.line)

    def __str__(self):
        return '{}:{}'.format(self.file, self.line)


def meta(**kwargs):
    """
    Decorator that sets meta for the given AST node.

    """
    def wrapper(cls: 'RuleBase.RuleContent'):
        cls.__meta__ = replace(cls.__meta__, **kwargs)
        return cls
    return wrapper


@dataclass(eq=False, frozen=True)
class Section:
    """
    Represents a single section header, i.e. a group of comments that start
    with a triple slash.

    """

    docs: List[Tuple[int, str]]
    """List of documentation lines in the section description"""


@dataclass(eq=False, frozen=True)
class RuleBase:
    """
    Base class for parser and lexer rules.

    """

    name: str
    """Name of this parser rule"""

    display_name: Optional[str]
    """Display name from `doc:name` command"""

    model: Model
    """Reference to the model in which this rule was declared"""

    position: Position
    """A position at which this rule is declared"""

    content: Optional['RuleBase.RuleContent']
    """Body of the token or rule definition.
    May be omitted for implicitly declared tokens or tokens that were declared
    in the `tokens` section of a lexer.
    """

    is_doxygen_nodoc: bool
    """Indicates that the ``'nodoc'`` flag is set for this rule.
    If true, generators should not output any content for this rule.
    """

    is_doxygen_no_diagram: bool
    """Indicates that the ``'no_diagram'`` flag is set.
    If true, generators should not produce railroad diagram for this rule.
    """

    css_class: Optional[str]
    """Custom css class set via `//@ doc:css_class`.
    """

    is_doxygen_inline: bool
    """Indicates that the `'inline'` flag is set for this rule.
    If true, generators should not output any content for this rule.
    They should also inline contents of this rule when rendering
    documentation for any other rule that refers this rule.
    """

    importance: int
    """Importance of the rule"""

    documentation: Optional[List[Tuple[int, str]]]
    """Documentation for this rule"""

    section: Optional[Section]
    """Which section this rule belong to?"""

    def __str__(self):
        lines = [self.name]

        if self.content is None:
            lines.append('  <implicit>')
        else:
            if isinstance(self.content, self.Alternative):
                alts = self.content.children
            else:
                alts = self.content,

            for i, alt in enumerate(alts):
                if i == 0:
                    lines.append('  : ' + str(alt))
                else:
                    lines.append('  | ' + str(alt))

        lines.append('  ;')

        return '\n'.join(lines)

    class RuleContent:
        """
        Base class for AST nodes that form lexer and parser rules.

        """

        @dataclass(frozen=True)
        class Meta:
            precedence: int = 0
            visitor_relay: str = 'visit_default'
            formatter: Callable = field(default=lambda x, _: repr(x))

        __meta__ = Meta()

        def __str__(self):
            p = self.__meta__.precedence
            return self.__meta__.formatter(
                self,
                lambda x: f'{x}' if x.__meta__.precedence > p else f'({x})'
            )

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_reference')
    @meta(precedence=4, formatter=lambda x, f: f'{x.name}')
    class Reference(RuleContent):
        """
        Refers another parser or lexer rule.

        """

        model: Model
        """Reference to the model in which the rule is used"""

        name: str
        """Referenced rule name"""

        def get_reference(self) -> Optional['RuleBase']:
            """
            Lookup and return the actual rule class.
            Returns None if reference is invalid.

            """
            return self.model.lookup(self.name)

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_doc')
    @meta(precedence=4, formatter=lambda x, f: f'/** {x.value} */')
    class Doc(RuleContent):
        """
        Inline documentation.

        """

        value: str

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_wildcard')
    @meta(precedence=4, formatter=lambda x, f: f'.')
    class Wildcard(RuleContent):
        """
        Matches any token.

        """

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_negation')
    @meta(precedence=3, formatter=lambda x, f: f'~{f(x.child)}')
    class Negation(RuleContent):
        """
        Matches anything but the child rules.

        """

        child: 'RuleBase.RuleContent'
        """Rules that will be negated"""

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_zero_plus')
    @meta(precedence=3, formatter=lambda x, f: f'{f(x.child)}*')
    class ZeroPlus(RuleContent):
        """
        Matches the child zero or more times.

        """

        child: 'RuleBase.RuleContent'
        """Rule which will be parsed zero or more times"""

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_one_plus')
    @meta(precedence=3, formatter=lambda x, f: f'{f(x.child)}+')
    class OnePlus(RuleContent):
        """
        Matches the child one or more times.

        """

        child: 'RuleBase.RuleContent'
        """Rule which will be parsed one or more times"""

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_maybe')
    @meta(precedence=3, formatter=lambda x, f: f'{f(x.child)}?')
    class Maybe(RuleContent):
        """
        Matches child or nothing.

        """

        child: 'RuleBase.RuleContent'
        """Rule which will be parsed"""

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_sequence')
    @meta(precedence=1, formatter=lambda x, f: ' '.join(map(f, x.children)))
    class Sequence(RuleContent):
        """
        Matches a sequence of elements.

        """

        children: Tuple['RuleBase.RuleContent', ...]
        """Children rules that will be parsed in order"""

        linebreaks: Optional[Tuple[bool, ...]] = field(
            default=None, compare=False, repr=False)
        """Bitmask which describes where it is preferable to wrap sequence"""

        def __post_init__(self):
            assert self.linebreaks is None or \
                   len(self.linebreaks) == len(self.children)

        def get_linebreaks(self):
            if self.linebreaks is not None:
                return self.linebreaks
            else:
                return tuple([False] * len(self.children))

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_alternative')
    @meta(precedence=0, formatter=lambda x, f: ' | '.join(map(f, x.children)))
    class Alternative(RuleContent):
        """
        Matches either of children.

        """

        children: Tuple['RuleBase.RuleContent', ...]
        """Children rules"""


@dataclass(eq=False, frozen=True)
class LexerRule(RuleBase):
    content: Optional['LexerRule.RuleContent']

    is_literal: bool
    """Indicates that this token is a literal token.
    Literal tokens are tokens with a single fixed-string literal element.
    """

    is_fragment: bool
    """Indicates that this rule is a fragment"""

    @dataclass(frozen=True)
    class RuleContent(RuleBase.RuleContent):
        """
        Lexer rule definition syntax tree node.

        """

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_literal')
    @meta(precedence=4, formatter=lambda x, f: f'{x.content}')
    class Literal(RuleContent):
        """
        A sequence of symbols (e.g. `'kwd'`).

        """

        content: str
        """Formatted content of the literal, with special symbols escaped"""

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_range')
    @meta(precedence=4, formatter=lambda x, f: f'{x.start}..{x.end}')
    class Range(RuleContent):
        """
        A range of symbols (e.g. `a..b`).

        """

        start: str
        """Range first symbol"""

        end: str
        """Range last symbol"""

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_charset')
    @meta(precedence=4, formatter=lambda x, f: f'{x.content}')
    class CharSet(RuleContent):
        """
        A character set (e.g. `[a-zA-Z]`).

        """

        content: str
        """Character set description, bracks included"""

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_reference')
    class Reference(RuleContent, RuleBase.Reference):
        def get_reference(self) -> Optional['LexerRule']:
            rule = super().get_reference()
            if rule is not None:
                assert isinstance(rule, LexerRule)
            return rule

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_doc')
    class Doc(RuleContent, RuleBase.Doc):
        pass

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_wildcard')
    class Wildcard(RuleContent, RuleBase.Wildcard):
        pass

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_negation')
    class Negation(RuleContent, RuleBase.Negation):
        child: 'LexerRule.RuleContent'

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_zero_plus')
    class ZeroPlus(RuleContent, RuleBase.ZeroPlus):
        child: 'LexerRule.RuleContent'

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_one_plus')
    class OnePlus(RuleContent, RuleBase.OnePlus):
        child: 'LexerRule.RuleContent'

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_maybe')
    class Maybe(RuleContent, RuleBase.Maybe):
        child: 'LexerRule.RuleContent'

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_sequence')
    class Sequence(RuleContent, RuleBase.Sequence):
        children: Tuple['LexerRule.RuleContent', ...]

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_lexer_alternative')
    class Alternative(RuleContent, RuleBase.Alternative):
        children: Tuple['LexerRule.RuleContent', ...]

    WILDCARD = Wildcard()
    EMPTY = Sequence(())


@dataclass(eq=False, frozen=True)
class ParserRule(RuleBase):
    content: Optional['ParserRule.RuleContent']

    @dataclass(frozen=True)
    class RuleContent(RuleBase.RuleContent):
        """
        Parser rule definition syntax tree node.

        """

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_parser_reference')
    class Reference(RuleContent, RuleBase.Reference):
        pass

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_parser_doc')
    class Doc(RuleContent, RuleBase.Doc):
        pass

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_parser_wildcard')
    class Wildcard(RuleContent, RuleBase.Wildcard):
        pass

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_parser_negation')
    class Negation(RuleContent, RuleBase.Negation):
        child: 'ParserRule.RuleContent'

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_parser_zero_plus')
    class ZeroPlus(RuleContent, RuleBase.ZeroPlus):
        child: 'ParserRule.RuleContent'

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_parser_one_plus')
    class OnePlus(RuleContent, RuleBase.OnePlus):
        child: 'ParserRule.RuleContent'

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_parser_maybe')
    class Maybe(RuleContent, RuleBase.Maybe):
        child: 'ParserRule.RuleContent'

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_parser_sequence')
    class Sequence(RuleContent, RuleBase.Sequence):
        children: Tuple['ParserRule.RuleContent', ...]

    @dataclass(frozen=True)
    @meta(visitor_relay='visit_parser_alternative')
    class Alternative(RuleContent, RuleBase.Alternative):
        children: Tuple['ParserRule.RuleContent', ...]

    WILDCARD = Wildcard()
    EMPTY = Sequence(())
