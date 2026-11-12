// This file is part of solidity.
//
// solidity is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// solidity is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with solidity.  If not, see <http://www.gnu.org/licenses/>.
// SPDX-License-Identifier: GPL-3.0

//! The stack shuffler of the SSA CFG code transform, in a form that an assembly-level proof can work with.
//!
//! This is `Shuffler.cpp` as restated for the Kraken proofs of https://github.com/argotorg/shuffler.lean
//! (`kraken/c/shuffler/stack/Shuffler.cpp` there), function by function, with its checks in its order. The
//! build compiles this file to assembly text and links the object assembled from that text into libyul.
//!
//! - All memory is the caller's: the inputs, the spill bytes and one `Workspace`. Nothing is allocated, no
//!   frame holds an array, and no function outside of this file is called.
//! - Nothing is thrown and nothing panics: a failed assertion is the error `AssertionFailed`, and an error is
//!   a value that a function returns (`try` returns it to the caller's caller).
//! - Each function that the proofs treat as a unit is `noinline`, and all other functions are `inline`. Thus
//!   the functions of the assembly are the units and the three functions for C++: `shuffle`, `workspaceSize`
//!   and `workspaceAlignment`. Only these three have the C calling convention and a symbol; how a unit is
//!   called is up to the compiler.
//!
//! The differences from `kraken/c/shuffler/stack/Shuffler.cpp`:
//!
//! - A failed assertion is an error, which `shuffle` returns as a status, instead of a call of `exit(1)`.
//! - The reach of a swap is an input (`Shuffle.reachable_stack_depth`), not the constant 16.
//! - The local arrays of the units are in the `Workspace`.
//! - `Planner.resolve` fails with Blocked for `Resolution::Stuck`.
//! - `Stack` asserts the capacity of the working stack and of the trace.
//! - `shuffle` is `Shuffle::run` of `Shuffler.cpp`, which that file leaves out.

const std = @import("std");
const builtin = @import("builtin");

/// In a build with safety checks, a failed check traps
pub const panic = std.debug.no_panic;

comptime {
    // `StackSlot.eql` needs the members in the low 6 bytes of the word
    std.debug.assert(builtin.cpu.arch.endian() == .little);
}

/// The EVM stack limit
pub const max_stack_size = 1024;
/// The capacity of a trace. An emission for a source of m and a target of n slots records at most
/// 6 n + 4 m operations (the trace bound of the Lean model), and m, n <= max_stack_size.
pub const max_trace_size = (6 + 4) * max_stack_size;

const AssertionError = error{
    /// `yulAssert` of the C++ failed
    AssertionFailed,
};

/// What a step of the shuffle fails with
const Error = AssertionError || error{
    /// A slot is out of reach. For `Planner.resolve`, `Planner.run` and `Shuffle.run`: nothing is left to drop.
    Blocked,
};

/// `yulAssert` of the C++: a failed assertion is an error of the caller, not a panic
inline fn assert(ok: bool) AssertionError!void {
    if (!ok) return error.AssertionFailed;
}

/// What `shuffle` returns to C++
pub const Status = enum(u32) { done = 0, blocked = 1, assertion_failed = 2 };

/// `StackSlot` of `StackSlot.h`, as one word
pub const StackSlot = packed struct(u64) {
    /// interpretation depends on the kind
    payload: u32,
    kind: Kind,
    /// for a value: the opcode of the defining instruction (`InstOpcode`)
    value_opcode: u8,
    /// the padding of the C++ type, which C++ does not initialize
    _padding: u16 = 0,

    pub const Kind = enum(u8) { value = 0, junk = 1, function_call_return_label = 2, function_return_label = 3 };

    /// `InstOpcode::Const`
    pub const opcode_const = 0;
    /// `InstOpcode::Unreachable`
    pub const opcode_unreachable = 5;

    pub const junk: StackSlot = .{ .payload = 0, .kind = .junk, .value_opcode = opcode_unreachable };

    /// The members as one word, to compare them with one compare in place of three. The shift drops the padding.
    inline fn eql(a: StackSlot, b: StackSlot) bool {
        return (@as(u64, @bitCast(a)) ^ @as(u64, @bitCast(b))) << 16 == 0;
    }

    inline fn isValue(self: StackSlot) bool {
        return self.kind == .value;
    }
    inline fn isLiteralValue(self: StackSlot) bool {
        return self.value_opcode == opcode_const;
    }
    /// A value that is not a literal. Only a variable can be spilled.
    inline fn isVariable(self: StackSlot) bool {
        return self.isValue() and !self.isLiteralValue();
    }
    inline fn isJunk(self: StackSlot) bool {
        return self.kind == .junk;
    }
    inline fn isFunctionCallReturnLabel(self: StackSlot) bool {
        return self.kind == .function_call_return_label;
    }
    inline fn isFunctionReturnLabel(self: StackSlot) bool {
        return self.kind == .function_return_label;
    }
    /// Whether the slot can be materialized on the stack top out of thin air, without a copy of it on the stack
    inline fn canBeFreelyGenerated(self: StackSlot) bool {
        return self.isLiteralValue() or self.isJunk() or self.isFunctionCallReturnLabel();
    }
};

/// The slots of a C++ `StackData`
const Slots = [*]align(4) const StackSlot;

/// An offset into a stack from the bottom (offset 0 = bottom), or none. No stack has an offset `none`, so the
/// type has the size of an offset.
pub const OptionalOffset = enum(usize) {
    none = std.math.maxInt(usize),
    _,

    inline fn some(offset: usize) OptionalOffset {
        return @fromBackingInt(@intCast(offset));
    }
    inline fn unwrap(self: OptionalOffset) ?usize {
        return if (self == .none) null else @backingInt(self);
    }
};

/// `ShuffleOp` of `ShuffleTrace.h`
pub const ShuffleOp = extern struct {
    kind: Kind,
    /// the operand of SWAPn and DUPn, 0 for the others
    depth: u8,
    /// the slot of a push or a load, junk for the others
    slot: StackSlot align(4),

    pub const Kind = enum(u8) { swap = 0, dup = 1, pop = 2, push = 3, load = 4, store = 5 };
};

comptime {
    std.debug.assert(@sizeOf(StackSlot) == 8);
    std.debug.assert(@sizeOf(ShuffleOp) == 12 and @alignOf(ShuffleOp) == 4 and @offsetOf(ShuffleOp, "slot") == 4);
}

/// `SpillSet` of `spill/SpillSet.h` in a buffer of the caller: the variable id is spilled if `spilled[id]` is
/// not 0. The buffer has a byte for each variable id of the caller.
const SpillSet = extern struct {
    spilled: [*]u8,

    /// Only a variable can be spilled
    inline fn isSpilled(self: SpillSet, slot: StackSlot) bool {
        return slot.isVariable() and self.spilled[slot.payload] != 0;
    }

    /// Spills the variable `slot`
    noinline fn add(self: *const SpillSet, slot: StackSlot) AssertionError!void {
        try assert(slot.isVariable()); // Lean
        try assert(self.spilled[slot.payload] == 0); // can't spill a value twice
        self.spilled[slot.payload] = 1;
    }
};

