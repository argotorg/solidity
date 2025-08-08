import re
import dataclasses
import textwrap

import sphinx.addnodes
import sphinx.domains
import sphinx.roles
import sphinx.util.docfields
from docutils.parsers.rst.languages import en
import docutils.statemachine
import docutils.nodes
import sphinx.util.docutils
import sphinx.ext.autodoc
import sphinx.errors
import sphinx.domains.rst
import sphinx.addnodes
import sphinx.application

from sphinx.locale import _
from sphinx.pycode import ModuleAnalyzer

from .configurator import Namespace, NamespaceHolder, ManagedDirective, make_converter
from .marker_nodes import find_or_add_marker

from typing import *


class ReSTDirective(sphinx.domains.rst.ReSTDirective):
    def before_content(self):
        super().before_content()
        self.env.ref_context['rst:directive'] = self.names

    def after_content(self):
        super().after_content()
        self.env.ref_context['rst:directive'] = None


class ReSTOption(sphinx.domains.rst.ReSTMarkup):
    def handle_signature(self, sig: str, signode: sphinx.addnodes.desc_signature) -> str:
        directive: Optional[List[str]] = self.env.ref_context.get('rst:directive', None)

        if directive is None:
            raise ValueError('rst option cannot be documented '
                             'outside of any directive')

        sig = sig.strip()

        match = re.match(r'^([^ ]+)(( .*)?)', sig)
        if match is None:
            raise ValueError(f'invalid option name {sig}')
        name, value_desc = match.group(1), match.group(2)

        name, value_desc = name.strip(), value_desc.strip()

        dispname = f':{name}:'
        if value_desc:
            dispname += ' '

        signode += sphinx.addnodes.desc_name(dispname, dispname)
        if value_desc:
            signode += sphinx.addnodes.desc_addname(value_desc, value_desc)

        return directive[0] + ':' + name


class OptRole(sphinx.roles.XRefRole):
    def process_link(self, env, refnode, has_explicit_title, title, target):
        refnode['rst:directive'] = env.ref_context.get('rst:directive', None)
        return super().process_link(env, refnode, has_explicit_title, title, target)


class ExtendedReSTDomain(sphinx.domains.rst.ReSTDomain):
    object_types = sphinx.domains.rst.ReSTDomain.object_types.copy()
    object_types['option'] = sphinx.domains.ObjType(_('option'), 'opt')

    directives = sphinx.domains.rst.ReSTDomain.directives.copy()
    directives['directive'] = ReSTDirective
    directives['option'] = ReSTOption

    roles = sphinx.domains.rst.ReSTDomain.roles.copy()
    roles['opt'] = OptRole()

    def resolve_xref(self, env, fromdocname, builder, typ, target, node, contnode):
        if typ == 'opt':
            if ':' not in target and node.get('rst:directive', None):
                target = node['rst:directive'][0] + ':' + target
        return super().resolve_xref(env, fromdocname, builder, typ, target, node, contnode)


@dataclasses.dataclass
class AutoDirectiveSettings:
    options: bool = True
    """
    Generate documentation for directive options.

    """

    prefixed_options: bool = False
    """
    Generate documentation for directive options with non-empty prefix.

    """

    inherited_options: bool = True
    """
    Generate documentation for inherited options (i.e., options that are
    not in the namespace dataclass, but in its bases).

    """

    prefix_filter: Optional[List[str]] = None
    """
    Filter options documentation by option prefix.

    """

    options_header: bool = True
    """
    Controls whether directive should render a header for options section.

    """


namespace = Namespace('configurator', AutoDirectiveSettings)


