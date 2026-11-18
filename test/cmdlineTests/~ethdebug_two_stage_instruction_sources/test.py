#!/usr/bin/env python3

import json
import os
import subprocess
import sys
import unittest
from pathlib import Path

# pylint: disable=wrong-import-position
PROJECT_ROOT = Path(__file__).parents[3]
sys.path.insert(0, str(PROJECT_ROOT / "scripts"))

from common.cmdline_helpers import add_preamble, inside_temporary_dir
from splitSources import split_sources


def extract_instruction_sources(program):
    return [
        (instruction["offset"], instruction.get("context", {}).get("code"))
        for instruction in program["instructions"]
    ]


class TwoStageInstructionSourcesTest(unittest.TestCase):
    def compile_standard_json(self, compiler_input):
        result = subprocess.run(
            [os.environ["SOLC"], "--standard-json"],
            input=json.dumps(compiler_input),
            text=True,
            capture_output=True,
            check=True,
        )
        output = json.loads(result.stdout)
        errors = [error for error in output.get("errors", []) if error["severity"] == "error"]
        self.assertEqual(errors, [])
        return output

    @inside_temporary_dir(Path(__file__).parent.name)
    def test_instruction_sources_survive_the_yul_stage(self):
        fixture = PROJECT_ROOT / "test/libsolidity/ethdebugTests/inherited_instruction_sources.sol"
        split_sources(fixture, suppress_output=True)
        add_preamble(Path.cwd())
        sources = {
            name: {"content": Path(name).read_text(encoding="utf8")}
            for name in ("A.sol", "B.sol")
        }
        # Keep the Solidity source IDs distinct from the Yul input's ID zero.
        sources["0.sol"] = {"content": ""}
        program_outputs = [
            "evm.bytecode.object",
            "evm.bytecode.ethdebug",
            "evm.deployedBytecode.object",
            "evm.deployedBytecode.ethdebug",
        ]
        settings = {
            "experimental": True,
            "debug": {"debugInfo": ["ast-id", "ethdebug"]},
        }
        solidity_output = self.compile_standard_json({
            "language": "Solidity",
            "sources": sources,
            "settings": {
                **settings,
                "viaIR": True,
                "outputSelection": {
                    "*": {"*": program_outputs + ["ir", "irOptimized", "ethdebug.compilation"]},
                },
            },
        })
        source_ids = {
            source["path"]: source["id"]
            for source in solidity_output["ethdebug"]["compilation"]["sources"]
        }
        expected_source_ids = {source_ids["A.sol"], source_ids["B.sol"]}
        assert 0 not in expected_source_ids
        contract = solidity_output["contracts"]["A.sol"]["Main"]
        for ir_output in ("ir", "irOptimized"):
            with self.subTest(ir=ir_output):
                yul_output = self.compile_standard_json({
                    "language": "Yul",
                    "sources": {"Main.yul": {"content": contract[ir_output]}},
                    "settings": {
                        **settings,
                        "outputSelection": {"*": {"*": program_outputs}},
                    },
                })
                yul_contract = next(iter(yul_output["contracts"]["Main.yul"].values()))
                for kind in ("bytecode", "deployedBytecode"):
                    with self.subTest(program=kind):
                        expected = contract["evm"][kind]
                        actual = yul_contract["evm"][kind]
                        self.assertEqual(actual["object"], expected["object"])
                        expected_sources = extract_instruction_sources(expected["ethdebug"])
                        self.assertEqual(
                            {code["source"]["id"] for (_, code) in expected_sources if code is not None},
                            expected_source_ids,
                        )
                        self.assertEqual(extract_instruction_sources(actual["ethdebug"]), expected_sources)


if __name__ == "__main__":
    unittest.main()