/// The partial bijection between the working stack's slots and target offsets: no offset is bound twice, a
/// target offset no slot is bound for is generated, and a slot without a destination is surplus
const Mapping = extern struct {
    destination_of: [max_stack_size]OptionalOffset,
    position_of: [max_stack_size]OptionalOffset,

    /// The mapping without bindings: no slot of a stack of `source_size` slots has a destination, and no
    /// slot is bound for a target offset below `target_size`
    inline fn reset(self: *Mapping, source_size: usize, target_size: usize) void {
        for (0..source_size) |pos| self.destination_of[pos] = .none;
        for (0..target_size) |destination| self.position_of[destination] = .none;
    }

    /// A copy of the entries of `other` for a stack of `source_size` slots and `target_size` target offsets
    inline fn copyFrom(self: *Mapping, other: *const Mapping, source_size: usize, target_size: usize) void {
        for (0..source_size) |pos| self.destination_of[pos] = other.destination_of[pos];
        for (0..target_size) |destination| self.position_of[destination] = other.position_of[destination];
    }

    /// The destination of the slot at `pos`, or none for a surplus slot
    inline fn destinationOf(self: *const Mapping, pos: usize) OptionalOffset {
        return self.destination_of[pos];
    }

    /// The position of the slot bound for `destination`, or none if no slot is bound for it
    inline fn positionOf(self: *const Mapping, destination: usize) OptionalOffset {
        return self.position_of[destination];
    }

    inline fn bind(self: *Mapping, pos: usize, destination: usize) void {
        self.destination_of[pos] = .some(destination);
        self.position_of[destination] = .some(pos);
    }

    /// Exchanges the destinations of the slots at `a` and `b`
    inline fn swapDestinations(self: *Mapping, a: usize, b: usize) void {
        const destination_of_a = self.destination_of[a];
        self.destination_of[a] = self.destination_of[b];
        self.destination_of[b] = destination_of_a;
        if (self.destination_of[a].unwrap()) |destination| self.position_of[destination] = .some(a);
        if (self.destination_of[b].unwrap()) |destination| self.position_of[destination] = .some(b);
    }

    /// Removes the slot at `top`, the top of the stack, with its binding. The entry of `top` in
    /// `destination_of` stays: it is above the stack, and the next push or dup binds it again.
    inline fn pop(self: *Mapping, top: usize) void {
        if (self.destination_of[top].unwrap()) |destination| self.position_of[destination] = .none;
    }
};

/// The working stack in a buffer of the caller, with the trace of the operations on it
const Stack = extern struct {
    data: *[max_stack_size]StackSlot,
    size: usize,
    trace: *[max_trace_size]ShuffleOp,
    trace_size: usize,

    inline fn at(self: *const Stack, offset: usize) StackSlot {
        return self.data[0..self.size][offset];
    }

    inline fn top(self: *const Stack) StackSlot {
        return self.at(self.topOffset());
    }

    /// Wraps for the empty stack, as in C++
    inline fn topOffset(self: *const Stack) usize {
        return self.size -% 1;
    }

    /// The distance of `offset` from the stack top (depth 0 = top). Wraps for an offset above the stack, as in C++.
    inline fn offsetToDepth(self: *const Stack, offset: usize) usize {
        return self.size -% 1 -% offset;
    }

    inline fn swap(self: *Stack, offset: usize) AssertionError!void {
        const slot = self.data[offset];
        self.data[offset] = self.top();
        self.data[self.size - 1] = slot;
        try self.record(.swap, self.offsetToDepth(offset), .junk);
    }

    /// A variable can only be pushed by a reload of its spill
    inline fn push(self: *Stack, slot: StackSlot) AssertionError!void {
        try assert(self.size < max_stack_size);
        self.data[self.size] = slot;
        self.size += 1;
        try self.record(if (slot.isVariable()) .load else .push, 0, slot);
    }

    inline fn dup(self: *Stack, offset: usize) AssertionError!void {
        try assert(self.size < max_stack_size);
        try self.record(.dup, self.offsetToDepth(offset) + 1, .junk);
        self.data[self.size] = self.data[offset];
        self.size += 1;
    }

    inline fn pop(self: *Stack) AssertionError!void {
        try assert(self.size != 0);
        self.size -= 1;
        try self.record(.pop, 0, .junk);
    }

    /// Writes the members in place: the trace gets no copy of an operation from a frame
    inline fn record(self: *Stack, kind: ShuffleOp.Kind, depth: usize, slot: StackSlot) AssertionError!void {
        try assert(self.trace_size < max_trace_size);
        const op = &self.trace[self.trace_size];
        op.kind = kind;
        op.depth = @truncate(depth);
        op.slot = slot;
        self.trace_size += 1;
    }
};

/// A copy that sits in a wildcard slot can either be moved to the target offset demanding it or left there,
/// serving the demand with a duplicate
pub const WildcardSlotsStrategy = enum(u8) { leave = 0, take = 1 };

/// Builds the mapping of the source stack to the target. Every target offset is either served by a source
/// slot (retained) or left empty (generated); source slots without a target offset are surplus. `Planner.run`
/// runs the five phases in order.
///
/// The mapping is the caller's. `dropped` has a byte for each source slot: the slot is scheduled to be popped
/// if its byte is not 0.
const MappingBuilder = extern struct {
    source: Slots,
    source_size: usize,
    target: Slots,
    target_size: usize,
    dropped: *const [max_stack_size]u8,
    wildcard_slots_strategy: WildcardSlotsStrategy,
    /// without bindings for `source_size` source slots and `target_size` target offsets
    mapping: *Mapping,
    /// Whether any target offset's demand was answered by a copy sitting in a wildcard slot, i.e. whether
    /// the `WildcardSlotsStrategy` had anything to decide
    saw_wildcard_copy: bool,

    /// Which copies `closestCopy` considers: only those standing in wildcard slots or only those that do not
    const CopyLocation = enum(u8) { outside_wildcard_slots = 0, in_wildcard_slots = 1 };

    inline fn sourceAt(self: *const MappingBuilder, offset: usize) StackSlot {
        return self.source[0..self.source_size][offset];
    }

    inline fn targetAt(self: *const MappingBuilder, offset: usize) StackSlot {
        return self.target[0..self.target_size][offset];
    }

    /// Whether the source slot is not scheduled to be dropped and also not yet pointing to a target
    inline fn mappable(self: *const MappingBuilder, source_offset: usize) bool {
        return self.dropped[source_offset] == 0 and self.mapping.destinationOf(source_offset) == .none;
    }

    /// Whether a source slot already serves `target_offset`
    inline fn hasSourceAssigned(self: *const MappingBuilder, target_offset: usize) bool {
        return self.mapping.positionOf(target_offset) != .none;
    }

    /// Whether the target at `target_offset` is junk, i.e. accepts whatever ends up there
    inline fn isWildcardTarget(self: *const MappingBuilder, target_offset: usize) bool {
        return self.targetAt(target_offset).isJunk();
    }

    /// Whether the source slot at `source_offset` stands at an offset that exists in the target and is junk
    /// there, i.e. a copy that may stay put
    inline fn inWildcardSlot(self: *const MappingBuilder, source_offset: usize) bool {
        return source_offset < self.target_size and self.isWildcardTarget(source_offset);
    }

    inline fn absDiff(a: usize, b: usize) usize {
        return if (a > b) a - b else b - a;
    }

    inline fn commonSize(self: *const MappingBuilder) usize {
        return @min(self.source_size, self.target_size);
    }

    noinline fn map(self: *MappingBuilder, source_offset: usize, target_offset: usize) AssertionError!void {
        try assert(self.mappable(source_offset));
        // slot already has a destination
        try assert(self.mapping.destinationOf(source_offset) == .none);
        // destination already bound to a slot
        try assert(self.mapping.positionOf(target_offset) == .none);
        self.mapping.bind(source_offset, target_offset);
    }

    /// The closest mappable copy of the slot demanded at `target_offset` among the copies at `location`; ties
    /// go to the shallower copy
    noinline fn closestCopy(
        self: *const MappingBuilder,
        target_offset: usize,
        location: CopyLocation,
    ) OptionalOffset {
        const in_wildcard_slots = location == .in_wildcard_slots;
        var best: OptionalOffset = .none;
        for (0..self.source_size) |i| {
            if (self.sourceAt(i).eql(self.targetAt(target_offset)) and
                self.mappable(i) and
                self.inWildcardSlot(i) == in_wildcard_slots)
            {
                if (best == .none or absDiff(i, target_offset) <= absDiff(@backingInt(best), target_offset))
                    best = .some(i);
            }
        }
        return best;
    }

    /// slots already in place get mapped directly
    noinline fn mapInPlace(self: *MappingBuilder) AssertionError!void {
        for (0..self.commonSize()) |j| {
            if (self.sourceAt(j).eql(self.targetAt(j)) and self.mappable(j)) {
                try self.map(j, j);
            }
        }
    }

    /// the remaining target offsets take the closest unused copy, deepest first: what is left over is
    /// generated on top, where that is cheapest
    noinline fn mapClosestCopies(self: *MappingBuilder) AssertionError!void {
        for (0..self.target_size) |j| {
            if (!self.hasSourceAssigned(j) and !self.isWildcardTarget(j)) {
                if (self.closestCopy(j, .outside_wildcard_slots).unwrap()) |copy| {
                    try self.map(copy, j);
                }
            }
        }
    }

    /// copies sitting in wildcard slots are taken or left according to the strategy
    noinline fn mapWildcardSlotCopies(self: *MappingBuilder) AssertionError!void {
        for (0..self.target_size) |j| {
            if (!self.hasSourceAssigned(j) and !self.isWildcardTarget(j)) {
                if (self.closestCopy(j, .in_wildcard_slots).unwrap()) |copy| {
                    // a function return label is always taken, can't be duped or pushed
                    if (self.targetAt(j).isFunctionReturnLabel()) {
                        try self.map(copy, j);
                    } else {
                        self.saw_wildcard_copy = true;
                        if (self.wildcard_slots_strategy == .take) {
                            try self.map(copy, j);
                        }
                    }
                }
            }
        }
    }

    /// wildcards keep whatever sits there
    noinline fn keepWildcardSlots(self: *MappingBuilder) AssertionError!void {
        for (0..self.commonSize()) |j| {
            if (self.isWildcardTarget(j) and !self.hasSourceAssigned(j) and self.mappable(j)) {
                try self.map(j, j);
            }
        }
    }

    /// the remaining wildcards absorb the closest surplus slot instead of having it popped
    noinline fn absorbSurplus(self: *MappingBuilder) AssertionError!void {
        for (0..self.target_size) |j| {
            if (self.isWildcardTarget(j) and !self.hasSourceAssigned(j)) {
                // of two slots at the same distance the deeper one: the comparison is strict
                var best: OptionalOffset = .none;
                for (0..self.source_size) |o| {
                    if (self.mappable(o) and (best == .none or absDiff(o, j) < absDiff(@backingInt(best), j)))
                        best = .some(o);
                }
                if (best.unwrap()) |surplus| {
                    try self.map(surplus, j);
                }
            }
        }
    }
};

