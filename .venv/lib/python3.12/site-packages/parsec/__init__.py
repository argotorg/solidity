#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
A universal Python parser combinator library inspired by Parsec library of Haskell.
'''

__author__ = 'He Tao, sighingnow@gmail.com'

try:
    from inspect import getfullargspec as getargspec
except ImportError:
    from inspect import getargspec as getargspec

import operator
import re
import inspect
import warnings
from functools import reduce, wraps
from collections import namedtuple

##########################################################################
# Text.Parsec.Error
##########################################################################

def expected_arguments(callable):
    if inspect.isbuiltin(callable):
        # NOTE: we cannot perform introspection on builtins
        return 1
    return len(getargspec(callable).args)

class ParseError(RuntimeError):
    '''Type for parse error.'''

    def __init__(self, expected, text, index):
        super(ParseError, self).__init__() # compatible with Python 2.
        self.expected = expected
        self.text = text
        self.index = index

    @staticmethod
    def loc_info(text, index):
        '''Location of `index` in source code `text`.'''
        if index > len(text):
            raise ValueError('Invalid index.')
        if isinstance(text, str):
            line, last_ln = text.count('\n', 0, index), text.rfind('\n', 0, index)
        else:
            line, last_ln = 0, index
        col = index - (last_ln + 1)
        return (line, col)

    def loc(self):
        '''Locate the error position in the source code text.'''
        try:
            return '{}:{}'.format(*ParseError.loc_info(self.text, self.index))
        except ValueError:
            return '<out of bounds index {!r}>'.format(self.index)

    def __str__(self):
        return 'expected: {!r} at {}'.format(self.expected, self.loc())


##########################################################################
# Definition the Value model of parsec.py.
##########################################################################


class Value(namedtuple('Value', 'status index value expected')):
    '''Represent the result of the Parser.'''
    @staticmethod
    def success(index, actual):
        '''Create success value.'''
        return Value(True, index, actual, None)

    @staticmethod
    def failure(index, expected):
        '''Create failure value.'''
        return Value(False, index, None, expected)

    def aggregate(self, other=None):
        '''collect the furthest failure from self and other.'''
        if not self.status:
            return self
        if not other:
            return self
        if not other.status:
            return other
        return Value.success(other.index, self.value + other.value)

    def update_index(self, index=None):
        if index is None:
            return self
        else:
            return Value(self.status, index, self.value, self.expected)

    @staticmethod
    def combinate(values):
        '''Aggregate multiple values into tuple'''
        if not values:
            raise TypeError("cannot call combinate without any value")

        for v in values:
            if not v.status:
                return v
        out_values = tuple([v.value for v in values])
        return Value.success(values[-1].index, out_values)

    def __str__(self):
        return 'Value: state: {},  @index: {}, values: {}, expected: {}'.format(
            self.status, self.index, self.value, self.expected)

##########################################################################
# Text.Parsec.Prim
##########################################################################


class Parser(object):
    '''
    A Parser is an object that wraps a function to do the parsing work.
    Arguments of the function should be a string to be parsed and the index on
    which to begin parsing.

    The function should return either Value.success(next_index, value) if
    parsing successfully, or Value.failure(index, expected) on the failure.
    '''

    def __init__(self, fn):
        '''`fn` is the function to wrap.'''
        self.fn = fn

    def __call__(self, text, index):
        '''call wrapped function.'''
        return self.fn(text, index)

    def __repr__(self):
        if hasattr(self.fn, "__name__"):
            return self.fn.__name__
        return super().__repr__()

    def parse(self, text):
        '''Parses a given string `text`.'''
        return self.parse_partial(text)[0]

    def parse_partial(self, text):
        '''Parse the longest possible prefix of a given string.

        Return a tuple of the result value and the rest of the string.

        If failed, raise a ParseError. '''
        res = self(text, 0)
        if res.status:
            return (res.value, text[res.index:])
        else:
            raise ParseError(res.expected, text, res.index)

    def parse_strict(self, text):
        '''Parse the longest possible prefix of the entire given string.

        If the parser worked successfully and NONE text was rested, return the
        result value, else raise a ParseError.

        The difference between `parse` and `parse_strict` is that whether entire
        given text must be used.'''
        # pylint: disable=comparison-with-callable
        # Here the `<` is not comparison.
        return (self < eof()).parse_partial(text)[0]

    def bind(self, fn):
        '''This is the monadic binding operation. Returns a parser which, if
        parser is successful, passes the result to fn, and continues with the
        parser returned from fn.
        '''
        args_count = expected_arguments(fn)
        if not 1 <= args_count <= 2:
            raise TypeError("can only bind on a function with one or two arguments, fn/{}".format(args_count))

        @Parser
        def bind_parser(text, index):
            res = self(text, index)
            if not res.status:
                return res

            return (fn(res.value, index) if args_count == 2 else fn(res.value))(text, res.index)
        return bind_parser

    def compose(self, other):
        '''(>>) Sequentially compose two actions, discarding any value produced
        by the first.'''
        @Parser
        def compose_parser(text, index):
            res = self(text, index)
            return res if not res.status else other(text, res.index)
        return compose_parser

    def joint(self, *parsers):
        '''(+) Joint two or more parsers into one. Return the aggregate of two results
        from this two parser.'''
        return joint(self, *parsers)

    def choice(self, other):
        '''(|) This combinator implements choice. The parser p | q first applies p.

        - If it succeeds, the value of p is returned.
        - If p fails **without consuming any input**, parser q is tried.

        NOTICE: without backtrack.'''
        @Parser
        def choice_parser(text, index):
            res = self(text, index)
            return res if res.status or res.index != index else other(text, index)
        return choice_parser

    def try_choice(self, other):
        '''(^) Choice with backtrack. This combinator is used whenever arbitrary
        look ahead is needed. The parser p || q first applies p, if it success,
        the value of p is returned. If p fails, it pretends that it hasn't consumed
        any input, and then parser q is tried.
        '''
        @Parser
        def try_choice_parser(text, index):
            res = self(text, index)
            return res if res.status else other(text, index)
        return try_choice_parser

    def skip(self, other):
        '''(<<) Ends with a specified parser, and at the end parser consumed the
        end flag.'''
        @Parser
        def skip_parser(text, index):
            res = self(text, index)
            if not res.status:
                return res
            end = other(text, res.index)
            if end.status:
                return Value.success(end.index, res.value)
            else:
                return Value.failure(end.index, 'ends with {}'.format(end.expected))
        return skip_parser

    def ends_with(self, other):
        '''(<) Ends with a specified parser, and at the end parser hasn't consumed
        any input.'''
        @Parser
        def ends_with_parser(text, index):
            res = self(text, index)
            if not res.status:
                return res
            end = other(text, res.index)
            if end.status:
                return res
            else:
                return Value.failure(end.index, 'ends with {}'.format(end.expected))
        return ends_with_parser

    def excepts(self, other):
        '''Fail though matched when the consecutive parser `other` success for the rest text.'''
        @Parser
        def excepts_parser(text, index):
            res = self(text, index)
            if not res.status:
                return res
            lookahead = other(text, res.index)
            if lookahead.status:
                return Value.failure(res.index, 'should not be "{}"'.format(lookahead.value))
            else:
                return res
        return excepts_parser

    def parsecmap(self, fn, star=False):
        '''Returns a parser that transforms the produced value of parser with `fn`.'''
        def mapper(res):
            # unpack tuple
            result = fn(*res) if star else fn(res)
            return success_with(result, advance=False)
        return self.bind(mapper)

    def map(self, fn, star=False):
        '''Functor map on the parsed value with `fn`.
        Alias to parsecmap
        '''
        return self.parsecmap(fn, star=star)

    def parsecapp(self, other):
        '''Returns a parser that applies the produced value of this parser to the produced value of `other`.'''
        # pylint: disable=unnecessary-lambda
        return self.bind(lambda res: other.parsecmap(lambda x: res(x)))

    def apply(self, other):
        '''Apply the function produced by self on the result of other.
        Alias to parsecapp
        '''
        return self.parsecapp(other)

    def result(self, res):
        '''Return a value according to the parameter `res` when parse successfully.'''
        return self >> success_with(res, advance=False)

    def mark(self):
        '''Mark the line and column information of the result of this parser.'''
        def pos(text, index):
            return ParseError.loc_info(text, index)

        def mark(value, index):
            @Parser
            def mark(text, resultant_index):
                return Value.success(resultant_index, (pos(text, index), value, pos(text, resultant_index)))
            return mark

        return self >= mark

    def desc(self, description):
        '''Describe a parser, when it failed, print out the description text.'''
        return self | fail_with(description)

    def __or__(self, other):
        '''Implements the `(|)` operator, means `choice`.'''
        return self.choice(other)

    def __xor__(self, other):
        '''Implements the `(^)` operator, means `try_choice`.'''
        return self.try_choice(other)

    def __add__(self, other):
        '''Implements the `(+)` operator, means `joint`.'''
        return self.joint(other)

    def __rshift__(self, other):
        '''Implements the `(>>)` operator, means `compose`.'''
        return self.compose(other)

    def __gt__(self, other):
        '''Implements the `(>)` operator, means `compose`.'''
        return self.compose(other)

    def __irshift__(self, other):
        '''Implements the `(>>=)` operator, means `bind`.'''
        warnings.warn('Call to deprecated operator (`>>=`) as it is an in-place '
                      'operator and offten causing misleading, using (`>=`) for '
                      'bind() instead.', category=DeprecationWarning)
        return self.bind(other)

    def __ge__(self, other):
        '''Implements the `(>=)` operator, means `bind`.'''
        return self.bind(other)

    def __lshift__(self, other):
        '''Implements the `(<<)` operator, means `skip`.'''
        return self.skip(other)

    def __lt__(self, other):
        '''Implements the `(<)` operator, means `ends_with`.'''
        return self.ends_with(other)

    def __truediv__(self, other):
        '''Implements the `(/)` operator, means `excepts`.'''
        return self.excepts(other)


def parse(p, text, index=0):
    '''Parse a string and return the result or raise a ParseError.'''
    return p.parse(text[index:])


def bind(p, fn):
    '''Bind two parsers, implements the operator of `(>=)`.'''
    return p.bind(fn)


def compose(pa, pb):
    '''Compose two parsers, implements the operator of `(>>)`, or `(>)`.'''
    return pa.compose(pb)


def joint(*parsers):
    '''Joint two or more parsers, implements the operator of `(+)`.'''
    @Parser
    def joint_parser(text, index):
        values = []
        prev_v = None
        for p in parsers:
            if prev_v:
                index = prev_v.index
            prev_v = v = p(text, index)
            if not v.status:
                return v
            values.append(v)
        return Value.combinate(values)
    return joint_parser


def choice(pa, pb):
    '''Choice one from two parsers, implements the operator of `(|)`.'''
    return pa.choice(pb)


def try_choice(pa, pb):
    '''Choose one from two parsers with backtrack, implements the operator of `(^)`.'''
    return pa.try_choice(pb)

def try_choices(*choices):
    '''Choose one from the choices'''
    return reduce(try_choice, choices)

def try_choices_longest(*choices):
    if not choices:
        raise TypeError("choices cannot be empty")

    if not all(isinstance(choice, Parser) for choice in choices):
        raise TypeError("choices can only be Parsers")

    @Parser
    def longest(text, index):
        results = list(map(lambda choice: choice(text, index), choices))
        if all(not result.status for result in results):
            return Value.failure(index, 'does not match with any choices {}'.format(list(zip(choices, results))))

        successful_results = list(filter(lambda result: result.status, results))
        return max(successful_results, key=lambda result: result.index)
    return longest

def skip(pa, pb):
    '''Ends with a specified parser, and at the end parser consumed the end flag.
    Implements the operator of `(<<)`.'''
    return pa.skip(pb)


def ends_with(pa, pb):
    '''Ends with a specified parser, and at the end parser hasn't consumed any input.
    Implements the operator of `(<)`.'''
    return pa.ends_with(pb)


def excepts(pa, pb):
    '''Fail `pa` though matched when the consecutive parser `pb` success for the rest text.'''
    return pa.excepts(pb)


def parsecmap(p, fn):
    '''Returns a parser that transforms the produced value of parser with `fn`.'''
    return p.parsecmap(fn)


def parsecapp(p, other):
    '''Returns a parser that applies the produced value of this parser to the produced
    value of `other`.

    There should be an operator `(<*>)`, but that is impossible in Python.
    '''
    return p.parsecapp(other)


def result(p, res):
    '''Return a value according to the parameter `res` when parse successfully.'''
    return p.result(res)


def mark(p):
    '''Mark the line and column information of the result of the parser `p`.'''
    return p.mark()


def desc(p, description):
    '''Describe a parser, when it failed, print out the description text.'''
    return p.desc(description)


##########################################################################
# Parser Generator
#
# The most powerful way to construct a parser is to use the generate decorator.
# the `generate` creates a parser from a generator that should yield parsers.
# These parsers are applied successively and their results are sent back to the
# generator using `.send()` protocol. The generator should return the result or
# another parser, which is equivalent to applying it and returning its result.
#
# Note that `return` with arguments inside generator is not supported in Python 2.
# Instead, we can raise a `StopIteration` to return the result in Python 2.
#
# See #15 and `test_generate_raise` in tests/test_parsec.py
##########################################################################


def generate(fn):
    '''Parser generator. (combinator syntax).'''
    if isinstance(fn, str):
        return lambda f: generate(f).desc(fn)

    @wraps(fn)
    @Parser
    def generated(text, index):
        try:
            iterator, value = fn(), None
            while True:
                parser = iterator.send(value)
                res = parser(text, index)
                if not res.status:  # this parser failed.
                    return res
                value, index = res.value, res.index  # iterate
        except StopIteration as stop:
            endval = stop.value
            if isinstance(endval, Parser):
                return endval(text, index)
            else:
                return Value.success(index, endval)
        except RuntimeError as error:
            stop = error.__cause__
            if isinstance(stop, StopIteration) and hasattr(stop, "value"): 
                endval = stop.value
                if isinstance(endval, Parser):
                    return endval(text, index)
                else:
                    return Value.success(index, endval)
            # not what we want
            raise error from None
    return generated.desc(fn.__name__)


##########################################################################
# Text.Parsec.Combinator
##########################################################################


def times(p, mint, maxt=None):
    '''Repeat a parser between `mint` and `maxt` times. DO AS MUCH MATCH AS IT CAN.
    Return a list of values.'''
    maxt = maxt if maxt else mint

    @Parser
    def times_parser(text, index):
        cnt, values, res = 0, [], None
        while cnt < maxt:
            res = p(text, index)
            if res.status:
                if maxt == float('inf') and res.index == index:
                    # TODO: check whether it reaches mint
                    # prevent infinite loop, see GH-43
                    break
                values.append(res.value)
                index, cnt = res.index, cnt + 1
            else:
                if cnt >= mint:
                    break
                else:
                    return res  # failed, throw exception.
            if cnt >= maxt:  # finish.
                break
            # If we don't have any remaining text to start next loop, we need break.
            #
            # We cannot put the `index < len(text)` in where because some parser can
            # success even when we have no any text. We also need to detect if the
            # parser consume no text.
            #
            # See: #28
            if index >= len(text):
                if cnt >= mint:
                    break  # we already have decent result to return
                else:
                    r = p(text, index)
                    if index != r.index:  # report error when the parser cannot success with no text
                        return Value.failure(index, "already meets the end, no enough text")
        return Value.success(index, values)
    return times_parser


def count(p, n):
    '''`count p n` parses n occurrences of p. If n is smaller or equal to zero,
    the parser equals to return []. Returns a list of n values returned by p.'''
    return times(p, n, n)


def optional(p, default_value=None):
    '''`Make a parser as optional. If success, return the result, otherwise return
    default_value silently, without raising any exception. If default_value is not
    provided None is returned instead.
    '''
    @Parser
    def optional_parser(text, index):
        res = p(text, index)
        if res.status:
            return Value.success(res.index, res.value)
        else:
            # Return the maybe existing default value without doing anything.
            return Value.success(index, default_value)
    return optional_parser


def many(p):
    '''Repeat a parser 0 to infinity times. DO AS MUCH MATCH AS IT CAN.
    Return a list of values.'''
    return times(p, 0, float('inf'))


def many1(p):
    '''Repeat a parser 1 to infinity times. DO AS MUCH MATCH AS IT CAN.
    Return a list of values.'''
    return times(p, 1, float('inf'))


def separated(p, sep, mint, maxt=None, end=None):
    '''Repeat a parser `p` separated by `s` between `mint` and `maxt` times.

    - When `end` is None, a trailing separator is optional.
    - When `end` is True, a trailing separator is required.
    - When `end` is False, a trailing separator will not be parsed.

    MATCHES AS MUCH AS POSSIBLE.

    Return list of values returned by `p`.'''
    maxt = maxt if maxt else mint

    @Parser
    def sep_parser(text, index):
        cnt, values_index, values, res = 0, index, [], None
        while cnt < maxt:
            res = p(text, index)
            if res.status:
                current_value_index = res.index
                current_value = res.value
                index, cnt = res.index, cnt + 1
            else:
                if cnt < mint:
                    return res  # error: need more elements, but no `p` found.
                else:
                    return Value.success(values_index, values)

            # consume the sep
            res = sep(text, index)
            if res.status:  # `sep` found, consume it (advance index)
                index = res.index
                if end in [True, None]:
                    current_value_index = res.index
            else:
                if cnt < mint or (cnt == mint and end is True):
                    return res  # error: need more elements, but no `sep` found.
                else:
                    if end is True:
                        # step back
                        return Value.success(values_index, values)
                    else:
                        values_index = current_value_index
                        values.append(current_value)
                        return Value.success(values_index, values)

            # record the new value
            values_index = current_value_index
            values.append(current_value)
        return Value.success(values_index, values)
    return sep_parser


def sepBy(p, sep):
    '''`sepBy(p, sep)` parses zero or more occurrences of p, separated by `sep`.
    Returns a list of values returned by `p`.'''
    return separated(p, sep, 0, maxt=float('inf'), end=False)


def sepBy1(p, sep):
    '''`sepBy1(p, sep)` parses one or more occurrences of `p`, separated by
    `sep`. Returns a list of values returned by `p`.'''
    return separated(p, sep, 1, maxt=float('inf'), end=False)


def endBy(p, sep):
    '''`endBy(p, sep)` parses zero or more occurrences of `p`, separated and
    ended by `sep`. Returns a list of values returned by `p`.'''
    return separated(p, sep, 0, maxt=float('inf'), end=True)


def endBy1(p, sep):
    '''`endBy1(p, sep) parses one or more occurrences of `p`, separated and
    ended by `sep`. Returns a list of values returned by `p`.'''
    return separated(p, sep, 1, maxt=float('inf'), end=True)


def sepEndBy(p, sep):
    '''`sepEndBy(p, sep)` parses zero or more occurrences of `p`, separated and
    optionally ended by `sep`. Returns a list of
    values returned by `p`.'''
    return separated(p, sep, 0, maxt=float('inf'))


def sepEndBy1(p, sep):
    '''`sepEndBy1(p, sep)` parses one or more occurrences of `p`, separated and
    optionally ended by `sep`. Returns a list of values returned by `p`.'''
    return separated(p, sep, 1, maxt=float('inf'))


##########################################################################
# Text.Parsec.Char
##########################################################################

def satisfy(predicate, failure=None):
    @Parser
    def satisfy_parser(text, index=0):
        if index < len(text) and predicate(text[index]):
            return Value.success(index + 1, text[index])
        else:
            return Value.failure(index, failure or "does not satisfy predicate")
    return satisfy_parser

def any():
    '''Parses a arbitrary character.'''
    return satisfy(lambda _: True, 'a random char')

def one_of(s):
    '''Parses a char from specified string.'''
    return satisfy(lambda c: c in s, 'one of {}'.format(s))

def none_of(s):
    '''Parses a char NOT from specified string.'''
    return satisfy(lambda c: c not in s, 'none of {}'.format(s))

def space():
    '''Parses a whitespace character.'''
    return satisfy(str.isspace, 'one space')

def spaces():
    '''Parses zero or more whitespace characters.'''
    return many(space())

def letter():
    '''Parse a letter in alphabet.'''
    return satisfy(str.isalpha, 'a letter')

def digit():
    '''Parse a digit.'''
    return satisfy(str.isdigit, 'a digit')

def eof():
    '''Parses EOF flag of a string.'''
    @Parser
    def eof_parser(text, index=0):
        if index >= len(text):
            return Value.success(index, None)
        else:
            return Value.failure(index, 'EOF')
    return eof_parser

def string(s):
    '''Parses a string.'''
    @Parser
    def string_parser(text, index=0):
        slen, tlen = len(s), len(text)
        if ''.join(text[index:index + slen]) == s:
            return Value.success(index + slen, s)
        else:
            matched = 0
            while matched < slen and index + matched < tlen and text[index + matched] == s[matched]:
                matched = matched + 1
            return Value.failure(index + matched, s)
    return string_parser


def regex(exp, flags=0):
    '''Parses according to a regular expression.'''
    if isinstance(exp, str):
        exp = re.compile(exp, flags)

    @Parser
    def regex_parser(text, index):
        if not isinstance(text, str):
            return Value.failure(index, "`regex` combinator only accepts string as input, "
                                 "but got type {!r}, value is {!r}".format(type(text), text))

        match = exp.match(text, index)
        if match:
            return Value.success(match.end(), match.group(0))
        else:
            return Value.failure(index, exp.pattern)
    return regex_parser

def newline():
    return string("\n").desc("LF")

def crlf():
    return (string("\r") >> newline()).desc("CRLF")

def end_of_line():
    return (newline() | crlf()).desc("EOL")

##########################################################################
# Useful utility parsers
##########################################################################

def success_with(value, advance=False):
    return Parser(lambda _, index: Value.success(index + int(advance), value))

def fail_with(message):
    return Parser(lambda _, index: Value.failure(index, message))

def exclude(p, exclude):
    '''Fails parser p if parser `exclude` matches'''
    @Parser
    def exclude_parser(text, index):
        res = exclude(text, index)
        if res.status:
            return Value.failure(index, 'something other than {}'.format(res.value))
        else:
            return p(text, index)
    return exclude_parser

def lookahead(p):
    '''Parses without consuming'''
    @Parser
    def lookahead_parser(text, index):
        res = p(text, index)
        if res.status:
            return Value.success(index, res.value)
        else:
            return Value.failure(index, res.expected)
    return lookahead_parser


def unit(p):
    '''Converts a parser into a single unit. Only consumes input if the parser succeeds'''
    @Parser
    def unit_parser(text, index):
        res = p(text, index)
        if res.status:
            return Value.success(res.index, res.value)
        else:
            return Value.failure(index, res.expected)
    return unit_parser

def between(open, close, parser):
    @generate
    def between_parser():
        yield open
        results = yield parser
        yield close
        return results
    return between_parser

def fix(fn):
    '''Allow recursive parser using the Y combinator trick.

       Note that this version still yields the stack overflow problem, and will be fixed
       in later version.

       See also: https://github.com/sighingnow/parsec.py/issues/39.
    '''
    return (lambda x: x(x))(lambda y: fn(lambda *args: y(y)(*args)))

def validate(predicate):
    def validator(value):
        if predicate(value):
            return success_with(value, advance=False)
        else:
            return fail_with(f"{value} does not satisfy the given predicate {predicate}")
    return validator

##########################################################################
# Text.Parsec.Number
##########################################################################

sign = string("-").result(operator.neg).desc("'-'") | optional(string("+").desc("'+'")).result(lambda x: x)

def number(base, digit):
    return many1(digit).parsecmap(
        lambda digits: reduce(lambda accumulation, digit: accumulation * base + int(digit, base), digits, 0),
    )

binary_digit = one_of("01").desc("binary_digit")
binary_number = number(2, binary_digit).desc("binary_number")
binary = (one_of("bB") >> binary_number).desc("binary")

octal_digit = one_of("01234567").desc("octal_digit")
octal_number = number(8, octal_digit).desc("octal_number")
octal = (one_of("oO") >> octal_number).desc("octal")

hexadecimal_digit = one_of("0123456789ABCDEFabcdef").desc("hexadecimal_digit")
hexadecimal_number = number(16, hexadecimal_digit).desc("hexadecimal_number")
hexadecimal = (one_of("xX") >> hexadecimal_number).desc("hexadecimal")

decimal_number = number(10, digit()).desc("decimal_number")
decimal = decimal_number

zero_number = string("0") >> (hexadecimal | octal | binary | decimal | success_with(0))
natural = zero_number | decimal
integer = sign.apply(natural)
