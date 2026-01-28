object "object" {
   code {
        mstore(64, 128)
        fun_f_5()
        function fun_f_5() {
            sstore(0, 42)
        }
    }

    object "object_deployed" {
        code {
            mstore(64, 128)
            fun_f_5()
            function fun_f_5() {
                sstore(0, 42)
            }
        }
    }
}
