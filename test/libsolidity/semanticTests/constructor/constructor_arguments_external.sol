contract Main {
    bytes3 name;
    bool flag;

    constructor(bytes3 x, bool f) {
        name = x;
        flag = f;
    }

    function getName() public returns (bytes3 ret) {
        return name;
    }

    function getFlag() public returns (bool ret) {
        return flag;
    }
}
// ----
// constructor(): "abc", true
// gas irOptimized: 80019
// gas irOptimized code: 23800
// gas legacy: 85098
// gas legacy code: 58200
// gas legacyOptimized: 80018
// gas legacyOptimized code: 22400
// gas ssaCFGOptimized: 79907
// gas ssaCFGOptimized code: 22200
// getFlag() -> true
// getName() -> "abc"
