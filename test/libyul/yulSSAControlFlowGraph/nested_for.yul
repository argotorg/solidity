{
    for { let i := 0 } lt(i, 3) { i := add(i, 1) } {
        for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
            for { let k := 0 } lt(k, 3) { k := add(k, 1) } {
                if 0 {
                    for { let l := 0 } lt(l, 3) { l := add(l, 1) } {
                        sstore(l, add(add(i,j),k))
                    }
                }
                if 1 {
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
// LiveOut: v1\l\nv1 := 0\l\
// "];
// Block0_0 -> Block0_0Exit [arrowhead=none];
// Block0_0Exit [label="Jump" shape=oval];
// Block0_0Exit -> Block0_1 [style="solid"];
// Block0_1 [label="\
// Block 1; (1, max 24)\nLiveIn: v4\l\
// LiveOut: v4\l\nv4 := φ(\l\
// 	Block 0 => v1,\l\
// 	Block 3 => v51\l\
// )\l\
// v3 := 3\l\
// v5 := lt(v3, v4)\l\
// "];
// Block0_1 -> Block0_1Exit;
// Block0_1Exit [label="{ If v5 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_1Exit:0 -> Block0_4 [style="solid"];
// Block0_1Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (2, max 23)\nLiveIn: v4\l\
// LiveOut: v4,v6\l\nv6 := 0\l\
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
// Block 5; (3, max 23)\nLiveIn: v4,v8\l\
// LiveOut: v4,v8\l\nv8 := φ(\l\
// 	Block 2 => v6,\l\
// 	Block 7 => v49\l\
// )\l\
// v7 := 3\l\
// v9 := lt(v7, v8)\l\
// "];
// Block0_5 -> Block0_5Exit;
// Block0_5Exit [label="{ If v9 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_5Exit:0 -> Block0_8 [style="solid"];
// Block0_5Exit:1 -> Block0_6 [style="solid"];
// Block0_6 [label="\
// Block 6; (4, max 21)\nLiveIn: v4,v8\l\
// LiveOut: v4,v8,v10\l\nv10 := 0\l\
// "];
// Block0_6 -> Block0_6Exit [arrowhead=none];
// Block0_6Exit [label="Jump" shape=oval];
// Block0_6Exit -> Block0_9 [style="solid"];
// Block0_8 [label="\
// Block 8; (22, max 23)\nLiveIn: v4\l\
// LiveOut: v4\l\n"];
// Block0_8 -> Block0_8Exit [arrowhead=none];
// Block0_8Exit [label="Jump" shape=oval];
// Block0_8Exit -> Block0_3 [style="solid"];
// Block0_9 [label="\
// Block 9; (5, max 21)\nLiveIn: v4,v8,v12\l\
// LiveOut: v4,v8,v12\l\nv12 := φ(\l\
// 	Block 6 => v10,\l\
// 	Block 11 => v44\l\
// )\l\
// v11 := 3\l\
// v13 := lt(v11, v12)\l\
// "];
// Block0_9 -> Block0_9Exit;
// Block0_9Exit [label="{ If v13 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_9Exit:0 -> Block0_12 [style="solid"];
// Block0_9Exit:1 -> Block0_10 [style="solid"];
// Block0_3 [label="\
// Block 3; (23, max 23)\nLiveIn: v4\l\
// LiveOut: v51\l\nv50 := 1\l\
// v51 := add(v50, v4)\l\
// "];
// Block0_3 -> Block0_3Exit [arrowhead=none];
// Block0_3Exit [label="Jump" shape=oval];
// Block0_3Exit -> Block0_1 [style="dashed"];
// Block0_10 [label="\
// Block 10; (6, max 19)\nLiveIn: v4,v8,v12\l\
// LiveOut: v4,v8,v12\l\n"];
// Block0_10 -> Block0_10Exit;
// Block0_10Exit [label="{ If 0 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_10Exit:0 -> Block0_14 [style="solid"];
// Block0_10Exit:1 -> Block0_13 [style="solid"];
// Block0_12 [label="\
// Block 12; (20, max 21)\nLiveIn: v4,v8\l\
// LiveOut: v4,v8\l\n"];
// Block0_12 -> Block0_12Exit [arrowhead=none];
// Block0_12Exit [label="Jump" shape=oval];
// Block0_12Exit -> Block0_7 [style="solid"];
// Block0_13 [label="\
// Block 13; (7, max 19)\nLiveIn: v4,v8,v12\l\
// LiveOut: v4,v8,v12,v14\l\nv14 := 0\l\
// "];
// Block0_13 -> Block0_13Exit [arrowhead=none];
// Block0_13Exit [label="Jump" shape=oval];
// Block0_13Exit -> Block0_15 [style="solid"];
// Block0_14 [label="\
// Block 14; (12, max 19)\nLiveIn: v4,v8,v12\l\
// LiveOut: v4,v8,v12\l\n"];
// Block0_14 -> Block0_14Exit;
// Block0_14Exit [label="{ If 1 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_14Exit:0 -> Block0_20 [style="solid"];
// Block0_14Exit:1 -> Block0_19 [style="solid"];
// Block0_7 [label="\
// Block 7; (21, max 21)\nLiveIn: v4,v8\l\
// LiveOut: v4,v49\l\nv48 := 1\l\
// v49 := add(v48, v8)\l\
// "];
// Block0_7 -> Block0_7Exit [arrowhead=none];
// Block0_7Exit [label="Jump" shape=oval];
// Block0_7Exit -> Block0_5 [style="dashed"];
// Block0_15 [label="\
// Block 15; (8, max 19)\nLiveIn: v4,v8,v12,v16\l\
// LiveOut: v4,v8,v12,v16\l\nv16 := φ(\l\
// 	Block 13 => v14,\l\
// 	Block 17 => v25\l\
// )\l\
// v15 := 3\l\
// v17 := lt(v15, v16)\l\
// "];
// Block0_15 -> Block0_15Exit;
// Block0_15Exit [label="{ If v17 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_15Exit:0 -> Block0_18 [style="solid"];
// Block0_15Exit:1 -> Block0_16 [style="solid"];
// Block0_19 [label="\
// Block 19; (13, max 19)\nLiveIn: v4,v8,v12\l\
// LiveOut: v4,v8,v12,v28\l\nv28 := 0\l\
// "];
// Block0_19 -> Block0_19Exit [arrowhead=none];
// Block0_19Exit [label="Jump" shape=oval];
// Block0_19Exit -> Block0_21 [style="solid"];
// Block0_20 [label="\
// Block 20; (18, max 19)\nLiveIn: v4,v8,v12\l\
// LiveOut: v4,v8,v12\l\n"];
// Block0_20 -> Block0_20Exit [arrowhead=none];
// Block0_20Exit [label="Jump" shape=oval];
// Block0_20Exit -> Block0_11 [style="solid"];
// Block0_16 [label="\
// Block 16; (9, max 10)\nLiveIn: v4,v8,v12,v16\l\
// LiveOut: v4,v8,v12,v16\l\nv21 := add(v8, v4)\l\
// v22 := add(v12, v21)\l\
// sstore(v22, v16)\l\
// "];
// Block0_16 -> Block0_16Exit [arrowhead=none];
// Block0_16Exit [label="Jump" shape=oval];
// Block0_16Exit -> Block0_17 [style="solid"];
// Block0_18 [label="\
// Block 18; (11, max 19)\nLiveIn: v4,v8,v12\l\
// LiveOut: v4,v8,v12\l\n"];
// Block0_18 -> Block0_18Exit [arrowhead=none];
// Block0_18Exit [label="Jump" shape=oval];
// Block0_18Exit -> Block0_14 [style="solid"];
// Block0_21 [label="\
// Block 21; (14, max 19)\nLiveIn: v4,v8,v12,v30\l\
// LiveOut: v4,v8,v12,v30\l\nv30 := φ(\l\
// 	Block 19 => v28,\l\
// 	Block 23 => v38\l\
// )\l\
// v29 := 3\l\
// v31 := lt(v29, v30)\l\
// "];
// Block0_21 -> Block0_21Exit;
// Block0_21Exit [label="{ If v31 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_21Exit:0 -> Block0_24 [style="solid"];
// Block0_21Exit:1 -> Block0_22 [style="solid"];
// Block0_11 [label="\
// Block 11; (19, max 19)\nLiveIn: v4,v8,v12\l\
// LiveOut: v4,v8,v44\l\nv42 := 1\l\
// v44 := add(v42, v12)\l\
// "];
// Block0_11 -> Block0_11Exit [arrowhead=none];
// Block0_11Exit [label="Jump" shape=oval];
// Block0_11Exit -> Block0_9 [style="dashed"];
// Block0_17 [label="\
// Block 17; (10, max 10)\nLiveIn: v4,v8,v12,v16\l\
// LiveOut: v4,v8,v12,v25\l\nv24 := 1\l\
// v25 := add(v24, v16)\l\
// "];
// Block0_17 -> Block0_17Exit [arrowhead=none];
// Block0_17Exit [label="Jump" shape=oval];
// Block0_17Exit -> Block0_15 [style="dashed"];
// Block0_22 [label="\
// Block 22; (15, max 16)\nLiveIn: v4,v8,v12,v30\l\
// LiveOut: v4,v8,v12,v30\l\nv35 := add(v8, v4)\l\
// v36 := add(v12, v35)\l\
// sstore(v36, v30)\l\
// "];
// Block0_22 -> Block0_22Exit [arrowhead=none];
// Block0_22Exit [label="Jump" shape=oval];
// Block0_22Exit -> Block0_23 [style="solid"];
// Block0_24 [label="\
// Block 24; (17, max 19)\nLiveIn: v4,v8,v12\l\
// LiveOut: v4,v8,v12\l\n"];
// Block0_24 -> Block0_24Exit [arrowhead=none];
// Block0_24Exit [label="Jump" shape=oval];
// Block0_24Exit -> Block0_20 [style="solid"];
// Block0_23 [label="\
// Block 23; (16, max 16)\nLiveIn: v4,v8,v12,v30\l\
// LiveOut: v4,v8,v12,v38\l\nv37 := 1\l\
// v38 := add(v37, v30)\l\
// "];
// Block0_23 -> Block0_23Exit [arrowhead=none];
// Block0_23Exit [label="Jump" shape=oval];
// Block0_23Exit -> Block0_21 [style="dashed"];
// }
