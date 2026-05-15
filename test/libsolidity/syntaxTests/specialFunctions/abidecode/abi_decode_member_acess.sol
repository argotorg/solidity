library L {
    struct S { int a; }
    enum State { idle, running, blocked }
}

contract D {
    struct X { uint b; }
    enum Color { red, green, blue }
}

contract C {
    function f() pure public {
        abi.decode("", (L.S));
        abi.decode("", (L.State));
        abi.decode("", (D.X));
        abi.decode("", (D.Color));
    }
}
// ----
// Warning 6133: (210-231): Statement has no effect.
// Warning 6133: (241-266): Statement has no effect.
// Warning 6133: (276-297): Statement has no effect.
// Warning 6133: (307-332): Statement has no effect.