/// The slot at `offset` of the working stack is out of reach by `excess` slots
const Blocked = extern struct {
    offset: usize,
    excess: usize,
};

/// The arrays of a planner and its emissions. Each user writes an element before it reads it.
const Scratch = extern struct {
    /// the mapping of the source to the target of an attempt
    planned_mapping: Mapping,
    /// the working mapping of the emission of an attempt
    mapping: Mapping,
    /// `Emission.buildBottomUp` and `Emission.permuteAtLowestHeight`
    permutation: [max_stack_size]usize,
    holes: [max_stack_size]usize,
    parked: [max_stack_size]usize,
    /// `Emission.permute`
    desired_by: [max_stack_size]OptionalOffset,
    /// `Planner.resolve`
    dropped_now: [max_stack_size]u8,
    candidates: [max_stack_size]usize,
};

/// One attempt to emit a plan's shuffle. Works on a copy of the source stack and records every operation in
/// a trace. The attempt has a fixed structure: surplus slots are popped, the retained slots are permuted at
/// the lowest stack height, then every target offset gets its slot bottom-up and the rest is one final
/// permutation.
const Emission = extern struct {
    target: Slots,
    target_size: usize,
    /// the emission does not spill
    spills: SpillSet,
    /// Deepest slot a swap may address: SWAP16 swaps with depth 16
    max_swap_depth: usize,
    /// Deepest slot a dup may address: DUP16 duplicates the slot at depth 15
    max_dup_depth: usize,
    /// the working stack and its (in sync) mapping
    stack: Stack,
    mapping: *Mapping,
    /// Number of target offsets whose slot still has to be produced; decremented by `produce`
    pending_generations: usize,
    /// only after `error.Blocked`
    blocked: Blocked,
    /// the mapping of the source stack to the target, before any operation
    planned_mapping: *const Mapping,
    scratch: *Scratch,

    /// The source stack is `stack`, and `planned_mapping` maps it to the target. The working mapping starts
    /// as a copy of it.
    inline fn init(
        self: *Emission,
        stack: Stack,
        target: Slots,
        target_size: usize,
        planned_mapping: *const Mapping,
        spills: SpillSet,
        max_swap_depth: usize,
        scratch: *Scratch,
    ) void {
        self.target = target;
        self.target_size = target_size;
        self.spills = spills;
        self.max_swap_depth = max_swap_depth;
        self.max_dup_depth = max_swap_depth - 1;
        self.stack = stack;
        self.mapping = &scratch.mapping;
        self.planned_mapping = planned_mapping;
        self.scratch = scratch;
        self.mapping.copyFrom(planned_mapping, stack.size, target_size);
        self.pending_generations = 0;
        for (0..target_size) |offset| {
            if (self.mapping.positionOf(offset) == .none) self.pending_generations += 1;
        }
    }

    inline fn targetAt(self: *const Emission, offset: usize) StackSlot {
        return self.target[0..self.target_size][offset];
    }

    /// Whether the slot at `pos` has no target offset to go to and is to be popped
    inline fn isSurplus(self: *const Emission, pos: usize) bool {
        return self.mapping.destinationOf(pos) == .none;
    }

    /// Whether the slot at `pos` is bound for `pos` itself, i.e., already is at its final target offset
    inline fn isFinal(self: *const Emission, pos: usize) bool {
        return self.mapping.destinationOf(pos) == OptionalOffset.some(pos);
    }

    /// Depth of the slot at `pos` below the top of the working stack
    inline fn depthOf(self: *const Emission, pos: usize) usize {
        return self.stack.offsetToDepth(pos);
    }

    /// Whether a swap can reach the slot at `pos`; trivially true for the top itself
    inline fn isSwapReachable(self: *const Emission, pos: usize) bool {
        return self.depthOf(pos) <= self.max_swap_depth;
    }

    /// Whether a dup can reach the slot at `pos`
    inline fn isDupReachable(self: *const Emission, pos: usize) bool {
        return self.depthOf(pos) <= self.max_dup_depth;
    }

    /// The slot at `position` is out of reach by `excess` slots
    inline fn block(self: *Emission, position: usize, excess: usize) Error {
        if (!(excess > 0)) return error.AssertionFailed;
        self.blocked = .{ .offset = position, .excess = excess };
        return error.Blocked;
    }

    /// A swap cannot reach the slot at `position`
    inline fn blockSwapUnreachable(self: *Emission, position: usize) Error {
        return self.block(position, self.depthOf(position) -% self.max_swap_depth);
    }

    /// A dup cannot reach the slot at `position`
    inline fn blockDupUnreachable(self: *Emission, position: usize) Error {
        return self.block(position, self.depthOf(position) -% self.max_dup_depth);
    }

    noinline fn isSpilled(self: *const Emission, slot: StackSlot) bool {
        return self.spills.isSpilled(slot);
    }

    noinline fn shallowestCopyPosition(self: *const Emission, slot: StackSlot) OptionalOffset {
        var pos = self.stack.size;
        while (pos > 0) {
            pos -= 1;
            if (self.stack.at(pos).eql(slot)) return .some(pos);
        }
        return .none;
    }

    /// Whether the slot of the target offset `offset` can be generated, loaded, or DUPed from a copy on the
    /// stack, which can be out of reach
    noinline fn isAvailable(self: *const Emission, offset: usize) bool {
        const slot = self.targetAt(offset);
        return slot.canBeFreelyGenerated() or self.isSpilled(slot) or self.shallowestCopyPosition(slot) != .none;
    }

    /// Swaps the top with the slot at `pos`, the destinations traveling along
    noinline fn swapWith(self: *Emission, pos: usize) AssertionError!void {
        try assert(pos < self.stack.size); // Lean
        try assert(!self.isFinal(pos)); // swapping a final slot out of place
        const depth = self.depthOf(pos);
        try assert(1 <= depth and depth <= self.max_swap_depth); // invalid swap target
        try self.stack.swap(pos);
        self.mapping.swapDestinations(pos, self.stack.topOffset());
    }

    /// Removes the top slot with its destination, if any
    noinline fn pop(self: *Emission) AssertionError!void {
        const top = self.stack.topOffset();
        try self.stack.pop();
        self.mapping.pop(top);
    }

    noinline fn push(self: *Emission, slot: StackSlot, destination: usize) AssertionError!void {
        try self.stack.push(slot);
        // destination already bound to a slot
        try assert(self.mapping.positionOf(destination) == .none);
        self.mapping.bind(self.stack.topOffset(), destination);
    }

    noinline fn dup(self: *Emission, copy: usize, destination: usize) AssertionError!void {
        // cannot dup a function return label
        try assert(!self.stack.at(copy).isFunctionReturnLabel());
        try self.stack.dup(copy);
        // destination already bound to a slot
        try assert(self.mapping.positionOf(destination) == .none);
        self.mapping.bind(self.stack.topOffset(), destination);
    }

    /// Produces the slot for `target_offset`
    noinline fn produce(self: *Emission, target_offset: usize) Error!void {
        const slot = self.targetAt(target_offset);
        const copy = self.shallowestCopyPosition(slot);
        if (slot.isJunk()) {
            try self.push(slot, target_offset);
        } else if (copy != .none and self.isDupReachable(@backingInt(copy))) {
            try self.dup(@backingInt(copy), target_offset);
        } else if (slot.canBeFreelyGenerated() or self.isSpilled(slot)) {
            try self.push(slot, target_offset);
        } else if (copy != .none) {
            return self.blockDupUnreachable(@backingInt(copy));
        } else {
            // generated slot has no copy on the stack and is not spilled
            return error.AssertionFailed;
        }
        try assert(self.mapping.positionOf(target_offset) == OptionalOffset.some(self.stack.topOffset()));
        self.pending_generations -%= 1;
    }

    /// Produces the slot for `target_offset` and moves it toward its place right away: if the offset exists
    /// already and holds a slot that is not final, a single swap places the produced slot and floats the
    /// other one, which may be its own placement. An equal slot there just takes over the destination.
    noinline fn generate(self: *Emission, target_offset: usize) Error!void {
        try assert(target_offset < self.target_size); // Lean
        try self.produce(target_offset);
        // `produce` left the slot on top; swap it down only if its offset exists strictly below the top:
        // as the top itself it is in place already, beyond the height it has to wait on top anyway
        if (target_offset + 1 < self.stack.size and !self.isFinal(target_offset)) {
            if (self.stack.at(target_offset).eql(self.stack.top())) {
                // an equal slot stands at the offset: retag instead of swapping two equal slots
                self.mapping.swapDestinations(target_offset, self.stack.topOffset());
            } else if (self.isSwapReachable(target_offset)) {
                return self.swapWith(target_offset);
            }
            // out of swap reach: leave the slot on top; buildBottomUp re-checks reach when filling the offset
        }
    }

    /// The slot at each offset `pos` goes to the offset `permutation[pos]`, a permutation of the offsets of
    /// the working stack. Changes the array in place: the regroup and each pass write it.
    noinline fn permute(self: *Emission, permutation: *[max_stack_size]usize) Error!void {
        if (self.stack.size == 0) return; // Lean

        // Equal slots are interchangeable: among them, those already at one of their desired offsets stay,
        // the others take the remaining offsets. Otherwise equal slots would pass each other in cycles.
        // A group is the offsets of equal slots, and the highest of them is its leader. desired_by[offset]
        // is the leader of the group that desires the offset, or none before that group.
        const desired_by = &self.scratch.desired_by;
        for (0..self.stack.size) |offset| desired_by[offset] = .none;
        for (0..self.stack.size) |leader| {
            const slot = self.stack.at(leader);
            if (self.shallowestCopyPosition(slot) != OptionalOffset.some(leader)) continue;
            // the group's desired offsets
            for (0..leader + 1) |pos| {
                if (self.stack.at(pos).eql(slot)) desired_by[permutation[pos]] = .some(leader);
            }
            // slots already standing on one of the group's desired offsets stay put, the others take the
            // vacant offsets (desired, but not in the group), both sides ascending, so nothing crosses
            var vacant: usize = 0;
            for (0..leader + 1) |pos| {
                if (!self.stack.at(pos).eql(slot)) continue;
                if (desired_by[pos] == OptionalOffset.some(leader)) {
                    permutation[pos] = pos;
                    continue;
                }
                while (vacant < self.stack.size and
                    !(desired_by[vacant] == OptionalOffset.some(leader) and !self.stack.at(vacant).eql(slot)))
                {
                    vacant += 1;
                }
                // movers and vacant must have the same size
                try assert(vacant < self.stack.size);
                permutation[pos] = vacant;
                vacant += 1;
            }
        }

        // `permutation` is a permutation of the offsets. Let m be the number of offsets i with
        // permutation[i] != i, and t be 1 if permutation[top] == top, else 0. Then 3 <= 2 m + 3 t <=
        // 2 size + 1, and each iteration that does not return lowers 2 m + 3 t. Thus the loop ends after at
        // most 2 size - 1 iterations.
        const top = self.stack.topOffset();
        while (true) {
            var pos = permutation[top];
            if (pos == top) {
                // the top is in place: find the shallowest misplaced slot
                var candidate = top;
                while (candidate > 0) {
                    candidate -= 1;
                    if (permutation[candidate] != candidate) {
                        pos = candidate;
                        break;
                    }
                }
                // nothing misplaced was found, we're done
                if (pos == top) return;
            }
            // an equal slot at `pos` serves the top's destination just as well; a misplaced slot equal to
            // the top takes over the top's destination, making the top the misplaced one
            if (self.stack.at(pos).eql(self.stack.top())) {
                self.mapping.swapDestinations(pos, top);
            } else if (!self.isSwapReachable(pos)) {
                return self.blockSwapUnreachable(pos);
            } else {
                try self.stack.swap(pos);
                self.mapping.swapDestinations(pos, top);
            }
            const desired = permutation[pos];
            permutation[pos] = permutation[top];
            permutation[top] = desired;
        }
    }

    /// Pops all surplus slots, or blocks if a surplus slot that has to be popped is out of swap reach
    noinline fn removeSurplus(self: *Emission) Error!void {
        while (self.stack.size != 0) {
            // scan from the top down: the first surplus slot is the shallowest, the last reachable one the
            // deepest
            var shallowest_surplus: OptionalOffset = .none;
            var deepest_reachable_surplus: OptionalOffset = .none;
            var pos = self.stack.size;
            while (pos > 0) {
                pos -= 1;
                if (self.isSurplus(pos)) {
                    if (shallowest_surplus == .none) shallowest_surplus = .some(pos);
                    if (self.isSwapReachable(pos)) deepest_reachable_surplus = .some(pos);
                }
            }
            const shallowest = shallowest_surplus.unwrap() orelse break;
            // there is a surplus but we can't reach it
            const deepest_reachable = deepest_reachable_surplus.unwrap() orelse
                return self.blockSwapUnreachable(shallowest);

            const stack_top_offset = self.stack.topOffset();
            if (shallowest != stack_top_offset) {
                // a surplus slot equal to the top takes over the top's destination, so the top itself can
                // be popped
                var equal_surplus: OptionalOffset = .none;
                var candidate = stack_top_offset;
                while (candidate > 0) {
                    candidate -= 1;
                    if (self.isSurplus(candidate) and self.stack.at(candidate).eql(self.stack.top())) {
                        equal_surplus = .some(candidate);
                        break;
                    }
                }
                if (equal_surplus.unwrap()) |equal| {
                    self.mapping.swapDestinations(equal, stack_top_offset);
                } else {
                    try self.swapWith(deepest_reachable);
                }
            }
            try self.pop();
        }
    }

    /// The stack is at its lowest height now, so deep target offsets are at their most reachable. Permutes
    /// every slot to its destination, or, if the destination is above the stack, into a hole: an offset whose
    /// target slot the planned mapping does not bind. Such a slot floats to the top for free when the hole's
    /// slot is generated and swapped into place.
    noinline fn permuteAtLowestHeight(self: *Emission) Error!void {
        const permutation = &self.scratch.permutation;
        // offsets whose target slots will be generated later, and the slots that wait for one of them
        const holes = &self.scratch.holes;
        const parked = &self.scratch.parked;
        var hole_count: usize = 0;
        var parked_count: usize = 0;
        // each offset below the height gets one entry of permutation, so permutation needs no initial value
        for (0..self.stack.size) |pos| {
            // all surplus is gone, so every slot has a destination
            const destination = self.mapping.destinationOf(pos).unwrap() orelse return error.AssertionFailed;
            try assert(pos < self.target_size); // Lean
            // no slot is planned for the target offset pos, so its slot has to be generated
            const is_hole = self.planned_mapping.positionOf(pos) == .none;
            // the destination can not be served yet
            const is_parked = destination >= self.stack.size;
            if (!is_parked) permutation[pos] = destination;
            if (is_parked and is_hole) permutation[pos] = pos;
            if (is_parked and !is_hole) {
                parked[parked_count] = pos;
                parked_count += 1;
            }
            if (!is_parked and is_hole) {
                holes[hole_count] = pos;
                hole_count += 1;
            }
        }
        // parked and holes must have the same size
        try assert(parked_count == hole_count);
        // parked is in ascending order
        for (0..parked_count) |i| permutation[parked[i]] = holes[i];
        return self.permute(permutation);
    }

    /// Builds the target bottom-up. Every offset either holds its slot already, gets a retained slot that is
    /// floating above it, or gets a freshly generated slot. Once everything is generated the rest is one
    /// final permutation.
    ///
    /// Loop invariant: every offset below `target_offset` is final, i.e., holds the slot bound for it.
    noinline fn buildBottomUp(self: *Emission) Error!void {
        var target_offset: usize = 0;
        // an iteration that revisits its offset decrements it before the increment; both wrap, as in C++
        while (target_offset < self.target_size) : (target_offset +%= 1) {
            // the offset exists and already holds the slot bound for it: nothing to do
            if (target_offset < self.stack.size and self.isFinal(target_offset)) continue;

            // all is generated, the final permutation
            if (self.pending_generations == 0) {
                try assert(self.stack.size == self.target_size);
                // every slot goes to the offset it is bound for
                const permutation = &self.scratch.permutation;
                for (0..self.stack.size) |pos| {
                    permutation[pos] = self.mapping.destinationOf(pos).unwrap() orelse return error.AssertionFailed;
                }
                return self.permute(permutation);
            }

            // a target offset that needs something DUPed urgently before it goes out of dup reach
            var urgent_to_dup: OptionalOffset = .none;
            // going bottom-up so we can start from target_offset
            for (target_offset..self.target_size) |offset| {
                // only offsets no slot is bound for yet (ie that need to be duped) can be urgent
                if (self.mapping.positionOf(offset) != .none) continue;
                const slot = self.targetAt(offset);
                if (slot.isJunk() or slot.canBeFreelyGenerated() or self.isSpilled(slot)) continue;
                if (self.shallowestCopyPosition(slot).unwrap()) |source_copy| {
                    if (!self.isDupReachable(source_copy)) return self.blockDupUnreachable(source_copy);
                    // a copy sitting at the offset being filled floats to the top when it is, so no hurry
                    if (self.depthOf(source_copy) == self.max_dup_depth and
                        source_copy != target_offset and
                        urgent_to_dup == .none)
                    {
                        urgent_to_dup = .some(offset);
                    }
                }
            }

            if (urgent_to_dup.unwrap()) |urgent| {
                // there is a slot that is about to go out of dup range but demands more copies, it's not
                // the target offset anyways, and duping it doesn't make the target go out of swap range
                if (urgent != target_offset and self.stack.size -% target_offset < self.max_swap_depth) {
                    // generate it
                    try self.generate(urgent);
                    // and revisit the current target in the next iteration
                    target_offset -%= 1;
                    continue;
                }
            }

            // a slot whose offset is exactly where the result of a dup would end up is in place for free,
            // as long as nothing is urgent and target_offset stays in reach for the slot generated after it
            const source_top = self.stack.size;
            if (urgent_to_dup == .none and // nothing urgent
                source_top > target_offset and // the new top sits above the current target_offset
                source_top < self.target_size and // the new top is in the target offset range
                self.mapping.positionOf(source_top) == .none and // no slot is bound for the offset yet
                source_top - target_offset < self.max_swap_depth) // target_offset stays in swap reach
            {
                // we generate the slot demanded at source top
                try self.generate(source_top);
                // revisit target offset
                target_offset -%= 1;
                continue;
            }

            // a slot is bound for the target: retained or generated already
            if (self.mapping.positionOf(target_offset).unwrap()) |source_for_target_offset| {
                // We go bottom-up, so the slot that should go into target_offset is somewhere above. Any
                // equal slot that is not in place will do the trick: the one at `target_offset` itself,
                // else the shallowest one.
                // slot bound for the offset being filled is already below it
                try assert(source_for_target_offset >= target_offset);
                const slot = self.stack.at(source_for_target_offset);
                var pos = source_for_target_offset;
                if (self.stack.at(target_offset).eql(slot)) {
                    // if the slot currently occupying target_offset happens to be an equal copy of that
                    // value we're done and can set `pos` directly to the target offset
                    pos = target_offset;
                } else {
                    // otherwise search if there is an equal, movable copy shallower than carrier
                    var candidate = self.stack.topOffset();
                    while (candidate > source_for_target_offset) : (candidate -= 1) {
                        if (self.stack.at(candidate).eql(slot) and !self.isFinal(candidate)) {
                            pos = candidate;
                            break;
                        }
                    }
                }

                // we picked a valid `pos`
                try assert(self.stack.at(pos).eql(self.stack.at(source_for_target_offset)));

                // update the destinations if needed
                self.mapping.swapDestinations(pos, source_for_target_offset);

                // we're already done
                if (pos == target_offset) continue;

                // if `pos` is not already at the top of the stack, swap it up
                if (pos != self.stack.topOffset()) {
                    if (!self.isSwapReachable(pos)) return self.blockSwapUnreachable(pos); // bail
                    try self.swapWith(pos);
                }
            } else {
                // the slot needs to be DUPed
                try self.generate(target_offset);

                // `generate` might have already placed the slot into the target offset, then we're done for
                // this offset
                try assert(target_offset < self.stack.size); // Lean
                if (self.isFinal(target_offset)) continue;
            }

            // we might have to swap the top down into the target offset
            try assert(target_offset < self.stack.size); // Lean
            try assert(!self.isFinal(target_offset));
            if (target_offset != self.stack.topOffset()) {
                if (!self.isSwapReachable(target_offset)) return self.blockSwapUnreachable(target_offset);
                try self.swapWith(target_offset);
            }
        }
        try assert(self.stack.size == self.target_size);
    }

    /// Removes the surplus, permutes at the lowest height, then builds the target bottom-up. The result stays
    /// in the emission and in the caller's buffers: `blocked`, the trace, the working stack and `mapping`.
    /// The checks marked `Lean` are the precondition of `buildBottomUp` in the Lean model.
    noinline fn run(self: *Emission) Error!void {
        // removes all surplus (slots that have no destination in the target)
        try self.removeSurplus();
        try self.permuteAtLowestHeight();
        // stack height and pending generations must match the target size
        try assert(self.stack.size + self.pending_generations == self.target_size); // Lean
        var unmapped: usize = 0;
        for (0..self.target_size) |offset| {
            if (self.mapping.positionOf(offset) == .none) unmapped += 1;
        }
        // pending generations must count unmapped target slots
        try assert(unmapped == self.pending_generations); // Lean
        for (0..self.target_size) |offset| {
            // target slot is unavailable
            try assert(self.isAvailable(offset)); // Lean
        }
        for (0..self.target_size) |offset| {
            // function return label has no bound source
            try assert(!self.targetAt(offset).isFunctionReturnLabel() or self.mapping.positionOf(offset) != .none); // Lean
        }
        return self.buildBottomUp();
    }
};

