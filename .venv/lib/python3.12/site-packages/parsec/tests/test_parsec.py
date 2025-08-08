#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import generators

'''
Test the basic functions of parsec.py.
'''

__author__ = 'He Tao, sighingnow@gmail.com'

import re
import random
import unittest

from parsec import *

class ParseErrorTest(unittest.TestCase):
    def test_loc_info_should_throw_on_invalid_index(self):
        with self.assertRaises(ValueError):
            ParseError.loc_info("", 1)

    def test_loc_info_should_use_default_values_when_text_is_not_str(self):
        self.assertEqual(ParseError.loc_info([0], 0), (0, -1))

    def test_str(self):
        self.assertTrue(str(ParseError("foo bar", "test", 0)))
        # trigger ValueError
        self.assertTrue(str(ParseError("foo bar", "", 1)))

class ValueTest(unittest.TestCase):
    def test_aggregate(self):
        value = Value.failure(-1, "this")
        self.assertEqual(value.aggregate(), value)

        value = Value.success(-1, ["foo"])
        self.assertEqual(value.aggregate(), value)

        other = Value.failure(-1, "that")
        self.assertEqual(value.aggregate(other), other)

        other = Value.success(0, ["bar"])
        self.assertEqual(value.aggregate(other), Value.success(0, ["foo", "bar"]))

    def test_update_index(self):
        value = Value.success(0, None)
        self.assertEqual(value.update_index(), value)
        self.assertEqual(value.update_index(1), Value.success(1, None))

    def test_combinate(self):
        with self.assertRaisesRegex(TypeError, "cannot call combinate without any value"):
            Value.combinate([])

        self.assertEqual(Value.combinate([Value.success(0, None)]), Value.success(0, (None,)))
        self.assertEqual(Value.combinate([Value.failure(0, "expect to fail")]), Value.failure(0, "expect to fail"))
        self.assertEqual(Value.combinate([Value.success(0, None), Value.failure(0, "expect to fail")]), Value.failure(0, "expect to fail"))

class ParsecTest(unittest.TestCase):
    '''Test the implementation of Text.Parsec. (The final test for all apis)'''
    def test_repr(self):
        self.assertIsNotNone(repr(any()))

    def test_times_with_then(self):
        parser = times(letter(), 3) >> digit()
        self.assertEqual(parser.parse('xyz1'), '1')
        self.assertRaises(ParseError, parser.parse, 'xy1')
        self.assertRaises(ParseError, parser.parse, 'xyz')
        self.assertRaises(ParseError, parser.parse, 'xyzw')

    def test_times_inf_maxt(self):
        parser = times(eof(), 1, float('inf'))
        self.assertEqual(parser.parse(''), [])
        # self.assertEqual(parser.parse('abc'), ['a', 'b', 'c'])

    def test_many_with_then(self):
        parser = many(string('x')) >> string('y')
        self.assertEqual(parser.parse('y'), 'y')
        self.assertEqual(parser.parse('xy'), 'y')
        self.assertEqual(parser.parse('xxxxxy'), 'y')

    def test_times_with_min_and_max(self):
        parser = times(letter(), 2, 4)
        self.assertEqual(parser.parse('xy'), ['x', 'y'])
        self.assertEqual(parser.parse('xyz'), ['x', 'y', 'z'])
        self.assertEqual(parser.parse('xyzw'), ['x', 'y', 'z', 'w'])
        self.assertEqual(parser.parse('xyzwv'), ['x', 'y', 'z', 'w'])
        self.assertRaises(ParseError, parser.parse, 'x')

    def test_times_with_min_and_max_and_then(self):
        parser = times(letter(), 2, 4) >> digit()
        self.assertEqual(parser.parse('xy1'), '1')
        self.assertEqual(parser.parse('xyz1'), '1')
        self.assertEqual(parser.parse('xyzw1'), '1')
        self.assertRaises(ParseError, parser.parse, 'xy')
        self.assertRaises(ParseError, parser.parse, 'xyzw')
        self.assertRaises(ParseError, parser.parse, 'xyzwv1')
        self.assertRaises(ParseError, parser.parse, 'x1')

