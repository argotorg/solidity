#!/usr/bin/env python3

import json
import re
import subprocess
import unittest
from functools import cache
from pathlib import Path

import jsonschema

# NOTE: test/ethdebugSchemaTests.py runs the tests with this directory in the import path.
# pragma pylint: disable=import-error
import schema_helpers
# pragma pylint: enable=import-error


TEST_DIR = Path(__file__).parent
RESOURCES_TEST_DIR = TEST_DIR.parent / "libsolidity" / "ethdebugTests" / "resources"


def get_nested_value(dictionary, *keys):
    """
    Return None if any path key is absent.
    """
    for key in keys:
        if key not in dictionary:
            return None
        dictionary = dictionary[key]
    return dictionary


def validator(schema_id, ethdebug_schema_repository):
    return jsonschema.Draft202012Validator(
        schema={"$ref": schema_id},
        registry=ethdebug_schema_repository
    )


def ethdebug_programs(solc_output, output_selection):
    assert "contracts" in solc_output
    for (source_name, source_contracts) in solc_output["contracts"].items():
        assert len(source_contracts) > 0
        for (contract_name, contract_output) in source_contracts.items():
            # Interfaces and abstract contracts have no bytecode and therefore no program.
            program = get_nested_value(contract_output, *(output_selection.split(".")))
            if program is not None:
                yield (source_name, contract_name, program)


def load_standard_json_input(source_paths):
    with open(TEST_DIR / "input_template.json", "r", encoding="utf8") as f:
        standard_json_input = json.load(f)

    assert len(standard_json_input["sources"]) == 0
    for source_path in source_paths:
        contents = source_path.read_bytes()
        # TODO: Share multi-source parsing with scripts/splitSources.py.
        if contents.startswith(b"==== Source:"):
            raise unittest.SkipTest("Multi-source fixtures are not supported yet.")
        contents = re.split(r"^// (?:----|====).*$", contents.decode("utf8"), maxsplit=1, flags=re.MULTILINE)[0]
        name = source_path.name
        assert name not in standard_json_input["sources"], f"Duplicate source: {name}"
        standard_json_input["sources"][name] = {"content": contents}

    return standard_json_input


def compile_standard_json(solc_path, standard_json_input):
    process = subprocess.run(
        [solc_path, "--standard-json"],
        input=json.dumps(standard_json_input),
        encoding="utf8",
        capture_output=True,
        check=True,
    )
    assert process.returncode == 0
    return json.loads(process.stdout)


def contract_outputs(solc_output):
    for (source_name, source_contracts) in solc_output["contracts"].items():
        for (contract_name, contract_output) in source_contracts.items():
            yield (source_name, contract_name, contract_output)


def referenced_type_ids(document):
    """
    The IDs of the type references `{"type": {"id": ...}}` inside a type document.
    """
    if isinstance(document, dict):
        for (key, value) in document.items():
            if key == "type" and isinstance(value, dict):
                assert set(value) == {"id"}, f"Unhandled type specifier: {value}"
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
    "struct": re.compile(r"^t_struct\$_([\w$]+)_\$\d+_(storage|memory|calldata)(_ptr)?$"),
    "enum": re.compile(r"^t_enum\$_([\w$]+)_\$\d+$"),
    "contract": re.compile(r"^t_contract\$_([\w$]+)_\$\d+$"),
    "alias": re.compile(r"^t_userDefinedValueType\$_([\w$]+)_\$\d+$"),
    "function": re.compile(r"^t_function_(internal|external)_\w+\$_.*$"),
    "tuple": re.compile(r"^t_tuple\$_.*_\$$"),
}


def storage_located(type_id):
    """
    The identifier of the variant of a reference type laid out in storage, which is
    what the type table keys a type by whatever its data location.
    """
    return re.sub(r"_(storage|memory|calldata)_ptr", "_storage", type_id)


def escaped_type_id(rich_identifier):
    """
    The ethdebug type identifier of a type the storage layout names by its rich identifier,
    e.g. `t_enum$_Color_$7` for `t_enum(Color)7` (Type::escapeIdentifier()).
    """
    return rich_identifier.replace("$", "$$$").replace("(", "$_").replace(")", "_$").replace(",", "_$_")


