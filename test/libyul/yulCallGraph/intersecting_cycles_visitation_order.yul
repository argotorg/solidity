{
    // Same topology as intersecting_cycles.yul (two recursive cycles sharing a node, so the whole
    // {hub, spoke, rim} set is a single strongly-connected component) but with different function names.
    function hub() { spoke() rim() }
    function spoke() { hub() }
    function rim() { spoke() }
}
// ----
// <main>
// hub (recursive) -> spoke, rim
// spoke (recursive) -> hub
// rim (recursive) -> spoke
