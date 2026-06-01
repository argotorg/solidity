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


def validator(schema_id, ethdebug_schema_repository):
    return jsonschema.Draft202012Validator(
        schema={"$ref": schema_id},
        registry=ethdebug_schema_repository
    )


def ethdebug_programs(solc_output, output_selection):
    assert "contracts" in solc_output
    for source_name, source_contracts in solc_output["contracts"].items():
        assert len(source_contracts) > 0
        for contract_name, contract_output in source_contracts.items():
            yield source_name, contract_name, get_nested_value(contract_output, *(output_selection.split(".")))


def load_standard_json_input(path):
    with open(path, "r", encoding="utf8") as f:
        standard_json_input = json.load(f)

    for source in standard_json_input["sources"].values():
        if "contentFile" in source:
            source["content"] = (path.parent / source.pop("contentFile")).read_text(encoding="utf8")

    return standard_json_input


@pytest.fixture(params=["input_file.json"])
def standard_json_input(request):
    testfile_dir = Path(__file__).parent
    return load_standard_json_input(testfile_dir / request.param)


@pytest.fixture
def solc_output(standard_json_input, solc_path):
    process = subprocess.run(
        [solc_path, "--standard-json"],
        input=json.dumps(standard_json_input),
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
    program_validator = validator("schema:ethdebug/format/program", ethdebug_schema_repository)
    for _, _, ethdebug_data in ethdebug_programs(solc_output, output_selection):
        program_validator.validate(ethdebug_data)


def test_resources_schema(ethdebug_schema_repository, solc_output):
    resources_validator = validator("schema:ethdebug/format/info/resources", ethdebug_schema_repository)
    resources_validator.validate(solc_output["ethdebug"]["resources"])


def test_compilation_schema(ethdebug_schema_repository, solc_output):
    compilation_validator = validator("schema:ethdebug/format/materials/compilation", ethdebug_schema_repository)
    compilation_validator.validate(solc_output["ethdebug"]["compilation"])


@pytest.mark.parametrize(
    ("output_selection", "environment"),
    [
        ("evm.bytecode.ethdebug", "create"),
        ("evm.deployedBytecode.ethdebug", "call"),
    ],
    ids=str
)
def test_program_sanity(output_selection, environment, solc_output):
    source_ids = {source_name: source["id"] for source_name, source in solc_output["sources"].items()}

    for source_name, contract_name, ethdebug_data in ethdebug_programs(solc_output, output_selection):
        assert ethdebug_data["environment"] == environment
        assert ethdebug_data["contract"]["name"] == contract_name
        assert ethdebug_data["contract"]["definition"]["source"]["id"] == source_ids[source_name]

        instructions = ethdebug_data["instructions"]
        assert len(instructions) > 0
        assert [instruction["offset"] for instruction in instructions] == sorted(
            instruction["offset"] for instruction in instructions
        )
        assert all(instruction["operation"]["mnemonic"] for instruction in instructions)


def test_resources_match_standard_json_sources(solc_output):
    standard_json_sources = {source_name: source["id"] for source_name, source in solc_output["sources"].items()}
    ethdebug_sources = {
        source["path"]: source["id"]
        for source in solc_output["ethdebug"]["resources"]["compilation"]["sources"]
    }
    assert ethdebug_sources == standard_json_sources


def test_resources_include_standard_json_source_contents(standard_json_input, solc_output):
    ethdebug_sources = {
        source["path"]: source
        for source in solc_output["ethdebug"]["resources"]["compilation"]["sources"]
    }

    assert set(ethdebug_sources) == set(standard_json_input["sources"])
    for source_name, source_input in standard_json_input["sources"].items():
        assert ethdebug_sources[source_name]["contents"] == source_input["content"]
        assert ethdebug_sources[source_name]["language"] == "Solidity"


def test_resources_include_empty_type_and_pointer_tables(solc_output):
    assert solc_output["ethdebug"]["resources"]["types"] == {}
    assert solc_output["ethdebug"]["resources"]["pointers"] == {}


def test_resources_and_compilation_share_compilation(solc_output):
    assert solc_output["ethdebug"]["resources"]["compilation"] == solc_output["ethdebug"]["compilation"]
