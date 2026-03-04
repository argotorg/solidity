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
// Entry [label="Entry"];
// Entry -> Block0_0;
// Block0_0 [fillcolor="#FF746C", style=filled, label="\
// Block 0; (0, max 0)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nsstore(0x01, 0x01)\l\
// v0 := f(0x02, 0x01)\l\
// pop(v0)\l\
// v1 := sload(0x00)\l\
// v2 := add(v1, 0x05)\l\
// v3 := sload(0x04)\l\
// v4 := f(v3, v2)\l\
// sstore(v4, v2)\l\
// v5 := sload(0x05)\l\
// v6 := f(v5, v4)\l\
// sstore(v6, 0x01)\l\
// "];
// Block0_0Exit [label="MainExit"];
// Block0_0 -> Block0_0Exit;
// FunctionEntry_f_0 [label="function f:
//  c := f(v0, v1)"];
// FunctionEntry_f_0 -> Block1_0;
// Block1_0 [label="\
// Block 0; (0, max 17)\nLiveIn: v1[1], v0[1]\l\
// LiveOut: v2[1], v1[1], v0[1]\l\nUsed: \l\nv2 := 0x2a\l\
// "];
// Block1_0 -> Block1_0Exit [arrowhead=none];
// Block1_0Exit [label="Jump" shape=oval];
// Block1_0Exit -> Block1_1 [style="solid"];
// Block1_1 [label="\
// Block 1; (1, max 17)\nLiveIn: phi1[4], v1[1], v0[1]\l\
// LiveOut: phi1[2], v1[1], v0[1]\l\nUsed: phi1[2]\l\nphi1 := φ(\l\
// 	Block 0 => v2,\l\
// 	Block 21 => v10\l\
// )\l\
// v3 := lt(v0, phi1)\l\
// "];
// Block1_1 -> Block1_1Exit;
// Block1_1Exit [label="{ If v3 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_1Exit:0 -> Block1_4 [style="solid"];
// Block1_1Exit:1 -> Block1_2 [style="solid"];
// Block1_2 [label="\
// Block 2; (2, max 17)\nLiveIn: phi1[2], v1[1], v0[1]\l\
// LiveOut: phi1[1], v1[1], v4[3], v0[1]\l\nUsed: phi1[1]\l\nv4 := mload(phi1)\l\
// v5 := eq(0x00, v4)\l\
// "];
// Block1_2 -> Block1_2Exit;
// Block1_2Exit [label="{ If v5 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_2Exit:0 -> Block1_7 [style="solid"];
// Block1_2Exit:1 -> Block1_6 [style="solid"];
// Block1_4 [label="\
// Block 4; (4, max 4)\nLiveIn: \l\
// LiveOut: v12[1]\l\nUsed: \l\nsstore(0x0c0c, 0x0c)\l\
// v12 := 0x1b\l\
// "];
// Block1_4Exit [label="FunctionReturn[v12]"];
// Block1_4 -> Block1_4Exit;
// Block1_6 [label="\
// Block 6; (3, max 4)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nsstore(0x0202, 0x02)\l\
// "];
// Block1_6 -> Block1_6Exit [arrowhead=none];
// Block1_6Exit [label="Jump" shape=oval];
// Block1_6Exit -> Block1_4 [style="solid"];
// Block1_7 [label="\
// Block 7; (5, max 17)\nLiveIn: phi1[1], v1[1], v4[3], v0[1]\l\
// LiveOut: phi1[1], v1[1], v4[2], v0[1]\l\nUsed: v4[1]\l\nv6 := eq(0x01, v4)\l\
// "];
// Block1_7 -> Block1_7Exit;
// Block1_7Exit [label="{ If v6 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_7Exit:0 -> Block1_10 [style="solid"];
// Block1_7Exit:1 -> Block1_9 [style="solid"];
// Block1_9 [label="\
// Block 9; (6, max 6)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nsstore(0x0404, 0x04)\l\
// "];
// Block1_9Exit [label="FunctionReturn[0x00]"];
// Block1_9 -> Block1_9Exit;
// Block1_10 [label="\
// Block 10; (7, max 17)\nLiveIn: phi1[1], v1[1], v4[2], v0[1]\l\
// LiveOut: phi1[1], v1[1], v4[1], v0[1]\l\nUsed: v4[1]\l\nv7 := eq(0x02, v4)\l\
// "];
// Block1_10 -> Block1_10Exit;
// Block1_10Exit [label="{ If v7 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_10Exit:0 -> Block1_13 [style="solid"];
// Block1_10Exit:1 -> Block1_12 [style="solid"];
// Block1_12 [fillcolor="#FF746C", style=filled, label="\
// Block 12; (8, max 8)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nsstore(0x0606, 0x06)\l\
// revert(0x00, 0x00)\l\
// "];
// Block1_12Exit [label="Terminated"];
// Block1_12 -> Block1_12Exit;
// Block1_13 [label="\
// Block 13; (9, max 17)\nLiveIn: phi1[1], v1[1], v4[1], v0[1]\l\
// LiveOut: phi1[1], v1[1], v0[1]\l\nUsed: v4[1]\l\nv8 := eq(0x03, v4)\l\
// "];
// Block1_13 -> Block1_13Exit;
// Block1_13Exit [label="{ If v8 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_13Exit:0 -> Block1_16 [style="solid"];
// Block1_13Exit:1 -> Block1_15 [style="solid"];
// Block1_15 [label="\
// Block 15; (10, max 14)\nLiveIn: phi1[1], v1[1], v0[1]\l\
// LiveOut: phi1[1], v1[1], v0[1]\l\nUsed: \l\nsstore(0x0808, 0x08)\l\
// "];
// Block1_15 -> Block1_15Exit [arrowhead=none];
// Block1_15Exit [label="Jump" shape=oval];
// Block1_15Exit -> Block1_5 [style="solid"];
// Block1_16 [label="\
// Block 16; (15, max 17)\nLiveIn: phi1[1], v1[1], v0[1]\l\
// LiveOut: phi1[1], v1[1], v0[1]\l\nUsed: \l\nv9 := mload(v1)\l\
// "];
// Block1_16 -> Block1_16Exit;
// Block1_16Exit [label="{ If v9 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_16Exit:0 -> Block1_18 [style="solid"];
// Block1_16Exit:1 -> Block1_17 [style="solid"];
// Block1_5 [label="\
// Block 5; (11, max 14)\nLiveIn: phi1[1], v1[1], v0[1]\l\
// LiveOut: phi1[1], v1[1], v0[1]\l\nUsed: \l\nsstore(0x0b0b, 0x0b)\l\
// "];
// Block1_5 -> Block1_5Exit [arrowhead=none];
// Block1_5Exit [label="Jump" shape=oval];
// Block1_5Exit -> Block1_3 [style="solid"];
// Block1_17 [fillcolor="#FF746C", style=filled, label="\
// Block 17; (16, max 16)\nLiveIn: \l\
// LiveOut: \l\nUsed: \l\nreturn(0x00, 0x00)\l\
// "];
// Block1_17Exit [label="Terminated"];
// Block1_17 -> Block1_17Exit;
// Block1_18 [label="\
// Block 18; (17, max 17)\nLiveIn: phi1[1], v1[1], v0[1]\l\
// LiveOut: phi1[1], v1[1], v0[1]\l\nUsed: \l\nsstore(0x0a0a, 0x0a)\l\
// "];
// Block1_18 -> Block1_18Exit [arrowhead=none];
// Block1_18Exit [label="Jump" shape=oval];
// Block1_18Exit -> Block1_5 [style="solid"];
// Block1_3 [label="\
// Block 3; (12, max 14)\nLiveIn: phi1[1], v1[1], v0[1]\l\
// LiveOut: v10[1], v1[1], v0[1]\l\nUsed: phi1[1]\l\nv10 := add(0x01, phi1)\l\
// v11 := calldataload(v10)\l\
// "];
// Block1_3 -> Block1_3Exit;
// Block1_3Exit [label="{ If v11 | { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1_3Exit:0 -> Block1_21 [style="solid"];
// Block1_3Exit:1 -> Block1_20 [style="solid"];
// Block1_20 [label="\
// Block 20; (13, max 13)\nLiveIn: v10[1]\l\
// LiveOut: \l\nUsed: v10[1]\l\nsstore(v10, 0x00)\l\
// "];
// Block1_20Exit [label="FunctionReturn[0x00]"];
// Block1_20 -> Block1_20Exit;
// Block1_21 [label="\
// Block 21; (14, max 14)\nLiveIn: v10[1], v1[1], v0[1]\l\
// LiveOut: v10[1], v1[1], v0[1]\l\nUsed: \l\nsstore(0xffff, 0xff)\l\
// "];
// Block1_21 -> Block1_21Exit [arrowhead=none];
// Block1_21Exit [label="Jump" shape=oval];
// Block1_21Exit -> Block1_1 [style="dashed"];
// }