/// How a slot can be regenerated after a drop, cheapest first: not needed or for free, pushed, reloaded from
/// an existing spill, duplicated from another copy, reloaded after a planned spill. The order of the values
/// is the order of the classes. `none`: the slot cannot be dropped.
const Class = enum(u8) { free = 0, push = 1, reload = 2, copy = 3, spill = 4, none = 0xff };

/// Plans the shuffle under one `WildcardSlotsStrategy`: builds the mapping and emits, and after each block
/// drops slots and tries again. The spill set and the dropped bytes are the caller's.
const Planner = extern struct {
    source: Slots,
    source_size: usize,
    target: Slots,
    target_size: usize,
    spills: SpillSet,
    spilling_allowed: bool,
    dropped: *[max_stack_size]u8,
    /// Only after `run`: whether the mapping of any attempt answered a demand with a copy in a wildcard slot
    saw_wildcard_copy: bool,
    max_swap_depth: usize,
    scratch: *Scratch,

    inline fn sourceAt(self: *const Planner, offset: usize) StackSlot {
        return self.source[0..self.source_size][offset];
    }

    inline fn targetAt(self: *const Planner, offset: usize) StackSlot {
        return self.target[0..self.target_size][offset];
    }

    noinline fn isRetained(mapping: *const Mapping, source_offset: usize) bool {
        return mapping.destinationOf(source_offset) != .none;
    }

    noinline fn hasOtherRetainedCopy(
        self: *const Planner,
        mapping: *const Mapping,
        dropped_now: *const [max_stack_size]u8,
        offset: usize,
    ) bool {
        for (0..self.source_size) |source_offset| {
            if (source_offset != offset and
                self.sourceAt(source_offset).eql(self.sourceAt(offset)) and // same value
                isRetained(mapping, source_offset) and
                dropped_now[source_offset] == 0) // not yet dropped
            {
                return true;
            }
        }
        return false;
    }

    /// this slot is needed somewhere in the target
    noinline fn isDemanded(self: *const Planner, slot: StackSlot) bool {
        for (0..self.target_size) |j| {
            if (!self.targetAt(j).isJunk() and self.targetAt(j).eql(slot)) return true;
        }
        return false;
    }

    /// The class of the slot at `offset`, which has a destination
    noinline fn classify(
        self: *const Planner,
        mapping: *const Mapping,
        dropped_now: *const [max_stack_size]u8,
        offset: usize,
    ) Class {
        const slot = self.sourceAt(offset);
        if (slot.isFunctionReturnLabel()) return .none;
        const regenerable = slot.isJunk() or slot.canBeFreelyGenerated() or self.spills.isSpilled(slot) or
            self.hasOtherRetainedCopy(mapping, dropped_now, offset);
        if (self.targetAt(@backingInt(mapping.destinationOf(offset))).isJunk() and
            (regenerable or !self.isDemanded(slot)))
        {
            return .free;
        }
        if (slot.canBeFreelyGenerated()) return .push;
        if (self.spills.isSpilled(slot)) return .reload;
        if (self.hasOtherRetainedCopy(mapping, dropped_now, offset)) return .copy;
        if (self.spilling_allowed and slot.isVariable()) return .spill;
        return .none;
    }

    /// Drops slots above the blocked one until it is within reach, cheapest regeneration first: slots whose
    /// target is a wildcard, freely generatable ones, spilled ones, values with another retained copy, and
    /// finally values that get a planned spill. Function return labels cannot be regenerated and are never
    /// dropped.
    ///
    /// `mapping` is the plan, and `current` the working mapping of a stack of `current_size` slots, with
    /// `blocked.offset` below `current_size`. Blocked: no candidate is left to drop. The drops and spills of
    /// the passes before a block or a failed assertion stay.
    noinline fn resolve(
        self: *Planner,
        mapping: *const Mapping,
        blocked: Blocked,
        current: *const Mapping,
        current_size: usize,
    ) Error!void {
        const dropped_now = &self.scratch.dropped_now;
        for (0..self.source_size) |source_offset| dropped_now[source_offset] = 0;

        // retained slots above the blocked one; the source offset of a retained slot is the one its
        // destination maps back to, while generated and surplus slots have no source. The working mapping
        // binds each destination once, so the candidates are distinct, and there are fewer than
        // current_size.
        const candidates = &self.scratch.candidates;
        var candidate_count: usize = 0;
        for (blocked.offset + 1..current_size) |pos| {
            if (current.destinationOf(pos).unwrap()) |destination| {
                if (mapping.positionOf(destination).unwrap()) |source| {
                    try assert(mapping.destinationOf(source) != .none); // Lean
                    candidates[candidate_count] = source;
                    candidate_count += 1;
                }
            }
        }

        for (0..blocked.excess) |_| {
            // classes can shift as copies get dropped, so pick one victim at a time
            var best: OptionalOffset = .none;
            var best_class: Class = .free;
            for (0..candidate_count) |i| {
                const offset = candidates[i];
                if (dropped_now[offset] != 0) continue;
                const class = self.classify(mapping, dropped_now, offset);
                if (class == .none) continue;
                // within a class prefer the slot whose target is highest
                if (best == .none or
                    @backingInt(class) < @backingInt(best_class) or
                    (class == best_class and
                        @backingInt(mapping.destinationOf(offset)) >
                            @backingInt(mapping.destinationOf(@backingInt(best)))))
                {
                    best = .some(offset);
                    best_class = class;
                }
            }
            const victim = best.unwrap() orelse return error.Blocked; // couldn't drop anything
            if (best_class == .spill) {
                try self.spills.add(self.sourceAt(victim));
            }
            dropped_now[victim] = 1;
            self.dropped[victim] = 1;
        }
    }

    /// Builds the mapping and emits from the source, and after each block resolves it and tries again, with
    /// the dropped bytes all 0 at the start. Done is a plan: `data` holds its stack, `ops` its `trace_size`
    /// operations, and `sources[j]` the source offset bound for target offset j in the mapping of the plan,
    /// or none. Blocked: `resolve` found nothing left to drop. Each attempt starts with a copy of the source
    /// in `data`, and writes `data` and `ops` as the emission does.
    noinline fn run(
        self: *Planner,
        strategy: WildcardSlotsStrategy,
        data: *[max_stack_size]StackSlot,
        ops: *[max_trace_size]ShuffleOp,
        sources: *[max_stack_size]OptionalOffset,
        trace_size: *usize,
    ) Error!void {
        self.saw_wildcard_copy = false;
        for (0..self.target_size) |j| {
            const slot = self.targetAt(j);
            // target slot neither on the stack nor generatable
            try assert(slot.isJunk() or
                slot.canBeFreelyGenerated() or
                contains(self.source, self.source_size, slot) or
                self.spills.isSpilled(slot));
        }

        while (true) {
            const mapping = &self.scratch.planned_mapping;
            mapping.reset(self.source_size, self.target_size);
            var builder: MappingBuilder = .{
                .source = self.source,
                .source_size = self.source_size,
                .target = self.target,
                .target_size = self.target_size,
                .dropped = self.dropped,
                .wildcard_slots_strategy = strategy,
                .mapping = mapping,
                .saw_wildcard_copy = false,
            };
            try builder.mapInPlace();
            try builder.mapClosestCopies();
            try builder.mapWildcardSlotCopies();
            try builder.keepWildcardSlots();
            try builder.absorbSurplus();
            self.saw_wildcard_copy = self.saw_wildcard_copy or builder.saw_wildcard_copy;

            for (0..self.source_size) |i| data[i] = self.sourceAt(i);
            var emission: Emission = undefined;
            emission.init(
                .{ .data = data, .size = self.source_size, .trace = ops, .trace_size = 0 },
                self.target,
                self.target_size,
                mapping,
                self.spills,
                self.max_swap_depth,
                self.scratch,
            );
            if (emission.run()) |_| {
                for (0..self.target_size) |j| sources[j] = mapping.positionOf(j);
                trace_size.* = emission.stack.trace_size;
                return;
            } else |err| switch (err) {
                error.Blocked => {},
                error.AssertionFailed => return err,
            }

            var dropped_before: usize = 0;
            for (0..self.source_size) |i| dropped_before += @intFromBool(self.dropped[i] != 0);
            try self.resolve(mapping, emission.blocked, emission.mapping, emission.stack.size);
            var dropped_after: usize = 0;
            for (0..self.source_size) |i| dropped_after += @intFromBool(self.dropped[i] != 0);
            // resolution must decrease the number of undropped source slots
            try assert(dropped_after > dropped_before); // Lean
        }
    }
};

