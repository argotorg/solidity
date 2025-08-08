#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#

from io import StringIO
import unittest
from antlr4.Token import Token

# need forward declarations
IntervalSet = None

class IntervalSet(object):

    def __init__(self):
        self.intervals = None
        self.readOnly = False

    def __iter__(self):
        if self.intervals is not None:
            for i in self.intervals:
                for c in i:
                    yield c

    def __getitem__(self, item):
        i = 0
        for k in self:
            if i==item:
                return k
            else:
                i += 1
        return Token.INVALID_TYPE

    def addOne(self, v:int):
        self.addRange(range(v, v+1))

    def addRange(self, v:range):
        if self.intervals is None:
            self.intervals = list()
            self.intervals.append(v)
        else:
            # find insert pos
            k = 0
            for i in self.intervals:
                # distinct range -> insert
                if v.stop<i.start:
                    self.intervals.insert(k, v)
                    return
                # contiguous range -> adjust
                elif v.stop==i.start:
                    self.intervals[k] = range(v.start, i.stop)
                    return
                # overlapping range -> adjust and reduce
                elif v.start<=i.stop:
                    self.intervals[k] = range(min(i.start,v.start), max(i.stop,v.stop))
                    self.reduce(k)
                    return
                k += 1
            # greater than any existing
            self.intervals.append(v)

    def addSet(self, other:IntervalSet):
        if other.intervals is not None:
            for i in other.intervals:
                self.addRange(i)
        return self

    def reduce(self, k:int):
        # only need to reduce if k is not the last
        if k<len(self.intervals)-1:
            l = self.intervals[k]
            r = self.intervals[k+1]
            # if r contained in l
            if l.stop >= r.stop:
                self.intervals.pop(k+1)
                self.reduce(k)
            elif l.stop >= r.start:
                self.intervals[k] = range(l.start, r.stop)
                self.intervals.pop(k+1)

    def complement(self, start, stop):
        result = IntervalSet()
        result.addRange(range(start,stop+1))
        for i in self.intervals:
            result.removeRange(i)
        return result

    def __contains__(self, item):
        if self.intervals is None:
            return False
        else:
            return any(item in i for i in self.intervals)

    def __len__(self):
        return sum(len(i) for i in self.intervals)

    def removeRange(self, v):
        if v.start==v.stop-1:
            self.removeOne(v.start)
        elif self.intervals is not None:
            k = 0
            for i in self.intervals:
                # intervals are ordered
                if v.stop<=i.start:
                    return
                # check for including range, split it
                elif v.start>i.start and v.stop<i.stop:
                    self.intervals[k] = range(i.start, v.start)
                    x = range(v.stop, i.stop)
                    self.intervals.insert(k, x)
                    return
                # check for included range, remove it
                elif v.start<=i.start and v.stop>=i.stop:
                    self.intervals.pop(k)
                    k -= 1  # need another pass
                # check for lower boundary
                elif v.start<i.stop:
                    self.intervals[k] = range(i.start, v.start)
                # check for upper boundary
                elif v.stop<i.stop:
                    self.intervals[k] = range(v.stop, i.stop)
                k += 1

    def removeOne(self, v):
        if self.intervals is not None:
            k = 0
            for i in self.intervals:
                # intervals is ordered
                if v<i.start:
                    return
                # check for single value range
                elif v==i.start and v==i.stop-1:
                    self.intervals.pop(k)
                    return
                # check for lower boundary
                elif v==i.start:
                    self.intervals[k] = range(i.start+1, i.stop)
                    return
                # check for upper boundary
                elif v==i.stop-1:
                    self.intervals[k] = range(i.start, i.stop-1)
                    return
                # split existing range
                elif v<i.stop-1:
                    x = range(i.start, v)
                    self.intervals[k] = range(v + 1, i.stop)
                    self.intervals.insert(k, x)
                    return
                k += 1


    def toString(self, literalNames:list, symbolicNames:list):
        if self.intervals is None:
            return "{}"
        with StringIO() as buf:
            if len(self)>1:
                buf.write("{")
            first = True
            for i in self.intervals:
                for j in i:
                    if not first:
                        buf.write(", ")
                    buf.write(self.elementName(literalNames, symbolicNames, j))
                    first = False
            if len(self)>1:
                buf.write("}")
            return buf.getvalue()

    def elementName(self, literalNames:list, symbolicNames:list, a:int):
        if a==Token.EOF:
            return "<EOF>"
        elif a==Token.EPSILON:
            return "<EPSILON>"
        else:
            if a<len(literalNames) and literalNames[a] != "<INVALID>":
                return literalNames[a]
            if a<len(symbolicNames):
                return symbolicNames[a]
            return "<UNKNOWN>"


