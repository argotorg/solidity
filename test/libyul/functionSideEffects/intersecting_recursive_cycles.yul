{
    // Two recursive cycles sharing alpha: alpha <-> beta and alpha -> gamma -> beta -> alpha,
    // so {alpha, beta, gamma} is a single strongly-connected component (all three are recursive).
    //
    // The old call-graph cycle finder mis-classified gamma as non-recursive (SOL-2026-2), but the
    // side-effect result is unaffected.
    function alpha() { beta() gamma() }
    function beta() { alpha() }
    function gamma() { beta() }
}
// ----
// : movable, movable apart from effects, can be removed, can be removed if no msize
// alpha: movable apart from effects, can loop
// beta: movable apart from effects, can loop
// gamma: movable apart from effects, can loop
