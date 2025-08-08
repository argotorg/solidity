#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#

# The following images show the relation of states and
# {@link ATNState#transitions} for various grammar constructs.
#
# <ul>
#
# <li>Solid edges marked with an &#0949; indicate a required
# {@link EpsilonTransition}.</li>
#
# <li>Dashed edges indicate locations where any transition derived from
# {@link Transition} might appear.</li>
#
# <li>Dashed nodes are place holders for either a sequence of linked
# {@link BasicState} states or the inclusion of a block representing a nested
# construct in one of the forms below.</li>
#
# <li>Nodes showing multiple outgoing alternatives with a {@code ...} support
# any number of alternatives (one or more). Nodes without the {@code ...} only
# support the exact number of alternatives shown in the diagram.</li>
#
# </ul>
#
# <h2>Basic Blocks</h2>
#
# <h3>Rule</h3>
#
# <embed src="images/Rule.svg" type="image/svg+xml"/>
#
# <h3>Block of 1 or more alternatives</h3>
#
# <embed src="images/Block.svg" type="image/svg+xml"/>
#
# <h2>Greedy Loops</h2>
#
# <h3>Greedy Closure: {@code (...)*}</h3>
#
# <embed src="images/ClosureGreedy.svg" type="image/svg+xml"/>
#
# <h3>Greedy Positive Closure: {@code (...)+}</h3>
#
# <embed src="images/PositiveClosureGreedy.svg" type="image/svg+xml"/>
#
# <h3>Greedy Optional: {@code (...)?}</h3>
#
# <embed src="images/OptionalGreedy.svg" type="image/svg+xml"/>
#
# <h2>Non-Greedy Loops</h2>
#
# <h3>Non-Greedy Closure: {@code (...)*?}</h3>
#
# <embed src="images/ClosureNonGreedy.svg" type="image/svg+xml"/>
#
# <h3>Non-Greedy Positive Closure: {@code (...)+?}</h3>
#
# <embed src="images/PositiveClosureNonGreedy.svg" type="image/svg+xml"/>
#
# <h3>Non-Greedy Optional: {@code (...)??}</h3>
#
# <embed src="images/OptionalNonGreedy.svg" type="image/svg+xml"/>
#

from antlr4.atn.Transition import Transition

INITIAL_NUM_TRANSITIONS = 4

class ATNState(object):

    # constants for serialization
    INVALID_TYPE = 0
    BASIC = 1
    RULE_START = 2
    BLOCK_START = 3
    PLUS_BLOCK_START = 4
    STAR_BLOCK_START = 5
    TOKEN_START = 6
    RULE_STOP = 7
    BLOCK_END = 8
    STAR_LOOP_BACK = 9
    STAR_LOOP_ENTRY = 10
    PLUS_LOOP_BACK = 11
    LOOP_END = 12

    serializationNames = [
            "INVALID",
            "BASIC",
            "RULE_START",
            "BLOCK_START",
            "PLUS_BLOCK_START",
            "STAR_BLOCK_START",
            "TOKEN_START",
            "RULE_STOP",
            "BLOCK_END",
            "STAR_LOOP_BACK",
            "STAR_LOOP_ENTRY",
            "PLUS_LOOP_BACK",
            "LOOP_END" ]

    INVALID_STATE_NUMBER = -1

    def __init__(self):
        # Which ATN are we in?
        self.atn = None
        self.stateNumber = ATNState.INVALID_STATE_NUMBER
        self.stateType = None
        self.ruleIndex = 0 # at runtime, we don't have Rule objects
        self.epsilonOnlyTransitions = False
        # Track the transitions emanating from this ATN state.
        self.transitions = []
        # Used to cache lookahead during parsing, not used during construction
        self.nextTokenWithinRule = None

    def __hash__(self):
        return self.stateNumber

    def __eq__(self, other):
        return isinstance(other, ATNState) and self.stateNumber==other.stateNumber

    def onlyHasEpsilonTransitions(self):
        return self.epsilonOnlyTransitions

    def isNonGreedyExitState(self):
        return False

    def __str__(self):
        return str(self.stateNumber)

    def addTransition(self, trans:Transition, index:int=-1):
        if len(self.transitions)==0:
            self.epsilonOnlyTransitions = trans.isEpsilon
        elif self.epsilonOnlyTransitions != trans.isEpsilon:
            self.epsilonOnlyTransitions = False
            # TODO System.err.format(Locale.getDefault(), "ATN state %d has both epsilon and non-epsilon transitions.\n", stateNumber);
        if index==-1:
            self.transitions.append(trans)
        else:
            self.transitions.insert(index, trans)

class BasicState(ATNState):

    def __init__(self):
        super().__init__()
        self.stateType = self.BASIC


class DecisionState(ATNState):

    def __init__(self):
        super().__init__()
        self.decision = -1
        self.nonGreedy = False

#  The start of a regular {@code (...)} block.
class BlockStartState(DecisionState):

    def __init__(self):
        super().__init__()
        self.endState = None

class BasicBlockStartState(BlockStartState):

    def __init__(self):
        super().__init__()
        self.stateType = self.BLOCK_START

# Terminal node of a simple {@code (a|b|c)} block.
class BlockEndState(ATNState):

    def __init__(self):
        super().__init__()
        self.stateType = self.BLOCK_END
        self.startState = None

# The last node in the ATN for a rule, unless that rule is the start symbol.
#  In that case, there is one transition to EOF. Later, we might encode
#  references to all calls to this rule to compute FOLLOW sets for
#  error handling.
#
class RuleStopState(ATNState):

    def __init__(self):
        super().__init__()
        self.stateType = self.RULE_STOP

class RuleStartState(ATNState):

    def __init__(self):
        super().__init__()
        self.stateType = self.RULE_START
        self.stopState = None
        self.isPrecedenceRule = False

# Decision state for {@code A+} and {@code (A|B)+}.  It has two transitions:
#  one to the loop back to start of the block and one to exit.
#
class PlusLoopbackState(DecisionState):

    def __init__(self):
        super().__init__()
        self.stateType = self.PLUS_LOOP_BACK

# Start of {@code (A|B|...)+} loop. Technically a decision state, but
#  we don't use for code generation; somebody might need it, so I'm defining
#  it for completeness. In reality, the {@link PlusLoopbackState} node is the
#  real decision-making note for {@code A+}.
#
class PlusBlockStartState(BlockStartState):

    def __init__(self):
        super().__init__()
        self.stateType = self.PLUS_BLOCK_START
        self.loopBackState = None

# The block that begins a closure loop.
class StarBlockStartState(BlockStartState):

    def __init__(self):
        super().__init__()
        self.stateType = self.STAR_BLOCK_START

class StarLoopbackState(ATNState):

    def __init__(self):
        super().__init__()
        self.stateType = self.STAR_LOOP_BACK


class StarLoopEntryState(DecisionState):

    def __init__(self):
        super().__init__()
        self.stateType = self.STAR_LOOP_ENTRY
        self.loopBackState = None
        # Indicates whether this state can benefit from a precedence DFA during SLL decision making.
        self.isPrecedenceDecision = None

# Mark the end of a * or + loop.
class LoopEndState(ATNState):

    def __init__(self):
        super().__init__()
        self.stateType = self.LOOP_END
        self.loopBackState = None

# The Tokens rule start state linking to each lexer rule start state */
class TokensStartState(DecisionState):

    def __init__(self):
        super().__init__()
        self.stateType = self.TOKEN_START
