"""
Unit tests for runner.py.

Covers:
- Command construction for all pipeline/debug_info_mode combinations (mock subprocess)
- run_case returns exactly N samples for N repeats (mock subprocess)
- build_synthetic_cases returns 20 cases (5 categories × 2 pipelines × 2 debug modes)
- Each source/pipeline combo has both debug modes (off and on)
- Missing real-world dir logs warning and returns empty list
- CI log lines have ISO 8601 timestamp prefix when CI env var is set
- log() without CI env var does not add timestamp
"""

from __future__ import annotations

import io
import os
import re
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

_HERE = Path(__file__).parent
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))

from models import BenchmarkCase, Sample  # noqa: E402
from contract_generator import StressCategory  # noqa: E402
import runner as runner_module  # noqa: E402
from runner import (  # noqa: E402
    BenchmarkRunner,
    _measure_peak_rss_mib,
    build_real_world_cases,
    build_synthetic_cases,
    log,
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_FAKE_SOLC = Path("/usr/bin/solc")
_ISO8601_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}")


def _make_case(
    case_id: str = "test-legacy-off",
    source_path: Path = Path("test.sol"),
    pipeline: str = "legacy",
    debug_info_mode: str = "off",
    use_standard_json: bool = False,
) -> BenchmarkCase:
    return BenchmarkCase(
        case_id=case_id,
        source_path=source_path,
        pipeline=pipeline,
        debug_info_mode=debug_info_mode,
        use_standard_json=use_standard_json,
    )


def _fake_completed_process(returncode: int = 0):
    """Return a mock CompletedProcess-like object."""
    mock = MagicMock()
    mock.returncode = returncode
    return mock


# ---------------------------------------------------------------------------
# Tests: log() — CI timestamp behaviour
# ---------------------------------------------------------------------------

class TestLog(unittest.TestCase):
    """Tests for the log() helper function."""

    def _capture_log(self, msg: str, ci_value: str | None) -> str:
        """Call log(msg) with CI env var set/unset and capture stdout."""
        env_patch = {}
        if ci_value is not None:
            env_patch["CI"] = ci_value
        else:
            # Ensure CI is absent
            env_patch.pop("CI", None)

        buf = io.StringIO()
        with patch.dict(os.environ, env_patch, clear=False):
            # Remove CI if we want it absent
            if ci_value is None and "CI" in os.environ:
                with patch.dict(os.environ, {}, clear=False):
                    os.environ.pop("CI", None)
                    with patch("sys.stdout", buf):
                        log(msg)
                    return buf.getvalue()
            with patch("sys.stdout", buf):
                log(msg)
        return buf.getvalue()

    def test_ci_set_adds_timestamp_prefix(self):
        """When CI is non-empty, output should start with ISO 8601 timestamp."""
        buf = io.StringIO()
        with patch.dict(os.environ, {"CI": "true"}, clear=False):
            with patch("sys.stdout", buf):
                log("hello")
        output = buf.getvalue()
        self.assertTrue(
            _ISO8601_RE.match(output),
            f"Expected ISO 8601 prefix, got: {output!r}",
        )

    def test_ci_set_message_follows_timestamp(self):
        """The original message should appear after the timestamp."""
        buf = io.StringIO()
        with patch.dict(os.environ, {"CI": "1"}, clear=False):
            with patch("sys.stdout", buf):
                log("my message")
        output = buf.getvalue()
        self.assertIn("my message", output)

    def test_ci_empty_string_no_timestamp(self):
        """When CI is set to empty string, no timestamp should be added."""
        buf = io.StringIO()
        with patch.dict(os.environ, {"CI": ""}, clear=False):
            with patch("sys.stdout", buf):
                log("plain message")
        output = buf.getvalue().strip()
        self.assertEqual(output, "plain message")

    def test_no_ci_no_timestamp(self):
        """When CI is absent, output should be the message only."""
        buf = io.StringIO()
        env_without_ci = {k: v for k, v in os.environ.items() if k != "CI"}
        with patch.dict(os.environ, env_without_ci, clear=True):
            with patch("sys.stdout", buf):
                log("plain message")
        output = buf.getvalue().strip()
        self.assertEqual(output, "plain message")

    def test_ci_timestamp_format_contains_t_separator(self):
        """ISO 8601 timestamps use 'T' as date/time separator."""
        buf = io.StringIO()
        with patch.dict(os.environ, {"CI": "true"}, clear=False):
            with patch("sys.stdout", buf):
                log("check format")
        output = buf.getvalue()
        # Should contain the 'T' separator and end with 'Z'
        self.assertIn("T", output)
        self.assertIn("Z", output)


