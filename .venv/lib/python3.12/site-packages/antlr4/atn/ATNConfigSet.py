#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.

#
# Specialized {@link Set}{@code <}{@link ATNConfig}{@code >} that can track
# info about the set, with support for combining similar configurations using a
# graph-structured stack.
#/
from io import StringIO
from functools import reduce
from antlr4.PredictionContext import PredictionContext, merge
from antlr4.Utils import str_list
from antlr4.atn.ATN import ATN
from antlr4.atn.ATNConfig import ATNConfig
from antlr4.atn.SemanticContext import SemanticContext
from antlr4.error.Errors import UnsupportedOperationException, IllegalStateException

ATNSimulator = None

class ATNConfigSet(object):
    #
    # The reason that we need this is because we don't want the hash map to use
    # the standard hash code and equals. We need all configurations with the same
    # {@code (s,i,_,semctx)} to be equal. Unfortunately, this key effectively doubles
    # the number of objects associated with ATNConfigs. The other solution is to
    # use a hash table that lets us specify the equals/hashcode operation.

    def __init__(self, fullCtx:bool=True):
        # All configs but hashed by (s, i, _, pi) not including context. Wiped out
        # when we go readonly as this set becomes a DFA state.
        self.configLookup = dict()
        # Indicates that this configuration set is part of a full context
        #  LL prediction. It will be used to determine how to merge $. With SLL
        #  it's a wildcard whereas it is not for LL context merge.
        self.fullCtx = fullCtx
        # Indicates that the set of configurations is read-only. Do not
        #  allow any code to manipulate the set; DFA states will point at
        #  the sets and they must not change. This does not protect the other
        #  fields; in particular, conflictingAlts is set after
        #  we've made this readonly.
        self.readonly = False
        # Track the elements as they are added to the set; supports get(i)#/
        self.configs = []

        # TODO: these fields make me pretty uncomfortable but nice to pack up info together, saves recomputation
        # TODO: can we track conflicts as they are added to save scanning configs later?
        self.uniqueAlt = 0
        self.conflictingAlts = None

        # Used in parser and lexer. In lexer, it indicates we hit a pred
        # while computing a closure operation.  Don't make a DFA state from this.
        self.hasSemanticContext = False
        self.dipsIntoOuterContext = False

        self.cachedHashCode = -1

    def __iter__(self):
        return self.configs.__iter__()

    # Adding a new config means merging contexts with existing configs for
    # {@code (s, i, pi, _)}, where {@code s} is the
    # {@link ATNConfig#state}, {@code i} is the {@link ATNConfig#alt}, and
    # {@code pi} is the {@link ATNConfig#semanticContext}. We use
    # {@code (s,i,pi)} as key.
    #
    # <p>This method updates {@link #dipsIntoOuterContext} and
    # {@link #hasSemanticContext} when necessary.</p>
    #/
    def add(self, config:ATNConfig, mergeCache=None):
        if self.readonly:
            raise Exception("This set is readonly")
        if config.semanticContext is not SemanticContext.NONE:
            self.hasSemanticContext = True
        if config.reachesIntoOuterContext > 0:
            self.dipsIntoOuterContext = True
        existing = self.getOrAdd(config)
        if existing is config:
            self.cachedHashCode = -1
            self.configs.append(config)  # track order here
            return True
        # a previous (s,i,pi,_), merge with it and save result
        rootIsWildcard = not self.fullCtx
        merged = merge(existing.context, config.context, rootIsWildcard, mergeCache)
        # no need to check for existing.context, config.context in cache
        # since only way to create new graphs is "call rule" and here.
        # We cache at both places.
        existing.reachesIntoOuterContext = max(existing.reachesIntoOuterContext, config.reachesIntoOuterContext)
        # make sure to preserve the precedence filter suppression during the merge
        if config.precedenceFilterSuppressed:
            existing.precedenceFilterSuppressed = True
        existing.context = merged # replace context; no need to alt mapping
        return True

    def getOrAdd(self, config:ATNConfig):
        h = config.hashCodeForConfigSet()
        l = self.configLookup.get(h, None)
        if l is not None:
            r = next((cfg for cfg in l if config.equalsForConfigSet(cfg)), None)
            if r is not None:
                return r
        if l is None:
            l = [config]
            self.configLookup[h] = l
        else:
            l.append(config)
        return config

    def getStates(self):
        return set(c.state for c in self.configs)

    def getPredicates(self):
        return list(cfg.semanticContext for cfg in self.configs if cfg.semanticContext!=SemanticContext.NONE)

    def get(self, i:int):
        return self.configs[i]

    def optimizeConfigs(self, interpreter:ATNSimulator):
        if self.readonly:
            raise IllegalStateException("This set is readonly")
        if len(self.configs)==0:
            return
        for config in self.configs:
            config.context = interpreter.getCachedContext(config.context)

    def addAll(self, coll:list):
        for c in coll:
            self.add(c)
        return False

    def __eq__(self, other):
        if self is other:
            return True
        elif not isinstance(other, ATNConfigSet):
            return False

        same = self.configs is not None and \
            self.configs==other.configs and \
            self.fullCtx == other.fullCtx and \
            self.uniqueAlt == other.uniqueAlt and \
            self.conflictingAlts == other.conflictingAlts and \
            self.hasSemanticContext == other.hasSemanticContext and \
            self.dipsIntoOuterContext == other.dipsIntoOuterContext

        return same

    def __hash__(self):
        if self.readonly:
            if self.cachedHashCode == -1:
                self.cachedHashCode = self.hashConfigs()
            return self.cachedHashCode
        return self.hashConfigs()

    def hashConfigs(self):
        return reduce(lambda h, cfg: hash((h, cfg)), self.configs, 0)

    def __len__(self):
        return len(self.configs)

    def isEmpty(self):
        return len(self.configs)==0

    def __contains__(self, config):
        if self.configLookup is None:
            raise UnsupportedOperationException("This method is not implemented for readonly sets.")
        h = config.hashCodeForConfigSet()
        l = self.configLookup.get(h, None)
        if l is not None:
            for c in l:
                if config.equalsForConfigSet(c):
                    return True
        return False

    def clear(self):
        if self.readonly:
            raise IllegalStateException("This set is readonly")
        self.configs.clear()
        self.cachedHashCode = -1
        self.configLookup.clear()

    def setReadonly(self, readonly:bool):
        self.readonly = readonly
        self.configLookup = None # can't mod, no need for lookup cache

    def __str__(self):
        with StringIO() as buf:
            buf.write(str_list(self.configs))
            if self.hasSemanticContext:
                buf.write(",hasSemanticContext=")
                buf.write(str(self.hasSemanticContext))
            if self.uniqueAlt!=ATN.INVALID_ALT_NUMBER:
                buf.write(",uniqueAlt=")
                buf.write(str(self.uniqueAlt))
            if self.conflictingAlts is not None:
                buf.write(",conflictingAlts=")
                buf.write(str(self.conflictingAlts))
            if self.dipsIntoOuterContext:
                buf.write(",dipsIntoOuterContext")
            return buf.getvalue()


class OrderedATNConfigSet(ATNConfigSet):

    def __init__(self):
        super().__init__()



