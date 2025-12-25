==== Source: A.sol ====
error ErrorA(string msg);
contract AContract {
    error ErrorAContract(string msg);
}

==== Source: B.sol ====
import * as A from "A.sol";
contract BContract {
    error ErrorBContract(string msg);
    function f1 () public {
        revert ErrorBContract("some error");
    }
    function f2 () public {
        revert A.ErrorA("some error");
    }
    function f3 () public {
        revert A.AContract.ErrorAContract("some error");
    }
}

// ----
