#!/usr/bin/env python3

import json
import os
import subprocess
import unittest
from pathlib import Path


FIXTURE = Path(__file__).resolve().parent
SOURCE = "contract.sol"


class SolidityEthdebugOutputsTest(unittest.TestCase):
    def solc_output(self, *arguments, payload=None):
        return subprocess.run(
            [os.environ["SOLC"], *arguments],
            input=payload,
            cwd=FIXTURE,
            text=True,
            capture_output=True,
            check=True,
        ).stdout

    def compile_standard_json(self, sources, outputs, **settings):
        compiler_input = {
            "language": "Solidity",
            "sources": sources,
            "settings": {
                "experimental": True,
                "outputSelection": {"*": {"*": outputs}},
                **settings,
            },
        }
        output = json.loads(self.solc_output("--standard-json", "--allow-paths", ".", payload=json.dumps(compiler_input)))
        self.assertEqual([diagnostic for diagnostic in output.get("errors", []) if diagnostic["severity"] == "error"], [])
        return output

    def check_metadata(self, metadata, source):
        settings = metadata["settings"]
        self.assertIs(settings["experimental"], True)
        self.assertIs(settings["viaIR"], True)
        self.assertEqual(settings["compilationTarget"], {source: "C"})

    def check_compilation_source(self, compilation, path, contents):
        self.assertEqual(compilation["compiler"]["name"], "solc")
        (source,) = compilation["sources"]
        self.assertEqual(source["path"], path)
        self.assertEqual(source["contents"], contents)
        self.assertEqual(source["language"], "Solidity")
        return source["id"]

    def split_compilation_output(self, output, source):
        header = "======= Debug Data (ethdebug compilation) =======\n"
        self.assertTrue(output.startswith(header))
        (compilation_json, contract) = output.removeprefix(header).split(f"\n======= {source}:C =======\n", 1)
        return (json.loads(compilation_json), contract)

    def test_command_line_metadata_and_program(self):
        output = self.solc_output(
            "--metadata",
            "--experimental",
            "--via-ir",
            "--ethdebug-program",
            "--ethdebug-compilation",
            "--no-cbor-metadata",
            "--pretty-json",
            "--json-indent", "4",
            SOURCE,
        )
        (compilation, metadata_and_program) = self.split_compilation_output(output, SOURCE)
        self.assertTrue(metadata_and_program.startswith("Metadata:\n"))
        metadata_and_program = metadata_and_program.removeprefix("Metadata:\n")
        (metadata_json, program_json) = metadata_and_program.split("\nDebug Data (ethdebug/format/program):\n", 1)

        metadata = json.loads(metadata_json)
        self.check_metadata(metadata, SOURCE)
        self.assertIs(metadata["settings"]["metadata"]["appendCBOR"], False)
        source_id = self.check_compilation_source(
            compilation, SOURCE, (FIXTURE / SOURCE).read_text(encoding="utf8")
        )

        program = json.loads(program_json)
        self.assertEqual(program["ethdebug"]["schema"], "ethdebug/format/program")
        self.assertEqual(program["environment"], "create")
        self.assertEqual(program["contract"]["name"], "C")
        self.assertEqual(program["contract"]["definition"]["source"], {"id": source_id, "type": "source"})

    def test_standard_json_metadata_and_ir(self):
        output = self.compile_standard_json(
            {"C": {"urls": [SOURCE]}}, ["metadata", "ir"], viaIR=True, debug={"debugInfo": ["ast-id", "ethdebug"]}
        )
        self.assertNotIn("ethdebug", output)
        contract = output["contracts"]["C"]["C"]
        self.assertEqual(set(contract), {"metadata", "ir"})
        self.check_metadata(json.loads(contract["metadata"]), "C")
        source_id = output["sources"]["C"]["id"]
        self.assertEqual(contract["ir"].splitlines()[:2], ["/// ethdebug: enabled", f'/// @use-src {source_id}:"C"'])

    def test_command_line_resources(self):
        output = self.solc_output(
            "--experimental", "--ethdebug-resources", "--pretty-json", "--json-indent", "4", "resources.sol"
        )
        header = "======= Debug Data (ethdebug/format/info/resources) =======\n"
        self.assertTrue(output.startswith(header))
        (resources_json, suffix) = output.removeprefix(header).split("\n======= resources.sol:C =======", 1)
        self.assertEqual(suffix.strip(), "")
        self.assertEqual(json.loads(resources_json)["ethdebug"]["schema"], "ethdebug/format/info/resources")

    def test_standard_json_global_output_selection(self):
        source = "//SPDX-License-Identifier: GPL-3.0\npragma solidity >=0.0;\ncontract C { function f() public pure {} }"
        for fields in (("resources",), ("compilation",), ("resources", "compilation")):
            with self.subTest(fields=fields):
                output = self.compile_standard_json({"a.sol": {"content": source}}, [f"ethdebug.{field}" for field in fields])
                debug_output = output["ethdebug"]
                self.assertEqual(set(debug_output), set(fields))
                self.assertNotIn("contracts", output)
                if "compilation" in fields:
                    source_id = self.check_compilation_source(debug_output["compilation"], "a.sol", source)
                    self.assertEqual(source_id, output["sources"]["a.sol"]["id"])

    def test_interfaces_and_abstract_contracts_have_no_programs(self):
        output = self.compile_standard_json(
            {
                "a.sol": {"content": (FIXTURE / "abstract.sol").read_text(encoding="utf8")},
                "b.sol": {"content": (FIXTURE / "interface.sol").read_text(encoding="utf8")},
            },
            ["evm.bytecode.ethdebug", "evm.deployedBytecode.ethdebug", "ethdebug.resources"],
            viaIR=True,
            debug={"debugInfo": ["ast-id", "ethdebug"]},
        )
        self.assertEqual(set(output["contracts"]), {"a.sol", "b.sol"})
        for source in output["contracts"].values():
            evm = source["C"]["evm"]
            self.assertIsNone(evm["bytecode"]["ethdebug"])
            self.assertIsNone(evm["deployedBytecode"]["ethdebug"])
        self.assertIsInstance(output["ethdebug"]["resources"], dict)

    def test_command_line_unimplemented_contracts_have_no_programs(self):
        for source in ("abstract.sol", "interface.sol"):
            with self.subTest(source=source):
                output = self.solc_output(
                    "--experimental", "--via-ir", "--ethdebug-compilation", "--ethdebug-program",
                    "--ethdebug-program-runtime", "--pretty-json", "--json-indent", "4", source,
                )
                (_, programs) = self.split_compilation_output(output, source)
                creation_header = "Debug Data (ethdebug/format/program):\n"
                self.assertTrue(programs.startswith(creation_header))
                (creation, runtime) = programs.removeprefix(creation_header).split(
                    "\nDebug Data of the runtime part (ethdebug/format/program):\n", 1
                )
                self.assertIsNone(json.loads(creation))
                self.assertIsNone(json.loads(runtime))


if __name__ == "__main__":
    unittest.main()
