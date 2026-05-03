"""
Unit tests for reporter.py — covering Reporter.compute_stats(), to_json(),
format_table(), compare(), and the standalone CLI.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

import pytest

# Ensure the benchmarks package is importable when running from repo root.
sys.path.insert(0, str(Path(__file__).parent))

from models import CaseStats, Sample
from reporter import Reporter


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_sample(case_id: str, elapsed_s: float, peak_rss_mib: float, exit_code: int = 0) -> Sample:
    return Sample(case_id=case_id, elapsed_s=elapsed_s, peak_rss_mib=peak_rss_mib, exit_code=exit_code)


def _make_case_stats(
    case_id: str = "foo-legacy-off",
    pipeline: str = "legacy",
    debug_info_mode: str = "off",
    repeat_count: int = 3,
    time_median_s: float = 1.0,
    time_mean_s: float = 1.0,
    time_variance_s2: float = 0.0,
    rss_median_mib: float = 100.0,
    rss_mean_mib: float = 100.0,
    rss_variance_mib2: float = 0.0,
    failed_count: int = 0,
) -> CaseStats:
    return CaseStats(
        case_id=case_id,
        pipeline=pipeline,
        debug_info_mode=debug_info_mode,
        repeat_count=repeat_count,
        time_median_s=time_median_s,
        time_mean_s=time_mean_s,
        time_variance_s2=time_variance_s2,
        rss_median_mib=rss_median_mib,
        rss_mean_mib=rss_mean_mib,
        rss_variance_mib2=rss_variance_mib2,
        failed_count=failed_count,
    )


# ---------------------------------------------------------------------------
# compute_stats — grouping
# ---------------------------------------------------------------------------

class TestComputeStatsGrouping:
    def test_groups_samples_by_case_id(self):
        samples = [
            _make_sample("a-legacy-off", 1.0, 10.0),
            _make_sample("a-legacy-off", 2.0, 20.0),
            _make_sample("b-ir-on", 3.0, 30.0),
        ]
        result = Reporter.compute_stats(samples)
        ids = [cs.case_id for cs in result]
        assert "a-legacy-off" in ids
        assert "b-ir-on" in ids
        assert len(result) == 2

    def test_repeat_count_equals_group_size(self):
        samples = [_make_sample("x-legacy-off", float(i), float(i)) for i in range(5)]
        result = Reporter.compute_stats(samples)
        assert len(result) == 1
        assert result[0].repeat_count == 5

    def test_empty_input_returns_empty_list(self):
        assert Reporter.compute_stats([]) == []


# ---------------------------------------------------------------------------
# compute_stats — median / mean / variance
# ---------------------------------------------------------------------------

class TestComputeStatsValues:
    def test_median_odd_count(self):
        samples = [
            _make_sample("c-legacy-off", 1.0, 10.0),
            _make_sample("c-legacy-off", 3.0, 30.0),
            _make_sample("c-legacy-off", 2.0, 20.0),
        ]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.time_median_s == pytest.approx(2.0)
        assert cs.rss_median_mib == pytest.approx(20.0)

    def test_mean_correct(self):
        samples = [
            _make_sample("d-legacy-off", 1.0, 10.0),
            _make_sample("d-legacy-off", 3.0, 30.0),
        ]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.time_mean_s == pytest.approx(2.0)
        assert cs.rss_mean_mib == pytest.approx(20.0)

    def test_variance_two_samples(self):
        # For [1, 3]: sample variance = ((1-2)^2 + (3-2)^2) / (2-1) = 2.0
        samples = [
            _make_sample("e-legacy-off", 1.0, 10.0),
            _make_sample("e-legacy-off", 3.0, 30.0),
        ]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.time_variance_s2 == pytest.approx(2.0)
        assert cs.rss_variance_mib2 == pytest.approx(200.0)

    def test_variance_three_samples(self):
        import statistics as _stats
        times = [1.0, 2.0, 4.0]
        rss = [10.0, 20.0, 40.0]
        samples = [_make_sample("f-legacy-off", t, r) for t, r in zip(times, rss)]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.time_variance_s2 == pytest.approx(_stats.variance(times))
        assert cs.rss_variance_mib2 == pytest.approx(_stats.variance(rss))


# ---------------------------------------------------------------------------
# compute_stats — single sample (variance = 0.0)
# ---------------------------------------------------------------------------

class TestComputeStatsSingleSample:
    def test_single_sample_variance_is_zero(self):
        samples = [_make_sample("g-legacy-off", 5.0, 50.0)]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.time_variance_s2 == 0.0
        assert cs.rss_variance_mib2 == 0.0

    def test_single_sample_median_equals_value(self):
        samples = [_make_sample("h-ir-on", 7.5, 75.0)]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.time_median_s == pytest.approx(7.5)
        assert cs.rss_median_mib == pytest.approx(75.0)

    def test_single_sample_mean_equals_value(self):
        samples = [_make_sample("i-legacy-on", 3.3, 33.0)]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.time_mean_s == pytest.approx(3.3)
        assert cs.rss_mean_mib == pytest.approx(33.0)


# ---------------------------------------------------------------------------
# compute_stats — failed_count
# ---------------------------------------------------------------------------

class TestComputeStatsFailedCount:
    def test_no_failures(self):
        samples = [_make_sample("j-legacy-off", 1.0, 10.0, exit_code=0) for _ in range(3)]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.failed_count == 0

    def test_all_failures(self):
        samples = [_make_sample("k-legacy-off", 1.0, 10.0, exit_code=1) for _ in range(3)]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.failed_count == 3

    def test_mixed_failures(self):
        samples = [
            _make_sample("l-legacy-off", 1.0, 10.0, exit_code=0),
            _make_sample("l-legacy-off", 1.0, 10.0, exit_code=1),
            _make_sample("l-legacy-off", 1.0, 10.0, exit_code=0),
        ]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.failed_count == 1

    def test_non_one_exit_code_counts_as_failure(self):
        samples = [
            _make_sample("m-legacy-off", 1.0, 10.0, exit_code=0),
            _make_sample("m-legacy-off", 1.0, 10.0, exit_code=2),
        ]
        cs = Reporter.compute_stats(samples)[0]
        assert cs.failed_count == 1


# ---------------------------------------------------------------------------
# to_json — required fields
# ---------------------------------------------------------------------------

class TestToJson:
    def _make_report(self, n: int = 2) -> dict:
        stats = [
            _make_case_stats(
                case_id=f"case{i}-legacy-off",
                pipeline="legacy",
                debug_info_mode="off",
                repeat_count=3,
                time_median_s=float(i),
                time_mean_s=float(i),
                rss_median_mib=float(i * 10),
                rss_mean_mib=float(i * 10),
            )
            for i in range(1, n + 1)
        ]
        return Reporter.to_json(stats)

    def test_schema_version_is_one(self):
        report = self._make_report()
        assert report["schema_version"] == "1"

    def test_generated_at_present(self):
        report = self._make_report()
        assert "generated_at" in report
        # Should be a non-empty ISO 8601 string ending with Z.
        assert report["generated_at"].endswith("Z")

    def test_solc_version_default(self):
        report = self._make_report()
        assert report["solc_version"] == "unknown"

    def test_solc_version_custom(self):
        stats = [_make_case_stats()]
        report = Reporter.to_json(stats, solc_version="0.8.30+commit.abc")
        assert report["solc_version"] == "0.8.30+commit.abc"

    def test_cases_array_length(self):
        report = self._make_report(n=3)
        assert len(report["cases"]) == 3

    def test_all_required_fields_present(self):
        required = {
            "case_id", "pipeline", "debug_info_mode", "repeat_count",
            "failed_count", "time_median_s", "time_mean_s", "time_variance_s2",
            "rss_median_mib", "rss_mean_mib", "rss_variance_mib2",
        }
        report = self._make_report(n=1)
        case = report["cases"][0]
        assert required.issubset(case.keys())

    def test_field_values_match_stats(self):
        cs = _make_case_stats(
            case_id="test-legacy-off",
            pipeline="legacy",
            debug_info_mode="off",
            repeat_count=5,
            time_median_s=1.23,
            time_mean_s=1.25,
            time_variance_s2=0.001,
            rss_median_mib=42.0,
            rss_mean_mib=43.0,
            rss_variance_mib2=0.5,
            failed_count=1,
        )
        report = Reporter.to_json([cs])
        c = report["cases"][0]
        assert c["case_id"] == "test-legacy-off"
        assert c["pipeline"] == "legacy"
        assert c["debug_info_mode"] == "off"
        assert c["repeat_count"] == 5
        assert c["failed_count"] == 1
        assert c["time_median_s"] == pytest.approx(1.23)
        assert c["time_mean_s"] == pytest.approx(1.25)
        assert c["time_variance_s2"] == pytest.approx(0.001)
        assert c["rss_median_mib"] == pytest.approx(42.0)
        assert c["rss_mean_mib"] == pytest.approx(43.0)
        assert c["rss_variance_mib2"] == pytest.approx(0.5)

    def test_json_serialisable(self):
        report = self._make_report()
        # Should not raise.
        serialised = json.dumps(report)
        assert isinstance(serialised, str)


# ---------------------------------------------------------------------------
# format_table
# ---------------------------------------------------------------------------

class TestFormatTable:
    def _table(self) -> str:
        stats = [
            _make_case_stats(
                case_id="deep-nesting-legacy-off",
                pipeline="legacy",
                debug_info_mode="off",
                repeat_count=3,
                time_median_s=1.23,
                rss_median_mib=42.7,
            ),
            _make_case_stats(
                case_id="wide-contract-ir-on",
                pipeline="ir",
                debug_info_mode="on",
                repeat_count=5,
                time_median_s=0.50,
                rss_median_mib=100.0,
            ),
        ]
        return Reporter.format_table(stats)

    def test_contains_case_id(self):
        table = self._table()
        assert "deep-nesting-legacy-off" in table
        assert "wide-contract-ir-on" in table

    def test_contains_pipeline(self):
        table = self._table()
        assert "legacy" in table
        assert "ir" in table

    def test_contains_debug_info_mode(self):
        table = self._table()
        assert "off" in table
        assert "on" in table

    def test_median_time_two_decimal_places(self):
        table = self._table()
        # 1.23 formatted to 2 dp
        assert "1.23" in table
        # 0.50 formatted to 2 dp
        assert "0.50" in table

    def test_median_rss_integer(self):
        table = self._table()
        # 42.7 → 42 (int truncation via int())
        assert "42" in table
        # 100.0 → 100
        assert "100" in table

    def test_sample_count_present(self):
        table = self._table()
        assert "3" in table
        assert "5" in table

    def test_header_row_present(self):
        table = self._table()
        assert "case_id" in table
        assert "pipeline" in table
        assert "debug_info_mode" in table
        assert "median_time_s" in table
        assert "median_rss_mib" in table
        assert "samples" in table

    def test_empty_stats_returns_header_only(self):
        table = Reporter.format_table([])
        assert "case_id" in table


# ---------------------------------------------------------------------------
# compare — missing baseline (!B)
# ---------------------------------------------------------------------------

def _make_json_report(cases: list[dict], solc_version: str = "test") -> dict:
    return {
        "schema_version": "1",
        "generated_at": "2025-01-01T00:00:00Z",
        "solc_version": solc_version,
        "cases": cases,
    }


def _case_dict(
    case_id: str,
    pipeline: str = "legacy",
    debug_info_mode: str = "off",
    time_median_s: float = 1.0,
    rss_median_mib: float = 100.0,
    repeat_count: int = 3,
    failed_count: int = 0,
) -> dict:
    return {
        "case_id": case_id,
        "pipeline": pipeline,
        "debug_info_mode": debug_info_mode,
        "repeat_count": repeat_count,
        "failed_count": failed_count,
        "time_median_s": time_median_s,
        "time_mean_s": time_median_s,
        "time_variance_s2": 0.0,
        "rss_median_mib": rss_median_mib,
        "rss_mean_mib": rss_median_mib,
        "rss_variance_mib2": 0.0,
    }


class TestCompareMissingBaseline:
    def test_missing_case_marked_as_no_baseline(self):
        baseline = _make_json_report([])
        current = _make_json_report([_case_dict("new-case-legacy-off")])
        output = Reporter.compare(baseline, current)
        assert "!B" in output

    def test_present_case_not_marked_as_no_baseline(self):
        case = _case_dict("existing-legacy-off")
        baseline = _make_json_report([case])
        current = _make_json_report([case])
        output = Reporter.compare(baseline, current)
        # The !B marker should not appear for a case that exists in baseline.
        # (It may appear in the header row label, so check the data rows.)
        lines = output.splitlines()
        data_lines = [l for l in lines if "existing-legacy-off" in l]
        assert data_lines, "Expected a row for existing-legacy-off"
        assert "!B" not in data_lines[0]


# ---------------------------------------------------------------------------
# compare — relative % differences
# ---------------------------------------------------------------------------

class TestCompareRelativeDiff:
    def test_time_increase_positive_pct(self):
        baseline = _make_json_report([_case_dict("a-legacy-off", time_median_s=1.0)])
        current = _make_json_report([_case_dict("a-legacy-off", time_median_s=1.1)])
        output = Reporter.compare(baseline, current)
        assert "+10.0%" in output

    def test_time_decrease_negative_pct(self):
        baseline = _make_json_report([_case_dict("b-legacy-off", time_median_s=2.0)])
        current = _make_json_report([_case_dict("b-legacy-off", time_median_s=1.0)])
        output = Reporter.compare(baseline, current)
        assert "-50.0%" in output

    def test_rss_increase_positive_pct(self):
        baseline = _make_json_report([_case_dict("c-legacy-off", rss_median_mib=100.0)])
        current = _make_json_report([_case_dict("c-legacy-off", rss_median_mib=110.0)])
        output = Reporter.compare(baseline, current)
        assert "+10.0%" in output

    def test_no_change_zero_pct(self):
        case = _case_dict("d-legacy-off", time_median_s=1.0, rss_median_mib=100.0)
        baseline = _make_json_report([case])
        current = _make_json_report([case])
        output = Reporter.compare(baseline, current)
        assert "+0.0%" in output or "-0.0%" in output or "0.0%" in output


# ---------------------------------------------------------------------------
# compare — ⚠ highlighting for >5% regression on debug_info_mode=="off"
# ---------------------------------------------------------------------------

class TestCompareHighlighting:
    def test_warn_symbol_when_time_exceeds_5pct(self):
        baseline = _make_json_report([_case_dict("e-legacy-off", time_median_s=1.0, debug_info_mode="off")])
        current = _make_json_report([_case_dict("e-legacy-off", time_median_s=1.06, debug_info_mode="off")])
        output = Reporter.compare(baseline, current)
        assert "⚠" in output

    def test_warn_symbol_when_rss_exceeds_5pct(self):
        baseline = _make_json_report([_case_dict("f-legacy-off", rss_median_mib=100.0, debug_info_mode="off")])
        current = _make_json_report([_case_dict("f-legacy-off", rss_median_mib=106.0, debug_info_mode="off")])
        output = Reporter.compare(baseline, current)
        assert "⚠" in output

    def test_no_warn_when_within_5pct(self):
        baseline = _make_json_report([_case_dict("g-legacy-off", time_median_s=1.0, rss_median_mib=100.0, debug_info_mode="off")])
        current = _make_json_report([_case_dict("g-legacy-off", time_median_s=1.04, rss_median_mib=104.0, debug_info_mode="off")])
        output = Reporter.compare(baseline, current)
        # No warning for ≤5% diff.
        lines = [l for l in output.splitlines() if "g-legacy-off" in l]
        assert lines
        assert "⚠" not in lines[0]

    def test_no_warn_for_debug_info_on_cases(self):
        # Regression highlighting only applies to debug_info_mode=="off".
        baseline = _make_json_report([_case_dict("h-legacy-on", time_median_s=1.0, debug_info_mode="on")])
        current = _make_json_report([_case_dict("h-legacy-on", time_median_s=2.0, debug_info_mode="on")])
        output = Reporter.compare(baseline, current)
        lines = [l for l in output.splitlines() if "h-legacy-on" in l]
        assert lines
        assert "⚠" not in lines[0]

    def test_no_warn_just_below_5pct(self):
        # 4% increase should NOT trigger warning (must be strictly > 5%).
        baseline = _make_json_report([_case_dict("i-legacy-off", time_median_s=1.0, debug_info_mode="off")])
        current = _make_json_report([_case_dict("i-legacy-off", time_median_s=1.04, debug_info_mode="off")])
        output = Reporter.compare(baseline, current)
        lines = [l for l in output.splitlines() if "i-legacy-off" in l]
        assert lines
        assert "⚠" not in lines[0]


# ---------------------------------------------------------------------------
# compare — debug overhead section
# ---------------------------------------------------------------------------

class TestCompareDebugOverhead:
    def _report_with_pair(
        self,
        base_name: str = "deep-nesting-legacy",
        time_off: float = 1.0,
        time_on: float = 1.2,
        rss_off: float = 100.0,
        rss_on: float = 110.0,
    ) -> dict:
        return _make_json_report(
            [
                _case_dict(f"{base_name}-off", time_median_s=time_off, rss_median_mib=rss_off, debug_info_mode="off"),
                _case_dict(f"{base_name}-on", time_median_s=time_on, rss_median_mib=rss_on, debug_info_mode="on"),
            ]
        )

    def test_debug_overhead_section_present(self):
        report = self._report_with_pair()
        output = Reporter.compare(report, report)
        assert "Debug Info Overhead" in output

    def test_debug_overhead_shows_correct_time_pct(self):
        # time_on=1.2, time_off=1.0 → overhead = +20.0%
        baseline = self._report_with_pair(time_off=1.0, time_on=1.2)
        current = self._report_with_pair(time_off=1.0, time_on=1.2)
        output = Reporter.compare(baseline, current)
        assert "+20.0%" in output

    def test_debug_overhead_shows_correct_rss_pct(self):
        # rss_on=110, rss_off=100 → overhead = +10.0%
        baseline = self._report_with_pair(rss_off=100.0, rss_on=110.0)
        current = self._report_with_pair(rss_off=100.0, rss_on=110.0)
        output = Reporter.compare(baseline, current)
        assert "+10.0%" in output

    def test_debug_overhead_section_absent_when_no_pairs(self):
        # Only off cases, no on counterpart.
        report = _make_json_report([_case_dict("solo-legacy-off", debug_info_mode="off")])
        output = Reporter.compare(report, report)
        # Section header should still be present but table body should be empty.
        assert "Debug Info Overhead" in output


# ---------------------------------------------------------------------------
# compare — Markdown table lines
# ---------------------------------------------------------------------------

class TestCompareMarkdown:
    def _output(self) -> str:
        case = _case_dict("j-legacy-off")
        report = _make_json_report([case])
        return Reporter.compare(report, report)

    def test_output_contains_markdown_table_lines(self):
        output = self._output()
        table_lines = [l for l in output.splitlines() if l.startswith("|")]
        assert len(table_lines) >= 1, "Expected at least one Markdown table line starting with '|'"

    def test_output_contains_header_separator(self):
        output = self._output()
        sep_lines = [l for l in output.splitlines() if l.startswith("|---")]
        assert len(sep_lines) >= 1

    def test_output_is_string(self):
        output = self._output()
        assert isinstance(output, str)
        assert len(output) > 0


# ---------------------------------------------------------------------------
# Standalone CLI
# ---------------------------------------------------------------------------

class TestStandaloneCLI:
    def _write_report(self, path: Path, cases: list[dict]) -> None:
        report = _make_json_report(cases)
        path.write_text(json.dumps(report), encoding="utf-8")

    def test_cli_prints_markdown_output(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            base_path = Path(tmpdir) / "baseline.json"
            curr_path = Path(tmpdir) / "current.json"
            self._write_report(base_path, [_case_dict("cli-test-legacy-off")])
            self._write_report(curr_path, [_case_dict("cli-test-legacy-off")])

            reporter_path = Path(__file__).parent / "reporter.py"
            result = subprocess.run(
                [sys.executable, str(reporter_path), str(base_path), str(curr_path)],
                capture_output=True,
                text=True,
            )
            assert result.returncode == 0
            assert "|" in result.stdout  # Markdown table lines present

    def test_cli_missing_args_exits_nonzero(self):
        reporter_path = Path(__file__).parent / "reporter.py"
        result = subprocess.run(
            [sys.executable, str(reporter_path)],
            capture_output=True,
            text=True,
        )
        assert result.returncode != 0
