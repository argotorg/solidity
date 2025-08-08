import os
import dataclasses
import docutils.parsers.rst
import docutils.statemachine
import docutils.nodes
import sphinx.addnodes
import sphinx.util.docutils
import sphinx.util.nodes

from sphinx_a4doc.settings import GrammarType, OrderSettings, GroupingSettings, EndClass
from sphinx_a4doc.settings import global_namespace, autogrammar_namespace, autorule_namespace
from sphinx_a4doc.domain import Grammar, Rule
from sphinx_a4doc.diagram_directive import RailroadDiagramNode
from sphinx_a4doc.model.model import ModelCache, Model, RuleBase
from sphinx_a4doc.model.reachable_finder import find_reachable_rules
from sphinx_a4doc.model.model_renderer import Renderer, cc_to_dash
from sphinx_a4doc.contrib.marker_nodes import find_or_add_marker

from typing import *


class ModelLoaderMixin:
    used_models: Optional[Set[Model]] = None

    def load_model(self, name: str) -> Model:
        # TODO: use grammar resolver
        base_path = global_namespace.load_global_settings(self.env).base_path
        if not name.endswith('.g4'):
            name += '.g4'
        name = os.path.normpath(os.path.expanduser(name))
        path = os.path.join(base_path, name)
        model = ModelCache.instance().from_file(path)
        if self.used_models is None:
            self.used_models = set()
        self.used_models.add(model)
        return model

    def register_deps(self):
        if self.used_models is None:
            return
        seen = set()
        models = self.used_models.copy()
        while models:
            model = models.pop()
            if model in seen:
                continue
            if not model.is_in_memory():
                self.state.document.settings.record_dependencies.add(model.get_path())
            models.update(model.get_imports())
            seen.add(model)


class DocsRendererMixin:
    def render_docs(self, path: str, docs: List[Tuple[int, str]], node, titles=False):
        docs = docs or []

        for line, doc in docs:
            lines = doc.splitlines()
            items = [(path, line + i - 1) for i in range(len(lines))]

            content = docutils.statemachine.StringList(lines, items=items)

            with sphinx.util.docutils.switch_source_input(self.state, content):
                if titles:
                    sphinx.util.nodes.nested_parse_with_titles(self.state, content, node)
                else:
                    self.state.nested_parse(content, 0, node)