class ParsecPrimTest(unittest.TestCase):
    '''Test the implementation of Text.Parsec.Prim.'''

    def test_bind(self):
        nonlocals = {'piped': None}

        def binder(x):
            nonlocals['piped'] = x
            return string('y')

        parser = string('x') >= binder
        self.assertEqual(parser.parse('xy'), 'y')
        self.assertEqual(nonlocals['piped'], 'x')
        self.assertRaises(ParseError, parser.parse, 'x')

        with self.assertRaises(TypeError):
            parser >= (lambda x, y, z: any())

    def test_compose(self):
        parser = string('x') >> string('y')
        self.assertEqual(parser.parse('xy'), 'y')
        self.assertRaises(ParseError, parser.parse, 'y')
        self.assertRaises(ParseError, parser.parse, 'z')

    def test_joint(self):
        parser = string('x') + string('y')
        self.assertEqual(parser.parse('xy'), ('x', 'y'))
        self.assertRaises(ParseError, parser.parse, 'y')
        self.assertRaises(ParseError, parser.parse, 'z')

        nonlocals = {'changed': False}

        @generate
        def fn():
            nonlocals['changed'] = True
            yield string('y')

        parser = string('x') + fn
        self.assertRaises(ParseError, parser.parse, '1')
        self.assertEqual(nonlocals['changed'], False)

    def test_choice(self):
        parser = string('x') | string('y')
        self.assertEqual(parser.parse('x'), 'x')
        self.assertEqual(parser.parse('y'), 'y')
        self.assertRaises(ParseError, parser.parse, 'z')

        parser = string('xy') | string('xz')
        self.assertEqual(parser.parse('xy'), 'xy')
        self.assertRaises(ParseError, parser.parse, 'xz')

    def test_try_choice(self):
        parser = string('x') ^ string('y')
        self.assertEqual(parser.parse('x'), 'x')
        self.assertEqual(parser.parse('y'), 'y')
        self.assertRaises(ParseError, parser.parse, 'z')

        parser = string('xy') ^ string('xz')
        self.assertEqual(parser.parse('xy'), 'xy')
        self.assertEqual(parser.parse('xz'), 'xz')

    def test_try_choices(self):
        # cannot try_choices without choices
        with self.assertRaisesRegex(TypeError, r"reduce\(\) of empty \w+ with no initial value"):
            try_choices()

        parser = try_choices(string('x'))
        self.assertEqual(parser.parse('x'), 'x')

        parser = try_choices(string('yz'), string('y'))
        self.assertEqual(parser.parse('yz'), 'yz')
        self.assertEqual(parser.parse('y'), 'y')

        parser = try_choices(string('x'), string('yz'), string('y'))
        self.assertEqual(parser.parse('x'), 'x')
        self.assertEqual(parser.parse('yz'), 'yz')
        self.assertEqual(parser.parse('y'), 'y')

    def test_try_choices_longest(self):
        with self.assertRaisesRegex(TypeError, "choices cannot be empty"):
            try_choices_longest()

        with self.assertRaisesRegex(TypeError, "choices can only be Parsers"):
            try_choices_longest(None)

        parser = try_choices_longest(string("x"), string("xyz"))
        self.assertEqual(parser.parse("x"), "x")
        self.assertEqual(parser.parse("xyz"), "xyz")

        with self.assertRaisesRegex(ParseError, r"does not match with any choices .*"):
            parser.parse("y")

    def test_ends_with(self):
        parser = string('x') < string('y')
        self.assertEqual(parser.parse('xy'), 'x')
        self.assertRaises(ParseError, parser.parse, 'xx')

        with self.assertRaises(ParseError):
            parser.parse('y')

    def test_map(self):

        def mapfn(p):
            return p + p

        parser = string('x').map(mapfn)
        self.assertEqual(parser.parse('x'), 'xx')

    def test_apply(self):

        def genfn(p):
            return lambda c: 'fn:' + p + c + c

        parser = string('x').map(genfn).apply(string('y'))
        self.assertEqual(parser.parse('xy'), 'fn:xyy')

    def test_desc(self):
        parser = string('x')
        self.assertEqual(parser.parse('x'), 'x')
        self.assertRaises(ParseError, parser.parse, 'y')

    def test_mark(self):
        parser = many1(mark(many(letter())) << string("\n"))

        lines = parser.parse("asdf\nqwer\n")

        self.assertEqual(len(lines), 2)

        (start, letters, end) = lines[0]
        self.assertEqual(start, (0, 0))
        self.assertEqual(letters, ['a', 's', 'd', 'f'])
        self.assertEqual(end, (0, 4))

        (start, letters, end) = lines[1]
        self.assertEqual(start, (1, 0))
        self.assertEqual(letters, ['q', 'w', 'e', 'r'])
        self.assertEqual(end, (1, 4))

        with self.assertRaises(ParseError):
            parser.parse("1")

    def test_choice_with_compose(self):
        parser = (string('\\') >> string('y')) | string('z')
        self.assertEqual(parser.parse('\\y'), 'y')
        self.assertEqual(parser.parse('z'), 'z')
        self.assertRaises(ParseError, parser.parse, '\\z')

