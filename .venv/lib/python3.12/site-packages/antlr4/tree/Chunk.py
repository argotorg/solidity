#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#

class Chunk(object):
    pass

class TagChunk(Chunk):

    def __init__(self, tag:str, label:str=None):
        self.tag = tag
        self.label = label

    def __str__(self):
        if self.label is None:
            return self.tag
        else:
            return self.label + ":" + self.tag

class TextChunk(Chunk):

    def __init__(self, text:str):
        self.text = text

    def __str__(self):
        return "'" + self.text + "'"