# ---------------------------------------------------------------------------
# Tests: command construction
# ---------------------------------------------------------------------------

class TestCommandConstruction(unittest.TestCase):
    """Tests for _build_regular_cmd and _build_standard_json_cmd."""

    def setUp(self):
        self.runner = BenchmarkRunner(solc_path=_FAKE_SOLC, repeats=1)

    def test_legacy_off_contains_optimize_and_bin(self):
        case = _make_case(pipeline="legacy", debug_info_mode="off")
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertIn("--optimize", cmd)
        self.assertIn("--bin", cmd)

    def test_debug_on_omits_optimize(self):
        # --optimize is incompatible with ethdebug (experimental)
        case = _make_case(pipeline="legacy", debug_info_mode="on")
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertNotIn("--optimize", cmd)
        self.assertIn("--bin", cmd)

    def test_debug_on_adds_experimental_flag(self):
        case = _make_case(pipeline="legacy", debug_info_mode="on")
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertIn("--experimental", cmd)

    def test_legacy_off_no_via_ir(self):
        case = _make_case(pipeline="legacy", debug_info_mode="off")
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertNotIn("--via-ir", cmd)

    def test_legacy_off_no_debug_info(self):
        case = _make_case(pipeline="legacy", debug_info_mode="off")
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertNotIn("--debug-info", cmd)
        self.assertNotIn("ethdebug", cmd)

    def test_ir_pipeline_adds_via_ir(self):
        case = _make_case(pipeline="ir", debug_info_mode="off")
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertIn("--via-ir", cmd)

    def test_debug_on_adds_debug_info_ethdebug(self):
        case = _make_case(pipeline="legacy", debug_info_mode="on")
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertIn("--debug-info", cmd)
        self.assertIn("ethdebug", cmd)

    def test_ir_debug_on_has_both_flags(self):
        case = _make_case(pipeline="ir", debug_info_mode="on")
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertIn("--via-ir", cmd)
        self.assertIn("--debug-info", cmd)
        self.assertIn("ethdebug", cmd)

    def test_ir_debug_off_no_debug_info(self):
        case = _make_case(pipeline="ir", debug_info_mode="off")
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertIn("--via-ir", cmd)
        self.assertNotIn("--debug-info", cmd)

    def test_regular_cmd_includes_source_path(self):
        source = Path("/tmp/test.sol")
        case = _make_case(source_path=source)
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertIn(str(source), cmd)

    def test_regular_cmd_starts_with_solc_path(self):
        case = _make_case()
        cmd, _ = self.runner._build_regular_cmd(case)
        self.assertEqual(cmd[0], str(_FAKE_SOLC))

    def test_standard_json_cmd_contains_standard_json_flag(self):
        with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as f:
            f.write(b'{"language": "Solidity"}')
            tmp_path = Path(f.name)
        try:
            case = _make_case(source_path=tmp_path, use_standard_json=True)
            cmd, stdin_data = self.runner._build_standard_json_cmd(case)
            self.assertIn("--standard-json", cmd)
        finally:
            tmp_path.unlink()

    def test_standard_json_cmd_no_bin_flag(self):
        with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as f:
            f.write(b'{"language": "Solidity"}')
            tmp_path = Path(f.name)
        try:
            case = _make_case(source_path=tmp_path, use_standard_json=True)
            cmd, _ = self.runner._build_standard_json_cmd(case)
            self.assertNotIn("--bin", cmd)
        finally:
            tmp_path.unlink()

    def test_standard_json_cmd_passes_file_content_as_stdin(self):
        content = b'{"language": "Solidity", "sources": {}}'
        with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as f:
            f.write(content)
            tmp_path = Path(f.name)
        try:
            case = _make_case(source_path=tmp_path, use_standard_json=True)
            _, stdin_data = self.runner._build_standard_json_cmd(case)
            self.assertEqual(stdin_data, content)
        finally:
            tmp_path.unlink()

    def test_standard_json_ir_pipeline_adds_via_ir(self):
        with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as f:
            f.write(b"{}")
            tmp_path = Path(f.name)
        try:
            case = _make_case(source_path=tmp_path, pipeline="ir", use_standard_json=True)
            cmd, _ = self.runner._build_standard_json_cmd(case)
            self.assertIn("--via-ir", cmd)
        finally:
            tmp_path.unlink()

    def test_standard_json_debug_on_adds_debug_info(self):
        with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as f:
            f.write(b"{}")
            tmp_path = Path(f.name)
        try:
            case = _make_case(
                source_path=tmp_path, debug_info_mode="on", use_standard_json=True
            )
            cmd, _ = self.runner._build_standard_json_cmd(case)
            self.assertIn("--debug-info", cmd)
            self.assertIn("ethdebug", cmd)
        finally:
            tmp_path.unlink()


