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
// Entry [label="Entry"];
// Entry -> Block0_0;
// Block0_0 [label="\
// IN: []\l\
// \l\
// [FunctionCallReturnLabel[0]]\l\
// i\l\
// [FunctionCallReturnLabel[0], v0, v1]\l\
// \l\
// [v0, JUNK, v0]\l\
// h\l\
// [v0, JUNK]\l\
// \l\
// OUT: [v0, JUNK]\l\
// "];
// Block0_0Exit [label="Terminated"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_f_0 [label="function f:
//  r := f(v0, v1)"];
// FunctionEntry_f_0 -> Block1_0;
// Block1_0 [label="\
// IN: [v1, v0]\l\
// \l\
// [v0, v1, v0]\l\
// add\l\
// [v0, v2]\l\
// \l\
// [v0, v2]\l\
// sub\l\
// [v3]\l\
// \l\
// OUT: [v3]\l\
// "];
// Block1_0Exit [label="FunctionReturn[v3]"];
// Block1_0 -> Block1_0Exit;
// FunctionEntry_g_0 [label="function g:
//  g()"];
// FunctionEntry_g_0 -> Block2_0;
// Block2_0 [label="\
// IN: []\l\
// \l\
// [lit0, lit1]\l\
// sstore\l\
// []\l\
// \l\
// OUT: []\l\
// "];
// Block2_0Exit [label="FunctionReturn[]"];
// Block2_0 -> Block2_0Exit;
// FunctionEntry_h_0 [label="function h:
//  h(v0)"];
// FunctionEntry_h_0 -> Block3_0;
// Block3_0 [label="\
// IN: [v0]\l\
// \l\
// [v0, FunctionCallReturnLabel[0], lit0, v0]\l\
// f\l\
// [v0, FunctionCallReturnLabel[0], v1]\l\
// \l\
// [JUNK, v1]\l\
// h\l\
// [JUNK]\l\
// \l\
// OUT: [JUNK]\l\
// "];
// Block3_0Exit [label="Terminated"];
// Block3_0 -> Block3_0Exit;
// FunctionEntry_i_0 [label="function i:
//  v, w := i()"];
// FunctionEntry_i_0 -> Block4_0;
// Block4_0 [label="\
// IN: []\l\
// \l\
// OUT: []\l\
// "];
// Block4_0Exit [label="FunctionReturn[0x0202, 0x0303]"];
// Block4_0 -> Block4_0Exit;
// }
