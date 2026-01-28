object "root" {
    code {
        // this produces non-zero PUSH #[$] assembly item values
        mstore(42, datasize("sub1.sub1_2"))
        mstore(42, datasize("sub2.sub2_2"))
    }
    object "sub1" {
        code {}
        object "sub1_2" {
            code {}
        }
    }
    object "sub2" {
        code {}
        object "sub2_2" {
            code {}
        }
    }
}
