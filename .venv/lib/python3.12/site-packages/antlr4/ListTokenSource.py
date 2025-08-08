#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#

#
# Provides an implementation of {@link TokenSource} as a wrapper around a list
# of {@link Token} objects.
#
# <p>If the final token in the list is an {@link Token#EOF} token, it will be used
# as the EOF token for every call to {@link #nextToken} after the end of the
# list is reached. Otherwise, an EOF token will be created.</p>
#
from antlr4.CommonTokenFactory import CommonTokenFactory
from antlr4.Lexer import TokenSource
from antlr4.Token import Token


class ListTokenSource(TokenSource):

    # Constructs a new {@link ListTokenSource} instance from the specified
    # collection of {@link Token} objects and source name.
    #
    # @param tokens The collection of {@link Token} objects to provide as a
    # {@link TokenSource}.
    # @param sourceName The name of the {@link TokenSource}. If this value is
    # {@code null}, {@link #getSourceName} will attempt to infer the name from
    # the next {@link Token} (or the previous token if the end of the input has
    # been reached).
    #
    # @exception NullPointerException if {@code tokens} is {@code null}
    #
    def __init__(self, tokens:list, sourceName:str=None):
        if tokens is None:
            raise ReferenceError("tokens cannot be null")
        self.tokens = tokens
        self.sourceName = sourceName
        # The index into {@link #tokens} of token to return by the next call to
        # {@link #nextToken}. The end of the input is indicated by this value
        # being greater than or equal to the number of items in {@link #tokens}.
        self.pos = 0
        # This field caches the EOF token for the token source.
        self.eofToken = None
        # This is the backing field for {@link #getTokenFactory} and
        self._factory = CommonTokenFactory.DEFAULT


    #
    # {@inheritDoc}
    #
    @property
    def column(self):
        if self.pos < len(self.tokens):
            return self.tokens[self.pos].column
        elif self.eofToken is not None:
            return self.eofToken.column
        elif len(self.tokens) > 0:
            # have to calculate the result from the line/column of the previous
            # token, along with the text of the token.
            lastToken = self.tokens[len(self.tokens) - 1]
            tokenText = lastToken.text
            if tokenText is not None:
                lastNewLine = tokenText.rfind('\n')
                if lastNewLine >= 0:
                    return len(tokenText) - lastNewLine - 1
            return lastToken.column + lastToken.stop - lastToken.start + 1

        # only reach this if tokens is empty, meaning EOF occurs at the first
        # position in the input
        return 0

    #
    # {@inheritDoc}
    #
    def nextToken(self):
        if self.pos >= len(self.tokens):
            if self.eofToken is None:
                start = -1
                if len(self.tokens) > 0:
                    previousStop = self.tokens[len(self.tokens) - 1].stop
                    if previousStop != -1:
                        start = previousStop + 1
                stop = max(-1, start - 1)
                self.eofToken = self._factory.create((self, self.getInputStream()),
                            Token.EOF, "EOF", Token.DEFAULT_CHANNEL, start, stop, self.line, self.column)
            return self.eofToken
        t = self.tokens[self.pos]
        if self.pos == len(self.tokens) - 1 and t.type == Token.EOF:
            self.eofToken = t
        self.pos += 1
        return t

    #
    # {@inheritDoc}
    #
    @property
    def line(self):
        if self.pos < len(self.tokens):
            return self.tokens[self.pos].line
        elif self.eofToken is not None:
            return self.eofToken.line
        elif len(self.tokens) > 0:
            # have to calculate the result from the line/column of the previous
            # token, along with the text of the token.
            lastToken = self.tokens[len(self.tokens) - 1]
            line = lastToken.line
            tokenText = lastToken.text
            if tokenText is not None:
                line += tokenText.count('\n')

            # if no text is available, assume the token did not contain any newline characters.
            return line

        # only reach this if tokens is empty, meaning EOF occurs at the first
        # position in the input
        return 1

    #
    # {@inheritDoc}
    #
    def getInputStream(self):
        if self.pos < len(self.tokens):
            return self.tokens[self.pos].getInputStream()
        elif self.eofToken is not None:
            return self.eofToken.getInputStream()
        elif len(self.tokens) > 0:
            return self.tokens[len(self.tokens) - 1].getInputStream()
        else:
            # no input stream information is available
            return None

    #
    # {@inheritDoc}
    #
    def getSourceName(self):
        if self.sourceName is not None:
            return self.sourceName
        inputStream = self.getInputStream()
        if inputStream is not None:
            return inputStream.getSourceName()
        else:
            return "List"