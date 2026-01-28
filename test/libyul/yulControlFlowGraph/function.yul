{
    function f(a, b) -> r {
        let x := add(a,b)
        r := sub(x,a)
    }
    function g() {
        sstore(0x01, 0x0101)
    }
    function h(x) {
        h(f(x, 0))
        g()
    }
    function i() -> v, w {
        v := 0x0202
        w := 0x0303
    }
    let x, y := i()
    h(x)
    h(y)
}
// ====
// bytecodeFormat: legacy
// ----
// digraph CFG {
// nodesep=0.7;
// node[shape=box];
//
// Entry [label="Entry"];
// Entry -> Block0;
// Block0 [label="\
// i: [ RET[i] ] => [ TMP[i, 0] TMP[i, 1] ]\l\
// Assignment(x, y): [ TMP[i, 0] TMP[i, 1] ] => [ x y ]\l\
// h: [ x ] => [ ]\l\
// "];
// Block0Exit [label="Terminated"];
// Block0 -> Block0Exit;
//
// FunctionEntry_f_1 [label="function f(a, b) -> r"];
// FunctionEntry_f_1 -> Block1;
// Block1 [label="\
// add: [ b a ] => [ TMP[add, 0] ]\l\
// Assignment(x): [ TMP[add, 0] ] => [ x ]\l\
// sub: [ a x ] => [ TMP[sub, 0] ]\l\
// Assignment(r): [ TMP[sub, 0] ] => [ r ]\l\
// "];
// Block1Exit [label="FunctionReturn[f]"];
// Block1 -> Block1Exit;
//
// FunctionEntry_h_2 [label="function h(x)"];
// FunctionEntry_h_2 -> Block2;
// Block2 [label="\
// f: [ RET[f] 0x00 x ] => [ TMP[f, 0] ]\l\
// h: [ TMP[f, 0] ] => [ ]\l\
// "];
// Block2Exit [label="Terminated"];
// Block2 -> Block2Exit;
//
// FunctionEntry_i_3 [label="function i() -> v, w"];
// FunctionEntry_i_3 -> Block3;
// Block3 [label="\
// Assignment(v): [ 0x0202 ] => [ v ]\l\
// Assignment(w): [ 0x0303 ] => [ w ]\l\
// "];
// Block3Exit [label="FunctionReturn[i]"];
// Block3 -> Block3Exit;
//
// }