/// Whether one of the `size` slots of `stack` is `slot`
inline fn contains(stack: Slots, size: usize, slot: StackSlot) bool {
    for (0..size) |i| {
        if (stack[i].eql(slot)) return true;
    }
    return false;
}

/// What a planner leaves behind
const Plan = extern struct {
    /// the shuffled stack
    data: [max_stack_size]StackSlot,
    /// the trace
    ops: [max_trace_size]ShuffleOp,
    trace_size: usize,
    /// for every target offset the source offset that serves it; none for a generated offset
    sources: [max_stack_size]OptionalOffset,
    /// for every source offset whether its slot is spilled after the planner ran
    spilled: [max_stack_size]u8,
    /// the number of variables that the planner spilled
    spill_count: usize,
};

/// All memory of `shuffle` but its inputs. The caller allocates it once (`workspaceSize` bytes with the
/// alignment `workspaceAlignment`) and can use it for any number of calls; it needs no initial value.
pub const Workspace = extern struct {
    /// one plan for each `WildcardSlotsStrategy`
    plans: [2]Plan,
    scratch: Scratch,
    dropped: [max_stack_size]u8,
    /// for every source offset whether its slot is spilled before any planner ran
    spilled_before: [max_stack_size]u8,
};

/// The inputs and outputs of `shuffle`
pub const Shuffle = extern struct {
    source: Slots,
    source_size: usize,
    target: Slots,
    target_size: usize,
    /// The spill set: the variable id is spilled if its byte is not 0. Has a byte for the id of each variable
    /// of the source and the target. After Done, it has the spills of the plan in addition; else it is as
    /// before unless an assertion failed.
    spills: [*]u8,
    workspace: *Workspace,
    /// The deepest slot a swap may address, at least 2. A dup may address one slot less.
    reachable_stack_depth: usize,
    spilling_allowed: bool,

    // The plan, in the workspace. Only after Done.

    /// the shuffled stack: `target_size` slots
    stack: [*]const StackSlot,
    /// the operations that shuffle the source to it
    trace: [*]const ShuffleOp,
    trace_size: usize,
    /// for each of the `target_size` target offsets the source offset that serves it; none for a generated offset
    sources: [*]const OptionalOffset,

    /// Runs the planner under `strategy` from the spills before, leaves its result in `plan` and restores
    /// the spills. Whether the planner has a plan.
    inline fn plan(
        self: *const Shuffle,
        planner: *Planner,
        strategy: WildcardSlotsStrategy,
        result: *Plan,
    ) AssertionError!bool {
        const workspace = self.workspace;
        for (0..self.source_size) |i| workspace.dropped[i] = 0;
        const done =
            if (planner.run(strategy, &result.data, &result.ops, &result.sources, &result.trace_size))
                true
            else |err| switch (err) {
                error.Blocked => false,
                error.AssertionFailed => |failed| return failed,
            };
        for (0..self.source_size) |i| result.spilled[i] = @intFromBool(planner.spills.isSpilled(self.source[i]));
        // the planner spills only variables of the source; a variable counts at its first unspill
        result.spill_count = 0;
        for (0..self.source_size) |i| {
            const slot = self.source[i];
            if (workspace.spilled_before[i] == 0 and planner.spills.isSpilled(slot)) {
                self.spills[slot.payload] = 0;
                result.spill_count += 1;
            }
        }
        return done;
    }

    /// Hands out `plan` and spills what its planner spilled
    inline fn commit(self: *Shuffle, result: *const Plan) void {
        for (0..self.source_size) |i| {
            const slot = self.source[i];
            if (slot.isVariable()) self.spills[slot.payload] = result.spilled[i];
        }
        self.stack = &result.data;
        self.trace = &result.ops;
        self.trace_size = result.trace_size;
        self.sources = &result.sources;
    }

    /// `Shuffle::run` of `Shuffler.cpp`: plans the shuffle under both wildcard policies when the choice
    /// matters. Copies sitting in wildcard slots are first left there and, if any demand was answered by such
    /// a copy, planned again taking them. Hands out the cheaper successful plan (fewest spills, then fewest
    /// operations). Blocked: neither policy admitted a plan (stack too deep).
    ///
    /// Each target slot is junk, can be freely generated, is on the source or is spilled, and the source has
    /// at least as many copies of a function return label as the target. Else an assertion fails.
    inline fn run(self: *Shuffle) Error!void {
        try assert(2 <= self.reachable_stack_depth);
        try assert(self.source_size <= max_stack_size);
        try assert(self.target_size <= max_stack_size);

        const workspace = self.workspace;
        var planner: Planner = .{
            .source = self.source,
            .source_size = self.source_size,
            .target = self.target,
            .target_size = self.target_size,
            .spills = .{ .spilled = self.spills },
            .spilling_allowed = self.spilling_allowed,
            .dropped = &workspace.dropped,
            .saw_wildcard_copy = false,
            .max_swap_depth = self.reachable_stack_depth,
            .scratch = &workspace.scratch,
        };
        for (0..self.source_size) |i| {
            workspace.spilled_before[i] = @intFromBool(planner.spills.isSpilled(self.source[i]));
        }

        const leave = &workspace.plans[@backingInt(WildcardSlotsStrategy.leave)];
        const leave_done = try self.plan(&planner, .leave, leave);
        if (!planner.saw_wildcard_copy) {
            if (!leave_done) return error.Blocked;
            return self.commit(leave);
        }

        const take = &workspace.plans[@backingInt(WildcardSlotsStrategy.take)];
        const take_done = try self.plan(&planner, .take, take);
        if (!leave_done and !take_done) return error.Blocked;
        const use_take = !leave_done or (take_done and
            (take.spill_count < leave.spill_count or
                (take.spill_count == leave.spill_count and take.trace_size < leave.trace_size)));
        self.commit(if (use_take) take else leave);
    }
};

