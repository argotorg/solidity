import os
import re
import textwrap

from typing import *

from antlr4 import CommonTokenStream, InputStream
from antlr4.error.ErrorListener import ErrorListener

from sphinx_a4doc.model.model import ModelCache, Model, Position, RuleBase, LexerRule, ParserRule, Section
from sphinx_a4doc.syntax import Lexer, Parser, ParserVisitor

import sphinx.util.logging

__all__ = [
    'ModelCacheImpl',
    'ModelImpl',
    'MetaLoader',
    'RuleLoader',
    'LexerRuleLoader',
    'ParserRuleLoader',
]


logger = sphinx.util.logging.getLogger(__name__)


CMD_RE = re.compile(r'''
    //@\s*doc\s*:\s*(?P<cmd>[a-zA-Z0-9_-]+)\s*(?P<ctx>.*)
    ''', re.UNICODE | re.VERBOSE)


class LoggingErrorListener(ErrorListener):
    def __init__(self, path: str, offset: int):
        self._path = path
        self._offset = offset

    def syntaxError(self, recognizer, offending_symbol, line, column, msg, e):
        logger.error(f'{self._path}:{line + self._offset}: WARNING: {msg}')


class ModelCacheImpl(ModelCache):
    def __init__(self):
        self._loaded: Dict[str, Model] = {}

    def from_file(self, path: Union[str, Tuple[str, int]]) -> 'Model':
        if isinstance(path, tuple):
            path, offset = path
        else:
            path, offset = path, 0

        path = os.path.abspath(os.path.normpath(path))

        if path in self._loaded:
            return self._loaded[path]

        if not os.path.exists(path):
            logger.error(f'unable to load {path!r}: file not found')
            model = self._loaded[path] = ModelImpl(path, offset, False, True)
            return model

        with open(path, 'r', encoding='utf-8', errors='strict') as f:
            self._loaded[path] = self._do_load(f.read(), path, offset, False, [])

        return self._loaded[path]

    def from_text(self, text: str, path: Union[str, Tuple[str, int]] = '<in-memory>', imports: List['Model'] = None) -> 'Model':
        if isinstance(path, tuple):
            path, offset = path
        else:
            path, offset = path, 0
        return self._do_load(text, path, offset, True, imports)

    def _do_load(self, text: str, path: str, offset: int, in_memory: bool, imports: List['Model']) -> 'Model':
        content = InputStream(text)

        lexer = Lexer(content)
        lexer.removeErrorListeners()
        lexer.addErrorListener(LoggingErrorListener(path, offset))

        tokens = CommonTokenStream(lexer)

        parser = Parser(tokens)
        parser.removeErrorListeners()
        parser.addErrorListener(LoggingErrorListener(path, offset))

        tree = parser.grammarSpec()

        if parser.getNumberOfSyntaxErrors():
            return ModelImpl(path, offset, in_memory, True)

        model = ModelImpl(path, offset, in_memory, False)

        for im in imports or []:
            model.add_import(im)

        MetaLoader(model, self).visit(tree)
        LexerRuleLoader(model).visit(tree)
        ParserRuleLoader(model).visit(tree)

        return model


class ModelImpl(Model):
    def __init__(self, path: str, offset: int, in_memory: bool, has_errors: bool):
        self._path = path
        self._in_memory = in_memory
        self._offset = offset
        self._has_errors = has_errors

        self._lexer_rules: Dict[str, LexerRule] = {}
        self._parser_rules: Dict[str, ParserRule] = {}
        self._imports: Set[Model] = set()

        self._type: Optional[str] = None
        self._name: Optional[str] = None
        self._docs: Optional[List[Tuple[int, str]]] = None

    def has_errors(self) -> bool:
        return self._has_errors

    def get_type(self) -> Optional[str]:
        return self._type

    def set_type(self, t: str):
        self._type = t

    def get_name(self) -> str:
        return self._name

    def set_name(self, n: str):
        self._name = n

    def is_in_memory(self):
        return self._in_memory

    def get_path(self) -> str:
        return self._path

    def get_model_docs(self) -> Optional[List[Tuple[int, str]]]:
        return self._docs

    def set_model_docs(self, docs: Optional[List[Tuple[int, str]]]):
        self._docs = docs

    def get_offset(self) -> int:
        return self._offset

    def add_import(self, model: 'Model'):
        self._imports.add(model)

    def set_lexer_rule(self, name: str, rule: LexerRule):
        self._lexer_rules[name] = rule

    def set_parser_rule(self, name: str, rule: ParserRule):
        self._parser_rules[name] = rule

    def lookup_local(self, name: str) -> Optional[RuleBase]:
        if name in self._lexer_rules:
            return self._lexer_rules[name]
        if name in self._parser_rules:
            return self._parser_rules[name]

        return None

    def get_imports(self) -> Iterable[Model]:
        return iter(self._imports)

    def get_terminals(self) -> Iterable[LexerRule]:
        return iter(set(self._lexer_rules.values()))

    def get_non_terminals(self) -> Iterable[ParserRule]:
        return iter(set(self._parser_rules.values()))


