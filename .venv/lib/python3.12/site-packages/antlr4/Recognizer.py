#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#
from antlr4.RuleContext import RuleContext
from antlr4.Token import Token
from antlr4.error.ErrorListener import ProxyErrorListener, ConsoleErrorListener

# need forward delcaration
RecognitionException = None

class Recognizer(object):

    tokenTypeMapCache = dict()
    ruleIndexMapCache = dict()

    def __init__(self):
        self._listeners = [ ConsoleErrorListener.INSTANCE ]
        self._interp = None
        self._stateNumber = -1

    def extractVersion(self, version):
        pos = version.find(".")
        major = version[0:pos]
        version = version[pos+1:]
        pos = version.find(".")
        if pos==-1:
            pos = version.find("-")
        if pos==-1:
            pos = len(version)
        minor = version[0:pos]
        return major, minor

    def checkVersion(self, toolVersion):
        runtimeVersion = "4.7.1"
        rvmajor, rvminor = self.extractVersion(runtimeVersion)
        tvmajor, tvminor = self.extractVersion(toolVersion)
        if rvmajor!=tvmajor or rvminor!=tvminor:
            print("ANTLR runtime and generated code versions disagree: "+runtimeVersion+"!="+toolVersion)

    def addErrorListener(self, listener):
        self._listeners.append(listener)

    def removeErrorListener(self, listener):
        self._listeners.remove(listener)

    def removeErrorListeners(self):
        self._listeners = []

    def getTokenTypeMap(self):
        tokenNames = self.getTokenNames()
        if tokenNames is None:
            from antlr4.error.Errors import UnsupportedOperationException
            raise UnsupportedOperationException("The current recognizer does not provide a list of token names.")
        result = self.tokenTypeMapCache.get(tokenNames, None)
        if result is None:
            result = zip( tokenNames, range(0, len(tokenNames)))
            result["EOF"] = Token.EOF
            self.tokenTypeMapCache[tokenNames] = result
        return result

    # Get a map from rule names to rule indexes.
    #
    # <p>Used for XPath and tree pattern compilation.</p>
    #
    def getRuleIndexMap(self):
        ruleNames = self.getRuleNames()
        if ruleNames is None:
            from antlr4.error.Errors import UnsupportedOperationException
            raise UnsupportedOperationException("The current recognizer does not provide a list of rule names.")
        result = self.ruleIndexMapCache.get(ruleNames, None)
        if result is None:
            result = zip( ruleNames, range(0, len(ruleNames)))
            self.ruleIndexMapCache[ruleNames] = result
        return result

    def getTokenType(self, tokenName:str):
        ttype = self.getTokenTypeMap().get(tokenName, None)
        if ttype is not None:
            return ttype
        else:
            return Token.INVALID_TYPE


    # What is the error header, normally line/character position information?#
    def getErrorHeader(self, e:RecognitionException):
        line = e.getOffendingToken().line
        column = e.getOffendingToken().column
        return "line "+line+":"+column


    # How should a token be displayed in an error message? The default
    #  is to display just the text, but during development you might
    #  want to have a lot of information spit out.  Override in that case
    #  to use t.toString() (which, for CommonToken, dumps everything about
    #  the token). This is better than forcing you to override a method in
    #  your token objects because you don't have to go modify your lexer
    #  so that it creates a new Java type.
    #
    # @deprecated This method is not called by the ANTLR 4 Runtime. Specific
    # implementations of {@link ANTLRErrorStrategy} may provide a similar
    # feature when necessary. For example, see
    # {@link DefaultErrorStrategy#getTokenErrorDisplay}.
    #
    def getTokenErrorDisplay(self, t:Token):
        if t is None:
            return "<no token>"
        s = t.text
        if s is None:
            if t.type==Token.EOF:
                s = "<EOF>"
            else:
                s = "<" + str(t.type) + ">"
        s = s.replace("\n","\\n")
        s = s.replace("\r","\\r")
        s = s.replace("\t","\\t")
        return "'" + s + "'"

    def getErrorListenerDispatch(self):
        return ProxyErrorListener(self._listeners)

    # subclass needs to override these if there are sempreds or actions
    # that the ATN interp needs to execute
    def sempred(self, localctx:RuleContext, ruleIndex:int, actionIndex:int):
        return True

    def precpred(self, localctx:RuleContext , precedence:int):
        return True

    @property
    def state(self):
        return self._stateNumber

    # Indicate that the recognizer has changed internal state that is
    #  consistent with the ATN state passed in.  This way we always know
    #  where we are in the ATN as the parser goes along. The rule
    #  context objects form a stack that lets us see the stack of
    #  invoking rules. Combine this and we have complete ATN
    #  configuration information.

    @state.setter
    def state(self, atnState:int):
        self._stateNumber = atnState

del RecognitionException

import unittest
class Test(unittest.TestCase):

    def testVersion(self):
        major, minor = Recognizer().extractVersion("1.2")
        self.assertEqual("1", major)
        self.assertEqual("2", minor)
        major, minor = Recognizer().extractVersion("1.2.3")
        self.assertEqual("1", major)
        self.assertEqual("2", minor)
        major, minor = Recognizer().extractVersion("1.2-snapshot")
        self.assertEqual("1", major)
        self.assertEqual("2", minor)