# ---------------------------------------------------------------------------
# Tests: run_case returns exactly N samples
# ---------------------------------------------------------------------------

class TestRunCase(unittest.TestCase):
    """Tests for BenchmarkRunner.run_case()."""

    def _run_case_mocked(
        self,
        repeats: int,
        returncode: int = 0,
        pipeline: str = "legacy",
        debug_info_mode: str = "off",
        use_standard_json: bool = False,
    ) -> list[Sample]:
        """Run run_case() with subprocess.run mocked out."""
        with tempfile.NamedTemporaryFile(suffix=".sol", delete=False) as f:
            f.write(b"// dummy")
            source_path = Path(f.name)

        try:
            bench_runner = BenchmarkRunner(solc_path=_FAKE_SOLC, repeats=repeats)
            case = _make_case(
                source_path=source_path,
                pipeline=pipeline,
                debug_info_mode=debug_info_mode,
                use_standard_json=use_standard_json,
            )

            mock_result = _fake_completed_process(returncode=returncode)

            with patch("runner.subprocess.run", return_value=mock_result):
                with patch("runner._measure_peak_rss_mib", return_value=42.0):
                    samples = bench_runner.run_case(case)
        finally:
            source_path.unlink()

        return samples

    def test_returns_exactly_1_sample_for_repeats_1(self):
        samples = self._run_case_mocked(repeats=1)
        self.assertEqual(len(samples), 1)

    def test_returns_exactly_3_samples_for_repeats_3(self):
        samples = self._run_case_mocked(repeats=3)
        self.assertEqual(len(samples), 3)

    def test_returns_exactly_5_samples_for_repeats_5(self):
        samples = self._run_case_mocked(repeats=5)
        self.assertEqual(len(samples), 5)

    def test_returns_exactly_10_samples_for_repeats_10(self):
        samples = self._run_case_mocked(repeats=10)
        self.assertEqual(len(samples), 10)

    def test_sample_has_correct_case_id(self):
        samples = self._run_case_mocked(repeats=1)
        self.assertEqual(samples[0].case_id, "test-legacy-off")

    def test_sample_elapsed_s_is_non_negative(self):
        samples = self._run_case_mocked(repeats=3)
        for s in samples:
            self.assertGreaterEqual(s.elapsed_s, 0.0)

    def test_sample_peak_rss_mib_is_mocked_value(self):
        samples = self._run_case_mocked(repeats=2)
        for s in samples:
            self.assertAlmostEqual(s.peak_rss_mib, 42.0)

    def test_sample_exit_code_zero_on_success(self):
        samples = self._run_case_mocked(repeats=1, returncode=0)
        self.assertEqual(samples[0].exit_code, 0)

    def test_sample_exit_code_nonzero_on_failure(self):
        samples = self._run_case_mocked(repeats=1, returncode=1)
        self.assertEqual(samples[0].exit_code, 1)

    def test_continues_after_nonzero_exit(self):
        """run_case should return all repeats even when solc fails."""
        samples = self._run_case_mocked(repeats=3, returncode=1)
        self.assertEqual(len(samples), 3)

    def test_ir_pipeline_run_case_returns_correct_count(self):
        samples = self._run_case_mocked(repeats=2, pipeline="ir")
        self.assertEqual(len(samples), 2)

    def test_debug_on_run_case_returns_correct_count(self):
        samples = self._run_case_mocked(repeats=2, debug_info_mode="on")
        self.assertEqual(len(samples), 2)

    def test_standard_json_run_case_returns_correct_count(self):
        with tempfile.NamedTemporaryFile(suffix=".json", delete=False) as f:
            f.write(b'{"language": "Solidity"}')
            source_path = Path(f.name)
        try:
            bench_runner = BenchmarkRunner(solc_path=_FAKE_SOLC, repeats=3)
            case = _make_case(source_path=source_path, use_standard_json=True)
            mock_result = _fake_completed_process(returncode=0)
            with patch("runner.subprocess.run", return_value=mock_result):
                with patch("runner._measure_peak_rss_mib", return_value=10.0):
                    samples = bench_runner.run_case(case)
        finally:
            source_path.unlink()
        self.assertEqual(len(samples), 3)