class MetaLoader(ParserVisitor):
    def __init__(self, model: ModelImpl, cache: ModelCacheImpl):
        self._model = model
        self._cache = cache
        if self._model.is_in_memory():
            self._basedir = None
        else:
            self._basedir = os.path.dirname(self._model.get_path())

    def add_import(self, name: str, position: Position):
        if self._model.is_in_memory():
            logger.error(f'{position}: WARNING: imports are not allowed for in-memory grammars')
        else:
            model = self._cache.from_file(os.path.join(self._basedir, name + '.g4'))
            self._model.add_import(model)

    def visitGrammarSpec(self, ctx):
        t = ctx.gtype.getText()
        if 'lexer' in t:  # that's nasty =(
            t = 'lexer'   # in fact, the whole file is nasty =(
        elif 'parser' in t:
            t = 'parser'
        else:
            t = None
        self._model.set_name(ctx.gname.getText())
        self._model.set_type(t)
        if ctx.docs:
            docs = load_docs(self._model, ctx.docs, allow_cmd=False)
            self._model.set_model_docs(docs['documentation'])
        return super(MetaLoader, self).visitGrammarSpec(ctx)

    def visitParserRuleSpec(self, ctx: Parser.ParserRuleSpecContext):
        return None  # do not recurse into this

    def visitLexerRuleSpec(self, ctx: Parser.LexerRuleSpecContext):
        return None  # do not recurse into this

    def visitModeSpec(self, ctx: Parser.ModeSpecContext):
        return None  # do not recurse into this

    def visitOption(self, ctx: Parser.OptionContext):
        if ctx.name.getText() == 'tokenVocab':
            self.add_import(ctx.value.getText(),
                            Position(self._model.get_path(), ctx.start.line + self._model.get_offset()))

    def visitDelegateGrammar(self, ctx: Parser.DelegateGrammarContext):
        self.add_import(ctx.value.getText(),
                        Position(self._model.get_path(), ctx.start.line + self._model.get_offset()))

    def visitTokensSpec(self, ctx: Parser.TokensSpecContext):
        tokens: List[Parser.IdentifierContext] = ctx.defs.defs
        for token in tokens:
            rule = LexerRule(
                name=token.getText(),
                display_name=None,
                model=self._model,
                position=Position(self._model.get_path(), token.start.line + self._model.get_offset()),
                is_literal=False,
                is_fragment=False,
                content=None,
                is_doxygen_nodoc=True,
                is_doxygen_inline=True,
                is_doxygen_no_diagram=True,
                css_class=None,
                importance=1,
                documentation='',
                section=None,
            )

            self._model.set_lexer_rule(rule.name, rule)


