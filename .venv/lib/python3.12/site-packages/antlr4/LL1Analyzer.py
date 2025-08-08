#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#/
from antlr4.IntervalSet import IntervalSet
from antlr4.Token import Token
from antlr4.PredictionContext import PredictionContext, SingletonPredictionContext, PredictionContextFromRuleContext
from antlr4.RuleContext import RuleContext
from antlr4.atn.ATN import ATN
from antlr4.atn.ATNConfig import ATNConfig
from antlr4.atn.ATNState import ATNState, RuleStopState
from antlr4.atn.Transition import WildcardTransition, NotSetTransition, AbstractPredicateTransition, RuleTransition


class LL1Analyzer (object):

    #* Special value added to the lookahead sets to indicate that we hit
    #  a predicate during analysis if {@code seeThruPreds==false}.
    #/
    HIT_PRED = Token.INVALID_TYPE

    def __init__(self, atn:ATN):
        self.atn = atn

    #*
    # Calculates the SLL(1) expected lookahead set for each outgoing transition
    # of an {@link ATNState}. The returned array has one element for each
    # outgoing transition in {@code s}. If the closure from transition
    # <em>i</em> leads to a semantic predicate before matching a symbol, the
    # element at index <em>i</em> of the result will be {@code null}.
    #
    # @param s the ATN state
    # @return the expected symbols for each outgoing transition of {@code s}.
    #/
    def getDecisionLookahead(self, s:ATNState):
        if s is None:
            return None

        count = len(s.transitions)
        look = [] * count
        for alt in range(0, count):
            look[alt] = set()
            lookBusy = set()
            seeThruPreds = False # fail to get lookahead upon pred
            self._LOOK(s.transition(alt).target, None, PredictionContext.EMPTY,
                  look[alt], lookBusy, set(), seeThruPreds, False)
            # Wipe out lookahead for this alternative if we found nothing
            # or we had a predicate when we !seeThruPreds
            if len(look[alt])==0 or self.HIT_PRED in look[alt]:
                look[alt] = None
        return look

    #*
    # Compute set of tokens that can follow {@code s} in the ATN in the
    # specified {@code ctx}.
    #
    # <p>If {@code ctx} is {@code null} and the end of the rule containing
    # {@code s} is reached, {@link Token#EPSILON} is added to the result set.
    # If {@code ctx} is not {@code null} and the end of the outermost rule is
    # reached, {@link Token#EOF} is added to the result set.</p>
    #
    # @param s the ATN state
    # @param stopState the ATN state to stop at. This can be a
    # {@link BlockEndState} to detect epsilon paths through a closure.
    # @param ctx the complete parser context, or {@code null} if the context
    # should be ignored
    #
    # @return The set of tokens that can follow {@code s} in the ATN in the
    # specified {@code ctx}.
    #/
    def LOOK(self, s:ATNState, stopState:ATNState=None, ctx:RuleContext=None):
        r = IntervalSet()
        seeThruPreds = True # ignore preds; get all lookahead
        lookContext = PredictionContextFromRuleContext(s.atn, ctx) if ctx is not None else None
        self._LOOK(s, stopState, lookContext, r, set(), set(), seeThruPreds, True)
        return r

    #*
    # Compute set of tokens that can follow {@code s} in the ATN in the
    # specified {@code ctx}.
    #
    # <p>If {@code ctx} is {@code null} and {@code stopState} or the end of the
    # rule containing {@code s} is reached, {@link Token#EPSILON} is added to
    # the result set. If {@code ctx} is not {@code null} and {@code addEOF} is
    # {@code true} and {@code stopState} or the end of the outermost rule is
    # reached, {@link Token#EOF} is added to the result set.</p>
    #
    # @param s the ATN state.
    # @param stopState the ATN state to stop at. This can be a
    # {@link BlockEndState} to detect epsilon paths through a closure.
    # @param ctx The outer context, or {@code null} if the outer context should
    # not be used.
    # @param look The result lookahead set.
    # @param lookBusy A set used for preventing epsilon closures in the ATN
    # from causing a stack overflow. Outside code should pass
    # {@code new HashSet<ATNConfig>} for this argument.
    # @param calledRuleStack A set used for preventing left recursion in the
    # ATN from causing a stack overflow. Outside code should pass
    # {@code new BitSet()} for this argument.
    # @param seeThruPreds {@code true} to true semantic predicates as
    # implicitly {@code true} and "see through them", otherwise {@code false}
    # to treat semantic predicates as opaque and add {@link #HIT_PRED} to the
    # result if one is encountered.
    # @param addEOF Add {@link Token#EOF} to the result if the end of the
    # outermost context is reached. This parameter has no effect if {@code ctx}
    # is {@code null}.
    #/
    def _LOOK(self, s:ATNState, stopState:ATNState , ctx:PredictionContext, look:IntervalSet, lookBusy:set,
                     calledRuleStack:set, seeThruPreds:bool, addEOF:bool):
        c = ATNConfig(s, 0, ctx)

        if c in lookBusy:
            return
        lookBusy.add(c)

        if s == stopState:
            if ctx is None:
                look.addOne(Token.EPSILON)
                return
            elif ctx.isEmpty() and addEOF:
                look.addOne(Token.EOF)
                return

        if isinstance(s, RuleStopState ):
            if ctx is None:
                look.addOne(Token.EPSILON)
                return
            elif ctx.isEmpty() and addEOF:
                look.addOne(Token.EOF)
                return

            if ctx != PredictionContext.EMPTY:
                # run thru all possible stack tops in ctx
                for i in range(0, len(ctx)):
                    returnState = self.atn.states[ctx.getReturnState(i)]
                    removed = returnState.ruleIndex in calledRuleStack
                    try:
                        calledRuleStack.discard(returnState.ruleIndex)
                        self._LOOK(returnState, stopState, ctx.getParent(i), look, lookBusy, calledRuleStack, seeThruPreds, addEOF)
                    finally:
                        if removed:
                            calledRuleStack.add(returnState.ruleIndex)
                return

        for t in s.transitions:
            if type(t) == RuleTransition:
                if t.target.ruleIndex in calledRuleStack:
                    continue

                newContext = SingletonPredictionContext.create(ctx, t.followState.stateNumber)

                try:
                    calledRuleStack.add(t.target.ruleIndex)
                    self._LOOK(t.target, stopState, newContext, look, lookBusy, calledRuleStack, seeThruPreds, addEOF)
                finally:
                    calledRuleStack.remove(t.target.ruleIndex)
            elif isinstance(t, AbstractPredicateTransition ):
                if seeThruPreds:
                    self._LOOK(t.target, stopState, ctx, look, lookBusy, calledRuleStack, seeThruPreds, addEOF)
                else:
                    look.addOne(self.HIT_PRED)
            elif t.isEpsilon:
                self._LOOK(t.target, stopState, ctx, look, lookBusy, calledRuleStack, seeThruPreds, addEOF)
            elif type(t) == WildcardTransition:
                look.addRange( range(Token.MIN_USER_TOKEN_TYPE, self.atn.maxTokenType + 1) )
            else:
                set_ = t.label
                if set_ is not None:
                    if isinstance(t, NotSetTransition):
                        set_ = set_.complement(Token.MIN_USER_TOKEN_TYPE, self.atn.maxTokenType)
                    look.addSet(set_)
