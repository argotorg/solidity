#!/usr/bin/env python3
"""
Validates the compiler's ethdebug output against the schemas of ethdebug/format
and checks the properties that hold for the output of any input.

Anything specific to one input belongs in the isoltest cases under
test/libsolidity/ethdebugTests/ instead.

Usage: test_ethdebug_schema_conformity.py --solc-binary-path <solc> [unittest options]
"""

import argparse
import json
import re
import subprocess
import sys
import unittest
from functools import cache
from pathlib import Path

import jsonschema
import referencing
import yaml
from referencing.jsonschema import DRAFT202012

TEST_DIR = Path(__file__).parent
SCHEMA_DIR = TEST_DIR / "ethdebug-format" / "schemas"
STANDARD_JSON_INPUT = TEST_DIR / "input_file.json"
# The isoltest cases in this directory pin down the resources of specific inputs;
# their output is checked against the schema here as well.
RESOURCES_TEST_SOURCES = sorted((TEST_DIR.parent / "libsolidity" / "ethdebugTests" / "resources").glob("*.sol"))

PROGRAM_OUTPUTS = {"evm.bytecode.ethdebug": "create", "evm.deployedBytecode.ethdebug": "call"}

# Set by main() from the command line.
SOLC_PATH = None


def solc_path():
    assert SOLC_PATH is not None, "Run with --solc-binary-path."
    assert SOLC_PATH.is_file(), f"Not a file: {SOLC_PATH}"
    return SOLC_PATH


@cache
def schema_registry():
    assert SCHEMA_DIR.is_dir(), (
        "ethdebug/format schemas are missing. "
        "Run `git submodule update --init test/ethdebugSchemaTests/ethdebug-format`."
    )
    registry = referencing.Registry()
    for path in SCHEMA_DIR.rglob("*.yaml"):
        with open(path, "r", encoding="utf8") as f:
            schema = yaml.safe_load(f)
        if "$id" not in schema:
            raise ValueError(f"Schema did not define an $id: {path}")
        registry = referencing.Resource.from_contents(schema, DRAFT202012) @ registry
    return registry


def validate(schema_id, instance):
    jsonschema.Draft202012Validator(schema={"$ref": schema_id}, registry=schema_registry()).validate(instance)


def load_standard_json_input(path):
    with open(path, "r", encoding="utf8") as f:
        standard_json_input = json.load(f)
    for source in standard_json_input["sources"].values():
        if "contentFile" in source:
            source["content"] = (path.parent / source.pop("contentFile")).read_text(encoding="utf8")
    return standard_json_input


@cache
def standard_json_output(input_path):
    standard_json_input = load_standard_json_input(input_path)
    process = subprocess.run(
        [solc_path(), "--standard-json"],
        input=json.dumps(standard_json_input),
        encoding="utf8",
        capture_output=True,
        check=True,
    )
    output = json.loads(process.stdout)
    errors = [error for error in output.get("errors", []) if error["severity"] == "error"]
    assert not errors, f"Compilation of {input_path} failed: {errors}"
    return standard_json_input, output


@cache
def resources_of_source(source_path):
    process = subprocess.run(
        [solc_path(), "--experimental", "--ethdebug-resources", str(source_path)],
        encoding="utf8",
        capture_output=True,
        check=True,
    )
    resources, _ = json.JSONDecoder().raw_decode(process.stdout[process.stdout.index("{"):])
    return resources


def get_nested_value(dictionary, *keys):
    for key in keys:
        dictionary = dictionary[key]
    return dictionary


def contract_outputs(solc_output):
    for source_name, source_contracts in solc_output["contracts"].items():
        for contract_name, contract_output in source_contracts.items():
            yield source_name, contract_name, contract_output


def ethdebug_programs(solc_output, output_selection):
    for source_name, contract_name, contract_output in contract_outputs(solc_output):
        # Interfaces and abstract contracts have no bytecode and therefore no program.
        try:
            program = get_nested_value(contract_output, *output_selection.split("."))
        except KeyError:
            continue
        if program is not None:
            yield source_name, contract_name, program


def referenced_type_ids(document):
    """The IDs of the type references `{"type": {"id": ...}}` inside a type document."""
    if isinstance(document, dict):
        for key, value in document.items():
            if key == "type" and isinstance(value, dict) and set(value) == {"id"}:
                yield value["id"]
            else:
                yield from referenced_type_ids(value)
    elif isinstance(document, list):
        for value in document:
            yield from referenced_type_ids(value)


