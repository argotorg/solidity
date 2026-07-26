{
    let addr := deploytimeaddress()
    sstore(0, eq(addr, address()))
}
// ====
// dialect: evm
// ----
