// A snippet whose live sets stay shallow enough that the layout generator never spills. The spill
// info reports `none` for every CFG and MemoryAddressing reserves no region.
object "C" {
    code {
        let x := calldataload(0x0)
        let y := calldataload(0x20)
        sstore(x, add(x, y))
    }
}
// ----
// object "C"
// ===== SSA CFG =====
// #0:
//     v0 = const 0x00
//     v1 = builtin @calldataload v0
//     v2 = const 0x20
//     v3 = builtin @calldataload v2
//     v4 = builtin @add v1, v3
//     builtin @sstore v1, v4
//     main_exit
//
// ===== spill info =====
// CFG[0] <main>
//   spilled: none
