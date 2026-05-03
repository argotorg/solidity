"""
Unit tests for contract_generator.py.

Covers:
- Each category generates a file at default size
- SPDX and pragma present in all generated files
- Output directory is created if absent
- Line count at size 20 >= 1.5x line count at size 10 for each category
- Structural keywords present per category
"""

from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

_HERE = Path(__file__).parent
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))

from contract_generator import StressCategory, generate  # noqa: E402


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _line_count(text: str) -> int:
    """Return the number of non-empty lines in *text*."""
    return sum(1 for line in text.splitlines() if line.strip())


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class TestGenerateDispatcher(unittest.TestCase):
    """Tests for the generate() dispatcher and file I/O."""

    def setUp(self):
        self._tmpdir = tempfile.TemporaryDirectory()
        self.out = Path(self._tmpdir.name)

    def tearDown(self):
        self._tmpdir.cleanup()

    def test_returns_path_object(self):
        path = generate(StressCategory.WIDE_CONTRACT, size=10, output_dir=self.out)
        self.assertIsInstance(path, Path)

    def test_file_exists_after_generate(self):
        path = generate(StressCategory.WIDE_CONTRACT, size=10, output_dir=self.out)
        self.assertTrue(path.exists(), f"Expected file at {path}")

    def test_filename_matches_category_value(self):
        for cat in StressCategory:
            with self.subTest(category=cat):
                path = generate(cat, size=10, output_dir=self.out)
                self.assertEqual(path.name, f"{cat.value}.sol")

    def test_creates_output_dir_if_absent(self):
        nested = self.out / "a" / "b" / "c"
        self.assertFalse(nested.exists())
        generate(StressCategory.WIDE_CONTRACT, size=5, output_dir=nested)
        self.assertTrue(nested.exists())

    def test_creates_output_dir_if_absent_deep_nesting(self):
        nested = self.out / "new_dir"
        generate(StressCategory.DEEP_NESTING, size=5, output_dir=nested)
        self.assertTrue(nested.exists())

    def test_invalid_size_raises(self):
        with self.assertRaises((ValueError, Exception)):
            generate(StressCategory.WIDE_CONTRACT, size=0, output_dir=self.out)


class TestSpdxAndPragma(unittest.TestCase):
    """Every generated file must contain SPDX identifier and pragma solidity."""

    def setUp(self):
        self._tmpdir = tempfile.TemporaryDirectory()
        self.out = Path(self._tmpdir.name)

    def tearDown(self):
        self._tmpdir.cleanup()

    def test_spdx_present_all_categories(self):
        for cat in StressCategory:
            with self.subTest(category=cat):
                path = generate(cat, size=10, output_dir=self.out)
                source = path.read_text(encoding="utf-8")
                self.assertIn("// SPDX-License-Identifier:", source,
                              f"SPDX missing in {cat.value}")

    def test_pragma_present_all_categories(self):
        for cat in StressCategory:
            with self.subTest(category=cat):
                path = generate(cat, size=10, output_dir=self.out)
                source = path.read_text(encoding="utf-8")
                self.assertIn("pragma solidity", source,
                              f"pragma solidity missing in {cat.value}")

    def test_spdx_gpl_30(self):
        """Spec requires GPL-3.0 specifically."""
        for cat in StressCategory:
            with self.subTest(category=cat):
                path = generate(cat, size=10, output_dir=self.out)
                source = path.read_text(encoding="utf-8")
                self.assertIn("GPL-3.0", source)

    def test_pragma_version_080(self):
        for cat in StressCategory:
            with self.subTest(category=cat):
                path = generate(cat, size=10, output_dir=self.out)
                source = path.read_text(encoding="utf-8")
                self.assertIn("^0.8.0", source)


