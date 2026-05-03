"""
Unit tests for run.py — covering CLI argument parsing and the wiring of
BenchmarkRunner + Reporter.

Tests use subprocess to invoke run.py for CLI-level checks, and
unittest.mock for unit-level wiring tests.
"""

from __future__ import annotations

import json
import os
import stat
import subprocess
import sys
import tempfile
import unittest
import unittest.mock
from pathlib import Path
from unittest.mock import MagicMock, patch

# Ensure the benchmarks package is importable when running from repo root.
_HERE = Path(__file__).resolve().parent
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))

import run  # noqa: E402 — the module under test
from models import CaseStats, Sample  # noqa: E402

# Path to run.py for subprocess invocations.
_RUN_PY = str(_HERE / "run.py")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_sample(case_id: str = "a-legacy-off", elapsed_s: float = 1.0,
                 peak_rss_mib: float = 10.0, exit_code: int = 0) -> Sample:
    return Sample(case_id=case_id, elapsed_s=elapsed_s,
                  peak_rss_mib=peak_rss_mib, exit_code=exit_code)


def _make_case_stats(case_id: str = "a-legacy-off") -> CaseStats:
    return CaseStats(
        case_id=case_id,
        pipeline="legacy",
        debug_info_mode="off",
        repeat_count=3,
        time_median_s=1.0,
        time_mean_s=1.0,
        time_variance_s2=0.0,
        rss_median_mib=10.0,
        rss_mean_mib=10.0,
        rss_variance_mib2=0.0,
        failed_count=0,
    )


def _make_report_dict(cases: list | None = None) -> dict:
    return {
        "schema_version": "1",
        "generated_at": "2025-01-01T00:00:00Z",
        "solc_version": "test",
        "cases": cases or [],
    }


# ---------------------------------------------------------------------------
# CLI tests via subprocess
# ---------------------------------------------------------------------------

class TestCLIInvalidSuite(unittest.TestCase):
    """Invalid --suite value causes non-zero exit (argparse handles this)."""

    def test_invalid_suite_exits_nonzero(self):
        result = subprocess.run(
            [sys.executable, _RUN_PY, "--suite", "invalid-suite"],
            capture_output=True,
            text=True,
        )
        self.assertNotEqual(result.returncode, 0)

    def test_invalid_suite_prints_to_stderr(self):
        result = subprocess.run(
            [sys.executable, _RUN_PY, "--suite", "bogus"],
            capture_output=True,
            text=True,
        )
        self.assertNotEqual(result.returncode, 0)
        # argparse prints usage/error to stderr
        self.assertTrue(
            len(result.stderr) > 0,
            "Expected error output on stderr for invalid --suite",
        )

    def test_invalid_suite_mentions_valid_choices(self):
        result = subprocess.run(
            [sys.executable, _RUN_PY, "--suite", "nope"],
            capture_output=True,
            text=True,
        )
        # argparse includes the valid choices in the error message
        combined = result.stderr + result.stdout
        self.assertTrue(
            any(choice in combined for choice in ("synthetic", "real-world", "all")),
            "Expected valid choices to appear in error output",
        )


class TestCLIValidSuites(unittest.TestCase):
    """Valid --suite values are accepted by argparse (no parse error)."""

    def _parse_only(self, suite: str) -> argparse.Namespace:
        """Parse args without running the full main() to avoid needing solc."""
        import argparse
        parser = run._build_parser()
        return parser.parse_args(["--suite", suite, "--solc", "/nonexistent"])

    def test_synthetic_accepted(self):
        import argparse
        parser = run._build_parser()
        args = parser.parse_args(["--suite", "synthetic", "--solc", "/x"])
        self.assertEqual(args.suite, "synthetic")

    def test_real_world_accepted(self):
        import argparse
        parser = run._build_parser()
        args = parser.parse_args(["--suite", "real-world", "--solc", "/x"])
        self.assertEqual(args.suite, "real-world")

    def test_all_accepted(self):
        import argparse
        parser = run._build_parser()
        args = parser.parse_args(["--suite", "all", "--solc", "/x"])
        self.assertEqual(args.suite, "all")


