from typing import *

import re

from sphinx_a4doc.model.model import RuleBase, LexerRule, ParserRule
from sphinx_a4doc.model.visitor import *
from sphinx_a4doc.settings import LiteralRendering


def cc_to_dash(name: str) -> str:
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1-\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1-\2', s1).lower()


class ImportanceProvider(CachedRuleContentVisitor[int]):
    """
    Given a rule content item, calculates its importance.

    """

    def visit_literal(self, r: LexerRule.Literal) -> int:
        return 1

    def visit_range(self, r: LexerRule.Range) -> int:
        return 1

    def visit_charset(self, r: LexerRule.CharSet) -> int:
        return 1

    def visit_reference(self, r: RuleBase.Reference) -> int:
        rule = r.get_reference()
        if rule is None:
            return 1
        else:
            return rule.importance

    def visit_doc(self, r: RuleBase.Doc) -> int:
        return 0

    def visit_wildcard(self, r: RuleBase.Wildcard) -> int:
        return 1

    def visit_negation(self, r: RuleBase.Negation) -> int:
        return self.visit(r.child)

    def visit_zero_plus(self, r: RuleBase.ZeroPlus) -> int:
        return self.visit(r.child)

    def visit_one_plus(self, r: RuleBase.OnePlus) -> int:
        return self.visit(r.child)

    def visit_maybe(self, r: RuleBase.Maybe) -> int:
        return self.visit(r.child)

    def visit_sequence(self, r: RuleBase.Sequence) -> int:
        return max(self.visit(c) for c in r.children)

    def visit_alternative(self, r: RuleBase.Alternative) -> int:
        return max(self.visit(c) for c in r.children)


