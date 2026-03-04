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
}
// ----
// digraph SSACFG {
// nodesep=0.7;
// graph[fontname="DejaVu Sans"]
// node[shape=box,fontname="DejaVu Sans"];
//
// Entry [label="Entry"];
// Entry -> Block0_0;
// Block0_0 [fillcolor="#FF746C", style=filled, label="\
// Block 0; (0, max 0)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nv0, v1 := i()\l\
// h(v0)\l\
// "];
// Block0_0Exit [label="Terminated"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_f_0 [label="function f:
//  r := f(v0, v1)"];
// FunctionEntry_f_0 -> Block1_0;
// Block1_0 [label="\
// Block 0; (0, max 0)\nLiveIn: v0[2], v1[1]\l\
// LiveOut: v3[1]\l\nUsed: v0[2], v1[1]\l\nv2 := add(v1, v0)\l\
// v3 := sub(v0, v2)\l\
// "];
// Block1_0Exit [label="FunctionReturn[v3]"];
// Block1_0 -> Block1_0Exit;
// FunctionEntry_g_0 [label="function g:
//  g()"];
// FunctionEntry_g_0 -> Block2_0;
// Block2_0 [label="\
// Block 0; (0, max 0)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nsstore(0x0101, 0x01)\l\
// "];
// Block2_0Exit [label="FunctionReturn[]"];
// Block2_0 -> Block2_0Exit;
// FunctionEntry_h_0 [label="function h:
//  h(v0)"];
// FunctionEntry_h_0 -> Block3_0;
// Block3_0 [fillcolor="#FF746C", style=filled, label="\
// Block 0; (0, max 0)\nLiveIn: v0[1]\l\
// LiveOut: \l\nUsed: v0[1]\l\nv1 := f(0x00, v0)\l\
// h(v1)\l\
// "];
// Block3_0Exit [label="Terminated"];
// Block3_0 -> Block3_0Exit;
// FunctionEntry_i_0 [label="function i:
//  v, w := i()"];
// FunctionEntry_i_0 -> Block4_0;
// Block4_0 [label="\
// Block 0; (0, max 0)\nLiveIn: \l\
// LiveOut: v0[1], v1[1]\l\nUsed: \l\nv0 := 0x0202\l\
// v1 := 0x0303\l\
// "];
// Block4_0Exit [label="FunctionReturn[v0, v1]"];
// Block4_0 -> Block4_0Exit;
// }