class AutoDirective(ReSTDirective, ManagedDirective):
    """
    Generates documentation for rst directives, including documentation for
    its options.

    """

    settings = namespace.for_directive()

    def run(self):
        self.name = 'rst:directive'

        nodes = super().run()

        try:
            directive = self.load_directive()
        except sphinx.errors.ExtensionError as e:
            return [
                self.state_machine.reporter.error(
                    str(e),
                    line=self.content_offset
                )
            ]

        if not issubclass(directive, docutils.parsers.rst.Directive):
            return [
                self.state_machine.reporter.error(
                    'cannot autodocument a directive that is not derived '
                    'from docutils.parsers.rst.Directive',
                    line=self.content_offset
                )
            ]

        for node in nodes:
            if isinstance(node, sphinx.addnodes.desc):
                for content_node in node.children:
                    if isinstance(content_node, sphinx.addnodes.desc_content):
                        self.render_directive(directive, content_node)
                        return nodes
                else:
                    raise RuntimeError('no desc_content node can be found')
        else:
            raise RuntimeError('no desc node can be found')

    def load_directive(self):
        if len(self.names) < 1:
            raise sphinx.errors.ExtensionError(
                'should provide at least one signature'
            )

        directive_name = self.names[0]
        if ':' in directive_name:
            domain_name, directive_name = directive_name.split(':', 1)

            if domain_name not in self.env.domains:
                raise sphinx.errors.ExtensionError(
                    f'unknown domain {domain_name!r}'
                )

            domain = self.env.domains[domain_name]

            if directive_name not in domain.directives:
                raise sphinx.errors.ExtensionError(
                    f'unknown directive {directive_name!r} '
                    f'within domain {domain_name!r}'
                )

            return domain.directives[directive_name]
        else:
            directive, messages = sphinx.util.docutils.directives.directive(
                directive_name,
                en,
                self.state.document
            )

            if directive is None:
                raise sphinx.errors.ExtensionError(
                    f'unknown directive {directive_name!r}'
                )

            return directive

    def render_directive(self, directive, nodes):
        if getattr(directive, '__doc__', None):
            doc_node = find_or_add_marker(nodes, 'docstring')

            self.before_content()

            try:
                doc = self.canonize_docstring(directive.__doc__)
                lines = docutils.statemachine.StringList(doc.splitlines())
                self.state.nested_parse(lines, self.content_offset, doc_node)
            finally:
                self.after_content()

            doc_node.replace_self(doc_node.children)

        if not self.settings.options:
            return

        holders: Set[NamespaceHolder] = getattr(
            directive,
            '_namespace_attrs_',
            set()
        )

        options: List[Tuple[str, Any, List[dataclasses.Field]]] = []

        for holder in holders:
            if holder.prefix:
                if not self.settings.prefixed_options:
                    continue
                if (self.settings.prefix_filter is not None and
                        holder.prefix not in self.settings.prefix_filter):
                    continue
                prefix = holder.prefix
            else:
                prefix = ''

            fields = holder.namespace.fields()
            cls = holder.namespace.get_cls()

            if fields:
                options.append((prefix, cls, fields))

        if not options:
            return

        opt_node = find_or_add_marker(nodes, 'members')

        if self.settings.options_header:
            # TODO: maybe add anchor?
            p = docutils.nodes.paragraph('', '')
            p += docutils.nodes.strong('Options:', _('Options:'))
            opt_node += p

        for p, cls, fields in sorted(options, key=lambda x: x[0]):
            fields = filter(lambda x: x[0], [
                (self.resolve_arg_doc_and_index(field.name, cls), field)
                for field in fields
            ])
            fields = sorted(fields, key=lambda x: (x[0][0], x[1].name))
            for (i, doc), field in fields:
                if p:
                    p += '-'

                name = field.name.replace('_', '-')
                names = [p + name]
                if 'converter' in field.metadata:
                    value_desc = str(field.metadata['converter'])
                elif field.type is bool:
                    value_desc = ''
                    names.append(p + 'no-' + name)
                else:
                    value_desc = str(make_converter(field.type))

                opt_node += self.render_option(names, value_desc, doc)

        opt_node.replace_self(opt_node.children)

    def render_option(self, names, value_desc, doc):
        lines = docutils.statemachine.StringList(doc.splitlines())

        directive = ReSTOption(
            name='rst:option',
            arguments=[
                '\n'.join([f'{name} {value_desc}' for name in names])
            ],
            options=self.options,
            content=lines,
            lineno=self.lineno,
            content_offset=self.content_offset,
            block_text=self.block_text,
            state=self.state,
            state_machine=self.state_machine
        )

        self.before_content()
        try:
            return directive.run()
        finally:
            self.after_content()

    @staticmethod
    def canonize_docstring(description):
        if description is None:
            return description

        lines = description.split('\n')
        lines = list(map(str.rstrip, lines))

        # Handle trivial cases:
        if len(lines) <= 1:
            return '\n'.join(lines) + '\n\n'

        # Ensure there is a blank line at the end of description:
        if lines[-1]:
            lines.append('')

        # The first line is a line that follows immediately after the triple quote.
        # We need to dedent the other lines but we don't need to dedent
        # the first one.
        body = lines[0] + '\n' + textwrap.dedent('\n'.join(lines[1:]))

        # Remove any leading newlines and ensure that
        # there is only one trailing newline.
        body = body.strip('\n') + '\n\n'

        return body

    def resolve_arg_doc_and_index(self, name, dataclass: type) -> Optional[Tuple[Tuple[int, int], str]]:
        if self.settings.inherited_options:
            bases = dataclass.__mro__
        else:
            bases = [dataclass]
        for i, base in enumerate(bases):
            analyzer = ModuleAnalyzer.for_module(base.__module__)
            docs = analyzer.find_attr_docs()
            if (base.__qualname__, name) in docs:
                tag = analyzer.tagorder[f'{base.__qualname__}.{name}']
                return (-i, tag), self.canonize_docstring(
                    '\n'.join(docs[base.__qualname__, name])
                )
        return None


def setup(app: sphinx.application.Sphinx):
    app.setup_extension('sphinx_a4doc.contrib.marker_nodes')

    app.add_domain(ExtendedReSTDomain, override=True)

    namespace.register_settings(app)
    app.add_directive_to_domain('rst', 'autodirective', AutoDirective)

    return {
        'version': '1.0.0',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }
