#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#/

# Represents an executor for a sequence of lexer actions which traversed during
# the matching operation of a lexer rule (token).
#
# <p>The executor tracks position information for position-dependent lexer actions
# efficiently, ensuring that actions appearing only at the end of the rule do
# not cause bloating of the {@link DFA} created for the lexer.</p>


from antlr4.InputStream import InputStream
from antlr4.atn.LexerAction import LexerAction, LexerIndexedCustomAction

# need a forward declaration
Lexer = None
LexerActionExecutor = None

class LexerActionExecutor(object):

    def __init__(self, lexerActions:list=list()):
        self.lexerActions = lexerActions
        # Caches the result of {@link #hashCode} since the hash code is an element
        # of the performance-critical {@link LexerATNConfig#hashCode} operation.
        self.hashCode = hash("".join([str(la) for la in lexerActions]))


    # Creates a {@link LexerActionExecutor} which executes the actions for
    # the input {@code lexerActionExecutor} followed by a specified
    # {@code lexerAction}.
    #
    # @param lexerActionExecutor The executor for actions already traversed by
    # the lexer while matching a token within a particular
    # {@link LexerATNConfig}. If this is {@code null}, the method behaves as
    # though it were an empty executor.
    # @param lexerAction The lexer action to execute after the actions
    # specified in {@code lexerActionExecutor}.
    #
    # @return A {@link LexerActionExecutor} for executing the combine actions
    # of {@code lexerActionExecutor} and {@code lexerAction}.
    @staticmethod
    def append(lexerActionExecutor:LexerActionExecutor , lexerAction:LexerAction ):
        if lexerActionExecutor is None:
            return LexerActionExecutor([ lexerAction ])

        lexerActions = lexerActionExecutor.lexerActions + [ lexerAction ]
        return LexerActionExecutor(lexerActions)

    # Creates a {@link LexerActionExecutor} which encodes the current offset
    # for position-dependent lexer actions.
    #
    # <p>Normally, when the executor encounters lexer actions where
    # {@link LexerAction#isPositionDependent} returns {@code true}, it calls
    # {@link IntStream#seek} on the input {@link CharStream} to set the input
    # position to the <em>end</em> of the current token. This behavior provides
    # for efficient DFA representation of lexer actions which appear at the end
    # of a lexer rule, even when the lexer rule matches a variable number of
    # characters.</p>
    #
    # <p>Prior to traversing a match transition in the ATN, the current offset
    # from the token start index is assigned to all position-dependent lexer
    # actions which have not already been assigned a fixed offset. By storing
    # the offsets relative to the token start index, the DFA representation of
    # lexer actions which appear in the middle of tokens remains efficient due
    # to sharing among tokens of the same length, regardless of their absolute
    # position in the input stream.</p>
    #
    # <p>If the current executor already has offsets assigned to all
    # position-dependent lexer actions, the method returns {@code this}.</p>
    #
    # @param offset The current offset to assign to all position-dependent
    # lexer actions which do not already have offsets assigned.
    #
    # @return A {@link LexerActionExecutor} which stores input stream offsets
    # for all position-dependent lexer actions.
    #/
    def fixOffsetBeforeMatch(self, offset:int):
        updatedLexerActions = None
        for i in range(0, len(self.lexerActions)):
            if self.lexerActions[i].isPositionDependent and not isinstance(self.lexerActions[i], LexerIndexedCustomAction):
                if updatedLexerActions is None:
                    updatedLexerActions = [ la for la in self.lexerActions ]
                updatedLexerActions[i] = LexerIndexedCustomAction(offset, self.lexerActions[i])

        if updatedLexerActions is None:
            return self
        else:
            return LexerActionExecutor(updatedLexerActions)


    # Execute the actions encapsulated by this executor within the context of a
    # particular {@link Lexer}.
    #
    # <p>This method calls {@link IntStream#seek} to set the position of the
    # {@code input} {@link CharStream} prior to calling
    # {@link LexerAction#execute} on a position-dependent action. Before the
    # method returns, the input position will be restored to the same position
    # it was in when the method was invoked.</p>
    #
    # @param lexer The lexer instance.
    # @param input The input stream which is the source for the current token.
    # When this method is called, the current {@link IntStream#index} for
    # {@code input} should be the start of the following token, i.e. 1
    # character past the end of the current token.
    # @param startIndex The token start index. This value may be passed to
    # {@link IntStream#seek} to set the {@code input} position to the beginning
    # of the token.
    #/
    def execute(self, lexer:Lexer, input:InputStream, startIndex:int):
        requiresSeek = False
        stopIndex = input.index
        try:
            for lexerAction in self.lexerActions:
                if isinstance(lexerAction, LexerIndexedCustomAction):
                    offset = lexerAction.offset
                    input.seek(startIndex + offset)
                    lexerAction = lexerAction.action
                    requiresSeek = (startIndex + offset) != stopIndex
                elif lexerAction.isPositionDependent:
                    input.seek(stopIndex)
                    requiresSeek = False
                lexerAction.execute(lexer)
        finally:
            if requiresSeek:
                input.seek(stopIndex)

    def __hash__(self):
        return self.hashCode

    def __eq__(self, other):
        if self is other:
            return True
        elif not isinstance(other, LexerActionExecutor):
            return False
        else:
            return self.hashCode == other.hashCode \
                and self.lexerActions == other.lexerActions

del Lexer