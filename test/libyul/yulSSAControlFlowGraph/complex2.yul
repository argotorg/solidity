{
    function f(a, b) -> c {
        for { let x := 42 } lt(x, a) {
            x := add(x, 1)
            if calldataload(x)
            {
                sstore(0, x)
                leave
                sstore(0x01, 0x0101)
            }
            sstore(0xFF, 0xFFFF)
        }
        {
            switch mload(x)
            case 0 {
                sstore(0x02, 0x0202)
                break
                sstore(0x03, 0x0303)
            }
            case 1 {
                sstore(0x04, 0x0404)
                leave
                sstore(0x05, 0x0505)
            }
            case 2 {
                sstore(0x06, 0x0606)
                revert(0, 0)
                sstore(0x07, 0x0707)
            }
            case 3 {
                sstore(0x08, 0x0808)
            }
            default {
                if mload(b) {
                    return(0, 0)
                    sstore(0x09, 0x0909)
                }
                    sstore(0x0A, 0x0A0A)
            }
            sstore(0x0B, 0x0B0B)
        }
        sstore(0x0C, 0x0C0C)
        c:=27
    }
    sstore(0x1,0x1)
    pop(f(1,2))
    let z:= add(5,sload(0))
    let w := f(z,sload(4))
    sstore(z,w)
    let x := f(w,sload(5))
    sstore(0x1,x)
}
// ----
// digraph SSACFG {
// nodesep=0.7;
// graph[fontname="DejaVu Sans"]
// node[shape=box,fontname="DejaVu Sans"];
//
// Entry0 [label="Entry"];
// Entry0 -> Block0_0;
// Block0_0 [label="\
// Block 0; (0, max 0)\nLiveIn: \l\
// LiveOut: \l\nv1 := 1\l\
// v2 := 1\l\
// sstore(v1, v2)\l\
// v4 := 2\l\
// v5 := 1\l\
// v6 := f(v4, v5)\l\
// pop(v6)\l\
// v8 := 0\l\
// v9 := sload(v8)\l\
// v11 := 5\l\
// v12 := add(v9, v11)\l\
// v14 := 4\l\
// v15 := sload(v14)\l\
// v16 := f(v15, v12)\l\
// sstore(v16, v12)\l\
// v17 := 5\l\
// v18 := sload(v17)\l\
// v19 := f(v18, v16)\l\
// v20 := 1\l\
// sstore(v19, v20)\l\
// "];
// Block0_0Exit [label="MainExit"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_f_0 [label="function f:
//  c := f(v0, v1)"];
// FunctionEntry_f_0 -> Block1_0;
// Block1_0 [label="\
// Block 0; (0, max 17)\nLiveIn: v0,v1\l\
// LiveOut: v0,v1,v4\l\nv4 := 42\l\
// "];
// Block1_0 -> Block1_0Exit [arrowhead=none];
// Block1_0Exit [label="Jump" shape=oval];
// Block1_0Exit -> Block1_1 [style="solid"];
// Block1_1 [label="\
// Block 1; (1, max 17)\nLiveIn: v0,v1,v6\l\
// LiveOut: v0,v1,v6\l\nv6 := φ(\l\
// 	Block 0 => v4,\l\
// 	Block 21 => v69\l\
// )\l\
// v7 := lt(v0, v6)\l\
// "];
// Block1_1 -> Block1_1Exit;
// Block1_1Exit [label="{ If v7 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_1Exit:0 -> Block1_4 [style="solid"];
// Block1_1Exit:1 -> Block1_2 [style="solid"];
// Block1_2 [label="\
// Block 2; (2, max 17)\nLiveIn: v0,v1,v6\l\
// LiveOut: v0,v1,v6,v8\l\nv8 := mload(v6)\l\
// v9 := eq(0, v8)\l\
// "];
// Block1_2 -> Block1_2Exit;
// Block1_2Exit [label="{ If v9 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_2Exit:0 -> Block1_7 [style="solid"];
// Block1_2Exit:1 -> Block1_6 [style="solid"];
// Block1_4 [label="\
// Block 4; (4, max 4)\nLiveIn: \l\
// LiveOut: v110\l\nv106 := 3084\l\
// v108 := 12\l\
// sstore(v106, v108)\l\
// v110 := 27\l\
// "];
// Block1_4Exit [label="FunctionReturn[v110]"];
// Block1_4 -> Block1_4Exit;
// Block1_6 [label="\
// Block 6; (3, max 4)\nLiveIn: \l\
// LiveOut: \l\nv11 := 514\l\
// v13 := 2\l\
// sstore(v11, v13)\l\
// "];
// Block1_6 -> Block1_6Exit [arrowhead=none];
// Block1_6Exit [label="Jump" shape=oval];
// Block1_6Exit -> Block1_4 [style="solid"];
// Block1_7 [label="\
// Block 7; (5, max 17)\nLiveIn: v0,v1,v6,v8\l\
// LiveOut: v0,v1,v6,v8\l\nv18 := eq(1, v8)\l\
// "];
// Block1_7 -> Block1_7Exit;
// Block1_7Exit [label="{ If v18 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_7Exit:0 -> Block1_10 [style="solid"];
// Block1_7Exit:1 -> Block1_9 [style="solid"];
// Block1_9 [label="\
// Block 9; (6, max 6)\nLiveIn: \l\
// LiveOut: \l\nv21 := 1028\l\
// v23 := 4\l\
// sstore(v21, v23)\l\
// "];
// Block1_9Exit [label="FunctionReturn[0]"];
// Block1_9 -> Block1_9Exit;
// Block1_10 [label="\
// Block 10; (7, max 17)\nLiveIn: v0,v1,v6,v8\l\
// LiveOut: v0,v1,v6,v8\l\nv29 := eq(2, v8)\l\
// "];
// Block1_10 -> Block1_10Exit;
// Block1_10Exit [label="{ If v29 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_10Exit:0 -> Block1_13 [style="solid"];
// Block1_10Exit:1 -> Block1_12 [style="solid"];
// Block1_12 [label="\
// Block 12; (8, max 8)\nLiveIn: \l\
// LiveOut: \l\nv31 := 1542\l\
// v33 := 6\l\
// sstore(v31, v33)\l\
// v34 := 0\l\
// v35 := 0\l\
// revert(v34, v35)\l\
// "];
// Block1_12Exit [label="Terminated"];
// Block1_12 -> Block1_12Exit;
// Block1_13 [label="\
// Block 13; (9, max 17)\nLiveIn: v0,v1,v6,v8\l\
// LiveOut: v0,v1,v6\l\nv40 := eq(3, v8)\l\
// "];
// Block1_13 -> Block1_13Exit;
// Block1_13Exit [label="{ If v40 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_13Exit:0 -> Block1_16 [style="solid"];
// Block1_13Exit:1 -> Block1_15 [style="solid"];
// Block1_15 [label="\
// Block 15; (10, max 14)\nLiveIn: v0,v1,v6\l\
// LiveOut: v0,v1,v6\l\nv42 := 2056\l\
// v44 := 8\l\
// sstore(v42, v44)\l\
// "];
// Block1_15 -> Block1_15Exit [arrowhead=none];
// Block1_15Exit [label="Jump" shape=oval];
// Block1_15Exit -> Block1_5 [style="solid"];
// Block1_16 [label="\
// Block 16; (15, max 17)\nLiveIn: v0,v1,v6\l\
// LiveOut: v0,v1,v6\l\nv46 := mload(v1)\l\
// "];
// Block1_16 -> Block1_16Exit;
// Block1_16Exit [label="{ If v46 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_16Exit:0 -> Block1_18 [style="solid"];
// Block1_16Exit:1 -> Block1_17 [style="solid"];
// Block1_5 [label="\
// Block 5; (11, max 14)\nLiveIn: v0,v1,v6\l\
// LiveOut: v0,v1,v6\l\nv58 := 2827\l\
// v60 := 11\l\
// sstore(v58, v60)\l\
// "];
// Block1_5 -> Block1_5Exit [arrowhead=none];
// Block1_5Exit [label="Jump" shape=oval];
// Block1_5Exit -> Block1_3 [style="solid"];
// Block1_17 [label="\
// Block 17; (16, max 16)\nLiveIn: \l\
// LiveOut: \l\nv47 := 0\l\
// v48 := 0\l\
// return(v47, v48)\l\
// "];
// Block1_17Exit [label="Terminated"];
// Block1_17 -> Block1_17Exit;
// Block1_18 [label="\
// Block 18; (17, max 17)\nLiveIn: v0,v1,v6\l\
// LiveOut: v0,v1,v6\l\nv54 := 2570\l\
// v56 := 10\l\
// sstore(v54, v56)\l\
// "];
// Block1_18 -> Block1_18Exit [arrowhead=none];
// Block1_18Exit [label="Jump" shape=oval];
// Block1_18Exit -> Block1_5 [style="solid"];
// Block1_3 [label="\
// Block 3; (12, max 14)\nLiveIn: v0,v1,v6\l\
// LiveOut: v0,v1,v69\l\nv61 := 1\l\
// v69 := add(v61, v6)\l\
// v70 := calldataload(v69)\l\
// "];
// Block1_3 -> Block1_3Exit;
// Block1_3Exit [label="{ If v70 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_3Exit:0 -> Block1_21 [style="solid"];
// Block1_3Exit:1 -> Block1_20 [style="solid"];
// Block1_20 [label="\
// Block 20; (13, max 13)\nLiveIn: v69\l\
// LiveOut: \l\nv71 := 0\l\
// sstore(v69, v71)\l\
// "];
// Block1_20Exit [label="FunctionReturn[0]"];
// Block1_20 -> Block1_20Exit;
// Block1_21 [label="\
// Block 21; (14, max 14)\nLiveIn: v0,v1,v69\l\
// LiveOut: v0,v1,v69\l\nv82 := 65535\l\
// v84 := 255\l\
// sstore(v82, v84)\l\
// "];
// Block1_21 -> Block1_21Exit [arrowhead=none];
// Block1_21Exit [label="Jump" shape=oval];
// Block1_21Exit -> Block1_1 [style="dashed"];
// }
