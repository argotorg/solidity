# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#/
from uuid import UUID
from io import StringIO
from typing import Callable
from antlr4.Token import Token
from antlr4.atn.ATN import ATN
from antlr4.atn.ATNType import ATNType
from antlr4.atn.ATNState import *
from antlr4.atn.Transition import *
from antlr4.atn.LexerAction import *
from antlr4.atn.ATNDeserializationOptions import ATNDeserializationOptions

# This is the earliest supported serialized UUID.
BASE_SERIALIZED_UUID = UUID("AADB8D7E-AEEF-4415-AD2B-8204D6CF042E")

# This UUID indicates the serialized ATN contains two sets of
# IntervalSets, where the second set's values are encoded as
# 32-bit integers to support the full Unicode SMP range up to U+10FFFF.
ADDED_UNICODE_SMP = UUID("59627784-3BE5-417A-B9EB-8131A7286089")

# This list contains all of the currently supported UUIDs, ordered by when
# the feature first appeared in this branch.
SUPPORTED_UUIDS = [ BASE_SERIALIZED_UUID, ADDED_UNICODE_SMP ]

SERIALIZED_VERSION = 3

# This is the current serialized UUID.
SERIALIZED_UUID = ADDED_UNICODE_SMP

class ATNDeserializer (object):

    def __init__(self, options : ATNDeserializationOptions = None):
        if options is None:
            options = ATNDeserializationOptions.defaultOptions
        self.deserializationOptions = options

    # Determines if a particular serialized representation of an ATN supports
    # a particular feature, identified by the {@link UUID} used for serializing
    # the ATN at the time the feature was first introduced.
    #
    # @param feature The {@link UUID} marking the first time the feature was
    # supported in the serialized ATN.
    # @param actualUuid The {@link UUID} of the actual serialized ATN which is
    # currently being deserialized.
    # @return {@code true} if the {@code actualUuid} value represents a
    # serialized ATN at or after the feature identified by {@code feature} was
    # introduced; otherwise, {@code false}.

    def isFeatureSupported(self, feature : UUID , actualUuid : UUID ):
        idx1 = SUPPORTED_UUIDS.index(feature)
        if idx1<0:
            return False
        idx2 = SUPPORTED_UUIDS.index(actualUuid)
        return idx2 >= idx1

    def deserialize(self, data : str):
        self.reset(data)
        self.checkVersion()
        self.checkUUID()
        atn = self.readATN()
        self.readStates(atn)
        self.readRules(atn)
        self.readModes(atn)
        sets = []
        # First, read all sets with 16-bit Unicode code points <= U+FFFF.
        self.readSets(atn, sets, self.readInt)
        # Next, if the ATN was serialized with the Unicode SMP feature,
        # deserialize sets with 32-bit arguments <= U+10FFFF.
        if self.isFeatureSupported(ADDED_UNICODE_SMP, self.uuid):
            self.readSets(atn, sets, self.readInt32)
        self.readEdges(atn, sets)
        self.readDecisions(atn)
        self.readLexerActions(atn)
        self.markPrecedenceDecisions(atn)
        self.verifyATN(atn)
        if self.deserializationOptions.generateRuleBypassTransitions \
                and atn.grammarType == ATNType.PARSER:
            self.generateRuleBypassTransitions(atn)
            # re-verify after modification
            self.verifyATN(atn)
        return atn

    def reset(self, data:str):
        def adjust(c):
            v = ord(c)
            return v-2 if v>1 else v + 65533
        temp = [ adjust(c) for c in data ]
        # don't adjust the first value since that's the version number
        temp[0] = ord(data[0])
        self.data = temp
        self.pos = 0

    def checkVersion(self):
        version = self.readInt()
        if version != SERIALIZED_VERSION:
            raise Exception("Could not deserialize ATN with version " + str(version) + " (expected " + str(SERIALIZED_VERSION) + ").")

    def checkUUID(self):
        uuid = self.readUUID()
        if not uuid in SUPPORTED_UUIDS:
            raise Exception("Could not deserialize ATN with UUID: " + str(uuid) + \
                            " (expected " + str(SERIALIZED_UUID) + " or a legacy UUID).", uuid, SERIALIZED_UUID)
        self.uuid = uuid

    def readATN(self):
        idx = self.readInt()
        grammarType = ATNType.fromOrdinal(idx)
        maxTokenType = self.readInt()
        return ATN(grammarType, maxTokenType)

    def readStates(self, atn:ATN):
        loopBackStateNumbers = []
        endStateNumbers = []
        nstates = self.readInt()
        for i in range(0, nstates):
            stype = self.readInt()
            # ignore bad type of states
            if stype==ATNState.INVALID_TYPE:
                atn.addState(None)
                continue
            ruleIndex = self.readInt()
            if ruleIndex == 0xFFFF:
                ruleIndex = -1

            s = self.stateFactory(stype, ruleIndex)
            if stype == ATNState.LOOP_END: # special case
                loopBackStateNumber = self.readInt()
                loopBackStateNumbers.append((s, loopBackStateNumber))
            elif isinstance(s, BlockStartState):
                endStateNumber = self.readInt()
                endStateNumbers.append((s, endStateNumber))

            atn.addState(s)

        # delay the assignment of loop back and end states until we know all the state instances have been initialized
        for pair in loopBackStateNumbers:
            pair[0].loopBackState = atn.states[pair[1]]

        for pair in endStateNumbers:
            pair[0].endState = atn.states[pair[1]]

        numNonGreedyStates = self.readInt()
        for i in range(0, numNonGreedyStates):
            stateNumber = self.readInt()
            atn.states[stateNumber].nonGreedy = True

        numPrecedenceStates = self.readInt()
        for i in range(0, numPrecedenceStates):
            stateNumber = self.readInt()
            atn.states[stateNumber].isPrecedenceRule = True

    def readRules(self, atn:ATN):
        nrules = self.readInt()
        if atn.grammarType == ATNType.LEXER:
            atn.ruleToTokenType = [0] * nrules

        atn.ruleToStartState = [0] * nrules
        for i in range(0, nrules):
            s = self.readInt()
            startState = atn.states[s]
            atn.ruleToStartState[i] = startState
            if atn.grammarType == ATNType.LEXER:
                tokenType = self.readInt()
                if tokenType == 0xFFFF:
                    tokenType = Token.EOF

                atn.ruleToTokenType[i] = tokenType

        atn.ruleToStopState = [0] * nrules
        for state in atn.states:
            if not isinstance(state, RuleStopState):
                continue
            atn.ruleToStopState[state.ruleIndex] = state
            atn.ruleToStartState[state.ruleIndex].stopState = state

    def readModes(self, atn:ATN):
        nmodes = self.readInt()
        for i in range(0, nmodes):
            s = self.readInt()
            atn.modeToStartState.append(atn.states[s])

    def readSets(self, atn:ATN, sets:list, readUnicode:Callable[[], int]):
        m = self.readInt()
        for i in range(0, m):
            iset = IntervalSet()
            sets.append(iset)
            n = self.readInt()
            containsEof = self.readInt()
            if containsEof!=0:
                iset.addOne(-1)
            for j in range(0, n):
                i1 = readUnicode()
                i2 = readUnicode()
                iset.addRange(range(i1, i2 + 1)) # range upper limit is exclusive

    def readEdges(self, atn:ATN, sets:list):
        nedges = self.readInt()
        for i in range(0, nedges):
            src = self.readInt()
            trg = self.readInt()
            ttype = self.readInt()
            arg1 = self.readInt()
            arg2 = self.readInt()
            arg3 = self.readInt()
            trans = self.edgeFactory(atn, ttype, src, trg, arg1, arg2, arg3, sets)
            srcState = atn.states[src]
            srcState.addTransition(trans)

        # edges for rule stop states can be derived, so they aren't serialized
        for state in atn.states:
            for i in range(0, len(state.transitions)):
                t = state.transitions[i]
                if not isinstance(t, RuleTransition):
                    continue
                outermostPrecedenceReturn = -1
                if atn.ruleToStartState[t.target.ruleIndex].isPrecedenceRule:
                    if t.precedence == 0:
                        outermostPrecedenceReturn = t.target.ruleIndex
                trans = EpsilonTransition(t.followState, outermostPrecedenceReturn)
                atn.ruleToStopState[t.target.ruleIndex].addTransition(trans)

        for state in atn.states:
            if isinstance(state, BlockStartState):
                # we need to know the end state to set its start state
                if state.endState is None:
                    raise Exception("IllegalState")
                # block end states can only be associated to a single block start state
                if state.endState.startState is not None:
                    raise Exception("IllegalState")
                state.endState.startState = state

            if isinstance(state, PlusLoopbackState):
                for i in range(0, len(state.transitions)):
                    target = state.transitions[i].target
                    if isinstance(target, PlusBlockStartState):
                        target.loopBackState = state
            elif isinstance(state, StarLoopbackState):
                for i in range(0, len(state.transitions)):
                    target = state.transitions[i].target
                    if isinstance(target, StarLoopEntryState):
                        target.loopBackState = state

    def readDecisions(self, atn:ATN):
        ndecisions = self.readInt()
        for i in range(0, ndecisions):
            s = self.readInt()
            decState = atn.states[s]
            atn.decisionToState.append(decState)
            decState.decision = i

    def readLexerActions(self, atn:ATN):
        if atn.grammarType == ATNType.LEXER:
            count = self.readInt()
            atn.lexerActions = [ None ] * count
            for i in range(0, count):
                actionType = self.readInt()
                data1 = self.readInt()
                if data1 == 0xFFFF:
                    data1 = -1
                data2 = self.readInt()
                if data2 == 0xFFFF:
                    data2 = -1
                lexerAction = self.lexerActionFactory(actionType, data1, data2)
                atn.lexerActions[i] = lexerAction

    def generateRuleBypassTransitions(self, atn:ATN):

        count = len(atn.ruleToStartState)
        atn.ruleToTokenType = [ 0 ] * count
        for i in range(0, count):
            atn.ruleToTokenType[i] = atn.maxTokenType + i + 1

        for i in range(0, count):
            self.generateRuleBypassTransition(atn, i)

    def generateRuleBypassTransition(self, atn:ATN, idx:int):

        bypassStart = BasicBlockStartState()
        bypassStart.ruleIndex = idx
        atn.addState(bypassStart)

        bypassStop = BlockEndState()
        bypassStop.ruleIndex = idx
        atn.addState(bypassStop)

        bypassStart.endState = bypassStop
        atn.defineDecisionState(bypassStart)

        bypassStop.startState = bypassStart

        excludeTransition = None

        if atn.ruleToStartState[idx].isPrecedenceRule:
            # wrap from the beginning of the rule to the StarLoopEntryState
            endState = None
            for state in atn.states:
                if self.stateIsEndStateFor(state, idx):
                    endState = state
                    excludeTransition = state.loopBackState.transitions[0]
                    break

            if excludeTransition is None:
                raise Exception("Couldn't identify final state of the precedence rule prefix section.")

        else:

            endState = atn.ruleToStopState[idx]

        # all non-excluded transitions that currently target end state need to target blockEnd instead
        for state in atn.states:
            for transition in state.transitions:
                if transition == excludeTransition:
                    continue
                if transition.target == endState:
                    transition.target = bypassStop

        # all transitions leaving the rule start state need to leave blockStart instead
        ruleToStartState = atn.ruleToStartState[idx]
        count = len(ruleToStartState.transitions)
        while count > 0:
            bypassStart.addTransition(ruleToStartState.transitions[count-1])
            del ruleToStartState.transitions[-1]

        # link the new states
        atn.ruleToStartState[idx].addTransition(EpsilonTransition(bypassStart))
        bypassStop.addTransition(EpsilonTransition(endState))

        matchState = BasicState()
        atn.addState(matchState)
        matchState.addTransition(AtomTransition(bypassStop, atn.ruleToTokenType[idx]))
        bypassStart.addTransition(EpsilonTransition(matchState))


    def stateIsEndStateFor(self, state:ATNState, idx:int):
        if state.ruleIndex != idx:
            return None
        if not isinstance(state, StarLoopEntryState):
            return None

        maybeLoopEndState = state.transitions[len(state.transitions) - 1].target
        if not isinstance(maybeLoopEndState, LoopEndState):
            return None

        if maybeLoopEndState.epsilonOnlyTransitions and \
                isinstance(maybeLoopEndState.transitions[0].target, RuleStopState):
            return state
        else:
            return None


    #
    # Analyze the {@link StarLoopEntryState} states in the specified ATN to set
    # the {@link StarLoopEntryState#isPrecedenceDecision} field to the
    # correct value.
    #
    # @param atn The ATN.
    #
    def markPrecedenceDecisions(self, atn:ATN):
        for state in atn.states:
            if not isinstance(state, StarLoopEntryState):
                continue

            # We analyze the ATN to determine if this ATN decision state is the
            # decision for the closure block that determines whether a
            # precedence rule should continue or complete.
            #
            if atn.ruleToStartState[state.ruleIndex].isPrecedenceRule:
                maybeLoopEndState = state.transitions[len(state.transitions) - 1].target
                if isinstance(maybeLoopEndState, LoopEndState):
                    if maybeLoopEndState.epsilonOnlyTransitions and \
                            isinstance(maybeLoopEndState.transitions[0].target, RuleStopState):
                        state.isPrecedenceDecision = True

    def verifyATN(self, atn:ATN):
        if not self.deserializationOptions.verifyATN:
            return
        # verify assumptions
        for state in atn.states:
            if state is None:
                continue

            self.checkCondition(state.epsilonOnlyTransitions or len(state.transitions) <= 1)

            if isinstance(state, PlusBlockStartState):
                self.checkCondition(state.loopBackState is not None)

            if isinstance(state, StarLoopEntryState):
                self.checkCondition(state.loopBackState is not None)
                self.checkCondition(len(state.transitions) == 2)

                if isinstance(state.transitions[0].target, StarBlockStartState):
                    self.checkCondition(isinstance(state.transitions[1].target, LoopEndState))
                    self.checkCondition(not state.nonGreedy)
                elif isinstance(state.transitions[0].target, LoopEndState):
                    self.checkCondition(isinstance(state.transitions[1].target, StarBlockStartState))
                    self.checkCondition(state.nonGreedy)
                else:
                    raise Exception("IllegalState")

            if isinstance(state, StarLoopbackState):
                self.checkCondition(len(state.transitions) == 1)
                self.checkCondition(isinstance(state.transitions[0].target, StarLoopEntryState))

            if isinstance(state, LoopEndState):
                self.checkCondition(state.loopBackState is not None)

            if isinstance(state, RuleStartState):
                self.checkCondition(state.stopState is not None)

            if isinstance(state, BlockStartState):
                self.checkCondition(state.endState is not None)

            if isinstance(state, BlockEndState):
                self.checkCondition(state.startState is not None)

            if isinstance(state, DecisionState):
                self.checkCondition(len(state.transitions) <= 1 or state.decision >= 0)
            else:
                self.checkCondition(len(state.transitions) <= 1 or isinstance(state, RuleStopState))

    def checkCondition(self, condition:bool, message=None):
        if not condition:
            if message is None:
                message = "IllegalState"
            raise Exception(message)

    def readInt(self):
        i = self.data[self.pos]
        self.pos += 1
        return i

    def readInt32(self):
        low = self.readInt()
        high = self.readInt()
        return low | (high << 16)

    def readLong(self):
        low = self.readInt32()
        high = self.readInt32()
        return (low & 0x00000000FFFFFFFF) | (high << 32)

    def readUUID(self):
        low = self.readLong()
        high = self.readLong()
        allBits = (low & 0xFFFFFFFFFFFFFFFF) | (high << 64)
        return UUID(int=allBits)

    edgeFactories = [ lambda args : None,
                      lambda atn, src, trg, arg1, arg2, arg3, sets, target : EpsilonTransition(target),
                      lambda atn, src, trg, arg1, arg2, arg3, sets, target : \
                        RangeTransition(target, Token.EOF, arg2) if arg3 != 0 else RangeTransition(target, arg1, arg2),
                      lambda atn, src, trg, arg1, arg2, arg3, sets, target : \
                        RuleTransition(atn.states[arg1], arg2, arg3, target),
                      lambda atn, src, trg, arg1, arg2, arg3, sets, target : \
                        PredicateTransition(target, arg1, arg2, arg3 != 0),
                      lambda atn, src, trg, arg1, arg2, arg3, sets, target : \
                        AtomTransition(target, Token.EOF) if arg3 != 0 else AtomTransition(target, arg1),
                      lambda atn, src, trg, arg1, arg2, arg3, sets, target : \
                        ActionTransition(target, arg1, arg2, arg3 != 0),
                      lambda atn, src, trg, arg1, arg2, arg3, sets, target : \
                        SetTransition(target, sets[arg1]),
                      lambda atn, src, trg, arg1, arg2, arg3, sets, target : \
                        NotSetTransition(target, sets[arg1]),
                      lambda atn, src, trg, arg1, arg2, arg3, sets, target : \
                        WildcardTransition(target),
                      lambda atn, src, trg, arg1, arg2, arg3, sets, target : \
                        PrecedencePredicateTransition(target, arg1)
                      ]

    def edgeFactory(self, atn:ATN, type:int, src:int, trg:int, arg1:int, arg2:int, arg3:int, sets:list):
        target = atn.states[trg]
        if type > len(self.edgeFactories) or self.edgeFactories[type] is None:
            raise Exception("The specified transition type: " + str(type) + " is not valid.")
        else:
            return self.edgeFactories[type](atn, src, trg, arg1, arg2, arg3, sets, target)

    stateFactories = [  lambda : None,
                        lambda : BasicState(),
                        lambda : RuleStartState(),
                        lambda : BasicBlockStartState(),
                        lambda : PlusBlockStartState(),
                        lambda : StarBlockStartState(),
                        lambda : TokensStartState(),
                        lambda : RuleStopState(),
                        lambda : BlockEndState(),
                        lambda : StarLoopbackState(),
                        lambda : StarLoopEntryState(),
                        lambda : PlusLoopbackState(),
                        lambda : LoopEndState()
                    ]

    def stateFactory(self, type:int, ruleIndex:int):
        if type> len(self.stateFactories) or self.stateFactories[type] is None:
            raise Exception("The specified state type " + str(type) + " is not valid.")
        else:
            s = self.stateFactories[type]()
            if s is not None:
                s.ruleIndex = ruleIndex
        return s

    CHANNEL = 0     #The type of a {@link LexerChannelAction} action.
    CUSTOM = 1      #The type of a {@link LexerCustomAction} action.
    MODE = 2        #The type of a {@link LexerModeAction} action.
    MORE = 3        #The type of a {@link LexerMoreAction} action.
    POP_MODE = 4    #The type of a {@link LexerPopModeAction} action.
    PUSH_MODE = 5   #The type of a {@link LexerPushModeAction} action.
    SKIP = 6        #The type of a {@link LexerSkipAction} action.
    TYPE = 7        #The type of a {@link LexerTypeAction} action.

    actionFactories = [ lambda data1, data2: LexerChannelAction(data1),
                        lambda data1, data2: LexerCustomAction(data1, data2),
                        lambda data1, data2: LexerModeAction(data1),
                        lambda data1, data2: LexerMoreAction.INSTANCE,
                        lambda data1, data2: LexerPopModeAction.INSTANCE,
                        lambda data1, data2: LexerPushModeAction(data1),
                        lambda data1, data2: LexerSkipAction.INSTANCE,
                        lambda data1, data2: LexerTypeAction(data1)
                      ]

    def lexerActionFactory(self, type:int, data1:int, data2:int):

        if type > len(self.actionFactories) or self.actionFactories[type] is None:
            raise Exception("The specified lexer action type " + str(type) + " is not valid.")
        else:
            return self.actionFactories[type](data1, data2)
