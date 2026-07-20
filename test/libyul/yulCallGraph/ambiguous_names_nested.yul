{
    {
        function f() {
            function g() {}
        }
    }
    {
        function g() {}
    }
}
// ----
// InputNotDisambiguatedException: CallGraphGenerator requires a disambiguated AST: duplicate function name g.