# The compiler's type identifiers (Type::richIdentifier()) determine the document.
TYPE_ID_PATTERNS = {
    "uint": re.compile(r"^t_uint(\d+)$"),
    "int": re.compile(r"^t_int(\d+)$"),
    "bool": re.compile(r"^t_bool$"),
    "address": re.compile(r"^t_address(_payable)?$"),
    "fixed_bytes": re.compile(r"^t_bytes(\d+)$"),
    "bytes": re.compile(r"^t_bytes_(storage|memory|calldata)(_ptr)?$"),
    "string": re.compile(r"^t_string_(storage|memory|calldata)(_ptr)?$"),
    "fixed": re.compile(r"^t_(u?fixed)(\d+)x(\d+)$"),
    "array": re.compile(r"^t_array\$_(.+)_\$(dyn|\d+)_(storage|memory|calldata)(_ptr)?$"),
    "mapping": re.compile(r"^t_mapping\$_(.+?)_\$_(.+)_\$$"),
    "struct": re.compile(r"^t_struct\$_(\w+)_\$\d+_(storage|memory|calldata)(_ptr)?$"),
    "enum": re.compile(r"^t_enum\$_(\w+)_\$\d+$"),
    "contract": re.compile(r"^t_contract\$_(\w+)_\$\d+$"),
    "alias": re.compile(r"^t_userDefinedValueType\$_(\w+)_\$\d+$"),
    "function": re.compile(r"^t_function_(internal|external)_\w+\$_.*$"),
}


def escaped_type_id(rich_identifier):
    """The ethdebug type identifier of a type the storage layout names by its rich identifier,
    e.g. `t_enum$_Color_$7` for `t_enum(Color)7` (Type::escapeIdentifier())."""
    return rich_identifier.replace("(", "$_").replace(")", "_$").replace(",", "_$_")


def classify_type_id(type_id):
    for kind, pattern in TYPE_ID_PATTERNS.items():
        match = pattern.match(type_id)
        if match:
            return kind, match
    return None, None


def pointer_expression_names(expression):
    """The variable and region names an expression refers to: (variables, regions)."""
    variables, regions = set(), set()
    if isinstance(expression, str):
        if not expression.startswith("0x") and not expression.isdigit() and expression != "$wordsize":
            variables.add(expression)
    elif isinstance(expression, dict):
        for key, operand in expression.items():
            if key in (".slot", ".offset", ".length", "$read"):
                regions.add(operand)
            elif isinstance(operand, list):
                for element in operand:
                    element_variables, element_regions = pointer_expression_names(element)
                    variables |= element_variables
                    regions |= element_regions
            else:
                operand_variables, operand_regions = pointer_expression_names(operand)
                variables |= operand_variables
                regions |= operand_regions
    return variables, regions


def region_names(pointer):
    names = set()
    if isinstance(pointer, dict):
        if "location" in pointer and "name" in pointer:
            names.add(pointer["name"])
        for value in pointer.values():
            names |= region_names(value)
    elif isinstance(pointer, list):
        for value in pointer:
            names |= region_names(value)
    return names


