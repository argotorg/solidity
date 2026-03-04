{
    function f(a, b) -> c {
        if mload(a) {
            a := add(a, 2)
            revert(a, a)
        }
        c := add(a, b)
    }
    mstore(42, f(0, 1))
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
// [FunctionCallReturnLabel[0], lit0, lit1]\l\
// f\l\
// [FunctionCallReturnLabel[0], v0]\l\
// \l\
// [v0, lit2]\l\
// mstore\l\
// []\l\
// \l\
// OUT: []\l\
// "];
// Block0_0Exit [label="MainExit"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_f_0 [label="function f:
//  c := f(v0, v1)"];
// FunctionEntry_f_0 -> Block1_0;
// Block1_0 [label="\
// IN: [v1, v0]\l\
// \l\
// [v1, v0, v0]\l\
// mload\l\
// [v1, v0, v2]\l\
// \l\
// OUT: [v1, v0, v2]\l\
// "];
// Block1_0 -> Block1_0Exit;
// Block1_0Exit [label="{ If v2 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_0Exit:0 -> Block1_2 [style="solid"];
// Block1_0Exit:1 -> Block1_1 [style="solid"];
// Block1_1 [label="\
// IN: [v1, v0]\l\
// \l\
// [JUNK, v0, lit1, v0]\l\
// add\l\
// [JUNK, v0, v3]\l\
// \l\
// [JUNK, JUNK, v3, v3]\l\
// revert\l\
// [JUNK, JUNK]\l\
// \l\
// OUT: [JUNK, JUNK]\l\
// "];
// Block1_1Exit [label="Terminated"];
// Block1_1 -> Block1_1Exit;
// Block1_2 [label="\
// IN: [v1, v0]\l\
// \l\
// [v1, v0]\l\
// add\l\
// [v4]\l\
// \l\
// OUT: [v4]\l\
// "];
// Block1_2Exit [label="FunctionReturn[v4]"];
// Block1_2 -> Block1_2Exit;
// }
