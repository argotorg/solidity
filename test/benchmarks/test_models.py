"""Unit tests for the shared data model dataclasses in models.py."""

import sys
import unittest
from pathlib import Path

# Allow running from repo root or from test/benchmarks/ directly.
_HERE = Path(__file__).parent
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))

from models import BenchmarkCase, CaseStats, Sample  # noqa: E402


class TestBenchmarkCase(unittest.TestCase):
    """Tests for BenchmarkCase dataclass."""

    def test_instantiation_required_fields(self):
        case = BenchmarkCase(
            case_id="deep-nesting-legacy-off",
            source_path=Path("test/benchmarks/generated/deep_nesting.sol"),
            pipeline="legacy",
            debug_info_mode="off",
        )
        self.assertEqual(case.case_id, "deep-nesting-legacy-off")
        self.assertEqual(case.source_path, Path("test/benchmarks/generated/deep_nesting.sol"))
        self.assertEqual(case.pipeline, "legacy")
        self.assertEqual(case.debug_info_mode, "off")
        self.assertFalse(case.use_standard_json)

    def test_use_standard_json_default_is_false(self):
        case = BenchmarkCase(
            case_id="x",
            source_path=Path("x.sol"),
            pipeline="legacy",
            debug_info_mode="off",
        )
        self.assertFalse(case.use_standard_json)

    def test_use_standard_json_can_be_set_true(self):
        case = BenchmarkCase(
            case_id="rw-legacy-off",
            source_path=Path("real-world/input.json"),
            pipeline="legacy",
            debug_info_mode="off",
            use_standard_json=True,
        )
        self.assertTrue(case.use_standard_json)

    def test_ir_pipeline(self):
        case = BenchmarkCase(
            case_id="wide-contract-ir-on",
            source_path=Path("wide.sol"),
            pipeline="ir",
            debug_info_mode="on",
        )
        self.assertEqual(case.pipeline, "ir")
        self.assertEqual(case.debug_info_mode, "on")

    def test_source_path_is_path_object(self):
        case = BenchmarkCase(
            case_id="c",
            source_path=Path("/abs/path/contract.sol"),
            pipeline="legacy",
            debug_info_mode="off",
        )
        self.assertIsInstance(case.source_path, Path)

    def test_equality(self):
        a = BenchmarkCase("id", Path("a.sol"), "legacy", "off")
        b = BenchmarkCase("id", Path("a.sol"), "legacy", "off")
        self.assertEqual(a, b)

    def test_inequality_different_case_id(self):
        a = BenchmarkCase("id-a", Path("a.sol"), "legacy", "off")
        b = BenchmarkCase("id-b", Path("a.sol"), "legacy", "off")
        self.assertNotEqual(a, b)


class TestSample(unittest.TestCase):
    """Tests for Sample dataclass."""

    def test_instantiation(self):
        s = Sample(
            case_id="deep-nesting-legacy-off",
            elapsed_s=1.234,
            peak_rss_mib=42.5,
            exit_code=0,
        )
        self.assertEqual(s.case_id, "deep-nesting-legacy-off")
        self.assertAlmostEqual(s.elapsed_s, 1.234)
        self.assertAlmostEqual(s.peak_rss_mib, 42.5)
        self.assertEqual(s.exit_code, 0)

    def test_non_zero_exit_code(self):
        s = Sample(case_id="failing-case", elapsed_s=0.1, peak_rss_mib=10.0, exit_code=1)
        self.assertEqual(s.exit_code, 1)

    def test_zero_elapsed_time_allowed(self):
        s = Sample(case_id="c", elapsed_s=0.0, peak_rss_mib=1.0, exit_code=0)
        self.assertEqual(s.elapsed_s, 0.0)

    def test_equality(self):
        a = Sample("c", 1.0, 2.0, 0)
        b = Sample("c", 1.0, 2.0, 0)
        self.assertEqual(a, b)

    def test_inequality_different_elapsed(self):
        a = Sample("c", 1.0, 2.0, 0)
        b = Sample("c", 2.0, 2.0, 0)
        self.assertNotEqual(a, b)

    def test_fields_are_correct_types(self):
        s = Sample(case_id="c", elapsed_s=0.5, peak_rss_mib=100.0, exit_code=0)
        self.assertIsInstance(s.case_id, str)
        self.assertIsInstance(s.elapsed_s, float)
        self.assertIsInstance(s.peak_rss_mib, float)
        self.assertIsInstance(s.exit_code, int)


class TestCaseStats(unittest.TestCase):
    """Tests for CaseStats dataclass."""

    def _make_stats(self, **overrides):
        defaults = dict(
            case_id="deep-nesting-legacy-off",
            pipeline="legacy",
            debug_info_mode="off",
            repeat_count=3,
            time_median_s=1.2,
            time_mean_s=1.25,
            time_variance_s2=0.01,
            rss_median_mib=42.0,
            rss_mean_mib=43.0,
            rss_variance_mib2=0.5,
            failed_count=0,
        )
        defaults.update(overrides)
        return CaseStats(**defaults)

    def test_instantiation_all_fields(self):
        stats = self._make_stats()
        self.assertEqual(stats.case_id, "deep-nesting-legacy-off")
        self.assertEqual(stats.pipeline, "legacy")
        self.assertEqual(stats.debug_info_mode, "off")
        self.assertEqual(stats.repeat_count, 3)
        self.assertAlmostEqual(stats.time_median_s, 1.2)
        self.assertAlmostEqual(stats.time_mean_s, 1.25)
        self.assertAlmostEqual(stats.time_variance_s2, 0.01)
        self.assertAlmostEqual(stats.rss_median_mib, 42.0)
        self.assertAlmostEqual(stats.rss_mean_mib, 43.0)
        self.assertAlmostEqual(stats.rss_variance_mib2, 0.5)
        self.assertEqual(stats.failed_count, 0)

    def test_failed_count_nonzero(self):
        stats = self._make_stats(failed_count=2)
        self.assertEqual(stats.failed_count, 2)

    def test_ir_pipeline_debug_on(self):
        stats = self._make_stats(
            case_id="wide-contract-ir-on",
            pipeline="ir",
            debug_info_mode="on",
        )
        self.assertEqual(stats.pipeline, "ir")
        self.assertEqual(stats.debug_info_mode, "on")

    def test_equality(self):
        a = self._make_stats()
        b = self._make_stats()
        self.assertEqual(a, b)

    def test_inequality_different_pipeline(self):
        a = self._make_stats(pipeline="legacy")
        b = self._make_stats(pipeline="ir")
        self.assertNotEqual(a, b)

    def test_all_field_names_present(self):
        stats = self._make_stats()
        expected_fields = {
            "case_id", "pipeline", "debug_info_mode", "repeat_count",
            "time_median_s", "time_mean_s", "time_variance_s2",
            "rss_median_mib", "rss_mean_mib", "rss_variance_mib2",
            "failed_count",
        }
        actual_fields = set(stats.__dataclass_fields__.keys())
        self.assertEqual(actual_fields, expected_fields)

    def test_variance_zero_for_single_sample(self):
        # Represents a run with a single repeat where variance is 0.0
        stats = self._make_stats(repeat_count=1, time_variance_s2=0.0, rss_variance_mib2=0.0)
        self.assertEqual(stats.time_variance_s2, 0.0)
        self.assertEqual(stats.rss_variance_mib2, 0.0)


if __name__ == "__main__":
    unittest.main()
