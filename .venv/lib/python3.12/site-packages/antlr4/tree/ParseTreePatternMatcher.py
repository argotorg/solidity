#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#

#
# A tree pattern matching mechanism for ANTLR {@link ParseTree}s.
#
# <p>Patterns are strings of source input text with special tags representing
# token or rule references such as:</p>
#
# <p>{@code <ID> = <expr>;}</p>
#
# <p>Given a pattern start rule such as {@code statement}, this object constructs
# a {@link ParseTree} with placeholders for the {@code ID} and {@code expr}
# subtree. Then the {@link #match} routines can compare an actual
# {@link ParseTree} from a parse with this pattern. Tag {@code <ID>} matches
# any {@code ID} token and tag {@code <expr>} references the result of the
# {@code expr} rule (generally an instance of {@code ExprContext}.</p>
#
# <p>Pattern {@code x = 0;} is a similar pattern that matches the same pattern
# except that it requires the identifier to be {@code x} and the expression to
# be {@code 0}.</p>
#
# <p>The {@link #matches} routines return {@code true} or {@code false} based
# upon a match for the tree rooted at the parameter sent in. The
# {@link #match} routines return a {@link ParseTreeMatch} object that
# contains the parse tree, the parse tree pattern, and a map from tag name to
# matched nodes (more below). A subtree that fails to match, returns with
# {@link ParseTreeMatch#mismatchedNode} set to the first tree node that did not
# match.</p>
#
# <p>For efficiency, you can compile a tree pattern in string form to a
# {@link ParseTreePattern} object.</p>
#
# <p>See {@code TestParseTreeMatcher} for lots of examples.
# {@link ParseTreePattern} has two static helper methods:
# {@link ParseTreePattern#findAll} and {@link ParseTreePattern#match} that
# are easy to use but not super efficient because they create new
# {@link ParseTreePatternMatcher} objects each time and have to compile the
# pattern in string form before using it.</p>
#
# <p>The lexer and parser that you pass into the {@link ParseTreePatternMatcher}
# constructor are used to parse the pattern in string form. The lexer converts
# the {@code <ID> = <expr>;} into a sequence of four tokens (assuming lexer
# throws out whitespace or puts it on a hidden channel). Be aware that the
# input stream is reset for the lexer (but not the parser; a
# {@link ParserInterpreter} is created to parse the input.). Any user-defined
# fields you have put into the lexer might get changed when this mechanism asks
# it to scan the pattern string.</p>
#
# <p>Normally a parser does not accept token {@code <expr>} as a valid
# {@code expr} but, from the parser passed in, we create a special version of
# the underlying grammar representation (an {@link ATN}) that allows imaginary
# tokens representing rules ({@code <expr>}) to match entire rules. We call
# these <em>bypass alternatives</em>.</p>
#
# <p>Delimiters are {@code <} and {@code >}, with {@code \} as the escape string
# by default, but you can set them to whatever you want using
# {@link #setDelimiters}. You must escape both start and stop strings
# {@code \<} and {@code \>}.</p>
#
from antlr4.CommonTokenStream import CommonTokenStream
from antlr4.InputStream import InputStream
from antlr4.ParserRuleContext import ParserRuleContext
from antlr4.Lexer import Lexer
from antlr4.ListTokenSource import ListTokenSource
from antlr4.Token import Token
from antlr4.error.ErrorStrategy import BailErrorStrategy
from antlr4.error.Errors import RecognitionException, ParseCancellationException
from antlr4.tree.Chunk import TagChunk, TextChunk
from antlr4.tree.RuleTagToken import RuleTagToken
from antlr4.tree.TokenTagToken import TokenTagToken
from antlr4.tree.Tree import ParseTree, TerminalNode, RuleNode

# need forward declaration
Parser = None
ParseTreePattern = None

class CannotInvokeStartRule(Exception):

    def __init__(self, e:Exception):
        super().__init__(e)

class StartRuleDoesNotConsumeFullPattern(Exception):

    pass


