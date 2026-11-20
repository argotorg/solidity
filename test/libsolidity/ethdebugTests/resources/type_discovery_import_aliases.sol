==== Source: consumer.sol ====
import {Amount as ImportedAmount, Color as ImportedColor, Point as ImportedPoint, Target as ImportedTarget} from "definitions.sol";
import * as Types from "definitions.sol";

contract C {
    ImportedAmount importedAmount;
    Types.Amount originalAmount;
    ImportedColor importedColor;
    Types.Color originalColor;
    ImportedPoint importedPoint;
    Types.Point originalPoint;
    ImportedTarget importedTarget;
    Types.Target originalTarget;
}
==== Source: definitions.sol ====
type Amount is uint128;
enum Color { Red, Green }
struct Point { uint8 x; uint8 y; }
contract Target {}
// ----
// .compilation.sources[1].path: definitions.sol
// .resources.types | keys: ["t_contract$_Target_$45","t_enum$_Color_$39","t_struct$_Point_$44_storage","t_uint128","t_uint8","t_userDefinedValueType$_Amount_$36"]
// .resources.types.t_contract$_Target_$45.definition.name: Target
// .resources.types.t_contract$_Target_$45.definition.location.source.id: 1
// .resources.types.t_enum$_Color_$39.definition.name: Color
// .resources.types.t_enum$_Color_$39.definition.location.source.id: 1
// .resources.types.t_struct$_Point_$44_storage.definition.name: Point
// .resources.types.t_struct$_Point_$44_storage.definition.location.source.id: 1
// .resources.types.t_userDefinedValueType$_Amount_$36.definition.name: Amount
// .resources.types.t_userDefinedValueType$_Amount_$36.definition.location.source.id: 1
// .resources.pointers | keys: ["storage-t_contract$_Target_$45","storage-t_enum$_Color_$39","storage-t_struct$_Point_$44_storage","storage-t_uint8","storage-t_userDefinedValueType$_Amount_$36"]
