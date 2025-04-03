contract B
{
    function f() public returns (uint ret){
        ret = 123;
    }
}

contract C {
    B b;

    function f() public {
        B t;
        assembly {
            t := eofcreate(B.objectName, 0, 0, 0, 0)
        }

        b = t;
    }

    function run_B_f() public returns (uint) {
        return b.f();
    }
}
// ====
// bytecodeFormat: >=EOFv1
// ----
// f()
// run_B_f() -> 123