from sphinx_a4doc.model.model import RuleBase
from sphinx_a4doc.model.visitor import RuleContentVisitor, T

from typing import *


class _ReachableFiner(RuleContentVisitor[Set[RuleBase]]):
    def __init__(self):
        super().__init__()

        self._seen = set()

    def visit_literal(self, r) -> Set[RuleBase]:
        return set()

    def visit_range(self, r) -> Set[RuleBase]:
        return set()

    def visit_charset(self, r) -> Set[RuleBase]:
        return set()

    def visit_reference(self, r: RuleBase.Reference) -> Set[RuleBase]:
        ref = r.get_reference()
        if ref is None:
            return set()
        elif ref in self._seen:
            return set()
        else:
            self._seen.add(ref)
            return {ref} | self.visit(ref.content)

    def visit_doc(self, r: RuleBase.Doc) -> T:
        return set()

    def visit_wildcard(self, r: RuleBase.Wildcard) -> Set[RuleBase]:
        return set()

    def visit_negation(self, r: RuleBase.Negation) -> Set[RuleBase]:
        return self.visit(r.child)

    def visit_zero_plus(self, r: RuleBase.ZeroPlus) -> Set[RuleBase]:
        return self.visit(r.child)

    def visit_one_plus(self, r: RuleBase.OnePlus) -> Set[RuleBase]:
        return self.visit(r.child)

    def visit_maybe(self, r: RuleBase.Maybe) -> Set[RuleBase]:
        return self.visit(r.child)

    def visit_sequence(self, r: RuleBase.Sequence) -> Set[RuleBase]:
        return set().union(*[self.visit(c) for c in r.children])

    def visit_alternative(self, r: RuleBase.Alternative) -> Set[RuleBase]:
        return set().union(*[self.visit(c) for c in r.children])


def find_reachable_rules(r: RuleBase) -> Set[RuleBase]:
    """
    Calculates a set of rules that are reachable from the root rule.

    """

    return {r} | _ReachableFiner().visit(r.content)
