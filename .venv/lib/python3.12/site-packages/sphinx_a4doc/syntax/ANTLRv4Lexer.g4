lexer grammar ANTLRv4Lexer;

options {
    superClass = LexerAdaptor ;
}

import LexBasic;	// Standard set of fragments

@header {
from sphinx_a4doc.syntax.lexer_adaptor import LexerAdaptor
}

tokens {
    TOKEN_REF,
    RULE_REF,
    LEXER_CHAR_SET
}

channels {
    OFF_CHANNEL		// non-default channel for whitespace and comments
}


// ======================================================
// Lexer specification
//

// -------------------------
// Comments

DOC_COMMENT
    :	DocComment
    ;

HEADER
    : '///' ~[\r\n]*
    ;

BLOCK_COMMENT
    :	BlockComment	-> channel(OFF_CHANNEL)
    ;

LINE_COMMENT
    :	LineComment		-> channel(OFF_CHANNEL)
    ;


// -------------------------
// Integer
//

INT	: DecimalNumeral
    ;


// -------------------------
// Literal string
//
// ANTLR makes no distinction between a single character literal and a
// multi-character string. All literals are single quote delimited and
// may contain unicode escape sequences of the form \uxxxx, where x
// is a valid hexadecimal number (per Unicode standard).

STRING_LITERAL
    : SQuoteLiteral
    ;

UNTERMINATED_STRING_LITERAL
    : USQuoteLiteral
    ;


// -------------------------
// Arguments
//
// Certain argument lists, such as those specifying call parameters
// to a rule invocation, or input parameters to a rule specification
// are contained within square brackets.

BEGIN_ARGUMENT
    :	LBrack		{ self.handleBeginArgument() }
    ;


// -------------------------
// Actions

BEGIN_ACTION
    :	LBrace		-> pushMode(Action)
    ;


// -------------------------
// Keywords
//
// Keywords may not be used as labels for rules or in any other context where
// they would be ambiguous with the keyword vs some other identifier.  OPTIONS,
// TOKENS, & CHANNELS blocks are handled idiomatically in dedicated lexical modes.


OPTIONS		: 'options' [ \t\f\n\r]* '{' 	-> pushMode(Options)	;
TOKENS		: 'tokens' [ \t\f\n\r]* '{'		-> pushMode(Tokens)		;
CHANNELS	: 'channels' [ \t\f\n\r]* '{'	-> pushMode(Channels)	;

IMPORT		: 'import'		;
FRAGMENT	: 'fragment'	;
LEXER		: 'lexer'		;
PARSER		: 'parser'		;
GRAMMAR		: 'grammar'		;
PROTECTED	: 'protected'	;
PUBLIC		: 'public'		;
PRIVATE		: 'private'		;
RETURNS		: 'returns'		;
LOCALS		: 'locals'		;
THROWS		: 'throws'		;
CATCH		: 'catch'		;
FINALLY		: 'finally'		;
MODE		: 'mode'		;


// -------------------------
// Punctuation

COLON		: Colon			;
COLONCOLON	: DColon		;
COMMA		: Comma			;
SEMI		: Semi			;
LPAREN		: LParen		;
RPAREN		: RParen		;
LBRACE		: LBrace		;
RBRACE		: RBrace		;
RARROW		: RArrow		;
LT			: Lt			;
GT			: Gt			;
ASSIGN		: Equal			;
QUESTION	: Question		;
STAR		: Star			;
PLUS_ASSIGN	: PlusAssign	;
PLUS		: Plus			;
OR			: Pipe			;
DOLLAR		: Dollar		;
RANGE		: Range			;
DOT			: Dot			;
AT			: At			;
POUND		: Pound			;
NOT			: Tilde			;


// -------------------------
// Identifiers - allows unicode rule/token names

ID	: Id
    ;


// -------------------------
// Whitespace

WS	:	Ws+		-> channel(OFF_CHANNEL)	;


// -------------------------
// Illegal Characters
//
// This is an illegal character trap which is always the last rule in the
// lexer specification. It matches a single character of any value and being
// the last rule in the file will match when no other rule knows what to do
// about the character. It is reported as an error but is not passed on to the
// parser. This means that the parser to deal with the gramamr file anyway
// but we will not try to analyse or code generate from a file with lexical
// errors.
//
// Comment this rule out to allow the error to be propagated to the parser

ERRCHAR
    :	.	-> channel(HIDDEN)
    ;


// ======================================================
// Lexer modes

// -------------------------
// Arguments

mode Argument;			// E.g., [int x, List<String> a[]]

    NESTED_ARGUMENT			: LBrack			-> type(ARGUMENT_CONTENT), pushMode(Argument)	;

    ARGUMENT_ESCAPE			: EscAny			-> type(ARGUMENT_CONTENT)		;

    ARGUMENT_STRING_LITERAL	: DQuoteLiteral	-> type(ARGUMENT_CONTENT)		;
    ARGUMENT_CHAR_LITERAL	: SQuoteLiteral	-> type(ARGUMENT_CONTENT)		;

    END_ARGUMENT			: RBrack	{ self.handleEndArgument() }	;

    // added this to return non-EOF token type here. EOF does something weird
    UNTERMINATED_ARGUMENT 	: EOF		-> popMode		;

    ARGUMENT_CONTENT		: .							;


