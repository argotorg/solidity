/*
 * [The "BSD license"]
 *  Copyright (c) 2012-2014 Terence Parr
 *  Copyright (c) 2012-2014 Sam Harwell
 *  Copyright (c) 2015 Gerald Rosenberg
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. The name of the author may not be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 *  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 *  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*	A grammar for ANTLR v4 written in ANTLR v4.
 *
 *  Modified 2018.08.13 taminomara -
 *  -- annotate some code parts with labels and named alternatives
 *  -- update tokens, options and channels spec to match new lexer behaviour
 *	Modified 2015.06.16 gbr -
 *	-- update for compatibility with Antlr v4.5
 *	-- add mode for channels
 *	-- moved members to LexerAdaptor
 * 	-- move fragments to imports
 */

parser grammar ANTLRv4Parser;

options {
   tokenVocab = ANTLRv4Lexer;
}

//@ doc:unimportant
/**
 * The main entry point for parsing a v4 grammar.
 */
grammarSpec
   : docs+=DOC_COMMENT* gtype=grammarType gname=identifier SEMI prequelConstruct* rules modeSpec* EOF
   ;

grammarType
   : (LEXER GRAMMAR | PARSER GRAMMAR | GRAMMAR)
   ;

// This is the list of all constructs that can be declared before
// the set of rules that compose the grammar, and is invoked 0..n
// times by the grammarPrequel rule.
prequelConstruct
   : optionsSpec
   | delegateGrammars
   | tokensSpec
   | channelsSpec
   | action
   ;

// ------------
// Options - things that affect analysis and/or code generation
optionsSpec
   : OPTIONS /* LBRACE */ (option SEMI)* RBRACE
   ;

option
   : name=identifier ASSIGN value=optionValue
   ;

optionValue
   : value+=identifier (DOT value+=identifier)* # pathOption
   | value=STRING_LITERAL # stringOption
   | value=actionBlock # actionOption
   | value=INT # intOption
   ;

// ------------
// Delegates
delegateGrammars
   : IMPORT delegateGrammar (COMMA delegateGrammar)* SEMI
   ;

delegateGrammar
   : value=identifier
   ;

// ------------
// Tokens & Channels
tokensSpec
   : TOKENS /* LBRACE */ defs=idList? RBRACE
   ;

channelsSpec
   : CHANNELS /* LBRACE */ idList? RBRACE
   ;

idList
   : defs+=identifier (COMMA defs+=identifier)* COMMA?
   ;

// Match stuff like @parser::members {int i;}
action
   : AT (actionScopeName COLONCOLON)? identifier actionBlock
   ;

// Scope names could collide with keywords; allow them as ids for action scopes
actionScopeName
   : identifier
   | LEXER
   | PARSER
   ;

actionBlock
   : BEGIN_ACTION ACTION_CONTENT* END_ACTION
   ;

argActionBlock
   : BEGIN_ARGUMENT ARGUMENT_CONTENT* END_ARGUMENT
   ;

modeSpec
   : MODE identifier SEMI lexerRuleSpec*
   ;

rules
   : ruleSpec*
   ;

ruleSpec
   : headers+=HEADER* (parserRuleSpec | lexerRuleSpec)
   ;

parserRuleSpec
   : docs+=DOC_COMMENT* ruleModifiers? name=RULE_REF argActionBlock? ruleReturns? throwsSpec? localsSpec? rulePrequel* COLON ruleBlock SEMI exceptionGroup
   ;

exceptionGroup
   : exceptionHandler* finallyClause?
   ;

exceptionHandler
   : CATCH argActionBlock actionBlock
   ;

finallyClause
   : FINALLY actionBlock
   ;

rulePrequel
   : optionsSpec
   | ruleAction
   ;

ruleReturns
   : RETURNS argActionBlock
   ;

// --------------
// Exception spec
throwsSpec
   : THROWS identifier (COMMA identifier)*
   ;

localsSpec
   : LOCALS argActionBlock
   ;

/** Match stuff like @init {int i;} */
ruleAction
   : AT identifier actionBlock
   ;

ruleModifiers
   : ruleModifier +
   ;

// An individual access modifier for a rule. The 'fragment' modifier
// is an internal indication for lexer rules that they do not match
// from the input but are like subroutines for other lexer rules to
// reuse for certain lexical patterns. The other modifiers are passed
// to the code generation templates and may be ignored by the template
// if they are of no use in that language.
ruleModifier
   : PUBLIC
   | PRIVATE
   | PROTECTED
   | FRAGMENT
   ;

