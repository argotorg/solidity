#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
from antlr4.atn.ATNState import StarLoopEntryState

from antlr4.atn.ATNConfigSet import ATNConfigSet
from antlr4.atn.ATNState import DecisionState
from antlr4.dfa.DFAState import DFAState
from antlr4.error.Errors import IllegalStateException


class DFA(object):

    def __init__(self, atnStartState:DecisionState, decision:int=0):
        # From which ATN state did we create this DFA?
        self.atnStartState = atnStartState
        self.decision = decision
        # A set of all DFA states. Use {@link Map} so we can get old state back
        #  ({@link Set} only allows you to see if it's there).
        self._states = dict()
        self.s0 = None
        # {@code true} if this DFA is for a precedence decision; otherwise,
        # {@code false}. This is the backing field for {@link #isPrecedenceDfa},
        # {@link #setPrecedenceDfa}.
        self.precedenceDfa = False

        if isinstance(atnStartState, StarLoopEntryState):
            if atnStartState.isPrecedenceDecision:
                self.precedenceDfa = True
                precedenceState = DFAState(configs=ATNConfigSet())
                precedenceState.edges = []
                precedenceState.isAcceptState = False
                precedenceState.requiresFullContext = False
                self.s0 = precedenceState


    # Get the start state for a specific precedence value.
    #
    # @param precedence The current precedence.
    # @return The start state corresponding to the specified precedence, or
    # {@code null} if no start state exists for the specified precedence.
    #
    # @throws IllegalStateException if this is not a precedence DFA.
    # @see #isPrecedenceDfa()

    def getPrecedenceStartState(self, precedence:int):
        if not self.precedenceDfa:
            raise IllegalStateException("Only precedence DFAs may contain a precedence start state.")

        # s0.edges is never null for a precedence DFA
        if precedence < 0 or precedence >= len(self.s0.edges):
            return None
        return self.s0.edges[precedence]

    # Set the start state for a specific precedence value.
    #
    # @param precedence The current precedence.
    # @param startState The start state corresponding to the specified
    # precedence.
    #
    # @throws IllegalStateException if this is not a precedence DFA.
    # @see #isPrecedenceDfa()
    #
    def setPrecedenceStartState(self, precedence:int, startState:DFAState):
        if not self.precedenceDfa:
            raise IllegalStateException("Only precedence DFAs may contain a precedence start state.")

        if precedence < 0:
            return

        # synchronization on s0 here is ok. when the DFA is turned into a
        # precedence DFA, s0 will be initialized once and not updated again
        # s0.edges is never null for a precedence DFA
        if precedence >= len(self.s0.edges):
            ext = [None] * (precedence + 1 - len(self.s0.edges))
            self.s0.edges.extend(ext)
        self.s0.edges[precedence] = startState
    #
    # Sets whether this is a precedence DFA. If the specified value differs
    # from the current DFA configuration, the following actions are taken;
    # otherwise no changes are made to the current DFA.
    #
    # <ul>
    # <li>The {@link #states} map is cleared</li>
    # <li>If {@code precedenceDfa} is {@code false}, the initial state
    # {@link #s0} is set to {@code null}; otherwise, it is initialized to a new
    # {@link DFAState} with an empty outgoing {@link DFAState#edges} array to
    # store the start states for individual precedence values.</li>
    # <li>The {@link #precedenceDfa} field is updated</li>
    # </ul>
    #
    # @param precedenceDfa {@code true} if this is a precedence DFA; otherwise,
    # {@code false}

    def setPrecedenceDfa(self, precedenceDfa:bool):
        if self.precedenceDfa != precedenceDfa:
            self._states = dict()
            if precedenceDfa:
                precedenceState = DFAState(configs=ATNConfigSet())
                precedenceState.edges = []
                precedenceState.isAcceptState = False
                precedenceState.requiresFullContext = False
                self.s0 = precedenceState
            else:
                self.s0 = None
            self.precedenceDfa = precedenceDfa

    @property
    def states(self):
        return self._states

    # Return a list of all states in this DFA, ordered by state number.
    def sortedStates(self):
        return sorted(self._states.keys(), key=lambda state: state.stateNumber)

    def __str__(self):
        return self.toString(None)

    def toString(self, literalNames:list=None, symbolicNames:list=None):
        if self.s0 is None:
            return ""
        from antlr4.dfa.DFASerializer import DFASerializer
        serializer = DFASerializer(self,literalNames,symbolicNames)
        return str(serializer)

    def toLexerString(self):
        if self.s0 is None:
            return ""
        from antlr4.dfa.DFASerializer import LexerDFASerializer
        serializer = LexerDFASerializer(self)
        return str(serializer)

