object "C" {
    code {}

    object "C_deployed" {
        code {
            sstore(0, loadimmutable("1"))
        }
    }
}