class ParsecCombinatorTest(unittest.TestCase):
    '''Test the implementation of Text.Parsec.Combinator.'''
    def test_times(self):
        parser = times(string('x'), 2, 10)
        self.assertEqual(parser.parse('xxx'), ['x', 'x', 'x'])
        self.assertRaises(ParseError, parser.parse, 'x')
        self.assertRaises(ParseError, parser.parse, 'xyyyyyyyyyyyyyyyyyyyyyy')

        parser = times(letter(), 0)
        self.assertEqual(parser.parse(''), [])
        self.assertEqual(parser.parse('x'), [])
        self.assertEqual(parser.parse('xxxxx'), [])

    def test_count(self):
        parser = count(letter(), 3)
        self.assertEqual(parser.parse('xyz'), ['x', 'y', 'z'])
        self.assertEqual(parser.parse('xyzwwwww'), ['x', 'y', 'z'])
        self.assertRaises(ParseError, parser.parse, 'xy')

    def test_optional(self):
        parser = optional(string('xx'))
        self.assertEqual(parser.parse('xx'), 'xx')
        self.assertEqual(parser.parse('xy'), None)

    def test_optional_default(self):
        parser = optional(string('xx'), 'k')
        self.assertEqual(parser.parse('xx'), 'xx')
        self.assertEqual(parser.parse('xy'), 'k')

    def test_many(self):
        parser = many(letter())
        self.assertEqual(parser.parse('x'), ['x'])
        self.assertEqual(parser.parse('xyz'), ['x', 'y', 'z'])
        self.assertEqual(parser.parse(''), [])
        self.assertEqual(parser.parse('1'), [])

    # from #28
    def test_many_many(self):
        parser = many(many(space()))
        self.assertEqual(parser.parse('    '), [[' ', ' ', ' ', ' ']])

        parser = times(spaces(), 4, 10)
        self.assertEqual(parser.parse(''), [[], [], [], []])
        self.assertEqual(parser.parse(' '), [[' '], [], [], []])
        self.assertEqual(parser.parse('  '), [[' ', ' '], [], [], []])

    def test_many1(self):
        parser = many1(letter())
        self.assertEqual(parser.parse('x'), ['x'])
        self.assertEqual(parser.parse('xyz'), ['x', 'y', 'z'])
        self.assertRaises(ParseError, parser.parse, '')
        self.assertRaises(ParseError, parser.parse, '1')

    def test_separated(self):
        parser = separated(string('x'), string(','), 2, 4)
        self.assertEqual(parser.parse('x,x,x') , ['x', 'x', 'x'])
        self.assertEqual(parser.parse('x,x,x,'), ['x', 'x', 'x'])
        self.assertRaises(ParseError, parser.parse, 'x')
        self.assertRaises(ParseError, parser.parse, 'x,')
        self.assertRaises(ParseError, parser.parse, 'x,y,y,y,y')
        self.assertRaises(ParseError, parser.parse, 'x,y,y,y,y,')
        self.assertEqual(parser.parse('x,x,y,y' ), ['x','x'])
        self.assertEqual(parser.parse('x,x,y,y,'), ['x','x'])

        parser = separated(letter(), string(','), 0)
        self.assertEqual(parser.parse('')          , [])
        self.assertEqual(parser.parse('x')         , [])
        self.assertEqual(parser.parse('x,')        , [])
        self.assertEqual(parser.parse('x,x,x,x,x') , [])
        self.assertEqual(parser.parse('x,x,x,x,x,'), [])

        # see GH-48
        parser = separated(string('a'), string(','), 3, 3, end=False)
        r, rest = parser.parse_partial('a,a,a,')
        self.assertEqual(r, ['a', 'a', 'a'])
        self.assertEqual(rest, ',')

        parser = separated(string('a'), string(','), 3, 3, end=True)
        r, rest = parser.parse_partial('a,a,a,')
        self.assertEqual(r, ['a', 'a', 'a'])
        self.assertEqual(rest, '')

        parser = separated(string('a'), string(','), 3, 3, end=None)
        r, rest = parser.parse_partial('a,a,a,')
        self.assertEqual(r, ['a', 'a', 'a'])
        self.assertEqual(rest, '')

        parser = separated(string('a'), string(','), 3, 6, end=True)
        r, rest = parser.parse_partial('a,a,a,a.')
        self.assertEqual(r, ['a', 'a', 'a'])
        self.assertEqual(rest, 'a.')

        # see GH-49
        parser = separated(string('a'), string(','), 3, 6, end=False)
        r, rest = parser.parse_partial('a,a,a,')
        self.assertEqual(r, ['a', 'a', 'a'])
        self.assertEqual(rest, ',')

    def test_sepBy(self):
        parser = sepBy(letter(), string(','))
        self.assertEqual(parser.parse_strict('x')     , ['x'])
        self.assertEqual(parser.parse       ('x,')    , ['x'])
        self.assertEqual(parser.parse_strict('x,y,z') , ['x', 'y', 'z'])
        self.assertEqual(parser.parse       ('x,y,z,'), ['x', 'y', 'z'])
        self.assertEqual(parser.parse       ('') , [])  # nothing consumed
        self.assertEqual(parser.parse       ('1'), [])  # nothing consumed
        self.assertEqual(parser.parse       ('1,'), []) # nothing consumed

    def test_sepBy1(self):
        parser = sepBy1(letter(), string(','))
        self.assertEqual(parser.parse_strict('x')     , ['x'])
        self.assertEqual(parser.parse       ('x,')    , ['x'])
        self.assertEqual(parser.parse_strict('x,y,z') , ['x', 'y', 'z'])
        self.assertEqual(parser.parse       ('x,y,z,'), ['x', 'y', 'z'])
        self.assertRaises(ParseError, parser.parse, (''))
        self.assertRaises(ParseError, parser.parse, ('1'))
        self.assertRaises(ParseError, parser.parse, ('1,'))

    def test_endBy(self):
        parser = endBy(letter(), string(','))
        self.assertEqual(parser.parse_strict('x,')    , ['x'])
        self.assertEqual(parser.parse_strict('x,y,z,'), ['x', 'y', 'z'])
        self.assertEqual(parser.parse       ('')      , [])
        self.assertEqual(parser.parse       ('1')     , [])
        self.assertEqual(parser.parse       ('1,')    , [])
        self.assertEqual(parser.parse       ('x')     , [])
        self.assertEqual(parser.parse       ('x,')    , ['x'])

    def test_endBy1(self):
        parser = endBy1(letter(), string(','))
        self.assertRaises(ParseError, parser.parse, ('x'))
        self.assertRaises(ParseError, parser.parse_strict, ('x,y,z'))
        self.assertEqual(parser.parse_strict('x,')    , ['x'])
        self.assertEqual(parser.parse_strict('x,y,z,'), ['x', 'y', 'z'])
        self.assertEqual(parser.parse('x,y,z')        , ['x', 'y'])
        self.assertRaises(ParseError, parser.parse, (''))
        self.assertRaises(ParseError, parser.parse, ('1'))
        self.assertRaises(ParseError, parser.parse, ('1,'))

    def test_sepEndBy(self):
        parser = sepEndBy(letter(), string(','))
        self.assertEqual(parser.parse_strict('x')     , ['x'])
        self.assertEqual(parser.parse_strict('x,')    , ['x'])
        self.assertEqual(parser.parse_strict('x,y,z') , ['x', 'y', 'z'])
        self.assertEqual(parser.parse_strict('x,y,z,'), ['x', 'y', 'z'])
        self.assertEqual(parser.parse       ('')      , [])
        self.assertEqual(parser.parse       ('1')     , [])
        self.assertEqual(parser.parse       ('1,')    , [])

    def test_sepEndBy1(self):
        parser = sepEndBy1(letter(), string(','))
        self.assertEqual(parser.parse_strict('x')     , ['x'])
        self.assertEqual(parser.parse_strict('x,')    , ['x'])
        self.assertEqual(parser.parse_strict('x,y,z') , ['x', 'y', 'z'])
        self.assertEqual(parser.parse_strict('x,y,z,'), ['x', 'y', 'z'])
        self.assertRaises(ParseError, parser.parse, (''))
        self.assertRaises(ParseError, parser.parse, ('1'))
        self.assertRaises(ParseError, parser.parse, ('1,'))

    def test_excepts(self):
        parser = (string('<') / string('=')) ^ string('<=')
        self.assertEqual(parser.parse('<'), "<")
        self.assertEqual(parser.parse('<='), "<=")

        with self.assertRaises(ParseError):
            parser.parse('>')

        parser = string('<') ^ string('<=')
        self.assertEqual(parser.parse('<'), "<")
        self.assertEqual(parser.parse('<='), "<")

    def test_between(self):
        parser = between(string("("), string(")"), many(none_of(")")))
        self.assertEqual(parser.parse("()"), [])
        self.assertEqual(parser.parse("(abc)"), ["a", "b", "c"])
        self.assertRaises(ParseError, parser.parse, "")
        self.assertRaises(ParseError, parser.parse, "(")
        self.assertRaises(ParseError, parser.parse, ")")
        self.assertRaises(ParseError, parser.parse, ")(")

    def test_fix(self):
        @Parser
        @fix
        def bracketed_expr(recur):
            return (string("(") >> recur << string(")")) | any()

        self.assertEqual(bracketed_expr.parse("((x))"), 'x')

    def test_validate(self):
        parser = any() >= validate(str.isalpha)
        self.assertEqual(parser.parse("a"), "a")
        self.assertRaises(ParseError, parser.parse, "1")

