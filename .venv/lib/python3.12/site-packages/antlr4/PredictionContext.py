#
# Copyright (c) 2012-2017 The ANTLR Project. All rights reserved.
# Use of this file is governed by the BSD 3-clause license that
# can be found in the LICENSE.txt file in the project root.
#/
from io import StringIO

from antlr4.error.Errors import IllegalStateException

from antlr4.RuleContext import RuleContext
from antlr4.atn.ATN import ATN
from antlr4.atn.ATNState import ATNState


class PredictionContext(object):

    # Represents {@code $} in local context prediction, which means wildcard.
    # {@code#+x =#}.
    #/
    EMPTY = None

    # Represents {@code $} in an array in full context mode, when {@code $}
    # doesn't mean wildcard: {@code $ + x = [$,x]}. Here,
    # {@code $} = {@link #EMPTY_RETURN_STATE}.
    #/
    EMPTY_RETURN_STATE = 0x7FFFFFFF

    globalNodeCount = 1
    id = globalNodeCount

    # Stores the computed hash code of this {@link PredictionContext}. The hash
    # code is computed in parts to match the following reference algorithm.
    #
    # <pre>
    #  private int referenceHashCode() {
    #      int hash = {@link MurmurHash#initialize MurmurHash.initialize}({@link #INITIAL_HASH});
    #
    #      for (int i = 0; i &lt; {@link #size()}; i++) {
    #          hash = {@link MurmurHash#update MurmurHash.update}(hash, {@link #getParent getParent}(i));
    #      }
    #
    #      for (int i = 0; i &lt; {@link #size()}; i++) {
    #          hash = {@link MurmurHash#update MurmurHash.update}(hash, {@link #getReturnState getReturnState}(i));
    #      }
    #
    #      hash = {@link MurmurHash#finish MurmurHash.finish}(hash, 2# {@link #size()});
    #      return hash;
    #  }
    # </pre>
    #/

    def __init__(self, cachedHashCode:int):
        self.cachedHashCode = cachedHashCode

    def __len__(self):
        return 0

    # This means only the {@link #EMPTY} context is in set.
    def isEmpty(self):
        return self is self.EMPTY

    def hasEmptyPath(self):
        return self.getReturnState(len(self) - 1) == self.EMPTY_RETURN_STATE

    def getReturnState(self, index:int):
        raise IllegalStateException("illegal!")

    def __hash__(self):
        return self.cachedHashCode

def calculateHashCode(parent:PredictionContext, returnState:int):
    return hash("") if parent is None else hash((hash(parent), returnState))

def calculateListsHashCode(parents:[], returnStates:[] ):
    h = 0
    for parent, returnState in zip(parents, returnStates):
        h = hash((h, calculateHashCode(parent, returnState)))
    return h

#  Used to cache {@link PredictionContext} objects. Its used for the shared
#  context cash associated with contexts in DFA states. This cache
#  can be used for both lexers and parsers.

class PredictionContextCache(object):

    def __init__(self):
        self.cache = dict()

    #  Add a context to the cache and return it. If the context already exists,
    #  return that one instead and do not add a new context to the cache.
    #  Protect shared cache from unsafe thread access.
    #
    def add(self, ctx:PredictionContext):
        if ctx==PredictionContext.EMPTY:
            return PredictionContext.EMPTY
        existing = self.cache.get(ctx, None)
        if existing is not None:
            return existing
        self.cache[ctx] = ctx
        return ctx

    def get(self, ctx:PredictionContext):
        return self.cache.get(ctx, None)

    def __len__(self):
        return len(self.cache)


class SingletonPredictionContext(PredictionContext):

    @staticmethod
    def create(parent:PredictionContext , returnState:int ):
        if returnState == PredictionContext.EMPTY_RETURN_STATE and parent is None:
            # someone can pass in the bits of an array ctx that mean $
            return SingletonPredictionContext.EMPTY
        else:
            return SingletonPredictionContext(parent, returnState)

    def __init__(self, parent:PredictionContext, returnState:int):
        hashCode = calculateHashCode(parent, returnState)
        super().__init__(hashCode)
        self.parentCtx = parent
        self.returnState = returnState

    def __len__(self):
        return 1

    def getParent(self, index:int):
        return self.parentCtx

    def getReturnState(self, index:int):
        return self.returnState

    def __eq__(self, other):
        if self is other:
            return True
        elif other is None:
            return False
        elif not isinstance(other, SingletonPredictionContext):
            return False
        else:
            return self.returnState == other.returnState and self.parentCtx == other.parentCtx

    def __hash__(self):
        return self.cachedHashCode

    def __str__(self):
        up = "" if self.parentCtx is None else str(self.parentCtx)
        if len(up)==0:
            if self.returnState == self.EMPTY_RETURN_STATE:
                return "$"
            else:
                return str(self.returnState)
        else:
            return str(self.returnState) + " " + up


