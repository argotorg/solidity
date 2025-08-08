#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
 #

from enum import IntEnum

# need forward declaration
Lexer = None


class LexerActionType(IntEnum):

    CHANNEL = 0     #The type of a {@link LexerChannelAction} action.
    CUSTOM = 1      #The type of a {@link LexerCustomAction} action.
    MODE = 2        #The type of a {@link LexerModeAction} action.
    MORE = 3        #The type of a {@link LexerMoreAction} action.
    POP_MODE = 4    #The type of a {@link LexerPopModeAction} action.
    PUSH_MODE = 5   #The type of a {@link LexerPushModeAction} action.
    SKIP = 6        #The type of a {@link LexerSkipAction} action.
    TYPE = 7        #The type of a {@link LexerTypeAction} action.

class LexerAction(object):

    def __init__(self, action:LexerActionType):
        self.actionType = action
        self.isPositionDependent = False

    def __hash__(self):
        return hash(self.actionType)

    def __eq__(self, other):
        return self is other


#
# Implements the {@code skip} lexer action by calling {@link Lexer#skip}.
#
# <p>The {@code skip} command does not have any parameters, so this action is
# implemented as a singleton instance exposed by {@link #INSTANCE}.</p>
class LexerSkipAction(LexerAction ):

    # Provides a singleton instance of this parameterless lexer action.
    INSTANCE = None

    def __init__(self):
        super().__init__(LexerActionType.SKIP)

    def execute(self, lexer:Lexer):
        lexer.skip()

    def __str__(self):
        return "skip"

LexerSkipAction.INSTANCE = LexerSkipAction()

#  Implements the {@code type} lexer action by calling {@link Lexer#setType}
# with the assigned type.
class LexerTypeAction(LexerAction):

    def __init__(self, type:int):
        super().__init__(LexerActionType.TYPE)
        self.type = type

    def execute(self, lexer:Lexer):
        lexer.type = self.type

    def __hash__(self):
        return hash((self.actionType, self.type))

    def __eq__(self, other):
        if self is other:
            return True
        elif not isinstance(other, LexerTypeAction):
            return False
        else:
            return self.type == other.type

    def __str__(self):
        return "type(" + str(self.type) + ")"


# Implements the {@code pushMode} lexer action by calling
# {@link Lexer#pushMode} with the assigned mode.
class LexerPushModeAction(LexerAction):

    def __init__(self, mode:int):
        super().__init__(LexerActionType.PUSH_MODE)
        self.mode = mode

    # <p>This action is implemented by calling {@link Lexer#pushMode} with the
    # value provided by {@link #getMode}.</p>
    def execute(self, lexer:Lexer):
        lexer.pushMode(self.mode)

    def __hash__(self):
        return hash((self.actionType, self.mode))

    def __eq__(self, other):
        if self is other:
            return True
        elif not isinstance(other, LexerPushModeAction):
            return False
        else:
            return self.mode == other.mode

    def __str__(self):
        return "pushMode(" + str(self.mode) + ")"


# Implements the {@code popMode} lexer action by calling {@link Lexer#popMode}.
#
# <p>The {@code popMode} command does not have any parameters, so this action is
# implemented as a singleton instance exposed by {@link #INSTANCE}.</p>
class LexerPopModeAction(LexerAction):

    INSTANCE = None

    def __init__(self):
        super().__init__(LexerActionType.POP_MODE)

    # <p>This action is implemented by calling {@link Lexer#popMode}.</p>
    def execute(self, lexer:Lexer):
        lexer.popMode()

    def __str__(self):
        return "popMode"

LexerPopModeAction.INSTANCE = LexerPopModeAction()

# Implements the {@code more} lexer action by calling {@link Lexer#more}.
#
# <p>The {@code more} command does not have any parameters, so this action is
# implemented as a singleton instance exposed by {@link #INSTANCE}.</p>
class LexerMoreAction(LexerAction):

    INSTANCE = None

    def __init__(self):
        super().__init__(LexerActionType.MORE)

    # <p>This action is implemented by calling {@link Lexer#popMode}.</p>
    def execute(self, lexer:Lexer):
        lexer.more()

    def __str__(self):
        return "more"

LexerMoreAction.INSTANCE = LexerMoreAction()

