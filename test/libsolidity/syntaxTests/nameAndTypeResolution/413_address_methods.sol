contract C {
    function f() public {
        address payable addr;
        uint balance = addr.balance;
        (bool callSuc,) = addr.call("");
        (bool delegatecallSuc,) = addr.delegatecall("");
        bool sendRet = addr.send(1);
        addr.transfer(1);
        balance; callSuc; delegatecallSuc; sendRet;
    }
}
// ----
// Warning 9207: (227-236): 'send' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
// Warning 9207: (249-262): 'transfer' is deprecated and scheduled for removal. Use 'call{value: <amount>}("")' instead.
