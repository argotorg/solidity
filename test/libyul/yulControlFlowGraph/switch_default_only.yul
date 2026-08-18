{
    let x := sload(0)
    switch x
    default { sstore(0x01, 0x0101) }
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
// sstore: [ 0x0101 0x01 ] => [ ]\l\
// "];
// Block0 -> Block0Exit [arrowhead=none];
// Block0Exit [label="Jump" shape=oval];
// Block0Exit -> Block1;
//
// Block1 [label="\
// "];
// Block1Exit [label="MainExit"];
// Block1 -> Block1Exit;
//
// }