class EthdebugTestCase(unittest.TestCase):
    #: The pointer table the templates under test reference, set by the test.
    templates = {}

    def assertPointerIsClosed(self, pointer, bound_variables, regions):
        """Every variable in the pointer is bound by a template parameter, a `define` or a
        `list`, and every region a lookup or `$read` refers to is named in the pointer."""

        def check_expression(expression):
            variables, referenced_regions = pointer_expression_names(expression)
            self.assertLessEqual(variables, bound_variables, f"Unbound variable in {expression}")
            self.assertLessEqual(referenced_regions, regions | {"$this"}, f"Unknown region in {expression}")

        if "location" in pointer:
            for key in ("slot", "offset", "length"):
                if key in pointer:
                    check_expression(pointer[key])
        elif "group" in pointer:
            for member in pointer["group"]:
                self.assertPointerIsClosed(member, bound_variables, regions)
        elif "list" in pointer:
            check_expression(pointer["list"]["count"])
            self.assertPointerIsClosed(pointer["list"]["is"], bound_variables | {pointer["list"]["each"]}, regions)
        elif "if" in pointer:
            check_expression(pointer["if"])
            self.assertPointerIsClosed(pointer["then"], bound_variables, regions)
            if "else" in pointer:
                self.assertPointerIsClosed(pointer["else"], bound_variables, regions)
        elif "define" in pointer:
            for expression in pointer["define"].values():
                check_expression(expression)
            self.assertPointerIsClosed(pointer["in"], bound_variables | set(pointer["define"]), regions)
        elif "templates" in pointer:
            self.assertPointerIsClosed(pointer["in"], bound_variables, regions)
        else:
            self.assertIn("template", pointer, f"Unknown pointer shape: {pointer}")
            # The referenced template's parameters are bound where it is referenced.
            self.assertIn(pointer["template"], self.templates, f"Unknown template {pointer['template']}")
            self.assertLessEqual(set(self.templates[pointer["template"]]["expect"]), bound_variables)

    def assertRegionCoversLayoutOffset(self, region, layout_offset):
        """A region's offset counts from the most significant byte of the slot, the storage
        layout's from the least significant one; a value of `length` bytes at layout offset
        `o` therefore starts at byte `32 - o - length`. A region without a length covers
        the rest of its slot, and one whose length exceeds a slot starts at the beginning
        of the first one."""
        if "length" not in region:
            self.assertNotIn("offset", region)
            self.assertEqual(layout_offset, 0)
            return
        offset = int(region.get("offset", "0x00"), 16)
        length = int(region["length"], 16)
        if length >= 32:
            self.assertEqual(offset, 0)
            self.assertEqual(layout_offset, 0)
        else:
            self.assertEqual(offset + length + layout_offset, 32)

    def assertTemplateIsClosed(self, template):
        self.assertEqual(len(template["expect"]), len(set(template["expect"])))
        self.assertPointerIsClosed(template["for"], set(template["expect"]), region_names(template["for"]))

    def assertTypeDocumentMatchesID(self, type_id, document, types):
        kind, match = classify_type_id(type_id)
        self.assertIsNotNone(kind, f"Type identifier of unknown form: {type_id}")
        if kind in ("uint", "int"):
            self.assertEqual(document, {"kind": kind, "bits": int(match.group(1))})
        elif kind == "bool":
            self.assertEqual(document, {"kind": "bool"})
        elif kind == "address":
            self.assertEqual(document, {"kind": "address", "payable": match.group(1) is not None})
        elif kind == "fixed_bytes":
            self.assertEqual(document, {"kind": "bytes", "size": int(match.group(1))})
        elif kind in ("bytes", "string"):
            self.assertEqual(document, {"kind": kind})
        elif kind == "fixed":
            self.assertEqual(document, {"kind": match.group(1), "bits": int(match.group(2)), "places": int(match.group(3))})
        elif kind == "array":
            self.assertEqual(document["kind"], "array")
            self.assertEqual(document["contains"], {"type": {"id": match.group(1)}})
            if match.group(2) == "dyn":
                self.assertNotIn("count", document)
            else:
                self.assertEqual(int(document["count"], 16), int(match.group(2)))
        elif kind == "mapping":
            self.assertEqual(document["kind"], "mapping")
            self.assertEqual(document["contains"]["key"], {"type": {"id": match.group(1)}})
            self.assertEqual(document["contains"]["value"], {"type": {"id": match.group(2)}})
        elif kind == "struct":
            self.assertEqual(document["kind"], "struct")
            self.assertEqual(document["definition"]["name"], match.group(1))
            for member in document["contains"]:
                self.assertIn("name", member)
        elif kind == "enum":
            self.assertEqual(document["kind"], "enum")
            self.assertEqual(document["definition"]["name"], match.group(1))
            self.assertGreater(len(document["values"]), 0)
        elif kind in ("contract", "alias"):
            self.assertEqual(document["kind"], kind)
            self.assertEqual(document["definition"]["name"], match.group(1))
        elif kind == "function":
            self.assertEqual(document["kind"], "function")
            self.assertIs(document.get(match.group(1)), True)
            self.assertEqual(document["contains"]["parameters"]["type"]["kind"], "tuple")
        for referenced_id in referenced_type_ids(document):
            self.assertIn(referenced_id, types, f"{type_id} references unknown type {referenced_id}")