# Implements the {@code mode} lexer action by calling {@link Lexer#mode} with
# the assigned mode.
class LexerModeAction(LexerAction):

    def __init__(self, mode:int):
        super().__init__(LexerActionType.MODE)
        self.mode = mode

    # <p>This action is implemented by calling {@link Lexer#mode} with the
    # value provided by {@link #getMode}.</p>
    def execute(self, lexer:Lexer):
        lexer.mode(self.mode)

    def __hash__(self):
        return hash((self.actionType, self.mode))

    def __eq__(self, other):
        if self is other:
            return True
        elif not isinstance(other, LexerModeAction):
            return False
        else:
            return self.mode == other.mode

    def __str__(self):
        return "mode(" + str(self.mode) + ")"

# Executes a custom lexer action by calling {@link Recognizer#action} with the
# rule and action indexes assigned to the custom action. The implementation of
# a custom action is added to the generated code for the lexer in an override
# of {@link Recognizer#action} when the grammar is compiled.
#
# <p>This class may represent embedded actions created with the <code>{...}</code>
# syntax in ANTLR 4, as well as actions created for lexer commands where the
# command argument could not be evaluated when the grammar was compiled.</p>

class LexerCustomAction(LexerAction):

    # Constructs a custom lexer action with the specified rule and action
    # indexes.
    #
    # @param ruleIndex The rule index to use for calls to
    # {@link Recognizer#action}.
    # @param actionIndex The action index to use for calls to
    # {@link Recognizer#action}.
    #/
    def __init__(self, ruleIndex:int, actionIndex:int):
        super().__init__(LexerActionType.CUSTOM)
        self.ruleIndex = ruleIndex
        self.actionIndex = actionIndex
        self.isPositionDependent = True

    # <p>Custom actions are implemented by calling {@link Lexer#action} with the
    # appropriate rule and action indexes.</p>
    def execute(self, lexer:Lexer):
        lexer.action(None, self.ruleIndex, self.actionIndex)

    def __hash__(self):
        return hash((self.actionType, self.ruleIndex, self.actionIndex))

    def __eq__(self, other):
        if self is other:
            return True
        elif not isinstance(other, LexerCustomAction):
            return False
        else:
            return self.ruleIndex == other.ruleIndex and self.actionIndex == other.actionIndex

# Implements the {@code channel} lexer action by calling
# {@link Lexer#setChannel} with the assigned channel.
class LexerChannelAction(LexerAction):

    # Constructs a new {@code channel} action with the specified channel value.
    # @param channel The channel value to pass to {@link Lexer#setChannel}.
    def __init__(self, channel:int):
        super().__init__(LexerActionType.CHANNEL)
        self.channel = channel

    # <p>This action is implemented by calling {@link Lexer#setChannel} with the
    # value provided by {@link #getChannel}.</p>
    def execute(self, lexer:Lexer):
        lexer._channel = self.channel

    def __hash__(self):
        return hash((self.actionType, self.channel))

    def __eq__(self, other):
        if self is other:
            return True
        elif not isinstance(other, LexerChannelAction):
            return False
        else:
            return self.channel == other.channel

    def __str__(self):
        return "channel(" + str(self.channel) + ")"

# This implementation of {@link LexerAction} is used for tracking input offsets
# for position-dependent actions within a {@link LexerActionExecutor}.
#
# <p>This action is not serialized as part of the ATN, and is only required for
# position-dependent lexer actions which appear at a location other than the
# end of a rule. For more information about DFA optimizations employed for
# lexer actions, see {@link LexerActionExecutor#append} and
# {@link LexerActionExecutor#fixOffsetBeforeMatch}.</p>
class LexerIndexedCustomAction(LexerAction):

    # Constructs a new indexed custom action by associating a character offset
    # with a {@link LexerAction}.
    #
    # <p>Note: This class is only required for lexer actions for which
    # {@link LexerAction#isPositionDependent} returns {@code true}.</p>
    #
    # @param offset The offset into the input {@link CharStream}, relative to
    # the token start index, at which the specified lexer action should be
    # executed.
    # @param action The lexer action to execute at a particular offset in the
    # input {@link CharStream}.
    def __init__(self, offset:int, action:LexerAction):
        super().__init__(action.actionType)
        self.offset = offset
        self.action = action
        self.isPositionDependent = True

    # <p>This method calls {@link #execute} on the result of {@link #getAction}
    # using the provided {@code lexer}.</p>
    def execute(self, lexer:Lexer):
        # assume the input stream position was properly set by the calling code
        self.action.execute(lexer)

    def __hash__(self):
        return hash((self.actionType, self.offset, self.action))

    def __eq__(self, other):
        if self is other:
            return True
        elif not isinstance(other, LexerIndexedCustomAction):
            return False
        else:
            return self.offset == other.offset and self.action == other.action