class TestEachCategoryDefaultSize(unittest.TestCase):
    """Each category generates a non-empty file at default size (10)."""

    def setUp(self):
        self._tmpdir = tempfile.TemporaryDirectory()
        self.out = Path(self._tmpdir.name)

    def tearDown(self):
        self._tmpdir.cleanup()

    def _generate_source(self, cat: StressCategory, size: int = 10) -> str:
        path = generate(cat, size=size, output_dir=self.out)
        return path.read_text(encoding="utf-8")

    def test_deep_nesting_generates_file(self):
        source = self._generate_source(StressCategory.DEEP_NESTING)
        self.assertGreater(len(source), 0)

    def test_wide_contract_generates_file(self):
        source = self._generate_source(StressCategory.WIDE_CONTRACT)
        self.assertGreater(len(source), 0)

    def test_heavy_abi_generates_file(self):
        source = self._generate_source(StressCategory.HEAVY_ABI)
        self.assertGreater(len(source), 0)

    def test_complex_control_flow_generates_file(self):
        source = self._generate_source(StressCategory.COMPLEX_CONTROL_FLOW)
        self.assertGreater(len(source), 0)

    def test_heavy_storage_generates_file(self):
        source = self._generate_source(StressCategory.HEAVY_STORAGE)
        self.assertGreater(len(source), 0)


class TestLineCountScaling(unittest.TestCase):
    """Line count at size 20 must be >= 1.5x line count at size 10 (Req 5.6)."""

    def setUp(self):
        self._tmpdir = tempfile.TemporaryDirectory()
        self.out = Path(self._tmpdir.name)

    def tearDown(self):
        self._tmpdir.cleanup()

    def _line_count_for(self, cat: StressCategory, size: int) -> int:
        path = generate(cat, size=size, output_dir=self.out)
        return _line_count(path.read_text(encoding="utf-8"))

    def test_deep_nesting_scales(self):
        lc10 = self._line_count_for(StressCategory.DEEP_NESTING, 10)
        lc20 = self._line_count_for(StressCategory.DEEP_NESTING, 20)
        self.assertGreaterEqual(lc20, 1.5 * lc10,
            f"deep-nesting: size-20 lines={lc20}, size-10 lines={lc10}, ratio={lc20/lc10:.2f}")

    def test_wide_contract_scales(self):
        lc10 = self._line_count_for(StressCategory.WIDE_CONTRACT, 10)
        lc20 = self._line_count_for(StressCategory.WIDE_CONTRACT, 20)
        self.assertGreaterEqual(lc20, 1.5 * lc10,
            f"wide-contract: size-20 lines={lc20}, size-10 lines={lc10}, ratio={lc20/lc10:.2f}")

    def test_heavy_abi_scales(self):
        lc10 = self._line_count_for(StressCategory.HEAVY_ABI, 10)
        lc20 = self._line_count_for(StressCategory.HEAVY_ABI, 20)
        self.assertGreaterEqual(lc20, 1.5 * lc10,
            f"heavy-abi: size-20 lines={lc20}, size-10 lines={lc10}, ratio={lc20/lc10:.2f}")

    def test_complex_control_flow_scales(self):
        lc10 = self._line_count_for(StressCategory.COMPLEX_CONTROL_FLOW, 10)
        lc20 = self._line_count_for(StressCategory.COMPLEX_CONTROL_FLOW, 20)
        self.assertGreaterEqual(lc20, 1.5 * lc10,
            f"complex-control-flow: size-20 lines={lc20}, size-10 lines={lc10}, ratio={lc20/lc10:.2f}")

    def test_heavy_storage_scales(self):
        lc10 = self._line_count_for(StressCategory.HEAVY_STORAGE, 10)
        lc20 = self._line_count_for(StressCategory.HEAVY_STORAGE, 20)
        self.assertGreaterEqual(lc20, 1.5 * lc10,
            f"heavy-storage: size-20 lines={lc20}, size-10 lines={lc10}, ratio={lc20/lc10:.2f}")


