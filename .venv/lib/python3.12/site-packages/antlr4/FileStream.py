#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#

#
#  This is an InputStream that is loaded from a file all at once
#  when you construct the object.
#

import codecs
import unittest
from antlr4.InputStream import InputStream


class FileStream(InputStream):

    def __init__(self, fileName:str, encoding:str='ascii', errors:str='strict'):
        super().__init__(self.readDataFrom(fileName, encoding, errors))
        self.fileName = fileName

    def readDataFrom(self, fileName:str, encoding:str, errors:str='strict'):
        # read binary to avoid line ending conversion
        with open(fileName, 'rb') as file:
            bytes = file.read()
            return codecs.decode(bytes, encoding, errors)


class TestFileStream(unittest.TestCase):

    def testStream(self):
        stream = FileStream(__file__)
        self.assertTrue(stream.size>0)
