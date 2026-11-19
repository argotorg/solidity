contract C {
    struct Leaf {
        Leaf[] ll;
        uint256 v;
    }
    struct Other {
        Leaf[] l;
    }
    struct Node {
        Node[] children;
        Other o;
    }

    Node n1;
    Node n2;

    function f() external returns (uint256 leafValue, uint256 nestedLeafValue, uint256 nestedLeafCount, uint256 childCount) {
        n2.children.push();
        n2.o.l.push();
        n2.o.l[0].v = 7;
        n2.o.l[0].ll.push();
        n2.o.l[0].ll[0].v = 11;

        n1 = n2;

        leafValue = n1.o.l[0].v;
        nestedLeafValue = n1.o.l[0].ll[0].v;
        nestedLeafCount = n1.o.l[0].ll.length;
        childCount = n1.children.length;
    }
}
// ----
// f() -> 7, 11, 1, 1
// gas irOptimized: 260815
// gas legacy: 264508
// gas legacyOptimized: 260492
// gas ssaCFGOptimized: 260746