class TestCLIDefaults(unittest.TestCase):
    """Default argument values are correct."""

    def _parse(self, extra_args: list | None = None) -> object:
        parser = run._build_parser()
        return parser.parse_args(extra_args or [])

    def test_repeats_default_is_3(self):
        args = self._parse()
        self.assertEqual(args.repeats, 3)

    def test_suite_default_is_all(self):
        args = self._parse()
        self.assertEqual(args.suite, "all")

    def test_output_default_is_none(self):
        args = self._parse()
        self.assertIsNone(args.output)

    def test_baseline_default_is_none(self):
        args = self._parse()
        self.assertIsNone(args.baseline)

    def test_solc_default_is_none_before_resolution(self):
        # The parser stores None; resolution happens in _validate_args.
        args = self._parse()
        self.assertIsNone(args.solc)


class TestCLIMissingOrNonExecutableSolc(unittest.TestCase):
    """Missing/non-executable solc binary causes exit(1) with error to stderr."""

    def test_nonexistent_solc_exits_1(self):
        result = subprocess.run(
            [sys.executable, _RUN_PY, "--solc", "/nonexistent/path/to/solc"],
            capture_output=True,
            text=True,
        )
        self.assertEqual(result.returncode, 1)

    def test_nonexistent_solc_prints_error_to_stderr(self):
        result = subprocess.run(
            [sys.executable, _RUN_PY, "--solc", "/nonexistent/path/to/solc"],
            capture_output=True,
            text=True,
        )
        self.assertIn("error", result.stderr.lower())

    def test_nonexistent_solc_error_mentions_path(self):
        result = subprocess.run(
            [sys.executable, _RUN_PY, "--solc", "/nonexistent/path/to/solc"],
            capture_output=True,
            text=True,
        )
        self.assertIn("/nonexistent/path/to/solc", result.stderr)

    def test_non_executable_file_exits_1(self):
        with tempfile.NamedTemporaryFile(suffix=".sh", delete=False) as f:
            f.write(b"#!/bin/sh\necho hello\n")
            tmp_path = f.name
        try:
            # Remove execute permission.
            os.chmod(tmp_path, stat.S_IRUSR | stat.S_IWUSR)
            result = subprocess.run(
                [sys.executable, _RUN_PY, "--solc", tmp_path],
                capture_output=True,
                text=True,
            )
            self.assertEqual(result.returncode, 1)
            self.assertIn("error", result.stderr.lower())
        finally:
            os.unlink(tmp_path)


# ---------------------------------------------------------------------------
# Unit tests for _validate_args
# ---------------------------------------------------------------------------

class TestValidateArgs(unittest.TestCase):
    """Unit tests for _validate_args() using mock filesystem checks."""

    def _make_args(self, solc: str | None = None) -> object:
        parser = run._build_parser()
        argv = []
        if solc is not None:
            argv += ["--solc", solc]
        return parser.parse_args(argv)

    def test_executable_solc_returns_path(self):
        with tempfile.NamedTemporaryFile(suffix=".bin", delete=False) as f:
            tmp_path = f.name
        try:
            os.chmod(tmp_path, os.stat(tmp_path).st_mode | stat.S_IXUSR)
            args = self._make_args(solc=tmp_path)
            result = run._validate_args(args)
            self.assertEqual(result, Path(tmp_path))
        finally:
            os.unlink(tmp_path)

    def test_non_executable_solc_calls_sys_exit_1(self):
        with tempfile.NamedTemporaryFile(suffix=".bin", delete=False) as f:
            tmp_path = f.name
        try:
            os.chmod(tmp_path, stat.S_IRUSR | stat.S_IWUSR)
            args = self._make_args(solc=tmp_path)
            with self.assertRaises(SystemExit) as ctx:
                run._validate_args(args)
            self.assertEqual(ctx.exception.code, 1)
        finally:
            os.unlink(tmp_path)

    def test_missing_solc_calls_sys_exit_1(self):
        args = self._make_args(solc="/does/not/exist/solc")
        with self.assertRaises(SystemExit) as ctx:
            run._validate_args(args)
        self.assertEqual(ctx.exception.code, 1)