class EmptyPredictionContext(SingletonPredictionContext):

    def __init__(self):
        super().__init__(None, self.EMPTY_RETURN_STATE)

    def isEmpty(self):
        return True

    def __eq__(self, other):
        return self is other

    def __hash__(self):
        return self.cachedHashCode

    def __str__(self):
        return "$"


PredictionContext.EMPTY = EmptyPredictionContext()

class ArrayPredictionContext(PredictionContext):
    # Parent can be null only if full ctx mode and we make an array
    #  from {@link #EMPTY} and non-empty. We merge {@link #EMPTY} by using null parent and
    #  returnState == {@link #EMPTY_RETURN_STATE}.

    def __init__(self, parents:list, returnStates:list):
        super().__init__(calculateListsHashCode(parents, returnStates))
        self.parents = parents
        self.returnStates = returnStates

    def isEmpty(self):
        # since EMPTY_RETURN_STATE can only appear in the last position, we
        # don't need to verify that size==1
        return self.returnStates[0]==PredictionContext.EMPTY_RETURN_STATE

    def __len__(self):
        return len(self.returnStates)

    def getParent(self, index:int):
        return self.parents[index]

    def getReturnState(self, index:int):
        return self.returnStates[index]

    def __eq__(self, other):
        if self is other:
            return True
        elif not isinstance(other, ArrayPredictionContext):
            return False
        elif hash(self) != hash(other):
            return False # can't be same if hash is different
        else:
            return self.returnStates==other.returnStates and self.parents==other.parents

    def __str__(self):
        if self.isEmpty():
            return "[]"
        with StringIO() as buf:
            buf.write("[")
            for i in range(0,len(self.returnStates)):
                if i>0:
                    buf.write(", ")
                if self.returnStates[i]==PredictionContext.EMPTY_RETURN_STATE:
                    buf.write("$")
                    continue
                buf.write(str(self.returnStates[i]))
                if self.parents[i] is not None:
                    buf.write(' ')
                    buf.write(str(self.parents[i]))
                else:
                    buf.write("null")
            buf.write("]")
            return buf.getvalue()

    def __hash__(self):
        return self.cachedHashCode



#  Convert a {@link RuleContext} tree to a {@link PredictionContext} graph.
#  Return {@link #EMPTY} if {@code outerContext} is empty or null.
#/
def PredictionContextFromRuleContext(atn:ATN, outerContext:RuleContext=None):
    if outerContext is None:
        outerContext = RuleContext.EMPTY

    # if we are in RuleContext of start rule, s, then PredictionContext
    # is EMPTY. Nobody called us. (if we are empty, return empty)
    if outerContext.parentCtx is None or outerContext is RuleContext.EMPTY:
        return PredictionContext.EMPTY

    # If we have a parent, convert it to a PredictionContext graph
    parent = PredictionContextFromRuleContext(atn, outerContext.parentCtx)
    state = atn.states[outerContext.invokingState]
    transition = state.transitions[0]
    return SingletonPredictionContext.create(parent, transition.followState.stateNumber)


def merge(a:PredictionContext, b:PredictionContext, rootIsWildcard:bool, mergeCache:dict):

    # share same graph if both same
    if a==b:
        return a

    if isinstance(a, SingletonPredictionContext) and isinstance(b, SingletonPredictionContext):
        return mergeSingletons(a, b, rootIsWildcard, mergeCache)

    # At least one of a or b is array
    # If one is $ and rootIsWildcard, return $ as# wildcard
    if rootIsWildcard:
        if isinstance( a, EmptyPredictionContext ):
            return a
        if isinstance( b, EmptyPredictionContext ):
            return b

    # convert singleton so both are arrays to normalize
    if isinstance( a, SingletonPredictionContext ):
        a = ArrayPredictionContext([a.parentCtx], [a.returnState])
    if isinstance( b, SingletonPredictionContext):
        b = ArrayPredictionContext([b.parentCtx], [b.returnState])
    return mergeArrays(a, b, rootIsWildcard, mergeCache)


