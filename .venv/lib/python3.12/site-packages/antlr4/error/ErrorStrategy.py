#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#
import sys
from antlr4.IntervalSet import IntervalSet

from antlr4.Token import Token
from antlr4.atn.ATNState import ATNState
from antlr4.error.Errors import RecognitionException, NoViableAltException, InputMismatchException, \
    FailedPredicateException, ParseCancellationException

# need forward declaration
Parser = None

class ErrorStrategy(object):

    def reset(self, recognizer:Parser):
        pass

    def recoverInline(self, recognizer:Parser):
        pass

    def recover(self, recognizer:Parser, e:RecognitionException):
        pass

    def sync(self, recognizer:Parser):
        pass

    def inErrorRecoveryMode(self, recognizer:Parser):
        pass

    def reportError(self, recognizer:Parser, e:RecognitionException):
        pass


# This is the default implementation of {@link ANTLRErrorStrategy} used for
# error reporting and recovery in ANTLR parsers.
#
class DefaultErrorStrategy(ErrorStrategy):

    def __init__(self):
        super().__init__()
        # Indicates whether the error strategy is currently "recovering from an
        # error". This is used to suppress reporting multiple error messages while
        # attempting to recover from a detected syntax error.
        #
        # @see #inErrorRecoveryMode
        #
        self.errorRecoveryMode = False

        # The index into the input stream where the last error occurred.
        # 	This is used to prevent infinite loops where an error is found
        #  but no token is consumed during recovery...another error is found,
        #  ad nauseum.  This is a failsafe mechanism to guarantee that at least
        #  one token/tree node is consumed for two errors.
        #
        self.lastErrorIndex = -1
        self.lastErrorStates = None

    # <p>The default implementation simply calls {@link #endErrorCondition} to
    # ensure that the handler is not in error recovery mode.</p>
    def reset(self, recognizer:Parser):
        self.endErrorCondition(recognizer)

    #
    # This method is called to enter error recovery mode when a recognition
    # exception is reported.
    #
    # @param recognizer the parser instance
    #
    def beginErrorCondition(self, recognizer:Parser):
        self.errorRecoveryMode = True

    def inErrorRecoveryMode(self, recognizer:Parser):
        return self.errorRecoveryMode

    #
    # This method is called to leave error recovery mode after recovering from
    # a recognition exception.
    #
    # @param recognizer
    #
    def endErrorCondition(self, recognizer:Parser):
        self.errorRecoveryMode = False
        self.lastErrorStates = None
        self.lastErrorIndex = -1

    #
    # {@inheritDoc}
    #
    # <p>The default implementation simply calls {@link #endErrorCondition}.</p>
    #
    def reportMatch(self, recognizer:Parser):
        self.endErrorCondition(recognizer)

    #
    # {@inheritDoc}
    #
    # <p>The default implementation returns immediately if the handler is already
    # in error recovery mode. Otherwise, it calls {@link #beginErrorCondition}
    # and dispatches the reporting task based on the runtime type of {@code e}
    # according to the following table.</p>
    #
    # <ul>
    # <li>{@link NoViableAltException}: Dispatches the call to
    # {@link #reportNoViableAlternative}</li>
    # <li>{@link InputMismatchException}: Dispatches the call to
    # {@link #reportInputMismatch}</li>
    # <li>{@link FailedPredicateException}: Dispatches the call to
    # {@link #reportFailedPredicate}</li>
    # <li>All other types: calls {@link Parser#notifyErrorListeners} to report
    # the exception</li>
    # </ul>
    #
    def reportError(self, recognizer:Parser, e:RecognitionException):
       # if we've already reported an error and have not matched a token
       # yet successfully, don't report any errors.
        if self.inErrorRecoveryMode(recognizer):
            return # don't report spurious errors
        self.beginErrorCondition(recognizer)
        if isinstance( e, NoViableAltException ):
            self.reportNoViableAlternative(recognizer, e)
        elif isinstance( e, InputMismatchException ):
            self.reportInputMismatch(recognizer, e)
        elif isinstance( e, FailedPredicateException ):
            self.reportFailedPredicate(recognizer, e)
        else:
            print("unknown recognition error type: " + type(e).__name__)
            recognizer.notifyErrorListeners(e.message, e.offendingToken, e)

    #
    # {@inheritDoc}
    #
    # <p>The default implementation resynchronizes the parser by consuming tokens
    # until we find one in the resynchronization set--loosely the set of tokens
    # that can follow the current rule.</p>
    #
    def recover(self, recognizer:Parser, e:RecognitionException):
        if self.lastErrorIndex==recognizer.getInputStream().index \
            and self.lastErrorStates is not None \
            and recognizer.state in self.lastErrorStates:
           # uh oh, another error at same token index and previously-visited
           # state in ATN; must be a case where LT(1) is in the recovery
           # token set so nothing got consumed. Consume a single token
           # at least to prevent an infinite loop; this is a failsafe.
            recognizer.consume()

        self.lastErrorIndex = recognizer._input.index
        if self.lastErrorStates is None:
            self.lastErrorStates = []
        self.lastErrorStates.append(recognizer.state)
        followSet = self.getErrorRecoverySet(recognizer)
        self.consumeUntil(recognizer, followSet)

    # The default implementation of {@link ANTLRErrorStrategy#sync} makes sure
    # that the current lookahead symbol is consistent with what were expecting
    # at this point in the ATN. You can call this anytime but ANTLR only
    # generates code to check before subrules/loops and each iteration.
    #
    # <p>Implements Jim Idle's magic sync mechanism in closures and optional
    # subrules. E.g.,</p>
    #
    # <pre>
    # a : sync ( stuff sync )* ;
    # sync : {consume to what can follow sync} ;
    # </pre>
    #
    # At the start of a sub rule upon error, {@link #sync} performs single
    # token deletion, if possible. If it can't do that, it bails on the current
    # rule and uses the default error recovery, which consumes until the
    # resynchronization set of the current rule.
    #
    # <p>If the sub rule is optional ({@code (...)?}, {@code (...)*}, or block
    # with an empty alternative), then the expected set includes what follows
    # the subrule.</p>
    #
    # <p>During loop iteration, it consumes until it sees a token that can start a
    # sub rule or what follows loop. Yes, that is pretty aggressive. We opt to
    # stay in the loop as long as possible.</p>
    #
    # <p><strong>ORIGINS</strong></p>
    #
    # <p>Previous versions of ANTLR did a poor job of their recovery within loops.
    # A single mismatch token or missing token would force the parser to bail
    # out of the entire rules surrounding the loop. So, for rule</p>
    #
    # <pre>
    # classDef : 'class' ID '{' member* '}'
    # </pre>
    #
    # input with an extra token between members would force the parser to
    # consume until it found the next class definition rather than the next
    # member definition of the current class.
    #
    # <p>This functionality cost a little bit of effort because the parser has to
    # compare token set at the start of the loop and at each iteration. If for
    # some reason speed is suffering for you, you can turn off this
    # functionality by simply overriding this method as a blank { }.</p>
    #
    def sync(self, recognizer:Parser):
        # If already recovering, don't try to sync
        if self.inErrorRecoveryMode(recognizer):
            return

        s = recognizer._interp.atn.states[recognizer.state]
        la = recognizer.getTokenStream().LA(1)
        # try cheaper subset first; might get lucky. seems to shave a wee bit off
        nextTokens = recognizer.atn.nextTokens(s)
        if Token.EPSILON in nextTokens or la in nextTokens:
            return

        if s.stateType in [ATNState.BLOCK_START, ATNState.STAR_BLOCK_START,
                                ATNState.PLUS_BLOCK_START, ATNState.STAR_LOOP_ENTRY]:
           # report error and recover if possible
            if self.singleTokenDeletion(recognizer)is not None:
                return
            else:
                raise InputMismatchException(recognizer)

        elif s.stateType in [ATNState.PLUS_LOOP_BACK, ATNState.STAR_LOOP_BACK]:
            self.reportUnwantedToken(recognizer)
            expecting = recognizer.getExpectedTokens()
            whatFollowsLoopIterationOrRule = expecting.addSet(self.getErrorRecoverySet(recognizer))
            self.consumeUntil(recognizer, whatFollowsLoopIterationOrRule)

        else:
           # do nothing if we can't identify the exact kind of ATN state
           pass

    # This is called by {@link #reportError} when the exception is a
    # {@link NoViableAltException}.
    #
    # @see #reportError
    #
    # @param recognizer the parser instance
    # @param e the recognition exception
    #
    def reportNoViableAlternative(self, recognizer:Parser, e:NoViableAltException):
        tokens = recognizer.getTokenStream()
        if tokens is not None:
            if e.startToken.type==Token.EOF:
                input = "<EOF>"
            else:
                input = tokens.getText((e.startToken, e.offendingToken))
        else:
            input = "<unknown input>"
        msg = "no viable alternative at input " + self.escapeWSAndQuote(input)
        recognizer.notifyErrorListeners(msg, e.offendingToken, e)

    #
    # This is called by {@link #reportError} when the exception is an
    # {@link InputMismatchException}.
    #
    # @see #reportError
    #
    # @param recognizer the parser instance
    # @param e the recognition exception
    #
    def reportInputMismatch(self, recognizer:Parser, e:InputMismatchException):
        msg = "mismatched input " + self.getTokenErrorDisplay(e.offendingToken) \
              + " expecting " + e.getExpectedTokens().toString(recognizer.literalNames, recognizer.symbolicNames)
        recognizer.notifyErrorListeners(msg, e.offendingToken, e)

    #
    # This is called by {@link #reportError} when the exception is a
    # {@link FailedPredicateException}.
    #
    # @see #reportError
    #
    # @param recognizer the parser instance
    # @param e the recognition exception
    #
    def reportFailedPredicate(self, recognizer, e):
        ruleName = recognizer.ruleNames[recognizer._ctx.getRuleIndex()]
        msg = "rule " + ruleName + " " + e.message
        recognizer.notifyErrorListeners(msg, e.offendingToken, e)

    # This method is called to report a syntax error which requires the removal
    # of a token from the input stream. At the time this method is called, the
    # erroneous symbol is current {@code LT(1)} symbol and has not yet been
    # removed from the input stream. When this method returns,
    # {@code recognizer} is in error recovery mode.
    #
    # <p>This method is called when {@link #singleTokenDeletion} identifies
    # single-token deletion as a viable recovery strategy for a mismatched
    # input error.</p>
    #
    # <p>The default implementation simply returns if the handler is already in
    # error recovery mode. Otherwise, it calls {@link #beginErrorCondition} to
    # enter error recovery mode, followed by calling
    # {@link Parser#notifyErrorListeners}.</p>
    #
    # @param recognizer the parser instance
    #
    def reportUnwantedToken(self, recognizer:Parser):
        if self.inErrorRecoveryMode(recognizer):
            return

        self.beginErrorCondition(recognizer)
        t = recognizer.getCurrentToken()
        tokenName = self.getTokenErrorDisplay(t)
        expecting = self.getExpectedTokens(recognizer)
        msg = "extraneous input " + tokenName + " expecting " \
            + expecting.toString(recognizer.literalNames, recognizer.symbolicNames)
        recognizer.notifyErrorListeners(msg, t, None)

    # This method is called to report a syntax error which requires the
    # insertion of a missing token into the input stream. At the time this
    # method is called, the missing token has not yet been inserted. When this
    # method returns, {@code recognizer} is in error recovery mode.
    #
    # <p>This method is called when {@link #singleTokenInsertion} identifies
    # single-token insertion as a viable recovery strategy for a mismatched
    # input error.</p>
    #
    # <p>The default implementation simply returns if the handler is already in
    # error recovery mode. Otherwise, it calls {@link #beginErrorCondition} to
    # enter error recovery mode, followed by calling
    # {@link Parser#notifyErrorListeners}.</p>
    #
    # @param recognizer the parser instance
    #
    def reportMissingToken(self, recognizer:Parser):
        if self.inErrorRecoveryMode(recognizer):
            return
        self.beginErrorCondition(recognizer)
        t = recognizer.getCurrentToken()
        expecting = self.getExpectedTokens(recognizer)
        msg = "missing " + expecting.toString(recognizer.literalNames, recognizer.symbolicNames) \
              + " at " + self.getTokenErrorDisplay(t)
        recognizer.notifyErrorListeners(msg, t, None)

    # <p>The default implementation attempts to recover from the mismatched input
    # by using single token insertion and deletion as described below. If the
    # recovery attempt fails, this method throws an
    # {@link InputMismatchException}.</p>
    #
    # <p><strong>EXTRA TOKEN</strong> (single token deletion)</p>
    #
    # <p>{@code LA(1)} is not what we are looking for. If {@code LA(2)} has the
    # right token, however, then assume {@code LA(1)} is some extra spurious
    # token and delete it. Then consume and return the next token (which was
    # the {@code LA(2)} token) as the successful result of the match operation.</p>
    #
    # <p>This recovery strategy is implemented by {@link #singleTokenDeletion}.</p>
    #
    # <p><strong>MISSING TOKEN</strong> (single token insertion)</p>
    #
    # <p>If current token (at {@code LA(1)}) is consistent with what could come
    # after the expected {@code LA(1)} token, then assume the token is missing
    # and use the parser's {@link TokenFactory} to create it on the fly. The
    # "insertion" is performed by returning the created token as the successful
    # result of the match operation.</p>
    #
    # <p>This recovery strategy is implemented by {@link #singleTokenInsertion}.</p>
    #
    # <p><strong>EXAMPLE</strong></p>
    #
    # <p>For example, Input {@code i=(3;} is clearly missing the {@code ')'}. When
    # the parser returns from the nested call to {@code expr}, it will have
    # call chain:</p>
    #
    # <pre>
    # stat &rarr; expr &rarr; atom
    # </pre>
    #
    # and it will be trying to match the {@code ')'} at this point in the
    # derivation:
    #
    # <pre>
    # =&gt; ID '=' '(' INT ')' ('+' atom)* ';'
    #                    ^
    # </pre>
    #
    # The attempt to match {@code ')'} will fail when it sees {@code ';'} and
    # call {@link #recoverInline}. To recover, it sees that {@code LA(1)==';'}
    # is in the set of tokens that can follow the {@code ')'} token reference
    # in rule {@code atom}. It can assume that you forgot the {@code ')'}.
    #
    def recoverInline(self, recognizer:Parser):
        # SINGLE TOKEN DELETION
        matchedSymbol = self.singleTokenDeletion(recognizer)
        if matchedSymbol is not None:
            # we have deleted the extra token.
            # now, move past ttype token as if all were ok
            recognizer.consume()
            return matchedSymbol

        # SINGLE TOKEN INSERTION
        if self.singleTokenInsertion(recognizer):
            return self.getMissingSymbol(recognizer)

        # even that didn't work; must throw the exception
        raise InputMismatchException(recognizer)

    #
    # This method implements the single-token insertion inline error recovery
    # strategy. It is called by {@link #recoverInline} if the single-token
    # deletion strategy fails to recover from the mismatched input. If this
    # method returns {@code true}, {@code recognizer} will be in error recovery
    # mode.
    #
    # <p>This method determines whether or not single-token insertion is viable by
    # checking if the {@code LA(1)} input symbol could be successfully matched
    # if it were instead the {@code LA(2)} symbol. If this method returns
    # {@code true}, the caller is responsible for creating and inserting a
    # token with the correct type to produce this behavior.</p>
    #
    # @param recognizer the parser instance
    # @return {@code true} if single-token insertion is a viable recovery
    # strategy for the current mismatched input, otherwise {@code false}
    #
    def singleTokenInsertion(self, recognizer:Parser):
        currentSymbolType = recognizer.getTokenStream().LA(1)
        # if current token is consistent with what could come after current
        # ATN state, then we know we're missing a token; error recovery
        # is free to conjure up and insert the missing token
        atn = recognizer._interp.atn
        currentState = atn.states[recognizer.state]
        next = currentState.transitions[0].target
        expectingAtLL2 = atn.nextTokens(next, recognizer._ctx)
        if currentSymbolType in expectingAtLL2:
            self.reportMissingToken(recognizer)
            return True
        else:
            return False

    # This method implements the single-token deletion inline error recovery
    # strategy. It is called by {@link #recoverInline} to attempt to recover
    # from mismatched input. If this method returns null, the parser and error
    # handler state will not have changed. If this method returns non-null,
    # {@code recognizer} will <em>not</em> be in error recovery mode since the
    # returned token was a successful match.
    #
    # <p>If the single-token deletion is successful, this method calls
    # {@link #reportUnwantedToken} to report the error, followed by
    # {@link Parser#consume} to actually "delete" the extraneous token. Then,
    # before returning {@link #reportMatch} is called to signal a successful
    # match.</p>
    #
    # @param recognizer the parser instance
    # @return the successfully matched {@link Token} instance if single-token
    # deletion successfully recovers from the mismatched input, otherwise
    # {@code null}
    #
    def singleTokenDeletion(self, recognizer:Parser):
        nextTokenType = recognizer.getTokenStream().LA(2)
        expecting = self.getExpectedTokens(recognizer)
        if nextTokenType in expecting:
            self.reportUnwantedToken(recognizer)
            # print("recoverFromMismatchedToken deleting " \
            #     + str(recognizer.getTokenStream().LT(1)) \
            #     + " since " + str(recognizer.getTokenStream().LT(2)) \
            #     + " is what we want", file=sys.stderr)
            recognizer.consume() # simply delete extra token
            # we want to return the token we're actually matching
            matchedSymbol = recognizer.getCurrentToken()
            self.reportMatch(recognizer) # we know current token is correct
            return matchedSymbol
        else:
            return None

    # Conjure up a missing token during error recovery.
    #
    #  The recognizer attempts to recover from single missing
    #  symbols. But, actions might refer to that missing symbol.
    #  For example, x=ID {f($x);}. The action clearly assumes
    #  that there has been an identifier matched previously and that
    #  $x points at that token. If that token is missing, but
    #  the next token in the stream is what we want we assume that
    #  this token is missing and we keep going. Because we
    #  have to return some token to replace the missing token,
    #  we have to conjure one up. This method gives the user control
    #  over the tokens returned for missing tokens. Mostly,
    #  you will want to create something special for identifier
    #  tokens. For literals such as '{' and ',', the default
    #  action in the parser or tree parser works. It simply creates
    #  a CommonToken of the appropriate type. The text will be the token.
    #  If you change what tokens must be created by the lexer,
    #  override this method to create the appropriate tokens.
    #
    def getMissingSymbol(self, recognizer:Parser):
        currentSymbol = recognizer.getCurrentToken()
        expecting = self.getExpectedTokens(recognizer)
        expectedTokenType = expecting[0] # get any element
        if expectedTokenType==Token.EOF:
            tokenText = "<missing EOF>"
        else:
            name = None
            if expectedTokenType < len(recognizer.literalNames):
                name = recognizer.literalNames[expectedTokenType]
            if name is None and expectedTokenType < len(recognizer.symbolicNames):
                name = recognizer.symbolicNames[expectedTokenType]
            tokenText = "<missing " + str(name) + ">"
        current = currentSymbol
        lookback = recognizer.getTokenStream().LT(-1)
        if current.type==Token.EOF and lookback is not None:
            current = lookback
        return recognizer.getTokenFactory().create(current.source,
            expectedTokenType, tokenText, Token.DEFAULT_CHANNEL,
            -1, -1, current.line, current.column)

    def getExpectedTokens(self, recognizer:Parser):
        return recognizer.getExpectedTokens()

    # How should a token be displayed in an error message? The default
    #  is to display just the text, but during development you might
    #  want to have a lot of information spit out.  Override in that case
    #  to use t.toString() (which, for CommonToken, dumps everything about
    #  the token). This is better than forcing you to override a method in
    #  your token objects because you don't have to go modify your lexer
    #  so that it creates a new Java type.
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
        return self.escapeWSAndQuote(s)

    def escapeWSAndQuote(self, s:str):
        s = s.replace("\n","\\n")
        s = s.replace("\r","\\r")
        s = s.replace("\t","\\t")
        return "'" + s + "'"

    #  Compute the error recovery set for the current rule.  During
    #  rule invocation, the parser pushes the set of tokens that can
    #  follow that rule reference on the stack; this amounts to
    #  computing FIRST of what follows the rule reference in the
    #  enclosing rule. See LinearApproximator.FIRST().
    #  This local follow set only includes tokens
    #  from within the rule; i.e., the FIRST computation done by
    #  ANTLR stops at the end of a rule.
    #
    #  EXAMPLE
    #
    #  When you find a "no viable alt exception", the input is not
    #  consistent with any of the alternatives for rule r.  The best
    #  thing to do is to consume tokens until you see something that
    #  can legally follow a call to r#or* any rule that called r.
    #  You don't want the exact set of viable next tokens because the
    #  input might just be missing a token--you might consume the
    #  rest of the input looking for one of the missing tokens.
    #
    #  Consider grammar:
    #
    #  a : '[' b ']'
    #    | '(' b ')'
    #    ;
    #  b : c '^' INT ;
    #  c : ID
    #    | INT
    #    ;
    #
    #  At each rule invocation, the set of tokens that could follow
    #  that rule is pushed on a stack.  Here are the various
    #  context-sensitive follow sets:
    #
    #  FOLLOW(b1_in_a) = FIRST(']') = ']'
    #  FOLLOW(b2_in_a) = FIRST(')') = ')'
    #  FOLLOW(c_in_b) = FIRST('^') = '^'
    #
    #  Upon erroneous input "[]", the call chain is
    #
    #  a -> b -> c
    #
    #  and, hence, the follow context stack is:
    #
    #  depth     follow set       start of rule execution
    #    0         <EOF>                    a (from main())
    #    1          ']'                     b
    #    2          '^'                     c
    #
    #  Notice that ')' is not included, because b would have to have
    #  been called from a different context in rule a for ')' to be
    #  included.
    #
    #  For error recovery, we cannot consider FOLLOW(c)
    #  (context-sensitive or otherwise).  We need the combined set of
    #  all context-sensitive FOLLOW sets--the set of all tokens that
    #  could follow any reference in the call chain.  We need to
    #  resync to one of those tokens.  Note that FOLLOW(c)='^' and if
    #  we resync'd to that token, we'd consume until EOF.  We need to
    #  sync to context-sensitive FOLLOWs for a, b, and c: {']','^'}.
    #  In this case, for input "[]", LA(1) is ']' and in the set, so we would
    #  not consume anything. After printing an error, rule c would
    #  return normally.  Rule b would not find the required '^' though.
    #  At this point, it gets a mismatched token error and throws an
    #  exception (since LA(1) is not in the viable following token
    #  set).  The rule exception handler tries to recover, but finds
    #  the same recovery set and doesn't consume anything.  Rule b
    #  exits normally returning to rule a.  Now it finds the ']' (and
    #  with the successful match exits errorRecovery mode).
    #
    #  So, you can see that the parser walks up the call chain looking
    #  for the token that was a member of the recovery set.
    #
    #  Errors are not generated in errorRecovery mode.
    #
    #  ANTLR's error recovery mechanism is based upon original ideas:
    #
    #  "Algorithms + Data Structures = Programs" by Niklaus Wirth
    #
    #  and
    #
    #  "A note on error recovery in recursive descent parsers":
    #  http:#portal.acm.org/citation.cfm?id=947902.947905
    #
    #  Later, Josef Grosch had some good ideas:
    #
    #  "Efficient and Comfortable Error Recovery in Recursive Descent
    #  Parsers":
    #  ftp:#www.cocolab.com/products/cocktail/doca4.ps/ell.ps.zip
    #
    #  Like Grosch I implement context-sensitive FOLLOW sets that are combined
    #  at run-time upon error to avoid overhead during parsing.
    #
    def getErrorRecoverySet(self, recognizer:Parser):
        atn = recognizer._interp.atn
        ctx = recognizer._ctx
        recoverSet = IntervalSet()
        while ctx is not None and ctx.invokingState>=0:
            # compute what follows who invoked us
            invokingState = atn.states[ctx.invokingState]
            rt = invokingState.transitions[0]
            follow = atn.nextTokens(rt.followState)
            recoverSet.addSet(follow)
            ctx = ctx.parentCtx
        recoverSet.removeOne(Token.EPSILON)
        return recoverSet

    # Consume tokens until one matches the given token set.#
    def consumeUntil(self, recognizer:Parser, set_:set):
        ttype = recognizer.getTokenStream().LA(1)
        while ttype != Token.EOF and not ttype in set_:
            recognizer.consume()
            ttype = recognizer.getTokenStream().LA(1)