class RuleLoader(ParserVisitor):
    rule_class: Union[Type[RuleBase], Type[LexerRule], Type[ParserRule]] = None

    def __init__(self, model: ModelImpl):
        self._model = model
        self._current_section: Optional[Section] = None

    def wrap_suffix(self, element, suffix):
        if element == self.rule_class.EMPTY:
            return element
        if suffix is None:
            return element
        suffix: str = suffix.getText()
        if suffix.startswith('?'):
            if isinstance(element, self.rule_class.Maybe):
                return element
            else:
                return self.rule_class.Maybe(child=element)
        if suffix.startswith('+'):
            return self.rule_class.OnePlus(child=element)
        if suffix.startswith('*'):
            return self.rule_class.ZeroPlus(child=element)
        return element

    def make_alt_rule(self, content):
        has_empty_alt = False
        alts = []

        for alt in [self.visit(alt) for alt in content]:
            if isinstance(alt, self.rule_class.Maybe):
                has_empty_alt = True
                alt = alt.child
            if alt == self.rule_class.EMPTY:
                has_empty_alt = True
            elif isinstance(alt, self.rule_class.Alternative):
                alts.extend(alt.children)
            else:
                alts.append(alt)

        if len(alts) == 0:
            return self.rule_class.EMPTY
        elif len(alts) == 1 and has_empty_alt:
            return self.rule_class.Maybe(child=alts[0])
        elif len(alts) == 1:
            return alts[0]

        rule = self.rule_class.Alternative(children=tuple(alts))

        if has_empty_alt:
            rule = self.rule_class.Maybe(rule)

        return rule

    def make_seq_rule(self, content):
        elements = []
        linebreaks = set()

        for element in [self.visit(element) for element in content]:
            if isinstance(element, self.rule_class.Sequence):
                elements.extend(element.children)
            else:
                elements.append(element)
            linebreaks.add(len(elements) - 1)

        if len(elements) == 1:
            return elements[0]

        linebreaks = tuple(True if i in linebreaks else False
                           for i in range(len(elements)))
        return self.rule_class.Sequence(tuple(elements), linebreaks)

    def visitRuleSpec(self, ctx: Parser.RuleSpecContext):
        docs: List[Tuple[int, str]] = []

        start_line = None
        cur_line = None
        cur_doc: List[str] = []

        for token in ctx.headers:
            text: str = token.text.lstrip('/').strip()
            line: int = token.line + self._model.get_offset()

            if start_line is None:
                start_line = line

            if cur_line is None or cur_line == line - 1:
                cur_doc.append(text)
            else:
                docs.append((start_line, '\n'.join(cur_doc)))
                start_line = line
                cur_doc = [text]
            cur_line = line

        if cur_doc:
            docs.append((start_line, '\n'.join(cur_doc)))

        if docs:
            self._current_section = Section(docs)
        else:
            self._current_section = None
        super(RuleLoader, self).visitRuleSpec(ctx)


class LexerRuleLoader(RuleLoader):
    rule_class = LexerRule

    def visitParserRuleSpec(self, ctx: Parser.ParserRuleSpecContext):
        return None  # do not recurse into this

    def visitPrequelConstruct(self, ctx: Parser.PrequelConstructContext):
        return None  # do not recurse into this

    def visitLexerRuleSpec(self, ctx: Parser.LexerRuleSpecContext):
        content: LexerRule.RuleContent = self.visit(ctx.lexerRuleBlock())

        doc_info = load_docs(self._model, ctx.docs)

        if isinstance(content, LexerRule.Literal):
            is_literal = True
            literal = content.content
        else:
            is_literal = False
            literal = ''

        rule = LexerRule(
            name=ctx.name.text,
            display_name=doc_info['name'] or None,
            model=self._model,
            position=Position(self._model.get_path(), ctx.start.line + self._model.get_offset()),
            content=content,
            is_doxygen_nodoc=doc_info['is_doxygen_nodoc'],
            is_doxygen_inline=doc_info['is_doxygen_inline'],
            is_doxygen_no_diagram=doc_info['is_doxygen_no_diagram'],
            css_class=doc_info['css_class'],
            importance=doc_info['importance'],
            documentation=doc_info['documentation'],
            is_fragment=bool(ctx.frag),
            is_literal=is_literal,
            section=self._current_section,
        )

        self._model.set_lexer_rule(rule.name, rule)
        if is_literal:
            self._model.set_lexer_rule(literal, rule)

    def visitLexerAltList(self, ctx: Parser.LexerAltListContext):
        return self.make_alt_rule(ctx.alts)

    def visitLexerAlt(self, ctx: Parser.LexerAltContext):
        return self.visit(ctx.lexerElements())

    def visitLexerElements(self, ctx: Parser.LexerElementsContext):
        return self.make_seq_rule(ctx.elements)

    def visitLexerElementLabeled(self, ctx: Parser.LexerElementLabeledContext):
        return self.wrap_suffix(self.visit(ctx.value), ctx.suffix)

    def visitLexerElementAtom(self, ctx: Parser.LexerElementAtomContext):
        return self.wrap_suffix(self.visit(ctx.value), ctx.suffix)

    def visitLexerElementBlock(self, ctx: Parser.LexerElementBlockContext):
        return self.wrap_suffix(self.visit(ctx.value), ctx.suffix)

    def visitLexerElementAction(self, ctx: Parser.LexerElementActionContext):
        return LexerRule.EMPTY

    def visitLabeledLexerElement(self, ctx: Parser.LabeledLexerElementContext):
        return self.visit(ctx.lexerAtom() or ctx.lexerBlock())

    def visitLexerBlock(self, ctx: Parser.LexerBlockContext):
        return self.visit(ctx.lexerAltList())

    def visitCharacterRange(self, ctx: Parser.CharacterRangeContext):
        return LexerRule.Range(start=ctx.start.text, end=ctx.end.text)

    def visitTerminalRef(self, ctx: Parser.TerminalRefContext):
        return LexerRule.Reference(model=self._model, name=ctx.value.text)

    def visitTerminalLit(self, ctx: Parser.TerminalLitContext):
        content = ctx.value.text
        if content == "''":
            return LexerRule.EMPTY
        else:
            return LexerRule.Literal(content=ctx.value.text)

    def visitLexerAtomCharSet(self, ctx: Parser.LexerAtomCharSetContext):
        content = ctx.value.text
        if content == '[]':
            return LexerRule.EMPTY
        else:
            return LexerRule.CharSet(content=content)

    def visitLexerAtomWildcard(self, ctx: Parser.LexerAtomWildcardContext):
        return LexerRule.WILDCARD

    def visitLexerAtomDoc(self, ctx: Parser.LexerAtomDocContext):
        docs = load_docs(self._model, [ctx.value], False)['documentation']
        return LexerRule.Doc(value='\n'.join(d[1] for d in docs))

    def visitNotElement(self, ctx: Parser.NotElementContext):
        return LexerRule.Negation(child=self.visit(ctx.value))

    def visitNotBlock(self, ctx: Parser.NotBlockContext):
        return LexerRule.Negation(child=self.visit(ctx.value))

    def visitBlockSet(self, ctx: Parser.BlockSetContext):
        return self.make_alt_rule(ctx.elements)

    def visitSetElementRef(self, ctx: Parser.SetElementRefContext):
        return LexerRule.Reference(model=self._model, name=ctx.value.text)

    def visitSetElementLit(self, ctx: Parser.SetElementLitContext):
        content = ctx.value.text
        if content == "''":
            return LexerRule.EMPTY
        else:
            return LexerRule.Literal(content=ctx.value.text)

    def visitSetElementCharSet(self, ctx: Parser.SetElementCharSetContext):
        content = ctx.value.text
        if content == '[]':
            return LexerRule.EMPTY
        else:
            return LexerRule.CharSet(content=content)


