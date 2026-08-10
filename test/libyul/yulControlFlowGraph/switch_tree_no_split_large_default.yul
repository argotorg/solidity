{
    let x := sload(0)
    switch x
    case 0 { sstore(0x01, 0x0101) }
    case 1 { sstore(0x02, 0x0101) }
    case 2 { sstore(0x03, 0x0101) }
    case 3 { sstore(0x04, 0x0101) }
    case 4 { sstore(0x05, 0x0101) }
    case 5 { sstore(0x06, 0x0101) }
    case 6 { sstore(0x07, 0x0101) }
    default {
        sstore(0x08, 0x0101)
        sstore(0x09, 0x0102)
        sstore(0x0a, 0x0103)
    }
}
// ----
// digraph CFG {
// nodesep=0.7;
// node[shape=box];
//
// Entry [label="Entry"];
// Entry -> Block0;
// Block0 [label="\
// sload: [ 0x00 ] => [ TMP[sload, 0] ]\l\
// Assignment(x): [ TMP[sload, 0] ] => [ x ]\l\
// Assignment(GHOST[0]): [ x ] => [ GHOST[0] ]\l\
// eq: [ GHOST[0] 0x00 ] => [ TMP[eq, 0] ]\l\
// "];
// Block0 -> Block0Exit;
// Block0Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0Exit:0 -> Block1;
// Block0Exit:1 -> Block2;
//
// Block1 [label="\
// eq: [ GHOST[0] 0x01 ] => [ TMP[eq, 0] ]\l\
// "];
// Block1 -> Block1Exit;
// Block1Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1Exit:0 -> Block3;
// Block1Exit:1 -> Block4;
//
// Block2 [label="\
// sstore: [ 0x0101 0x01 ] => [ ]\l\
// "];
// Block2 -> Block2Exit [arrowhead=none];
// Block2Exit [label="Jump" shape=oval];
// Block2Exit -> Block5;
//
// Block3 [label="\
// eq: [ GHOST[0] 0x02 ] => [ TMP[eq, 0] ]\l\
// "];
// Block3 -> Block3Exit;
// Block3Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block3Exit:0 -> Block6;
// Block3Exit:1 -> Block7;
//
// Block4 [label="\
// sstore: [ 0x0101 0x02 ] => [ ]\l\
// "];
// Block4 -> Block4Exit [arrowhead=none];
// Block4Exit [label="Jump" shape=oval];
// Block4Exit -> Block5;
//
// Block5 [label="\
// "];
// Block5Exit [label="MainExit"];
// Block5 -> Block5Exit;
//
// Block6 [label="\
// eq: [ GHOST[0] 0x03 ] => [ TMP[eq, 0] ]\l\
// "];
// Block6 -> Block6Exit;
// Block6Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block6Exit:0 -> Block8;
// Block6Exit:1 -> Block9;
//
// Block7 [label="\
// sstore: [ 0x0101 0x03 ] => [ ]\l\
// "];
// Block7 -> Block7Exit [arrowhead=none];
// Block7Exit [label="Jump" shape=oval];
// Block7Exit -> Block5;
//
// Block8 [label="\
// eq: [ GHOST[0] 0x04 ] => [ TMP[eq, 0] ]\l\
// "];
// Block8 -> Block8Exit;
// Block8Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block8Exit:0 -> Block10;
// Block8Exit:1 -> Block11;
//
// Block9 [label="\
// sstore: [ 0x0101 0x04 ] => [ ]\l\
// "];
// Block9 -> Block9Exit [arrowhead=none];
// Block9Exit [label="Jump" shape=oval];
// Block9Exit -> Block5;
//
// Block10 [label="\
// eq: [ GHOST[0] 0x05 ] => [ TMP[eq, 0] ]\l\
// "];
// Block10 -> Block10Exit;
// Block10Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block10Exit:0 -> Block12;
// Block10Exit:1 -> Block13;
//
// Block11 [label="\
// sstore: [ 0x0101 0x05 ] => [ ]\l\
// "];
// Block11 -> Block11Exit [arrowhead=none];
// Block11Exit [label="Jump" shape=oval];
// Block11Exit -> Block5;
//
// Block12 [label="\
// eq: [ GHOST[0] 0x06 ] => [ TMP[eq, 0] ]\l\
// "];
// Block12 -> Block12Exit;
// Block12Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block12Exit:0 -> Block14;
// Block12Exit:1 -> Block15;
//
// Block13 [label="\
// sstore: [ 0x0101 0x06 ] => [ ]\l\
// "];
// Block13 -> Block13Exit [arrowhead=none];
// Block13Exit [label="Jump" shape=oval];
// Block13Exit -> Block5;
//
// Block14 [label="\
// sstore: [ 0x0101 0x08 ] => [ ]\l\
// sstore: [ 0x0102 0x09 ] => [ ]\l\
// sstore: [ 0x0103 0x0a ] => [ ]\l\
// "];
// Block14 -> Block14Exit [arrowhead=none];
// Block14Exit [label="Jump" shape=oval];
// Block14Exit -> Block5;
//
// Block15 [label="\
// sstore: [ 0x0101 0x07 ] => [ ]\l\
// "];
// Block15 -> Block15Exit [arrowhead=none];
// Block15Exit [label="Jump" shape=oval];
// Block15Exit -> Block5;
//
// }
