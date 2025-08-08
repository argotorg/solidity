import os

import sphinx.application

from sphinx_a4doc.domain import A4Domain
from sphinx_a4doc.diagram_directive import RailroadDiagramNode, RailroadDiagram, LexerRuleDiagram, ParserRuleDiagram
from sphinx_a4doc.settings import register_settings
from sphinx_a4doc.autodoc_directive import AutoGrammar, AutoRule


def config_inited(app, config):
    static_path = os.path.join(os.path.dirname(__file__), '_static')
    config.html_static_path.append(static_path)


def setup(app: sphinx.application.Sphinx):
    app.setup_extension('sphinx_a4doc.contrib.marker_nodes')

    app.add_domain(A4Domain)

    app.add_node(RailroadDiagramNode,
                 text=(RailroadDiagramNode.visit_node_text,
                       RailroadDiagramNode.depart_node),
                 html=(RailroadDiagramNode.visit_node_html,
                       RailroadDiagramNode.depart_node),
                 latex=(RailroadDiagramNode.visit_node_latex,
                        RailroadDiagramNode.depart_node),
                 man=(RailroadDiagramNode.visit_node_man,
                      RailroadDiagramNode.depart_node))

    app.add_directive('railroad-diagram', RailroadDiagram)
    app.add_directive('lexer-rule-diagram', LexerRuleDiagram)
    app.add_directive('parser-rule-diagram', ParserRuleDiagram)

    app.add_directive_to_domain('a4', 'autogrammar', AutoGrammar)
    app.add_directive_to_domain('a4', 'autorule', AutoRule)

    register_settings(app)

    app.add_css_file('a4_railroad_diagram.css')

    app.connect('config-inited', config_inited)

    return {
        'version': '1.0.0',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
