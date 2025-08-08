# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#

# A token has properties: text, type, line, character position in the line
# (so we can ignore tabs), token channel, index, and source from which
# we obtained this token.
from io import StringIO


class Token (object):

    INVALID_TYPE = 0

    # During lookahead operations, this "token" signifies we hit rule end ATN state
    # and did not follow it despite needing to.
    EPSILON = -2

    MIN_USER_TOKEN_TYPE = 1

    EOF = -1

    # All tokens go to the parser (unless skip() is called in that rule)
    # on a particular "channel".  The parser tunes to a particular channel
    # so that whitespace etc... can go to the parser on a "hidden" channel.

    DEFAULT_CHANNEL = 0

    # Anything on different channel than DEFAULT_CHANNEL is not parsed
    # by parser.

    HIDDEN_CHANNEL = 1

    def __init__(self):
        self.source = None
        self.type = None # token type of the token
        self.channel = None # The parser ignores everything not on DEFAULT_CHANNEL
        self.start = None # optional; return -1 if not implemented.
        self.stop = None  # optional; return -1 if not implemented.
        self.tokenIndex = None # from 0..n-1 of the token object in the input stream
        self.line = None # line=1..n of the 1st character
        self.column = None # beginning of the line at which it occurs, 0..n-1
        self._text = None # text of the token.

    @property
    def text(self):
        return self._text

    # Explicitly set the text for this token. If {code text} is not
    # {@code null}, then {@link #getText} will return this value rather than
    # extracting the text from the input.
    #
    # @param text The explicit text of the token, or {@code null} if the text
    # should be obtained from the input along with the start and stop indexes
    # of the token.

    @text.setter
    def text(self, text:str):
        self._text = text


    def getTokenSource(self):
        return self.source[0]

    def getInputStream(self):
        return self.source[1]

class CommonToken(Token):


    # An empty {@link Pair} which is used as the default value of
    # {@link #source} for tokens that do not have a source.
    EMPTY_SOURCE = (None, None)

    def __init__(self, source:tuple = EMPTY_SOURCE, type:int = None, channel:int=Token.DEFAULT_CHANNEL, start:int=-1, stop:int=-1):
        super().__init__()
        self.source = source
        self.type = type
        self.channel = channel
        self.start = start
        self.stop = stop
        self.tokenIndex = -1
        if source[0] is not None:
            self.line = source[0].line
            self.column = source[0].column
        else:
            self.column = -1

    # Constructs a new {@link CommonToken} as a copy of another {@link Token}.
    #
    # <p>
    # If {@code oldToken} is also a {@link CommonToken} instance, the newly
    # constructed token will share a reference to the {@link #text} field and
    # the {@link Pair} stored in {@link #source}. Otherwise, {@link #text} will
    # be assigned the result of calling {@link #getText}, and {@link #source}
    # will be constructed from the result of {@link Token#getTokenSource} and
    # {@link Token#getInputStream}.</p>
    #
    # @param oldToken The token to copy.
     #
    def clone(self):
        t = CommonToken(self.source, self.type, self.channel, self.start, self.stop)
        t.tokenIndex = self.tokenIndex
        t.line = self.line
        t.column = self.column
        t.text = self.text
        return t

    @property
    def text(self):
        if self._text is not None:
            return self._text
        input = self.getInputStream()
        if input is None:
            return None
        n = input.size
        if self.start < n and self.stop < n:
            return input.getText(self.start, self.stop)
        else:
            return "<EOF>"

    @text.setter
    def text(self, text:str):
        self._text = text

    def __str__(self):
        with StringIO() as buf:
            buf.write("[@")
            buf.write(str(self.tokenIndex))
            buf.write(",")
            buf.write(str(self.start))
            buf.write(":")
            buf.write(str(self.stop))
            buf.write("='")
            txt = self.text
            if txt is not None:
                txt = txt.replace("\n","\\n")
                txt = txt.replace("\r","\\r")
                txt = txt.replace("\t","\\t")
            else:
                txt = "<no text>"
            buf.write(txt)
            buf.write("',<")
            buf.write(str(self.type))
            buf.write(">")
            if self.channel > 0:
                buf.write(",channel=")
                buf.write(str(self.channel))
            buf.write(",")
            buf.write(str(self.line))
            buf.write(":")
            buf.write(str(self.column))
            buf.write("]")
            return buf.getvalue()
