from antlr4 import *


class LexerAdaptor(Lexer):

    """
      Track whether we are inside of a rule and whether it is lexical parser. _currentRuleType==Token.INVALID_TYPE
      means that we are outside of a rule. At the first sign of a rule name reference and _currentRuleType==invalid, we
      can assume that we are starting a parser rule. Similarly, seeing a token reference when not already in rule means
      starting a token rule. The terminating ';' of a rule, flips this back to invalid type.
      This is not perfect logic but works. For example, "grammar T;" means that we start and stop a lexical rule for
      the "T;". Dangerous but works.
      The whole point of this state information is to distinguish between [..arg actions..] and [charsets]. Char sets
      can only occur in lexical rules and arg actions cannot occur.
    """

    _currentRuleType = Token.INVALID_TYPE

    def __init__(self, inp, output):
        Lexer.__init__(self, inp, output)

    def getCurrentRuleType(self):
        return self._currentRuleType

    def setCurrentRuleType(self, ruleType):
        self._currentRuleType = ruleType

    def handleBeginArgument(self):
        if self.inLexerRule():
            self.pushMode(self.LexerCharSet)
            self.more()
        else:
            self.pushMode(self.Argument)

    def handleEndArgument(self):
        self.popMode()
        if len(self._modeStack) > 0:
            self._type = self.ARGUMENT_CONTENT

    def handleEndAction(self):
        self.popMode()
        if len(self._modeStack) > 0:
            self._type = self.ACTION_CONTENT

    def emit(self):
        if self._type == self.ID:
            firstChar = self._input.getText(self._tokenStartCharIndex, self._tokenStartCharIndex)
            if firstChar[0].isupper():
                self._type = self.TOKEN_REF
            else:
                self._type = self.RULE_REF

            if self._currentRuleType == Token.INVALID_TYPE:  # if outside of rule def
                self._currentRuleType = self._type  # set to inside lexer or parser rule

        elif self._type == self.SEMI:  # exit rule def
            self._currentRuleType = Token.INVALID_TYPE
        return Lexer.emit(self)

    def inLexerRule(self):
        return self._currentRuleType == self.TOKEN_REF

    def inParserRule(self):  # not used, but added for clarity
        return self._currentRuleType == self.RULE_REF
