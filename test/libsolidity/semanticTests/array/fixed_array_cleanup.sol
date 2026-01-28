contract c {
    uint spacer1;
    uint spacer2;
    uint[20] data;
    function fill() public {
        for (uint i = 0; i < data.length; ++i) data[i] = i+1;
    }
    function clear() public { delete data; }
}
// ----
// storageEmpty -> 1
// fill() ->
// gas irOptimized: 465013
// gas legacy: 468825
// gas legacyOptimized: 466238
// storageEmpty -> 0
// clear() ->
// gas irOptimized: 97800
// gas legacy: 97947
// gas legacyOptimized: 97882
// storageEmpty -> 1
