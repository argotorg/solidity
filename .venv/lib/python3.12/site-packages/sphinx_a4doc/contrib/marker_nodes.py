import docutils.nodes
import sphinx.util.docutils
import sphinx.application


class MarkerNode(docutils.nodes.Element):
    pass


class DocstringMarker(sphinx.util.docutils.SphinxDirective):
    """
    This marker allows customizing where grammar docstring will be rendered.

    By default, grammar docstring (i.e., the comment at the very top of
    a grammar file) will be added to the end of the autogrammar directive.
    However, if there is a docstring marker present, grammar docstring
    will be rendered on its place.

    **Example:**

    .. code-block:: rst

       .. a4:autogrammar:: Json

          (1) This is the description of the grammar.

          .. docstring-marker::

          (2) This is the continuation of the description.

    In this case, the grammar docstring will be rendered
    between ``(1)`` and ``(2)``.

    """

    def run(self):
        return [MarkerNode(marker='docstring')]


class MembersMarker(sphinx.util.docutils.SphinxDirective):
    """
    This marker allows customizing where rule descriptions will be rendered.

    See :rst:dir:`docstring-marker`.

    """

    def run(self):
        return [MarkerNode(marker='members')]


def find_marker(nodes, marker: str):
    """
    Find a marker node with the given mark.

    """

    for node in nodes:
        if isinstance(node, MarkerNode) and node['marker'] == marker:
            return node
    return None


def find_or_add_marker(nodes, marker: str):
    """
    Find a marker node with the given mark or insert one if not found.

    """

    node = find_marker(nodes, marker)
    if node is None:
        node = MarkerNode(marker=marker)
        nodes += node
    return node


def remove_marker_nodes(app, doctree, fromdocname):
    for node in doctree.traverse(MarkerNode):
        node.parent.remove(node)


def setup(app: sphinx.application.Sphinx):
    app.add_node(MarkerNode)

    app.add_directive('docstring-marker', DocstringMarker)
    app.add_directive('members-marker', MembersMarker)

    app.connect('doctree-resolved', remove_marker_nodes)

    return {
        'version': '1.0.0',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
