#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#

#
# A {@link Token} object representing an entire subtree matched by a parser
# rule; e.g., {@code <expr>}. These tokens are created for {@link TagChunk}
# chunks where the tag corresponds to a parser rule.
#
from antlr4.Token import Token


class RuleTagToken(Token):
   #
    # Constructs a new instance of {@link RuleTagToken} with the specified rule
    # name, bypass token type, and label.
    #
    # @param ruleName The name of the parser rule this rule tag matches.
    # @param bypassTokenType The bypass token type assigned to the parser rule.
    # @param label The label associated with the rule tag, or {@code null} if
    # the rule tag is unlabeled.
    #
    # @exception IllegalArgumentException if {@code ruleName} is {@code null}
    # or empty.

    def __init__(self, ruleName:str, bypassTokenType:int, label:str=None):
        if ruleName is None or len(ruleName)==0:
            raise Exception("ruleName cannot be null or empty.")
        self.source = None
        self.type = bypassTokenType # token type of the token
        self.channel = Token.DEFAULT_CHANNEL # The parser ignores everything not on DEFAULT_CHANNEL
        self.start = -1 # optional; return -1 if not implemented.
        self.stop = -1  # optional; return -1 if not implemented.
        self.tokenIndex = -1 # from 0..n-1 of the token object in the input stream
        self.line = 0 # line=1..n of the 1st character
        self.column = -1 # beginning of the line at which it occurs, 0..n-1
        self.label = label
        self._text = self.getText() # text of the token.

        self.ruleName = ruleName


    def getText(self):
        if self.label is None:
            return "<" + self.ruleName + ">"
        else:
            return "<" + self.label + ":" + self.ruleName + ">"
