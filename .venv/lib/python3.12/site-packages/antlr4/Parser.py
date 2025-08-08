#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
import sys
from typing.io import TextIO
from antlr4.BufferedTokenStream import TokenStream
from antlr4.CommonTokenFactory import TokenFactory
from antlr4.error.ErrorStrategy import DefaultErrorStrategy
from antlr4.InputStream import InputStream
from antlr4.Recognizer import Recognizer
from antlr4.RuleContext import RuleContext
from antlr4.ParserRuleContext import ParserRuleContext
from antlr4.Token import Token
from antlr4.Lexer import Lexer
from antlr4.atn.ATNDeserializer import ATNDeserializer
from antlr4.atn.ATNDeserializationOptions import ATNDeserializationOptions
from antlr4.error.Errors import UnsupportedOperationException, RecognitionException
from antlr4.tree.ParseTreePatternMatcher import ParseTreePatternMatcher
from antlr4.tree.Tree import ParseTreeListener, TerminalNode, ErrorNode

class TraceListener(ParseTreeListener):

    def __init__(self, parser):
        self._parser = parser

    def enterEveryRule(self, ctx):
        print("enter   " + self._parser.ruleNames[ctx.getRuleIndex()] + ", LT(1)=" + self._parser._input.LT(1).text, file=self._parser._output)

    def visitTerminal(self, node):

        print("consume " + str(node.symbol) + " rule " + self._parser.ruleNames[self._parser._ctx.getRuleIndex()], file=self._parser._output)

    def visitErrorNode(self, node):
        pass


    def exitEveryRule(self, ctx):
        print("exit    " + self._parser.ruleNames[ctx.getRuleIndex()] + ", LT(1)=" + self._parser._input.LT(1).text, file=self._parser._output)