class ParsecCharTest(unittest.TestCase):
    '''Test the implementation of Text.Parsec.Char.'''

    def test_string(self):
        parser = string('x')
        self.assertEqual(parser.parse('x'), 'x')
        self.assertRaises(ParseError, parser.parse, 'y')

    def test_regex(self):
        parser = regex(r'[0-9]')
        self.assertEqual(parser.parse('1'), '1')
        self.assertEqual(parser.parse('4'), '4')
        self.assertRaises(ParseError, parser.parse, 'x')
        # combinator only accepts string as input
        self.assertRaises(ParseError, parser.parse, [1])

        parser = regex(re.compile(r'[0-9]'))
        self.assertEqual(parser.parse('1'), '1')

    def test_one_of(self):
        parser = one_of('abc')
        self.assertEqual(parser.parse('a'), 'a')
        self.assertEqual(parser.parse('b'), 'b')
        self.assertEqual(parser.parse('c'), 'c')
        self.assertRaises(ParseError, parser.parse, 'd')

    def test_none_of(self):
        parser = none_of('abc')
        self.assertRaises(ParseError, parser.parse, 'a')
        self.assertRaises(ParseError, parser.parse, 'b')
        self.assertRaises(ParseError, parser.parse, 'c')
        self.assertEqual(parser.parse('d'), 'd')

    def test_exclude(self):
        parser = exclude(string("test"), string("should-be-excluded"))
        self.assertEqual(parser.parse("test"), "test")
        self.assertRaises(ParseError, parser.parse, "should-be-excluded")

    def test_lookahead(self):
        parser = lookahead(string("test")) + string("test")
        self.assertEqual(parser.parse("test"), ("test", "test"))
        self.assertRaises(ParseError, parser.parse, "tes")

    def test_unit(self):
        parser = unit(string("abc")) | one_of("a")
        self.assertEqual(parser.parse("abc"), "abc")
        self.assertEqual(parser.parse("a"), "a")

