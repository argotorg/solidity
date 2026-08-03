// Regression test: a switch reached only from the constructor, with enough small
// literal cases that SwitchSplitter should split it even in creation code.
contract test {
    uint256 public immutable result;

    constructor(uint256 x) {
        uint256 r;
        assembly {
            switch x
            case 1 { r := 10 }
            case 2 { r := 20 }
            case 3 { r := 30 }
            case 4 { r := 40 }
            case 5 { r := 50 }
            case 6 { r := 60 }
            case 7 { r := 70 }
            case 8 { r := 80 }
            case 9 { r := 90 }
            case 10 { r := 100 }
            case 11 { r := 110 }
            case 12 { r := 120 }
            case 13 { r := 130 }
            case 14 { r := 140 }
            case 15 { r := 150 }
            case 16 { r := 160 }
            case 17 { r := 170 }
            case 18 { r := 180 }
            case 19 { r := 190 }
            case 20 { r := 200 }
            case 21 { r := 210 }
            case 22 { r := 220 }
            case 23 { r := 230 }
            case 24 { r := 240 }
            case 25 { r := 250 }
            case 26 { r := 260 }
            case 27 { r := 270 }
            case 28 { r := 280 }
            case 29 { r := 290 }
            case 30 { r := 300 }
            case 31 { r := 310 }
            case 32 { r := 320 }
            case 33 { r := 330 }
            case 34 { r := 340 }
            case 35 { r := 350 }
            case 36 { r := 360 }
            case 37 { r := 370 }
            case 38 { r := 380 }
            case 39 { r := 390 }
            case 40 { r := 400 }
            case 41 { r := 410 }
            case 42 { r := 420 }
            case 43 { r := 430 }
            case 44 { r := 440 }
            case 45 { r := 450 }
            case 46 { r := 460 }
            case 47 { r := 470 }
            case 48 { r := 480 }
        }
        result = r;
    }
}
// ----
// constructor(): 24
// gas irOptimized: 70450
// gas irOptimized code: 18600
// gas legacy: 72499
// gas legacy code: 29800
// gas legacyOptimized: 70165
// gas legacyOptimized code: 19600
// gas ssaCFGOptimized: 68966
// gas ssaCFGOptimized code: 17200
// result() -> 240
