{
    let x
    if mload(42) {
        x := 5
    }
    sstore(x, x)
}
// ----
// digraph SSACFG {
// nodesep=0.7;
// graph[fontname="DejaVu Sans"]
// node[shape=box,fontname="DejaVu Sans"];
//
// Entry [label="Entry"];
// Entry -> Block0_0;
// Block0_0 [label="\
// Block 0; (0, max 2)\nLiveIn: \l\
// LiveOut: v0[1]\l\nUsed: \l\nv0 := 0x00\l\
// v1 := mload(0x2a)\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If v1 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_2 [style="solid"];
// Block0_0Exit:1 -> Block0_1 [style="solid"];
// Block0_1 [label="\
// Block 1; (1, max 2)\nLiveIn: \l\
// LiveOut: v2[1]\l\nUsed: \l\nv2 := 0x05\l\
// "];
// Block0_1 -> Block0_1Exit [arrowhead=none];
// Block0_1Exit [label="Jump" shape=oval];
// Block0_1Exit -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (2, max 2)\nLiveIn: phi0[3]\l\
// LiveOut: \l\nUsed: phi0[3]\l\nphi0 := φ(\l\
// 	Block 0 => v0,\l\
// 	Block 1 => v2\l\
// )\l\
// sstore(phi0, phi0)\l\
// "];
// Block0_2Exit [label="MainExit"];
// Block0_2 -> Block0_2Exit;
// }