class ParsecNumberTest(unittest.TestCase):
    '''Test the implementation of Text.Parsec.Number.'''

    def test_decimal(self):
        parser = decimal
        self.assertEqual(parser.parse('0'), 0)
        self.assertEqual(parser.parse('1'), 1)
        self.assertEqual(parser.parse('10'), 10)
        self.assertEqual(parser.parse('9999'), 9999)

    def test_binary(self):
        parser = binary
        self.assertEqual(parser.parse('b0'), 0b0)
        self.assertEqual(parser.parse('b1'), 0b1)
        self.assertEqual(parser.parse('B1'), 0b1)
        self.assertEqual(parser.parse('b10'), 0b10)
        self.assertEqual(parser.parse('B10'), 0b10)
        self.assertEqual(parser.parse('b1111'), 0b1111)
        self.assertEqual(parser.parse('B1111'), 0b1111)

    def test_octal(self):
        parser = octal
        self.assertEqual(parser.parse('o0'), 0o0)
        self.assertEqual(parser.parse('o1'), 0o1)
        self.assertEqual(parser.parse('O1'), 0o1)
        self.assertEqual(parser.parse('o10'), 0o10)
        self.assertEqual(parser.parse('O10'), 0o10)
        self.assertEqual(parser.parse('o7777'), 0o7777)
        self.assertEqual(parser.parse('O7777'), 0o7777)

    def test_hexadecimal(self):
        parser = hexadecimal
        self.assertEqual(parser.parse('x0'), 0x0)
        self.assertEqual(parser.parse('x1'), 0x1)
        self.assertEqual(parser.parse('X1'), 0x1)
        self.assertEqual(parser.parse('x10'), 0x10)
        self.assertEqual(parser.parse('X10'), 0x10)
        self.assertEqual(parser.parse('xffff'), 0xffff)
        self.assertEqual(parser.parse('Xffff'), 0xffff)

    def test_integer(self):
        parser = integer
        self.assertEqual(parser.parse('0'), 0)
        self.assertEqual(parser.parse('-1'), -1)
        self.assertEqual(parser.parse('+1'), 1)
        self.assertEqual(parser.parse('0b10'), 0b10)
        self.assertEqual(parser.parse('-0b10'), -0b10)
        self.assertEqual(parser.parse('+0b10'), 0b10)
        self.assertEqual(parser.parse('0o10'), 0o10)
        self.assertEqual(parser.parse('+0o10'), 0o10)
        self.assertEqual(parser.parse('-0o10'), -0o10)
        self.assertEqual(parser.parse('0x10'), 0x10)
        self.assertEqual(parser.parse('+0x10'), 0x10)
        self.assertEqual(parser.parse('-0x10'), -0x10)