def classify_type_id(type_id):
    for (kind, pattern) in TYPE_ID_PATTERNS.items():
        match = pattern.match(type_id)
        if match is not None:
            return (kind, match)
    return (None, None)


def extract_names_referenced_by_pointer_expression(expression):
    """
    Return (referenced_variable_names, referenced_region_names).
    """
    (referenced_variable_names, referenced_region_names) = (set(), set())
    if isinstance(expression, str):
        if expression != "~wordsize" and not expression.startswith("0x"):
            assert not expression.startswith("~"), f"Unhandled expression constant: {expression}"
            referenced_variable_names.add(expression)
    elif isinstance(expression, dict):
        assert len(expression) == 1
        ((key, operand),) = expression.items()
        if key in (".slot", ".offset", ".length", "~read"):
            referenced_region_names.add(operand)
        elif key in ("~sum", "~difference", "~product", "~quotient", "~remainder", "~keccak256", "~concat"):
            assert isinstance(operand, list)
            for element in operand:
                (element_variables, element_regions) = extract_names_referenced_by_pointer_expression(element)
                referenced_variable_names |= element_variables
                referenced_region_names |= element_regions
        else:
            assert key == "~wordsized" or re.fullmatch(r"~sized[1-9][0-9]*", key) is not None, f"Unhandled expression: {key}"
            (referenced_variable_names, referenced_region_names) = extract_names_referenced_by_pointer_expression(operand)
    else:
        assert isinstance(expression, int)
    return (referenced_variable_names, referenced_region_names)


POINTER_FIELDS = {
    "location": {"location", "name", "slot", "offset", "length"},
    "group": {"group"},
    "list": {"list"},
    "if": {"if", "then", "else"},
    "define": {"define", "in"},
    "templates": {"templates", "in"},
    "template": {"template", "yields"},
}


def pointer_variant(pointer):
    variants = set(pointer) & set(POINTER_FIELDS)
    assert len(variants) == 1, f"Unhandled pointer variant: {pointer}"
    variant = variants.pop()
    assert set(pointer) <= POINTER_FIELDS[variant], f"Unhandled fields in {pointer}"
    if variant == "list":
        assert set(pointer["list"]) == {"count", "each", "is"}
    return variant


def extract_defined_region_names(pointer, templates, expanding=frozenset(), renamings=()):
    """
    Return (defined_region_names, duplicate_region_names) after template yields.

    Repeated list elements and mutually exclusive branches may reuse names. Each
    template body is checked separately, so recursive references stop at the first cycle.
    """
    variant = pointer_variant(pointer)
    if variant == "location":
        (defined_region_names, duplicate_region_names) = (set(), set())
        if "name" in pointer:
            name = pointer["name"]
            for renaming in renamings:
                name = renaming.get(name, name)
            defined_region_names.add(name)
    elif variant == "group":
        (defined_region_names, duplicate_region_names) = (set(), set())
        for member in pointer["group"]:
            (member_region_names, member_duplicate_region_names) = extract_defined_region_names(
                member,
                templates,
                expanding,
                renamings,
            )
            duplicate_region_names |= member_duplicate_region_names | (defined_region_names & member_region_names)
            defined_region_names |= member_region_names
    elif variant == "if":
        (defined_region_names, duplicate_region_names) = extract_defined_region_names(
            pointer["then"],
            templates,
            expanding,
            renamings,
        )
        if "else" in pointer:
            (else_region_names, else_duplicate_region_names) = extract_defined_region_names(
                pointer["else"],
                templates,
                expanding,
                renamings,
            )
            defined_region_names |= else_region_names
            duplicate_region_names |= else_duplicate_region_names
    elif variant == "list":
        return extract_defined_region_names(pointer["list"]["is"], templates, expanding, renamings)
    elif variant == "define":
        return extract_defined_region_names(pointer["in"], templates, expanding, renamings)
    elif variant == "templates":
        return extract_defined_region_names(pointer["in"], templates | pointer["templates"], expanding, renamings)
    else:
        template_name = pointer["template"]
        assert template_name in templates, f"Unknown template: {template_name}"
        if template_name in expanding:
            return (set(), set())
        return extract_defined_region_names(
            templates[template_name]["for"],
            templates,
            expanding | {template_name},
            (pointer.get("yields", {}), *renamings),
        )
    return (defined_region_names, duplicate_region_names)


