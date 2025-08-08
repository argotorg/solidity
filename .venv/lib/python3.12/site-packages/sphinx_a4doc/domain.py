import re

from dataclasses import dataclass

import sphinx.addnodes
import sphinx.util.docutils
import sphinx.util.logging
import sphinx.util.nodes

from sphinx.domains import Domain, ObjType
from sphinx.directives import ObjectDescription
from sphinx.roles import XRefRole
from sphinx.locale import _

from sphinx_a4doc.settings import grammar_namespace, rule_namespace, diagram_namespace, GrammarType
from sphinx_a4doc.contrib.configurator import ManagedDirective

from typing import *


ID_RE = re.compile(r'^[a-zA-Z][a-zA-Z0-9_]*$', re.UNICODE)


class A4ObjectDescription(ObjectDescription, ManagedDirective):
    """
    Common base for rule and grammar directives.

    """

    diagram_settings = diagram_namespace.for_directive('diagram')
    """
    We can redefine rendering settings for all diagrams withing a single object.

    """

    def get_fqn(self, name: str) -> str:
        """
        Get fully qualified name for the given object.

        """

        raise NotImplementedError

    def get_display_name(self) -> Optional[str]:
        """
        Get display name which will be used instead of plain a name.

        """

        raise NotImplementedError

    def get_type(self) -> Optional[str]:
        """
        Get object type which will be used in signature and index entry.

        """

        raise NotImplementedError

    def before_content(self):
        self.push_settings(diagram_namespace, self.diagram_settings)
        if self.names:
            self.env.ref_context['a4:' + self.objtype] = self.names[0]

    def after_content(self):
        self.pop_settings(diagram_namespace)
        if self.names:
            self.env.ref_context.pop('a4:' + self.objtype)

    def signature_fail(self, msg):
        self.state_machine.reporter.warning(msg, line=self.lineno)
        raise ValueError()

    def handle_signature(self, sig, signode):
        if ID_RE.match(sig) is None:
            self.signature_fail(f'entity name {sig!r} is invalid')

        subtype = self.get_type()
        display_name = self.get_display_name()

        if subtype:
            ann = f'{subtype} {self.objtype} '
        else:
            ann = f'{self.objtype} '

        signode += sphinx.addnodes.desc_annotation(ann, ann)

        if display_name:
            signode += sphinx.addnodes.desc_name(display_name, display_name)
        else:
            signode += sphinx.addnodes.desc_name(sig, sig)

        return sig

    def add_target_and_index(self, name, sig, signode):
        fqn = self.get_fqn(name)
        anchor = 'a4.' + fqn

        if anchor not in self.state.document.ids:
            signode['names'].append(anchor)
            signode['ids'].append(anchor)
            signode['first'] = not self.names
            self.state.document.note_explicit_target(signode)

            domain = self.env.domains[A4Domain.name]
            assert isinstance(domain, A4Domain)

            if fqn in domain.index:
                path = self.env.doc2path(domain.index[fqn].docname)
                self.state_machine.reporter.warning(
                    f'duplicate Antlr4 object description of {name}, '
                    f'other instance in {path}',
                    line=self.lineno)

            self.add_target(name, fqn, anchor, domain)

        self.add_index(name, fqn, anchor)

    def add_target(self, name, fqn, anchor, domain):
        raise NotImplementedError

    def add_index(self, name, fqn, anchor):
        subtype = self.get_type()
        objtype = A4Domain.object_types[self.objtype].lname
        display_name = self.get_display_name() or name

        # TODO: translate
        if subtype:
            indextext = f'{display_name} (Antlr4 {subtype} {objtype})'
        else:
            indextext = f'{display_name} (Antlr4 {objtype})'

        self.indexnode['entries'].append(
            ('single', indextext, anchor, '', None)
        )


