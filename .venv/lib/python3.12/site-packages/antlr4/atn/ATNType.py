# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#/

from enum import IntEnum

# Represents the type of recognizer an ATN applies to.

class ATNType(IntEnum):

    LEXER = 0
    PARSER = 1

    @classmethod
    def fromOrdinal(cls, i:int):
        return cls._value2member_map_[i]