# ---------------------------------------------------------------------------
# Unit tests for _get_solc_version
# ---------------------------------------------------------------------------

class TestGetSolcVersion(unittest.TestCase):
    def test_parses_version_line(self):
        mock_result = MagicMock()
        mock_result.stdout = "solc, the solidity compiler commandline interface\nVersion: 0.8.30+commit.abc\n"
        with patch("subprocess.run", return_value=mock_result):
            version = run._get_solc_version(Path("/fake/solc"))
        self.assertEqual(version, "0.8.30+commit.abc")

    def test_returns_unknown_on_exception(self):
        with patch("subprocess.run", side_effect=Exception("boom")):
            version = run._get_solc_version(Path("/fake/solc"))
        self.assertEqual(version, "unknown")

    def test_returns_unknown_when_no_version_line(self):
        mock_result = MagicMock()
        mock_result.stdout = "some other output\nno version here\n"
        with patch("subprocess.run", return_value=mock_result):
            version = run._get_solc_version(Path("/fake/solc"))
        self.assertEqual(version, "unknown")


# ---------------------------------------------------------------------------
# Unit tests for _build_cases
# ---------------------------------------------------------------------------

class TestBuildCases(unittest.TestCase):
    def test_synthetic_calls_build_synthetic_cases(self):
        with patch("run.build_synthetic_cases", return_value=[]) as mock_syn, \
             patch("run.build_real_world_cases", return_value=[]) as mock_rw:
            result = run._build_cases("synthetic")
            mock_syn.assert_called_once()
            mock_rw.assert_not_called()
            self.assertEqual(result, [])

    def test_real_world_calls_build_real_world_cases(self):
        with patch("run.build_synthetic_cases", return_value=[]) as mock_syn, \
             patch("run.build_real_world_cases", return_value=[]) as mock_rw:
            result = run._build_cases("real-world")
            mock_rw.assert_called_once()
            mock_syn.assert_not_called()
            self.assertEqual(result, [])

    def test_all_calls_both_builders(self):
        fake_syn = [MagicMock()]
        fake_rw = [MagicMock()]
        with patch("run.build_synthetic_cases", return_value=fake_syn), \
             patch("run.build_real_world_cases", return_value=fake_rw):
            result = run._build_cases("all")
            self.assertEqual(len(result), 2)

    def test_synthetic_output_dir_is_under_repo_root(self):
        captured = {}
        def capture_syn(output_dir):
            captured["output_dir"] = output_dir
            return []
        with patch("run.build_synthetic_cases", side_effect=capture_syn), \
             patch("run.build_real_world_cases", return_value=[]):
            run._build_cases("synthetic")
        # output_dir should be inside the repo root
        self.assertIn("test", str(captured["output_dir"]))
        self.assertIn("benchmarks", str(captured["output_dir"]))
        self.assertIn("generated", str(captured["output_dir"]))

    def test_real_world_dir_is_under_repo_root(self):
        captured = {}
        def capture_rw(real_world_dir):
            captured["real_world_dir"] = real_world_dir
            return []
        with patch("run.build_real_world_cases", side_effect=capture_rw):
            run._build_cases("real-world")
        self.assertIn("real-world", str(captured["real_world_dir"]))


# ---------------------------------------------------------------------------
# Unit tests for main() wiring — always exits 0
# ---------------------------------------------------------------------------