class ParserRuleLoader(RuleLoader):
    rule_class = ParserRule

    def visitParserRuleSpec(self, ctx: Parser.ParserRuleSpecContext):
        content: ParserRule.RuleContent = self.visit(ctx.ruleBlock())
        doc_info = load_docs(self._model, ctx.docs)
        rule = ParserRule(
            name=ctx.name.text,
            display_name=doc_info['name'] or None,
            model=self._model,
            position=Position(self._model.get_path(), ctx.start.line + self._model.get_offset()),
            content=content,
            is_doxygen_nodoc=doc_info['is_doxygen_nodoc'],
            is_doxygen_inline=doc_info['is_doxygen_inline'],
            is_doxygen_no_diagram=doc_info['is_doxygen_no_diagram'],
            css_class=doc_info['css_class'],
            importance=doc_info['importance'],
            documentation=doc_info['documentation'],
            section=self._current_section,
        )

        self._model.set_parser_rule(rule.name, rule)

    def visitPrequelConstruct(self, ctx: Parser.PrequelConstructContext):
        return None  # do not recurse into this

    def visitLexerRuleSpec(self, ctx: Parser.LexerRuleSpecContext):
        return None  # do not recurse into this

    def visitModeSpec(self, ctx: Parser.ModeSpecContext):
        return None  # do not recurse into this

    def visitRuleAltList(self, ctx: Parser.RuleAltListContext):
        return self.make_alt_rule(ctx.alts)

    def visitAltList(self, ctx: Parser.AltListContext):
        return self.make_alt_rule(ctx.alts)

    def visitLabeledAlt(self, ctx: Parser.LabeledAltContext):
        return self.visit(ctx.alternative())

    def visitAlternative(self, ctx: Parser.AlternativeContext):
        return self.make_seq_rule(ctx.elements)

    def visitParserElementLabeled(self, ctx: Parser.ParserElementLabeledContext):
        return self.wrap_suffix(self.visit(ctx.value), ctx.suffix)

    def visitParserElementAtom(self, ctx: Parser.ParserElementAtomContext):
        return self.wrap_suffix(self.visit(ctx.value), ctx.suffix)

    def visitParserElementBlock(self, ctx: Parser.ParserElementBlockContext):
        return self.wrap_suffix(self.visit(ctx.value), ctx.suffix)

    def visitParserElementAction(self, ctx: Parser.ParserElementActionContext):
        return ParserRule.EMPTY

    def visitParserInlineDoc(self, ctx: Parser.ParserInlineDocContext):
        docs = load_docs(self._model, [ctx.value], False)['documentation']
        return ParserRule.Doc(value='\n'.join(d[1] for d in docs))

    def visitLabeledElement(self, ctx: Parser.LabeledElementContext):
        return self.visit(ctx.atom() or ctx.block())

    def visitBlock(self, ctx: Parser.BlockContext):
        return self.visit(ctx.altList())

    def visitAtomWildcard(self, ctx: Parser.AtomWildcardContext):
        return ParserRule.WILDCARD

    def visitTerminalRef(self, ctx: Parser.TerminalRefContext):
        return ParserRule.Reference(model=self._model, name=ctx.value.text)

    def visitTerminalLit(self, ctx: Parser.TerminalLitContext):
        return ParserRule.Reference(model=self._model, name=ctx.value.text)

    def visitRuleref(self, ctx: Parser.RulerefContext):
        return ParserRule.Reference(model=self._model, name=ctx.value.text)

    def visitNotElement(self, ctx: Parser.NotElementContext):
        return ParserRule.Negation(child=self.visit(ctx.value))

    def visitNotBlock(self, ctx: Parser.NotBlockContext):
        return ParserRule.Negation(child=self.visit(ctx.value))

    def visitBlockSet(self, ctx: Parser.BlockSetContext):
        return self.make_alt_rule(ctx.elements)

    def visitSetElementRef(self, ctx: Parser.SetElementRefContext):
        return ParserRule.Reference(model=self._model, name=ctx.value.text)

    def visitSetElementLit(self, ctx: Parser.SetElementLitContext):
        return ParserRule.Reference(model=self._model, name=ctx.value.text)

    def visitSetElementCharSet(self, ctx: Parser.SetElementCharSetContext):
        # Char sets are not allowed in parser rules,
        # yet our grammar can match them...
        return ParserRule.EMPTY

    def visitCharacterRange(self, ctx: Parser.CharacterRangeContext):
        # This also makes no sense...
        return ParserRule.EMPTY


