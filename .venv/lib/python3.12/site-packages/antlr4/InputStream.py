#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#
import unittest


#
#  Vacuum all input from a string and then treat it like a buffer.
#
from antlr4.Token import Token


class InputStream (object):

    def __init__(self, data: str):
        self.name = "<empty>"
        self.strdata = data
        self._loadString()

    def _loadString(self):
        self._index = 0
        self.data = [ord(c) for c in self.strdata]
        self._size = len(self.data)

    @property
    def index(self):
        return self._index

    @property
    def size(self):
        return self._size

    # Reset the stream so that it's in the same state it was
    #  when the object was created *except* the data array is not
    #  touched.
    #
    def reset(self):
        self._index = 0

    def consume(self):
        if self._index >= self._size:
            assert self.LA(1) == Token.EOF
            raise Exception("cannot consume EOF")
        self._index += 1

    def LA(self, offset: int):
        if offset==0:
            return 0 # undefined
        if offset<0:
            offset += 1 # e.g., translate LA(-1) to use offset=0
        pos = self._index + offset - 1
        if pos < 0 or pos >= self._size: # invalid
            return Token.EOF
        return self.data[pos]

    def LT(self, offset: int):
        return self.LA(offset)

    # mark/release do nothing; we have entire buffer
    def mark(self):
        return -1

    def release(self, marker: int):
        pass

    # consume() ahead until p==_index; can't just set p=_index as we must
    # update line and column. If we seek backwards, just set p
    #
    def seek(self, _index: int):
        if _index<=self._index:
            self._index = _index # just jump; don't update stream state (line, ...)
            return
        # seek forward
        self._index = min(_index, self._size)

    def getText(self, start :int, stop: int):
        if stop >= self._size:
            stop = self._size-1
        if start >= self._size:
            return ""
        else:
            return self.strdata[start:stop+1]

    def __str__(self):
        return self.strdata


class TestInputStream(unittest.TestCase):

    def testStream(self):
        stream = InputStream("abcde")
        self.assertEqual(0, stream.index)
        self.assertEqual(5, stream.size)
        self.assertEqual(ord("a"), stream.LA(1))
        stream.consume()
        self.assertEqual(1, stream.index)
        stream.seek(5)
        self.assertEqual(Token.EOF, stream.LA(1))
        self.assertEqual("bcd", stream.getText(1, 3))
        stream.reset()
        self.assertEqual(0, stream.index)