class TestMainAlwaysExitsZero(unittest.TestCase):
    """Always exits 0 even when cases fail (mock runner raises exception)."""

    def _run_main_with_mocks(
        self,
        suite: str = "synthetic",
        runner_side_effect=None,
        extra_argv: list | None = None,
    ) -> int:
        """Run main() with a fake executable solc and mocked runner/reporter.

        Returns the exit code (0 on normal completion, or the SystemExit code).
        """
        with tempfile.NamedTemporaryFile(suffix=".bin", delete=False) as f:
            tmp_solc = f.name
        try:
            os.chmod(tmp_solc, os.stat(tmp_solc).st_mode | stat.S_IXUSR)

            argv = [
                "--solc", tmp_solc,
                "--suite", suite,
            ]
            if extra_argv:
                argv += extra_argv

            fake_samples = [_make_sample()]
            fake_stats = [_make_case_stats()]
            fake_report = _make_report_dict()

            mock_runner_instance = MagicMock()
            if runner_side_effect is not None:
                mock_runner_instance.run_suite.side_effect = runner_side_effect
            else:
                mock_runner_instance.run_suite.return_value = fake_samples

            with patch("sys.argv", ["run.py"] + argv), \
                 patch("run.BenchmarkRunner", return_value=mock_runner_instance), \
                 patch("run.build_synthetic_cases", return_value=[]), \
                 patch("run.build_real_world_cases", return_value=[]), \
                 patch("run.Reporter.compute_stats", return_value=fake_stats), \
                 patch("run.Reporter.to_json", return_value=fake_report), \
                 patch("run.Reporter.format_table", return_value="table"), \
                 patch("run._get_solc_version", return_value="0.8.0"), \
                 patch("builtins.print"):
                try:
                    run.main()
                    return 0
                except SystemExit as e:
                    return e.code if e.code is not None else 0
        finally:
            os.unlink(tmp_solc)

    def test_exits_0_on_normal_run(self):
        code = self._run_main_with_mocks()
        self.assertEqual(code, 0)

    def test_exits_0_when_runner_raises_exception(self):
        """Even if the runner raises, main() should exit 0."""
        code = self._run_main_with_mocks(
            runner_side_effect=RuntimeError("solc crashed unexpectedly")
        )
        self.assertEqual(code, 0)

    def test_exits_0_for_synthetic_suite(self):
        code = self._run_main_with_mocks(suite="synthetic")
        self.assertEqual(code, 0)

    def test_exits_0_for_real_world_suite(self):
        code = self._run_main_with_mocks(suite="real-world")
        self.assertEqual(code, 0)

    def test_exits_0_for_all_suite(self):
        code = self._run_main_with_mocks(suite="all")
        self.assertEqual(code, 0)


# ---------------------------------------------------------------------------
# Unit tests for main() — JSON output routing
# ---------------------------------------------------------------------------

