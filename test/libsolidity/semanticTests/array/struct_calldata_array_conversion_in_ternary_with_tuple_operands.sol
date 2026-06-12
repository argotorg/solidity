pragma abicoder v2;

contract C {
    struct N {
        address addr;
        bytes32 data32;
    }

    struct S {
        uint8 a;
        address addr;
        N[] ns;
        bytes data;
    }

    function g() private returns(S[] memory) {
        S[] memory ss = new S[](3);

        ss[0].a = 123;
        ss[0].addr = address(1);
        ss[0].ns = new N[](1);
        ss[0].ns[0].addr = address(1);
        ss[0].ns[0].data32 = "abdeff00";
        ss[0].data = "abdeff";

        ss[1].a = 124;
        ss[1].addr = address(2);
        ss[1].ns = new N[](2);
        ss[1].ns[0].addr = address(2);
        ss[1].ns[0].data32 = "abdeff10";
        ss[1].ns[1].addr = address(2);
        ss[1].ns[1].data32 = "abdeff11";
        ss[1].data = "deabff";

        ss[2].a = 125;
        ss[2].addr = address(3);
        ss[2].ns = new N[](3);
        ss[2].ns[0].addr = address(3);
        ss[2].ns[0].data32 = "abdeff20";
        ss[2].ns[1].addr = address(3);
        ss[2].ns[1].data32 = "abdeff21";
        ss[2].ns[2].addr = address(3);
        ss[2].ns[2].data32 = "abdeff22";
        ss[2].data = "deffab";

        return ss;
    }

    function g(S[] calldata a, S[] calldata b) public returns(S[] memory) {
        (S[] calldata r, ) = true ? (a, 0) : (b, 0);
        return r;
    }

    function compare_bytes(bytes memory a, bytes memory b) private pure returns(bool)
    {
        require(a.length == b.length);
        for (uint i = 0; i < a.length; i = i + 1)
            if (a[i] != b[i])
                return false;

        return true;
    }

    function test() public
    {
        S[] memory s0 = g();
        S[] memory s1 = this.g(s0, s0);

        require(s0.length == s1.length);

        for (uint i = 0; i < s0.length; i = i + 1)
        {
            require(s0[i].a == s1[i].a);
            require(s0[i].addr == s1[i].addr);

            require(s0[i].ns.length == s1[i].ns.length);

            for (uint j = 0; j < s0[i].ns.length; j = j + 1)
            {
                require(s0[i].ns[j].addr == s1[i].ns[j].addr);
                require(s0[i].ns[j].data32 == s1[i].ns[j].data32);
            }

            require(compare_bytes(s0[i].data, s1[i].data));
        }
    }
}
// ====
// EVMVersion: >homestead
// ----
// test() ->
// gas legacy: 85950
