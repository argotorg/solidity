{
    function f(a, b) -> r {
        let x := add(a,b)
        r := sub(x,a)
    }
    function g() {
        sstore(0x01, 0x0101)
    }
    function h(x) {
        h(f(x, 0))
        g()
    }
    function i() -> v, w {
        v := 0x0202
        w := 0x0303
    }
    let x, y := i()
    h(x)
    h(y)
    // This call of g() is unreachable too as the one in h() but we wanna cover both cases.
    g()
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
// [FunctionCallReturnLabel[0]]\l\
// i\l\
// [v1, v2]\l\
// \l\
// [v1]\l\
// h\l\
// []\l\
// \l\
// OUT: []\l\
// "];
// Block0_0Exit [label="Terminated"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_f_0 [label="function f:
//  [1 returns] := f(v0, v1)
// spilled: {}"];
// FunctionEntry_f_0 -> Block1_0;
// Block1_0 [label="\
// IN: [ReturnLabel[1], v1, v0]\l\
// \l\
// [ReturnLabel[1], v0, v1, v0]\l\
// add\l\
// [ReturnLabel[1], v0, v3]\l\
// \l\
// [ReturnLabel[1], v0, v3]\l\
// sub\l\
// [ReturnLabel[1], v4]\l\
// \l\
// OUT: [v4, ReturnLabel[1]]\l\
// "];
// Block1_0Exit [label="FunctionReturn[v4]"];
// Block1_0 -> Block1_0Exit;
// FunctionEntry_g_0 [label="function g:
//  g()
// spilled: {}"];
// FunctionEntry_g_0 -> Block2_0;
// Block2_0 [label="\
// IN: [ReturnLabel[2]]\l\
// \l\
// [ReturnLabel[2], lit0, lit1]\l\
// sstore\l\
// [ReturnLabel[2]]\l\
// \l\
// OUT: [ReturnLabel[2]]\l\
// "];
// Block2_0Exit [label="FunctionReturn[]"];
// Block2_0 -> Block2_0Exit;
// FunctionEntry_h_0 [label="function h:
//  h(v0)
// spilled: {}"];
// FunctionEntry_h_0 -> Block3_0;
// Block3_0 [label="\
// IN: [v0]\l\
// \l\
// [FunctionCallReturnLabel[0], lit1, v0]\l\
// f\l\
// [v2]\l\
// \l\
// [v2]\l\
// h\l\
// []\l\
// \l\
// OUT: []\l\
// "];
// Block3_0Exit [label="Terminated"];
// Block3_0 -> Block3_0Exit;
// FunctionEntry_i_0 [label="function i:
//  [2 returns] := i()
// spilled: {}"];
// FunctionEntry_i_0 -> Block4_0;
// Block4_0 [label="\
// IN: [ReturnLabel[4]]\l\
// \l\
// OUT: [lit1, lit2, ReturnLabel[4]]\l\
// "];
// Block4_0Exit [label="FunctionReturn[0x0202, 0x0303]"];
// Block4_0 -> Block4_0Exit;
// }
