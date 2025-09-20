contract C {

    enum E {
        VALUE,
        VALUE2,
        VALUE3,
        VALUE4
    }

    struct Mail {
        address from;
        address to;
        string contents;
        E e;
    }

    function f() public pure returns(bool) {
        return type(Mail).typehash == keccak256("Mail(address from,address to,string contents,uint8 e)");
    }
}
// ----
// f() -> true
