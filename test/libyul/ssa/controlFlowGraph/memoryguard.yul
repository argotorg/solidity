{
    let p := memoryguard(0x80)
    mstore(p, 42)
    let q := memoryguard(0x80)
    sstore(q, 1)
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
// LiveOut: \l\nUsed: \l\nv0 := memoryguard<0x80>()\l\
// mstore(0x2a, v0)\l\
// v3 := memoryguard<0x80>()\l\
// sstore(0x01, v3)\l\
// "];
// Block0_0Exit [label="MainExit"];
// Block0_0 -> Block0_0Exit;
// }