ruleBlock
   : ruleAltList
   ;

ruleAltList
   : alts+=labeledAlt (OR alts+=labeledAlt)*
   ;

labeledAlt
   : alternative (POUND identifier)?
   ;

// --------------------
// Lexer rules
lexerRuleSpec
   : docs+=DOC_COMMENT* frag=FRAGMENT? name=TOKEN_REF COLON lexerRuleBlock SEMI
   ;

lexerRuleBlock
   : lexerAltList
   ;

lexerAltList
   : alts+=lexerAlt (OR alts+=lexerAlt)*
   ;

lexerAlt
   : lexerElements lexerCommands?
   |
   // explicitly allow empty alts
   ;

lexerElements
   : elements+=lexerElement+
   ;

lexerElement
   : value=labeledLexerElement suffix=ebnfSuffix? # lexerElementLabeled
   | value=lexerAtom suffix=ebnfSuffix? # lexerElementAtom
   | value=lexerBlock suffix=ebnfSuffix? # lexerElementBlock
   | actionBlock QUESTION? # lexerElementAction
   ;

// but preds can be anywhere
labeledLexerElement
   : identifier (ASSIGN | PLUS_ASSIGN) (lexerAtom | lexerBlock)
   ;

lexerBlock
   : LPAREN lexerAltList RPAREN
   ;

// E.g., channel(HIDDEN), skip, more, mode(INSIDE), push(INSIDE), pop
lexerCommands
   : RARROW lexerCommand (COMMA lexerCommand)*
   ;

lexerCommand
   : lexerCommandName LPAREN lexerCommandExpr RPAREN
   | lexerCommandName
   ;

lexerCommandName
   : identifier
   | MODE
   ;

lexerCommandExpr
   : identifier
   | INT
   ;

// --------------------
// Rule Alts
altList
   : alts+=alternative (OR alts+=alternative)*
   ;

alternative
   : elementOptions? elements+=element+
   |
   // explicitly allow empty alts
   ;

element
   : value=labeledElement suffix=ebnfSuffix? # parserElementLabeled
   | value=atom suffix=ebnfSuffix? # parserElementAtom
   | value=block suffix=ebnfSuffix? # parserElementBlock
   | actionBlock QUESTION? # parserElementAction
   | value=DOC_COMMENT # parserInlineDoc
   ;

labeledElement
   : identifier (ASSIGN | PLUS_ASSIGN) (atom | block)
   ;

// --------------------
// EBNF and blocks
ebnfSuffix
   : QUESTION QUESTION?
   | STAR QUESTION?
   | PLUS QUESTION?
   ;

lexerAtom
   : characterRange # lexerAtomRange
   | terminal # lexerAtomTerminal
   | notSet # lexerAtomNot
   | value=LEXER_CHAR_SET # lexerAtomCharSet
   | DOT elementOptions? # lexerAtomWildcard
   | value=DOC_COMMENT # lexerAtomDoc
   ;

atom
   : terminal # atomTerminal
   | ruleref # atomRuleRef
   | notSet # atomNot
   | DOT elementOptions? # atomWildcard
   ;

// --------------------
// Inverted element set
notSet
   : NOT value=setElement # notElement
   | NOT value=blockSet # notBlock
   ;

blockSet
   : LPAREN elements+=setElement (OR elements+=setElement)* RPAREN
   ;

setElement
   : value=TOKEN_REF elementOptions? # setElementRef
   | value=STRING_LITERAL elementOptions? # setElementLit
   | characterRange # setElementRange
   | value=LEXER_CHAR_SET # setElementCharSet
   ;

// -------------
// Grammar Block
block
   : LPAREN (optionsSpec? ruleAction* COLON)? altList RPAREN
   ;

// ----------------
// Parser rule ref
ruleref
   : value=RULE_REF argActionBlock? elementOptions?
   ;

// ---------------
// Character Range
characterRange
   : start=STRING_LITERAL RANGE end=STRING_LITERAL
   ;

terminal
   : value=TOKEN_REF elementOptions? # terminalRef
   | value=STRING_LITERAL elementOptions? # terminalLit
   ;

// Terminals may be adorned with certain options when
// reference in the grammar: TOK<,,,>
elementOptions
   : LT elementOption (COMMA elementOption)* GT
   ;

elementOption
   : identifier
   | identifier ASSIGN (identifier | STRING_LITERAL)
   ;

identifier
   : value=RULE_REF # ruleRefIdentifier
   | value=TOKEN_REF # tokenRefIdentifier
   ;
