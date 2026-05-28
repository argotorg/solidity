{
    let x := calldataload(3)

    switch sload(0)
    case 0 {
        x := calldataload(77)
    }
    case 1 {
        x := calldataload(88)
    }
    default {
        x := calldataload(99)
    }
    sstore(x, 0)
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
// Block 0; (0, max 5)\nLiveIn: \l\
// LiveOut: v3[1]\l\nUsed: \l\nv1 := calldataload(0x03)\l\
// v3 := sload(0x00)\l\
// v4 := eq(0x00, v3)\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If v4 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_3 [style="solid"];
// Block0_0Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (1, max 2)\nLiveIn: \l\
// LiveOut: v6[1]\l\nUsed: \l\nv6 := calldataload(0x4d)\l\
// "];
// Block0_2 -> Block0_2Exit [arrowhead=none];
// Block0_2Exit [label="Jump" shape=oval];
// Block0_2Exit -> Block0_1 [style="solid"];
// Block0_3 [label="\
// Block 3; (3, max 5)\nLiveIn: v3[1]\l\
// LiveOut: \l\nUsed: v3[1]\l\nv8 := eq(0x01, v3)\l\
// "];
// Block0_3 -> Block0_3Exit;
// Block0_3Exit [label="{ If v8 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_3Exit:0 -> Block0_5 [style="solid"];
// Block0_3Exit:1 -> Block0_4 [style="solid"];
// Block0_1 [label="\
// Block 1; (2, max 2)\nLiveIn: phi13[2]\l\
// LiveOut: \l\nUsed: phi13[2]\l\nphi13 := φ(\l\
// 	Block 2 => v6,\l\
// 	Block 4 => v10,\l\
// 	Block 5 => v12\l\
// )\l\
// sstore(0x00, phi13)\l\
// "];
// Block0_1Exit [label="MainExit"];
// Block0_1 -> Block0_1Exit;
// Block0_4 [label="\
// Block 4; (4, max 4)\nLiveIn: \l\
// LiveOut: v10[1]\l\nUsed: \l\nv10 := calldataload(0x58)\l\
// "];
// Block0_4 -> Block0_4Exit [arrowhead=none];
// Block0_4Exit [label="Jump" shape=oval];
// Block0_4Exit -> Block0_1 [style="solid"];
// Block0_5 [label="\
// Block 5; (5, max 5)\nLiveIn: \l\
// LiveOut: v12[1]\l\nUsed: \l\nv12 := calldataload(0x63)\l\
// "];
// Block0_5 -> Block0_5Exit [arrowhead=none];
// Block0_5Exit [label="Jump" shape=oval];
// Block0_5Exit -> Block0_1 [style="solid"];
// }
