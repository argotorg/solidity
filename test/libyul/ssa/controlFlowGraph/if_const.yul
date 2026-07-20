{
    let x := calldataload(3)
    // this should not appear in the output at all
    if 0 {
        x := calldataload(77)
    }
    // this should avoid a conditional jump
    if 33 {
        x := calldataload(42)
    }
    let y := calldataload(x)
    sstore(y, 0)
}
// ----
// digraph SSACFG {
// nodesep=0.7;
// graph[fontname="DejaVu Sans"]
// node[shape=box,fontname="DejaVu Sans"];
//
// Entry [label="Entry"];
// Entry -> Block0_0;
// Block0_0 [fillcolor="#FF746C", style=filled, label="\
// Block 0; (0, max 0)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv1 := calldataload(0x03)\l\
// v7 := calldataload(0x2a)\l\
// v14 := calldataload(v7)\l\
// sstore(v14, 0x00)\l\
// "];
// Block0_0Exit [label="MainExit"];
// Block0_0 -> Block0_0Exit;
// }
