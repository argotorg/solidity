from dataclasses import dataclass, field
from enum import Enum

from sphinx_a4doc.contrib.configurator import Namespace

from typing import *


class InternalAlignment(Enum):
    """
    Controls how to align nodes within a single railroad.
    See `DiagramSettings.internal_alignment` for documentation on elements.

    """

    CENTER = 'CENTER'
    LEFT = 'LEFT'
    RIGHT = 'RIGHT'
    AUTO_LEFT = 'AUTO_LEFT'
    AUTO_RIGHT = 'AUTO_RIGHT'


class EndClass(Enum):
    """
    Controls how diagram start and end look like.
    See `DiagramSettings.end_class` for documentation on elements.

    """

    SIMPLE = 'SIMPLE'
    COMPLEX = 'COMPLEX'


class GrammarType(Enum):
    """
    Antlr4 grammar types.

    """

    MIXED = 'MIXED'
    LEXER = 'LEXER'
    PARSER = 'PARSER'


class OrderSettings(Enum):
    """
    Controls how autodoc orders rules that are extracted from sources.

    """

    BY_SOURCE = 'BY_SOURCE'
    """
    Order by position in source file.

    """

    BY_NAME = 'BY_NAME'
    """
    Order by human-readable name.

    """


class GroupingSettings(Enum):
    """
    Controls how autodoc groups rules that are extracted from sources.

    """

    MIXED = 'MIXED'
    """
    Rules are not ordered.

    """

    LEXER_FIRST = 'LEXER_FIRST'
    """
    Lexer rules go first.

    """

    PARSER_FIRST = 'PARSER_FIRST'
    """
    Parser rules go first.

    """


class LiteralRendering(Enum):
    """
    Controls how literal rules are rendered.

    """

    NAME = 'NAME'
    """
    Name of the rule is displayed.

    """

    CONTENTS = 'CONTENTS'
    """
    Contents of the rule are displayed.

    """

    CONTENTS_UNQUOTED = 'CONTENTS_UNQUOTED'
    """
    Contents of the rule are displayed, single quotes are stripped away.

    """


@dataclass(frozen=True)
class DiagramSettings:
    """
    Settings for diagram directive.

    """

    padding: Tuple[int, int, int, int] = (1, 1, 1, 1)
    """
    Array of four positive integers denoting top, right, bottom and left
    padding between the diagram and its container. By default, there is 1px
    of padding on each side.

    """

    vertical_separation: int = 8
    """
    Vertical space between diagram lines.

    """

    horizontal_separation: int = 10
    """
    Horizontal space between items within a sequence.

    """

    arc_radius: int = 10
    """
    Arc radius of railroads. 10px by default.

    """

    translate_half_pixel: bool = False
    """
    If enabled, the diagram will be translated half-pixel in both directions.
    May be used to deal with anti-aliasing issues when using odd stroke widths.

    """

    internal_alignment: InternalAlignment = InternalAlignment.AUTO_LEFT
    """
    Determines how nodes aligned within a single diagram line. Available
    options are:

    - ``center`` -- nodes are centered.

      .. parser-rule-diagram:: (A B | C D E) (',' (A B | C D E))*
         :internal-alignment: CENTER

    - ``left`` -- nodes are flushed to left in all cases.

      .. parser-rule-diagram:: (A B | C D E) (',' (A B | C D E))*
         :internal-alignment: LEFT

    - ``right`` -- nodes are flushed to right in all cases.

      .. parser-rule-diagram:: (A B | C D E) (',' (A B | C D E))*
         :internal-alignment: RIGHT

    - ``auto_left`` -- nodes in choice groups are flushed left,
      all other nodes are centered.

      .. parser-rule-diagram:: (A B | C D E) (',' (A B | C D E))*
         :internal-alignment: AUTO_LEFT

    - ``auto_right`` -- nodes in choice groups are flushed right,
      all other nodes are centered.

      .. parser-rule-diagram:: (A B | C D E) (',' (A B | C D E))*
         :internal-alignment: AUTO_RIGHT

    """

    character_advance: float = 8.4
    """
    Average length of one character in the used font. Since SVG elements
    cannot expand and shrink dynamically, length of text nodes is calculated
    as number of symbols multiplied by this constant.

    """

    end_class: EndClass = EndClass.SIMPLE
    """
    Controls how diagram start and end look like. Available options are:

    - ``simple`` -- a simple ``T``-shaped ending.

      .. parser-rule-diagram:: X
         :end-class: SIMPLE

    - ``complex`` -- a ``T``-shaped ending with vertical line doubled.

      .. parser-rule-diagram:: X
         :end-class: COMPLEX

    """

    max_width: int = 500
    """
    Max width after which a sequence will be wrapped. This option is used to
    automatically convert sequences to stacks. Note that this is a suggestive
    option, there is no guarantee that the diagram will
    fit to its ``max_width``.

    """

    literal_rendering: LiteralRendering = LiteralRendering.CONTENTS_UNQUOTED
    """
    Controls how literal rules (i.e. lexer rules that only consist of one
    string) are rendered. Available options are:
    
    - ``name`` -- only name of the literal rule is displayed.
    
    - ``contents`` -- quoted literal string is displayed.
    
      .. parser-rule-diagram:: 'def' Id
         :literal-rendering: contents
    
    - ``contents-unquoted``: -- literal string is displayed, quotes stripped
      away.
      

      .. parser-rule-diagram:: 'def' Id
         :literal-rendering: contents-unquoted
    
    """

    cc_to_dash: bool = False
    """
    If rule have no human-readable name set, convert its name from
    ``CamelCase`` to ``dash-case``.
    
    """

    alt: Optional[str] = None
    """
    If rendering engine does not support output of contents, specified
    string is used alternatively.
    """


