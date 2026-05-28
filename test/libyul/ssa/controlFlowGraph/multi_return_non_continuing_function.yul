{
    function reverter() -> a, b { revert(0, 0) }
    // the cfg should reflect that reverter has two output variables although it cannot continue
    let x, y := reverter()
    sstore(x, y)
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
// LiveOut: \l\nUsed: \l\nv0 := reverter()\l\
// v1 := v0.proj(0)\l\
// v2 := v0.proj(1)\l\
// "];
// Block0_0Exit [label="Terminated"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_reverter_0 [label="function reverter:
//  [2 returns] := reverter()"];
// FunctionEntry_reverter_0 -> Block1_0;
// Block1_0 [fillcolor="#FF746C", style=filled, label="\
// Block 0; (0, max 0)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nrevert(0x00, 0x00)\l\
// "];
// Block1_0Exit [label="Terminated"];
// Block1_0 -> Block1_0Exit;
// }