#
# Merge two {@link SingletonPredictionContext} instances.
#
# <p>Stack tops equal, parents merge is same; return left graph.<br>
# <embed src="images/SingletonMerge_SameRootSamePar.svg" type="image/svg+xml"/></p>
#
# <p>Same stack top, parents differ; merge parents giving array node, then
# remainders of those graphs. A new root node is created to point to the
# merged parents.<br>
# <embed src="images/SingletonMerge_SameRootDiffPar.svg" type="image/svg+xml"/></p>
#
# <p>Different stack tops pointing to same parent. Make array node for the
# root where both element in the root point to the same (original)
# parent.<br>
# <embed src="images/SingletonMerge_DiffRootSamePar.svg" type="image/svg+xml"/></p>
#
# <p>Different stack tops pointing to different parents. Make array node for
# the root where each element points to the corresponding original
# parent.<br>
# <embed src="images/SingletonMerge_DiffRootDiffPar.svg" type="image/svg+xml"/></p>
#
# @param a the first {@link SingletonPredictionContext}
# @param b the second {@link SingletonPredictionContext}
# @param rootIsWildcard {@code true} if this is a local-context merge,
# otherwise false to indicate a full-context merge
# @param mergeCache
#/
def mergeSingletons(a:SingletonPredictionContext, b:SingletonPredictionContext, rootIsWildcard:bool, mergeCache:dict):
    if mergeCache is not None:
        previous = mergeCache.get((a,b), None)
        if previous is not None:
            return previous
        previous = mergeCache.get((b,a), None)
        if previous is not None:
            return previous

    merged = mergeRoot(a, b, rootIsWildcard)
    if merged is not None:
        if mergeCache is not None:
            mergeCache[(a, b)] = merged
        return merged

    if a.returnState==b.returnState:
        parent = merge(a.parentCtx, b.parentCtx, rootIsWildcard, mergeCache)
        # if parent is same as existing a or b parent or reduced to a parent, return it
        if parent == a.parentCtx:
            return a # ax + bx = ax, if a=b
        if parent == b.parentCtx:
            return b # ax + bx = bx, if a=b
        # else: ax + ay = a'[x,y]
        # merge parents x and y, giving array node with x,y then remainders
        # of those graphs.  dup a, a' points at merged array
        # new joined parent so create new singleton pointing to it, a'
        merged = SingletonPredictionContext.create(parent, a.returnState)
        if mergeCache is not None:
            mergeCache[(a, b)] = merged
        return merged
    else: # a != b payloads differ
        # see if we can collapse parents due to $+x parents if local ctx
        singleParent = None
        if a is b or (a.parentCtx is not None and a.parentCtx==b.parentCtx): # ax + bx = [a,b]x
            singleParent = a.parentCtx
        if singleParent is not None:	# parents are same
            # sort payloads and use same parent
            payloads = [ a.returnState, b.returnState ]
            if a.returnState > b.returnState:
                payloads = [ b.returnState, a.returnState ]
            parents = [singleParent, singleParent]
            merged = ArrayPredictionContext(parents, payloads)
            if mergeCache is not None:
                mergeCache[(a, b)] = merged
            return merged
        # parents differ and can't merge them. Just pack together
        # into array; can't merge.
        # ax + by = [ax,by]
        payloads = [ a.returnState, b.returnState ]
        parents = [ a.parentCtx, b.parentCtx ]
        if a.returnState > b.returnState: # sort by payload
            payloads = [ b.returnState, a.returnState ]
            parents = [ b.parentCtx, a.parentCtx ]
        merged = ArrayPredictionContext(parents, payloads)
        if mergeCache is not None:
            mergeCache[(a, b)] = merged
        return merged


