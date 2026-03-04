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
// Entry [label="Entry"];
// Entry -> Block0_0;
// Block0_0 [fillcolor="#FF746C", style=filled, label="\
// Block 0; (0, max 24)\nLiveIn: \l\
// LiveOut: v0[1]\l\nUsed: \l\nv0 := 0x00\l\
// "];
// Block0_0 -> Block0_0Exit [arrowhead=none];
// Block0_0Exit [label="Jump" shape=oval];
// Block0_0Exit -> Block0_1 [style="solid"];
// Block0_1 [fillcolor="#FF746C", style=filled, label="\
// Block 1; (1, max 24)\nLiveIn: phi0[3]\l\
// LiveOut: phi0[1]\l\nUsed: phi0[2]\l\nphi0 := φ(\l\
// 	Block 0 => v0,\l\
// 	Block 3 => v20\l\
// )\l\
// v1 := lt(0x03, phi0)\l\
// "];
// Block0_1 -> Block0_1Exit;
// Block0_1Exit [label="{ If v1 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_1Exit:0 -> Block0_4 [style="solid"];
// Block0_1Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (2, max 23)\nLiveIn: phi0[1]\l\
// LiveOut: v2[1], phi0[1]\l\nUsed: \l\nv2 := 0x00\l\
// "];
// Block0_2 -> Block0_2Exit [arrowhead=none];
// Block0_2Exit [label="Jump" shape=oval];
// Block0_2Exit -> Block0_5 [style="solid"];
// Block0_4 [fillcolor="#FF746C", style=filled, label="\
// Block 4; (24, max 24)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\n"];
// Block0_4Exit [label="MainExit"];
// Block0_4 -> Block0_4Exit;
// Block0_5 [label="\
// Block 5; (3, max 23)\nLiveIn: phi1[3], phi0[1]\l\
// LiveOut: phi1[1], phi0[1]\l\nUsed: phi1[2]\l\nphi1 := φ(\l\
// 	Block 2 => v2,\l\
// 	Block 7 => v19\l\
// )\l\
// v3 := lt(0x03, phi1)\l\
// "];
// Block0_5 -> Block0_5Exit;
// Block0_5Exit [label="{ If v3 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_5Exit:0 -> Block0_8 [style="solid"];
// Block0_5Exit:1 -> Block0_6 [style="solid"];
// Block0_6 [label="\
// Block 6; (4, max 21)\nLiveIn: phi1[1], phi0[1]\l\
// LiveOut: v4[1], phi1[1], phi0[1]\l\nUsed: \l\nv4 := 0x00\l\
// "];
// Block0_6 -> Block0_6Exit [arrowhead=none];
// Block0_6Exit [label="Jump" shape=oval];
// Block0_6Exit -> Block0_9 [style="solid"];
// Block0_8 [label="\
// Block 8; (22, max 23)\nLiveIn: phi0[1]\l\
// LiveOut: phi0[1]\l\nUsed: \l\n"];
// Block0_8 -> Block0_8Exit [arrowhead=none];
// Block0_8Exit [label="Jump" shape=oval];
// Block0_8Exit -> Block0_3 [style="solid"];
// Block0_9 [label="\
// Block 9; (5, max 21)\nLiveIn: phi2[3], phi1[1], phi0[1]\l\
// LiveOut: phi2[1], phi1[1], phi0[1]\l\nUsed: phi2[2]\l\nphi2 := φ(\l\
// 	Block 6 => v4,\l\
// 	Block 11 => v18\l\
// )\l\
// v5 := lt(0x03, phi2)\l\
// "];
// Block0_9 -> Block0_9Exit;
// Block0_9Exit [label="{ If v5 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_9Exit:0 -> Block0_12 [style="solid"];
// Block0_9Exit:1 -> Block0_10 [style="solid"];
// Block0_3 [label="\
// Block 3; (23, max 23)\nLiveIn: phi0[1]\l\
// LiveOut: v20[1]\l\nUsed: phi0[1]\l\nv20 := add(0x01, phi0)\l\
// "];
// Block0_3 -> Block0_3Exit [arrowhead=none];
// Block0_3Exit [label="Jump" shape=oval];
// Block0_3Exit -> Block0_1 [style="dashed"];
// Block0_10 [label="\
// Block 10; (6, max 19)\nLiveIn: phi2[1], phi1[1], phi0[1]\l\
// LiveOut: phi2[1], phi1[1], phi0[1]\l\nUsed: \l\nv6 := mload(0x00)\l\
// "];
// Block0_10 -> Block0_10Exit;
// Block0_10Exit [label="{ If v6 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_10Exit:0 -> Block0_14 [style="solid"];
// Block0_10Exit:1 -> Block0_13 [style="solid"];
// Block0_12 [label="\
// Block 12; (20, max 21)\nLiveIn: phi1[1], phi0[1]\l\
// LiveOut: phi1[1], phi0[1]\l\nUsed: \l\n"];
// Block0_12 -> Block0_12Exit [arrowhead=none];
// Block0_12Exit [label="Jump" shape=oval];
// Block0_12Exit -> Block0_7 [style="solid"];
// Block0_13 [label="\
// Block 13; (7, max 19)\nLiveIn: phi2[1], phi1[1], phi0[1]\l\
// LiveOut: v7[1], phi2[1], phi1[1], phi0[1]\l\nUsed: \l\nv7 := 0x00\l\
// "];
// Block0_13 -> Block0_13Exit [arrowhead=none];
// Block0_13Exit [label="Jump" shape=oval];
// Block0_13Exit -> Block0_15 [style="solid"];
// Block0_14 [label="\
// Block 14; (12, max 19)\nLiveIn: phi2[1], phi1[1], phi0[1]\l\
// LiveOut: phi2[1], phi1[1], phi0[1]\l\nUsed: \l\nv12 := mload(0x01)\l\
// "];
// Block0_14 -> Block0_14Exit;
// Block0_14Exit [label="{ If v12 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_14Exit:0 -> Block0_20 [style="solid"];
// Block0_14Exit:1 -> Block0_19 [style="solid"];
// Block0_7 [label="\
// Block 7; (21, max 21)\nLiveIn: phi1[1], phi0[1]\l\
// LiveOut: v19[1], phi0[1]\l\nUsed: phi1[1]\l\nv19 := add(0x01, phi1)\l\
// "];
// Block0_7 -> Block0_7Exit [arrowhead=none];
// Block0_7Exit [label="Jump" shape=oval];
// Block0_7Exit -> Block0_5 [style="dashed"];
// Block0_15 [label="\
// Block 15; (8, max 19)\nLiveIn: phi3[4], phi2[1], phi1[1], phi0[1]\l\
// LiveOut: phi3[2], phi2[1], phi1[1], phi0[1]\l\nUsed: phi3[2]\l\nphi3 := φ(\l\
// 	Block 13 => v7,\l\
// 	Block 17 => v11\l\
// )\l\
// v8 := lt(0x03, phi3)\l\
// "];
// Block0_15 -> Block0_15Exit;
// Block0_15Exit [label="{ If v8 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_15Exit:0 -> Block0_18 [style="solid"];
// Block0_15Exit:1 -> Block0_16 [style="solid"];
// Block0_19 [label="\
// Block 19; (13, max 19)\nLiveIn: phi2[1], phi1[1], phi0[1]\l\
// LiveOut: v13[1], phi2[1], phi1[1], phi0[1]\l\nUsed: \l\nv13 := 0x00\l\
// "];
// Block0_19 -> Block0_19Exit [arrowhead=none];
// Block0_19Exit [label="Jump" shape=oval];
// Block0_19Exit -> Block0_21 [style="solid"];
// Block0_20 [label="\
// Block 20; (18, max 19)\nLiveIn: phi2[1], phi1[1], phi0[1]\l\
// LiveOut: phi2[1], phi1[1], phi0[1]\l\nUsed: \l\n"];
// Block0_20 -> Block0_20Exit [arrowhead=none];
// Block0_20Exit [label="Jump" shape=oval];
// Block0_20Exit -> Block0_11 [style="solid"];
// Block0_16 [label="\
// Block 16; (9, max 10)\nLiveIn: phi3[2], phi2[1], phi1[1], phi0[1]\l\
// LiveOut: phi3[1], phi2[1], phi1[1], phi0[1]\l\nUsed: phi3[1]\l\nv9 := add(phi1, phi0)\l\
// v10 := add(phi2, v9)\l\
// sstore(v10, phi3)\l\
// "];
// Block0_16 -> Block0_16Exit [arrowhead=none];
// Block0_16Exit [label="Jump" shape=oval];
// Block0_16Exit -> Block0_17 [style="solid"];
// Block0_18 [label="\
// Block 18; (11, max 19)\nLiveIn: phi2[1], phi1[1], phi0[1]\l\
// LiveOut: phi2[1], phi1[1], phi0[1]\l\nUsed: \l\n"];
// Block0_18 -> Block0_18Exit [arrowhead=none];
// Block0_18Exit [label="Jump" shape=oval];
// Block0_18Exit -> Block0_14 [style="solid"];
// Block0_21 [label="\
// Block 21; (14, max 19)\nLiveIn: phi9[4], phi2[1], phi1[1], phi0[1]\l\
// LiveOut: phi9[2], phi2[1], phi1[1], phi0[1]\l\nUsed: phi9[2]\l\nphi9 := φ(\l\
// 	Block 19 => v13,\l\
// 	Block 23 => v17\l\
// )\l\
// v14 := lt(0x03, phi9)\l\
// "];
// Block0_21 -> Block0_21Exit;
// Block0_21Exit [label="{ If v14 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_21Exit:0 -> Block0_24 [style="solid"];
// Block0_21Exit:1 -> Block0_22 [style="solid"];
// Block0_11 [label="\
// Block 11; (19, max 19)\nLiveIn: phi2[1], phi1[1], phi0[1]\l\
// LiveOut: v18[1], phi1[1], phi0[1]\l\nUsed: phi2[1]\l\nv18 := add(0x01, phi2)\l\
// "];
// Block0_11 -> Block0_11Exit [arrowhead=none];
// Block0_11Exit [label="Jump" shape=oval];
// Block0_11Exit -> Block0_9 [style="dashed"];
// Block0_17 [label="\
// Block 17; (10, max 10)\nLiveIn: phi3[1], phi2[1], phi1[1], phi0[1]\l\
// LiveOut: v11[1], phi2[1], phi1[1], phi0[1]\l\nUsed: phi3[1]\l\nv11 := add(0x01, phi3)\l\
// "];
// Block0_17 -> Block0_17Exit [arrowhead=none];
// Block0_17Exit [label="Jump" shape=oval];
// Block0_17Exit -> Block0_15 [style="dashed"];
// Block0_22 [label="\
// Block 22; (15, max 16)\nLiveIn: phi9[2], phi2[1], phi1[1], phi0[1]\l\
// LiveOut: phi9[1], phi2[1], phi1[1], phi0[1]\l\nUsed: phi9[1]\l\nv15 := add(phi1, phi0)\l\
// v16 := add(phi2, v15)\l\
// sstore(v16, phi9)\l\
// "];
// Block0_22 -> Block0_22Exit [arrowhead=none];
// Block0_22Exit [label="Jump" shape=oval];
// Block0_22Exit -> Block0_23 [style="solid"];
// Block0_24 [label="\
// Block 24; (17, max 19)\nLiveIn: phi2[1], phi1[1], phi0[1]\l\
// LiveOut: phi2[1], phi1[1], phi0[1]\l\nUsed: \l\n"];
// Block0_24 -> Block0_24Exit [arrowhead=none];
// Block0_24Exit [label="Jump" shape=oval];
// Block0_24Exit -> Block0_20 [style="solid"];
// Block0_23 [label="\
// Block 23; (16, max 16)\nLiveIn: phi9[1], phi2[1], phi1[1], phi0[1]\l\
// LiveOut: v17[1], phi2[1], phi1[1], phi0[1]\l\nUsed: phi9[1]\l\nv17 := add(0x01, phi9)\l\
// "];
// Block0_23 -> Block0_23Exit [arrowhead=none];
// Block0_23Exit [label="Jump" shape=oval];
// Block0_23Exit -> Block0_21 [style="dashed"];
// }
