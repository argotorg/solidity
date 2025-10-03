{
    let x := calldataload(3)
    if mload(42) {
        x := calldataload(77)
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
// Entry0 [label="Entry"];
// Entry0 -> Block0_0;
// Block0_0 [label="\
// Block 0; (0, max 2)\nLiveIn: \l\
// LiveOut: v1[1]\l\nv1 := calldataload(3)\l\
// v3 := mload(42)\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If v3 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_2 [style="solid"];
// Block0_0Exit:1 -> Block0_1 [style="solid"];
// Block0_1 [label="\
// Block 1; (1, max 2)\nLiveIn: \l\
// LiveOut: v5[1]\l\nv5 := calldataload(77)\l\
// "];
// Block0_1 -> Block0_1Exit [arrowhead=none];
// Block0_1Exit [label="Jump" shape=oval];
// Block0_1Exit -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (2, max 2)\nLiveIn: v6[2]\l\
// LiveOut: \l\nv6 := φ(\l\
// 	Block 0 => v1,\l\
// 	Block 1 => v5\l\
// )\l\
// v7 := calldataload(v6)\l\
// sstore(0, v7)\l\
// "];
// Block0_2Exit [label="MainExit"];
// Block0_2 -> Block0_2Exit;
// }