class Renderer(CachedRuleContentVisitor[dict]):
    def __init__(
        self,
        literal_rendering: LiteralRendering = LiteralRendering.CONTENTS_UNQUOTED,
        do_cc_to_dash: bool = False,
        importance_provider: ImportanceProvider = ImportanceProvider()
    ):
        super().__init__()

        self._do_cc_to_dash = do_cc_to_dash
        self.literal_rendering = literal_rendering
        self.importance_provider = importance_provider

    @staticmethod
    def _sequence(*items, linebreaks):
        return dict(sequence=items, autowrap=True, linebreaks=linebreaks)

    @staticmethod
    def _stack(*items):
        return dict(stack=items)

    @staticmethod
    def _choice(*items, default: int = 0):
        return dict(choice=items, default=default)

    @staticmethod
    def _optional(item, skip: bool = False):
        return dict(optional=item, skip=skip)

    @staticmethod
    def _one_or_more(item, repeat=None):
        return dict(one_or_more=item, repeat=repeat)

    @staticmethod
    def _zero_or_more(item, repeat=None):
        return dict(zero_or_more=item, repeat=repeat)

    @staticmethod
    def _terminal(text: str, href: Optional[str]=None, resolve: bool = True, title_is_weak: bool = False, css_class: Optional[str] = None):
        return dict(terminal=text, href=href, resolve=resolve, title_is_weak=title_is_weak, css_class=css_class)

    @staticmethod
    def _non_terminal(text: str, href: Optional[str]=None, resolve: bool = True, title_is_weak: bool = False, css_class: Optional[str] = None):
        return dict(non_terminal=text, href=href, resolve=resolve, title_is_weak=title_is_weak, css_class=css_class)

    @staticmethod
    def _comment(text: str, href: Optional[str]=None):
        return dict(comment=text, href=href)

    @staticmethod
    def _literal(text: str):
        return dict(literal=text)

    @staticmethod
    def _range(text: str):
        return dict(range=text)

    @staticmethod
    def _charset(text: str):
        return dict(charset=text)

    @staticmethod
    def _wildcard(text: str):
        return dict(wildcard=text)

    @staticmethod
    def _negation(text: str):
        return dict(negation=text)

    @staticmethod
    def _skip():
        return None

    def visit_literal(self, r: LexerRule.Literal):
        return self._literal(r.content)

    def visit_range(self, r: LexerRule.Range):
        return self._range(f'{r.start}..{r.end}')

    def visit_charset(self, r: LexerRule.CharSet):
        return self._charset(r.content)

    def visit_reference(self, r: RuleBase.Reference):
        rule = r.get_reference()
        if rule is None:
            if r.name and (r.name[0].isupper() or r.name.startswith('\'')):
                if r.name.startswith('\'') and r.name.endswith('\''):
                    if self.literal_rendering is LiteralRendering.CONTENTS_UNQUOTED:
                        name = r.name[1:-1]
                    else:
                        name = r.name
                else:
                    name = self._cc_to_dash(r.name)
                return self._terminal(name)
            else:
                return self._non_terminal(self._cc_to_dash(r.name))
        elif rule.is_doxygen_inline and rule.content is not None:
            return self.visit(rule.content)
        elif isinstance(rule, LexerRule):
            path = f'{rule.model.get_name()}.{rule.name}'
            if rule.is_literal and self.literal_rendering is not LiteralRendering.NAME:
                literal = str(rule.content)
                if self.literal_rendering is LiteralRendering.CONTENTS_UNQUOTED:
                    literal = literal[1:-1]
                return self._terminal(literal, path, css_class=rule.css_class)
            else:
                name = rule.display_name or self._cc_to_dash(rule.name)
                return self._terminal(name, path, title_is_weak=True, css_class=rule.css_class)
        elif isinstance(rule, ParserRule):
            return self._non_terminal(
                rule.display_name or self._cc_to_dash(rule.name),
                f'{rule.model.get_name()}.{rule.name}',
                title_is_weak=True,
                css_class=rule.css_class)
        else:
            assert False

    def visit_doc(self, r: RuleBase.Doc):
        return self._comment(r.value)

    def visit_wildcard(self, r: RuleBase.Wildcard):
        return self._wildcard('.')

    def visit_negation(self, r: RuleBase.Negation):
        return self._negation(str(r))

    def visit_zero_plus(self, r: RuleBase.ZeroPlus):
        skip = not self.importance_provider.visit(r.child)
        return self._optional(self._one_or_more(self.visit(r.child)), skip=skip)

    def visit_one_plus(self, r: RuleBase.OnePlus):
        return self._one_or_more(self.visit(r.child))

    def visit_maybe(self, r: RuleBase.Maybe):
        if (
            isinstance(r.child, RuleBase.Alternative) and
            len(r.child.children) == 2 and
            self.importance_provider.visit(r.child.children[0]) ==
            self.importance_provider.visit(r.child.children[1])
        ):
            return self._choice(
                self.visit(r.child.children[0]),
                self._skip(),
                self.visit(r.child.children[1]),
                default=1,
            )

        skip = not self.importance_provider.visit(r.child)
        return self._optional(self.visit(r.child), skip=skip)

    def visit_sequence(self, r: RuleBase.Sequence):
        return self._optimize_sequence(list(r.children),
                                       list(r.get_linebreaks()))

    def visit_alternative(self, r: RuleBase.Alternative):
        default = max(enumerate(r.children),
                      key=lambda x: self.importance_provider.visit(x[1]))[0]
        return self._choice(*[self.visit(c) for c in r.children], default=default)

    def _optimize_sequence(self, seq: List[RuleBase.RuleContent], lb: List[bool]):
        assert len(seq) == len(lb)

        # We are trying to find a sub-sequence of form `x y z (A B x y z)*`
        # and replace it with a single 'OneOrMore(Seq(x, y, z), Seq(A, B))'.
        for i in range(len(seq) - 1, -1, -1):
            # Our ZeroPlus rule with a sequence inside:
            star = seq[i]

            if not isinstance(star, RuleBase.ZeroPlus):
                continue
            if not isinstance(star.child, RuleBase.Sequence):
                continue

            nested_seq = list(star.child.children)
            nested_seq_lb = list(star.child.get_linebreaks())

            for j in range(len(nested_seq) - 1, -1, -1):
                k = i + j - len(nested_seq)
                if k < 0 or seq[k] != nested_seq[j]:
                    # Index of the seq after which our sub-sequence start
                    # (e.g. 0 if the first element of our sub-sequence
                    # is the first element of the sequence):
                    seq_start = k + 1
                    # Index of the nested_seq which splits main part
                    # and the repeat part (e.g. for [A, B, x, y, z]
                    # the index is 2):
                    nested_seq_start = j + 1
                    break
            else:
                seq_start = i - len(nested_seq)
                nested_seq_start = 0

            if seq_start == i:
                # matched no elements from the nested sequence
                continue

            repeat = self._optimize_sequence(nested_seq[:nested_seq_start],
                                             nested_seq_lb[:nested_seq_start])
            main = self._optimize_sequence(nested_seq[nested_seq_start:],
                                           nested_seq_lb[nested_seq_start:])

            item = self._one_or_more(main, repeat)

            seq[seq_start:i + 1] = [item]
            lb[seq_start:i + 1] = [any(lb[seq_start:i + 1])]

            return self._optimize_sequence(seq, lb)

        return self._sequence(*[
            e if isinstance(e, dict) else self.visit(e) for e in seq
        ], linebreaks=lb)

    def _cc_to_dash(self, name):
        if self._do_cc_to_dash:
            return cc_to_dash(name)
        else:
            return name
