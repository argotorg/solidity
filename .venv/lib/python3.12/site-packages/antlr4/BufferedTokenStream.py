#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.

# This implementation of {@link TokenStream} loads tokens from a
# {@link TokenSource} on-demand, and places the tokens in a buffer to provide
# access to any previous token by index.
#
# <p>
# This token stream ignores the value of {@link Token#getChannel}. If your
# parser requires the token stream filter tokens to only those on a particular
# channel, such as {@link Token#DEFAULT_CHANNEL} or
# {@link Token#HIDDEN_CHANNEL}, use a filtering token stream such a
# {@link CommonTokenStream}.</p>
from io import StringIO
from antlr4.Token import Token
from antlr4.error.Errors import IllegalStateException

# need forward declaration
Lexer = None

# this is just to keep meaningful parameter types to Parser
class TokenStream(object):

    pass


class BufferedTokenStream(TokenStream):

    def __init__(self, tokenSource:Lexer):
        # The {@link TokenSource} from which tokens for this stream are fetched.
        self.tokenSource = tokenSource

        # A collection of all tokens fetched from the token source. The list is
        # considered a complete view of the input once {@link #fetchedEOF} is set
        # to {@code true}.
        self.tokens = []

        # The index into {@link #tokens} of the current token (next token to
        # {@link #consume}). {@link #tokens}{@code [}{@link #p}{@code ]} should be
        # {@link #LT LT(1)}.
        #
        # <p>This field is set to -1 when the stream is first constructed or when
        # {@link #setTokenSource} is called, indicating that the first token has
        # not yet been fetched from the token source. For additional information,
        # see the documentation of {@link IntStream} for a description of
        # Initializing Methods.</p>
        self.index = -1

        # Indicates whether the {@link Token#EOF} token has been fetched from
        # {@link #tokenSource} and added to {@link #tokens}. This field improves
        # performance for the following cases:
        #
        # <ul>
        # <li>{@link #consume}: The lookahead check in {@link #consume} to prevent
        # consuming the EOF symbol is optimized by checking the values of
        # {@link #fetchedEOF} and {@link #p} instead of calling {@link #LA}.</li>
        # <li>{@link #fetch}: The check to prevent adding multiple EOF symbols into
        # {@link #tokens} is trivial with this field.</li>
        # <ul>
        self.fetchedEOF = False

    def mark(self):
        return 0

    def release(self, marker:int):
        # no resources to release
        pass

    def reset(self):
        self.seek(0)

    def seek(self, index:int):
        self.lazyInit()
        self.index = self.adjustSeekIndex(index)

    def get(self, index:int):
        self.lazyInit()
        return self.tokens[index]

    def consume(self):
        skipEofCheck = False
        if self.index >= 0:
            if self.fetchedEOF:
                # the last token in tokens is EOF. skip check if p indexes any
                # fetched token except the last.
                skipEofCheck = self.index < len(self.tokens) - 1
            else:
               # no EOF token in tokens. skip check if p indexes a fetched token.
                skipEofCheck = self.index < len(self.tokens)
        else:
            # not yet initialized
            skipEofCheck = False

        if not skipEofCheck and self.LA(1) == Token.EOF:
            raise IllegalStateException("cannot consume EOF")

        if self.sync(self.index + 1):
            self.index = self.adjustSeekIndex(self.index + 1)

    # Make sure index {@code i} in tokens has a token.
    #
    # @return {@code true} if a token is located at index {@code i}, otherwise
    #    {@code false}.
    # @see #get(int i)
    #/
    def sync(self, i:int):
        n = i - len(self.tokens) + 1 # how many more elements we need?
        if n > 0 :
            fetched = self.fetch(n)
            return fetched >= n
        return True

    # Add {@code n} elements to buffer.
    #
    # @return The actual number of elements added to the buffer.
    #/
    def fetch(self, n:int):
        if self.fetchedEOF:
            return 0
        for i in range(0, n):
            t = self.tokenSource.nextToken()
            t.tokenIndex = len(self.tokens)
            self.tokens.append(t)
            if t.type==Token.EOF:
                self.fetchedEOF = True
                return i + 1
        return n


    # Get all tokens from start..stop inclusively#/
    def getTokens(self, start:int, stop:int, types:set=None):
        if start<0 or stop<0:
            return None
        self.lazyInit()
        subset = []
        if stop >= len(self.tokens):
            stop = len(self.tokens)-1
        for i in range(start, stop):
            t = self.tokens[i]
            if t.type==Token.EOF:
                break
            if types is None or t.type in types:
                subset.append(t)
        return subset

    def LA(self, i:int):
        return self.LT(i).type

    def LB(self, k:int):
        if (self.index-k) < 0:
            return None
        return self.tokens[self.index-k]

    def LT(self, k:int):
        self.lazyInit()
        if k==0:
            return None
        if k < 0:
            return self.LB(-k)
        i = self.index + k - 1
        self.sync(i)
        if i >= len(self.tokens): # return EOF token
            # EOF must be last token
            return self.tokens[len(self.tokens)-1]
        return self.tokens[i]

    # Allowed derived classes to modify the behavior of operations which change
    # the current stream position by adjusting the target token index of a seek
    # operation. The default implementation simply returns {@code i}. If an
    # exception is thrown in this method, the current stream index should not be
    # changed.
    #
    # <p>For example, {@link CommonTokenStream} overrides this method to ensure that
    # the seek target is always an on-channel token.</p>
    #
    # @param i The target token index.
    # @return The adjusted target token index.

    def adjustSeekIndex(self, i:int):
        return i

    def lazyInit(self):
        if self.index == -1:
            self.setup()

    def setup(self):
        self.sync(0)
        self.index = self.adjustSeekIndex(0)

    # Reset this token stream by setting its token source.#/
    def setTokenSource(self, tokenSource:Lexer):
        self.tokenSource = tokenSource
        self.tokens = []
        self.index = -1
        self.fetchedEOF = False


    # Given a starting index, return the index of the next token on channel.
    #  Return i if tokens[i] is on channel.  Return -1 if there are no tokens
    #  on channel between i and EOF.
    #/
    def nextTokenOnChannel(self, i:int, channel:int):
        self.sync(i)
        if i>=len(self.tokens):
            return -1
        token = self.tokens[i]
        while token.channel!=channel:
            if token.type==Token.EOF:
                return -1
            i += 1
            self.sync(i)
            token = self.tokens[i]
        return i

    # Given a starting index, return the index of the previous token on channel.
    #  Return i if tokens[i] is on channel. Return -1 if there are no tokens
    #  on channel between i and 0.
    def previousTokenOnChannel(self, i:int, channel:int):
        while i>=0 and self.tokens[i].channel!=channel:
            i -= 1
        return i

    # Collect all tokens on specified channel to the right of
    #  the current token up until we see a token on DEFAULT_TOKEN_CHANNEL or
    #  EOF. If channel is -1, find any non default channel token.
    def getHiddenTokensToRight(self, tokenIndex:int, channel:int=-1):
        self.lazyInit()
        if tokenIndex<0 or tokenIndex>=len(self.tokens):
            raise Exception(str(tokenIndex) + " not in 0.." + str(len(self.tokens)-1))
        from antlr4.Lexer import Lexer
        nextOnChannel = self.nextTokenOnChannel(tokenIndex + 1, Lexer.DEFAULT_TOKEN_CHANNEL)
        from_ = tokenIndex+1
        # if none onchannel to right, nextOnChannel=-1 so set to = last token
        to = (len(self.tokens)-1) if nextOnChannel==-1 else nextOnChannel
        return self.filterForChannel(from_, to, channel)


    # Collect all tokens on specified channel to the left of
    #  the current token up until we see a token on DEFAULT_TOKEN_CHANNEL.
    #  If channel is -1, find any non default channel token.
    def getHiddenTokensToLeft(self, tokenIndex:int, channel:int=-1):
        self.lazyInit()
        if tokenIndex<0 or tokenIndex>=len(self.tokens):
            raise Exception(str(tokenIndex) + " not in 0.." + str(len(self.tokens)-1))
        from antlr4.Lexer import Lexer
        prevOnChannel = self.previousTokenOnChannel(tokenIndex - 1, Lexer.DEFAULT_TOKEN_CHANNEL)
        if prevOnChannel == tokenIndex - 1:
            return None
        # if none on channel to left, prevOnChannel=-1 then from=0
        from_ = prevOnChannel+1
        to = tokenIndex-1
        return self.filterForChannel(from_, to, channel)


    def filterForChannel(self, left:int, right:int, channel:int):
        hidden = []
        for i in range(left, right+1):
            t = self.tokens[i]
            if channel==-1:
                from antlr4.Lexer import Lexer
                if t.channel!= Lexer.DEFAULT_TOKEN_CHANNEL:
                    hidden.append(t)
            elif t.channel==channel:
                    hidden.append(t)
        if len(hidden)==0:
            return None
        return hidden

    def getSourceName(self):
        return self.tokenSource.getSourceName()

    # Get the text of all tokens in this buffer.#/
    def getText(self, interval:tuple=None):
        self.lazyInit()
        self.fill()
        if interval is None:
            interval = (0, len(self.tokens)-1)
        start = interval[0]
        if isinstance(start, Token):
            start = start.tokenIndex
        stop = interval[1]
        if isinstance(stop, Token):
            stop = stop.tokenIndex
        if start is None or stop is None or start<0 or stop<0:
            return ""
        if stop >= len(self.tokens):
            stop = len(self.tokens)-1
        with StringIO() as buf:
            for i in range(start, stop+1):
                t = self.tokens[i]
                if t.type==Token.EOF:
                    break
                buf.write(t.text)
            return buf.getvalue()


    # Get all tokens from lexer until EOF#/
    def fill(self):
        self.lazyInit()
        while self.fetch(1000)==1000:
            pass
