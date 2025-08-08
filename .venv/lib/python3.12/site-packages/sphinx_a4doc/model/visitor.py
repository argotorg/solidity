from weakref import WeakKeyDictionary

from sphinx_a4doc.model.model import RuleBase, LexerRule, ParserRule

from typing import *


__all__ = [
    'RuleContentVisitor',
    'CachedRuleContentVisitor',
]


T = TypeVar('T')


class RuleContentVisitor(Generic[T]):
    """
    Generic visitor for rule contents.

    """

    def visit(self, r: RuleBase.RuleContent) -> T:
        return getattr(self, r.__meta__.visitor_relay, self.visit_default)(r)

    def visit_default(self, r: RuleBase.RuleContent) -> T:
        raise RuntimeError(f'no visitor for {r.__class__.__name__!r}')

    # Lexer

    def visit_lexer_literal(self, r: LexerRule.Literal) -> T:
        return self.visit_literal(r)

    def visit_lexer_range(self, r: LexerRule.Range) -> T:
        return self.visit_range(r)

    def visit_lexer_charset(self, r: LexerRule.CharSet) -> T:
        return self.visit_charset(r)

    def visit_lexer_reference(self, r: LexerRule.Reference) -> T:
        return self.visit_reference(r)

    def visit_lexer_doc(self, r: LexerRule.Doc) -> T:
        return self.visit_doc(r)

    def visit_lexer_wildcard(self, r: LexerRule.Wildcard) -> T:
        return self.visit_wildcard(r)

    def visit_lexer_negation(self, r: LexerRule.Negation) -> T:
        return self.visit_negation(r)

    def visit_lexer_zero_plus(self, r: LexerRule.ZeroPlus) -> T:
        return self.visit_zero_plus(r)

    def visit_lexer_one_plus(self, r: LexerRule.OnePlus) -> T:
        return self.visit_one_plus(r)

    def visit_lexer_maybe(self, r: LexerRule.Maybe) -> T:
        return self.visit_maybe(r)

    def visit_lexer_sequence(self, r: LexerRule.Sequence) -> T:
        return self.visit_sequence(r)

    def visit_lexer_alternative(self, r: LexerRule.Alternative) -> T:
        return self.visit_alternative(r)

    # Parser

    def visit_parser_reference(self, r: ParserRule.Reference) -> T:
        return self.visit_reference(r)

    def visit_parser_doc(self, r: ParserRule.Doc) -> T:
        return self.visit_doc(r)

    def visit_parser_wildcard(self, r: ParserRule.Wildcard) -> T:
        return self.visit_wildcard(r)

    def visit_parser_negation(self, r: ParserRule.Negation) -> T:
        return self.visit_negation(r)

    def visit_parser_zero_plus(self, r: ParserRule.ZeroPlus) -> T:
        return self.visit_zero_plus(r)

    def visit_parser_one_plus(self, r: ParserRule.OnePlus) -> T:
        return self.visit_one_plus(r)

    def visit_parser_maybe(self, r: ParserRule.Maybe) -> T:
        return self.visit_maybe(r)

    def visit_parser_sequence(self, r: ParserRule.Sequence) -> T:
        return self.visit_sequence(r)

    def visit_parser_alternative(self, r: ParserRule.Alternative) -> T:
        return self.visit_alternative(r)

    # Common

    def visit_literal(self, r: LexerRule.Literal) -> T:
        return self.visit_default(r)

    def visit_range(self, r: LexerRule.Range) -> T:
        return self.visit_default(r)

    def visit_charset(self, r: LexerRule.CharSet) -> T:
        return self.visit_default(r)

    def visit_reference(self, r: RuleBase.Reference) -> T:
        return self.visit_default(r)

    def visit_doc(self, r: RuleBase.Doc) -> T:
        return self.visit_default(r)

    def visit_wildcard(self, r: RuleBase.Wildcard) -> T:
        return self.visit_default(r)

    def visit_negation(self, r: RuleBase.Negation) -> T:
        return self.visit_default(r)

    def visit_zero_plus(self, r: RuleBase.ZeroPlus) -> T:
        return self.visit_default(r)

    def visit_one_plus(self, r: RuleBase.OnePlus) -> T:
        return self.visit_default(r)

    def visit_maybe(self, r: RuleBase.Maybe) -> T:
        return self.visit_default(r)

    def visit_sequence(self, r: RuleBase.Sequence) -> T:
        return self.visit_default(r)

    def visit_alternative(self, r: RuleBase.Alternative) -> T:
        return self.visit_default(r)


class CachedRuleContentVisitor(RuleContentVisitor[T]):
    def __init__(self):
        self._cache: Dict[RuleBase.RuleContent, T] = WeakKeyDictionary()

    def visit(self, r: RuleBase.RuleContent) -> T:
        if r not in self._cache:
            self._cache[r] = super().visit(r)
        return self._cache[r]