class TestStructuralKeywords(unittest.TestCase):
    """Each category must contain category-appropriate structural keywords."""

    def setUp(self):
        self._tmpdir = tempfile.TemporaryDirectory()
        self.out = Path(self._tmpdir.name)

    def tearDown(self):
        self._tmpdir.cleanup()

    def _source(self, cat: StressCategory, size: int = 10) -> str:
        return generate(cat, size=size, output_dir=self.out).read_text(encoding="utf-8")

    def test_deep_nesting_contains_struct(self):
        source = self._source(StressCategory.DEEP_NESTING)
        self.assertIn("struct", source)

    def test_deep_nesting_contains_nested_struct(self):
        """Should have at least two struct definitions (S1, S2, …)."""
        source = self._source(StressCategory.DEEP_NESTING)
        self.assertGreaterEqual(source.count("struct S"), 2)

    def test_deep_nesting_contains_mapping(self):
        source = self._source(StressCategory.DEEP_NESTING)
        self.assertIn("mapping", source)

    def test_wide_contract_contains_state_variables(self):
        source = self._source(StressCategory.WIDE_CONTRACT)
        # Should have multiple uint256 public var declarations
        self.assertGreaterEqual(source.count("uint256 public var"), 10)

    def test_wide_contract_contains_public_functions(self):
        source = self._source(StressCategory.WIDE_CONTRACT)
        self.assertGreaterEqual(source.count("function"), 10)

    def test_heavy_abi_contains_struct(self):
        source = self._source(StressCategory.HEAVY_ABI)
        self.assertIn("struct", source)

    def test_heavy_abi_contains_array_params(self):
        source = self._source(StressCategory.HEAVY_ABI)
        self.assertIn("[]", source)

    def test_heavy_abi_contains_calldata(self):
        source = self._source(StressCategory.HEAVY_ABI)
        self.assertIn("calldata", source)

    def test_complex_control_flow_contains_if(self):
        source = self._source(StressCategory.COMPLEX_CONTROL_FLOW)
        self.assertIn("if", source)

    def test_complex_control_flow_contains_for(self):
        source = self._source(StressCategory.COMPLEX_CONTROL_FLOW)
        self.assertIn("for", source)

    def test_complex_control_flow_contains_internal_calls(self):
        source = self._source(StressCategory.COMPLEX_CONTROL_FLOW)
        # Internal helper functions should be called
        self.assertIn("_helper", source)

    def test_heavy_storage_contains_mapping(self):
        source = self._source(StressCategory.HEAVY_STORAGE)
        self.assertIn("mapping", source)

    def test_heavy_storage_contains_mapping_of_mapping(self):
        """Should have nested mappings (mapping inside mapping)."""
        source = self._source(StressCategory.HEAVY_STORAGE)
        # A mapping-of-mapping has "mapping" appearing inside another mapping's value type
        self.assertGreaterEqual(source.count("mapping("), 2)

    def test_heavy_storage_contains_dynamic_array_of_struct(self):
        source = self._source(StressCategory.HEAVY_STORAGE)
        # Dynamic array of struct: Record1[] public records1
        self.assertIn("Record", source)
        self.assertIn("[]", source)

    def test_heavy_storage_contains_struct(self):
        source = self._source(StressCategory.HEAVY_STORAGE)
        self.assertIn("struct", source)


class TestStressCategoryEnum(unittest.TestCase):
    """Tests for the StressCategory enum itself."""

    def test_all_five_values_present(self):
        values = {cat.value for cat in StressCategory}
        expected = {
            "deep-nesting",
            "wide-contract",
            "heavy-abi",
            "complex-control-flow",
            "heavy-storage",
        }
        self.assertEqual(values, expected)

    def test_enum_members_by_name(self):
        self.assertEqual(StressCategory.DEEP_NESTING.value, "deep-nesting")
        self.assertEqual(StressCategory.WIDE_CONTRACT.value, "wide-contract")
        self.assertEqual(StressCategory.HEAVY_ABI.value, "heavy-abi")
        self.assertEqual(StressCategory.COMPLEX_CONTROL_FLOW.value, "complex-control-flow")
        self.assertEqual(StressCategory.HEAVY_STORAGE.value, "heavy-storage")


if __name__ == "__main__":
    unittest.main()
