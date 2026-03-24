{
    // a function that can continue depending on condition
    function revert_wrapper(val, condition)
    {
        if iszero(condition)
        {
            revert(val, val)
        }
        // if we don't revert, we return nothing and the stack out should contain nothing but the return label
    }

    revert_wrapper(42, 1)
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
// revert_wrapper\l\
// [FunctionCallReturnLabel[0]]\l\
// \l\
// OUT: []\l\
// "];
// Block0_0Exit [label="MainExit"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_revert_wrapper_0 [label="function revert_wrapper:
//  revert_wrapper(v0, v1)"];
// FunctionEntry_revert_wrapper_0 -> Block1_0;
// Block1_0 [label="\
// IN: [ReturnLabel[1], v1, v0]\l\
// \l\
// [ReturnLabel[1], v0, v1]\l\
// iszero\l\
// [ReturnLabel[1], v0, v2]\l\
// \l\
// OUT: [ReturnLabel[1], v0, v2]\l\
// "];
// Block1_0 -> Block1_0Exit;
// Block1_0Exit [label="{ If v2 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_0Exit:0 -> Block1_2 [style="solid"];
// Block1_0Exit:1 -> Block1_1 [style="solid"];
// Block1_1 [label="\
// IN: [ReturnLabel[1], v0]\l\
// \l\
// [ReturnLabel[1], v0, v0]\l\
// revert\l\
// [ReturnLabel[1]]\l\
// \l\
// OUT: [ReturnLabel[1]]\l\
// "];
// Block1_1Exit [label="Terminated"];
// Block1_1 -> Block1_1Exit;
// Block1_2 [label="\
// IN: [ReturnLabel[1], JUNK]\l\
// \l\
// OUT: [ReturnLabel[1]]\l\
// "];
// Block1_2Exit [label="FunctionReturn[]"];
// Block1_2 -> Block1_2Exit;
// }
