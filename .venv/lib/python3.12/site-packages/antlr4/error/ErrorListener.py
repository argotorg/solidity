#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.

# Provides an empty default implementation of {@link ANTLRErrorListener}. The
# default implementation of each method does nothing, but can be overridden as
# necessary.


import sys

class ErrorListener(object):

    def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
        pass

    def reportAmbiguity(self, recognizer, dfa, startIndex, stopIndex, exact, ambigAlts, configs):
        pass

    def reportAttemptingFullContext(self, recognizer, dfa, startIndex, stopIndex, conflictingAlts, configs):
        pass

    def reportContextSensitivity(self, recognizer, dfa, startIndex, stopIndex, prediction, configs):
        pass

class ConsoleErrorListener(ErrorListener):
    #
    # Provides a default instance of {@link ConsoleErrorListener}.
    #
    INSTANCE = None

    #
    # {@inheritDoc}
    #
    # <p>
    # This implementation prints messages to {@link System#err} containing the
    # values of {@code line}, {@code charPositionInLine}, and {@code msg} using
    # the following format.</p>
    #
    # <pre>
    # line <em>line</em>:<em>charPositionInLine</em> <em>msg</em>
    # </pre>
    #
    def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
        print("line " + str(line) + ":" + str(column) + " " + msg, file=sys.stderr)

ConsoleErrorListener.INSTANCE = ConsoleErrorListener()

class ProxyErrorListener(ErrorListener):

    def __init__(self, delegates):
        super().__init__()
        if delegates is None:
            raise ReferenceError("delegates")
        self.delegates = delegates

    def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
        for delegate in self.delegates:
            delegate.syntaxError(recognizer, offendingSymbol, line, column, msg, e)

    def reportAmbiguity(self, recognizer, dfa, startIndex, stopIndex, exact, ambigAlts, configs):
        for delegate in self.delegates:
            delegate.reportAmbiguity(recognizer, dfa, startIndex, stopIndex, exact, ambigAlts, configs)

    def reportAttemptingFullContext(self, recognizer, dfa, startIndex, stopIndex, conflictingAlts, configs):
        for delegate in self.delegates:
            delegate.reportAttemptingFullContext(recognizer, dfa, startIndex, stopIndex, conflictingAlts, configs)

    def reportContextSensitivity(self, recognizer, dfa, startIndex, stopIndex, prediction, configs):
        for delegate in self.delegates:
            delegate.reportContextSensitivity(recognizer, dfa, startIndex, stopIndex, prediction, configs)