/// `Shuffle.run` for C++, with its error as the status
fn shuffle(self: *Shuffle) callconv(.c) Status {
    self.run() catch |err| return switch (err) {
        error.Blocked => .blocked,
        error.AssertionFailed => .assertion_failed,
    };
    return .done;
}

fn workspaceSize() callconv(.c) usize {
    return @sizeOf(Workspace);
}

fn workspaceAlignment() callconv(.c) usize {
    return @alignOf(Workspace);
}

comptime {
    // The symbols are hidden: the caller is in the library that the object is linked into.
    @export(&shuffle, .{ .name = "solidity_shuffler_shuffle", .visibility = .hidden });
    @export(&workspaceSize, .{ .name = "solidity_shuffler_workspaceSize", .visibility = .hidden });
    @export(&workspaceAlignment, .{ .name = "solidity_shuffler_workspaceAlignment", .visibility = .hidden });
}

const testing = std.testing;

var test_workspace: Workspace = undefined;

fn testVariable(id: u32) StackSlot {
    return .{ .payload = id, .kind = .value, .value_opcode = 3 };
}

fn testLiteral(id: u32) StackSlot {
    return .{ .payload = id, .kind = .value, .value_opcode = StackSlot.opcode_const };
}

fn testShuffle(source: []const StackSlot, target: []const StackSlot, spills: []u8, spilling_allowed: bool, reach: usize) Shuffle {
    return .{
        .source = source.ptr,
        .source_size = source.len,
        .target = target.ptr,
        .target_size = target.len,
        .spills = spills.ptr,
        .workspace = &test_workspace,
        .reachable_stack_depth = reach,
        .spilling_allowed = spilling_allowed,
        .stack = undefined,
        .trace = undefined,
        .trace_size = undefined,
        .sources = undefined,
    };
}