class AutoGrammar(Grammar, ModelLoaderMixin, DocsRendererMixin):
    """
    Autogrammar directive generates a grammar description from a ``.g4`` file.

    Its only argument, ``name``, should contain path of the grammar file
    relative to the ``a4_base_path``. File extension may be omitted.

    .. TODO: reference to global settings
    .. TODO: mention grammar resolver (once it's implemented).

    Autogrammar will read a ``.g4`` file and extract grammar name (which will
    be used for cross-referencing), grammar-level documentation comments,
    set of production rules, their documentation and contents. It will then
    generate railroad diagrams and render extracted information.

    See more on how to write documentation comments and control look of the
    automatically generated railroad diagrams in the ':ref:`grammar_comments`'
    section.

    Like :rst:dir:`autoclass` and other default autodoc directives,
    ``autogrammar`` can have contents on its own. These contents will
    be merged with the automatically generated description.

    Use :rst:dir:`docstring-marker` and :rst:dir:`members-marker` to control
    merging process.

    **Options:**

    .. rst:option:: name
                    type
                    imports
                    noindex
                    diagram-*

       Inherited from :rst:dir:`a4:grammar` directive.

       If not given, :rst:opt:`:type: <a4:grammar:type>` and
       :rst:opt:`:imports: <a4:grammar:imports>`
       will be extracted from grammar file.

    .. members-marker::

    """

    required_arguments = 1
    has_content = True

    settings = autogrammar_namespace.for_directive()

    def __init__(self, *args, **kwargs):
        super().__init__(*args, *kwargs)

        self.root_rule: Optional[RuleBase] = None

    def run(self):
        self.name = 'a4:grammar'

        if 'cc-to-dash' in self.options and 'diagram-cc-to-dash' not in self.options:
            self.options['diagram-cc-to-dash'] = self.options['cc-to-dash']

        # Load model from file
        model = self.load_model(self.arguments[0])
        # Early exit
        if model.has_errors():
            self.register_deps()
            return [
                self.state_machine.reporter.error(
                    'unable to document this grammar',
                    line=self.lineno
                )
            ]
        # Update settings from model
        if 'imports' not in self.options:
            self.options['imports'] = [
                i.get_name() for i in model.get_imports() if i.get_name()
            ]
        if 'type' not in self.options and model.get_type():
            self.options['type'] = GrammarType[model.get_type().upper()]

        self.arguments = [model.get_name()]

        self.env.temp_data.setdefault('a4:autogrammar_ctx', []).append(model.get_path())
        try:
            # Create a skeleton of the grammar description
            nodes = super(AutoGrammar, self).run()
            # If user described some rules manually, we want that descriptions
            # to replace ones obtained from the grammar file. We also want to
            # remove all descriptions temporarily to rearrange them according
            # to the `ordering` settings
            desc_content, rule_nodes = self.cut_rule_descriptions(model, nodes)
            # Set proper ref_context
            self.before_content()
            try:
                # Find place where docstring should be rendered
                doc_node = find_or_add_marker(desc_content, 'docstring')
                # Render model docstring
                self.render_docs(model.get_path(), model.get_model_docs(), doc_node)
                # Insert docstring to the document
                doc_node.replace_self(doc_node.children)
                # Find place where to insert rule descriptions
                rules_node = find_or_add_marker(desc_content, 'members')
                # Arrange rules found in the grammar file and render them
                last_section = None
                for rule in self.make_order(model):
                    if (
                        self.settings.honor_sections and
                        self.settings.ordering is OrderSettings.BY_SOURCE and
                        last_section is not rule.section
                    ):
                        last_section = rule.section
                        if last_section is not None:
                            self.render_docs(
                                rule.position.file,
                                last_section.docs,
                                rules_node,
                                True
                            )
                    # Manual description overrides autogenerated description
                    if rule.name in rule_nodes:
                        rules_node.append(rule_nodes.pop(rule.name))
                    else:
                        rules_node.extend(self.make_rule(rule))
                # Add any rule that was described manually but that wasn't found
                # in the grammar file
                for rule in sorted(rule_nodes.values(), key=lambda x: x.line):
                    rules_node.append(rule)
                # Insert rule descriptions to the document
                rules_node.replace_self(rules_node.children)
            finally:
                self.after_content()

            return nodes
        finally:
            self.env.temp_data['a4:autogrammar_ctx'].pop()
            self.register_deps()

    def cut_rule_descriptions(self, model, nodes):
        desc_content = None

        rule_nodes = {}

        for node in nodes:
            if not isinstance(node, sphinx.addnodes.desc):
                continue

            for content_node in node.children:
                if isinstance(content_node, sphinx.addnodes.desc_content):
                    desc_content = content_node
                    break
            else:
                raise RuntimeError('no desc_content can be found')
            for rule_node in node.traverse(
                lambda x: (
                    isinstance(x, sphinx.addnodes.desc) and
                    x['domain'] == 'a4' and
                    x['objtype'] == 'rule'
                )
            ):
                sig = rule_node.next_node(sphinx.addnodes.desc_signature)

                if sig is None:
                    continue

                prefix = f'a4.{model.get_name()}.'

                for ident in sig['ids']:
                    if ident.startswith(prefix):
                        rule_nodes[ident[len(prefix):]] = rule_node
                        rule_node.replace_self([])
                        break

        assert desc_content is not None

        return desc_content, rule_nodes

    def make_order(self, model: Model) -> List[RuleBase]:
        lexer_rules = []
        if self.settings.lexer_rules:
            lexer_rules = model.get_terminals()
            if not self.settings.fragments:
                lexer_rules = filter(lambda r: not r.is_fragment, lexer_rules)
            if not self.settings.undocumented:
                lexer_rules = filter(lambda r: r.documentation, lexer_rules)
        lexer_rules = list(lexer_rules)

        parser_rules = []
        if self.settings.parser_rules:
            parser_rules = model.get_non_terminals()
            if not self.settings.undocumented:
                parser_rules = filter(lambda r: r.documentation, parser_rules)
        parser_rules = list(parser_rules)

        precedence = {
            OrderSettings.BY_SOURCE: lambda rule: rule.position,
            OrderSettings.BY_NAME: lambda rule: rule.name.lower(),
        }[self.settings.ordering]

        if self.settings.grouping is GroupingSettings.MIXED:
            all_rules = sorted(lexer_rules + parser_rules, key=precedence)
        elif self.settings.grouping is GroupingSettings.LEXER_FIRST:
            all_rules = sorted(lexer_rules, key=precedence) + sorted(parser_rules, key=precedence)
        elif self.settings.grouping is GroupingSettings.PARSER_FIRST:
            all_rules = sorted(parser_rules, key=precedence) + sorted(lexer_rules, key=precedence)
        else:
            raise RuntimeError('invalid grouping parameter')

        if self.settings.only_reachable_from:
            rule_name = self.settings.only_reachable_from
            rule_model = model
            if '.' in rule_name:
                model_name, rule_name = rule_name.split('.', 1)
                rule_model = self.load_model(model_name)
            rule = rule_model.lookup(rule_name)
            self.root_rule = rule
            if rule is None:
                return all_rules
            reachable = find_reachable_rules(rule)
            return [r for r in all_rules if r in reachable]

        return all_rules

    def make_rule(self, rule: RuleBase) -> List[docutils.nodes.Node]:
        if rule.is_doxygen_nodoc or rule.is_doxygen_inline:
            return []  # implicitly disabled
        if not rule.documentation and rule.content is None:
            return []  # nothing to document

        options = {}
        if 'noindex' in self.options:
            options['noindex'] = None
        if self.settings.cc_to_dash and not rule.display_name:
            options['name'] = cc_to_dash(rule.name)
        elif rule.display_name:
            options['name'] = rule.display_name

        rule_dir = Rule(
            name='a4:rule',
            arguments=[rule.name],
            options=options,
            content=docutils.statemachine.StringList(),
            lineno=self.lineno,
            content_offset=self.content_offset,
            block_text=self.block_text,
            state=self.state,
            state_machine=self.state_machine
        )

        nodes = rule_dir.run()

        for node in nodes:
            if not isinstance(node, sphinx.addnodes.desc):
                continue

            for content_node in node.children:
                if isinstance(content_node, sphinx.addnodes.desc_content):
                    desc_content = content_node
                    break
            else:
                raise RuntimeError('no desc_content can be found')

            if rule.documentation:
                self.render_docs(rule.position.file, rule.documentation[:1], desc_content)
                docs = rule.documentation[1:]
            else:
                docs = rule.documentation

            if not rule.is_doxygen_no_diagram:
                env = self.env
                grammar = env.ref_context.get('a4:grammar', '__default__')
                renderer = Renderer(
                    self.diagram_settings.literal_rendering,
                    self.diagram_settings.cc_to_dash
                )
                dia = renderer.visit(rule.content)

                settings = self.diagram_settings

                if (
                    self.settings.mark_root_rule and
                    self.root_rule is not None and
                    rule.name == self.root_rule.name and
                    rule.model is self.root_rule.model
                ):
                    settings = dataclasses.replace(settings, end_class=EndClass.COMPLEX)
                desc_content.append(
                    RailroadDiagramNode(
                        '', diagram=dia, options=settings, grammar=grammar
                    )
                )

            self.render_docs(rule.position.file, docs, desc_content)

            break

        return nodes