// -------------------------
// Actions
//
// Many language targets use {} as block delimiters and so we
// must recursively match {} delimited blocks to balance the
// braces. Additionally, we must make some assumptions about
// literal string representation in the target language. We assume
// that they are delimited by ' or " and so consume these
// in their own alts so as not to inadvertantly match {}.

mode Action;

    NESTED_ACTION			: LBrace			-> type(ACTION_CONTENT), pushMode(Action)	;

    ACTION_ESCAPE			: EscAny			-> type(ACTION_CONTENT)		;

    ACTION_STRING_LITERAL	: DQuoteLiteral		-> type(ACTION_CONTENT)		;
    ACTION_CHAR_LITERAL		: SQuoteLiteral		-> type(ACTION_CONTENT)		;

    ACTION_DOC_COMMENT		: DocComment		-> type(ACTION_CONTENT)		;
    ACTION_BLOCK_COMMENT	: BlockComment 		-> type(ACTION_CONTENT)		;
    ACTION_LINE_COMMENT		: LineComment 		-> type(ACTION_CONTENT)		;

    END_ACTION				: RBrace	{ self.handleEndAction() }	;

    UNTERMINATED_ACTION		: EOF		-> popMode		;

    ACTION_CONTENT			: .							;


// -------------------------

mode Options;

    OPT_DOC_COMMENT		: DocComment		-> type(DOC_COMMENT), channel(OFF_CHANNEL)		;
    OPT_BLOCK_COMMENT	: BlockComment 		-> type(BLOCK_COMMENT), channel(OFF_CHANNEL)	;
    OPT_LINE_COMMENT	: LineComment 		-> type(LINE_COMMENT), channel(OFF_CHANNEL)		;

    OPT_LBRACE			: LBrace			-> type(LBRACE)				;
    OPT_RBRACE			: RBrace			-> type(RBRACE), popMode	;

    OPT_ID				: Id				-> type(ID)					;
    OPT_DOT				: Dot				-> type(DOT)				;
    OPT_ASSIGN			: Equal				-> type(ASSIGN)				;
    OPT_STRING_LITERAL	: SQuoteLiteral		-> type(STRING_LITERAL)		;
    OPT_INT				: DecimalNumeral	-> type(INT)				;
    OPT_STAR			: Star				-> type(STAR)				;
    OPT_SEMI			: Semi				-> type(SEMI)				;

    OPT_WS				: Ws+	-> type(WS), channel(OFF_CHANNEL) 	;


// -------------------------

mode Tokens;

    TOK_DOC_COMMENT		: DocComment		-> type(DOC_COMMENT), channel(OFF_CHANNEL)		;
    TOK_BLOCK_COMMENT	: BlockComment 		-> type(BLOCK_COMMENT), channel(OFF_CHANNEL)	;
    TOK_LINE_COMMENT	: LineComment 		-> type(LINE_COMMENT), channel(OFF_CHANNEL)		;

    TOK_LBRACE			: LBrace			-> type(LBRACE)				;
    TOK_RBRACE			: RBrace			-> type(RBRACE), popMode	;

    TOK_ID				: Id				-> type(ID)					;
    TOK_DOT				: Dot				-> type(DOT)				;
    TOK_COMMA			: Comma				-> type(COMMA)				;

    TOK_WS				: Ws+	-> type(WS), channel(OFF_CHANNEL) 	;


// -------------------------

mode Channels;	// currently same as Tokens mode; distinguished by keyword

    CHN_DOC_COMMENT		: DocComment		-> type(DOC_COMMENT), channel(OFF_CHANNEL)		;
    CHN_BLOCK_COMMENT	: BlockComment 		-> type(BLOCK_COMMENT), channel(OFF_CHANNEL)	;
    CHN_LINE_COMMENT	: LineComment 		-> type(LINE_COMMENT), channel(OFF_CHANNEL)		;

    CHN_LBRACE			: LBrace			-> type(LBRACE)				;
    CHN_RBRACE			: RBrace			-> type(RBRACE), popMode	;

    CHN_ID				: Id				-> type(ID)					;
    CHN_DOT				: Dot				-> type(DOT)				;
    CHN_COMMA			: Comma				-> type(COMMA)				;

    CHN_WS				: Ws+	-> type(WS), channel(OFF_CHANNEL) 	;


// -------------------------

mode LexerCharSet;

    LEXER_CHAR_SET_BODY
        :	(	~[\]\\]
            |	EscAny
            )+				-> more
        ;

    LEXER_CHAR_SET
        :	RBrack			-> popMode
        ;

    UNTERMINATED_CHAR_SET
        :	EOF				-> popMode
        ;


// ------------------------------------------------------------------------------
// Grammar specific Keywords, Punctuation, etc.

fragment Id	: NameStartChar NameChar*;
