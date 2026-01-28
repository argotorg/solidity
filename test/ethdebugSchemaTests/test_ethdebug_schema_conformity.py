#!/usr/bin/env python3

import json
import subprocess
from pathlib import Path

import jsonschema
import pytest


def get_nested_value(dictionary, *keys):
    for key in keys:
        dictionary = dictionary[key]
    return dictionary


@pytest.fixture(params=["input_file.json", "input_file_eof.json"])
def solc_output(request, solc_path):
    testfile_dir = Path(__file__).parent
    with open(testfile_dir / request.param, "r", encoding="utf8") as f:
        source = json.load(f)

    process = subprocess.run(
        [solc_path, "--standard-json"],
        input=json.dumps(source),
        encoding="utf8",
        capture_output=True,
        check=True,
    )
    assert process.returncode == 0
    return json.loads(process.stdout)


@pytest.mark.parametrize("output_selection", ["evm.bytecode.ethdebug", "evm.deployedBytecode.ethdebug"], ids=str)
def test_program_schema(
    output_selection,
    ethdebug_schema_repository,
    solc_output
):
    validator = jsonschema.Draft202012Validator(
        schema={"$ref": "schema:ethdebug/format/program"},
        registry=ethdebug_schema_repository
    )
    assert "contracts" in solc_output
    for contract in solc_output["contracts"].keys():
        contract_output = solc_output["contracts"][contract]
        assert len(contract_output) > 0
        for source in contract_output.keys():
            source_output = contract_output[source]
            ethdebug_data = get_nested_value(source_output, *(output_selection.split(".")))
            validator.validate(ethdebug_data)
