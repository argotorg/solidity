# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#/


#  A rule context is a record of a single rule invocation. It knows
#  which context invoked it, if any. If there is no parent context, then
#  naturally the invoking state is not valid.  The parent link
#  provides a chain upwards from the current rule invocation to the root
#  of the invocation tree, forming a stack. We actually carry no
#  information about the rule associated with this context (except
#  when parsing). We keep only the state number of the invoking state from
#  the ATN submachine that invoked this. Contrast this with the s
#  pointer inside ParserRuleContext that tracks the current state
#  being "executed" for the current rule.
#
#  The parent contexts are useful for computing lookahead sets and
#  getting error information.
#
#  These objects are used during parsing and prediction.
#  For the special case of parsers, we use the subclass
#  ParserRuleContext.
#
#  @see ParserRuleContext
#/
from io import StringIO
from antlr4.tree.Tree import RuleNode, INVALID_INTERVAL, ParseTreeVisitor
from antlr4.tree.Trees import Trees

# need forward declarations
RuleContext = None
Parser = None

class RuleContext(RuleNode):

    EMPTY = None

    def __init__(self, parent:RuleContext=None, invokingState:int=-1):
        super().__init__()
        # What context invoked this rule?
        self.parentCtx = parent
        # What state invoked the rule associated with this context?
        #  The "return address" is the followState of invokingState
        #  If parent is null, this should be -1.
        self.invokingState = invokingState


    def depth(self):
        n = 0
        p = self
        while p is not None:
            p = p.parentCtx
            n += 1
        return n

    # A context is empty if there is no invoking state; meaning nobody call
    #  current context.
    def isEmpty(self):
        return self.invokingState == -1

    # satisfy the ParseTree / SyntaxTree interface

    def getSourceInterval(self):
        return INVALID_INTERVAL

    def getRuleContext(self):
        return self

    def getPayload(self):
        return self

   # Return the combined text of all child nodes. This method only considers
    #  tokens which have been added to the parse tree.
    #  <p>
    #  Since tokens on hidden channels (e.g. whitespace or comments) are not
    #  added to the parse trees, they will not appear in the output of this
    #  method.
    #/
    def getText(self):
        if self.getChildCount() == 0:
            return ""
        with StringIO() as builder:
            for child in self.getChildren():
                builder.write(child.getText())
            return builder.getvalue()

    def getRuleIndex(self):
        return -1

    # For rule associated with this parse tree internal node, return
    # the outer alternative number used to match the input. Default
    # implementation does not compute nor store this alt num. Create
    # a subclass of ParserRuleContext with backing field and set
    # option contextSuperClass.
    # to set it.
    def getAltNumber(self):
        return 0 # should use ATN.INVALID_ALT_NUMBER but won't compile

    # Set the outer alternative number for this context node. Default
    # implementation does nothing to avoid backing field overhead for
    # trees that don't need it.  Create
    # a subclass of ParserRuleContext with backing field and set
    # option contextSuperClass.
    def setAltNumber(self, altNumber:int):
        pass

    def getChild(self, i:int):
        return None

    def getChildCount(self):
        return 0

    def getChildren(self):
        for c in []:
            yield c

    def accept(self, visitor:ParseTreeVisitor):
        return visitor.visitChildren(self)

   # # Call this method to view a parse tree in a dialog box visually.#/
   #  public Future<JDialog> inspect(@Nullable Parser parser) {
   #      List<String> ruleNames = parser != null ? Arrays.asList(parser.getRuleNames()) : null;
   #      return inspect(ruleNames);
   #  }
   #
   #  public Future<JDialog> inspect(@Nullable List<String> ruleNames) {
   #      TreeViewer viewer = new TreeViewer(ruleNames, this);
   #      return viewer.open();
   #  }
   #
   # # Save this tree in a postscript file#/
   #  public void save(@Nullable Parser parser, String fileName)
   #      throws IOException, PrintException
   #  {
   #      List<String> ruleNames = parser != null ? Arrays.asList(parser.getRuleNames()) : null;
   #      save(ruleNames, fileName);
   #  }
   #
   # # Save this tree in a postscript file using a particular font name and size#/
   #  public void save(@Nullable Parser parser, String fileName,
   #                   String fontName, int fontSize)
   #      throws IOException
   #  {
   #      List<String> ruleNames = parser != null ? Arrays.asList(parser.getRuleNames()) : null;
   #      save(ruleNames, fileName, fontName, fontSize);
   #  }
   #
   # # Save this tree in a postscript file#/
   #  public void save(@Nullable List<String> ruleNames, String fileName)
   #      throws IOException, PrintException
   #  {
   #      Trees.writePS(this, ruleNames, fileName);
   #  }
   #
   # # Save this tree in a postscript file using a particular font name and size#/
   #  public void save(@Nullable List<String> ruleNames, String fileName,
   #                   String fontName, int fontSize)
   #      throws IOException
   #  {
   #      Trees.writePS(this, ruleNames, fileName, fontName, fontSize);
   #  }
   #
   # # Print out a whole tree, not just a node, in LISP format
   #  #  (root child1 .. childN). Print just a node if this is a leaf.
   #  #  We have to know the recognizer so we can get rule names.
   #  #/
   #  @Override
   #  public String toStringTree(@Nullable Parser recog) {
   #      return Trees.toStringTree(this, recog);
   #  }
   #
   # Print out a whole tree, not just a node, in LISP format
   #  (root child1 .. childN). Print just a node if this is a leaf.
   #
    def toStringTree(self, ruleNames:list=None, recog:Parser=None):
        return Trees.toStringTree(self, ruleNames=ruleNames, recog=recog)
   #  }
   #
   #  @Override
   #  public String toStringTree() {
   #      return toStringTree((List<String>)null);
   #  }
   #
    def __str__(self):
        return self.toString(None, None)

   #  @Override
   #  public String toString() {
   #      return toString((List<String>)null, (RuleContext)null);
   #  }
   #
   #  public final String toString(@Nullable Recognizer<?,?> recog) {
   #      return toString(recog, ParserRuleContext.EMPTY);
   #  }
   #
   #  public final String toString(@Nullable List<String> ruleNames) {
   #      return toString(ruleNames, null);
   #  }
   #
   #  // recog null unless ParserRuleContext, in which case we use subclass toString(...)
   #  public String toString(@Nullable Recognizer<?,?> recog, @Nullable RuleContext stop) {
   #      String[] ruleNames = recog != null ? recog.getRuleNames() : null;
   #      List<String> ruleNamesList = ruleNames != null ? Arrays.asList(ruleNames) : null;
   #      return toString(ruleNamesList, stop);
   #  }

    def toString(self, ruleNames:list, stop:RuleContext)->str:
        with StringIO() as buf:
            p = self
            buf.write("[")
            while p is not None and p is not stop:
                if ruleNames is None:
                    if not p.isEmpty():
                        buf.write(str(p.invokingState))
                else:
                    ri = p.getRuleIndex()
                    ruleName = ruleNames[ri] if ri >= 0 and ri < len(ruleNames) else str(ri)
                    buf.write(ruleName)

                if p.parentCtx is not None and (ruleNames is not None or not p.parentCtx.isEmpty()):
                    buf.write(" ")

                p = p.parentCtx

            buf.write("]")
            return buf.getvalue()

