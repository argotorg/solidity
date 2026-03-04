{
    function pair(a) -> x, y {
        x := add(a, 1)
        y := add(a, 2)
    }
    let p, q := pair(42)
    let r, s := pair(p)
    sstore(q, add(r, s))
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
// pair\l\
// [FunctionCallReturnLabel[0], v0, v1]\l\
// \l\
// [v0, v1, FunctionCallReturnLabel[1], v0]\l\
// pair\l\
// [v0, v1, FunctionCallReturnLabel[1], v2, v3]\l\
// \l\
// [JUNK, v1, v2, v3, v2]\l\
// add\l\
// [JUNK, v1, v2, v4]\l\
// \l\
// [JUNK, v1, JUNK, v4, v1]\l\
// sstore\l\
// [JUNK, v1, JUNK]\l\
// \l\
// OUT: [JUNK, v1, JUNK]\l\
// "];
// Block0_0Exit [label="MainExit"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_pair_0 [label="function pair:
//  x, y := pair(v0)"];
// FunctionEntry_pair_0 -> Block1_0;
// Block1_0 [label="\
// IN: [v0]\l\
// \l\
// [v0, lit1, v0]\l\
// add\l\
// [v0, v1]\l\
// \l\
// [v1, lit2, v0]\l\
// add\l\
// [v1, v2]\l\
// \l\
// OUT: [v1, v2]\l\
// "];
// Block1_0Exit [label="FunctionReturn[v1, v2]"];
// Block1_0 -> Block1_0Exit;
// }