#
# This implementation of {@link ANTLRErrorStrategy} responds to syntax errors
# by immediately canceling the parse operation with a
# {@link ParseCancellationException}. The implementation ensures that the
# {@link ParserRuleContext#exception} field is set for all parse tree nodes
# that were not completed prior to encountering the error.
#
# <p>
# This error strategy is useful in the following scenarios.</p>
#
# <ul>
# <li><strong>Two-stage parsing:</strong> This error strategy allows the first
# stage of two-stage parsing to immediately terminate if an error is
# encountered, and immediately fall back to the second stage. In addition to
# avoiding wasted work by attempting to recover from errors here, the empty
# implementation of {@link BailErrorStrategy#sync} improves the performance of
# the first stage.</li>
# <li><strong>Silent validation:</strong> When syntax errors are not being
# reported or logged, and the parse result is simply ignored if errors occur,
# the {@link BailErrorStrategy} avoids wasting work on recovering from errors
# when the result will be ignored either way.</li>
# </ul>
#
# <p>
# {@code myparser.setErrorHandler(new BailErrorStrategy());}</p>
#
# @see Parser#setErrorHandler(ANTLRErrorStrategy)
#
class BailErrorStrategy(DefaultErrorStrategy):
    # Instead of recovering from exception {@code e}, re-throw it wrapped
    #  in a {@link ParseCancellationException} so it is not caught by the
    #  rule function catches.  Use {@link Exception#getCause()} to get the
    #  original {@link RecognitionException}.
    #
    def recover(self, recognizer:Parser, e:RecognitionException):
        context = recognizer._ctx
        while context is not None:
            context.exception = e
            context = context.parentCtx
        raise ParseCancellationException(e)

    # Make sure we don't attempt to recover inline; if the parser
    #  successfully recovers, it won't throw an exception.
    #
    def recoverInline(self, recognizer:Parser):
        self.recover(recognizer, InputMismatchException(recognizer))

    # Make sure we don't attempt to recover from problems in subrules.#
    def sync(self, recognizer:Parser):
        pass

del Parser