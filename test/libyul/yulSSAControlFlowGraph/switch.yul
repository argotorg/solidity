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
// Entry0 [label="Entry"];
// Entry0 -> Block0_0;
// Block0_0 [label="\
// Block 0; (0, max 5)\nLiveIn: \l\
// LiveOut: v1[1]\l\nUsed: \l\nv0 := calldataload(0x03)\l\
// v1 := sload(0x00)\l\
// v2 := eq(0x00, v1)\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If v2 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_3 [style="solid"];
// Block0_0Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (1, max 2)\nLiveIn: \l\
// LiveOut: v3[1]\l\nUsed: \l\nv3 := calldataload(0x4d)\l\
// "];
// Block0_2 -> Block0_2Exit [arrowhead=none];
// Block0_2Exit [label="Jump" shape=oval];
// Block0_2Exit -> Block0_1 [style="solid"];
// Block0_3 [label="\
// Block 3; (3, max 5)\nLiveIn: v1[1]\l\
// LiveOut: \l\nUsed: v1[1]\l\nv4 := eq(0x01, v1)\l\
// "];
// Block0_3 -> Block0_3Exit;
// Block0_3Exit [label="{ If v4 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_3Exit:0 -> Block0_5 [style="solid"];
// Block0_3Exit:1 -> Block0_4 [style="solid"];
// Block0_1 [label="\
// Block 1; (2, max 2)\nLiveIn: phi0[2]\l\
// LiveOut: \l\nUsed: phi0[2]\l\nphi0 := φ(\l\
// 	Block 2 => v3,\l\
// 	Block 4 => v5,\l\
// 	Block 5 => v6\l\
// )\l\
// sstore(0x00, phi0)\l\
// "];
// Block0_1Exit [label="MainExit"];
// Block0_1 -> Block0_1Exit;
// Block0_4 [label="\
// Block 4; (4, max 4)\nLiveIn: \l\
// LiveOut: v5[1]\l\nUsed: \l\nv5 := calldataload(0x58)\l\
// "];
// Block0_4 -> Block0_4Exit [arrowhead=none];
// Block0_4Exit [label="Jump" shape=oval];
// Block0_4Exit -> Block0_1 [style="solid"];
// Block0_5 [label="\
// Block 5; (5, max 5)\nLiveIn: \l\
// LiveOut: v6[1]\l\nUsed: \l\nv6 := calldataload(0x63)\l\
// "];
// Block0_5 -> Block0_5Exit [arrowhead=none];
// Block0_5Exit [label="Jump" shape=oval];
// Block0_5Exit -> Block0_1 [style="solid"];
// }
