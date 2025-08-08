#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import generators

'''
Test the basic functions of parsec.py.
'''

__author__ = 'He Tao, sighingnow@gmail.com'

import enum
import unittest

from parsec import *

class ParsecGenericTest(unittest.TestCase):
    '''Test the implementation of Text.Parsec. (The final test for all apis)'''
    def test_times_with_then(self):
        parser = times(letter(), 3) >> digit()
        self.assertEqual(parser.parse(['x', 'y', 'z', '1']), '1')
        self.assertRaises(ParseError, parser.parse, ['x', 'y', '1'])
        self.assertRaises(ParseError, parser.parse, ['x', 'y', 'z'])
        self.assertRaises(ParseError, parser.parse, ['x', 'y', 'z', 'w'])

    def test_many_with_then(self):
        parser = many(string('x')) >> string('y')
        self.assertEqual(parser.parse(['y']), 'y')
        self.assertEqual(parser.parse(['x', 'y']), 'y')
        self.assertEqual(parser.parse(['x', 'x', 'x', 'x', 'x', 'y']), 'y')

    def test_times_with_min_and_max(self):
        parser = times(letter(), 2, 4)
        self.assertEqual(parser.parse(['x', 'y']), ['x', 'y'])
        self.assertEqual(parser.parse(['x', 'y', 'z']), ['x', 'y', 'z'])
        self.assertEqual(parser.parse(['x', 'y', 'z', 'w']), ['x', 'y', 'z', 'w'])
        self.assertEqual(parser.parse(['x', 'y', 'z', 'w', 'v']), ['x', 'y', 'z', 'w'])
        self.assertRaises(ParseError, parser.parse, 'x')

    def test_times_with_min_and_max_and_then(self):
        parser = times(letter(), 2, 4) >> digit()
        self.assertEqual(parser.parse(['x', 'y', '1']), '1')
        self.assertEqual(parser.parse(['x', 'y', 'z', '1']), '1')
        self.assertEqual(parser.parse(['x', 'y', 'z', 'w', '1']), '1')
        self.assertRaises(ParseError, parser.parse, ['x', 'y'])
        self.assertRaises(ParseError, parser.parse, ['x', 'y', 'z', 'w'])
        self.assertRaises(ParseError, parser.parse, ['x', 'y', 'z', 'w', 'v', '1'])
        self.assertRaises(ParseError, parser.parse, ['x', '1'])


class Token(enum.Enum):
    TU = 10
    TV = 21
    TW = 22
    TX = 23
    TY = 24
    TZ = 25

    T0 = 100
    T1 = 101
    T2 = 102


u = Token.TU
v = Token.TV
w = Token.TW
x = Token.TX
y = Token.TY
z = Token.TZ

n0 = Token.T0
n1 = Token.T1
n2 = Token.T2


def xletter():
    @Parser
    def letter_parser(text, index=0):
        if index < len(text) and text[index] in [u, v, w, x, y, z]:
            return Value.success(index + 1, text[index])
        else:
            return Value.failure(index, 'a xletter')
    return letter_parser


def xdigit():
    @Parser
    def digit_parser(text, index=0):
        if index < len(text) and text[index] in [n0, n1, n2]:
            return Value.success(index + 1, text[index])
        else:
            return Value.failure(index, 'a xdigit')
    return digit_parser


def xstring(s):
    @Parser
    def string_parser(text, index=0):
        slen, tlen = len(s), len(text)
        if text[index:index + slen] == s:
            return Value.success(index + slen, s)
        else:
            matched = 0
            while matched < slen and index + matched < tlen and text[index + matched] == s[matched]:
                matched = matched + 1
            return Value.failure(index + matched, s)
    return string_parser


class ParsecGenericTokenTest(unittest.TestCase):
    '''Test the implementation of Text.Parsec. (The final test for all apis)'''
    def test_times_with_then(self):
        parser = times(xletter(), 3) >> xdigit()
        self.assertEqual(parser.parse([x, y, z, n1]), n1)
        self.assertRaises(ParseError, parser.parse, [x, y, n1])
        self.assertRaises(ParseError, parser.parse, [x, y, z])
        self.assertRaises(ParseError, parser.parse, [x, y, z, w])

    def test_many_with_then(self):
        parser = many(xstring([x])) >> xstring([y])
        self.assertEqual(parser.parse([y]), [y])
        self.assertEqual(parser.parse([x, y]), [y])
        self.assertEqual(parser.parse([x, x, x, x, x, y]), [y])

    def test_times_with_min_and_max(self):
        parser = times(xletter(), 2, 4)
        self.assertEqual(parser.parse([x, y]), [x, y])
        self.assertEqual(parser.parse([x, y, z]), [x, y, z])
        self.assertEqual(parser.parse([x, y, z, w]), [x, y, z, w])
        self.assertEqual(parser.parse([x, y, z, w, v]), [x, y, z, w])
        self.assertRaises(ParseError, parser.parse, [x])

    def test_times_with_min_and_max_and_then(self):
        parser = times(xletter(), 2, 4) >> xdigit()
        self.assertEqual(parser.parse([x, y, n1]), n1)
        self.assertEqual(parser.parse([x, y, z, n1]), n1)
        self.assertEqual(parser.parse([x, y, z, w, n1]), n1)
        self.assertRaises(ParseError, parser.parse, [x, y])
        self.assertRaises(ParseError, parser.parse, [x, y, z, w])
        self.assertRaises(ParseError, parser.parse, [x, y, z, w, v, n1])
        self.assertRaises(ParseError, parser.parse, [x, n1])


if __name__ == '__main__':
    unittest.main()