@dataclass(frozen=True)
class GrammarSettings:
    """
    Settings for grammar directive.

    """

    name: Optional[str] = field(default=None, metadata=dict(no_global=True))
    """
    Specifies a human-readable name for the grammar.

    If given, the human-readable name will be rendered instead of the primary
    grammar name. It will also replace the primary name in all cross references.

    For example this code:

    .. code-block:: rst

       .. a4:grammar:: PrimaryName
          :name: Human-readable name

    will render the next grammar description:

    .. highlights::

       .. a4:grammar:: PrimaryName
          :noindex:
          :name: Human-readable name

    """

    type: GrammarType = field(default=GrammarType.MIXED, metadata=dict(no_global=True))
    """
    Specifies a grammar type. The type will be displayed in the grammar
    signature.

    For example these three grammars:

    .. code-block:: rst

       .. a4:grammar:: Grammar1

       .. a4:grammar:: Grammar2
          :type: lexer

       .. a4:grammar:: Grammar3
          :type: parser

    will be rendered differently:

    .. highlights::

       .. a4:grammar:: Grammar1
          :noindex:

       .. a4:grammar:: Grammar2
          :noindex:
          :type: lexer

       .. a4:grammar:: Grammar3
          :noindex:
          :type: parser

    """

    imports: List[str] = field(default_factory=list, metadata=dict(no_global=True))
    """
    Specifies a list of imported grammars.

    This option affects name resolution process for rule cross-references.
    That is, if there is a reference to ``grammar.rule`` and there is no
    ``rule`` found in the ``grammar``, the imported grammars will be searched
    as well.
    
    Note that this setting is not passed through intersphinx.

    """


@dataclass(frozen=True)
class RuleSettings:
    """
    Settings for rule directive.

    """

    name: Optional[str] = field(default=None, metadata=dict(no_global=True))
    """
    Specifies a human-readable name for this rule. Refer to the corresponding
    :rst:opt:`a4:grammar <a4:grammar:name>`'s option for more info.

    """


