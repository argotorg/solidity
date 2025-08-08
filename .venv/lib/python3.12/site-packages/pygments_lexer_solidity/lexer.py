# -*- coding: utf-8 -*-
"""
    pygments.lexers.solidity
    ~~~~~~~~~~~~~~~~~~~~~~~~

    Lexer for the Solidity language.

    :copyright: Copyright 2006-2015 by the Pygments team, see AUTHORS.
    :license: BSD, see LICENSE for details.
"""

import re

from pygments.lexer import (
    RegexLexer,
    bygroups,
    combined,
    default,
    include,
    inherit,
    this,
    using,
    words,
)
from pygments.token import Text, Comment, Operator, Keyword, Name, String, \
    Number, Punctuation, Other

__all__ = ['SolidityLexer', 'YulLexer']


class BaseLexer(RegexLexer):
    """Common for both Solidity and Yul."""

    tokens = {
        'assembly': [
            include('comments'),
            include('numbers'),
            include('strings'),
            include('whitespace'),

            (r'\{', Punctuation, '#push'),
            (r'\}', Punctuation, '#pop'),
            (r'[(),]', Punctuation),
            (r':=|=:', Operator),
            (r'(let)(\s*)(\w*\b)',
             bygroups(Operator.Word, Text, Name.Variable)),

            # evm instructions; ordered by opcode
            (r'(stop|add|mul|sub|div|sdiv|mod|smod|addmod|mulmod|exp|'
             r'signextend|'
             r'lt|gt|slt|sgt|eq|iszero|and|or|xor|not|byte|shl|shr|sar|'
             r'keccak256|'
             r'address|balance|origin|caller|'
             r'callvalue|calldataload|calldatasize|calldatacopy|'
             r'codesize|codecopy|gasprice|extcodesize|extcodecopy|'
             r'returndatasize|returndatacopy|extcodehash|'
             r'blockhash|coinbase|timestamp|number|difficulty|gaslimit|'
             r'chainid|selfbalance|'
             r'pop|mload|mstore|mstore8|sload|sstore|'
             r'pc|msize|gas|'
             r'log0|log1|log2|log3|log4|'
             r'create|call|callcode|return|delegatecall|create2|'
             r'staticcall|revert|'
             r'invalid|selfdestruct)\b',
             Name.Function),

            # obsolete aliases for keccak256 and selfdestruct
            (r'(sha3|suicide)\b', Name.Function),

            (r'(case|default|for|if|switch)\b', Keyword),

            # everything else is either a local/external var, or label
            ('[a-zA-Z_]\w*', Name)
        ],
        'comment-parse-single': [
            include('natspec'),
            include('spdx'),
            (r'\n', Comment.Single, '#pop'),
            (r'[^\n]', Comment.Single),
        ],
        'comment-parse-multi': [
            include('natspec'),
            include('spdx'),
            (r'[^*/]', Comment.Multiline),
            (r'\*/', Comment.Multiline, '#pop'),
            (r'[*/]', Comment.Multiline),
        ],
        'comments': [
            (r'//', Comment.Single, 'comment-parse-single'),
            (r'/[*]', Comment.Multiline, 'comment-parse-multi'),
        ],
        'natspec': [
            (r'@(author|dev|inheritdoc|notice|param|return|title|'
             r'custom:[a-z][a-z-]*)\b',
             Comment.Special),
        ],
        'spdx': [
            (r'SPDX-License-Identifier:',
            Comment.Special),
        ],
        'numbers': [
            (r'0[xX][0-9a-fA-F]+', Number.Hex),
            (r'[0-9][0-9]*\.[0-9]+([eE][0-9]+)?', Number.Float),
            (r'[0-9]+([eE][0-9]+)?', Number.Integer),
        ],
        'string-parse-common': [
            # escapes
            (r'\\(u[0-9a-fA-F]{4}|x..|[^x])', String.Escape),
            # almost everything else is plain characters
            (r'[^\\"\'\n]+', String),
            # line continuation
            (r'\\\n', String),
            # stray backslash
            (r'\\', String)
        ],
        'string-parse-double': [
            (r'"', String, '#pop'),
            (r"'", String)
        ],
        'string-parse-single': [
            (r"'", String, '#pop'),
            (r'"', String)
        ],
        'strings': [
            # hexadecimal string literals
            (r"hex'[0-9a-fA-F]+'", String),
            (r'hex"[0-9a-fA-F]+"', String),
            # unicode string literals
            (r'unicode"', String, combined('string-parse-common',
                                    'string-parse-double')),
            (r"unicode'", String, combined('string-parse-common',
                                    'string-parse-single')),
            # usual strings
            (r'"', String, combined('string-parse-common',
                                    'string-parse-double')),
            (r"'", String, combined('string-parse-common',
                                    'string-parse-single'))
        ],
        'whitespace': [
            (r'\s+', Text)
        ],
    } # tokens


