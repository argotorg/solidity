{
    let x := calldataload(0)
    if x {
        revert(0, 0)
    }
    let y := calldataload(32)
    if y {
        revert(0, 0)
    }
    sstore(x, y)
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
// calldataload\l\
// [v0]\l\
// \l\
// OUT: [v0, v0]\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If v0 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_2 [style="solid"];
// Block0_0Exit:1 -> Block0_1 [style="solid"];
// Block0_1 [label="\
// IN: [v0]\l\
// \l\
// [JUNK, lit0, lit0]\l\
// revert\l\
// [JUNK]\l\
// \l\
// OUT: [JUNK]\l\
// "];
// Block0_1Exit [label="Terminated"];
// Block0_1 -> Block0_1Exit;
// Block0_2 [label="\
// IN: [v0]\l\
// \l\
// [v0, lit1]\l\
// calldataload\l\
// [v0, v1]\l\
// \l\
// OUT: [v0, v1, v1]\l\
// "];
// Block0_2 -> Block0_2Exit;
// Block0_2Exit [label="{ If v1 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_2Exit:0 -> Block0_5 [style="solid"];
// Block0_2Exit:1 -> Block0_4 [style="solid"];
// Block0_4 [label="\
// IN: [v0, v1]\l\
// \l\
// [JUNK, JUNK, lit0, lit0]\l\
// revert\l\
// [JUNK, JUNK]\l\
// \l\
// OUT: [JUNK, JUNK]\l\
// "];
// Block0_4Exit [label="Terminated"];
// Block0_4 -> Block0_4Exit;
// Block0_5 [label="\
// IN: [v0, v1]\l\
// \l\
// [v0, v1, v0]\l\
// sstore\l\
// [v0]\l\
// \l\
// OUT: [v0]\l\
// "];
// Block0_5Exit [label="MainExit"];
// Block0_5 -> Block0_5Exit;
// }