# ---------------------------------------------------------------------------
# Tests: build_synthetic_cases
# ---------------------------------------------------------------------------

class TestBuildSyntheticCases(unittest.TestCase):
    """Tests for build_synthetic_cases()."""

    def setUp(self):
        self._tmpdir = tempfile.TemporaryDirectory()
        self.out = Path(self._tmpdir.name)

    def tearDown(self):
        self._tmpdir.cleanup()

    def _cases(self) -> list[BenchmarkCase]:
        return build_synthetic_cases(self.out)

    def test_returns_exactly_20_cases(self):
        cases = self._cases()
        self.assertEqual(len(cases), 20)

    def test_all_five_categories_present(self):
        cases = self._cases()
        category_values = {c.case_id.rsplit("-", 2)[0] for c in cases}
        expected = {cat.value for cat in StressCategory}
        self.assertEqual(category_values, expected)

    def test_both_pipelines_present(self):
        cases = self._cases()
        pipelines = {c.pipeline for c in cases}
        self.assertEqual(pipelines, {"legacy", "ir"})

    def test_both_debug_modes_present(self):
        cases = self._cases()
        debug_modes = {c.debug_info_mode for c in cases}
        self.assertEqual(debug_modes, {"off", "on"})

    def test_each_category_has_4_cases(self):
        """Each category × 2 pipelines × 2 debug modes = 4 cases."""
        cases = self._cases()
        for cat in StressCategory:
            cat_cases = [c for c in cases if c.case_id.startswith(cat.value)]
            self.assertEqual(
                len(cat_cases), 4,
                f"Expected 4 cases for {cat.value}, got {len(cat_cases)}",
            )

    def test_each_source_pipeline_combo_has_both_debug_modes(self):
        """For every (source, pipeline) pair, both 'off' and 'on' must exist."""
        cases = self._cases()
        # Group by (source_path, pipeline)
        combos: dict[tuple, set] = {}
        for c in cases:
            key = (str(c.source_path), c.pipeline)
            combos.setdefault(key, set()).add(c.debug_info_mode)
        for key, modes in combos.items():
            self.assertEqual(
                modes, {"off", "on"},
                f"Combo {key} missing a debug mode: {modes}",
            )

    def test_use_standard_json_is_false_for_all_synthetic(self):
        cases = self._cases()
        for c in cases:
            self.assertFalse(c.use_standard_json, f"Case {c.case_id} should not use standard-json")

    def test_source_files_exist(self):
        cases = self._cases()
        seen_paths = set()
        for c in cases:
            if c.source_path not in seen_paths:
                self.assertTrue(
                    c.source_path.exists(),
                    f"Source file missing: {c.source_path}",
                )
                seen_paths.add(c.source_path)

    def test_case_ids_follow_naming_convention(self):
        """Case IDs should follow pattern: {category}-{pipeline}-{debug_mode}."""
        cases = self._cases()
        valid_pipelines = {"legacy", "ir"}
        valid_debug_modes = {"off", "on"}
        for c in cases:
            parts = c.case_id.rsplit("-", 2)
            self.assertEqual(len(parts), 3, f"Unexpected case_id format: {c.case_id}")
            _, pipeline, debug_mode = parts
            self.assertIn(pipeline, valid_pipelines)
            self.assertIn(debug_mode, valid_debug_modes)


