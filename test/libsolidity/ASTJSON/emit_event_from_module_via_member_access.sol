==== Source: A.sol ====
event TransferA(address indexed from, address indexed to, uint amount);
contract AContract {
    event TransferAContract(address indexed from, address indexed to, uint amount);
}

==== Source: ERC20.sol ====
import * as A from "A.sol";
contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint amount);
    function f () public {
        emit Transfer(address(1), address(2), 3);
        emit A.TransferA(address(1), address(2), 3);
        emit A.AContract.TransferAContract(address(1), address(2), 3);
    }
}

// ----
