{
    // Two recursive cycles sharing alpha: alpha <-> beta and alpha -> gamma -> beta -> alpha,
    // so {alpha, beta, gamma} is a single strongly-connected component and all three are recursive.
    function alpha() { beta() gamma() }
    function beta() { alpha() }
    function gamma() { beta() }
}
// ----
// <main>
// alpha (recursive) -> beta, gamma
// beta (recursive) -> alpha
// gamma (recursive) -> beta