# self is all the parsing support code essentially; most of it is error recovery stuff.#
class Parser (Recognizer):

    # self field maps from the serialized ATN string to the deserialized {@link ATN} with
    # bypass alternatives.
    #
    # @see ATNDeserializationOptions#isGenerateRuleBypassTransitions()
    #
    bypassAltsAtnCache = dict()

    def __init__(self, input:TokenStream, output:TextIO = sys.stdout):
        super().__init__()
        # The input stream.
        self._input = None
        self._output = output
        # The error handling strategy for the parser. The default value is a new
        # instance of {@link DefaultErrorStrategy}.
        self._errHandler = DefaultErrorStrategy()
        self._precedenceStack = list()
        self._precedenceStack.append(0)
        # The {@link ParserRuleContext} object for the currently executing rule.
        # self is always non-null during the parsing process.
        self._ctx = None
        # Specifies whether or not the parser should construct a parse tree during
        # the parsing process. The default value is {@code true}.
        self.buildParseTrees = True
        # When {@link #setTrace}{@code (true)} is called, a reference to the
        # {@link TraceListener} is stored here so it can be easily removed in a
        # later call to {@link #setTrace}{@code (false)}. The listener itself is
        # implemented as a parser listener so self field is not directly used by
        # other parser methods.
        self._tracer = None
        # The list of {@link ParseTreeListener} listeners registered to receive
        # events during the parse.
        self._parseListeners = None
        # The number of syntax errors reported during parsing. self value is
        # incremented each time {@link #notifyErrorListeners} is called.
        self._syntaxErrors = 0
        self.setInputStream(input)

    # reset the parser's state#
    def reset(self):
        if self._input is not None:
            self._input.seek(0)
        self._errHandler.reset(self)
        self._ctx = None
        self._syntaxErrors = 0
        self.setTrace(False)
        self._precedenceStack = list()
        self._precedenceStack.append(0)
        if self._interp is not None:
            self._interp.reset()

    # Match current input symbol against {@code ttype}. If the symbol type
    # matches, {@link ANTLRErrorStrategy#reportMatch} and {@link #consume} are
    # called to complete the match process.
    #
    # <p>If the symbol type does not match,
    # {@link ANTLRErrorStrategy#recoverInline} is called on the current error
    # strategy to attempt recovery. If {@link #getBuildParseTree} is
    # {@code true} and the token index of the symbol returned by
    # {@link ANTLRErrorStrategy#recoverInline} is -1, the symbol is added to
    # the parse tree by calling {@link ParserRuleContext#addErrorNode}.</p>
    #
    # @param ttype the token type to match
    # @return the matched symbol
    # @throws RecognitionException if the current input symbol did not match
    # {@code ttype} and the error strategy could not recover from the
    # mismatched symbol

    def match(self, ttype:int):
        t = self.getCurrentToken()
        if t.type==ttype:
            self._errHandler.reportMatch(self)
            self.consume()
        else:
            t = self._errHandler.recoverInline(self)
            if self.buildParseTrees and t.tokenIndex==-1:
                # we must have conjured up a new token during single token insertion
                # if it's not the current symbol
                self._ctx.addErrorNode(t)
        return t

    # Match current input symbol as a wildcard. If the symbol type matches
    # (i.e. has a value greater than 0), {@link ANTLRErrorStrategy#reportMatch}
    # and {@link #consume} are called to complete the match process.
    #
    # <p>If the symbol type does not match,
    # {@link ANTLRErrorStrategy#recoverInline} is called on the current error
    # strategy to attempt recovery. If {@link #getBuildParseTree} is
    # {@code true} and the token index of the symbol returned by
    # {@link ANTLRErrorStrategy#recoverInline} is -1, the symbol is added to
    # the parse tree by calling {@link ParserRuleContext#addErrorNode}.</p>
    #
    # @return the matched symbol
    # @throws RecognitionException if the current input symbol did not match
    # a wildcard and the error strategy could not recover from the mismatched
    # symbol

    def matchWildcard(self):
        t = self.getCurrentToken()
        if t.type > 0:
            self._errHandler.reportMatch(self)
            self.consume()
        else:
            t = self._errHandler.recoverInline(self)
            if self.buildParseTrees and t.tokenIndex == -1:
                # we must have conjured up a new token during single token insertion
                # if it's not the current symbol
                self._ctx.addErrorNode(t)

        return t

    def getParseListeners(self):
        return list() if self._parseListeners is None else self._parseListeners

    # Registers {@code listener} to receive events during the parsing process.
    #
    # <p>To support output-preserving grammar transformations (including but not
    # limited to left-recursion removal, automated left-factoring, and
    # optimized code generation), calls to listener methods during the parse
    # may differ substantially from calls made by
    # {@link ParseTreeWalker#DEFAULT} used after the parse is complete. In
    # particular, rule entry and exit events may occur in a different order
    # during the parse than after the parser. In addition, calls to certain
    # rule entry methods may be omitted.</p>
    #
    # <p>With the following specific exceptions, calls to listener events are
    # <em>deterministic</em>, i.e. for identical input the calls to listener
    # methods will be the same.</p>
    #
    # <ul>
    # <li>Alterations to the grammar used to generate code may change the
    # behavior of the listener calls.</li>
    # <li>Alterations to the command line options passed to ANTLR 4 when
    # generating the parser may change the behavior of the listener calls.</li>
    # <li>Changing the version of the ANTLR Tool used to generate the parser
    # may change the behavior of the listener calls.</li>
    # </ul>
    #
    # @param listener the listener to add
    #
    # @throws NullPointerException if {@code} listener is {@code null}
    #
    def addParseListener(self, listener:ParseTreeListener):
        if listener is None:
            raise ReferenceError("listener")
        if self._parseListeners is None:
            self._parseListeners = []
        self._parseListeners.append(listener)

    #
    # Remove {@code listener} from the list of parse listeners.
    #
    # <p>If {@code listener} is {@code null} or has not been added as a parse
    # listener, self method does nothing.</p>
    # @param listener the listener to remove
    #
    def removeParseListener(self, listener:ParseTreeListener):
        if self._parseListeners is not None:
            self._parseListeners.remove(listener)
            if len(self._parseListeners)==0:
                    self._parseListeners = None

    # Remove all parse listeners.
    def removeParseListeners(self):
        self._parseListeners = None

    # Notify any parse listeners of an enter rule event.
    def triggerEnterRuleEvent(self):
        if self._parseListeners is not None:
            for listener in self._parseListeners:
                listener.enterEveryRule(self._ctx)
                self._ctx.enterRule(listener)

    #
    # Notify any parse listeners of an exit rule event.
    #
    # @see #addParseListener
    #
    def triggerExitRuleEvent(self):
        if self._parseListeners is not None:
            # reverse order walk of listeners
            for listener in reversed(self._parseListeners):
                self._ctx.exitRule(listener)
                listener.exitEveryRule(self._ctx)


    # Gets the number of syntax errors reported during parsing. This value is
    # incremented each time {@link #notifyErrorListeners} is called.
    #
    # @see #notifyErrorListeners
    #
    def getNumberOfSyntaxErrors(self):
        return self._syntaxErrors

    def getTokenFactory(self):
        return self._input.tokenSource._factory

    # Tell our token source and error strategy about a new way to create tokens.#
    def setTokenFactory(self, factory:TokenFactory):
        self._input.tokenSource._factory = factory

    # The ATN with bypass alternatives is expensive to create so we create it
    # lazily.
    #
    # @throws UnsupportedOperationException if the current parser does not
    # implement the {@link #getSerializedATN()} method.
    #
    def getATNWithBypassAlts(self):
        serializedAtn = self.getSerializedATN()
        if serializedAtn is None:
            raise UnsupportedOperationException("The current parser does not support an ATN with bypass alternatives.")
        result = self.bypassAltsAtnCache.get(serializedAtn, None)
        if result is None:
            deserializationOptions = ATNDeserializationOptions()
            deserializationOptions.generateRuleBypassTransitions = True
            result = ATNDeserializer(deserializationOptions).deserialize(serializedAtn)
            self.bypassAltsAtnCache[serializedAtn] = result
        return result

    # The preferred method of getting a tree pattern. For example, here's a
    # sample use:
    #
    # <pre>
    # ParseTree t = parser.expr();
    # ParseTreePattern p = parser.compileParseTreePattern("&lt;ID&gt;+0", MyParser.RULE_expr);
    # ParseTreeMatch m = p.match(t);
    # String id = m.get("ID");
    # </pre>
    #
    def compileParseTreePattern(self, pattern:str, patternRuleIndex:int, lexer:Lexer = None):
        if lexer is None:
            if self.getTokenStream() is not None:
                tokenSource = self.getTokenStream().tokenSource
                if isinstance( tokenSource, Lexer ):
                    lexer = tokenSource
        if lexer is None:
            raise UnsupportedOperationException("Parser can't discover a lexer to use")

        m = ParseTreePatternMatcher(lexer, self)
        return m.compile(pattern, patternRuleIndex)


    def getInputStream(self):
        return self.getTokenStream()

    def setInputStream(self, input:InputStream):
        self.setTokenStream(input)

    def getTokenStream(self):
        return self._input

    # Set the token stream and reset the parser.#
    def setTokenStream(self, input:TokenStream):
        self._input = None
        self.reset()
        self._input = input

    # Match needs to return the current input symbol, which gets put
    #  into the label for the associated token ref; e.g., x=ID.
    #
    def getCurrentToken(self):
        return self._input.LT(1)

    def notifyErrorListeners(self, msg:str, offendingToken:Token = None, e:RecognitionException = None):
        if offendingToken is None:
            offendingToken = self.getCurrentToken()
        self._syntaxErrors += 1
        line = offendingToken.line
        column = offendingToken.column
        listener = self.getErrorListenerDispatch()
        listener.syntaxError(self, offendingToken, line, column, msg, e)

    #
    # Consume and return the {@linkplain #getCurrentToken current symbol}.
    #
    # <p>E.g., given the following input with {@code A} being the current
    # lookahead symbol, self function moves the cursor to {@code B} and returns
    # {@code A}.</p>
    #
    # <pre>
    #  A B
    #  ^
    # </pre>
    #
    # If the parser is not in error recovery mode, the consumed symbol is added
    # to the parse tree using {@link ParserRuleContext#addChild(Token)}, and
    # {@link ParseTreeListener#visitTerminal} is called on any parse listeners.
    # If the parser <em>is</em> in error recovery mode, the consumed symbol is
    # added to the parse tree using
    # {@link ParserRuleContext#addErrorNode(Token)}, and
    # {@link ParseTreeListener#visitErrorNode} is called on any parse
    # listeners.
    #
    def consume(self):
        o = self.getCurrentToken()
        if o.type != Token.EOF:
            self.getInputStream().consume()
        hasListener = self._parseListeners is not None and len(self._parseListeners)>0
        if self.buildParseTrees or hasListener:
            if self._errHandler.inErrorRecoveryMode(self):
                node = self._ctx.addErrorNode(o)
            else:
                node = self._ctx.addTokenNode(o)
            if hasListener:
                for listener in self._parseListeners:
                    if isinstance(node, ErrorNode):
                        listener.visitErrorNode(node)
                    elif isinstance(node, TerminalNode):
                        listener.visitTerminal(node)
        return o

    def addContextToParseTree(self):
        # add current context to parent if we have a parent
        if self._ctx.parentCtx is not None:
            self._ctx.parentCtx.addChild(self._ctx)

    # Always called by generated parsers upon entry to a rule. Access field
    # {@link #_ctx} get the current context.
    #
    def enterRule(self, localctx:ParserRuleContext , state:int , ruleIndex:int):
        self.state = state
        self._ctx = localctx
        self._ctx.start = self._input.LT(1)
        if self.buildParseTrees:
            self.addContextToParseTree()
        if self._parseListeners  is not None:
            self.triggerEnterRuleEvent()

    def exitRule(self):
        self._ctx.stop = self._input.LT(-1)
        # trigger event on _ctx, before it reverts to parent
        if self._parseListeners is not None:
            self.triggerExitRuleEvent()
        self.state = self._ctx.invokingState
        self._ctx = self._ctx.parentCtx

    def enterOuterAlt(self, localctx:ParserRuleContext, altNum:int):
        localctx.setAltNumber(altNum)
        # if we have new localctx, make sure we replace existing ctx
        # that is previous child of parse tree
        if self.buildParseTrees and self._ctx != localctx:
            if self._ctx.parentCtx is not None:
                self._ctx.parentCtx.removeLastChild()
                self._ctx.parentCtx.addChild(localctx)
        self._ctx = localctx

    # Get the precedence level for the top-most precedence rule.
    #
    # @return The precedence level for the top-most precedence rule, or -1 if
    # the parser context is not nested within a precedence rule.
    #
    def getPrecedence(self):
        if len(self._precedenceStack)==0:
            return -1
        else:
            return self._precedenceStack[-1]

    def enterRecursionRule(self, localctx:ParserRuleContext, state:int, ruleIndex:int, precedence:int):
        self.state = state
        self._precedenceStack.append(precedence)
        self._ctx = localctx
        self._ctx.start = self._input.LT(1)
        if self._parseListeners is not None:
            self.triggerEnterRuleEvent() # simulates rule entry for left-recursive rules

    #
    # Like {@link #enterRule} but for recursive rules.
    #
    def pushNewRecursionContext(self, localctx:ParserRuleContext, state:int, ruleIndex:int):
        previous = self._ctx
        previous.parentCtx = localctx
        previous.invokingState = state
        previous.stop = self._input.LT(-1)

        self._ctx = localctx
        self._ctx.start = previous.start
        if self.buildParseTrees:
            self._ctx.addChild(previous)

        if self._parseListeners is not None:
            self.triggerEnterRuleEvent() # simulates rule entry for left-recursive rules

    def unrollRecursionContexts(self, parentCtx:ParserRuleContext):
        self._precedenceStack.pop()
        self._ctx.stop = self._input.LT(-1)
        retCtx = self._ctx # save current ctx (return value)
        # unroll so _ctx is as it was before call to recursive method
        if self._parseListeners is not None:
            while self._ctx is not parentCtx:
                self.triggerExitRuleEvent()
                self._ctx = self._ctx.parentCtx
        else:
            self._ctx = parentCtx

        # hook into tree
        retCtx.parentCtx = parentCtx

        if self.buildParseTrees and parentCtx is not None:
            # add return ctx into invoking rule's tree
            parentCtx.addChild(retCtx)

    def getInvokingContext(self, ruleIndex:int):
        ctx = self._ctx
        while ctx is not None:
            if ctx.ruleIndex == ruleIndex:
                return ctx
            ctx = ctx.parentCtx
        return None


    def precpred(self, localctx:RuleContext , precedence:int):
        return precedence >= self._precedenceStack[-1]

    def inContext(self, context:str):
        # TODO: useful in parser?
        return False

    #
    # Checks whether or not {@code symbol} can follow the current state in the
    # ATN. The behavior of self method is equivalent to the following, but is
    # implemented such that the complete context-sensitive follow set does not
    # need to be explicitly constructed.
    #
    # <pre>
    # return getExpectedTokens().contains(symbol);
    # </pre>
    #
    # @param symbol the symbol type to check
    # @return {@code true} if {@code symbol} can follow the current state in
    # the ATN, otherwise {@code false}.
    #
    def isExpectedToken(self, symbol:int):
        atn = self._interp.atn
        ctx = self._ctx
        s = atn.states[self.state]
        following = atn.nextTokens(s)
        if symbol in following:
            return True
        if not Token.EPSILON in following:
            return False

        while ctx is not None and ctx.invokingState>=0 and Token.EPSILON in following:
            invokingState = atn.states[ctx.invokingState]
            rt = invokingState.transitions[0]
            following = atn.nextTokens(rt.followState)
            if symbol in following:
                return True
            ctx = ctx.parentCtx

        if Token.EPSILON in following and symbol == Token.EOF:
            return True
        else:
            return False

    # Computes the set of input symbols which could follow the current parser
    # state and context, as given by {@link #getState} and {@link #getContext},
    # respectively.
    #
    # @see ATN#getExpectedTokens(int, RuleContext)
    #
    def getExpectedTokens(self):
        return self._interp.atn.getExpectedTokens(self.state, self._ctx)

    def getExpectedTokensWithinCurrentRule(self):
        atn = self._interp.atn
        s = atn.states[self.state]
        return atn.nextTokens(s)

    # Get a rule's index (i.e., {@code RULE_ruleName} field) or -1 if not found.#
    def getRuleIndex(self, ruleName:str):
        ruleIndex = self.getRuleIndexMap().get(ruleName, None)
        if ruleIndex is not None:
            return ruleIndex
        else:
            return -1

    # Return List&lt;String&gt; of the rule names in your parser instance
    #  leading up to a call to the current rule.  You could override if
    #  you want more details such as the file/line info of where
    #  in the ATN a rule is invoked.
    #
    #  this is very useful for error messages.
    #
    def getRuleInvocationStack(self, p:RuleContext=None):
        if p is None:
            p = self._ctx
        stack = list()
        while p is not None:
            # compute what follows who invoked us
            ruleIndex = p.getRuleIndex()
            if ruleIndex<0:
                stack.append("n/a")
            else:
                stack.append(self.ruleNames[ruleIndex])
            p = p.parentCtx
        return stack

    # For debugging and other purposes.#
    def getDFAStrings(self):
        return [ str(dfa) for dfa in self._interp.decisionToDFA]

    # For debugging and other purposes.#
    def dumpDFA(self):
        seenOne = False
        for i in range(0, len(self._interp.decisionToDFA)):
            dfa = self._interp.decisionToDFA[i]
            if len(dfa.states)>0:
                if seenOne:
                    print(file=self._output)
                print("Decision " + str(dfa.decision) + ":", file=self._output)
                print(dfa.toString(self.literalNames, self.symbolicNames), end='', file=self._output)
                seenOne = True


    def getSourceName(self):
        return self._input.sourceName

    # During a parse is sometimes useful to listen in on the rule entry and exit
    #  events as well as token matches. self is for quick and dirty debugging.
    #
    def setTrace(self, trace:bool):
        if not trace:
            self.removeParseListener(self._tracer)
            self._tracer = None
        else:
            if self._tracer is not None:
                self.removeParseListener(self._tracer)
            self._tracer = TraceListener(self)
            self.addParseListener(self._tracer)