#
# Handle case where at least one of {@code a} or {@code b} is
# {@link #EMPTY}. In the following diagrams, the symbol {@code $} is used
# to represent {@link #EMPTY}.
#
# <h2>Local-Context Merges</h2>
#
# <p>These local-context merge operations are used when {@code rootIsWildcard}
# is true.</p>
#
# <p>{@link #EMPTY} is superset of any graph; return {@link #EMPTY}.<br>
# <embed src="images/LocalMerge_EmptyRoot.svg" type="image/svg+xml"/></p>
#
# <p>{@link #EMPTY} and anything is {@code #EMPTY}, so merged parent is
# {@code #EMPTY}; return left graph.<br>
# <embed src="images/LocalMerge_EmptyParent.svg" type="image/svg+xml"/></p>
#
# <p>Special case of last merge if local context.<br>
# <embed src="images/LocalMerge_DiffRoots.svg" type="image/svg+xml"/></p>
#
# <h2>Full-Context Merges</h2>
#
# <p>These full-context merge operations are used when {@code rootIsWildcard}
# is false.</p>
#
# <p><embed src="images/FullMerge_EmptyRoots.svg" type="image/svg+xml"/></p>
#
# <p>Must keep all contexts; {@link #EMPTY} in array is a special value (and
# null parent).<br>
# <embed src="images/FullMerge_EmptyRoot.svg" type="image/svg+xml"/></p>
#
# <p><embed src="images/FullMerge_SameRoot.svg" type="image/svg+xml"/></p>
#
# @param a the first {@link SingletonPredictionContext}
# @param b the second {@link SingletonPredictionContext}
# @param rootIsWildcard {@code true} if this is a local-context merge,
# otherwise false to indicate a full-context merge
#/
def mergeRoot(a:SingletonPredictionContext, b:SingletonPredictionContext, rootIsWildcard:bool):
    if rootIsWildcard:
        if a == PredictionContext.EMPTY:
            return PredictionContext.EMPTY  ## + b =#
        if b == PredictionContext.EMPTY:
            return PredictionContext.EMPTY  # a +# =#
    else:
        if a == PredictionContext.EMPTY and b == PredictionContext.EMPTY:
            return PredictionContext.EMPTY # $ + $ = $
        elif a == PredictionContext.EMPTY: # $ + x = [$,x]
            payloads = [ b.returnState, PredictionContext.EMPTY_RETURN_STATE ]
            parents = [ b.parentCtx, None ]
            return ArrayPredictionContext(parents, payloads)
        elif b == PredictionContext.EMPTY: # x + $ = [$,x] ($ is always first if present)
            payloads = [ a.returnState, PredictionContext.EMPTY_RETURN_STATE ]
            parents = [ a.parentCtx, None ]
            return ArrayPredictionContext(parents, payloads)
    return None


#
# Merge two {@link ArrayPredictionContext} instances.
#
# <p>Different tops, different parents.<br>
# <embed src="images/ArrayMerge_DiffTopDiffPar.svg" type="image/svg+xml"/></p>
#
# <p>Shared top, same parents.<br>
# <embed src="images/ArrayMerge_ShareTopSamePar.svg" type="image/svg+xml"/></p>
#
# <p>Shared top, different parents.<br>
# <embed src="images/ArrayMerge_ShareTopDiffPar.svg" type="image/svg+xml"/></p>
#
# <p>Shared top, all shared parents.<br>
# <embed src="images/ArrayMerge_ShareTopSharePar.svg" type="image/svg+xml"/></p>
#
# <p>Equal tops, merge parents and reduce top to
# {@link SingletonPredictionContext}.<br>
# <embed src="images/ArrayMerge_EqualTop.svg" type="image/svg+xml"/></p>
#/
def mergeArrays(a:ArrayPredictionContext, b:ArrayPredictionContext, rootIsWildcard:bool, mergeCache:dict):
    if mergeCache is not None:
        previous = mergeCache.get((a,b), None)
        if previous is not None:
            return previous
        previous = mergeCache.get((b,a), None)
        if previous is not None:
            return previous

    # merge sorted payloads a + b => M
    i = 0 # walks a
    j = 0 # walks b
    k = 0 # walks target M array

    mergedReturnStates = [None] * (len(a.returnStates) + len( b.returnStates))
    mergedParents = [None] * len(mergedReturnStates)
    # walk and merge to yield mergedParents, mergedReturnStates
    while i<len(a.returnStates) and j<len(b.returnStates):
        a_parent = a.parents[i]
        b_parent = b.parents[j]
        if a.returnStates[i]==b.returnStates[j]:
            # same payload (stack tops are equal), must yield merged singleton
            payload = a.returnStates[i]
            # $+$ = $
            bothDollars = payload == PredictionContext.EMPTY_RETURN_STATE and \
                            a_parent is None and b_parent is None
            ax_ax = (a_parent is not None and b_parent is not None) and a_parent==b_parent # ax+ax -> ax
            if bothDollars or ax_ax:
                mergedParents[k] = a_parent # choose left
                mergedReturnStates[k] = payload
            else: # ax+ay -> a'[x,y]
                mergedParent = merge(a_parent, b_parent, rootIsWildcard, mergeCache)
                mergedParents[k] = mergedParent
                mergedReturnStates[k] = payload
            i += 1 # hop over left one as usual
            j += 1 # but also skip one in right side since we merge
        elif a.returnStates[i]<b.returnStates[j]: # copy a[i] to M
            mergedParents[k] = a_parent
            mergedReturnStates[k] = a.returnStates[i]
            i += 1
        else: # b > a, copy b[j] to M
            mergedParents[k] = b_parent
            mergedReturnStates[k] = b.returnStates[j]
            j += 1
        k += 1

    # copy over any payloads remaining in either array
    if i < len(a.returnStates):
        for p in range(i, len(a.returnStates)):
            mergedParents[k] = a.parents[p]
            mergedReturnStates[k] = a.returnStates[p]
            k += 1
    else:
        for p in range(j, len(b.returnStates)):
            mergedParents[k] = b.parents[p]
            mergedReturnStates[k] = b.returnStates[p]
            k += 1

    # trim merged if we combined a few that had same stack tops
    if k < len(mergedParents): # write index < last position; trim
        if k == 1: # for just one merged element, return singleton top
            merged = SingletonPredictionContext.create(mergedParents[0], mergedReturnStates[0])
            if mergeCache is not None:
                mergeCache[(a,b)] = merged
            return merged
        mergedParents = mergedParents[0:k]
        mergedReturnStates = mergedReturnStates[0:k]

    merged = ArrayPredictionContext(mergedParents, mergedReturnStates)

    # if we created same array as a or b, return that instead
    # TODO: track whether this is possible above during merge sort for speed
    if merged==a:
        if mergeCache is not None:
            mergeCache[(a,b)] = a
        return a
    if merged==b:
        if mergeCache is not None:
            mergeCache[(a,b)] = b
        return b
    combineCommonParents(mergedParents)

    if mergeCache is not None:
        mergeCache[(a,b)] = merged
    return merged