class StandardJSONOutputTest(EthdebugTestCase):
    """The ethdebug outputs of a Standard JSON compilation."""

    @classmethod
    def setUpClass(cls):
        cls.standard_json_input, cls.solc_output = standard_json_output(STANDARD_JSON_INPUT)
        cls.resources = cls.solc_output["ethdebug"]["resources"]

    def test_programs_conform_to_schema(self):
        for output_selection in PROGRAM_OUTPUTS:
            for _, contract_name, program in ethdebug_programs(self.solc_output, output_selection):
                with self.subTest(output=output_selection, contract=contract_name):
                    validate("schema:ethdebug/format/program", program)

    def test_resources_conform_to_schema(self):
        validate("schema:ethdebug/format/info/resources", self.resources)

    def test_compilation_conforms_to_schema(self):
        validate("schema:ethdebug/format/materials/compilation", self.solc_output["ethdebug"]["compilation"])

    def test_programs_describe_their_contracts(self):
        source_ids = {source_name: source["id"] for source_name, source in self.solc_output["sources"].items()}
        for output_selection, environment in PROGRAM_OUTPUTS.items():
            for source_name, contract_name, program in ethdebug_programs(self.solc_output, output_selection):
                with self.subTest(output=output_selection, contract=contract_name):
                    self.assertEqual(program["environment"], environment)
                    self.assertEqual(program["contract"]["name"], contract_name)
                    self.assertEqual(program["contract"]["definition"]["source"]["id"], source_ids[source_name])

                    instructions = program["instructions"]
                    self.assertGreater(len(instructions), 0)
                    offsets = [instruction["offset"] for instruction in instructions]
                    self.assertEqual(offsets, sorted(offsets))
                    for instruction in instructions:
                        self.assertTrue(instruction["operation"]["mnemonic"])

    def test_resources_list_the_standard_json_sources(self):
        standard_json_sources = {source_name: source["id"] for source_name, source in self.solc_output["sources"].items()}
        ethdebug_sources = {source["path"]: source["id"] for source in self.resources["compilation"]["sources"]}
        self.assertEqual(ethdebug_sources, standard_json_sources)

    def test_resources_include_the_source_contents(self):
        ethdebug_sources = {source["path"]: source for source in self.resources["compilation"]["sources"]}
        self.assertEqual(set(ethdebug_sources), set(self.standard_json_input["sources"]))
        for source_name, source_input in self.standard_json_input["sources"].items():
            self.assertEqual(ethdebug_sources[source_name]["contents"], source_input["content"])
            self.assertEqual(ethdebug_sources[source_name]["language"], "Solidity")

    def test_resources_and_compilation_output_share_the_compilation(self):
        self.assertEqual(self.resources["compilation"], self.solc_output["ethdebug"]["compilation"])

    def test_type_documents_match_their_identifiers(self):
        types = self.resources["types"]
        self.assertGreater(len(types), 0)
        for type_id, document in types.items():
            with self.subTest(type=type_id):
                self.assertTypeDocumentMatchesID(type_id, document, types)

    def test_definition_locations_refer_to_the_compilation_sources(self):
        source_ids = {source["id"] for source in self.resources["compilation"]["sources"]}
        for type_id, document in self.resources["types"].items():
            location = document.get("definition", {}).get("location")
            if location is not None:
                with self.subTest(type=type_id):
                    self.assertIn(location["source"]["id"], source_ids)

    def test_pointer_templates_are_closed(self):
        self.templates = self.resources["pointers"]
        for name, template in self.templates.items():
            with self.subTest(pointer=name):
                self.assertTemplateIsClosed(template)

    def test_pointer_templates_describe_the_storage_types(self):
        """A template is keyed by the identifier of a struct, array or mapping type and
        expects the base slot of a value, a mapping's the key of the entry as well; the
        types the storage layouts list have one unless they are value types, which are
        single regions wherever they occur."""
        types = self.resources["types"]
        pointers = self.resources["pointers"]
        for name, template in pointers.items():
            with self.subTest(pointer=name):
                self.assertIn(name, types)
                kind = types[name]["kind"]
                self.assertIn(kind, ("struct", "array", "mapping", "bytes", "string"))
                self.assertEqual(template["expect"], ["slot", "key"] if kind == "mapping" else ["slot"])
        layouts = {"storage": "storageLayout", "transient": "transientStorageLayout"}
        for _, contract_name, contract_output in contract_outputs(self.solc_output):
            for layout_output in layouts.values():
                for variable in contract_output[layout_output]["storage"]:
                    type_id = escaped_type_id(variable["type"])
                    with self.subTest(contract=contract_name, variable=variable["label"]):
                        kind = types[type_id]["kind"]
                        dynamic = kind in ("bytes", "string") and "size" not in types[type_id]
                        composed = kind in ("struct", "array", "mapping") or dynamic
                        self.assertEqual(type_id in pointers, composed)


class ResourcesTestSourcesTest(EthdebugTestCase):
    """The resources of the isoltest cases under ethdebugTests/resources/."""

    def test_resources_conform_to_schema(self):
        assert RESOURCES_TEST_SOURCES, "No test sources found."
        for source_path in RESOURCES_TEST_SOURCES:
            with self.subTest(source=source_path.name):
                resources = resources_of_source(source_path)
                validate("schema:ethdebug/format/info/resources", resources)
                self.assertGreater(len(resources["types"]), 0)

    def test_type_documents_match_their_identifiers(self):
        for source_path in RESOURCES_TEST_SOURCES:
            types = resources_of_source(source_path)["types"]
            for type_id, document in types.items():
                with self.subTest(source=source_path.name, type=type_id):
                    self.assertTypeDocumentMatchesID(type_id, document, types)

    def test_pointer_templates_are_closed(self):
        for source_path in RESOURCES_TEST_SOURCES:
            self.templates = resources_of_source(source_path)["pointers"]
            for name, template in self.templates.items():
                with self.subTest(source=source_path.name, pointer=name):
                    self.assertTemplateIsClosed(template)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--solc-binary-path", type=Path, required=True, help="Path to the solidity compiler binary.")
    options, unittest_args = parser.parse_known_args()

    global SOLC_PATH  # pylint: disable=global-statement
    SOLC_PATH = options.solc_binary_path
    unittest.main(argv=[sys.argv[0]] + unittest_args)


if __name__ == "__main__":
    main()
