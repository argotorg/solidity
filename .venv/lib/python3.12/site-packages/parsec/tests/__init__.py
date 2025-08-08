#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Used as test cases loader to load all unit tests under the examples directory for parsec.py.
'''

__author__ = 'He Tao, sighingnow@gmail.com'

import sys
import unittest

def additional_tests():
    suite = unittest.TestSuite()
    '''Accumulate all unit test cases.'''
    loader = unittest.defaultTestLoader
    ## some test cases use the syntax that Python 2 doesn't support.
    additional_names = []
    if sys.version_info[0] >= 3 and sys.version_info[1] >= 3:
        additional_names.append('examples')
        from parsec.tests.python_3_only.test_generator import ParserGeneratorWithReturnTest
        suite.addTest(loader.loadTestsFromTestCase(ParserGeneratorWithReturnTest))
    for name in additional_names:
        suite.addTests(loader.discover(name))
    return suite
