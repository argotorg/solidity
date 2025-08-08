#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#


#
# Represents the result of matching a {@link ParseTree} against a tree pattern.
#
from io import StringIO
from antlr4.tree.ParseTreePattern import ParseTreePattern
from antlr4.tree.Tree import ParseTree


class ParseTreeMatch(object):

    #
    # Constructs a new instance of {@link ParseTreeMatch} from the specified
    # parse tree and pattern.
    #
    # @param tree The parse tree to match against the pattern.
    # @param pattern The parse tree pattern.
    # @param labels A mapping from label names to collections of
    # {@link ParseTree} objects located by the tree pattern matching process.
    # @param mismatchedNode The first node which failed to match the tree
    # pattern during the matching process.
    #
    # @exception IllegalArgumentException if {@code tree} is {@code null}
    # @exception IllegalArgumentException if {@code pattern} is {@code null}
    # @exception IllegalArgumentException if {@code labels} is {@code null}
    #
    def __init__(self, tree:ParseTree, pattern:ParseTreePattern, labels:dict, mismatchedNode:ParseTree):
        if tree is None:
            raise Exception("tree cannot be null")
        if pattern is None:
            raise Exception("pattern cannot be null")
        if labels is None:
            raise Exception("labels cannot be null")
        self.tree = tree
        self.pattern = pattern
        self.labels = labels
        self.mismatchedNode = mismatchedNode

    #
    # Get the last node associated with a specific {@code label}.
    #
    # <p>For example, for pattern {@code <id:ID>}, {@code get("id")} returns the
    # node matched for that {@code ID}. If more than one node
    # matched the specified label, only the last is returned. If there is
    # no node associated with the label, this returns {@code null}.</p>
    #
    # <p>Pattern tags like {@code <ID>} and {@code <expr>} without labels are
    # considered to be labeled with {@code ID} and {@code expr}, respectively.</p>
    #
    # @param label The label to check.
    #
    # @return The last {@link ParseTree} to match a tag with the specified
    # label, or {@code null} if no parse tree matched a tag with the label.
    #
    def get(self, label:str):
        parseTrees = self.labels.get(label, None)
        if parseTrees is None or len(parseTrees)==0:
            return None
        else:
            return parseTrees[len(parseTrees)-1]

    #
    # Return all nodes matching a rule or token tag with the specified label.
    #
    # <p>If the {@code label} is the name of a parser rule or token in the
    # grammar, the resulting list will contain both the parse trees matching
    # rule or tags explicitly labeled with the label and the complete set of
    # parse trees matching the labeled and unlabeled tags in the pattern for
    # the parser rule or token. For example, if {@code label} is {@code "foo"},
    # the result will contain <em>all</em> of the following.</p>
    #
    # <ul>
    # <li>Parse tree nodes matching tags of the form {@code <foo:anyRuleName>} and
    # {@code <foo:AnyTokenName>}.</li>
    # <li>Parse tree nodes matching tags of the form {@code <anyLabel:foo>}.</li>
    # <li>Parse tree nodes matching tags of the form {@code <foo>}.</li>
    # </ul>
    #
    # @param label The label.
    #
    # @return A collection of all {@link ParseTree} nodes matching tags with
    # the specified {@code label}. If no nodes matched the label, an empty list
    # is returned.
    #
    def getAll(self, label:str):
        nodes = self.labels.get(label, None)
        if nodes is None:
            return list()
        else:
            return nodes


    #
    # Gets a value indicating whether the match operation succeeded.
    #
    # @return {@code true} if the match operation succeeded; otherwise,
    # {@code false}.
    #
    def succeeded(self):
        return self.mismatchedNode is None

    #
    # {@inheritDoc}
    #
    def __str__(self):
        with StringIO() as buf:
            buf.write("Match ")
            buf.write("succeeded" if self.succeeded() else "failed")
            buf.write("; found ")
            buf.write(str(len(self.labels)))
            buf.write(" labels")
            return buf.getvalue()
