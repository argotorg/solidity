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
// Entry0 [label="Entry"];
// Entry0 -> Block0_0;
// Block0_0 [label="\
// Block 0; (0, max 2)\nLiveIn: \l\
// LiveOut: v1[1]\l\nv1 := 0\l\
// v3 := mload(42)\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If v3 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_2 [style="solid"];
// Block0_0Exit:1 -> Block0_1 [style="solid"];
// Block0_1 [label="\
// Block 1; (1, max 2)\nLiveIn: \l\
// LiveOut: v5[1]\l\nv5 := 5\l\
// "];
// Block0_1 -> Block0_1Exit [arrowhead=none];
// Block0_1Exit [label="Jump" shape=oval];
// Block0_1Exit -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (2, max 2)\nLiveIn: v6[3]\l\
// LiveOut: \l\nv6 := φ(\l\
// 	Block 0 => v1,\l\
// 	Block 1 => v5\l\
// )\l\
// sstore(v6, v6)\l\
// "];
// Block0_2Exit [label="MainExit"];
// Block0_2 -> Block0_2Exit;
// }