@cache
def ethdebug_schema_repository():
    repository = schema_helpers.ethdebug_schema_repository(schema_helpers.ethdebug_schema_dir())
    with open(TEST_DIR / "known_schema_fields.json", encoding="utf8") as file:
        expected_fields = json.load(file)
    fields = schema_helpers.type_and_pointer_schema_fields(repository)
    changed = sorted(name for name in fields.keys() | expected_fields.keys() if fields.get(name) != expected_fields.get(name))
    assert len(changed) == 0, (
        f"Schema fields changed in {', '.join(changed)}. Review the producer and the conformity checks "
        "before updating known_schema_fields.json."
    )
    return repository


class EthdebugTestCase(unittest.TestCase):
    # Set by test/ethdebugSchemaTests.py.
    config = None
    #: The pointer table the templates under test reference, set by the test.
    templates = {}

    @classmethod
    def setUpClass(cls):
        if cls.config is None:
            raise RuntimeError("No configuration. Run the tests through test/ethdebugSchemaTests.py.")
        cls.ethdebug_schema_repository = ethdebug_schema_repository()

    def validate(self, schema_id, instance):
        validator(schema_id, self.ethdebug_schema_repository).validate(instance)

    def assertPointerIsClosed(self, pointer, bound_variables, defined_region_names):
        """
        Every variable in the pointer is bound by a template parameter, a `define` or a
        `list`, and every region a lookup or `~read` refers to is named in the pointer.
        """

        def check_expression(expression):
            (referenced_variables, referenced_regions) = extract_names_referenced_by_pointer_expression(expression)
            self.assertLessEqual(referenced_variables, bound_variables, f"Unbound variable in {expression}")
            self.assertLessEqual(referenced_regions, defined_region_names | {"~this"}, f"Unknown region in {expression}")

        variant = pointer_variant(pointer)
        if variant == "location":
            for key in ("slot", "offset", "length"):
                if key in pointer:
                    check_expression(pointer[key])
        elif variant == "group":
            for member in pointer["group"]:
                self.assertPointerIsClosed(member, bound_variables, defined_region_names)
        elif variant == "list":
            check_expression(pointer["list"]["count"])
            self.assertPointerIsClosed(pointer["list"]["is"], bound_variables | {pointer["list"]["each"]}, defined_region_names)
        elif variant == "if":
            check_expression(pointer["if"])
            self.assertPointerIsClosed(pointer["then"], bound_variables, defined_region_names)
            if "else" in pointer:
                self.assertPointerIsClosed(pointer["else"], bound_variables, defined_region_names)
        elif variant == "define":
            for expression in pointer["define"].values():
                check_expression(expression)
            self.assertPointerIsClosed(pointer["in"], bound_variables | set(pointer["define"]), defined_region_names)
        elif variant == "templates":
            self.assertPointerIsClosed(pointer["in"], bound_variables, defined_region_names)
        else:
            assert variant == "template"
            # The referenced template's parameters are bound where it is referenced.
            self.assertIn(pointer["template"], self.templates, f"Unknown template {pointer['template']}")
            self.assertLessEqual(set(self.templates[pointer["template"]]["expect"]), bound_variables)

    def assertRegionCoversLayoutOffset(self, region, layout_offset):
        """
        A region's offset counts from the most significant byte of the slot, the storage
        layout's from the least significant one; a value of `length` bytes at layout offset
        `o` therefore starts at byte `32 - o - length`. A region without a length covers
        the rest of its slot, and one whose length exceeds a slot starts at the beginning
        of the first one.
        """
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
        assert set(template) == {"expect", "for"}
        self.assertEqual(len(template["expect"]), len(set(template["expect"])))
        (defined_region_names, _) = extract_defined_region_names(template["for"], self.templates)
        self.assertPointerIsClosed(template["for"], set(template["expect"]), defined_region_names)

    def assertTypeDocumentMatchesID(self, type_id, document, types):
        (kind, match) = classify_type_id(type_id)
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
            self.assertEqual(document["contains"], {"type": {"id": storage_located(match.group(1))}})
            if match.group(2) == "dyn":
                self.assertNotIn("count", document)
            else:
                self.assertEqual(int(document["count"], 16), int(match.group(2)))
        elif kind == "mapping":
            self.assertEqual(document["kind"], "mapping")
            self.assertEqual(document["contains"]["key"], {"type": {"id": storage_located(match.group(1))}})
            self.assertEqual(document["contains"]["value"], {"type": {"id": storage_located(match.group(2))}})
        elif kind in ("struct", "enum", "contract", "alias"):
            self.assertEqual(document["kind"], kind)
            self.assertEqual(document["definition"]["name"], match.group(1).replace("$$$", "$"))
            if kind == "struct":
                for member in document["contains"]:
                    self.assertIn("name", member)
            elif kind == "enum":
                self.assertGreater(len(document["values"]), 0)
        elif kind == "function":
            self.assertEqual(document["kind"], "function")
            self.assertIs(document.get(match.group(1)), True)
            parameters = document["contains"]["parameters"]["type"]
            assert set(parameters) == {"id"}
            self.assertEqual(types[parameters["id"]]["kind"], "tuple")
        elif kind == "tuple":
            self.assertEqual(document["kind"], "tuple")
        for referenced_id in referenced_type_ids(document):
            self.assertIn(referenced_id, types, f"{type_id} references unknown type {referenced_id}")