/// Replays the trace of the plan on the source: each operation is within reach, the result is the stack of
/// the plan, and it matches the target
fn expectPlan(plan: *const Shuffle, spills: []const u8) !void {
    const source = plan.source[0..plan.source_size];
    const target = plan.target[0..plan.target_size];
    const reach = plan.reachable_stack_depth;
    var stack: [max_stack_size]StackSlot = undefined;
    var size = source.len;
    @memcpy(stack[0..size], source);
    for (plan.trace[0..plan.trace_size]) |op| switch (op.kind) {
        .swap => {
            try testing.expect(1 <= op.depth and op.depth <= reach and op.depth < size);
            std.mem.swap(StackSlot, &stack[size - 1], &stack[size - 1 - op.depth]);
        },
        .dup => {
            try testing.expect(1 <= op.depth and op.depth <= reach and op.depth <= size);
            try testing.expect(!stack[size - op.depth].isFunctionReturnLabel());
            stack[size] = stack[size - op.depth];
            size += 1;
        },
        .pop => {
            try testing.expect(size > 0);
            size -= 1;
        },
        .push => {
            try testing.expect(op.slot.canBeFreelyGenerated());
            stack[size] = op.slot;
            size += 1;
        },
        .load => {
            try testing.expect(op.slot.isVariable() and spills[op.slot.payload] != 0);
            stack[size] = op.slot;
            size += 1;
        },
        .store => return error.TestUnexpectedResult,
    };
    try testing.expectEqual(target.len, size);
    for (target, 0..) |slot, offset| {
        try testing.expect(plan.stack[offset].eql(stack[offset]));
        try testing.expect(slot.isJunk() or slot.eql(stack[offset]));
        if (plan.sources[offset].unwrap()) |source_offset| {
            try testing.expect(slot.isJunk() or slot.eql(source[source_offset]));
        }
    }
}

