{
    function sum(n) -> s {
        if n {
            s := add(n, sum(sub(n, 1)))
        }
    }
    mstore(0, sum(10))
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
// [FunctionCallReturnLabel[0], lit0]\l\
// sum\l\
// [FunctionCallReturnLabel[0], v0]\l\
// \l\
// [v0, lit1]\l\
// mstore\l\
// []\l\
// \l\
// OUT: []\l\
// "];
// Block0_0Exit [label="MainExit"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_sum_0 [label="function sum:
//  s := sum(v0)"];
// FunctionEntry_sum_0 -> Block1_0;
// Block1_0 [label="\
// IN: [v0]\l\
// \l\
// OUT: [v0, v0]\l\
// "];
// Block1_0 -> Block1_0Exit;
// Block1_0Exit [label="{ If v0 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_0Exit:0 -> Block1_2 [style="solid"];
// Block1_0Exit:1 -> Block1_1 [style="solid"];
// Block1_1 [label="\
// IN: [v0]\l\
// \l\
// [v0, lit1, v0]\l\
// sub\l\
// [v0, v1]\l\
// \l\
// [v0, FunctionCallReturnLabel[0], v1]\l\
// sum\l\
// [v0, FunctionCallReturnLabel[0], v2]\l\
// \l\
// [v2, v0]\l\
// add\l\
// [v3]\l\
// \l\
// OUT: [v3]\l\
// "];
// Block1_1 -> Block1_1Exit [arrowhead=none];
// Block1_1Exit [label="Jump" shape=oval];
// Block1_1Exit -> Block1_2 [style="solid"];
// Block1_2 [label="\
// IN: [JUNK, phi0]\l\
// \l\
// OUT: [JUNK, phi0]\l\
// "];
// Block1_2Exit [label="FunctionReturn[phi0]"];
// Block1_2 -> Block1_2Exit;
// }
