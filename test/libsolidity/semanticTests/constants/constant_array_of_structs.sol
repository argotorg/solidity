contract C {
    struct Point { uint256 x; uint256 y; }
    Point[3] constant POINTS = [Point(10, 20), Point(30, 40), Point(50, 60)];

    function getX(uint256 i) public pure returns (uint256) { return POINTS[i].x; }
    function getY(uint256 i) public pure returns (uint256) { return POINTS[i].y; }
}
// ====
// compileViaYul: true
// ----
// getX(uint256): 0 -> 10
// getY(uint256): 0 -> 20
// getX(uint256): 1 -> 30
// getY(uint256): 1 -> 40
// getX(uint256): 2 -> 50
// getY(uint256): 2 -> 60