class TestIntervalSet(unittest.TestCase):

    def testEmpty(self):
        s = IntervalSet()
        self.assertIsNone(s.intervals)
        self.assertFalse(30 in s)

    def testOne(self):
        s = IntervalSet()
        s.addOne(30)
        self.assertTrue(30 in s)
        self.assertFalse(29 in s)
        self.assertFalse(31 in s)

    def testTwo(self):
        s = IntervalSet()
        s.addOne(30)
        s.addOne(40)
        self.assertTrue(30 in s)
        self.assertTrue(40 in s)
        self.assertFalse(35 in s)

    def testRange(self):
        s = IntervalSet()
        s.addRange(range(30,41))
        self.assertTrue(30 in s)
        self.assertTrue(40 in s)
        self.assertTrue(35 in s)

    def testDistinct1(self):
        s = IntervalSet()
        s.addRange(range(30,32))
        s.addRange(range(40,42))
        self.assertEquals(2,len(s.intervals))
        self.assertTrue(30 in s)
        self.assertTrue(40 in s)
        self.assertFalse(35 in s)

    def testDistinct2(self):
        s = IntervalSet()
        s.addRange(range(40,42))
        s.addRange(range(30,32))
        self.assertEquals(2,len(s.intervals))
        self.assertTrue(30 in s)
        self.assertTrue(40 in s)
        self.assertFalse(35 in s)

    def testContiguous1(self):
        s = IntervalSet()
        s.addRange(range(30,36))
        s.addRange(range(36,41))
        self.assertEquals(1,len(s.intervals))
        self.assertTrue(30 in s)
        self.assertTrue(40 in s)
        self.assertTrue(35 in s)

    def testContiguous2(self):
        s = IntervalSet()
        s.addRange(range(36,41))
        s.addRange(range(30,36))
        self.assertEquals(1,len(s.intervals))
        self.assertTrue(30 in s)
        self.assertTrue(40 in s)

    def testOverlapping1(self):
        s = IntervalSet()
        s.addRange(range(30,40))
        s.addRange(range(35,45))
        self.assertEquals(1,len(s.intervals))
        self.assertTrue(30 in s)
        self.assertTrue(44 in s)

    def testOverlapping2(self):
        s = IntervalSet()
        s.addRange(range(35,45))
        s.addRange(range(30,40))
        self.assertEquals(1,len(s.intervals))
        self.assertTrue(30 in s)
        self.assertTrue(44 in s)

    def testOverlapping3(self):
        s = IntervalSet()
        s.addRange(range(30,32))
        s.addRange(range(40,42))
        s.addRange(range(50,52))
        s.addRange(range(20,61))
        self.assertEquals(1,len(s.intervals))
        self.assertTrue(20 in s)
        self.assertTrue(60 in s)

    def testComplement(self):
        s = IntervalSet()
        s.addRange(range(10,21))
        c = s.complement(1,100)
        self.assertTrue(1 in c)
        self.assertTrue(100 in c)
        self.assertTrue(10 not in c)
        self.assertTrue(20 not in c)