// test/libyul/ssa/stackShuffler/deep_argument_dup_order.stack
test "dups a slot before a push takes it out of reach" {
    const junk: StackSlot = .junk;
    const v129 = testVariable(0);
    const v43 = testVariable(1);
    const source = [_]StackSlot{ v129, v43 } ++ @as([10]StackSlot, @splat(junk)) ++
        [_]StackSlot{ testVariable(2), junk, testVariable(3), testVariable(4) };
    const target = [_]StackSlot{ v129, v43 } ++ @as([14]StackSlot, @splat(junk)) ++ [_]StackSlot{ testLiteral(5), v129 };
    var spills: [6]u8 = @splat(0);
    var plan = testShuffle(&source, &target, &spills, true, 16);
    try plan.run();
    try expectPlan(&plan, &spills);
    const kinds = [_]ShuffleOp.Kind{ .dup, .push, .swap };
    const depths = [_]u8{ 16, 0, 1 };
    try testing.expectEqual(kinds.len, plan.trace_size);
    for (kinds, depths, plan.trace[0..plan.trace_size]) |kind, depth, op| {
        try testing.expectEqual(kind, op.kind);
        try testing.expectEqual(depth, op.depth);
    }
    try testing.expectEqualSlices(u8, &@as([6]u8, @splat(0)), &spills);
}

test "spills what is out of reach, or is blocked if it may not" {
    // the slot at the bottom is to be swapped with the top, 4 slots above it
    const source = [_]StackSlot{ testVariable(0), testVariable(1), testVariable(2), testVariable(3), testVariable(4) };
    const target = [_]StackSlot{ testVariable(4), testVariable(1), testVariable(2), testVariable(3), testVariable(0) };
    for ([_]bool{ false, true }) |spilling_allowed| {
        var spills: [5]u8 = @splat(0);
        var plan = testShuffle(&source, &target, &spills, spilling_allowed, 2);
        if (spilling_allowed) {
            try plan.run();
            try expectPlan(&plan, &spills);
            try testing.expect(std.mem.indexOfScalar(u8, &spills, 1) != null);
        } else {
            try testing.expectError(error.Blocked, plan.run());
            try testing.expectEqualSlices(u8, &@as([5]u8, @splat(0)), &spills);
        }
    }
}

test "a target slot that is not available fails an assertion" {
    const source = [_]StackSlot{testVariable(0)};
    const target = [_]StackSlot{testVariable(1)};
    var spills: [2]u8 = @splat(0);
    var plan = testShuffle(&source, &target, &spills, true, 16);
    try testing.expectError(error.AssertionFailed, plan.run());
    try testing.expectEqual(Status.assertion_failed, shuffle(&plan));
}

test "random stacks shuffle to their targets" {
    const variable_count = 6;
    const max_size = 24;
    var prng: std.Random.DefaultPrng = .init(0x5eed);
    const random = prng.random();
    for (0..50_000) |_| {
        const reach: usize = if (random.boolean()) 16 else random.intRangeAtMost(usize, 2, 6);
        const spilling_allowed = random.boolean();
        var spills: [variable_count]u8 = undefined;
        for (&spills) |*spilled| spilled.* = @intFromBool(random.uintLessThan(u8, 8) == 0);
        const spills_before = spills;

        var source_buffer: [max_size]StackSlot = undefined;
        const source = source_buffer[0..random.uintAtMost(usize, max_size)];
        var return_labels: usize = 0;
        for (source) |*slot| slot.* = switch (random.uintLessThan(u8, 16)) {
            0...8 => testVariable(random.uintLessThan(u32, variable_count)),
            9, 10 => testLiteral(variable_count + random.uintLessThan(u32, 2)),
            11, 12 => .junk,
            13, 14 => .{ .payload = random.uintLessThan(u32, 2), .kind = .function_call_return_label, .value_opcode = StackSlot.opcode_unreachable },
            else => label: {
                return_labels += 1;
                break :label .{ .payload = 0, .kind = .function_return_label, .value_opcode = StackSlot.opcode_unreachable };
            },
        };

        var target_buffer: [max_size]StackSlot = undefined;
        const target = target_buffer[0..random.uintAtMost(usize, max_size)];
        for (target) |*slot| slot.* = switch (random.uintLessThan(u8, 16)) {
            // a variable of the source or a spilled one
            0...8 => variable: {
                const candidate = if (source.len > 0 and random.boolean())
                    source[random.uintLessThan(usize, source.len)]
                else
                    testVariable(random.uintLessThan(u32, variable_count));
                const available = candidate.isVariable() and
                    (spills[candidate.payload] != 0 or contains(source.ptr, source.len, candidate));
                break :variable if (available) candidate else .junk;
            },
            9, 10 => testLiteral(variable_count + random.uintLessThan(u32, 2)),
            11, 12 => .junk,
            13, 14 => .{ .payload = random.uintLessThan(u32, 2), .kind = .function_call_return_label, .value_opcode = StackSlot.opcode_unreachable },
            // the source has at least as many function return labels as the target
            else => label: {
                if (return_labels == 0) break :label .junk;
                return_labels -= 1;
                break :label .{ .payload = 0, .kind = .function_return_label, .value_opcode = StackSlot.opcode_unreachable };
            },
        };

        var plan = testShuffle(source, target, &spills, spilling_allowed, reach);
        if (plan.run()) |_| {
            try expectPlan(&plan, &spills);
            for (spills, spills_before) |after, before| {
                try testing.expect(after == 1 or (after == 0 and before == 0));
                if (!spilling_allowed) try testing.expectEqual(before, after);
            }
        } else |err| switch (err) {
            error.Blocked => try testing.expectEqualSlices(u8, &spills_before, &spills),
            // the error return trace has the line of the assertion
            error.AssertionFailed => return err,
        }
    }
}
