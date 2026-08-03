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
// Entry [label="Entry
// spilled: {}"];
// Entry -> Block0_0;
// Block0_0 [label="\
// IN: []\l\
// \l\
// [FunctionCallReturnLabel[0], lit0, lit1]\l\
// f\l\
// [v2]\l\
// \l\
// [v2, lit3]\l\
// mstore\l\
// []\l\
// \l\
// OUT: []\l\
// "];
// Block0_0Exit [label="MainExit"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_f_0 [label="function f:
//  [1 returns] := f(v0, v1)
// spilled: {}"];
// FunctionEntry_f_0 -> Block1_0;
// Block1_0 [label="\
// IN: [ReturnLabel[1], v1, v0]\l\
// \l\
// [ReturnLabel[1], v1, v0, v0]\l\
// mload\l\
// [ReturnLabel[1], v1, v0, v3]\l\
// \l\
// OUT: [ReturnLabel[1], v1, v0, v3]\l\
// "];
// Block1_0 -> Block1_0Exit;
// Block1_0Exit [label="{ If v3 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_0Exit:0 -> Block1_2 [style="solid"];
// Block1_0Exit:1 -> Block1_1 [style="solid"];
// Block1_1 [label="\
// IN: [ReturnLabel[1], JUNK, v0]\l\
// \l\
// [ReturnLabel[1], JUNK, lit4, v0]\l\
// add\l\
// [ReturnLabel[1], JUNK, v5]\l\
// \l\
// [ReturnLabel[1], JUNK, v5, v5]\l\
// revert\l\
// [ReturnLabel[1], JUNK]\l\
// \l\
// OUT: [ReturnLabel[1], JUNK]\l\
// "];
// Block1_1Exit [label="Terminated"];
// Block1_1 -> Block1_1Exit;
// Block1_2 [label="\
// IN: [ReturnLabel[1], v1, v0]\l\
// \l\
// [ReturnLabel[1], v1, v0]\l\
// add\l\
// [ReturnLabel[1], v16]\l\
// \l\
// OUT: [v16, ReturnLabel[1]]\l\
// "];
// Block1_2Exit [label="FunctionReturn[v16]"];
// Block1_2 -> Block1_2Exit;
// }
