#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Test the return with generator syntax in @generate decorate.
'''

__author__ = 'He Tao, sighingnow@gmail.com'

import unittest

from parsec import *

class ParserGeneratorWithReturnTest(unittest.TestCase):
    '''
    Test the implementation of Parser Generator with 'return' statement.
    Since 'return' with argument inside generator is not supported in Python 2, this usage
    is Python 3 only. For Python 2 users, you can raise a exception to pass return value.
    More detailed discussion about this topic could be found at
    `https://github.com/sighingnow/parsec.py/issues/9 <https://github.com/sighingnow/parsec.py/issues/9>`_ .
    '''
    def test_generate(self):
        x, y = None, None

        @generate
        def fn():
            nonlocal x, y
            x = yield string('x')
            y = yield string('y')
            return string('z')
        self.assertEqual(fn.parse('xyz'), 'z')
        self.assertEqual(x, 'x')
        self.assertEqual(y, 'y')

        @generate
        def fn():
            nonlocal x, y
            x = yield digit()
            y = yield count(digit(), 5)
            return None
        self.assertEqual(fn.parse('123456'), None)
        self.assertEqual(x, '1')
        self.assertEqual(y, ['2', '3', '4', '5', '6'])

if __name__ == '__main__':
    unittest.main()