class ParserGeneratorTest(unittest.TestCase):
    '''Test the implementation of Parser Generator.(generate)'''
    def test_generate_desc(self):
        description = 'expected description for fn'

        @generate(description)
        def fn():
            yield string('t')

        with self.assertRaises(ParseError) as err: fn.parse('x')

        ex = err.exception

        self.assertEqual(ex.expected, description)
        self.assertEqual(ex.text, 'x')
        self.assertEqual(ex.index, 0)

    def test_generate_backtracking(self):
        @generate
        def xy():
            yield string('x')
            yield string('y')
            assert False
        parser = xy | string('z')
        # should not finish executing xy()
        self.assertEqual(parser.parse('z'), 'z')

    def test_generate_raise(self):

        # `return` with argument inside generator is not supported in Python 2.
        # Instead, we can raise a `StopIteration` directly with the intended
        # result in generator for Python 2.
        #
        # Before Python 3.3, the `StopIteration` didn't have the `value` attribute,
        # we need to assign the attribute manually.
        #
        # See #15.

        @generate
        def xy():
            yield string('x')
            yield string('y')

            # NOTE: this will appear in the form of a RuntimeError caused by StopIteration
            r = StopIteration('success')
            r.value = 'success'  # for pre-3.3 Python
            raise r

        parser = xy
        self.assertEqual(parser.parse('xy'), 'success')

        @generate
        def yz():
            r = StopIteration()
            r.value = string("yz")
            raise r

        parser = yz
        self.assertEqual(parser.parse('yz'), 'yz')

        @generate
        def stop_iteration_without_value():
            # simulate python 2
            r = StopIteration()
            delattr(r, "value")
            raise RuntimeError from r

        parser = stop_iteration_without_value
        self.assertEqual(parser.parse("whatever"), None) 

        @generate
        def stop_iteration_with_parser_as_value():
            raise RuntimeError from StopIteration(string("yz"))

        parser = stop_iteration_with_parser_as_value
        self.assertEqual(parser.parse("yz"), "yz")

        @generate
        def runtime_error():
            r = RuntimeError
            raise r

        parser = runtime_error
        with self.assertRaises(RuntimeError):
            parser.parse("whatever")

if __name__ == '__main__':
    unittest.main()
