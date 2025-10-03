{
    for { let i := 0 } lt(i, 3) { i := add(i, 1) } {
        for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            for { let k := 0 } lt(k, 3) { k := add(k, 1) } {
                if mload(0) {
                    for { let l := 0 } lt(l, 3) { l := add(l, 1) } {
                        sstore(l, add(add(i,j),k))
                    }
                }
                if mload(1) {
                    for { let l := 0 } lt(l, 3) { l := add(l, 1) } {
                        sstore(l, add(add(i,j),k))
                    }
                }
            }
        }
    }
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
// Block 0; (0, max 24)\nLiveIn: \l\
// LiveOut: v1[1]\l\nv1 := 0\l\
// "];
// Block0_0 -> Block0_0Exit [arrowhead=none];
// Block0_0Exit [label="Jump" shape=oval];
// Block0_0Exit -> Block0_1 [style="solid"];
// Block0_1 [label="\
// Block 1; (1, max 24)\nLiveIn: v3[3]\l\
// LiveOut: v3[1]\l\nv3 := φ(\l\
// 	Block 0 => v1,\l\
// 	Block 3 => v43\l\
// )\l\
// v4 := lt(3, v3)\l\
// "];
// Block0_1 -> Block0_1Exit;
// Block0_1Exit [label="{ If v4 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_1Exit:0 -> Block0_4 [style="solid"];
// Block0_1Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (2, max 23)\nLiveIn: v3[1]\l\
// LiveOut: v5[1], v3[1]\l\nv5 := 0\l\
// "];
// Block0_2 -> Block0_2Exit [arrowhead=none];
// Block0_2Exit [label="Jump" shape=oval];
// Block0_2Exit -> Block0_5 [style="solid"];
// Block0_4 [label="\
// Block 4; (24, max 24)\nLiveIn: \l\
// LiveOut: \l\n"];
// Block0_4Exit [label="MainExit"];
// Block0_4 -> Block0_4Exit;
// Block0_5 [label="\
// Block 5; (3, max 23)\nLiveIn: v6[3], v3[1]\l\
// LiveOut: v6[1], v3[1]\l\nv6 := φ(\l\
// 	Block 2 => v5,\l\
// 	Block 7 => v42\l\
// )\l\
// v7 := lt(3, v6)\l\
// "];
// Block0_5 -> Block0_5Exit;
// Block0_5Exit [label="{ If v7 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_5Exit:0 -> Block0_8 [style="solid"];
// Block0_5Exit:1 -> Block0_6 [style="solid"];
// Block0_6 [label="\
// Block 6; (4, max 21)\nLiveIn: v6[1], v3[1]\l\
// LiveOut: v8[1], v6[1], v3[1]\l\nv8 := 0\l\
// "];
// Block0_6 -> Block0_6Exit [arrowhead=none];
// Block0_6Exit [label="Jump" shape=oval];
// Block0_6Exit -> Block0_9 [style="solid"];
// Block0_8 [label="\
// Block 8; (22, max 23)\nLiveIn: v3[1]\l\
// LiveOut: v3[1]\l\n"];
// Block0_8 -> Block0_8Exit [arrowhead=none];
// Block0_8Exit [label="Jump" shape=oval];
// Block0_8Exit -> Block0_3 [style="solid"];
// Block0_9 [label="\
// Block 9; (5, max 21)\nLiveIn: v9[3], v6[1], v3[1]\l\
// LiveOut: v9[1], v6[1], v3[1]\l\nv9 := φ(\l\
// 	Block 6 => v8,\l\
// 	Block 11 => v38\l\
// )\l\
// v10 := lt(3, v9)\l\
// "];
// Block0_9 -> Block0_9Exit;
// Block0_9Exit [label="{ If v10 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_9Exit:0 -> Block0_12 [style="solid"];
// Block0_9Exit:1 -> Block0_10 [style="solid"];
// Block0_3 [label="\
// Block 3; (23, max 23)\nLiveIn: v3[1]\l\
// LiveOut: v43[1]\l\nv43 := add(1, v3)\l\
// "];
// Block0_3 -> Block0_3Exit [arrowhead=none];
// Block0_3Exit [label="Jump" shape=oval];
// Block0_3Exit -> Block0_1 [style="dashed"];
// Block0_10 [label="\
// Block 10; (6, max 19)\nLiveIn: v9[1], v6[1], v3[1]\l\
// LiveOut: v9[1], v6[1], v3[1]\l\nv11 := mload(0)\l\
// "];
// Block0_10 -> Block0_10Exit;
// Block0_10Exit [label="{ If v11 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_10Exit:0 -> Block0_14 [style="solid"];
// Block0_10Exit:1 -> Block0_13 [style="solid"];
// Block0_12 [label="\
// Block 12; (20, max 21)\nLiveIn: v6[1], v3[1]\l\
// LiveOut: v6[1], v3[1]\l\n"];
// Block0_12 -> Block0_12Exit [arrowhead=none];
// Block0_12Exit [label="Jump" shape=oval];
// Block0_12Exit -> Block0_7 [style="solid"];
// Block0_13 [label="\
// Block 13; (7, max 19)\nLiveIn: v9[1], v6[1], v3[1]\l\
// LiveOut: v12[1], v9[1], v6[1], v3[1]\l\nv12 := 0\l\
// "];
// Block0_13 -> Block0_13Exit [arrowhead=none];
// Block0_13Exit [label="Jump" shape=oval];
// Block0_13Exit -> Block0_15 [style="solid"];
// Block0_14 [label="\
// Block 14; (12, max 19)\nLiveIn: v9[1], v6[1], v3[1]\l\
// LiveOut: v9[1], v6[1], v3[1]\l\nv24 := mload(1)\l\
// "];
// Block0_14 -> Block0_14Exit;
// Block0_14Exit [label="{ If v24 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_14Exit:0 -> Block0_20 [style="solid"];
// Block0_14Exit:1 -> Block0_19 [style="solid"];
// Block0_7 [label="\
// Block 7; (21, max 21)\nLiveIn: v6[1], v3[1]\l\
// LiveOut: v42[1], v3[1]\l\nv42 := add(1, v6)\l\
// "];
// Block0_7 -> Block0_7Exit [arrowhead=none];
// Block0_7Exit [label="Jump" shape=oval];
// Block0_7Exit -> Block0_5 [style="dashed"];
// Block0_15 [label="\
// Block 15; (8, max 19)\nLiveIn: v13[4], v9[1], v6[1], v3[1]\l\
// LiveOut: v13[2], v9[1], v6[1], v3[1]\l\nv13 := φ(\l\
// 	Block 13 => v12,\l\
// 	Block 17 => v21\l\
// )\l\
// v14 := lt(3, v13)\l\
// "];
// Block0_15 -> Block0_15Exit;
// Block0_15Exit [label="{ If v14 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_15Exit:0 -> Block0_18 [style="solid"];
// Block0_15Exit:1 -> Block0_16 [style="solid"];
// Block0_19 [label="\
// Block 19; (13, max 19)\nLiveIn: v9[1], v6[1], v3[1]\l\
// LiveOut: v25[1], v9[1], v6[1], v3[1]\l\nv25 := 0\l\
// "];
// Block0_19 -> Block0_19Exit [arrowhead=none];
// Block0_19Exit [label="Jump" shape=oval];
// Block0_19Exit -> Block0_21 [style="solid"];
// Block0_20 [label="\
// Block 20; (18, max 19)\nLiveIn: v9[1], v6[1], v3[1]\l\
// LiveOut: v9[1], v6[1], v3[1]\l\n"];
// Block0_20 -> Block0_20Exit [arrowhead=none];
// Block0_20Exit [label="Jump" shape=oval];
// Block0_20Exit -> Block0_11 [style="solid"];
// Block0_16 [label="\
// Block 16; (9, max 10)\nLiveIn: v13[2], v9[1], v6[1], v3[1]\l\
// LiveOut: v13[1], v9[1], v6[1], v3[1]\l\nv18 := add(v6, v3)\l\
// v19 := add(v9, v18)\l\
// sstore(v19, v13)\l\
// "];
// Block0_16 -> Block0_16Exit [arrowhead=none];
// Block0_16Exit [label="Jump" shape=oval];
// Block0_16Exit -> Block0_17 [style="solid"];
// Block0_18 [label="\
// Block 18; (11, max 19)\nLiveIn: v9[1], v6[1], v3[1]\l\
// LiveOut: v9[1], v6[1], v3[1]\l\n"];
// Block0_18 -> Block0_18Exit [arrowhead=none];
// Block0_18Exit [label="Jump" shape=oval];
// Block0_18Exit -> Block0_14 [style="solid"];
// Block0_21 [label="\
// Block 21; (14, max 19)\nLiveIn: v26[4], v9[1], v6[1], v3[1]\l\
// LiveOut: v26[2], v9[1], v6[1], v3[1]\l\nv26 := φ(\l\
// 	Block 19 => v25,\l\
// 	Block 23 => v33\l\
// )\l\
// v27 := lt(3, v26)\l\
// "];
// Block0_21 -> Block0_21Exit;
// Block0_21Exit [label="{ If v27 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_21Exit:0 -> Block0_24 [style="solid"];
// Block0_21Exit:1 -> Block0_22 [style="solid"];
// Block0_11 [label="\
// Block 11; (19, max 19)\nLiveIn: v9[1], v6[1], v3[1]\l\
// LiveOut: v38[1], v6[1], v3[1]\l\nv38 := add(1, v9)\l\
// "];
// Block0_11 -> Block0_11Exit [arrowhead=none];
// Block0_11Exit [label="Jump" shape=oval];
// Block0_11Exit -> Block0_9 [style="dashed"];
// Block0_17 [label="\
// Block 17; (10, max 10)\nLiveIn: v13[1], v9[1], v6[1], v3[1]\l\
// LiveOut: v21[1], v9[1], v6[1], v3[1]\l\nv21 := add(1, v13)\l\
// "];
// Block0_17 -> Block0_17Exit [arrowhead=none];
// Block0_17Exit [label="Jump" shape=oval];
// Block0_17Exit -> Block0_15 [style="dashed"];
// Block0_22 [label="\
// Block 22; (15, max 16)\nLiveIn: v26[2], v9[1], v6[1], v3[1]\l\
// LiveOut: v26[1], v9[1], v6[1], v3[1]\l\nv31 := add(v6, v3)\l\
// v32 := add(v9, v31)\l\
// sstore(v32, v26)\l\
// "];
// Block0_22 -> Block0_22Exit [arrowhead=none];
// Block0_22Exit [label="Jump" shape=oval];
// Block0_22Exit -> Block0_23 [style="solid"];
// Block0_24 [label="\
// Block 24; (17, max 19)\nLiveIn: v9[1], v6[1], v3[1]\l\
// LiveOut: v9[1], v6[1], v3[1]\l\n"];
// Block0_24 -> Block0_24Exit [arrowhead=none];
// Block0_24Exit [label="Jump" shape=oval];
// Block0_24Exit -> Block0_20 [style="solid"];
// Block0_23 [label="\
// Block 23; (16, max 16)\nLiveIn: v26[1], v9[1], v6[1], v3[1]\l\
// LiveOut: v33[1], v9[1], v6[1], v3[1]\l\nv33 := add(1, v26)\l\
// "];
// Block0_23 -> Block0_23Exit [arrowhead=none];
// Block0_23Exit [label="Jump" shape=oval];
// Block0_23Exit -> Block0_21 [style="dashed"];
// }
