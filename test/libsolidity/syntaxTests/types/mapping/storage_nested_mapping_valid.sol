struct S {
    mapping(uint => uint) m;
    mapping(uint => uint)[2] a;
}
struct T {
    S[] s;
    mapping(uint => S) n;
}
library L {
    function f(T storage) public {}
    function g(S[2] storage) internal {}
}
contract C {
    T t;
    S[2] s;
    mapping(uint => T) m;
    function h() internal view {
        T storage x = t;
        S[2] storage y = s;
        x; y;
    }
}