class AutoRule(Rule, ModelLoaderMixin, DocsRendererMixin):
    """
    Autorule directive renders documentation for a single rule.
    It accepts two arguments, first is a path to the grammar file relative
    to the ``a4_base_path``, second is name of the rule that should
    be documented.

    Note that autorule can only be used when within a grammar definition.
    Name of the current grammar definition must match name of the grammar
    from which the documented rule is imported.

    **Options:**

    .. rst:option:: name
                    noindex
                    diagram-*

       Inherited from :rst:dir:`a4:rule` directive.

    .. members-marker::

    """

    settings = autorule_namespace.for_directive()

    required_arguments = 1
    optional_arguments = 2
    has_content = True

    def run(self):
        self.name = 'a4:rule'

        if len(self.arguments) == 2:
            path, rule_name = self.arguments
        else:
            rule_name = self.arguments[0]
            if self.env.temp_data.get('a4:autogrammar_ctx'):
                path = self.env.temp_data['a4:autogrammar_ctx'][-1]
            elif 'a4:grammar' in self.env.ref_context:
                path = self.env.ref_context['a4:grammar']
            else:
                return [
                    self.state_machine.reporter.error(
                        'could not figure out grammar path for autorule directive',
                        line=self.lineno
                    )
                ]

        model = self.load_model(path)
        if model.has_errors():
            self.register_deps()
            return [
                self.state_machine.reporter.error(
                    'unable to document this rule',
                    line=self.lineno
                )
            ]

        if self.env.ref_context.get('a4:grammar') != model.get_name():
            return [
                self.state_machine.reporter.error(
                    f'cannot only use autorule while within a proper '
                    f'grammar definition',
                    line=self.lineno
                )
            ]

        rule = model.lookup(rule_name)
        if rule is None:
            self.register_deps()
            return [
                self.state_machine.reporter.error(
                    f'unknown rule {rule_name!r}',
                    line=self.lineno
                )
            ]

        if rule.display_name and 'name' not in self.options:
            self.options['name'] = rule.display_name

        self.arguments = [rule.name]

        self.env.temp_data.setdefault('a4:autogrammar_ctx', []).append(model.get_path())
        try:
            nodes = super(AutoRule, self).run()

            desc_content = self.find_desc_content(nodes)

            self.before_content()
            try:
                doc_node = find_or_add_marker(desc_content, 'docstring')

                if rule.documentation:
                    self.render_docs(rule.position.file, rule.documentation[:1], doc_node)
                    docs = rule.documentation[1:]
                else:
                    docs = rule.documentation

                if not rule.is_doxygen_no_diagram:
                    env = self.env
                    grammar = env.ref_context.get('a4:grammar', '__default__')
                    renderer = Renderer(
                        self.diagram_settings.literal_rendering,
                        self.diagram_settings.cc_to_dash
                    )
                    dia = renderer.visit(rule.content)

                    settings = self.diagram_settings

                    doc_node.append(
                        RailroadDiagramNode(
                            '', diagram=dia, options=settings, grammar=grammar
                        )
                    )

                self.render_docs(rule.position.file, docs, doc_node)

                doc_node.replace_self(doc_node.children)
            finally:
                self.after_content()

            return nodes
        finally:
            self.env.temp_data['a4:autogrammar_ctx'].pop()
            self.register_deps()

    def find_desc_content(self, nodes):
        for node in nodes:
            if not isinstance(node, sphinx.addnodes.desc):
                continue

            for content_node in node.children:
                if isinstance(content_node, sphinx.addnodes.desc_content):
                    return content_node

            break

        raise RuntimeError('no desc_content can be found')
