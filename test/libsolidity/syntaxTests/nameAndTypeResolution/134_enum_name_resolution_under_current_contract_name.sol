contract A {
    enum Foo {
        First,
        Second
    }

    function a() public {
        A.Foo;
    }
}
// ----
// Warning 6133: (99-104): Statement has no effect.
// Warning 2018: (69-111): Function state mutability can be restricted to pure
