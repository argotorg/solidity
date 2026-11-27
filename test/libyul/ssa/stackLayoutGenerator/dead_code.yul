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
// Entry [label="Entry
// spilled: {}"];
// Entry -> Block0_0;
// Block0_0 [label="\
// IN: []\l\
// \l\
// [lit0]\l\
// calldataload\l\
// [v1]\l\
// \l\
// OUT: [v1, v1]\l\
// "];
// Block0_0 -> Block0_0Exit;
// Block0_0Exit [label="{ If v1 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_0Exit:0 -> Block0_2 [style="solid"];
// Block0_0Exit:1 -> Block0_1 [style="solid"];
// Block0_1 [label="\
// IN: [JUNK]\l\
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
// IN: [v1]\l\
// \l\
// [v1, lit3]\l\
// calldataload\l\
// [v1, v4]\l\
// \l\
// OUT: [v1, v4, v4]\l\
// "];
// Block0_2 -> Block0_2Exit;
// Block0_2Exit [label="{ If v4 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_2Exit:0 -> Block0_4 [style="solid"];
// Block0_2Exit:1 -> Block0_3 [style="solid"];
// Block0_3 [label="\
// IN: [JUNK, JUNK]\l\
// \l\
// [JUNK, JUNK, lit0, lit0]\l\
// revert\l\
// [JUNK, JUNK]\l\
// \l\
// OUT: [JUNK, JUNK]\l\
// "];
// Block0_3Exit [label="Terminated"];
// Block0_3 -> Block0_3Exit;
// Block0_4 [label="\
// IN: [v1, v4]\l\
// \l\
// [v4, v1]\l\
// sstore\l\
// []\l\
// \l\
// OUT: []\l\
// "];
// Block0_4Exit [label="MainExit"];
// Block0_4 -> Block0_4Exit;
// }