# ---------------------------------------------------------------------------
# Tests: build_real_world_cases
# ---------------------------------------------------------------------------

class TestBuildRealWorldCases(unittest.TestCase):
    """Tests for build_real_world_cases()."""

    def test_missing_dir_returns_empty_list(self):
        non_existent = Path("/tmp/does_not_exist_benchmark_test_xyz_12345")
        cases = build_real_world_cases(non_existent)
        self.assertEqual(cases, [])

    def test_missing_dir_logs_warning(self):
        non_existent = Path("/tmp/does_not_exist_benchmark_test_xyz_12345")
        buf = io.StringIO()
        env_without_ci = {k: v for k, v in os.environ.items() if k != "CI"}
        with patch.dict(os.environ, env_without_ci, clear=True):
            with patch("sys.stdout", buf):
                build_real_world_cases(non_existent)
        output = buf.getvalue()
        self.assertIn("WARNING", output)

    def test_empty_dir_returns_empty_list(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            cases = build_real_world_cases(Path(tmpdir))
        self.assertEqual(cases, [])

    def test_empty_dir_logs_warning(self):
        buf = io.StringIO()
        env_without_ci = {k: v for k, v in os.environ.items() if k != "CI"}
        with tempfile.TemporaryDirectory() as tmpdir:
            with patch.dict(os.environ, env_without_ci, clear=True):
                with patch("sys.stdout", buf):
                    build_real_world_cases(Path(tmpdir))
        output = buf.getvalue()
        self.assertIn("WARNING", output)

    def test_json_files_produce_cases(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            rw_dir = Path(tmpdir)
            (rw_dir / "project-1.0.json").write_text('{"language": "Solidity"}')
            cases = build_real_world_cases(rw_dir)
        self.assertGreater(len(cases), 0)

    def test_each_json_file_produces_4_cases(self):
        """Each JSON file × 2 pipelines × 2 debug modes = 4 cases."""
        with tempfile.TemporaryDirectory() as tmpdir:
            rw_dir = Path(tmpdir)
            (rw_dir / "project-a.json").write_text("{}")
            (rw_dir / "project-b.json").write_text("{}")
            cases = build_real_world_cases(rw_dir)
        self.assertEqual(len(cases), 8)

    def test_real_world_cases_use_standard_json(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            rw_dir = Path(tmpdir)
            (rw_dir / "project.json").write_text("{}")
            cases = build_real_world_cases(rw_dir)
        for c in cases:
            self.assertTrue(c.use_standard_json, f"Case {c.case_id} should use standard-json")

    def test_real_world_cases_have_both_debug_modes(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            rw_dir = Path(tmpdir)
            (rw_dir / "project.json").write_text("{}")
            cases = build_real_world_cases(rw_dir)
        debug_modes = {c.debug_info_mode for c in cases}
        self.assertEqual(debug_modes, {"off", "on"})

    def test_real_world_cases_have_both_pipelines(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            rw_dir = Path(tmpdir)
            (rw_dir / "project.json").write_text("{}")
            cases = build_real_world_cases(rw_dir)
        pipelines = {c.pipeline for c in cases}
        self.assertEqual(pipelines, {"legacy", "ir"})

    def test_non_json_files_are_ignored(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            rw_dir = Path(tmpdir)
            (rw_dir / "project.json").write_text("{}")
            (rw_dir / "readme.txt").write_text("ignore me")
            (rw_dir / "data.sol").write_text("// ignore")
            cases = build_real_world_cases(rw_dir)
        # Only the .json file should produce cases
        self.assertEqual(len(cases), 4)


# ---------------------------------------------------------------------------
# Tests: run_suite
# ---------------------------------------------------------------------------

class TestRunSuite(unittest.TestCase):
    """Tests for BenchmarkRunner.run_suite()."""

    def test_run_suite_accumulates_all_samples(self):
        """run_suite with 3 cases × 2 repeats should return 6 samples."""
        bench_runner = BenchmarkRunner(solc_path=_FAKE_SOLC, repeats=2)

        with tempfile.NamedTemporaryFile(suffix=".sol", delete=False) as f:
            f.write(b"// dummy")
            source_path = Path(f.name)

        try:
            cases = [
                _make_case(case_id=f"case-{i}", source_path=source_path)
                for i in range(3)
            ]
            mock_result = _fake_completed_process(returncode=0)
            with patch("runner.subprocess.run", return_value=mock_result):
                with patch("runner._measure_peak_rss_mib", return_value=10.0):
                    samples = bench_runner.run_suite(cases)
        finally:
            source_path.unlink()

        self.assertEqual(len(samples), 6)

    def test_run_suite_empty_cases_returns_empty(self):
        bench_runner = BenchmarkRunner(solc_path=_FAKE_SOLC, repeats=3)
        samples = bench_runner.run_suite([])
        self.assertEqual(samples, [])

    def test_run_suite_preserves_case_ids(self):
        bench_runner = BenchmarkRunner(solc_path=_FAKE_SOLC, repeats=1)

        with tempfile.NamedTemporaryFile(suffix=".sol", delete=False) as f:
            f.write(b"// dummy")
            source_path = Path(f.name)

        try:
            cases = [
                _make_case(case_id="alpha", source_path=source_path),
                _make_case(case_id="beta", source_path=source_path),
            ]
            mock_result = _fake_completed_process(returncode=0)
            with patch("runner.subprocess.run", return_value=mock_result):
                with patch("runner._measure_peak_rss_mib", return_value=5.0):
                    samples = bench_runner.run_suite(cases)
        finally:
            source_path.unlink()

        case_ids = [s.case_id for s in samples]
        self.assertIn("alpha", case_ids)
        self.assertIn("beta", case_ids)


# ---------------------------------------------------------------------------
# Tests: _measure_peak_rss_mib
# ---------------------------------------------------------------------------

class TestMeasurePeakRssMib(unittest.TestCase):
    """Tests for _measure_peak_rss_mib()."""

    def test_linux_divides_by_1024(self):
        mock_usage = MagicMock()
        mock_usage.ru_maxrss = 102400  # 100 MiB in KB

        with patch("runner.sys.platform", "linux"):
            with patch("resource.getrusage", return_value=mock_usage):
                result = _measure_peak_rss_mib()

        self.assertAlmostEqual(result, 100.0)

    def test_macos_divides_by_1048576(self):
        mock_usage = MagicMock()
        mock_usage.ru_maxrss = 104857600  # 100 MiB in bytes

        with patch("runner.sys.platform", "darwin"):
            with patch("resource.getrusage", return_value=mock_usage):
                result = _measure_peak_rss_mib()

        self.assertAlmostEqual(result, 100.0)

    def test_unsupported_platform_returns_zero(self):
        mock_usage = MagicMock()
        mock_usage.ru_maxrss = 999999

        buf = io.StringIO()
        env_without_ci = {k: v for k, v in os.environ.items() if k != "CI"}
        with patch("runner.sys.platform", "win32"):
            with patch("resource.getrusage", return_value=mock_usage):
                with patch.dict(os.environ, env_without_ci, clear=True):
                    with patch("sys.stdout", buf):
                        result = _measure_peak_rss_mib()

        self.assertEqual(result, 0.0)

    def test_unsupported_platform_logs_warning(self):
        mock_usage = MagicMock()
        mock_usage.ru_maxrss = 1

        buf = io.StringIO()
        env_without_ci = {k: v for k, v in os.environ.items() if k != "CI"}
        with patch("runner.sys.platform", "win32"):
            with patch("resource.getrusage", return_value=mock_usage):
                with patch.dict(os.environ, env_without_ci, clear=True):
                    with patch("sys.stdout", buf):
                        _measure_peak_rss_mib()

        self.assertIn("WARNING", buf.getvalue())


if __name__ == "__main__":
    unittest.main()