class EthdebugSchemaConformityTest(EthdebugTestCase):
    source_paths = sorted((TEST_DIR / "sources").rglob("*.sol"))

    @classmethod
    def setUpClass(cls):
        """
        Compiles these sources once for the whole class, since every test reads the same output.
        """
        super().setUpClass()
        assert len(cls.source_paths) != 0, "No test sources found."
        cls.standard_json_input = load_standard_json_input(cls.source_paths)
        cls.solc_output = compile_standard_json(cls.config.solc_path, cls.standard_json_input)
        cls.resources = cls.solc_output["ethdebug"]["resources"]

    def check_program_schema(self, output_selection):
        program_validator = validator("schema:ethdebug/format/program", self.ethdebug_schema_repository)
        for (_, contract_name, ethdebug_data) in ethdebug_programs(self.solc_output, output_selection):
            with self.subTest(contract=contract_name):
                program_validator.validate(ethdebug_data)

    def test_creation_program_schema(self):
        self.check_program_schema("evm.bytecode.ethdebug")

    def test_deployed_program_schema(self):
        self.check_program_schema("evm.deployedBytecode.ethdebug")

    def test_resources_schema(self):
        resources_validator = validator("schema:ethdebug/format/info/resources", self.ethdebug_schema_repository)
        resources_validator.validate(self.solc_output["ethdebug"]["resources"])

    def test_compilation_schema(self):
        compilation_validator = validator("schema:ethdebug/format/materials/compilation", self.ethdebug_schema_repository)
        compilation_validator.validate(self.solc_output["ethdebug"]["compilation"])

    def check_program_sanity(self, output_selection, environment):
        source_ids = {source_name: source["id"] for (source_name, source) in self.solc_output["sources"].items()}

        for (source_name, contract_name, ethdebug_data) in ethdebug_programs(self.solc_output, output_selection):
            with self.subTest(contract=contract_name):
                self.assertEqual(ethdebug_data["environment"], environment)
                self.assertEqual(ethdebug_data["contract"]["name"], contract_name)
                self.assertEqual(
                    ethdebug_data["contract"]["definition"]["source"],
                    {
                        "id": source_ids[source_name],
                        "type": "source",
                    },
                )

                instructions = ethdebug_data["instructions"]
                self.assertGreater(len(instructions), 0)
                self.assertEqual(
                    [instruction["offset"] for instruction in instructions],
                    sorted(instruction["offset"] for instruction in instructions),
                )
                self.assertTrue(all(instruction["operation"]["mnemonic"] for instruction in instructions))
                for instruction in instructions:
                    if "code" in instruction.get("context", {}):
                        with self.subTest(offset=instruction["offset"]):
                            self.assertEqual(instruction["context"]["code"]["source"]["type"], "source")


    def test_creation_program_sanity(self):
        self.check_program_sanity("evm.bytecode.ethdebug", "create")

    def test_deployed_program_sanity(self):
        self.check_program_sanity("evm.deployedBytecode.ethdebug", "call")

    def test_compilation_matches_standard_json_sources(self):
        standard_json_sources = {
            source_name: source["id"] for (source_name, source) in self.solc_output["sources"].items()
        }
        ethdebug_sources = {
            source["path"]: source["id"]
            for source in self.solc_output["ethdebug"]["compilation"]["sources"]
        }
        self.assertEqual(ethdebug_sources, standard_json_sources)

    def test_compilation_includes_standard_json_source_contents(self):
        ethdebug_sources = {
            source["path"]: source
            for source in self.solc_output["ethdebug"]["compilation"]["sources"]
        }

        self.assertEqual(set(ethdebug_sources), set(self.standard_json_input["sources"]))
        for (source_name, source_input) in self.standard_json_input["sources"].items():
            self.assertEqual(ethdebug_sources[source_name]["contents"], source_input["content"])
            self.assertEqual(ethdebug_sources[source_name]["language"], "Solidity")

    def test_resources_exclude_compilation(self):
        self.assertNotIn("compilation", self.resources)

    def test_type_documents_match_their_identifiers(self):
        types = self.resources["types"]
        self.assertGreater(len(types), 0)
        for (type_id, document) in types.items():
            with self.subTest(type=type_id):
                self.assertTypeDocumentMatchesID(type_id, document, types)

    def test_definition_locations_refer_to_the_compilation_sources(self):
        source_ids = {source["id"] for source in self.solc_output["ethdebug"]["compilation"]["sources"]}
        for (type_id, document) in self.resources["types"].items():
            location = document.get("definition", {}).get("location")
            if location is not None:
                with self.subTest(type=type_id):
                    self.assertIn(location["source"]["id"], source_ids)
                    self.assertEqual(location["source"]["type"], "source")

    def test_pointer_templates_are_closed(self):
        self.templates = self.resources["pointers"]
        for (name, template) in self.templates.items():
            with self.subTest(pointer=name):
                self.assertTemplateIsClosed(template)

    def test_pointer_region_names_are_unique(self):
        templates = self.resources["pointers"]
        for name, template in templates.items():
            with self.subTest(pointer=name):
                (_, duplicate_region_names) = extract_defined_region_names(template["for"], templates, {name})
                self.assertEqual(len(duplicate_region_names), 0, f"Duplicate region names: {duplicate_region_names}")

    def test_pointer_templates_describe_located_types(self):
        """
        Layout-qualified pointer IDs refer to location-independent type documents.
        """
        types = self.resources["types"]
        pointers = self.resources["pointers"]
        for (name, template) in pointers.items():
            with self.subTest(pointer=name):
                (location, type_id) = name.split("-", 1)
                self.assertIn(location, ("storage", "transient", "memory", "calldata"))
                self.assertIn(type_id, types)
                document = types[type_id]
                kind = document["kind"]
                composite = kind in ("struct", "array", "mapping") or (
                    kind in ("bytes", "string") and "size" not in document
                )
                if location in ("memory", "calldata"):
                    self.assertNotEqual(kind, "mapping")
                    expected = ["offset"]
                elif kind == "mapping":
                    self.assertEqual(location, "storage")
                    expected = ["slot", "key"]
                else:
                    self.assertFalse(location == "transient" and composite)
                    expected = ["slot"] if composite else ["slot", "offset"]
                self.assertEqual(template["expect"], expected)
        layouts = {"storage": "storageLayout", "transient": "transientStorageLayout"}
        for (_, contract_name, contract_output) in contract_outputs(self.solc_output):
            for location, layout_output in layouts.items():
                for variable in contract_output[layout_output]["storage"]:
                    type_id = escaped_type_id(variable["type"])
                    with self.subTest(contract=contract_name, variable=variable["label"]):
                        self.assertIn(f"{location}-{type_id}", pointers)


def load_tests(loader, standard_tests, _pattern):
    """
    Discover resource fixtures alongside the shared-source conformity tests.
    """
    source_paths = sorted(RESOURCES_TEST_DIR.rglob("*.sol"))
    assert len(source_paths) != 0, "No resources test sources found."
    for source_path in source_paths:
        test_case = type(
            f"EthdebugSchemaConformityTest[{source_path.relative_to(RESOURCES_TEST_DIR)}]",
            (EthdebugSchemaConformityTest,),
            {"source_paths": [source_path], "__module__": __name__},
        )
        standard_tests.addTests(loader.loadTestsFromTestCase(test_case))
    return standard_tests
