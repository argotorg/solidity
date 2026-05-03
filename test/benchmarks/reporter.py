"""
Statistical reporter for the solc benchmarking infrastructure.

Computes statistics over raw Sample objects, formats results as console tables,
JSON reports, and Markdown comparison diffs.

Can also be run as a standalone script:
    python reporter.py <baseline.json> <current.json>
"""

from __future__ import annotations

import argparse
import json
import statistics
from collections import defaultdict
from datetime import datetime, timezone
from typing import Dict, List

from models import CaseStats, Sample


class Reporter:
    """Stateless reporter: all methods are @staticmethod."""

    # ------------------------------------------------------------------
    # Task 6.1 — compute_stats
    # ------------------------------------------------------------------

    @staticmethod
    def compute_stats(samples: List[Sample]) -> List[CaseStats]:
        """Group samples by case_id and compute aggregated statistics.

        For each group the following are computed using the ``statistics``
        stdlib module:
          - median, arithmetic mean, and sample variance (ddof=1) for
            elapsed_s and peak_rss_mib.
          - failed_count: number of samples whose exit_code != 0.

        A single-sample group has variance 0.0 (statistics.variance would
        raise StatisticsError for n < 2, so we handle that explicitly).

        Returns a list of CaseStats, one per unique case_id, in the order
        the case_ids are first encountered.
        """
        # Preserve insertion order of case_ids.
        groups: Dict[str, List[Sample]] = defaultdict(list)
        for s in samples:
            groups[s.case_id].append(s)

        # We need pipeline / debug_info_mode per case_id.  These come from
        # the BenchmarkCase that produced the samples; the runner embeds
        # them in the Sample's case_id string but does NOT store them on
        # Sample directly.  The runner.py module exposes build_synthetic_cases
        # and build_real_world_cases, but the reporter must not depend on the
        # runner.  Instead we accept that the caller may pass a parallel list
        # of BenchmarkCase objects — however the current interface only takes
        # List[Sample].
        #
        # The design doc says CaseStats has pipeline and debug_info_mode, but
        # Sample does not carry those fields.  We therefore derive them from
        # the case_id convention "{source}-{pipeline}-{debug_info_mode}" by
        # splitting on the last two "-" separated tokens.  This is consistent
        # with the case-ID convention documented in design.md.

        result: List[CaseStats] = []
        for case_id, grp in groups.items():
            times = [s.elapsed_s for s in grp]
            rss = [s.peak_rss_mib for s in grp]
            failed = sum(1 for s in grp if s.exit_code != 0)

            t_median = statistics.median(times)
            t_mean = statistics.mean(times)
            t_var = statistics.variance(times) if len(times) > 1 else 0.0

            r_median = statistics.median(rss)
            r_mean = statistics.mean(rss)
            r_var = statistics.variance(rss) if len(rss) > 1 else 0.0

            # Derive pipeline and debug_info_mode from case_id convention.
            # Convention: "...-{pipeline}-{debug_info_mode}"
            # pipeline ∈ {"legacy", "ir"}, debug_info_mode ∈ {"on", "off"}
            parts = case_id.split("-")
            pipeline = "unknown"
            debug_info_mode = "unknown"
            if len(parts) >= 2:
                candidate_dim = parts[-1]
                candidate_pipeline = parts[-2]
                if candidate_dim in ("on", "off"):
                    debug_info_mode = candidate_dim
                if candidate_pipeline in ("legacy", "ir"):
                    pipeline = candidate_pipeline

            result.append(
                CaseStats(
                    case_id=case_id,
                    pipeline=pipeline,
                    debug_info_mode=debug_info_mode,
                    repeat_count=len(grp),
                    time_median_s=t_median,
                    time_mean_s=t_mean,
                    time_variance_s2=t_var,
                    rss_median_mib=r_median,
                    rss_mean_mib=r_mean,
                    rss_variance_mib2=r_var,
                    failed_count=failed,
                )
            )

        return result

    # ------------------------------------------------------------------
    # Task 6.2 — to_json
    # ------------------------------------------------------------------

    @staticmethod
    def to_json(stats: List[CaseStats], solc_version: str = "unknown") -> dict:
        """Produce a JSON-serialisable dict matching the report schema.

        Schema:
          {
            "schema_version": "1",
            "generated_at": "<ISO 8601 UTC>",
            "solc_version": "<str>",
            "cases": [ { ...all 11 CaseStats fields... }, ... ]
          }
        """
        generated_at = datetime.now(tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

        cases = []
        for cs in stats:
            cases.append(
                {
                    "case_id": cs.case_id,
                    "pipeline": cs.pipeline,
                    "debug_info_mode": cs.debug_info_mode,
                    "repeat_count": cs.repeat_count,
                    "failed_count": cs.failed_count,
                    "time_median_s": cs.time_median_s,
                    "time_mean_s": cs.time_mean_s,
                    "time_variance_s2": cs.time_variance_s2,
                    "rss_median_mib": cs.rss_median_mib,
                    "rss_mean_mib": cs.rss_mean_mib,
                    "rss_variance_mib2": cs.rss_variance_mib2,
                }
            )

        return {
            "schema_version": "1",
            "generated_at": generated_at,
            "solc_version": solc_version,
            "cases": cases,
        }

    # ------------------------------------------------------------------
    # Task 6.3 — format_table
    # ------------------------------------------------------------------

    @staticmethod
    def format_table(stats: List[CaseStats]) -> str:
        """Render a plain-text console table.

        Columns (fixed-width):
          case_id | pipeline | debug_info_mode | median_time_s | median_rss_mib | samples
        """
        # Column headers
        headers = [
            "case_id",
            "pipeline",
            "debug_info_mode",
            "median_time_s",
            "median_rss_mib",
            "samples",
        ]

        # Build rows as strings first so we can compute column widths.
        rows = []
        for cs in stats:
            rows.append(
                [
                    cs.case_id,
                    cs.pipeline,
                    cs.debug_info_mode,
                    f"{cs.time_median_s:.2f}",
                    str(int(cs.rss_median_mib)),
                    str(cs.repeat_count),
                ]
            )

        # Compute column widths (max of header and all row values).
        col_widths = [len(h) for h in headers]
        for row in rows:
            for i, cell in enumerate(row):
                col_widths[i] = max(col_widths[i], len(cell))

        def fmt_row(cells: List[str]) -> str:
            return "  ".join(cell.ljust(col_widths[i]) for i, cell in enumerate(cells))

        separator = "  ".join("-" * w for w in col_widths)

        lines = [fmt_row(headers), separator]
        for row in rows:
            lines.append(fmt_row(row))

        return "\n".join(lines)

    # ------------------------------------------------------------------
    # Task 6.4 — compare
    # ------------------------------------------------------------------

    @staticmethod
    def compare(baseline: dict, current: dict) -> str:
        """Produce a Markdown-formatted regression comparison.

        For each case in *current*:
          - Compute relative % diff vs baseline for median time and RSS.
          - Mark cases absent from baseline as ``!B``.
          - Highlight (⚠) cases where debug_info_mode=="off" and either
            relative time or RSS diff exceeds 5%.

        Also includes a "Debug Info Overhead" section showing
        (debug_on - debug_off) / debug_off * 100% for each case in the
        current run.

        Returns a Markdown string.
        """
        # Index baseline cases by case_id.
        baseline_by_id: Dict[str, dict] = {
            c["case_id"]: c for c in baseline.get("cases", [])
        }
        current_cases: List[dict] = current.get("cases", [])

        # ---- Regression comparison table --------------------------------
        comp_header = (
            "| case_id | pipeline | debug_info_mode "
            "| Δ time % | Δ RSS % | note |"
        )
        comp_sep = "|---|---|---|---|---|---|"
        comp_rows = []

        for cc in current_cases:
            cid = cc["case_id"]
            pipeline = cc.get("pipeline", "")
            dim = cc.get("debug_info_mode", "")
            bc = baseline_by_id.get(cid)

            if bc is None:
                comp_rows.append(
                    f"| {cid} | {pipeline} | {dim} | !B | !B | no baseline |"
                )
                continue

            # Relative % differences.
            def rel_pct(base_val: float, curr_val: float) -> str:
                if base_val == 0:
                    return "N/A"
                pct = (curr_val - base_val) / base_val * 100.0
                sign = "+" if pct >= 0 else ""
                return f"{sign}{pct:.1f}%"

            t_pct_str = rel_pct(bc["time_median_s"], cc["time_median_s"])
            r_pct_str = rel_pct(bc["rss_median_mib"], cc["rss_median_mib"])

            # Determine if we should highlight (⚠).
            warn = ""
            if dim == "off":
                try:
                    t_pct_val = (
                        (cc["time_median_s"] - bc["time_median_s"])
                        / bc["time_median_s"]
                        * 100.0
                    )
                    r_pct_val = (
                        (cc["rss_median_mib"] - bc["rss_median_mib"])
                        / bc["rss_median_mib"]
                        * 100.0
                    )
                    if abs(t_pct_val) > 5.0 or abs(r_pct_val) > 5.0:
                        warn = "⚠"
                except ZeroDivisionError:
                    pass

            comp_rows.append(
                f"| {cid} | {pipeline} | {dim} "
                f"| {t_pct_str} | {r_pct_str} | {warn} |"
            )

        # ---- Debug Info Overhead section --------------------------------
        # Group current cases by (source_prefix, pipeline) to pair off/on.
        # The case_id convention is "{source}-{pipeline}-{debug_info_mode}".
        # We strip the last token to get the "base" key.
        def _base_key(case_id: str) -> str:
            """Return case_id without the trailing '-on' or '-off'."""
            parts = case_id.rsplit("-", 1)
            return parts[0] if len(parts) == 2 and parts[1] in ("on", "off") else case_id

        current_by_id: Dict[str, dict] = {c["case_id"]: c for c in current_cases}

        # Build a map: base_key -> {"off": case_dict, "on": case_dict}
        overhead_map: Dict[str, Dict[str, dict]] = defaultdict(dict)
        for cc in current_cases:
            dim = cc.get("debug_info_mode", "")
            if dim in ("on", "off"):
                overhead_map[_base_key(cc["case_id"])][dim] = cc

        overhead_header = (
            "| base_case | pipeline "
            "| time overhead % | RSS overhead % |"
        )
        overhead_sep = "|---|---|---|---|"
        overhead_rows = []

        for base_key in sorted(overhead_map.keys()):
            pair = overhead_map[base_key]
            off_case = pair.get("off")
            on_case = pair.get("on")
            if off_case is None or on_case is None:
                continue

            pipeline = off_case.get("pipeline", "")

            def overhead_pct(off_val: float, on_val: float) -> str:
                if off_val == 0:
                    return "N/A"
                pct = (on_val - off_val) / off_val * 100.0
                sign = "+" if pct >= 0 else ""
                return f"{sign}{pct:.1f}%"

            t_oh = overhead_pct(off_case["time_median_s"], on_case["time_median_s"])
            r_oh = overhead_pct(off_case["rss_median_mib"], on_case["rss_median_mib"])
            overhead_rows.append(
                f"| {base_key} | {pipeline} | {t_oh} | {r_oh} |"
            )

        # ---- Assemble Markdown output -----------------------------------
        current_ver = current.get("solc_version", "unknown")
        baseline_ver = baseline.get("solc_version", "unknown")

        lines = [
            "## Benchmark Regression Report",
            "",
            f"**Baseline:** `{baseline_ver}`  ",
            f"**Current:** `{current_ver}`",
            "",
            "### Regression Comparison",
            "",
            comp_header,
            comp_sep,
        ]
        lines.extend(comp_rows)

        lines += [
            "",
            "### Debug Info Overhead",
            "",
            "_Overhead of enabling `debug_info_mode=on` relative to `off` in the current run._",
            "",
            overhead_header,
            overhead_sep,
        ]
        lines.extend(overhead_rows)

        return "\n".join(lines)


# ------------------------------------------------------------------
# Task 6.5 — standalone CLI
# ------------------------------------------------------------------

def _main() -> None:
    parser = argparse.ArgumentParser(
        description="Compare two solc benchmark JSON reports and print a Markdown diff."
    )
    parser.add_argument("baseline_json", help="Path to the baseline JSON report file.")
    parser.add_argument("current_json", help="Path to the current JSON report file.")
    args = parser.parse_args()

    with open(args.baseline_json, encoding="utf-8") as fh:
        baseline = json.load(fh)
    with open(args.current_json, encoding="utf-8") as fh:
        current = json.load(fh)

    print(Reporter.compare(baseline, current))


if __name__ == "__main__":
    _main()