class ParseTreePatternMatcher(object):

    # Constructs a {@link ParseTreePatternMatcher} or from a {@link Lexer} and
    # {@link Parser} object. The lexer input stream is altered for tokenizing
    # the tree patterns. The parser is used as a convenient mechanism to get
    # the grammar name, plus token, rule names.
    def __init__(self, lexer:Lexer, parser:Parser):
        self.lexer = lexer
        self.parser = parser
        self.start = "<"
        self.stop = ">"
        self.escape = "\\"  # e.g., \< and \> must escape BOTH!

    # Set the delimiters used for marking rule and token tags within concrete
    # syntax used by the tree pattern parser.
    #
    # @param start The start delimiter.
    # @param stop The stop delimiter.
    # @param escapeLeft The escape sequence to use for escaping a start or stop delimiter.
    #
    # @exception IllegalArgumentException if {@code start} is {@code null} or empty.
    # @exception IllegalArgumentException if {@code stop} is {@code null} or empty.
    #
    def setDelimiters(self, start:str, stop:str, escapeLeft:str):
        if start is None or len(start)==0:
            raise Exception("start cannot be null or empty")
        if stop is None or len(stop)==0:
            raise Exception("stop cannot be null or empty")
        self.start = start
        self.stop = stop
        self.escape = escapeLeft

    # Does {@code pattern} matched as rule {@code patternRuleIndex} match {@code tree}?#
    def matchesRuleIndex(self, tree:ParseTree, pattern:str, patternRuleIndex:int):
        p = self.compileTreePattern(pattern, patternRuleIndex)
        return self.matches(tree, p)

    # Does {@code pattern} matched as rule patternRuleIndex match tree? Pass in a
    #  compiled pattern instead of a string representation of a tree pattern.
    #
    def matchesPattern(self, tree:ParseTree, pattern:ParseTreePattern):
        mismatchedNode = self.matchImpl(tree, pattern.patternTree, dict())
        return mismatchedNode is None

    #
    # Compare {@code pattern} matched as rule {@code patternRuleIndex} against
    # {@code tree} and return a {@link ParseTreeMatch} object that contains the
    # matched elements, or the node at which the match failed.
    #
    def matchRuleIndex(self, tree:ParseTree, pattern:str, patternRuleIndex:int):
        p = self.compileTreePattern(pattern, patternRuleIndex)
        return self.matchPattern(tree, p)

    #
    # Compare {@code pattern} matched against {@code tree} and return a
    # {@link ParseTreeMatch} object that contains the matched elements, or the
    # node at which the match failed. Pass in a compiled pattern instead of a
    # string representation of a tree pattern.
    #
    def matchPattern(self, tree:ParseTree, pattern:ParseTreePattern):
        labels = dict()
        mismatchedNode = self.matchImpl(tree, pattern.patternTree, labels)
        from antlr4.tree.ParseTreeMatch import ParseTreeMatch
        return ParseTreeMatch(tree, pattern, labels, mismatchedNode)

    #
    # For repeated use of a tree pattern, compile it to a
    # {@link ParseTreePattern} using this method.
    #
    def compileTreePattern(self, pattern:str, patternRuleIndex:int):
        tokenList = self.tokenize(pattern)
        tokenSrc = ListTokenSource(tokenList)
        tokens = CommonTokenStream(tokenSrc)
        from antlr4.ParserInterpreter import ParserInterpreter
        parserInterp = ParserInterpreter(self.parser.grammarFileName, self.parser.tokenNames,
                                self.parser.ruleNames, self.parser.getATNWithBypassAlts(),tokens)
        tree = None
        try:
            parserInterp.setErrorHandler(BailErrorStrategy())
            tree = parserInterp.parse(patternRuleIndex)
        except ParseCancellationException as e:
            raise e.cause
        except RecognitionException as e:
            raise e
        except Exception as e:
            raise CannotInvokeStartRule(e)

        # Make sure tree pattern compilation checks for a complete parse
        if tokens.LA(1)!=Token.EOF:
            raise StartRuleDoesNotConsumeFullPattern()

        from antlr4.tree.ParseTreePattern import ParseTreePattern
        return ParseTreePattern(self, pattern, patternRuleIndex, tree)

    #
    # Recursively walk {@code tree} against {@code patternTree}, filling
    # {@code match.}{@link ParseTreeMatch#labels labels}.
    #
    # @return the first node encountered in {@code tree} which does not match
    # a corresponding node in {@code patternTree}, or {@code null} if the match
    # was successful. The specific node returned depends on the matching
    # algorithm used by the implementation, and may be overridden.
    #
    def matchImpl(self, tree:ParseTree, patternTree:ParseTree, labels:dict):
        if tree is None:
            raise Exception("tree cannot be null")
        if patternTree is None:
            raise Exception("patternTree cannot be null")

        # x and <ID>, x and y, or x and x; or could be mismatched types
        if isinstance(tree, TerminalNode) and isinstance(patternTree, TerminalNode ):
            mismatchedNode = None
            # both are tokens and they have same type
            if tree.symbol.type == patternTree.symbol.type:
                if isinstance( patternTree.symbol, TokenTagToken ): # x and <ID>
                    tokenTagToken = patternTree.symbol
                    # track label->list-of-nodes for both token name and label (if any)
                    self.map(labels, tokenTagToken.tokenName, tree)
                    if tokenTagToken.label is not None:
                        self.map(labels, tokenTagToken.label, tree)
                elif tree.getText()==patternTree.getText():
                    # x and x
                    pass
                else:
                    # x and y
                    if mismatchedNode is None:
                        mismatchedNode = tree
            else:
                if mismatchedNode is None:
                    mismatchedNode = tree

            return mismatchedNode

        if isinstance(tree, ParserRuleContext) and isinstance(patternTree, ParserRuleContext):
            mismatchedNode = None
            # (expr ...) and <expr>
            ruleTagToken = self.getRuleTagToken(patternTree)
            if ruleTagToken is not None:
                m = None
                if tree.ruleContext.ruleIndex == patternTree.ruleContext.ruleIndex:
                    # track label->list-of-nodes for both rule name and label (if any)
                    self.map(labels, ruleTagToken.ruleName, tree)
                    if ruleTagToken.label is not None:
                        self.map(labels, ruleTagToken.label, tree)
                else:
                    if mismatchedNode is None:
                        mismatchedNode = tree

                return mismatchedNode

            # (expr ...) and (expr ...)
            if tree.getChildCount()!=patternTree.getChildCount():
                if mismatchedNode is None:
                    mismatchedNode = tree
                return mismatchedNode

            n = tree.getChildCount()
            for i in range(0, n):
                childMatch = self.matchImpl(tree.getChild(i), patternTree.getChild(i), labels)
                if childMatch is not None:
                    return childMatch

            return mismatchedNode

        # if nodes aren't both tokens or both rule nodes, can't match
        return tree

    def map(self, labels, label, tree):
        v = labels.get(label, None)
        if v is None:
            v = list()
            labels[label] = v
        v.append(tree)

    # Is {@code t} {@code (expr <expr>)} subtree?#
    def getRuleTagToken(self, tree:ParseTree):
        if isinstance( tree, RuleNode ):
            if tree.getChildCount()==1 and isinstance(tree.getChild(0), TerminalNode ):
                c = tree.getChild(0)
                if isinstance( c.symbol, RuleTagToken ):
                    return c.symbol
        return None

    def tokenize(self, pattern:str):
        # split pattern into chunks: sea (raw input) and islands (<ID>, <expr>)
        chunks = self.split(pattern)

        # create token stream from text and tags
        tokens = list()
        for chunk in chunks:
            if isinstance( chunk, TagChunk ):
                # add special rule token or conjure up new token from name
                if chunk.tag[0].isupper():
                    ttype = self.parser.getTokenType(chunk.tag)
                    if ttype==Token.INVALID_TYPE:
                        raise Exception("Unknown token " + str(chunk.tag) + " in pattern: " + pattern)
                    tokens.append(TokenTagToken(chunk.tag, ttype, chunk.label))
                elif chunk.tag[0].islower():
                    ruleIndex = self.parser.getRuleIndex(chunk.tag)
                    if ruleIndex==-1:
                        raise Exception("Unknown rule " + str(chunk.tag) + " in pattern: " + pattern)
                    ruleImaginaryTokenType = self.parser.getATNWithBypassAlts().ruleToTokenType[ruleIndex]
                    tokens.append(RuleTagToken(chunk.tag, ruleImaginaryTokenType, chunk.label))
                else:
                    raise Exception("invalid tag: " + str(chunk.tag) + " in pattern: " + pattern)
            else:
                self.lexer.setInputStream(InputStream(chunk.text))
                t = self.lexer.nextToken()
                while t.type!=Token.EOF:
                    tokens.append(t)
                    t = self.lexer.nextToken()
        return tokens

    # Split {@code <ID> = <e:expr> ;} into 4 chunks for tokenizing by {@link #tokenize}.#
    def split(self, pattern:str):
        p = 0
        n = len(pattern)
        chunks = list()
        # find all start and stop indexes first, then collect
        starts = list()
        stops = list()
        while p < n :
            if p == pattern.find(self.escape + self.start, p):
                p += len(self.escape) + len(self.start)
            elif p == pattern.find(self.escape + self.stop, p):
                p += len(self.escape) + len(self.stop)
            elif p == pattern.find(self.start, p):
                starts.append(p)
                p += len(self.start)
            elif p == pattern.find(self.stop, p):
                stops.append(p)
                p += len(self.stop)
            else:
                p += 1

        nt = len(starts)

        if nt > len(stops):
            raise Exception("unterminated tag in pattern: " + pattern)
        if nt < len(stops):
            raise Exception("missing start tag in pattern: " + pattern)

        for i in range(0, nt):
            if starts[i] >= stops[i]:
                raise Exception("tag delimiters out of order in pattern: " + pattern)

        # collect into chunks now
        if nt==0:
            chunks.append(TextChunk(pattern))

        if nt>0 and starts[0]>0: # copy text up to first tag into chunks
            text = pattern[0:starts[0]]
            chunks.add(TextChunk(text))

        for i in range(0, nt):
            # copy inside of <tag>
            tag = pattern[starts[i] + len(self.start) : stops[i]]
            ruleOrToken = tag
            label = None
            colon = tag.find(':')
            if colon >= 0:
                label = tag[0:colon]
                ruleOrToken = tag[colon+1 : len(tag)]
            chunks.append(TagChunk(label, ruleOrToken))
            if i+1 < len(starts):
                # copy from end of <tag> to start of next
                text = pattern[stops[i] + len(self.stop) : starts[i + 1]]
                chunks.append(TextChunk(text))

        if nt > 0 :
            afterLastTag = stops[nt - 1] + len(self.stop)
            if afterLastTag < n : # copy text from end of last tag to end
                text = pattern[afterLastTag : n]
                chunks.append(TextChunk(text))

        # strip out the escape sequences from text chunks but not tags
        for i in range(0, len(chunks)):
            c = chunks[i]
            if isinstance( c, TextChunk ):
                unescaped = c.text.replace(self.escape, "")
                if len(unescaped) < len(c.text):
                    chunks[i] = TextChunk(unescaped)
        return chunks