class Grammar(A4ObjectDescription):
    """
    Declare a new grammar with the given name.

    Grammar names should be unique within the project.

    .. members-marker::

    .. rst:option:: noindex

       A standard sphinx option to disable indexing for this rule.

    .. rst:option:: diagram-*

       One can override any option for all
       :rst:dir:`railroad diagrams <railroad-diagram>` within this grammar.
       Prefix the desired option with ``diagram-`` and add to the
       rule description.

       For example:

       .. code-block:: rst

          .. a4:grammar:: Test
             :diagram-end-class: complex

             All diagrams rendered inside this grammar
             will have 'end-class' set to 'complex'.

    """

    settings = grammar_namespace.for_directive()

    def get_fqn(self, name: str) -> str:
        return name

    def get_display_name(self) -> Optional[str]:
        return self.settings.name

    def get_type(self) -> Optional[str]:
        if self.settings.type is GrammarType.MIXED:
            return None
        else:
            return self.settings.type.name.lower()

    def add_target(self, name, fqn, anchor, domain):
        domain.register_grammar(
            docname=self.env.docname,
            name=name,
            fqn=fqn,
            display_name=self.get_display_name(),
            relations=self.settings.imports
        )

    def handle_signature(self, sig, signode):
        if 'a4:rule' in self.env.ref_context:
            self.signature_fail('defining grammars within a rule body is not allowed')
        if 'a4:grammar' in self.env.ref_context:
            self.signature_fail('defining nested grammars is not allowed')

        return super().handle_signature(sig, signode)


class Rule(A4ObjectDescription):
    """
    Declare a new production rule with the given name.

    If placed within an :rst:dir:`a4:grammar` body, the rule will be added to
    that grammar. It can then be referenced by a full path which will include
    the grammar name and the rule name concatenated with a dot symbol.

    If placed outside any grammar directive, the rule will be added to
    an implicitly declared "default" grammar. In this case, the rule's full
    path will only include its name.

    In either case, the rule name should be unique within its grammar.

    .. members-marker::

    .. rst:option:: noindex

       A standard sphinx option to disable indexing for this rule.

    .. rst:option:: diagram-*

        One can override any option for all
        :rst:dir:`railroad diagrams <railroad-diagram>`
        within this rule. Refer to the corresponding
        :rst:opt:`a4:grammar <a4:grammar:diagram-*>`'s option for more info.

    """

    settings = rule_namespace.for_directive()

    def get_fqn(self, name: str) -> str:
        grammar = self.env.ref_context.get(
            'a4:grammar', A4Domain.DEFAULT_GRAMMAR.name
        )
        return grammar + '.' + name

    def get_display_name(self) -> Optional[str]:
        return self.settings.name

    def get_type(self) -> Optional[str]:
        return None

    def add_target(self, name, fqn, anchor, domain):
        domain.register_rule(
            docname=self.env.docname,
            name=name,
            fqn=fqn,
            display_name=self.get_display_name(),
        )

    def handle_signature(self, sig, signode):
        if 'a4:rule' in self.env.ref_context:
            self.signature_fail('defining nested rules is not allowed')

        return super().handle_signature(sig, signode)


class A4XRefRole(XRefRole):
    def process_link(self, env, refnode, has_explicit_title, title, target):
        refnode['a4:grammar'] = env.ref_context.get(
            'a4:grammar', A4Domain.DEFAULT_GRAMMAR.name
        )

        # This is the standard tilde handling, copied from ``c`` domain:
        target = target.lstrip('~')
        if not has_explicit_title:
            if title[0:1] == '~':
                title = title[1:]
                dot = title.rfind('.')
                if dot != -1:
                    title = title[dot + 1:]

        return super().process_link(env, refnode, has_explicit_title, title, target)


