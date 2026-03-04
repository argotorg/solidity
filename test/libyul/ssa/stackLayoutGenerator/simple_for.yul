{
    let x
    for {let i := 0} x {i := add(i, 1)} {
        if mload(i) {
            x := add(x, i)
            x := add(x, mload(32))
        }
    }
    mstore(x, 33)
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
// IN: [phi0, phi1]\l\
// \l\
// OUT: [phi0, phi1, phi0]\l\
// "];
// Block0_1 -> Block0_1Exit;
// Block0_1Exit [label="{ If phi0 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_1Exit:0 -> Block0_4 [style="solid"];
// Block0_1Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// IN: [phi0, phi1]\l\
// \l\
// [phi0, phi1, phi1]\l\
// mload\l\
// [phi0, phi1, v0]\l\
// \l\
// OUT: [phi0, phi1, v0]\l\
// "];
// Block0_2 -> Block0_2Exit;
// Block0_2Exit [label="{ If v0 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_2Exit:0 -> Block0_6 [style="solid"];
// Block0_2Exit:1 -> Block0_5 [style="solid"];
// Block0_4 [label="\
// IN: [phi0, JUNK]\l\
// \l\
// [phi0, JUNK, lit3, phi0]\l\
// mstore\l\
// [phi0, JUNK]\l\
// \l\
// OUT: [phi0, JUNK]\l\
// "];
// Block0_4Exit [label="MainExit"];
// Block0_4 -> Block0_4Exit;
// Block0_5 [label="\
// IN: [phi0, phi1]\l\
// \l\
// [phi1, phi1, phi0]\l\
// add\l\
// [phi1, v1]\l\
// \l\
// [phi1, v1, lit1]\l\
// mload\l\
// [phi1, v1, v2]\l\
// \l\
// [phi1, v2, v1]\l\
// add\l\
// [phi1, v3]\l\
// \l\
// OUT: [phi1, v3]\l\
// "];
// Block0_5 -> Block0_5Exit [arrowhead=none];
// Block0_5Exit [label="Jump" shape=oval];
// Block0_5Exit -> Block0_6 [style="solid"];
// Block0_6 [label="\
// IN: [phi3, phi1]\l\
// \l\
// OUT: [phi3, phi1]\l\
// "];
// Block0_6 -> Block0_6Exit [arrowhead=none];
// Block0_6Exit [label="Jump" shape=oval];
// Block0_6Exit -> Block0_3 [style="solid"];
// Block0_3 [label="\
// IN: [phi3, phi1]\l\
// \l\
// [phi3, lit2, phi1]\l\
// add\l\
// [phi3, v4]\l\
// \l\
// OUT: [phi3, v4]\l\
// "];
// Block0_3 -> Block0_3Exit [arrowhead=none];
// Block0_3Exit [label="Jump" shape=oval];
// Block0_3Exit -> Block0_1 [style="solid"];
// }