class TestMainOutputRouting(unittest.TestCase):
    """JSON report goes to --output file when specified, else to stdout."""

    def _run_main_capturing(self, extra_argv: list | None = None) -> tuple[str, str]:
        """Run main() and return (stdout_output, written_file_content)."""
        with tempfile.NamedTemporaryFile(suffix=".bin", delete=False) as f:
            tmp_solc = f.name
        try:
            os.chmod(tmp_solc, os.stat(tmp_solc).st_mode | stat.S_IXUSR)

            argv = ["--solc", tmp_solc, "--suite", "synthetic"]
            if extra_argv:
                argv += extra_argv

            fake_stats = [_make_case_stats()]
            fake_report = _make_report_dict()

            mock_runner_instance = MagicMock()
            mock_runner_instance.run_suite.return_value = [_make_sample()]

            printed_lines: list[str] = []

            def fake_print(*args, **kwargs):
                printed_lines.append(" ".join(str(a) for a in args))

            with patch("sys.argv", ["run.py"] + argv), \
                 patch("run.BenchmarkRunner", return_value=mock_runner_instance), \
                 patch("run.build_synthetic_cases", return_value=[]), \
                 patch("run.build_real_world_cases", return_value=[]), \
                 patch("run.Reporter.compute_stats", return_value=fake_stats), \
                 patch("run.Reporter.to_json", return_value=fake_report), \
                 patch("run.Reporter.format_table", return_value="TABLE"), \
                 patch("run._get_solc_version", return_value="0.8.0"), \
                 patch("builtins.print", side_effect=fake_print):
                try:
                    run.main()
                except SystemExit:
                    pass

            return "\n".join(printed_lines)
        finally:
            os.unlink(tmp_solc)

    def test_json_written_to_output_file(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            out_path = Path(tmpdir) / "report.json"
            with tempfile.NamedTemporaryFile(suffix=".bin", delete=False) as f:
                tmp_solc = f.name
            try:
                os.chmod(tmp_solc, os.stat(tmp_solc).st_mode | stat.S_IXUSR)

                fake_stats = [_make_case_stats()]
                fake_report = _make_report_dict()
                mock_runner_instance = MagicMock()
                mock_runner_instance.run_suite.return_value = [_make_sample()]

                with patch("sys.argv", ["run.py", "--solc", tmp_solc,
                                        "--suite", "synthetic",
                                        "--output", str(out_path)]), \
                     patch("run.BenchmarkRunner", return_value=mock_runner_instance), \
                     patch("run.build_synthetic_cases", return_value=[]), \
                     patch("run.build_real_world_cases", return_value=[]), \
                     patch("run.Reporter.compute_stats", return_value=fake_stats), \
                     patch("run.Reporter.to_json", return_value=fake_report), \
                     patch("run.Reporter.format_table", return_value="TABLE"), \
                     patch("run._get_solc_version", return_value="0.8.0"), \
                     patch("builtins.print"):
                    try:
                        run.main()
                    except SystemExit:
                        pass

                self.assertTrue(out_path.exists(), "Expected output file to be created")
                content = json.loads(out_path.read_text())
                self.assertIn("schema_version", content)
            finally:
                os.unlink(tmp_solc)

    def test_table_always_printed_to_stdout(self):
        stdout = self._run_main_capturing()
        self.assertIn("TABLE", stdout)

    def test_baseline_comparison_printed_when_provided(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            baseline_path = Path(tmpdir) / "baseline.json"
            baseline_path.write_text(json.dumps(_make_report_dict()), encoding="utf-8")

            with tempfile.NamedTemporaryFile(suffix=".bin", delete=False) as f:
                tmp_solc = f.name
            try:
                os.chmod(tmp_solc, os.stat(tmp_solc).st_mode | stat.S_IXUSR)

                fake_stats = [_make_case_stats()]
                fake_report = _make_report_dict()
                mock_runner_instance = MagicMock()
                mock_runner_instance.run_suite.return_value = [_make_sample()]

                printed_lines: list[str] = []

                def fake_print(*args, **kwargs):
                    printed_lines.append(" ".join(str(a) for a in args))

                with patch("sys.argv", ["run.py", "--solc", tmp_solc,
                                        "--suite", "synthetic",
                                        "--baseline", str(baseline_path)]), \
                     patch("run.BenchmarkRunner", return_value=mock_runner_instance), \
                     patch("run.build_synthetic_cases", return_value=[]), \
                     patch("run.build_real_world_cases", return_value=[]), \
                     patch("run.Reporter.compute_stats", return_value=fake_stats), \
                     patch("run.Reporter.to_json", return_value=fake_report), \
                     patch("run.Reporter.format_table", return_value="TABLE"), \
                     patch("run.Reporter.compare", return_value="## Comparison") as mock_compare, \
                     patch("run._get_solc_version", return_value="0.8.0"), \
                     patch("builtins.print", side_effect=fake_print):
                    try:
                        run.main()
                    except SystemExit:
                        pass

                mock_compare.assert_called_once()
                combined = "\n".join(printed_lines)
                self.assertIn("## Comparison", combined)
            finally:
                os.unlink(tmp_solc)


# ---------------------------------------------------------------------------
# Unit tests for _default_solc_path
# ---------------------------------------------------------------------------

class TestDefaultSolcPath(unittest.TestCase):
    def test_uses_solidity_build_dir_env(self):
        with patch.dict(os.environ, {"SOLIDITY_BUILD_DIR": "/custom/build"}):
            path = run._default_solc_path()
        self.assertEqual(path, Path("/custom/build/solc/solc"))

    def test_falls_back_to_repo_root_build(self):
        env = {k: v for k, v in os.environ.items() if k != "SOLIDITY_BUILD_DIR"}
        with patch.dict(os.environ, env, clear=True):
            path = run._default_solc_path()
        # Should end with build/solc/solc
        self.assertTrue(str(path).endswith("build/solc/solc"))


if __name__ == "__main__":
    unittest.main()