@dataclass(frozen=True)
class AutogrammarSettings(GrammarSettings):
    """
    Settings for autogrammar directive.

    """

    only_reachable_from: Optional[str] = field(default=None, metadata=dict(no_global=True, rebuild=True))
    """
    If given, autodoc will only render rules that are reachable from this root.
    This is useful to exclude rules from imported grammars that are not used
    by the primary grammar.

    The value should be either name of a rule from the grammar that's being
    documented or a full path which includes grammar name and rule name.

    For example, suppose there's ``Lexer.g4`` and ``Parser.g4``. To filter
    lexer rules that are not used by parser grammar, use:

    .. code-block:: rst

       .. a4:autogrammar:: Parser
          :only-reachable-from: Parser.root

       .. a4:autogrammar:: Lexer
          :only-reachable-from: Parser.root

    """

    mark_root_rule: bool = field(default=True, metadata=dict(rebuild=True))
    """
    If enabled, automatic diagram for the rule that's listed in
    :rst:opt:`only-reachable-from` will use complex line endings
    (see the :rst:opt:`end-class <railroad-diagram:end-class>` option
    of the :rst:dir:`railroad-diagram` directive).

    """

    lexer_rules: bool = field(default=True, metadata=dict(rebuild=True))
    """
    Controls whether lexer rules should appear in documentation.
    Enabled by default.

    """

    parser_rules: bool = field(default=True, metadata=dict(rebuild=True))
    """
    Controls whether parser rules should appear in documentation.
    Enabled by default.

    """

    fragments: bool = field(default=False, metadata=dict(rebuild=True))
    """
    Controls whether fragments should appear in documentation.
    Disabled by default.

    """

    undocumented: bool = field(default=False, metadata=dict(rebuild=True))
    """
    Controls whether undocumented rules should appear in documentation.
    Disabled by default.

    """

    grouping: GroupingSettings = field(default=GroupingSettings.MIXED, metadata=dict(rebuild=True))
    """
    Controls how autodoc groups rules that are extracted from sources.

    - ``mixed`` -- there's one group that contain all rules.

    - ``lexer-first`` -- there are two group: one for parser rules and one for
      lexer rules and fragments. Lexer group goes first.

    - ``parser-first`` -- like ``lexer-first``, but parser group preceeds
      lexer group.

    """

    ordering: OrderSettings = field(default=OrderSettings.BY_SOURCE, metadata=dict(rebuild=True))
    """
    Controls how autodoc orders rules within each group
    (see :rst:opt:`grouping` option).

    - ``by-source`` -- rules are ordered as they appear in the grammar file.

    - ``by-name`` -- rules are ordered lexicographically.

    """

    honor_sections: bool = field(default=True, metadata=dict(rebuild=True))
    """
    If true, render comments that start with a triple slash, treating them
    as paragraphs that placed between rules.

    This setting has no effect unless :rst:opt:`ordering` is ``by-source``.

    .. versionadded:: 1.2.0

    """

    cc_to_dash: bool = False
    """
    For rules without explicit human-readable names, generate ones by converting
    rule name from ``CamelCase`` to ``dash-case``.
    
    Setting this option will also set the ``diagram-cc-to-dash`` option, unless
    the latter is specified explicitly.
    
    """


@dataclass(frozen=True)
class AutoruleSettings(GrammarSettings):
    """
    Settings for autorule directive.

    .. versionadded:: 1.2.0

    """


@dataclass(frozen=True)
class GlobalSettings:
    """
    Global A4Doc settings. Each member of this dataclass will be added
    to the global sphinx settings registry with prefix ``a4_``.

    """

    base_path: str = field(default='.', metadata=dict(rebuild=True))
    """
    Path which autodoc searches for grammar files.

    """


diagram_namespace = Namespace('a4_diagram', DiagramSettings)
grammar_namespace = Namespace('a4_grammar', GrammarSettings)
rule_namespace = Namespace('a4_rule', RuleSettings)
autogrammar_namespace = Namespace('a4_autogrammar', AutogrammarSettings)
autorule_namespace = Namespace('a4_autorule', AutoruleSettings)
global_namespace = Namespace('a4', GlobalSettings)


def register_settings(app):
    diagram_namespace.register_settings(app)
    grammar_namespace.register_settings(app)
    rule_namespace.register_settings(app)
    autogrammar_namespace.register_settings(app)
    autorule_namespace.register_settings(app)
    global_namespace.register_settings(app)
