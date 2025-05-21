{
    let x := calldataload(3)
    if 0 {
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
// LiveOut: v2\l\nv1 := 3\l\
// v2 := calldataload(v1)\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If 0 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_2 [style="solid"];
// Block0_0Exit:1 -> Block0_1 [style="solid"];
// Block0_1 [label="\
// Block 1; (1, max 2)\nLiveIn: \l\
// LiveOut: v6\l\nv5 := 77\l\
// v6 := calldataload(v5)\l\
// "];
// Block0_1 -> Block0_1Exit [arrowhead=none];
// Block0_1Exit [label="Jump" shape=oval];
// Block0_1Exit -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (2, max 2)\nLiveIn: v7\l\
// LiveOut: \l\nv7 := φ(\l\
// 	Block 0 => v2,\l\
// 	Block 1 => v6\l\
// )\l\
// v8 := calldataload(v7)\l\
// v9 := 0\l\
// sstore(v9, v8)\l\
// "];
// Block0_2Exit [label="MainExit"];
// Block0_2 -> Block0_2Exit;
// }
