contract C layout at 2**256 - 2 {
    mapping(uint => uint) m;

    function init() public {
        for (uint i = 0; i < 1000; ++i)
            m[i] = i + 1;
    }

    function validate() public {
        for (uint i = 0; i < 1000; ++i)
            require(m[i] == i + 1);
    }
}
// ----
// init() ->
// gas irOptimized: 22266229
// gas legacy: 22447245
// gas legacyOptimized: 22310238
// validate() ->
// gas irOptimized: 2279210
// gas legacy: 2456223
// gas legacyOptimized: 2327216
