// If compiler changes make this test pass, all the other recursive-struct
// copy tests of this fix need transient storage variants.
contract C {
    struct Node {
        Node[] children;
        uint256 balance;
    }

    Node transient root;
}
// ====
// EVMVersion: >=cancun
// ----
// UnimplementedFeatureError 1834: Transient data location is only supported for value types.
