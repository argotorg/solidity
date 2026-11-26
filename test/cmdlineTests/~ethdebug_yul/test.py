#!/usr/bin/env python3

import json
import os
import subprocess
import unittest
from pathlib import Path


FIXTURE = Path(__file__).resolve().parent
CREATION_AND_RUNTIME = ("bytecode", "deployedBytecode")
DEBUG_INFO = ("location", "snippet", "ast-id", "ethdebug")


class YulEthdebugTest(unittest.TestCase):
    def compile_yul_output(self, source, source_input, outputs, **settings):
        compiler_input = {
            "language": "Yul",
            "sources": {source: source_input},
            "settings": {
                "outputSelection": {"*": {"*": outputs}},
                **settings,
            },
        }
        result = subprocess.run(
            [os.environ["SOLC"], "--standard-json", "--allow-paths", "."],
            input=json.dumps(compiler_input),
            cwd=FIXTURE,
            text=True,
            capture_output=True,
            check=True,
        )
        output = json.loads(result.stdout)
        self.assertEqual([diagnostic for diagnostic in output.get("errors", []) if diagnostic["severity"] == "error"], [])
        self.assertNotIn("ethdebug", output)
        return output

    def compile_yul(
        self, fixture, source, contract, programs, requested_ir=(), expected_ir=(), debug_info=DEBUG_INFO, inline=False,
    ):
        source_input = {"content": (FIXTURE / fixture).read_text(encoding="utf8")} if inline else {"urls": [fixture]}
        outputs = [*(f"evm.{program}.ethdebug" for program in programs), *requested_ir]
        output = self.compile_yul_output(source, source_input, outputs, experimental=True, debug={"debugInfo": debug_info})
        selected = output["contracts"][source][contract]
        self.assertEqual(set(selected), {"evm", *expected_ir})
        self.assertEqual(set(selected["evm"]), set(programs))
        for program in selected["evm"].values():
            self.assertEqual(set(program), {"ethdebug"})
            self.assertEqual(program["ethdebug"]["ethdebug"]["schema"], "ethdebug/format/program")
        return selected

    def instruction(self, program, mnemonic):
        (instruction,) = [item for item in program["instructions"] if item["operation"]["mnemonic"] == mnemonic]
        return instruction

    def check_instruction_source(self, instruction, source_id, offset, length):
        code = instruction["context"]["code"]
        self.assertEqual(code["source"], {"id": source_id, "type": "source"})
        self.assertEqual(code["range"], {"offset": offset, "length": length})

    def test_instruction_sources_use_object_local_ids(self):
        selected = self.compile_yul(
            "instruction_sources.yul", "input.yul", "C", CREATION_AND_RUNTIME, debug_info=("ast-id", "ethdebug")
        )
        for (kind, expected) in (
            ("bytecode", {
                "CALLDATASIZE": (0, 10, 10),
                "PUSH0": (0, 10, 10),
                "SSTORE": (0, 10, 10),
                "STOP": (9, 30, 10),
            }),
            ("deployedBytecode", {
                "CALLDATASIZE": (19, 50, 10),
                "PUSH0": (19, 50, 10),
                "SSTORE": (19, 50, 10),
                "STOP": (14, 70, 10),
            }),
        ):
            for (mnemonic, source_range) in expected.items():
                with self.subTest(kind=kind, mnemonic=mnemonic):
                    instruction = self.instruction(selected["evm"][kind]["ethdebug"], mnemonic)
                    self.check_instruction_source(instruction, *source_range)

    def test_unannotated_yul_uses_the_input_source(self):
        fixture = "native_sources.yul"
        selected = self.compile_yul(
            fixture, "input.yul", "C", CREATION_AND_RUNTIME, debug_info=("ast-id", "ethdebug"), inline=True
        )
        source = (FIXTURE / fixture).read_text(encoding="utf8")
        creation_offset = source.index("stop()")
        runtime_offset = source.index("stop()", creation_offset + 1)
        for (kind, offset) in zip(CREATION_AND_RUNTIME, (creation_offset, runtime_offset)):
            with self.subTest(kind=kind):
                instruction = self.instruction(selected["evm"][kind]["ethdebug"], "STOP")
                self.check_instruction_source(instruction, 0, offset, len("stop()"))

    def test_setimmutable_preserves_value_and_source(self):
        fixture = "assign_immutable.yul"
        selected = self.compile_yul(fixture, "C", "a", ("bytecode",))
        instruction = self.instruction(selected["evm"]["bytecode"]["ethdebug"], "PUSH20")
        value = "0x1234567890123456789012345678901234567890"
        self.assertEqual(instruction["operation"]["arguments"], [value])
        # The assembler takes its absolute position from reprinted Yul.
        code = instruction["context"]["code"]
        self.assertEqual(code["source"], {"id": 0, "type": "source"})
        self.assertEqual(code["range"]["length"], len(value))

    def test_program_output_selection(self):
        for programs in (("deployedBytecode",), CREATION_AND_RUNTIME):
            with self.subTest(programs=programs):
                self.compile_yul("creation_and_runtime.yul", "C", "object", programs)

    def test_global_outputs_are_ignored(self):
        output = self.compile_yul_output(
            "input.yul",
            {"content": 'object "C" { code { stop() } }'},
            ["ethdebug.resources", "ethdebug.compilation", "evm.bytecode.object"],
        )
        bytecode = output["contracts"]["input.yul"]["C"]["evm"]
        self.assertEqual(set(bytecode), {"bytecode"})
        self.assertEqual(set(bytecode["bytecode"]), {"object"})
        self.assertTrue(bytecode["bytecode"]["object"])

    def test_ir_output_selection_and_annotations(self):
        for (debug_info, requested, emitted) in (
            (("ast-id", "ethdebug"), ("ir", "irOptimized"), ("ir", "irOptimized")),
            (DEBUG_INFO, ("ir",), ("ir",)),
            (DEBUG_INFO, ("irOptimized",), ("irOptimized",)),
            (DEBUG_INFO, ("irOptimize",), ()),
        ):
            with self.subTest(outputs=requested):
                output = self.compile_yul(
                    "annotated_deployed.yul", "C", "C_6_deployed", ("bytecode",),
                    requested_ir=requested, expected_ir=emitted, debug_info=debug_info,
                )
                for kind in emitted:
                    ir = output[kind]
                    self.assertEqual(ir.splitlines()[:2], ["/// ethdebug: enabled", '/// @use-src 0:"input.sol"'])
                    self.assertIn("/// @src 0:77:99", ir)


if __name__ == "__main__":
    unittest.main()
