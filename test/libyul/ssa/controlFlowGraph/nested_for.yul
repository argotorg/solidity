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
// Block 0; (0, max 19)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\n"];
// Block0_0 -> Block0_0Exit [arrowhead=none];
// Block0_0Exit [label="Jump" shape=oval];
// Block0_0Exit -> Block0_1 [style="solid"];
// Block0_1 [label="\
// Block 1; (1, max 19)\nLiveIn: phi2[3]\l\
// LiveOut: phi2[1]\l\nUsed: phi2[2]\l\nphi2 := φ(\l\
// 	Block 0 => 0x00,\l\
// 	Block 8 => v78\l\
// )\l\
// v3 := lt(phi2, 0x03)\l\
// "];
// Block0_1 -> Block0_1Exit;
// Block0_1Exit [label="{ If v3 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_1Exit:0 -> Block0_4 [style="solid"];
// Block0_1Exit:1 -> Block0_2 [style="solid"];
// Block0_2 [label="\
// Block 2; (2, max 18)\nLiveIn: phi2[1]\l\
// LiveOut: phi2[1]\l\nUsed: \l\n"];
// Block0_2 -> Block0_2Exit [arrowhead=none];
// Block0_2Exit [label="Jump" shape=oval];
// Block0_2Exit -> Block0_5 [style="solid"];
// Block0_4 [fillcolor="#FF746C", style=filled, label="\
// Block 4; (19, max 19)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\n"];
// Block0_4Exit [label="MainExit"];
// Block0_4 -> Block0_4Exit;
// Block0_5 [label="\
// Block 5; (3, max 18)\nLiveIn: phi2[1], phi4[3]\l\
// LiveOut: phi2[1], phi4[1]\l\nUsed: phi4[2]\l\nphi4 := φ(\l\
// 	Block 2 => 0x00,\l\
// 	Block 12 => v73\l\
// )\l\
// v5 := lt(phi4, 0x03)\l\
// "];
// Block0_5 -> Block0_5Exit;
// Block0_5Exit [label="{ If v5 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_5Exit:0 -> Block0_8 [style="solid"];
// Block0_5Exit:1 -> Block0_6 [style="solid"];
// Block0_6 [label="\
// Block 6; (4, max 17)\nLiveIn: phi2[1], phi4[1]\l\
// LiveOut: phi2[1], phi4[1]\l\nUsed: \l\n"];
// Block0_6 -> Block0_6Exit [arrowhead=none];
// Block0_6Exit [label="Jump" shape=oval];
// Block0_6Exit -> Block0_9 [style="solid"];
// Block0_8 [label="\
// Block 8; (18, max 18)\nLiveIn: phi2[1]\l\
// LiveOut: v78[1]\l\nUsed: phi2[1]\l\nv78 := add(phi2, 0x01)\l\
// "];
// Block0_8 -> Block0_8Exit [arrowhead=none];
// Block0_8Exit [label="Jump" shape=oval];
// Block0_8Exit -> Block0_1 [style="dashed"];
// Block0_9 [label="\
// Block 9; (5, max 17)\nLiveIn: phi6[3], phi2[1], phi4[1]\l\
// LiveOut: phi6[1], phi2[1], phi4[1]\l\nUsed: phi6[2]\l\nphi6 := φ(\l\
// 	Block 6 => 0x00,\l\
// 	Block 20 => v59\l\
// )\l\
// v7 := lt(phi6, 0x03)\l\
// "];
// Block0_9 -> Block0_9Exit;
// Block0_9Exit [label="{ If v7 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_9Exit:0 -> Block0_12 [style="solid"];
// Block0_9Exit:1 -> Block0_10 [style="solid"];
// Block0_10 [label="\
// Block 10; (6, max 16)\nLiveIn: phi6[1], phi2[1], phi4[1]\l\
// LiveOut: phi6[1], phi2[1], phi4[1]\l\nUsed: \l\nv8 := mload(0x00)\l\
// "];
// Block0_10 -> Block0_10Exit;
// Block0_10Exit [label="{ If v8 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_10Exit:0 -> Block0_14 [style="solid"];
// Block0_10Exit:1 -> Block0_13 [style="solid"];
// Block0_12 [label="\
// Block 12; (17, max 17)\nLiveIn: phi4[1], phi2[1]\l\
// LiveOut: v73[1], phi2[1]\l\nUsed: phi4[1]\l\nv73 := add(phi4, 0x01)\l\
// "];
// Block0_12 -> Block0_12Exit [arrowhead=none];
// Block0_12Exit [label="Jump" shape=oval];
// Block0_12Exit -> Block0_5 [style="dashed"];
// Block0_13 [label="\
// Block 13; (7, max 16)\nLiveIn: phi6[1], phi2[1], phi4[1]\l\
// LiveOut: phi6[1], phi2[1], phi4[1]\l\nUsed: \l\n"];
// Block0_13 -> Block0_13Exit [arrowhead=none];
// Block0_13Exit [label="Jump" shape=oval];
// Block0_13Exit -> Block0_15 [style="solid"];
// Block0_14 [label="\
// Block 14; (11, max 16)\nLiveIn: phi6[1], phi2[1], phi4[1]\l\
// LiveOut: phi6[1], phi2[1], phi4[1]\l\nUsed: \l\nv29 := mload(0x01)\l\
// "];
// Block0_14 -> Block0_14Exit;
// Block0_14Exit [label="{ If v29 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_14Exit:0 -> Block0_20 [style="solid"];
// Block0_14Exit:1 -> Block0_19 [style="solid"];
// Block0_15 [label="\
// Block 15; (8, max 16)\nLiveIn: phi9[4], phi6[1], phi2[1], phi4[1]\l\
// LiveOut: phi9[2], phi6[1], phi2[1], phi4[1]\l\nUsed: phi9[2]\l\nphi9 := φ(\l\
// 	Block 13 => 0x00,\l\
// 	Block 16 => v18\l\
// )\l\
// v10 := lt(phi9, 0x03)\l\
// "];
// Block0_15 -> Block0_15Exit;
// Block0_15Exit [label="{ If v10 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_15Exit:0 -> Block0_18 [style="solid"];
// Block0_15Exit:1 -> Block0_16 [style="solid"];
// Block0_19 [label="\
// Block 19; (12, max 16)\nLiveIn: phi6[1], phi2[1], phi4[1]\l\
// LiveOut: phi6[1], phi2[1], phi4[1]\l\nUsed: \l\n"];
// Block0_19 -> Block0_19Exit [arrowhead=none];
// Block0_19Exit [label="Jump" shape=oval];
// Block0_19Exit -> Block0_21 [style="solid"];
// Block0_20 [label="\
// Block 20; (16, max 16)\nLiveIn: phi6[1], phi2[1], phi4[1]\l\
// LiveOut: v59[1], phi2[1], phi4[1]\l\nUsed: phi6[1]\l\nv59 := add(phi6, 0x01)\l\
// "];
// Block0_20 -> Block0_20Exit [arrowhead=none];
// Block0_20Exit [label="Jump" shape=oval];
// Block0_20Exit -> Block0_9 [style="dashed"];
// Block0_16 [label="\
// Block 16; (9, max 9)\nLiveIn: phi9[2], phi6[1], phi2[1], phi4[1]\l\
// LiveOut: v18[1], phi6[1], phi2[1], phi4[1]\l\nUsed: phi9[2]\l\nv14 := add(phi2, phi4)\l\
// v15 := add(v14, phi6)\l\
// sstore(phi9, v15)\l\
// v18 := add(phi9, 0x01)\l\
// "];
// Block0_16 -> Block0_16Exit [arrowhead=none];
// Block0_16Exit [label="Jump" shape=oval];
// Block0_16Exit -> Block0_15 [style="dashed"];
// Block0_18 [label="\
// Block 18; (10, max 16)\nLiveIn: phi6[1], phi2[1], phi4[1]\l\
// LiveOut: phi6[1], phi2[1], phi4[1]\l\nUsed: \l\n"];
// Block0_18 -> Block0_18Exit [arrowhead=none];
// Block0_18Exit [label="Jump" shape=oval];
// Block0_18Exit -> Block0_14 [style="solid"];
// Block0_21 [label="\
// Block 21; (13, max 16)\nLiveIn: phi30[4], phi6[1], phi2[1], phi4[1]\l\
// LiveOut: phi30[2], phi6[1], phi2[1], phi4[1]\l\nUsed: phi30[2]\l\nphi30 := φ(\l\
// 	Block 19 => 0x00,\l\
// 	Block 22 => v38\l\
// )\l\
// v31 := lt(phi30, 0x03)\l\
// "];
// Block0_21 -> Block0_21Exit;
// Block0_21Exit [label="{ If v31 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0_21Exit:0 -> Block0_24 [style="solid"];
// Block0_21Exit:1 -> Block0_22 [style="solid"];
// Block0_22 [label="\
// Block 22; (14, max 14)\nLiveIn: phi30[2], phi6[1], phi2[1], phi4[1]\l\
// LiveOut: v38[1], phi6[1], phi2[1], phi4[1]\l\nUsed: phi30[2]\l\nv35 := add(phi2, phi4)\l\
// v36 := add(v35, phi6)\l\
// sstore(phi30, v36)\l\
// v38 := add(phi30, 0x01)\l\
// "];
// Block0_22 -> Block0_22Exit [arrowhead=none];
// Block0_22Exit [label="Jump" shape=oval];
// Block0_22Exit -> Block0_21 [style="dashed"];
// Block0_24 [label="\
// Block 24; (15, max 16)\nLiveIn: phi6[1], phi2[1], phi4[1]\l\
// LiveOut: phi6[1], phi2[1], phi4[1]\l\nUsed: \l\n"];
// Block0_24 -> Block0_24Exit [arrowhead=none];
// Block0_24Exit [label="Jump" shape=oval];
// Block0_24Exit -> Block0_20 [style="solid"];
// }