def load_docs(model, tokens, allow_cmd=True):
        is_doxygen_nodoc = False
        is_doxygen_inline = False
        is_doxygen_no_diagram = False
        css_class = None
        importance = 1
        name = None
        docs: List[Tuple[int, str]] = []

        for token in tokens:
            text: str = token.text
            position = Position(model.get_path(), token.line + model.get_offset())
            if text.startswith('//@'):
                match = CMD_RE.match(text)

                if match is None:
                    logger.error(f'{position}: WARNING: invalid command {text!r}')
                    continue

                if not allow_cmd:
                    logger.error(f'{position}: WARNING: commands not allowed here')
                    continue

                cmd = match['cmd']

                if cmd == 'nodoc':
                    is_doxygen_nodoc = True
                elif cmd == 'inline':
                    is_doxygen_inline = True
                elif cmd == 'no-diagram':
                    is_doxygen_no_diagram = True
                elif cmd == 'unimportant':
                    importance = 0
                elif cmd == 'importance':
                    try:
                        val = int(match['ctx'].strip())
                    except ValueError:
                        logger.error(f'{position}: WARNING: importance requires an integer argument')
                        continue
                    if val < 0:
                        logger.error(f'{position}: WARNING: importance should not be negative')
                    importance = val
                elif cmd == 'name':
                    name = match['ctx'].strip()
                    if not name:
                        logger.error(f'{position}: WARNING: name command requires an argument')
                        continue
                elif cmd == 'css-class':
                    css_class = match['ctx'].strip()
                    if not name:
                        logger.error(f'{position}: WARNING: css-class command requires an argument')
                        continue
                else:
                    logger.error(f'{position}: WARNING: unknown command {cmd!r}')

                if cmd not in ['name', 'class', 'importance'] and match['ctx']:
                    logger.warning(f'argument for {cmd!r} command is ignored')
            else:
                documentation_lines = []

                lines = text.splitlines()

                if len(lines) == 1:
                    documentation_lines.append(lines[0][3:-2].strip())
                else:
                    first_line = lines[0]
                    lines = lines[1:]

                    first_line = first_line[3:].strip()
                    documentation_lines.append(first_line)

                    lines[-1] = lines[-1][:-2].rstrip()

                    if not lines[-1].lstrip():
                        lines.pop()

                    if all(line.lstrip().startswith('*') for line in lines):
                        lines = [line.lstrip()[1:] for line in lines]

                    text = textwrap.dedent('\n'.join(lines))

                    documentation_lines.append(text)

                docs.append((position.line, '\n'.join(documentation_lines)))

        return dict(
            importance=importance,
            is_doxygen_inline=is_doxygen_inline,
            is_doxygen_nodoc=is_doxygen_nodoc,
            is_doxygen_no_diagram=is_doxygen_no_diagram,
            css_class=css_class,
            name=name,
            documentation=docs
        )