class SolidityLexer(BaseLexer):
    """For Solidity source code."""

    name = 'Solidity'
    aliases = ['sol', 'solidity']
    filenames = ['*.sol', '*.solidity']
    mimetypes = ['text/x-solidity']

    flags = re.DOTALL | re.UNICODE | re.MULTILINE

    def type_names(prefix, sizerange):
        """
        Helper for type name generation, like: bytes1 .. bytes32

        Assumes that the size range passed in is valid.
        """
        namelist = []
        for i in sizerange: namelist.append(prefix + str(i))
        return tuple(namelist)

    def type_names_mn(prefix, sizerangem, sizerangen):
        """
        Helper for type name generation, like: fixed8x0 .. fixed26x80

        Assumes that the size range passed in is valid.
        """
        lm = []
        ln = []
        namelist = []

        # construct lists out of ranges
        for i in sizerangem: lm.append(i)
        for i in sizerangen: ln.append(i)

        validpairs = [tuple([m,n]) for m in lm for n in ln]
        for i in validpairs:
            namelist.append(prefix + str(i[0]) + 'x' + str(i[1]))

        return tuple(namelist)


    tokens = {
        'assembly': [
            # labels
            (r'(\w*\b)(\:[^=])',
             bygroups(Name.Label, Punctuation)),

            # evm instructions present in `assembly` but not Yul
            (r'(jump|jumpi|jumpdest)\b', Name.Function),
            # TODO: rename helper: instructions, not types
            (words(type_names('dup', range(1, 16+1)),
                   suffix=r'\b'), Keyword.Function),
            (words(type_names('swap', range(1, 16+1)),
                   suffix=r'\b'), Keyword.Function),
            (words(type_names('push', range(1, 32+1)),
                   suffix=r'\b'), Keyword.Function),

            inherit,
        ],
        'keywords-builtins': [
            # compiler built-ins
            (r'(balance|now)\b', Name.Builtin),
            (r'selector\b', Name.Builtin),
            (r'(super|this)\b', Name.Builtin),
        ],
        'keywords-functions': [
            # receive/fallback functions
            (r'(receive|fallback)\b', Keyword.Function),

            # like block.hash and msg.gas in `keywords-nested`
            (r'(blockhash|gasleft)\b', Name.Function),

            # single-instruction yet function syntax
            (r'(selfdestruct|suicide)\b', Name.Function),

            # processed into many-instructions
            (r'(send|transfer|call|callcode|delegatecall)\b',
             Name.Function),
            (r'(assert|revert|require)\b', Name.Function),
            (r'push\b', Name.Function),

            # built-in functions and/or precompiles
            (words(('addmod', 'ecrecover', 'keccak256', 'mulmod',
                    'sha256', 'sha3', 'ripemd160'),
                   suffix=r'\b'), Name.Function),
        ],
        'keywords-types': [
            (words(('address', 'bool', 'byte', 'bytes', 'int', 'string',
                    'uint'),
                   suffix=r'\b'), Keyword.Type),
            (words(type_names('bytes', range(1, 32+1)),
                   suffix=r'\b'), Keyword.Type),
            (words(type_names('int', range(8, 256+1, 8)),
                   suffix=r'\b'), Keyword.Type),
            (words(type_names('uint', range(8, 256+1, 8)),
                   suffix=r'\b'), Keyword.Type),

            # not yet fully implemented, therefore reserved types
            (words(('fixed', 'ufixed'), suffix=r'\b'), Keyword.Reserved),
            (words(type_names_mn('fixed',
                                 range(8, 256+1, 8),
                                 range(0, 80+1, 1)),
                   suffix=r'\b'), Keyword.Reserved),
            (words(type_names_mn('ufixed',
                                 range(8, 256+1, 8),
                                 range(0, 80+1, 1)),
                   suffix=r'\b'), Keyword.Reserved),
        ],
        'keywords-nested': [
            (r'abi\.encode(|Packed|WithSelector|WithSignature)\b',
             Name.Builtin),
            (r'block\.(blockhash|chainid|coinbase|difficulty|gaslimit|hash|'
             r'number|timestamp)\b', Name.Builtin),
            (r'msg\.(data|gas|sender|value)\b', Name.Builtin),
            (r'tx\.(gasprice|origin)\b', Name.Builtin),
        ],
        'keywords-other': [
            (words(('for', 'in', 'while', 'do', 'break', 'return',
                    'returns', 'continue', 'if', 'else', 'throw',
                    'new', 'delete', 'try', 'catch'),
                   suffix=r'\b'), Keyword),

            (r'assembly\b', Keyword, 'assembly'),

            (words(('contract', 'interface', 'enum', 'event', 'function',
                    'constructor', 'library', 'mapping', 'modifier',
                    'struct', 'var'),
                   suffix=r'\b'), Keyword.Declaration),

            (r'(import|using)\b', Keyword.Namespace),

            # pragmas are not pragmatic in their formatting :/
            (r'pragma( experimental| solidity| abicoder|)\b', Keyword),
            # misc keywords
            (r'(_|as|constant|from|is)\b', Keyword),
            (r'emit\b', Keyword),
            # built-in modifier
            (r'payable\b', Keyword),
            # variable location specifiers
            (r'(calldata|memory|storage)\b', Keyword),
            # method visibility specifiers
            (r'(external|internal|private|public)\b', Keyword),
            # event parameter specifiers
            (r'(anonymous|indexed)\b', Keyword),
            # added in solc v0.4.0, not covered elsewhere
            (r'(abstract|pure|static|view)\b', Keyword),
            # added in solc v0.6.0, not covered elsewhere
            (r'(override|virtual)\b', Keyword),
            # added in solc v0.8.0
            (r'(unchecked)\b', Keyword),
            # type information
            (r'type\(.*\)\.(min|max|interfaceId|creationCode|runtimeCode|name)\b', Keyword),

            # reserved for future use since don't-remember-when
            (words(('after', 'case', 'default', 'final', 'in', 'inline',
                    'let', 'match', 'null', 'of', 'relocatable', 'static',
                    'switch', 'typeof'),
                   suffix=r'\b'), Keyword.Reserved),
            # reserved for future use since solc v0.5.0
            (words(('alias', 'apply', 'auto', 'copyof', 'define',
                    'immutable', 'implements', 'macro', 'mutable',
                    'partial', 'promise', 'reference',
                    'sealed', 'sizeof', 'supports', 'typedef'),
                   suffix=r'\b'), Keyword.Reserved),

            # built-in constants
            (r'(true|false)\b', Keyword.Constant),
            (r'(wei|finney|szabo|ether)\b', Keyword.Constant),
            (r'(seconds|minutes|hours|days|weeks|years)\b',
             Keyword.Constant),
        ],

        'root': [
            inherit,
            include('comments'),
            include('keywords-builtins'),
            include('keywords-functions'),
            include('keywords-types'),
            include('keywords-nested'),
            include('keywords-other'),
            include('numbers'),
            include('strings'),
            include('whitespace'),

            (r'\+\+|--|\*\*|\?|:|~|&&|\|\||=>|==?|!=?|'
             r'(<<|>>>?|[-<>+*%&|^/])=?', Operator),

            (r'[{(\[;,]', Punctuation),
            (r'[})\].]', Punctuation),

            # everything else is a var/function name
            ('[a-zA-Z$_]\w*', Name),
        ],
    } # tokens


class YulLexer(BaseLexer):
    """For Yul stand-alone source code."""

    name = 'Yul'
    aliases = ['yul']
    filenames = ['*.yul']
    mimetypes = ['text/x-yul']

    flags = re.DOTALL | re.UNICODE | re.MULTILINE

    tokens = {
        'root': [
            inherit,

            # Yul-specific
            (r'(code|data|function|object)\b', Keyword),
            (r'data(copy|offset|size)\b', Keyword.Function),
            (r'->', Operator),

            include('assembly'),

            # ':' - variable declaration type hint - catch it last
            (':', Punctuation),
        ],
    } # tokens
