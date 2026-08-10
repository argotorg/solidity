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
    case 7 { sstore(0x08, 0x0101) }
    default { sstore(0x09, 0x0101) }
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
// gt: [ 0x03 GHOST[0] ] => [ TMP[gt, 0] ]\l\
// "];
// Block0 -> Block0Exit;
// Block0Exit [label="{ TMP[gt, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block0Exit:0 -> Block1;
// Block0Exit:1 -> Block2;
//
// Block1 [label="\
// eq: [ GHOST[0] 0x00 ] => [ TMP[eq, 0] ]\l\
// "];
// Block1 -> Block1Exit;
// Block1Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block1Exit:0 -> Block3;
// Block1Exit:1 -> Block4;
//
// Block2 [label="\
// eq: [ GHOST[0] 0x04 ] => [ TMP[eq, 0] ]\l\
// "];
// Block2 -> Block2Exit;
// Block2Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block2Exit:0 -> Block5;
// Block2Exit:1 -> Block6;
//
// Block3 [label="\
// eq: [ GHOST[0] 0x01 ] => [ TMP[eq, 0] ]\l\
// "];
// Block3 -> Block3Exit;
// Block3Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block3Exit:0 -> Block7;
// Block3Exit:1 -> Block8;
//
// Block4 [label="\
// sstore: [ 0x0101 0x01 ] => [ ]\l\
// "];
// Block4 -> Block4Exit [arrowhead=none];
// Block4Exit [label="Jump" shape=oval];
// Block4Exit -> Block9;
//
// Block5 [label="\
// eq: [ GHOST[0] 0x05 ] => [ TMP[eq, 0] ]\l\
// "];
// Block5 -> Block5Exit;
// Block5Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block5Exit:0 -> Block10;
// Block5Exit:1 -> Block11;
//
// Block6 [label="\
// sstore: [ 0x0101 0x05 ] => [ ]\l\
// "];
// Block6 -> Block6Exit [arrowhead=none];
// Block6Exit [label="Jump" shape=oval];
// Block6Exit -> Block9;
//
// Block7 [label="\
// eq: [ GHOST[0] 0x02 ] => [ TMP[eq, 0] ]\l\
// "];
// Block7 -> Block7Exit;
// Block7Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block7Exit:0 -> Block12;
// Block7Exit:1 -> Block13;
//
// Block8 [label="\
// sstore: [ 0x0101 0x02 ] => [ ]\l\
// "];
// Block8 -> Block8Exit [arrowhead=none];
// Block8Exit [label="Jump" shape=oval];
// Block8Exit -> Block9;
//
// Block9 [label="\
// "];
// Block9Exit [label="MainExit"];
// Block9 -> Block9Exit;
//
// Block10 [label="\
// eq: [ GHOST[0] 0x06 ] => [ TMP[eq, 0] ]\l\
// "];
// Block10 -> Block10Exit;
// Block10Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block10Exit:0 -> Block14;
// Block10Exit:1 -> Block15;
//
// Block11 [label="\
// sstore: [ 0x0101 0x06 ] => [ ]\l\
// "];
// Block11 -> Block11Exit [arrowhead=none];
// Block11Exit [label="Jump" shape=oval];
// Block11Exit -> Block9;
//
// Block12 [label="\
// eq: [ GHOST[0] 0x03 ] => [ TMP[eq, 0] ]\l\
// "];
// Block12 -> Block12Exit;
// Block12Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block12Exit:0 -> Block16;
// Block12Exit:1 -> Block17;
//
// Block13 [label="\
// sstore: [ 0x0101 0x03 ] => [ ]\l\
// "];
// Block13 -> Block13Exit [arrowhead=none];
// Block13Exit [label="Jump" shape=oval];
// Block13Exit -> Block9;
//
// Block14 [label="\
// eq: [ GHOST[0] 0x07 ] => [ TMP[eq, 0] ]\l\
// "];
// Block14 -> Block14Exit;
// Block14Exit [label="{ TMP[eq, 0]| { <0> Zero | <1> NonZero }}" shape=Mrecord];
// Block14Exit:0 -> Block16;
// Block14Exit:1 -> Block18;
//
// Block15 [label="\
// sstore: [ 0x0101 0x07 ] => [ ]\l\
// "];
// Block15 -> Block15Exit [arrowhead=none];
// Block15Exit [label="Jump" shape=oval];
// Block15Exit -> Block9;
//
// Block16 [label="\
// sstore: [ 0x0101 0x09 ] => [ ]\l\
// "];
// Block16 -> Block16Exit [arrowhead=none];
// Block16Exit [label="Jump" shape=oval];
// Block16Exit -> Block9;
//
// Block17 [label="\
// sstore: [ 0x0101 0x04 ] => [ ]\l\
// "];
// Block17 -> Block17Exit [arrowhead=none];
// Block17Exit [label="Jump" shape=oval];
// Block17Exit -> Block9;
//
// Block18 [label="\
// sstore: [ 0x0101 0x08 ] => [ ]\l\
// "];
// Block18 -> Block18Exit [arrowhead=none];
// Block18Exit [label="Jump" shape=oval];
// Block18Exit -> Block9;
//
// }
