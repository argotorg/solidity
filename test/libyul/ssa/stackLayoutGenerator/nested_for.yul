{
    let s
    for {let i := 0} lt(i, 10) {i := add(i, 1)} {
        for {let j := 0} lt(j, 10) {j := add(j, 1)} {
            s := add(s, mul(i, j))
        }
    }
    mstore(0, s)
}
// ----
// digraph SSACFG {
// nodesep=0.7;
// graph[fontname="DejaVu Sans", rankdir=LR]
// node[shape=box,fontname="DejaVu Sans"];
//
// Entry [label="Entry
// spilled: {}"];
// Entry -> Block0_0;
// Block0_0 [label="\
// IN: []\l\
// \l\
// OUT: []\l\
// "];
// Block0_0 -> Block0_0Exit [arrowhead=none];
// Block0_0Exit [label="Jump" shape=oval];
// Block0_0Exit -> Block0_1 [style="solid"];
// Block0_1 [label="\
// IN: [phi2, phi16]\l\
// \l\
// [phi2, phi16, lit1, phi2]\l\
// lt\l\
// [phi2, phi16, v3]\l\
// \l\
// OUT: [phi2, phi16, v3]\l\
// "];
// Block0_1 -> Block0_1Exit;
// Block0_1Exit [label="{ If v3 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_1Exit:0 -> Block0_4 [style="solid"];
// Block0_1Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// IN: [phi2, phi16]\l\
// \l\
// OUT: [phi2, phi16]\l\
// "];
// Block0_2 -> Block0_2Exit [arrowhead=none];
// Block0_2Exit [label="Jump" shape=oval];
// Block0_2Exit -> Block0_5 [style="solid"];
// Block0_4 [label="\
// IN: [JUNK, phi16]\l\
// \l\
// [JUNK, phi16, lit0]\l\
// mstore\l\
// [JUNK]\l\
// \l\
// OUT: [JUNK]\l\
// "];
// Block0_4Exit [label="MainExit"];
// Block0_4 -> Block0_4Exit;
// Block0_5 [label="\
// IN: [phi2, phi8, phi4]\l\
// \l\
// [phi2, phi8, phi4, lit1, phi4]\l\
// lt\l\
// [phi2, phi8, phi4, v5]\l\
// \l\
// OUT: [phi2, phi8, phi4, v5]\l\
// "];
// Block0_5 -> Block0_5Exit;
// Block0_5Exit [label="{ If v5 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_5Exit:0 -> Block0_8 [style="solid"];
// Block0_5Exit:1 -> Block0_6 [style="solid"];
// Block0_6 [label="\
// IN: [phi2, phi8, phi4]\l\
// \l\
// [phi2, phi8, phi4, phi4, phi2]\l\
// mul\l\
// [phi2, phi8, phi4, v7]\l\
// \l\
// [phi2, phi4, v7, phi8]\l\
// add\l\
// [phi2, phi4, v9]\l\
// \l\
// OUT: [phi2, phi4, v9]\l\
// "];
// Block0_6 -> Block0_6Exit [arrowhead=none];
// Block0_6Exit [label="Jump" shape=oval];
// Block0_6Exit -> Block0_7 [style="solid"];
// Block0_8 [label="\
// IN: [phi2, phi8, JUNK]\l\
// \l\
// OUT: [phi2, phi8, JUNK]\l\
// "];
// Block0_8 -> Block0_8Exit [arrowhead=none];
// Block0_8Exit [label="Jump" shape=oval];
// Block0_8Exit -> Block0_3 [style="solid"];
// Block0_7 [label="\
// IN: [phi2, phi4, v9]\l\
// \l\
// [phi2, v9, lit10, phi4]\l\
// add\l\
// [phi2, v9, v11]\l\
// \l\
// OUT: [phi2, v9, v11]\l\
// "];
// Block0_7 -> Block0_7Exit [arrowhead=none];
// Block0_7Exit [label="Jump" shape=oval];
// Block0_7Exit -> Block0_5 [style="solid"];
// Block0_3 [label="\
// IN: [phi2, phi8, JUNK]\l\
// \l\
// [phi2, phi8, lit10, phi2]\l\
// add\l\
// [phi2, phi8, v19]\l\
// \l\
// OUT: [phi2, phi8, v19]\l\
// "];
// Block0_3 -> Block0_3Exit [arrowhead=none];
// Block0_3Exit [label="Jump" shape=oval];
// Block0_3Exit -> Block0_1 [style="solid"];
// }
