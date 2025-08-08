#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#

#
# This default implementation of {@link TokenFactory} creates
# {@link CommonToken} objects.
#
from antlr4.Token import CommonToken

class TokenFactory(object):

    pass

class CommonTokenFactory(TokenFactory):
    #
    # The default {@link CommonTokenFactory} instance.
    #
    # <p>
    # This token factory does not explicitly copy token text when constructing
    # tokens.</p>
    #
    DEFAULT = None

    def __init__(self, copyText:bool=False):
        # Indicates whether {@link CommonToken#setText} should be called after
        # constructing tokens to explicitly set the text. This is useful for cases
        # where the input stream might not be able to provide arbitrary substrings
        # of text from the input after the lexer creates a token (e.g. the
        # implementation of {@link CharStream#getText} in
        # {@link UnbufferedCharStream} throws an
        # {@link UnsupportedOperationException}). Explicitly setting the token text
        # allows {@link Token#getText} to be called at any time regardless of the
        # input stream implementation.
        #
        # <p>
        # The default value is {@code false} to avoid the performance and memory
        # overhead of copying text for every token unless explicitly requested.</p>
        #
        self.copyText = copyText

    def create(self, source, type:int, text:str, channel:int, start:int, stop:int, line:int, column:int):
        t = CommonToken(source, type, channel, start, stop)
        t.line = line
        t.column = column
        if text is not None:
            t.text = text
        elif self.copyText and source[1] is not None:
            t.text = source[1].getText(start,stop)
        return t

    def createThin(self, type:int, text:str):
        t = CommonToken(type=type)
        t.text = text
        return t

CommonTokenFactory.DEFAULT = CommonTokenFactory()