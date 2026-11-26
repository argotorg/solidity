#!/usr/bin/env python3

import json
import os
import re
import subprocess
from pathlib import Path


INPUT_TEMPLATE = Path(__file__).with_name("sources.json")
# Function names and byte ranges in sources.json.
FUNCTIONS = {
    "a.sol": {"A1": ("a", (72, 121)), "A2": ("a", (138, 187))},
    "b.sol": {"A1": ("b", (72, 121)), "B2": ("b", (138, 187))},
}
PROGRAMS = {"creation": ("bytecode",), "runtime": ("deployedBytecode",), "both": ("bytecode", "deployedBytecode")}
IR_OUTPUTS = {"ir": ("ir",), "irOptimized": ("irOptimized",), "both": ("ir", "irOptimized")}
CASES = (
    ("explicit", "both", "both"),
    ("no-optimizer", "both", "ir"),
    ("no-optimizer", "both", "irOptimized"),
    ("no-optimizer", "creation", "ir"),
    ("no-optimizer", "creation", "irOptimized"),
    ("no-optimizer", "runtime", "ir"),
    ("no-optimizer", "runtime", "irOptimized"),
    ("default", "creation", "ir"),
    ("default", "creation", "irOptimized"),
)
ETHDEBUG_MARKER = "/// ethdebug: enabled"
OBJECT_ANNOTATION = re.compile(
    r'^[ \t]*/// @use-src (?P<source_id>[0-9]+):"(?P<source>[^"\n]+)"[ \t]*\n'
    r'[ \t]*object "(?P<name>[^"\n]+)" \{',
    re.MULTILINE,
)
FUNCTION_ANNOTATION = re.compile(
    r"^[ \t]*/// @ast-id (?P<ast_id>[0-9]+)(?:[ \t]+|\n[ \t]*///[ \t]+)"
    r"@src (?P<source_id>[0-9]+):(?P<start>[0-9]+):(?P<end>[0-9]+)(?=[ \t\n])[^\n]*\n"
    r"[ \t]*function (?P<name>[^(\s]+)\(",
    re.MULTILINE,
)


def build_input(settings_variant, programs, ir_outputs):
    input_json = json.loads(INPUT_TEMPLATE.read_text(encoding="utf8"))
    settings = input_json["settings"]
    if settings_variant == "explicit":
        settings["debug"] = {"debugInfo": ["ast-id", "ethdebug"]}
    elif settings_variant == "no-optimizer":
        settings["optimizer"] = {"enabled": False}
    settings["outputSelection"] = {"*": {"*": [
        *(f"evm.{program}.ethdebug" for program in programs),
        *ir_outputs,
        "ethdebug.resources",
    ]}}
    return input_json


def require_keys(value, expected, label):
    if not isinstance(value, dict) or value.keys() != set(expected):
        actual = sorted(value) if isinstance(value, dict) else type(value).__name__
        raise ValueError(f"{label}: expected keys {sorted(expected)}, got {actual}")


def read_ir_annotations(ir, kind, explicit, source, source_id, contract, function, expected_range):
    if not isinstance(ir, str) or not ir:
        raise ValueError("expected non-empty IR")
    if explicit and ir.splitlines()[0].strip() != ETHDEBUG_MARKER:
        raise ValueError("missing ETHDebug marker")
    if not explicit and ETHDEBUG_MARKER in ir:
        raise ValueError("unexpected ETHDebug marker")

    objects = list(OBJECT_ANNOTATION.finditer(ir))
    if len(objects) != 2:
        raise ValueError(f"expected two annotated Yul objects, got {len(objects)}")
    (creation, runtime) = objects
    if not re.fullmatch(re.escape(contract) + r"_[0-9]+", creation["name"]) or runtime["name"] != creation["name"] + "_deployed":
        raise ValueError(f"unexpected creation/runtime object names: {creation['name']}, {runtime['name']}")
    for obj in objects:
        if (obj["source_id"], obj["source"]) != (source_id, source):
            raise ValueError(f"{obj['name']}: expected source {source_id}:{source}, got {obj['source_id']}:{obj['source']}")

    # Anchor the source range to the actual Yul function, not just any @src.
    for annotation in FUNCTION_ANNOTATION.finditer(ir, runtime.end()):
        function_name = f"fun_{function}"
        if kind == "ir":
            function_name += f"_{annotation['ast_id']}"
        if annotation["name"] == function_name:
            if annotation["source_id"] != source_id:
                raise ValueError(f"{function_name}: expected source ID {source_id}, got {annotation['source_id']}")
            source_range = (int(annotation["start"]), int(annotation["end"]))
            if source_range != expected_range:
                raise ValueError(f"{function_name}: expected source range {expected_range}, got {source_range}")
            return (creation["name"], annotation["ast_id"])
    raise ValueError(f"missing AST ID or source range for fun_{function}")


def check_output(output, programs, ir_outputs, explicit):
    errors = [diagnostic for diagnostic in output.get("errors", []) if diagnostic["severity"] == "error"]
    if errors:
        raise ValueError(errors[0]["formattedMessage"])

    require_keys(output.get("ethdebug"), {"resources"}, "global ETHDebug output")
    if not isinstance(output["ethdebug"]["resources"], dict):
        raise ValueError("Expected an ETHDebug resources object.")
    require_keys(output.get("contracts"), FUNCTIONS.keys(), "contract sources")
    require_keys(output.get("sources"), FUNCTIONS.keys(), "source records")

    for (source, functions) in FUNCTIONS.items():
        contracts = output["contracts"][source]
        require_keys(contracts, functions.keys(), source)
        for (name, (function, expected_range)) in functions.items():
            label = f"{source}:{name}"
            contract = contracts[name]
            require_keys(contract, {"evm", *ir_outputs}, label)
            require_keys(contract["evm"], programs, f"{label}.evm")
            for (kind, bytecode) in contract["evm"].items():
                require_keys(bytecode, {"ethdebug"}, f"{label}.evm.{kind}")
                if not isinstance(bytecode["ethdebug"], dict):
                    raise ValueError(f"{label}.evm.{kind}.ethdebug: expected a program object")
            source_id = str(output["sources"][source]["id"])
            annotations = []
            for kind in ir_outputs:
                try:
                    annotations.append(
                        read_ir_annotations(contract[kind], kind, explicit, source, source_id, name, function, expected_range)
                    )
                except ValueError as error:
                    raise ValueError(f"{label}.{kind}: {error}") from error
            if len(annotations) == 2 and annotations[0] != annotations[1]:
                raise ValueError(f"{label}: IR annotations differ: {annotations[0]} != {annotations[1]}")


def main():
    for (settings_variant, program_selection, ir_selection) in CASES:
        programs = PROGRAMS[program_selection]
        ir_outputs = IR_OUTPUTS[ir_selection]
        case_name = f"{settings_variant}/{program_selection}/{ir_selection}"
        try:
            result = subprocess.run(
                [os.environ["SOLC"], "--standard-json"],
                input=json.dumps(build_input(settings_variant, programs, ir_outputs)),
                text=True,
                capture_output=True,
                check=True,
            )
            check_output(
                json.loads(result.stdout), programs, ir_outputs, settings_variant == "explicit"
            )
        except (KeyError, OSError, ValueError, subprocess.CalledProcessError) as error:
            raise SystemExit(f"{case_name}: {error}") from error
        print(f"ETHDebug output selection: {case_name}: passed")


if __name__ == "__main__":
    main()