class A4Domain(Domain):
    @dataclass
    class IndexEntry:
        docname: str
        """
        Name of the document in which this entry was indexed.

        """

        objtype: str
        """
        Object type, either ``'grammar'`` or ``'rule'``.

        """

        name: str
        """
        Object name.

        """

        fqn: str
        """
        Fully qualified name.

        """

        display_name: Optional[str] = None
        """
        Human readable name which should replace the default name in crossrefs.

        """

        relations: Optional[List[str]] = None
        """
        For grammar objects, contains list of imported grammars.

        """

    DEFAULT_GRAMMAR = IndexEntry(
        docname='',
        objtype='grammar',
        name='__default__',
        fqn='__default__',
        display_name=None,
        relations=[]
    )

    name = 'a4'

    label = 'Antlr4'

    object_types = {
        'grammar': ObjType(_('grammar'), 'grammar', 'g'),
        'rule': ObjType(_('production rule'), 'rule', 'r'),
    }

    directives = {
        'grammar': Grammar,
        'rule': Rule,
    }

    roles = {
        'grammar': A4XRefRole(),
        'g': A4XRefRole(),
        'rule': A4XRefRole(),
        'r': A4XRefRole(),
    }

    initial_data = {
        'objects': {},  # fullname -> index entry
    }

    def register_grammar(self, docname, name, fqn, display_name, relations):
        self.index[fqn] = A4Domain.IndexEntry(
            docname=docname,
            objtype='grammar',
            name=name,
            fqn=fqn,
            display_name=display_name,
            relations=relations
        )

    def register_rule(self, docname, name, fqn, display_name):
        self.index[fqn] = A4Domain.IndexEntry(
            docname=docname,
            objtype='rule',
            name=name,
            fqn=fqn,
            display_name=display_name,
            relations=None
        )

    @property
    def index(self) -> Dict[str, IndexEntry]:
        return self.data['objects']

    def lookup(self, fqn, objtype):
        if fqn not in self.index:
            return None
        if self.index[fqn].objtype != objtype:
            return None
        return self.index[fqn]

    def lookup_grammar(self, fqn):
        return self.lookup(fqn, 'grammar')

    def lookup_rule(self, fqn):
        return self.lookup(fqn, 'rule')

    def traverse_grammars(self, roots, add_default_grammar):
        stack = list(roots)
        seen = set()
        while stack:
            grammar_name = stack.pop()
            if grammar_name in seen:
                continue
            seen.add(grammar_name)
            grammar = self.lookup_grammar(grammar_name)
            if grammar is not None:
                yield grammar
                stack.extend(grammar.relations or [])
            # else:
            #     self.env.warn_node(
            #         f'cannot resolve grammar {grammar_name!r}', node
            #     )
        if add_default_grammar:
            yield self.DEFAULT_GRAMMAR

    def clear_doc(self, docname):
        for fqn, entry in list(self.index.items()):
            if entry.docname == docname:
                self.index.pop(fqn)

    def merge_domaindata(self, docnames, otherdata):
        objects: Dict[str, A4Domain.IndexEntry] = otherdata['objects']
        objects = {k: v for k, v in objects.items() if v.docname in docnames}
        self.index.update(objects)

    def resolve_xref(self, env, fromdocname, builder, typ, target, node, contnode):
        if typ in ['grammar', 'g']:
            resolver = self.resolve_grammar
        elif typ in ['rule', 'r']:
            resolver = self.resolve_rule
        else:
            raise RuntimeError(f'unknown object type {typ}')

        return resolver(env, fromdocname, builder, target, node, contnode)

    def resolve_any_xref(self, env, fromdocname, builder, target, node, contnode):
        results = []

        as_grammar = self.resolve_grammar(env, fromdocname, builder, target, node, contnode)
        if as_grammar is not None:
            results.append(('a4:grammar', as_grammar))

        as_rule = self.resolve_rule(env, fromdocname, builder, target, node, contnode, True)
        for r in as_rule:
            results.append(('a4:rule', r))

        return results

    def resolve_grammar(self, env, fromdocname, builder, target, node, contnode):
        obj = self.lookup_grammar(target)
        if obj is not None:
            return self.make_refnode(fromdocname, builder, node, contnode, obj)

    def resolve_rule(self, env, fromdocname, builder, target, node, contnode, allow_multiple=False):
        if '.' in target:
            # Got fully qualified rule reference.
            add_default_grammar = False
            grammar_name, rule_name = target.rsplit('.', 1)
            roots = [grammar_name]
        elif 'a4:grammar' in node:
            # Got rule reference made by A4XRefRole.
            add_default_grammar = True
            if node['a4:grammar'] == self.DEFAULT_GRAMMAR.name:
                roots = []
            else:
                roots = [node['a4:grammar']]
            rule_name = target
        else:
            # Got rule reference made by AnyXRefRole.
            add_default_grammar = True
            roots = [k for k, v in self.index.items() if v.objtype == 'grammar']
            rule_name = target

        results = []

        for grammar in self.traverse_grammars(roots, add_default_grammar):
            fqn = f'{grammar.name}.{rule_name}'
            obj = self.lookup_rule(fqn)
            if obj is not None:
                refnode = self.make_refnode(fromdocname, builder, node, contnode, obj)
                if allow_multiple:
                    results.append(refnode)
                else:
                    return refnode

        if allow_multiple:
            return results
        else:
            return None

    def make_refnode(self, fromdocname, builder, node, contnode, obj):
        if not node['refexplicit'] and obj.display_name:
            contnode = contnode.deepcopy()
            contnode.clear()
            contnode += sphinx.util.docutils.nodes.Text(obj.display_name)
        return sphinx.util.nodes.make_refnode(
            builder, fromdocname, obj.docname, 'a4.' + obj.fqn, contnode, obj.fqn
        )

    def get_objects(self):
        for fqn, entry in self.index.items():
            display_name = entry.display_name or entry.name or fqn
            yield (fqn, display_name, entry.objtype, entry.docname, 'a4.' + fqn, 1)
