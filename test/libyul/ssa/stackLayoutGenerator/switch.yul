{
    let x := 0x0101
    let y := 0x0202
    let z := 0x0303
    switch sload(x)
    case 0 {
        x := 0x42
    }
    case 1 {
        y := 0x42
    }
    default {
        sstore(z, z)
    }

    sstore(0x0404, y)
}
// ----
// digraph SSACFG {
// nodesep=0.7;
// graph[fontname="DejaVu Sans", rankdir=LR]
// node[shape=box,fontname="DejaVu Sans"];
//
// Entry [label="Entry"];
// Entry -> Block0_0;
// Block0_0 [label="\
// IN: []\l\
// \l\
// [lit0]\l\
// sload\l\
// [v0]\l\
// \l\
// [v0, lit3, v0]\l\
// eq\l\
// [v0, v1]\l\
// \l\
// OUT: [v0, v1]\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If v1 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_3 [style="solid"];
// Block0_0Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// IN: [v0]\l\
// \l\
// OUT: [v0]\l\
// "];
// Block0_2 -> Block0_2Exit [arrowhead=none];
// Block0_2Exit [label="Jump" shape=oval];
// Block0_2Exit -> Block0_1 [style="solid"];
// Block0_3 [label="\
// IN: [v0]\l\
// \l\
// [lit5, v0]\l\
// eq\l\
// [v2]\l\
// \l\
// OUT: [v2]\l\
// "];
// Block0_3 -> Block0_3Exit;
// Block0_3Exit [label="{ If v2 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_3Exit:0 -> Block0_5 [style="solid"];
// Block0_3Exit:1 -> Block0_4 [style="solid"];
// Block0_1 [label="\
// IN: [JUNK, phi0]\l\
// \l\
// [JUNK, phi0, lit6]\l\
// sstore\l\
// [JUNK]\l\
// \l\
// OUT: [JUNK]\l\
// "];
// Block0_1Exit [label="MainExit"];
// Block0_1 -> Block0_1Exit;
// Block0_4 [label="\
// IN: []\l\
// \l\
// OUT: []\l\
// "];
// Block0_4 -> Block0_4Exit [arrowhead=none];
// Block0_4Exit [label="Jump" shape=oval];
// Block0_4Exit -> Block0_1 [style="solid"];
// Block0_5 [label="\
// IN: []\l\
// \l\
// [lit2, lit2]\l\
// sstore\l\
// []\l\
// \l\
// OUT: []\l\
// "];
// Block0_5 -> Block0_5Exit [arrowhead=none];
// Block0_5Exit [label="Jump" shape=oval];
// Block0_5Exit -> Block0_1 [style="solid"];
// }
