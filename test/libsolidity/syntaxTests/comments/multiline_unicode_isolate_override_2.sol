contract C {
    function f() public pure
    {
        // LRI PDI
        /*ok ⁦⁩*/

        // LRI LRI PDI PDI
        /*ok ⁦⁦⁩⁩*/

        // RLI FSI PDI PDI
        /*ok ⁧⁨⁩⁩*/
    }
}
// ----