#
# Make pass over all <em>M</em> {@code parents}; merge any {@code equals()}
# ones.
#/
def combineCommonParents(parents:list):
    uniqueParents = dict()

    for p in range(0, len(parents)):
        parent = parents[p]
        if uniqueParents.get(parent, None) is None:
            uniqueParents[parent] = parent

    for p in range(0, len(parents)):
        parents[p] = uniqueParents[parents[p]]

def getCachedPredictionContext(context:PredictionContext, contextCache:PredictionContextCache, visited:dict):
    if context.isEmpty():
        return context
    existing = visited.get(context)
    if existing is not None:
        return existing
    existing = contextCache.get(context)
    if existing is not None:
        visited[context] = existing
        return existing
    changed = False
    parents = [None] * len(context)
    for i in range(0, len(parents)):
        parent = getCachedPredictionContext(context.getParent(i), contextCache, visited)
        if changed or parent is not context.getParent(i):
            if not changed:
                parents = [context.getParent(j) for j in range(len(context))]
                changed = True
            parents[i] = parent
    if not changed:
        contextCache.add(context)
        visited[context] = context
        return context

    updated = None
    if len(parents) == 0:
        updated = PredictionContext.EMPTY
    elif len(parents) == 1:
        updated = SingletonPredictionContext.create(parents[0], context.getReturnState(0))
    else:
        updated = ArrayPredictionContext(parents, context.returnStates)

    contextCache.add(updated)
    visited[updated] = updated
    visited[context] = updated

    return updated


#	# extra structures, but cut/paste/morphed works, so leave it.
#	# seems to do a breadth-first walk
#	public static List<PredictionContext> getAllNodes(PredictionContext context) {
#		Map<PredictionContext, PredictionContext> visited =
#			new IdentityHashMap<PredictionContext, PredictionContext>();
#		Deque<PredictionContext> workList = new ArrayDeque<PredictionContext>();
#		workList.add(context);
#		visited.put(context, context);
#		List<PredictionContext> nodes = new ArrayList<PredictionContext>();
#		while (!workList.isEmpty()) {
#			PredictionContext current = workList.pop();
#			nodes.add(current);
#			for (int i = 0; i < current.size(); i++) {
#				PredictionContext parent = current.getParent(i);
#				if ( parent!=null && visited.put(parent, parent) == null) {
#					workList.push(parent);
#				}
#			}
#		}
#		return nodes;
#	}

# ter's recursive version of Sam's getAllNodes()
def getAllContextNodes(context:PredictionContext, nodes:list=None, visited:dict=None):
    if nodes is None:
        nodes = list()
        return getAllContextNodes(context, nodes, visited)
    elif visited is None:
        visited = dict()
        return getAllContextNodes(context, nodes, visited)
    else:
        if context is None or visited.get(context, None) is not None:
            return nodes
        visited.put(context, context)
        nodes.add(context)
        for i in range(0, len(context)):
            getAllContextNodes(context.getParent(i), nodes, visited)
        return nodes

