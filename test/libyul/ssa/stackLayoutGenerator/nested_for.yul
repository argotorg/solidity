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
// Entry [label="Entry"];
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
// IN: [phi0, phi4]\l\
// \l\
// [phi0, phi4, lit1, phi0]\l\
// lt\l\
// [phi0, phi4, v0]\l\
// \l\
// OUT: [phi0, phi4, v0]\l\
// "];
// Block0_1 -> Block0_1Exit;
// Block0_1Exit [label="{ If v0 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_1Exit:0 -> Block0_4 [style="solid"];
// Block0_1Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// IN: [phi0, phi4]\l\
// \l\
// OUT: [phi0, phi4]\l\
// "];
// Block0_2 -> Block0_2Exit [arrowhead=none];
// Block0_2Exit [label="Jump" shape=oval];
// Block0_2Exit -> Block0_5 [style="solid"];
// Block0_4 [label="\
// IN: [JUNK, phi4]\l\
// \l\
// [JUNK, phi4, lit0]\l\
// mstore\l\
// [JUNK]\l\
// \l\
// OUT: [JUNK]\l\
// "];
// Block0_4Exit [label="MainExit"];
// Block0_4 -> Block0_4Exit;
// Block0_5 [label="\
// IN: [phi0, JUNK, phi1, phi3]\l\
// \l\
// [phi0, JUNK, phi1, phi3, lit1, phi1]\l\
// lt\l\
// [phi0, JUNK, phi1, phi3, v1]\l\
// \l\
// OUT: [phi0, JUNK, phi1, phi3, v1]\l\
// "];
// Block0_5 -> Block0_5Exit;
// Block0_5Exit [label="{ If v1 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_5Exit:0 -> Block0_8 [style="solid"];
// Block0_5Exit:1 -> Block0_6 [style="solid"];
// Block0_6 [label="\
// IN: [phi0, JUNK, phi1, phi3]\l\
// \l\
// [phi0, JUNK, phi1, phi3, phi1, phi0]\l\
// mul\l\
// [phi0, JUNK, phi1, phi3, v2]\l\
// \l\
// [phi0, JUNK, phi1, v2, phi3]\l\
// add\l\
// [phi0, JUNK, phi1, v3]\l\
// \l\
// OUT: [phi0, JUNK, phi1, v3]\l\
// "];
// Block0_6 -> Block0_6Exit [arrowhead=none];
// Block0_6Exit [label="Jump" shape=oval];
// Block0_6Exit -> Block0_7 [style="solid"];
// Block0_8 [label="\
// IN: [phi0, JUNK, JUNK, phi3]\l\
// \l\
// OUT: [phi0, JUNK, JUNK, phi3]\l\
// "];
// Block0_8 -> Block0_8Exit [arrowhead=none];
// Block0_8Exit [label="Jump" shape=oval];
// Block0_8Exit -> Block0_3 [style="solid"];
// Block0_7 [label="\
// IN: [phi0, JUNK, phi1, v3]\l\
// \l\
// [phi0, JUNK, v3, lit2, phi1]\l\
// add\l\
// [phi0, JUNK, v3, v4]\l\
// \l\
// OUT: [phi0, JUNK, v3, v4]\l\
// "];
// Block0_7 -> Block0_7Exit [arrowhead=none];
// Block0_7Exit [label="Jump" shape=oval];
// Block0_7Exit -> Block0_5 [style="solid"];
// Block0_3 [label="\
// IN: [phi0, JUNK, JUNK, phi3]\l\
// \l\
// [phi3, JUNK, JUNK, lit2, phi0]\l\
// add\l\
// [phi3, JUNK, JUNK, v5]\l\
// \l\
// OUT: [phi3, JUNK, JUNK, v5]\l\
// "];
// Block0_3 -> Block0_3Exit [arrowhead=none];
// Block0_3Exit [label="Jump" shape=oval];
// Block0_3Exit -> Block0_1 [style="solid"];
// }
