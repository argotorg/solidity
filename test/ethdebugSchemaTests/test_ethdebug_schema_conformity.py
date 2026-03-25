#!/usr/bin/env python3

import json
import subprocess
from pathlib import Path

import jsonschema
import pytest


ETHDEBUG_OUTPUT_PATHS = (
    ("evm", "bytecode", "ethdebug"),
    ("evm", "deployedBytecode", "ethdebug"),
)

def is_successful_ethdebug_standard_json_test_case(test_case_dir):
    if "ethdebug" not in test_case_dir.name:
        return False
    if not (test_case_dir / "input.json").is_file() or not (test_case_dir / "output.json").is_file():
        return False

    output = (test_case_dir / "output.json").read_text(encoding="utf8")
    if "\"contracts\"" not in output or "\"errors\"" in output:
        return False

    return "\"ethdebug\": null" not in output or "<ETHDEBUG DEBUG DATA REMOVED>" in output


def resolve_standard_json_sources(test_input, input_path):
    test_input = dict(test_input)
    test_input["sources"] = dict(test_input["sources"])

    for source_name, source_description in list(test_input["sources"].items()):
        if "urls" not in source_description:
            continue

        assert len(source_description["urls"]) == 1
        source_path = input_path.parent / source_description["urls"][0]
        test_input["sources"][source_name] = {"content": source_path.read_text(encoding="utf8")}

    return test_input


def ethdebug_standard_json_inputs():
    testfile_dir = Path(__file__).parent
    cmdline_tests_dir = testfile_dir.parent / "cmdlineTests"

    input_paths = [
        testfile_dir / "input_file.json",
        testfile_dir / "input_file_eof.json",
    ]
    input_paths.extend(
        test_case_dir / "input.json"
        for test_case_dir in sorted(cmdline_tests_dir.iterdir())
        if test_case_dir.is_dir() and is_successful_ethdebug_standard_json_test_case(test_case_dir)
    )
    return input_paths


@pytest.fixture(
    params=ethdebug_standard_json_inputs(),
    ids=lambda input_path: str(input_path.relative_to(Path(__file__).parent.parent))
)
def solc_output(request, solc_path):
    input_path = request.param
    with open(input_path, "r", encoding="utf8") as f:
        source = resolve_standard_json_sources(json.load(f), input_path)

    process = subprocess.run(
        [solc_path, "--standard-json"],
        input=json.dumps(source),
        encoding="utf8",
        capture_output=True,
        check=True,
    )
    assert process.returncode == 0
    return json.loads(process.stdout)


def test_program_schema(ethdebug_schema_repository, solc_output):
    validator = jsonschema.Draft202012Validator(
        schema={"$ref": "schema:ethdebug/format/program"},
        registry=ethdebug_schema_repository
    )
    assert "contracts" in solc_output
    found_ethdebug_output = False
    for contract in solc_output["contracts"].keys():
        contract_output = solc_output["contracts"][contract]
        assert len(contract_output) > 0
        for source in contract_output.keys():
            source_output = contract_output[source]
            for output_path in ETHDEBUG_OUTPUT_PATHS:
                current = source_output
                for key in output_path[:-1]:
                    current = current.get(key)
                    if current is None:
                        break
                if current is None or output_path[-1] not in current:
                    continue

                ethdebug_data = current[output_path[-1]]
                if ethdebug_data is None:
                    continue

                found_ethdebug_output = True
                validator.validate(ethdebug_data)

    assert found_ethdebug_output
