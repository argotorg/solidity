#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#/

#
# This class extends {@link BufferedTokenStream} with functionality to filter
# token streams to tokens on a particular channel (tokens where
# {@link Token#getChannel} returns a particular value).
#
# <p>
# This token stream provides access to all tokens by index or when calling
# methods like {@link #getText}. The channel filtering is only used for code
# accessing tokens via the lookahead methods {@link #LA}, {@link #LT}, and
# {@link #LB}.</p>
#
# <p>
# By default, tokens are placed on the default channel
# ({@link Token#DEFAULT_CHANNEL}), but may be reassigned by using the
# {@code ->channel(HIDDEN)} lexer command, or by using an embedded action to
# call {@link Lexer#setChannel}.
# </p>
#
# <p>
# Note: lexer rules which use the {@code ->skip} lexer command or call
# {@link Lexer#skip} do not produce tokens at all, so input text matched by
# such a rule will not be available as part of the token stream, regardless of
# channel.</p>
#/

from antlr4.BufferedTokenStream import BufferedTokenStream
from antlr4.Lexer import Lexer
from antlr4.Token import Token


class CommonTokenStream(BufferedTokenStream):

    def __init__(self, lexer:Lexer, channel:int=Token.DEFAULT_CHANNEL):
        super().__init__(lexer)
        self.channel = channel

    def adjustSeekIndex(self, i:int):
        return self.nextTokenOnChannel(i, self.channel)

    def LB(self, k:int):
        if k==0 or (self.index-k)<0:
            return None
        i = self.index
        n = 1
        # find k good tokens looking backwards
        while n <= k:
            # skip off-channel tokens
            i = self.previousTokenOnChannel(i - 1, self.channel)
            n += 1
        if i < 0:
            return None
        return self.tokens[i]

    def LT(self, k:int):
        self.lazyInit()
        if k == 0:
            return None
        if k < 0:
            return self.LB(-k)
        i = self.index
        n = 1 # we know tokens[pos] is a good one
        # find k good tokens
        while n < k:
            # skip off-channel tokens, but make sure to not look past EOF
            if self.sync(i + 1):
                i = self.nextTokenOnChannel(i + 1, self.channel)
            n += 1
        return self.tokens[i]

    # Count EOF just once.#/
    def getNumberOfOnChannelTokens(self):
        n = 0
        self.fill()
        for i in range(0, len(self.tokens)):
            t = self.tokens[i]
            if t.channel==self.channel:
                n += 1
            if t.type==Token.EOF:
                break
        return n
